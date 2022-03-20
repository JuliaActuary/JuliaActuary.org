@def author = "Misc"
@def date = "August 7, 2021"
@def title = "Benchmarks"

@def rss_pubdate = Date(2021,8,7)
@def rss = "Acturial-related benchmarks."

# {{fill title}}

\toc

## The Life Modeling Problem

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what someone referred to as the "Life Modeling Problem". This user [submitted a short snippet](https://github.com/orgs/actuarialopensource/teams/common-room/discussions/5) for consideration of a representative problem.

### Benchmarks

After the original user submitted a proposal, others chimed in and submitted versions in their favorite languages. I have collected those versions, and run them on a consistent set of hardware.

Some submissions were excluded because from the benchmarks they involved an entirely different approach, such as [memoizing](https://en.wikipedia.org/wiki/Memoization) the function calls[^1].


```julia:./code/getdata
#hideall
using CSV, DataFrames
using PrettyTables
file = download("https://raw.githubusercontent.com/JuliaActuary/Learn/master/Benchmarks/LifeModelingProblem/benchmarks.csv")
benchmarks = CSV.read(file,DataFrame)
header = (["Language", "Algorithm", "Function name", "Median","Mean"],
                 [ "",       "",    "",      "[nanoseconds]","[nanoseconds]"]);
pretty_table(benchmarks;header,formatters = ft_printf("%'.1d"))
```
\output{./code/getdata}

To aid in visualizing results with such vast different orders of magnitude, this graph includes a physical length comparison to serve as a reference. The computation time is represented by the distance that light travels in the time for the computation to complete (comparing a nanosecond to one foot length [goes at least back to Admiral Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)).

```julia:lmp_plot
#hideall
using Plots
using DataFrames
p = plot(palette = :seaborn_colorblind,rotation=25,yaxis=:log)
# label equivalents to distance to make log scale more relatable
scatter!(
    fill("\n equivalents (ns → ft)",7),
    [1,1e1,1e2,1e3,.8e4,0.72e5,3.3e6],
    series_annotations=Plots.text.(["1 foot","basketball hoop","blue whale","Eiffel Tower","avg ocean depth","marathon distance","Space Station altitude"], :left, 8,:grey),marker=0,label="",left_margin=20Plots.mm,bottom_margin=8Plots.mm)

# plot mean, or median if not available
for g in groupby(benchmarks,:algorithm)
    scatter!(p,g.lang,
        ifelse.(ismissing.(g.mean),g.median,g.mean),
        label="$(g.algorithm[1])",
        ylabel="Nanoseconds (log scale)",
    marker = (:circle, 5, 0.7, stroke(0)))
end

savefig(joinpath(@OUTPUT,"lmp_benchmarks.svg"))
```

\fig{lmp_benchmarks.svg}

### Discussion

For more a more in-depth discussion of these results, see [this post](/blog/life-modeling-problem/).

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/Benchmarks/LifeModelingProblem). Please file an issue or submit a PR request there for issues/suggestions.

## IRRs

**Task:** determine the IRR for a series of cashflows 701 elements long.

### Benchmarks

```plaintext
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

Julia is 13,350 times faster than `numpy_financial`, and 54 times faster than the `better` Python package. The [ActuaryUtililites.jl](/#actuaryutilitiesjl) implementation is also more flexible, as it can be given an argument with timepoints, similar to Excel's `XIRR`.

Excel was used to attempt a benchmark, but the `IRR` formula returned a `#DIV/0!` error.

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/Benchmarks/irr). Please file an issue or submit a PR request there for issues/suggestions.

## Black-Scholes-Merton European Option Pricing

**Task:** calculate the price of a vanilla european call option using the Black-Scholes-Merton formula.


\begin{align}
C(S_t, t) &= N(d_1)S_t - N(d_2)Ke^{-r(T - t)} \\

d_1 &= \frac{1}{\sigma\sqrt{T - t}}\left[\ln\left(\frac{S_t}{K}\right) + \left(r + \frac{\sigma^2}{2}\right)(T - t)\right] \\

d_2 &= d_1 - \sigma\sqrt{T - t}

\end{align}

### Benchmarks

```plaintext
Times are in nanoseconds:
┌──────────┬─────────┬─────────────┬───────────────┐
│ Language │  Median │        Mean │ Relative Mean │
├──────────┼─────────┼─────────────┼───────────────┤
│   Python │ missing │    817000.0 │       19926.0 │
│        R │  3649.0 │      3855.2 │          92.7 │
│    Julia │    41.0 │        41.6 │           1.0 │
└──────────┴─────────┴─────────────┴───────────────┘
```

### Discussion

Julia is nearly 20,000 times faster than Python, and two orders of magnitude faster than R.

## Other benchmarks

These benchmarks have been performed by others, but provide relevant information for actuarial-related work:

- [H2Oai DataFrames/Database-like Operations](https://h2oai.github.io/db-benchmark/)
- [Reading CSVs](https://juliacomputing.com/blog/2020/06/fast-csv/)


## Colophone

### Code

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/Benchmarks/). Please file an issue or submit a PR request there for issues/suggestions.

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
1.61.0-nightly (f103b2969 2022-03-12)
```

#### Python

```
Python 3.9.7

numba                     0.54.1           py39hae1ba45_0
numpy                     1.20.3           py39h4b4dc7a_0
```

#### R

```
R Under development (unstable) (2021-04-16 r80179) -- "Unsuffered Consequences"
Copyright (C) 2021 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin20.0 (64-bit)
```

## Footnotes

[^1] If benchmarking memoiziation, it's essentially benchmarking how long it takes to perform hashing in a language. While interesting, especially in the context of [incremental computing](https://scattered-thoughts.net/writing/an-opinionated-map-of-incremental-and-streaming-systems), it's not the core issue at hand. Incremental computing libraries exist for all of the modern languages discussed here.

[^2] Note that not all languages have both a mean and median result in their benchmarking libraries. Mean is a better representation for a garbage-collected modern language, because sometimes the computation just takes longer than the median result. Where the mean is not available in the graph below, median is substituted.
