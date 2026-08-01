# GPU benchmark grid for the fused KA kernel.
#   julia -t auto --project=. bench.jl               # CPU backend (sanity only)
#   julia -t auto --project=. bench.jl cuda          # the real thing
# Measures one outer scenario across configs, prints per-unit costs and
# effective Gsteps/s, and re-times the threaded CPU driver for the same
# workloads so the GPU-vs-CPU column comes from the same process.

include("model.jl")
include("kernels.jl")
using Printf

if length(ARGS) >= 1 && ARGS[1] == "cuda"
    using CUDA
    backend = CUDABackend()
    device_name = CUDA.name(CUDA.device())
else
    backend = CPU()
    device_name = "CPU backend ($(Threads.nthreads()) threads)"
end
println("device: ", device_name)

qx = load_mortality()
fmap = load_fund_map()
rw1 = fund_returns(load_scenarios("scenarios_rw.csv")[1], fmap)
rn = load_scenarios("scenarios_rn.csv")

besttime(f; reps=3) = minimum((f(); @elapsed f()) for _ in 1:reps)

for (inforce_file, N, reps) in (("inforce.csv", 10, 3), ("inforce.csv", 100, 3),
    ("inforce.csv", 500, 2), ("inforce190k.csv", 500, 2))
    inf = load_inforce(inforce_file)
    I = nrow(inf)
    p32, q32, s32 = build_portfolio(inf, qx, Float32)
    rw32 = to_svectors(rw1, Float32)
    rns = [fund_returns(rn[n], fmap) for n in 1:N]
    rns_mat = scenario_matrix(rns, Float32)
    steps = sum(p -> N * (Int(p.tp) * (Int(p.tp) + 1) ÷ 2) + Int(p.tp), p32)

    t_gpu = besttime(() -> value_portfolio_ka(backend, p32, rw32, rns_mat, q32, s32); reps)
    @printf("KA  %-16s I=%6d N=%3d: %8.2f s  %7.3f µs/pol·scen  %6.2f Gsteps/s\n",
        device_name[1:min(end, 16)], I, N, t_gpu, t_gpu / I / N * 1e6, steps / t_gpu / 1e9)

    if I <= 38_000  # CPU comparison on the same workload (Float64, as in the post)
        p64, q64, s64 = build_portfolio(inf, qx, Float64)
        t_cpu = besttime(() -> value_portfolio(p64, to_svectors(rw1),
                [to_svectors(r) for r in rns], q64, s64); reps=min(reps, 2))
        @printf("CPU %d threads (f64)  I=%6d N=%3d: %8.2f s  %7.3f µs/pol·scen  (gpu speedup %.1fx)\n",
            Threads.nthreads(), I, N, t_cpu, t_cpu / I / N * 1e6, t_cpu / t_gpu)
    end
end