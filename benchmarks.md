@def author = "Misc"
@def date = "August 7, 2021"
@def title = "Benchmarks"

@def rss_pubdate = Date(2021,8,7)
@def rss = "Acturial-related benchmarks."

# {{fill title}}

\toc

## The Life Modeling Problem

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what someone referred to as the "Life Modeling Problem". This user [submitted a short snippet](https://github.com/orgs/actuarialopensource/teams/common-room/discussions/5) for consideraton of a representative problem.

### Benchmarks

After the orignal user submitted a proposal, others chimed in and submitted versions in their favorite languages. I have collected those versions, and run them on a consistent set of hardware.

Some submissions were excluded becuase from the benchmarks they involved an entirely different approach, such as [memoizing](https://en.wikipedia.org/wiki/Memoization) the function calls[^1].

```
Times are nanoseconds:
┌────────────────┬─────────────┬───────────────┬──────────┬──────────┐
│           lang │   algorithm │ function_name │   median │     mean │
│         String │      String │        String │ Float64? │ Float64? │
├────────────────┼─────────────┼───────────────┼──────────┼──────────┤
│ R (data.table) │  Vectorized │           npv │ 770554.0 │ 842767.3 │
│              R │  Vectorized │      npv base │   4264.0 │  46617.0 │
│              R │ Accumulator │      npv_loop │   4346.0 │  62275.7 │
│           Rust │ Accumulator │           npv │     24.0 │  missing │
│ Python (NumPy) │  Vectorized │           npv │  missing │   6823.3 │
│         Python │ Accumulator │      npv_loop │  missing │   1486.0 │
│          Julia │  Vectorized │          npv1 │    235.3 │    228.2 │
│          Julia │  Vectorized │          npv2 │    235.8 │    218.4 │
│          Julia │ Accumulator │          npv3 │     14.5 │     14.5 │
│          Julia │ Accumulator │          npv4 │     10.8 │     10.8 │
│          Julia │ Accumulator │          npv5 │     11.5 │     11.5 │
│          Julia │ Accumulator │          npv6 │      9.0 │      9.0 │
│          Julia │ Accumulator │          npv7 │      7.9 │      7.9 │
│          Julia │ Accumulator │          npv8 │      7.4 │      7.4 │
│          Julia │ Accumulator │          npv9 │      6.4 │      6.4 │
└────────────────┴─────────────┴───────────────┴──────────┴──────────┘
```

```julia:./code/lmp/packages
#hideall
using Plots
using Dates
using DataFrames
using CSV
using Measures
```

```julia:./code/lmp/loaddata
#hideall
benchmarks = DataFrame(CSV.File("blog/data/lmp_benchmarks.csv"))
```

\output{./code/lmp/loaddata}

To aid in visualizing results with such vast different orders of magnitude, this graph includes a physical length comparsion to serve as a reference. The computation time is represented by the distance that light travels in the time for the computation to complete (comparing a nanosecond to one foot length [goes at least back to Admiral Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)).

```julia:./code/lmp/benchmkarkplot
#hideall
# Reference Grace Hopper explains the nanosecond
p = plot(palette = :seaborn_colorblind,rotation=15)
# label equivalents to distance to make log scale more relatable
scatter!(fill("\n equivalents (ns → ft)",7),[1,1e1,1e2,1e3,.8e4,0.72e5,3.3e6],series_annotations=Plots.text.(["1 foot","basketball hoop","blue whale","Eiffle Tower","avg ocean depth","marathon distance","Space Station altitude"], :left, 8,:grey),marker=0,label="",left_margin=20mm)

# plot mean, or median if not available
for g in groupby(benchmarks,:algorithm)
    scatter!(g.lang,
        ifelse.(ismissing.(g.mean),g.median,g.mean),
        label="$(g.algorithm[1])",
        yaxis=:log,
        ylabel="Nanoseconds (log scale)",
    marker = (:circle, 5, 0.5, stroke(0)))
end
savefig(p,joinpath(@OUTPUT, "benchmarks.svg")) # hide

```

\fig{./code/lmp/benchmarks}

### Discussion

For more a more in-depth discussion of these results, see [this post](/blog/life-modeling-problem/).

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/benchmarks/LifeModelingProblem). Please file an issue or submit a PR request there for issues/suggestions.

## IRRs

Task: determine the IRR for a series of cashflows 701 elements long.

Julia is 13,350 times faster than `numpy_financial`, and 54 times faster than the `better` Python package.

### Benchmarks

```
Times are in nanoseconds:
┌──────────┬──────────────────┬───────────────────┬─────────┬─────────────┬───────────────┐
│ Language │          Package │          Function │  Median │        Mean │ Relative Mean │
├──────────┼──────────────────┼───────────────────┼─────────┼─────────────┼───────────────┤
│   Python │  numpy_financial │               irr │ missing │ 918376814.0 │       13350.1 │
│   Python │           better │ irr_binary_search │ missing │   3698785.0 │          53.8 │
│   Python │           better │        irr_newton │ missing │    557129.0 │           8.1 │
│    Julia │ ActuaryUtilities │               irr │ 69625.0 │     68792.0 │           1.0 │
└──────────┴──────────────────┴───────────────────┴─────────┴─────────────┴───────────────┘
```

### Discussion

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/Benchmarks/LifeModelingProblem). Please file an issue or submit a PR request there for issues/suggestions.

## Other benchmarks

These benchmarks have been performed by others, but provide relevant information for actuarial-related work:

- [H2Oai DataFrames/Database-like Operations](https://h2oai.github.io/db-benchmark/)
- [Reading CSVs](https://juliacomputing.com/blog/2020/06/fast-csv/)


## Colophone

### Code

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/Benchmarks/irr). Please file an issue or submit a PR request there for issues/suggestions.

### Hardware

Macbook Air (M1, 2020)

### Software

All languages/libraries are Mac M1 native unless otherwise noted

#### Julia

```
Julia Version 1.7.0-DEV.938
Commit 2b4c088ee7* (2021-04-16 20:37 UTC)
Platform Info:
  OS: macOS (arm64-apple-darwin20.3.0)
  CPU: Apple M1
  WORD_SIZE: 64
  LIBM: libopenlibm
  LLVM: libLLVM-11.0.1 (ORCJIT, cyclone)
```
 
#### Rust

```
1.53.0-nightly (b0c818c5e 2021-04-16)
```

#### Python

```
Python 3.9.4 (default, Apr  4 2021, 17:42:23) 
[Clang 12.0.0 (clang-1200.0.32.29)] on darwin
```

#### R

```
R Under development (unstable) (2021-04-16 r80179) -- "Unsuffered Consequences"
Copyright (C) 2021 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin20.0 (64-bit)
```

## Footnotes

[^1] If benchmarking memoiziation, it's essentially benchmarking how long it takes to perform hashing in a language. While interesting, especially in the context of [incremental computing](https://scattered-thoughts.net/writing/an-opinionated-map-of-incremental-and-streaming-systems), it's not the core issue at hand. Incremental computing libraries exist for all of the modern languages discussed here.

[^2] Note that not all languages have both a mean and median result in their benchmarking libraries. Mean is a better representation for a garbage-collected modern language, because sometimes the computation just takes longer than the median result. Where the mean is not avaiable in the graph below, median is substituted.
