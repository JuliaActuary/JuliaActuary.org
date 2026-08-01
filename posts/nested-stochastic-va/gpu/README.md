# GPU follow-up bundle

Everything needed to run the nested-stochastic follow-up on a rented GPU box
(built for a Lambda A100/H100 instance). The KA kernels were validated on the
CPU backend before ever touching a GPU: blockreduce agrees with the blog post's
threaded CPU implementation to ~3e-6 (Float32) on the full 38K block.

## Files

| file | purpose |
|---|---|
| `prep_data.jl` | regenerate all inputs (downloads the Gan–Valdez bundle); also makes the 190K tiled inforce and 1,000 outer scenarios |
| `model.jl` | portable copy of the post's model + threaded CPU driver (ground truth) |
| `kernels.jl` | KernelAbstractions backbone + inner kernels (`:atomic` for checking, `:blockreduce` for speed) and the `value_portfolio_ka` driver |
| `validate.jl` | CPU-vs-KA agreement checks (run with no args locally, `cuda` on the box) |
| `bench.jl` | benchmark grid: 38K × {10,100,500} inner + 190K × 500, GPU vs CPU |
| `bench_cupy.py` | the paper's CuPy rung, `numpy`/`cupy`-switchable (same class both ways) |
| `full_run.jl` | the "560-day" computation: 190K × 1,000 outer × 500 inner, checkpointed to `results/full_run_R.csv`, resumable |
| `setup.sh` | one-time instance setup (juliaup, project instantiate, cupy venv) |

## Order of operations on the instance

```sh
rsync -az gpu/ ubuntu@<ip>:nsva/gpu/          # from the laptop, includes data/
ssh ubuntu@<ip>
cd nsva/gpu && bash setup.sh
export PATH="$HOME/.juliaup/bin:$PATH"
julia -t auto --project=. validate.jl cuda     # must pass before anything else
julia -t auto --project=. bench.jl cuda        # the benchmark grid
.venv/bin/python bench_cupy.py numpy --I 500 --rn 3    # reference values
.venv/bin/python bench_cupy.py cupy  --I 500 --rn 3    # must match numpy
.venv/bin/python bench_cupy.py cupy  --I 38000 --rn 10
.venv/bin/python bench_cupy.py cupy  --I 190000 --rn 10 --inforce inforce190k.csv
nohup julia -t auto --project=. full_run.jl cuda > results/full_run.log 2>&1 &
```

The full run writes `results/full_run_R.csv` (outer, sp, R) incrementally and
can be interrupted/resumed at any time. Expected duration: single-digit hours
on an A100/H100 if the kernel sustains ≥10 Gsteps/s (total work is 1.9e14
policy-quarter-steps).

## Design notes

- Work-item = (policy, inner scenario), inner-scenario-fastest, so warps hold
  one policy: snapshot loads broadcast, scenario loads coalesce (`scenario_matrix`
  is n-major), and per-policy maturity bounds are warp-uniform.
- The blockreduce inner kernel launches once per switch point with all
  `@synchronize`s at kernel top level (KA CPU-backend requirement; also lets
  the GPU pipeline 120 small launches). Workgroup partials are summed on the
  host in Float64.
- Policies are sorted by maturity before upload so workgroups stay coherent.
- Snapshots for 190K policies: `121 × 190,000` `PathState{Float32}` ≈ 1.4 GB.
- Everything is Float32 on device; the blog post measured Float32 vs Float64
  agreement at ~8e-6 on this model.
