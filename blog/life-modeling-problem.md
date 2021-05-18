@def author = "Alec Loudenback"
@def date = "May 16, 2021"
@def title = "The Life Modeling Problem"

@def rss_pubdate = Date(2021,5,16)
@def rss = "The \"hard parts\" of computational actuarial science and how well programming languages fare."

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*

**!! Note that this article is a draft**

In the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub organization, a discussion began of the "Life Modeling Problem" (LMP) in actuarial science.

I think the "Life Modeling Problem" has the following attributes:

- Recursive calcuations
- Computationally intensive
- Large volume of data to process

The following discussion will get a little bit technical, but I think there are a few key takeaways:

1. There are a lot of ways to accomplish the same task and it probably doesn't matter how
2. The approach to a problem makes a big difference: "if all you have is a dataframe, everything looks like a join"
3. Performance, flexibility, readablily: pick one, two, or three depending on the language

To skip the background and the discussion, [click here to jump to the benchmarks](#benchmarks).

## The Life Modeling Problem

Inspired by the discussion in the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub community discussion, folks started submitted solutions to what someone referred to as the "Life Modeling Problem". This user [submitted a short snippet](https://github.com/orgs/actuarialopensource/teams/common-room/discussions/5) for consideraton of a representative problem.

My take on the characteristics are that modeling life actuarial science problems breaks down to the following items:

- Calculations are recursive in nature
- Computationally intensive cacluations
- Performance matters given large volumes of data to process
- Readability and usability aids in controls and risk

### Recursive calculations

Many actuarial formulas are recursive in nature. Reserves are defined "prospecively" or "retrospectively" 

### Computationally intensive

Modeling is incredibly computationally complex due to the volume of data needed to process. For example, CUNA Mutual disclosed that they spin up 50 servers with 20 cores a [couple of days per month](https://www.cunamutual.com/landing-pages/that-conference/cuna-mutual-applications) to do the calculations. 

### Processing volume

There's a cottage industry devoted to inforce compression and model simplifications to get runtimes and budgets down to a reasonable level. However, as the capacity for computing has grown, the company and regulatory demnads have grown. E.g in the US reserving has transition from net-premium reserve to integrated ALM (CFT) to deterministic scenarios sets (CFT w NY7 + others) to truly stochastic (Stochasic PBR). "What Intel giveth, the NAIC taketh away."[^1]. 

So again, performance matters!

### Readability and Expressiveness

Actuaries, even the [10x Actuary](/blog/coding-for-the-future/), aren't pure computer scientists and computuational efficiency has never been *so* critical that they sacrifce everthing else to get it. So the industry never turned to the 40-year king of performance computation, [Fortran](https://en.wikipedia.org/wiki/Fortran). The syntax is very "close to the machine". I's a bit rough to read to anyone not well versed.

Interestingly, [APL](https://en.wikipedia.org/wiki/APL_(programming_language)) took off and was one of the dominant languages used by actuaries before the advent of [vendor-supplied modeling solutions](/blog/coding-for-the-future/#the_10x_actuary). 

Counting the occurances of a string looks like this in APL:
```APL
csubs←{0=x←⊃⍸⍺⍷⍵:0 ⋄ 1+⍺∇(¯1+x+⍴⍺)↓⍵}
```

whereas in Fortan it would be:

```
function countsubstring(s1, s2) result(c)
  character(*), intent(in) :: s1, s2
  integer :: c, p, posn
 
  c = 0
  if(len(s2) == 0) return
  p = 1
  do 
    posn = index(s1(p:), s2)
    if(posn == 0) return
    c = c + 1
    p = p + posn + len(s2) - 1
  end do
end function
```

Maybe more readable to the modern eye than APL, but many valuation and pricing acturies would still recognize what's going on with the first code example.

Why did APL take off for Acturies and not APL? I think [expressiveness](https://en.wikipedia.org/wiki/Expressive_power_%28computer_science%29) and the ability to have a language inspired by mathematical notation were attractive. More on this later in a comparison between the modern languages.

The takeaway from this point, though, is that there is a natural draw towards more expressive, powerful languages than less expressive langauges, especially when dealing with math notations. So high expressiveness is something we want from a language that solves the LMP.

## Benchmarks

After the orignal user submitted a proposal, others chimed in and submitted versions in their favorite languages. I have collected those versions, and run them on a consistent set of hardware.

Some "submissions" were excluded becuase they involved an entirely different approach, such as [memoizing](https://en.wikipedia.org/wiki/Memoization) the function calls[^2].


Times are nanoseconds[^3]:

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

It's hard to visualize/compare results with such vast different orders of magnitude. To aid in that, I've included a physical length comparsion representing the distance that light travels in the time for the computation to complete (comparing a nanosecond to one foot length [goes at least back to Admiral Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)).

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

## Benchmark Discussion

### Takeaway #1

> There are a lot of ways to accomplish the same task and it probably doesn't matter how

All of the submissions and algorithms above worked, and fast enough that it gave an answer in very little time.

But remember the CUNA Mutual example from above: Let's say that CUNA's runtime is already as fast as it can be, and index it to the fastest result in the benchmarks below. The difference between the fastest "couple of days" run and the slowest would be over __721 years__. So it's important to use tools and approaches that are performant for actuarial work.

So for little one-off tasks it doesn't make a big difference what tool or algorthim is used. More often than not, your one-off calculatons or checks will be done fast enough that it's not important to be picky. But if wanting to scale your work to a broader application within your company or the industry, I think it's important to be perfromance-minded[^4]. 

### Takeaway #2

> "If all you have is a dataframe, everything looks like a join"

I've seen this several times in practice. Where a stacked dataframe of mortality rates is joined up with policy data in a complicated series of `%>%`s (pipes), `inner_joins` and `mutates`.

Don't get me wrong, I think code is often still a better approach than spreadsheets[^5].

However, like the old proverb that "if all you have is a hammer, everything looks like a nail" - sometimes the tool you have just isn't right for the job. That's the lesson of the R [data.table](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html) result above. Even with the fastest dataframe implementation in R, it vastly trails other submissions.

### Algortihm choice

Getting more refined about the approach, the other thing that is very obvious is that for this recursive type calculation, it's much more efficient to write a `for` loop (the `Accumulator` approach) in every language except for R (where it wants everthing to be a vector or dataframe).

The differnece hints at some computational aspects related to arrays that I will touch upon when discussing code examples below. The point for now is that you should consider using tools that give you the flexibility to approach problems in different ways.

### Takeaway #3

> Performance, flexibility, readablily: pick one, two, or three depending on the language

...

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

[^1] A take on [Andy and Bill's law](https://en.wikipedia.org/wiki/Andy_and_Bill%27s_law)

[^2] If benchmarking memoiziation, it's essentially benchmarking how long it takes to perform hashing in a language. While interesting, especially in the context of [incremental computing](https://scattered-thoughts.net/writing/an-opinionated-map-of-incremental-and-streaming-systems), it's not the core issue at hand. Incremental computing libraries exist for all of the modern languages discussed here.

[^3] Note that not all languages have both a mean and median result in their benchmarking libraries. Mean is a better representation for a garbage-collected modern language, because sometimes the computation just takes longer than the median result. Where the mean is not avaiable in the graph below, median is substituted.

[^4] Don't [prematurely optimize](https://en.wikipedia.org/wiki/Program_optimization#When_to_optimizer). But in the long run avoid, [re-writing your code in a faster language too many times!](https://www.nature.com/articles/d41586-019-02310-3)

[^5]  I've seen 50+ line, irregular Excel formulas. To Nick: it probably started out as a good idea but it was a beast to understand and modify! At least with code you can look at the code with variable names and syntax highlighting! Comments, if you are lucky!