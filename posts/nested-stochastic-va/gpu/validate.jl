# Correctness gate for the KA kernels. Runs on any machine:
#   julia -t auto --project=. validate.jl            # CPU backend (no GPU needed)
#   julia -t auto --project=. validate.jl cuda       # CUDABackend on the A100
# Compares, on 500 policies and on the full 38K block (N=3):
#   1. CPU fused Float64 (ground truth — matches the blog post / original Python)
#   2. CPU fused Float32
#   3. KA kernel, :atomic and :blockreduce, Float32, on the chosen backend
# Pass criteria: KA vs CPU-Float32 tight (same arithmetic, different order);
# everything vs Float64 within Float32 accumulation tolerance (~1e-4).

include("model.jl")
include("kernels.jl")

if length(ARGS) >= 1 && ARGS[1] == "cuda"
    using CUDA
    CUDA.versioninfo()
    backend = CUDABackend()
else
    backend = CPU()
end
println("backend: ", typeof(backend))

relerr(a, b) = maximum(abs.(a .- b) ./ max.(abs.(b), 1e-6))

qx = load_mortality()
fmap = load_fund_map()
rw = load_scenarios("scenarios_rw.csv")
rn = load_scenarios("scenarios_rn.csv")
rw1 = fund_returns(rw[1], fmap)
rns3 = [fund_returns(rn[n], fmap) for n in 1:3]

for (label, nrows) in (("500 policies", 500), ("full 38K block", nothing))
    inf = isnothing(nrows) ? load_inforce() : load_inforce()[1:nrows, :]
    p64, q64, s64 = build_portfolio(inf, qx, Float64)
    R64, _ = value_portfolio(p64, to_svectors(rw1), [to_svectors(r) for r in rns3], q64, s64)

    p32, q32, s32 = build_portfolio(inf, qx, Float32)
    rw32 = to_svectors(rw1, Float32)
    R32cpu, _ = value_portfolio(p32, rw32, [to_svectors(r, Float32) for r in rns3], q32, s32)

    rns_mat = scenario_matrix(rns3, Float32)
    Ratomic = value_portfolio_ka(backend, p32, rw32, rns_mat, q32, s32; kernel=:atomic)
    Rblock = value_portfolio_ka(backend, p32, rw32, rns_mat, q32, s32; kernel=:blockreduce)

    println("== $label")
    println("  ka atomic  vs cpu f32: ", relerr(Ratomic, Float64.(R32cpu)))
    println("  ka blockrd vs cpu f32: ", relerr(Rblock, Float64.(R32cpu)))
    println("  ka blockrd vs cpu f64: ", relerr(Rblock, R64))
    println("  cpu f32    vs cpu f64: ", relerr(Float64.(R32cpu), R64))
end
println("validation complete")