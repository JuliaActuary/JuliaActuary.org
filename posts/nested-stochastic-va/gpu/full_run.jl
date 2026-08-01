# The "560-day" computation, measured: 190,000 policies (38K Gan-Valdez block
# tiled 5x) × 1,000 outer × 500 inner scenarios × 120 switch points, exact
# brute force under the reference semantics.
#
#   julia -t auto --project=. full_run.jl cuda
#
# Checkpoints after every outer scenario to results/full_run_R.csv
# (outer, sp, R). Safe to interrupt and rerun: completed outer scenarios are
# skipped. Logs throughput and ETA as it goes.

include("model.jl")
include("kernels.jl")
using Printf

if length(ARGS) >= 1 && ARGS[1] == "cuda"
    using CUDA
    backend = CUDABackend()
else
    @warn "running the FULL problem on the CPU backend — expect days, not hours"
    backend = CPU()
end

const OUTDIR = joinpath(@__DIR__, "results")
const OUTFILE = joinpath(OUTDIR, "full_run_R.csv")
isdir(OUTDIR) || mkpath(OUTDIR)

qx = load_mortality()
fmap = load_fund_map()
rw_all = load_scenarios("scenarios_rw1000.csv")
rn_all = load_scenarios("scenarios_rn.csv")

inf = load_inforce("inforce190k.csv")
p32, q32, s32 = build_portfolio(inf, qx, Float32)
rns_mat = scenario_matrix([fund_returns(r, fmap) for r in rn_all], Float32)
println("portfolio: ", length(p32), " policies; inner: ", size(rns_mat, 1),
    "; outer: ", length(rw_all))

done = Set{Int}()
if isfile(OUTFILE)
    for ln in Iterators.drop(eachline(OUTFILE), 1)
        push!(done, parse(Int, split(ln, ',')[1]))
    end
    println("resuming: ", length(done), " outer scenarios already complete")
else
    open(OUTFILE, "w") do io
        println(io, "outer,sp,R")
    end
end

t_start = time()
n_done_this_run = 0
for m in 1:length(rw_all)
    m in done && continue
    rw32 = to_svectors(fund_returns(rw_all[m], fmap), Float32)
    t = @elapsed R = value_portfolio_ka(backend, p32, rw32, rns_mat, q32, s32)
    open(OUTFILE, "a") do io
        for sp in 1:length(R)
            println(io, m, ",", sp, ",", R[sp])
        end
    end
    global n_done_this_run += 1
    if n_done_this_run % 10 == 1
        rate = (time() - t_start) / n_done_this_run
        remaining = length(rw_all) - length(done) - n_done_this_run
        @printf("outer %4d done in %.1fs; avg %.1fs/outer; ETA %.1f h\n",
            m, t, rate, remaining * rate / 3600)
    end
end
@printf("full run complete: %d outer scenarios in %.2f h (this session)\n",
    n_done_this_run, (time() - t_start) / 3600)