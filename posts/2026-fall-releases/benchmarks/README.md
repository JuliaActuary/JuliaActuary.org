# JuliaActuary release benchmarks

These are end-to-end workflow comparisons on the same Julia version and computer. Each environment pins the full dependency stack; differences can include dependency changes as well as changes in the four packages.

| Package | Baseline | Release |
|---|---|---|
| FinanceCore | 2.8.0 | 3.0.0 |
| FinanceModels | 6.5.0 | 7.0.0 |
| ActuaryUtilities | 5.12.0 | 6.0.0 |
| MortalityTables | 2.6.0 | 3.0.0, commit `cae71f5750374cb234826080a7487520d87828e5` |

The MortalityTables source is pinned to the maintainer's designated release commit, tree `8fb7e2ef6bbef04c8aac2c4c87ca9e382ed07470`. It has no dependency on a local checkout.

## Reproduce

Use Julia 1.13.1 and Python 3. From this directory:

```sh
julia --project=baseline --startup-file=no -e 'using Pkg; Pkg.instantiate()'
julia --project=release --startup-file=no -e 'using Pkg; Pkg.instantiate()'
python3 run.py --smoke
python3 run.py
python3 summarize.py
```

`run.py` fixes Julia and BLAS to one thread. For each package it alternates baseline/release in three rounds, with a one-second budget per BenchmarkTools trial. Every workload executes once before timing. Errors abort the run; there is no catch-and-skip path. Each process starts afresh, but timings exclude package loading and compilation. Scalar-only inputs are read through `Ref` to prevent constant folding. Seeds and input sizes are in the four workload scripts.

The blog uses the smallest trial minimum across the three rounds. The CSV also contains the median of the three trial medians, minimum-time variation across rounds, and allocations. Raw trial summaries and machine/version metadata are under `results/`. The maintainer reported other work running on the machine during measurement. Taking the smallest of three trial minima reduces transient interference but cannot remove sustained load or scheduling effects. Treat small differences cautiously; the CSV preserves the variation rather than hiding it. The detailed results include regressions as well as improvements.

## Comparing changed APIs

- FinanceModels uses `Projection` in 6.5 and `Models` in 7.0. Both swaps have quarterly payments. Some valuations change because 7.0 fixes portfolio and projection behavior; these are timings of the same requested workflow, not an assertion that old prices were correct.
- FinanceModels 6.5 cannot refit an existing Linear spline through the public `fit` API. The unchanged-quote and updated-quote rows compare a fresh 6.5 spline fit with a 7.0 refit starting from the previously calibrated curve. The new quotes in the latter row are all 1 bp higher. Separate fresh-fit rows compare both versions without a warm start.
- The zero-volatility CIR row uses the public `discount` call in both versions. Both versions return `0.6954389459421917` for these parameters. The smoke output records returned values as well as whether the call executed.
- AU 5.12 fixed-cashflow and callback sensitivity bundles calculate Hessians; AU 6 therefore uses `SecondOrder()` for those comparisons. Contract bundles expose first derivatives in both versions, although 5.12 computed and discarded an internal Hessian.
- AU 6 removes the two-curve fixed-cashflow forms. Their replacements combine `base + credit` and calculate `duration(DV01(), ...)`, `convexity(...)`, or the second-order bundle. A single convexity block replaces the old repeated identical blocks. DV01 uses the corrected signed convention. The separate two-curve IR01 callback remains in the comparison.
- Hull–White sensitivities use 100 paths, monthly steps and an 11-year horizon in both versions; the payment stream ends at year 10. Both versions request second-order key-rate results.
- MT 2.6 `life_expectancy(law, age)` maps to 3.0 `complete_life_expectancy`; the rate-vector form maps to `curtate_life_expectancy`. `Uniform()` maps to `UniformDeaths()`. Fractional-age survival and some parametric laws intentionally return corrected values.
- The XTbML rows bypass each version's table cache and include file reading, XML parsing and table construction. Parsed ultimate rates are checked against the cached public table. A separate row measures the ordinary cached lookup.
- New functions without a baseline equivalent, such as `implied_quote` and the general `instantaneous_forward` interface, are excluded from both sides.

- AU 5.12 cannot discover the model key through the transducer in a swap, so swap and swap-containing portfolio sensitivity bundles are excluded from both sides. The FinanceModels portfolio valuation comparison remains.
