# KernelAbstractions implementation of the fused nested-stochastic valuation.
# The same `step`/`Policy`/`PathState` from model.jl, mapped one work-item per
# (policy, inner scenario). Runs on any KA backend: CPU() for local validation,
# CUDABackend() on the A100.
#
# Thread layout: linear index = (policy-1)*N + n with n fastest, so a warp
# holds one policy's consecutive inner scenarios — snapshot loads broadcast,
# scenario loads coalesce (scenario_matrix is n-major), and the per-policy
# maturity bound tp is warp-uniform (no divergence inside a warp).
#
# Two inner kernels:
#   inner_atomic!      — simple and obviously correct; every (i,n,sp) partial
#                        PV lands in R via an atomic add. Used for validation.
#   inner_blockreduce! — no atomics: each 256-thread workgroup tree-reduces
#                        into Rpart[sp, group]; host sums in Float64.

using KernelAbstractions, Adapt
const KA = KernelAbstractions

@kernel function backbone!(snaps, @Const(policies), @Const(rw), @Const(q), @Const(surv))
    i = @index(Global, Linear)
    p = policies[i]
    s = init_state(p)
    @inbounds snaps[1, i] = s
    tp = Int(p.tp)
    @inbounds for t in 1:tp
        s, _ = step(s, p, rw[t+1], q[t+1, p.mort], surv[t+1, p.mort], t == tp)
        snaps[t+1, i] = s
    end
end

@kernel function inner_atomic!(R, @Const(policies), @Const(snaps), @Const(rns),
    @Const(q), @Const(surv), @Const(disc), N::Int32)
    idx = @index(Global, Linear)
    i = (idx - 1) ÷ N + 1
    n = (idx - 1) % N + 1
    @inbounds begin
        p = policies[i]
        tp = Int(p.tp)
        for sp in 1:tp
            s = snaps[sp, i]
            pv = zero(eltype(R))
            for t in sp:tp
                s, payout = step(s, p, rns[n, t+1], q[t+1, p.mort], surv[t+1, p.mort], t == tp)
                pv += payout * disc[t-sp+1]
            end
            KA.@atomic R[sp] += pv
        end
    end
end

# One launch per switch point: each thread values its (policy, inner scenario)
# continuation from `sp`, then the workgroup tree-reduces into Rpart[sp, group].
# Keeping the sp loop on the host keeps every @synchronize at kernel top level
# (a KA CPU-backend requirement) and lets the GPU pipeline the 120 launches.
@kernel function inner_sp!(Rpart, @Const(policies), @Const(snaps), @Const(rns),
    @Const(q), @Const(surv), @Const(disc), N::Int32, total::Int32, sp::Int32)
    idx = @index(Global, Linear)
    li = @index(Local, Linear)
    grp = @index(Group, Linear)
    shared = @localmem Float32 (256,)

    pv = 0.0f0
    if idx <= total
        i = (Int(idx) - 1) ÷ N + 1
        n = (Int(idx) - 1) % N + 1
        p = @inbounds policies[i]
        tp = Int(p.tp)
        if Int(sp) <= tp
            @inbounds begin
                s = snaps[Int(sp), i]
                for t in Int(sp):tp
                    s, payout = step(s, p, rns[n, t+1], q[t+1, p.mort], surv[t+1, p.mort], t == tp)
                    pv += payout * disc[t-Int(sp)+1]
                end
            end
        end
    end
    @inbounds shared[li] = pv
    @synchronize
    if li <= 128
        @inbounds shared[li] += shared[li+128]
    end
    @synchronize
    if li <= 64
        @inbounds shared[li] += shared[li+64]
    end
    @synchronize
    if li <= 32
        @inbounds shared[li] += shared[li+32]
    end
    @synchronize
    if li <= 16
        @inbounds shared[li] += shared[li+16]
    end
    @synchronize
    if li <= 8
        @inbounds shared[li] += shared[li+8]
    end
    @synchronize
    if li <= 4
        @inbounds shared[li] += shared[li+4]
    end
    @synchronize
    if li <= 2
        @inbounds shared[li] += shared[li+2]
    end
    @synchronize
    if li == 1
        @inbounds Rpart[Int(sp), grp] = shared[1] + shared[2]
    end
end

"""
    value_portfolio_ka(backend, policies, rw_v, rns_mat, q, surv;
                       kernel=:blockreduce, groupsize=256) -> Vector{Float64}

Full fused valuation of one outer scenario on a KA `backend`. Inputs are host
arrays with eltype FT (build with `build_portfolio(inforce, qx, Float32)` and
`scenario_matrix(rns, Float32)`); they are moved to the device here. Returns
R[sp] (switch-point PVs summed over policies and inner scenarios) accumulated
to Float64 on the host.
"""
function value_portfolio_ka(backend, policies::Vector{Policy{FT}}, rw_v, rns_mat, q, surv;
    kernel::Symbol=:blockreduce, groupsize::Int=256) where {FT}
    I = length(policies)
    N = size(rns_mat, 1)
    order = sortperm(policies; by=p -> p.tp, rev=true)  # group similar maturities
    d_pol = adapt(backend, policies[order])
    d_rw = adapt(backend, [SVector{10,FT}(r) for r in rw_v])
    d_rns = adapt(backend, rns_mat)
    d_q = adapt(backend, q)
    d_surv = adapt(backend, surv)
    d_disc = adapt(backend, FT.(accum_discount()))
    snaps = KA.allocate(backend, PathState{FT}, T, I)

    backbone!(backend, groupsize)(snaps, d_pol, d_rw, d_q, d_surv; ndrange=I)

    total = I * N
    if kernel === :atomic
        d_R = KA.zeros(backend, FT, T - 1)
        inner_atomic!(backend, groupsize)(d_R, d_pol, snaps, d_rns, d_q, d_surv,
            d_disc, Int32(N); ndrange=total)
        KA.synchronize(backend)
        return Float64.(Array(d_R))
    elseif kernel === :blockreduce
        groupsize == 256 || error("blockreduce kernel is compiled for groupsize 256")
        padded = cld(total, groupsize) * groupsize
        ngroups = padded ÷ groupsize
        d_Rpart = KA.zeros(backend, Float32, T - 1, ngroups)
        k = inner_sp!(backend, groupsize)
        for sp in 1:T-1
            k(d_Rpart, d_pol, snaps, d_rns, d_q, d_surv,
                d_disc, Int32(N), Int32(total), Int32(sp); ndrange=padded)
        end
        KA.synchronize(backend)
        return vec(sum(Float64.(Array(d_Rpart)), dims=2))
    else
        error("kernel must be :atomic or :blockreduce")
    end
end