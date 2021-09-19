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

```plaintext
Times are nanoseconds:
┌────────────────┬─────────────┬───────────────┬──────────┬──────────┐
│       Language │   Algorithm │ Function Name │   Median │     Mean │
├────────────────┼─────────────┼───────────────┼──────────┼──────────┤
│ R (data.table) │  Vectorized │           npv │ 770554.0 │ 842767.3 │
│              R │  Vectorized │      npv base │   4264.0 │  46617.0 │
│              R │ Accumulator │      npv_loop │   4346.0 │  62275.7 │
│           Rust │ Accumulator │           npv │     24.0 │  missing │
│ Python (NumPy) │  Vectorized │           npv │  missing │  14261.0 │
│         Python │ Accumulator │      npv_loop │  missing │   2314.0 │
│ Python (Numba) │ Accumulator │     npv_numba │  missing │    626.0 │
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

To aid in visualizing results with such vast different orders of magnitude, this graph includes a physical length comparison to serve as a reference. The computation time is represented by the distance that light travels in the time for the computation to complete (comparing a nanosecond to one foot length [goes at least back to Admiral Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)).
![Life Modeling Problem Benchmarks](/blog/data/benchmarks.svg)

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
1.53.0-nightly (b0c818c5e 2021-04-16)
```

#### Python

```
Python 3.9.4 (default, Apr  9 2021, 09:32:38) 
[Clang 10.0.0 ] :: Anaconda, Inc. on darwin

numba                     0.53.1           py39hb2f4e1b_0
numpy                     1.20.1           py39hd6e1bb9_0 
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
