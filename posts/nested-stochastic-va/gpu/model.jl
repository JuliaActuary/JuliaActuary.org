# Portable copy of the blog post's model: data loading, the fused kernel
# (Policy/PathState/step), and the threaded CPU driver used as ground truth.
# Semantics identical to ../index.qmd (validated there against the original
# Python to ~1e-11). Generic over the number type FT.

using CSV, DataFrames, StaticArrays

const DATA = joinpath(@__DIR__, "data")
const RISK_FREE = 0.03
const VAL_FREQ = 4
const T = 121

load_inforce(name="inforce.csv") = CSV.read(joinpath(DATA, name), DataFrame)
load_fund_map() = Matrix{Float64}(CSV.read(joinpath(DATA, "fundmap.csv"), DataFrame))

function load_scenarios(name)
    df = CSV.read(joinpath(DATA, name), DataFrame)
    n = maximum(df.scenario)
    scen = reshape(Matrix{Float64}(df[:, r"idx"])', 5, T, n)
    [permutedims(scen[:, :, s]) for s in 1:n]
end

function load_mortality()
    df = CSV.read(joinpath(DATA, "mortality.csv"), DataFrame)
    qx = Dict{String,Vector{Float64}}()
    for sex in ("male", "female")
        v = zeros(146)
        v[df.age.+1] = df[!, sex]
        qx[sex] = v
    end
    qx
end

function mortality_path(qx_by_age, attained_age, is_male)
    rate = qx_by_age[is_male ? "male" : "female"][attained_age+1:end]
    rate3 = repeat(rate[1:31] ./ VAL_FREQ, inner=VAL_FREQ)[1:T]
    rate3[1] = 0.0
    surv = similar(rate3)
    surv[1] = 1.0
    for i in 2:length(rate3)
        surv[i] = surv[i-1] * (1.0 - rate3[i])
    end
    rate3, surv
end

fund_returns(scen, fund_map) = exp.(scen * fund_map)
accum_discount() = exp.(-RISK_FREE / VAL_FREQ .* (0:T-1))

struct Policy{FT}
    funds::SVector{10,FT}
    fees::SVector{10,FT}
    gb_amt::FT
    gmwb_balance::FT
    wd_rate::FT
    withdrawal::FT
    wd_phase::Bool
    use_gb::Bool
    tp::Int32
    mort::Int32
end

struct PathState{FT}
    funds::SVector{10,FT}
    av::FT
    B::FT
    W::FT
    GB::FT
    WAV::FT
end

init_state(p::Policy{FT}) where {FT} =
    PathState(p.funds, sum(p.funds), p.gb_amt, p.withdrawal, p.gmwb_balance, zero(FT))

@inline function step(s::PathState{FT}, p::Policy{FT}, r::SVector{10},
    q_t, surv_t, at_maturity::Bool) where {FT}
    wd_scale = s.av > 0 ? s.WAV / s.av : zero(FT)
    funds = max.(zero(FT), s.funds .* r .* (one(FT) .- p.fees) .- s.funds .* wd_scale)
    av = sum(funds)
    B = p.wd_phase ? s.B - s.W : max(av, s.B)
    W = B * p.wd_rate
    GB = max(zero(FT), s.GB - s.W)
    mbdb = p.use_gb ? GB : B
    payout = max(zero(FT), W - av) * surv_t +
             max(zero(FT), mbdb - av) * q_t * surv_t +
             (at_maturity ? (mbdb - av) * surv_t : zero(FT))
    PathState(funds, av, B, W, GB, min(av, W)), payout
end

function value_policy!(R, Vvec, p::Policy{FT}, rw, rns, q, surv, disc,
    snaps::Vector{PathState{FT}}) where {FT}
    qv = @view q[:, p.mort]
    sv = @view surv[:, p.mort]
    tp = Int(p.tp)
    s = init_state(p)
    snaps[1] = s
    for t in 1:tp
        s, _ = step(s, p, rw[t+1], qv[t+1], sv[t+1], t == tp)
        snaps[t+1] = s
    end
    for rn in rns, sp in 1:tp
        s = snaps[sp]
        pv = zero(FT)
        for t in sp:tp
            s, payout = step(s, p, rn[t+1], qv[t+1], sv[t+1], t == tp)
            d = disc[t-sp+1]
            pv += payout * d
            Vvec[t+1] += payout * d
        end
        R[sp] += pv
    end
    nothing
end

function value_portfolio(policies::Vector{Policy{FT}}, rw, rns, q, surv;
    ntasks=Threads.nthreads()) where {FT}
    disc = FT.(accum_discount())
    chunks = Iterators.partition(eachindex(policies), cld(length(policies), ntasks))
    tasks = map(chunks) do idxs
        Threads.@spawn begin
            R = zeros(FT, T - 1)
            Vvec = zeros(FT, T)
            snaps = Vector{PathState{FT}}(undef, T)
            for i in idxs
                value_policy!(R, Vvec, policies[i], rw, rns, q, surv, disc, snaps)
            end
            R, Vvec
        end
    end
    results = fetch.(tasks)
    sum(first.(results)), sum(last.(results))
end

to_svectors(ret, FT=Float64) = [SVector{10,FT}(view(ret, t, :)) for t in 1:size(ret, 1)]

function build_portfolio(inforce, qx_by_age, FT=Float64)
    keys_ = collect(zip(inforce.AttainedAge, inforce.gender .== "M"))
    uniq = unique(keys_)
    col = Dict(k => Int32(j) for (j, k) in enumerate(uniq))
    q = zeros(FT, T, length(uniq))
    surv = zeros(FT, T, length(uniq))
    for (j, (age, m)) in enumerate(uniq)
        q[:, j], surv[:, j] = mortality_path(qx_by_age, age, m)
    end
    policies = map(1:nrow(inforce)) do i
        row = inforce[i, :]
        Policy{FT}(
            SVector{10,FT}(row[Symbol("FundValue$j")] for j in 1:10),
            SVector{10,FT}(row[Symbol("FundFee$j")] for j in 1:10),
            row.gbAmt, row.gmwbBalance, row.wbWithdrawalRate / VAL_FREQ, row.withdrawal,
            row.withdrawal > 0, row.wbWithdrawalRate > 0,
            Int32(min(ceil(Int, row.ProjectionMonths / 3), T - 1)),
            col[(row.AttainedAge, row.gender == "M")])
    end
    policies, q, surv
end

"Scenario returns as an (N × T) matrix of SVectors — inner-scenario-major so
adjacent GPU threads (same policy, consecutive n) read adjacent memory."
function scenario_matrix(rn_rets, FT=Float32)
    N = length(rn_rets)
    M = Matrix{SVector{10,FT}}(undef, N, T)
    for n in 1:N, t in 1:T
        M[n, t] = SVector{10,FT}(view(rn_rets[n], t, :))
    end
    M
end