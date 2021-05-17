@def author = "Alec Loudenback"
@def date = "May 16, 2021"
@def title = "The Life Modeling Problem"

@def rss_pubdate = Date(2021,5,16)
@def rss = "The \"hard parts\" of computational actuarial science and how well programming languages fare."

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*

**!! Note that this article is a draft**

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what Lewis Fogden referred to as the "Life Modeling Problem".

Which wasn't concretely defined, but I think the "Life Modeling Problem" has the following attributes:

- Recursive calcuations
- Computationally intensive
- Parallelizeable (across policies/cells/products)

Folks started submitting versions of a toy problem with the first two characteristics to showcase different approaches and languages.

Times are nanoseconds:

```
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

It's hard to visualize/compare results with such vast different orders of magnitude. To aid in that, I've included a physical length comparsion representing the distance that light travels in the time for the computation to complete. Comparing a nanosecond to one foot length [goes way back to the great Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)

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

## Colophone

### Code

All of the benchmarked code can be found in the [JuliaActuary Learn repository](https://github.com/JuliaActuary/Learn/tree/master/LifeModelingProblemBenchmarks). Please file an issue or submit a PR request there for issues/suggestions.

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