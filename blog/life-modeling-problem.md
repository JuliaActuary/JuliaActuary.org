@def author = "Alec Loudenback"
@def date = "May 16, 2021"
@def title = "The Life Modeling Problem: A Comparison of Julia, Rust, Python, and R"

@def rss_pubdate = Date(2021,5,16)
@def rss = "The \"hard parts\" of computational actuarial science and how well programming languages fare."

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*

> **!! Note that this article is a draft**

*Note: This is an extended discussion of the results from one of the items on the [Benchmarks](/benchmarks/) page.*

In the [ActuarialOpenSource](https://github.com/actuarialopensource) GitHub organization, a discussion began of the "Life Modeling Problem" (LMP) in actuarial science.

I think the "Life Modeling Problem" has the following attributes:

- Recursive calcuations
- Computationally intensive
- Large volume of data to process

The following discussion will get a little bit technical, but I think there are a few key takeaways:

1. There are a lot of ways to accomplish the same task and and that's good enough in most cases
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

After the orignal user submitted a proposal, others chimed in and submitted versions in their favorite languages. I have collected those versions, and run them on a consistent set of hardware[^3].

Some "submissions" were excluded becuase they involved an entirely different approach, such as [memoizing](https://en.wikipedia.org/wiki/Memoization) the function calls[^2].

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

\output{./code/lmp/loaddata}

To aid in visualizing results with such vast different orders of magnitude, this graph includes a physical length comparsion to serve as a reference. The computation time is represented by the distance that light travels in the time for the computation to complete (comparing a nanosecond to one foot length [goes at least back to Admiral Grace Hopper](https://www.youtube.com/watch?v=9eyFDBPk4Yw)).

![Life Modeling Problem Benchmarks](/blog/data/benchmarks.svg)

## Benchmark Discussion

### Takeaway #1

> TThere are a lot of ways to accomplish the same task and and that's good enough in most cases

All of the submissions and algorithms above worked, and fast enough that it gave an answer in very little time. And much of the time, the volume of data to process is small enough that it doesn't matter.

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

This section ranges from objective (performance metrics) to subjective (my take on flexibility and readabilty). My opinions are based on using R heavily for several years ~2011-2015, Python for ~2015-2018, and then primarily swtiched to Julia in ~2018. I have a lot of experience with VBA, and moderate experience with Javascript, with some educational/introductory background in C, List/Racket, Mathematica, Haskell, and Java.

#### R


##### Perfomrance

R was the slowest all-around.

##### Flexibility

R scores well here - [non-standard evaluation](http://adv-r.had.co.nz/Computing-on-the-language.html#nse) lets you, essentially, inspect the written code without evaluating it. This is a nice feature that enables a lot of creativity and pleasantries (like ggplot knowing what to label the axes without you telling it).

R works in notebook environments and from a REPL.

##### Readbility

R is pretty good here too:

```R

# via Houstonwp
q <- c(0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011)
w <- c(0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04)
P <- 100
S <- 25000
r <- 0.02

base_r_npv <- function(q,w,P,S,r) {
  inforce <- c(1,head(cumprod(1-q-w), -1))
  ncf <- inforce * P - inforce * q * S
  d <- (1/(1+r)) ^ seq_along(ncf)
  sum(ncf * d)
}

base_r_npv(q,w,P,S,r)
#> [1] 50.32483
microbenchmark::microbenchmark(base_r_npv(q,w,P,S,r))
```

...


#### Rust 

Rust is a newer, statically compiled language designed for performance and safety (in the don't let your program do memory managment mistakes that crash the computer).

##### Performance

Rust scores well here, coming second only to Julia.

##### Flexibility

Rust is statically compiled (you write script, have computer run script, see results). It doesn't have a REPL or ability to be used in an interactive way (e.g. notebook environments).

##### Readabilty

I really like the explcit function contract: you give it various floating point (`f64`) vectors and numbers, and it returns a float: `-> f64`. 

Other than that it's pretty straightforward but definitely more verbose than any of the others.

```
#![feature(test)]
extern crate test;
use test::Bencher;

// Via Paddy Horan
pub fn npv(mortality_rates: &Vec<f64>, lapse_rates: &Vec<f64>, interest_rate: f64, sum_assured: f64, premium: f64, init_pols: f64, term: Option<usize>) -> f64 {

    let term = term.unwrap_or_else(|| mortality_rates.len());
    let mut result = 0.0;
    let mut inforce = init_pols;
    let v: f64 = 1.0 / (1.0 + interest_rate);

    for (t, (q, w)) in mortality_rates.iter().zip(lapse_rates).enumerate() {
        let no_deaths = if t < term {inforce * q} else {0.0};
        let no_lapses = if t < term {inforce * w} else {0.0};
        let premiums = inforce * premium;
        let claims = no_deaths * sum_assured;
        let net_cashflow = premiums - claims;
        result += net_cashflow * v.powi(t as i32);
        inforce = inforce - no_deaths - no_lapses;
    }

    result
}
#[bench]
fn bench_xor_1000_ints(b: &mut Bencher) {

let q: Vec<f64> = vec![0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011];
let w: Vec<f64> = vec![0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04];
let p: f64 = 100.0;
let s: f64 = 25000.0;
let r: f64 = 0.02;
    b.iter(|| {
        // use `test::black_box` to prevent compiler optimizations from disregarding
        // unused values
        test::black_box(npv(&q,&w,r,s,p,1.0,Some(10)));
    });
}
```

#### Python

##### Performance

With [NumPy](https://numpy.org/), Python was the second fastest `Vectorized` approach and 3rd place for the `Accumulator` loop, both cases were still more than an order of magnitude slower than the next place.

##### Flexibility

Python wins points for interactive usage in the REPL, notebooks, and wide variety of environments that support running Python code. However, within the language itself I have to dedcut points for the ease of inspectng/evaluating code.

What I mean by that, is that if you look at the code example below, in order to test the code you have to turn it into string and then call the `timeit` function to read and parse the string. In none of the other tested languages was that required.

I would also ding Python here, becuse once you get deep into an ecosystem (e.g. NumPy), you are sort of at the mercy of package developers to ensure that the packages are compatible.

##### Readability

One of Python's seminal features is the pleasant syntax, though opionions differ as to whehter the indentation should matter to how your program runs.


```Python
import timeit
setup='''
import numpy as np
q = np.array([0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011])
w = np.array([0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04])
P = 100
S = 25000
r = 0.02
def npv(q,w,P,S,r):
    decrements = np.cumprod(1-q-w)
    inforce = np.empty_like(decrements)
    inforce[:1] = 1
    inforce[1:] = decrements[:-1]
    ncf = inforce * P - inforce * q * S
    t = np.arange(np.size(q))
    d = np.power(1/(1+r), t)
    return np.sum(ncf * d)
'''
benchmark = '''npv(q,w,P,S,r)'''

print(timeit.timeit(stmt=benchmark,setup=setup,number = 1000000))
```

I will say that the benchmarking setup with Python's `timeit` is definitely the most painful, needing to wrap the whole thing in a string. And then only get a single nubmer reult, without normalizing for the number of runs is very annoying.

#### Juila

##### Perfomrance

The fastest language with both algorithms.

##### Flexiblity

Available in a variety of environments, include the standard interactive ones like the REPL and notebooks. One key differentiator is the [reactive notebook](https://www.nature.com/articles/d41586-021-01174-w) environment, [Pluto.jl](https://github.com/fonsp/Pluto.jl) where notebook cells understand and interact with one-another.

Julia packags are also [notoriously cross-functional](https://www.youtube.com/watch?v=kc9HwsxE1OY), so unlike Python (e.g. NumPy) or R (e.g. Tidyverse), tightly coupled specialty-ecosystems have not evolved in Julia.


##### Readability

Julia scores well here, but gets dinged in my mind for a couple of things:

- all of those dots! 
- the weird `@benchmark` and dollar signs (`$`s)

The former is actually a very powerful concept/tool called [broadcasting](https://docs.julialang.org/en/v1/manual/arrays/#Broadcasting). Kind of like R (where everything is a vector and will combine in vector-like ways). Julia lets you both worlds: really effective scalars and highly efficient vector operations. Once you know what it does, it's hard to think of a shorter/more concise way to express it than the dot (`.`).

The latter, `@benchmark` is a way to get Julia to work with the code itself, again kind of like R does. `@benchmark` is a [macro](https://docs.julialang.org/en/v1/manual/metaprogramming/#man-macros) that will run a really comprehensive and informative benchmarking set on the code given. 


The `Vectorized` version:
```Julia 
using BenchmarkTools

q = [0.001,0.002,0.003,0.003,0.004,0.004,0.005,0.007,0.009,0.011]
w = [0.05,0.07,0.08,0.10,0.14,0.20,0.20,0.20,0.10,0.04]
P = 100
S = 25000
r = 0.02

function npv1(q,w,P,S,r) 
	inforce = [1.; cumprod(1 .- q .- w)[1:end-1]] 
  	ncf = inforce .* P .- inforce .* q .* S
 	d = (1 ./ (1 + r)) .^ (1:length(ncf))
  	return sum(ncf .* d)
end

@benchmark npv($q,$w,$P,$S,$r)
```

And the `Accumulator` version:

```julia
function npv5(q,w,P,S,r,term=nothing)
    term = term === nothing ? length(q) : term
    inforce = 1.0
    result = 0.0
    v = (1 / ( 1 + r))
    v_t = v
    for (q,w,_) in zip(q,w,1:term)
        result += inforce * (P - S * q) * v_t
        inforce -= inforce * q + inforce * w
        v_t *= v
    end
    return result
end
```

## More flexibiltiy, more performance from Julia

I wanted to go a little bit deeper and show how 1) Julia just runs fast even if your not explicitly focused on performance. But for where it *really* matters, you can go even deeper. This is a lttle advanced, but I think it can be useful to introduce some basics as to why some languages and approaches are going to be fundamentally slower than others.

Notes:
The accumulator approach
vectors and allocations
talk about stack/heap?
pick a faster approach and explain why it's even faster.




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

## Footnotes

[^1] A take on [Andy and Bill's law](https://en.wikipedia.org/wiki/Andy_and_Bill%27s_law)

[^2] If benchmarking memoiziation, it's essentially benchmarking how long it takes to perform hashing in a language. While interesting, especially in the context of [incremental computing](https://scattered-thoughts.net/writing/an-opinionated-map-of-incremental-and-streaming-systems), it's not the core issue at hand. Incremental computing libraries exist for all of the modern languages discussed here.

[^3] Note that not all languages have both a mean and median result in their benchmarking libraries. Mean is a better representation for a garbage-collected modern language, because sometimes the computation just takes longer than the median result. Where the mean is not avaiable in the graph below, median is substituted.

[^4] Don't [prematurely optimize](https://en.wikipedia.org/wiki/Program_optimization#When_to_optimizer). But in the long run avoid, [re-writing your code in a faster language too many times!](https://www.nature.com/articles/d41586-019-02310-3)

[^5]  I've seen 50+ line, irregular Excel formulas. To Nick: it probably started out as a good idea but it was a beast to understand and modify! At least with code you can look at the code with variable names and syntax highlighting! Comments, if you are lucky!