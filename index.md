@def title = "Home"
@def tags = ["syntax", "code"]

<!-- =============================
     ABOUT
    ============================== -->

# Mission

> JuliaActuary is focused on building packages that enable actuaries everywhere to build solutions using open-source tools.

The packages utilize all of the benefits of the [Julia language](https://julialang.org) and:

* provide easy access and clean interface to mortality tables (**MortalityTables.jl**)
* bundle a set of commonly used financial and math functions (**ActuaryUtiltities.jl**)
* provide an easy interface to many common life contingent maths (**LifeContingencies.jl**)

~~~
</br>
<a class="github-button" href="https://github.com/JuliaActuary/" data-size="large" aria-label="View {{title}} on GitHub">JuliaActuary on GitHub</a>

~~~


<!-- =============================
     PACKAGES
     ============================== -->
# Packages

These packages are available for use in your project. Keep scrolling down for more info on each one.
~~~
<div class="wide_table_reponsive" >
<table><tbody><tr><th align="left">Name</th><th align="right">Description</th><th align="center">Development Status</th></tr><tr><td align="left"><a href="https://github.com/JuliaActuary/MortalityTables.jl"><code>MortalityTables.jl</code></a></td><td align="right">Easily work with standard <a href="mort.SOA.org">mort.SOA.org</a> tables and parametric models with common survival calculations.</td><td align="center"><img class="lifecycle" alt="Maturing" src="/assets/Maturing.svg"> <br> The package is nearing it's <code>v1.0.0</code> release</td></tr><tr><td align="left"><a href="https://github.com/JuliaActuary/ActuaryUtilities.jl"><code>ActuaryUtilities.jl</code></a></td><td align="right">Robust and fast calculations for <code>internal_rate_of_return</code>, <code>duration</code>, <code>convexity</code>, <code>present_value</code>, <code>breakeven</code>, and more.</td><td align="center"> <img class="lifecycle" alt="Maturing" src="/assets/Maturing.svg"> <br>  The package is nearing it's <code>v1.0.0</code> release</td></tr><tr><td align="left"><a href="https://github.com/JuliaActuary/LifeContingencies.jl"><code>LifeContingencies.jl</code></a></td><td align="right">Insurance, annuity, premium, and reserve maths.</td><td align="center"> <img class="lifecycle" alt="Developing" src="/assets/Developing.svg"> <br>  Functionality is mostly built-out, but the API may change substantially.</td></tr></tbody></table>
</div>
~~~

~~~
<div class="alert alert-info"> <strong>Note:</strong> You can use any package in it's current state and not worry about changes breaking any code that you write. Julia's package manager let's you <a href="https://julialang.github.io/Pkg.jl/v1/toml-files/#Manifest.toml-1" >exactly recreate a set of code and its dependencies.</a> (<a href="https://stackoverflow.com/questions/63485891/how-do-i-ensure-repeatability-of-julia-code-and-assoicated-dependencies">More</a>).
</div>
~~~

## Adding and Using Packages

There are two ways to add packages: 
- In the code itself: `using Pkg; Pkg.add("MortalityTables")`
- In the [REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html), hit `]` to enter Pkg mode and type `add MortalityTables`
More info can be found at the [Pkg manager documentation](https://julialang.github.io/Pkg.jl/v1/getting-started).

To use packages in your code:

```julia
using PackageName
```

<!-- =============================
     MortalityTables
     ============================== -->
## MortalityTables.jl 

> Hassle-free mortality and other rate tables.


**Features**

- Lots of bundled SOA mort.soa.org tables
- `survival` and `decrement` functions to calculate decrements over period of time
- Partial year mortality calculations (Uniform, Constant, Balducci)
- Friendly syntax and flexible usage
- Extensive set of parametric mortality models.

**Quickstart**

Loading the package and bundled tables:

```julia-repl
julia> using MortalityTables

julia> tables = MortalityTables.tables()
Dict{String,MortalityTable} with 266 entries:
  "2015 VBT Female Non-Smoker RR90 ALB"                                       => SelectUltimateTable{OffsetArray{OffsetArray{Float64,1,Array{Float64,1}},1,Array{OffsetArray{F…  
  "2017 Loaded CSO Preferred Structure Nonsmoker Preferred Female ANB"        => SelectUltimateTable{OffsetArray{OffsetArray{Float64,1,Array{Float64,1}},1,Array{OffsetArray{F…  
  ⋮                                                                            => ⋮
```

Get information about a particular table:

```julia-repl
julia> vbt2001 = tables["2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB"]
MortalityTable (Insured Lives Mortality):
   Name:
       2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB
   Fields:
       (:select, :ultimate, :metadata)
   Provider:
       Society of Actuaries
   mort.SOA.org ID:
       1118
   mort.SOA.org link:
       https://mort.soa.org/ViewTable.aspx?&TableIdentity=1118
   Description:
       2001 Valuation Basic Table (VBT) Residual Standard Select and Ultimate Table -  Male Nonsmoker.
       Basis: Age Nearest Birthday. 
       Minimum Select Age: 0. 
       Maximum Select Age: 99. 
       Minimum Ultimate Age: 25. 
       Maximum Ultimate Age: 120
```

The package revolves around easy-to-access vectors which are indexed by attained age:

```julia-repl
julia> vbt2001.select[35] # vector of rates for issue age 35
 0.00036
 0.00048
 ⋮
 0.94729
 1.0

julia> vbt2001.select[35][35] #issue age 35, attained age 35
 0.00036

julia> vbt2001.ultimate[95]  # ultimate vectors only need to be called with the attained age
 0.24298
```

Calculate the force of mortality or survival over a range of time:

```julia
julia> survival(vbt2001.ultimate,30,40) # the survival between ages 30 and 40
0.9894404665434904

julia> decrement(vbt2001.ultimate,30,40) # the decrement between ages 30 and 40
0.010559533456509618
```

**Parametric Models**

Over 20 different models included. Example with the `Gompertz` model

```julia
m = MortalityTables.Gompertz(a=0.01,b=0.2)

m[20]                 # the mortality rate at age 20
decrement(m,20,25)    # the five year cumulative mortality rate
survival(m,20,25) # the five year survival rate
```
\\
[MortalityTables package on Github 🡕](https://github.com/JuliaActuary/MortalityTables.jl)




<!-- =============================
     ActuaryUtilities
    ============================== -->

## ActuaryUtilities.jl

> A collection of common functions/manipulations used in Actuarial Calculations.


Some of the functions included:

- `duration`:
  - Calculate the duration given an issue date and date (a.k.a. policy duration)
  - Calculate the `Macaulay`, `Modified`, or `DV01` durations for a set of cashflows
- `convexity` for price sensitivity
- `present_value` or `pv` to calculate the present value of a set of cashflows
- `discount_rate` for a given fixed rate or `InterestCurve`
- `internal_rate_of_return` or `irr` to calculate the IRR given cashflows (including at timepoints like Excel's `XIRR`)
- `breakeven` to calculate the breakeven time for a set of cashflows
- `accum_offset` to calculate accumulations like survival from a mortality vector

\\
[ActuaryUtilities package on GitHub 🡕](https://github.com/JuliaActuary/ActuaryUtilities.jl)



<!-- =============================
     LifeContingencies
    ============================== -->

## LifeContingencies.jl

> Common life contingent calculations with a convenient interface.

**Benefits**

- Integration with other JuliaActuary packages such as [MortalityTables.jl](https://github.com/JuliaActuary/MortalityTables.jl)
- Fast calculations, with some parts utilizing parallel processing power automatically
- Use functions that look more like the math you are used to (e.g. `A`, `ä`) with [Unicode support](https://docs.julialang.org/en/v1/manual/unicode-input/index.html)
- All of the power, speed, convenience, tooling, and ecosystem of Julia
- Flexible and modular modeling approach

**Package Overview**

- Leverages [MortalityTables.jl](https://github.com/JuliaActuary/MortalityTables.jl) for the mortality calculations
- Contains common insurance calculations such as:
    - `A(life)`: Whole life
    - `A(life,n)`: Term life for `n` years
    - `ä(life)`: Life contingent annuity due
    - `ä(life,n)`: Life contingent annuity due for `n` years
- Contains various commutation functions such as `D(x)`,`M(x)`,`C(x)`, etc.
- `SingleLife` and `JointLife` capable
- Various interest rate mechanics (e.g. stochastic, constant, etc.)
- More documentation available by clicking the DOCS badges at the top of this README

**Quickstart**

Calculate various items for a 30-year-old male nonsmoker using 2015 VBT base table and a 5% interest rate

```julia
using LifeContingencies, MortalityTables

tbls = MortalityTables.tables()
vbt2001 = tbls["2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB"]
age = 30
life = SingleLife(
    mort = vbt2001.select[age],
    issue_age = age
)

lc = LifeContingency(
    life,
    InterestRate(0.05)
)


A(lc)        # Whole Life insurance
A(lc,10)     # 10 year term insurance
P(lc)        # Net whole life premium 
V(lc,5)      # Net premium reserve for whole life insurance at time 5
ä(lc)        # Whole life annuity due
ä(lc, 5)     # 5 year annuity due
...          # and more!
```
\\
[LifeContingencies package on GitHub 🡕](https://github.com/JuliaActuary/LifeContingencies.jl)

# Community 
<!-- =============================
     Learn
    ============================== -->

## Learn

> Resources to help get started.

### Programming and Julia

- [JuliaLang.org](https://julialang.org/), the home site with the downloads to get started, and links to learning resources.
- [JuliaHub](https://juliahub.com/ui/Home) indexes open-source Julia packages and makes the entire ecosystem and documentation searchable from one place.
- [JuliaAcademy](https://juliaacademy.com/courses), which has free short courses in Data Science, Introduction to Julia, DataFrames.jl, Machine Learning, and more.
- [Data Science Tutorials](https://alan-turing-institute.github.io/DataScienceTutorials.jl/) from the Alan Turing Institute.
- [Learn Julia in Y minutes](https://learnxinyminutes.com/docs/julia/), a great quick-start if you are already comfortable with coding.
- [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html), a free e-book (or paid print edition) book which introduces programming from the start and teaches you valuable ways of thinking.
- [Design Patterns and Best Practices](https://www.packtpub.com/application-development/hands-design-patterns-julia-10), a book that will help you as you transition from smaller, one-off scripts to designing larger packages and projects.

### Actuarial Usage and Examples

#### Documentation

Each package includes examples on the Github site and in the documentation.

#### Walkthroughs and tutorials 
Coming soon!

#### Miscellaneous

- [Interactive exploration](/tutorials/PlutoESG) of the AAA's Economic Scenario Generator
- [Universal Life Policy Account Mechanics as a Differential Equation](/tutorials/PolicyDiffEq)

#### Help mode

You can also access help text when using the packages in the REPL by [activating help mode](https://docs.julialang.org/en/v1/stdlib/REPL/index.html#Help-mode-1), e.g.:

```julia-repl
julia> ? survival
    survival(mortality_vector,to_age)
    survival(mortality_vector,from_age,to_age)


  Returns the survival through attained age to_age. The start of the 
  calculation is either the start of the vector, or attained age `from_age` 
  and `to_age` need to be Integers. 

  Add a DeathDistribution as the last argument to handle floating point 
  and non-whole ages:

    survival(mortality_vector,to_age,::DeathDistribution)
    survival(mortality_vector,from_age,to_age,::DeathDistribution)


  If given a negative to_age, it will return 1.0. Aside from simplifying the code, 
  this makes sense as for something to exist in order to decrement in the first place, 
  it must have existed and surived to the point of being able to be decremented.

  Examples
  ≡≡≡≡≡≡≡≡≡≡

  julia> qs = UltimateMortality([0.1,0.3,0.6,1]);

  julia> survival(qs,0)
  1.0
  julia> survival(qs,1)
  0.9

  julia> survival(qs,1,1)
  1.0
  julia> survival(qs,1,2)
  0.7

  julia> survival(qs,0.5,Uniform())
  0.95
```

## Integration with R and Python

Julia integrates with other languages, allowing you to leverage existing scripts and packages in R via [RCall](https://github.com/JuliaInterop/RCall.jl) and in Python  via [PyCall](https://github.com/JuliaPy/PyCall.jl).

<!-- =============================
     Contributing
    ============================== -->

## Contributing

> Help by contributing code, asking questions, or reporting issues.

~~~
<p>First off, <mark>thank you</mark> for your interest in modern actuarial solutions, no matter how you participate in the community.</p>
~~~

**License and Usage**:
The packages in JuliaActuary are open-source and liberally licensed (MIT License) to allow wide private and commercial usage of the packages, like the base Julia language and many other packages in the ecosystem.

**Pull Requests**:
JuliaActuary is open source; you are free to modify, use, or change your copy of the code - but if you make enhancements please consider opening a pull request ([basic walkthrough here](https://kshyatt.github.io/post/firstjuliapr/)).

**Issues**:
If you find issues, please open an issue on the relevant package's repository and we will try and address it as soon as possible.

**Discussion and Questions**:
If you have other ideas or questions, feel free to also open an issue, or discuss on the community [Zulip](https://julialang.zulipchat.com/#narrow/stream/249536-actuary) or [Slack #actuary channel](https://slackinvite.julialang.org/). We welcome all actuarial and related disciplines!


# Blog

- [Coding the Future](/blog/coding-for-the-future/)
  - Building the insurance company of tomorrow by being a 10x actuary.
- [Julia for Actuaries](/blog/julia-actuaries/) 
  - Why Julia works so well for actuarial science. 

~~~
<em>Subscribe to new posts via the <a href="feed.xml">JuliaActuary RSS Feed <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path fill="none" d="M0 0h24v24H0z"/><path d="M3 3c9.941 0 18 8.059 18 18h-3c0-8.284-6.716-15-15-15V3zm0 7c6.075 0 11 4.925 11 11h-3a8 8 0 0 0-8-8v-3zm0 7a4 4 0 0 1 4 4H3v-4z"/></svg></a></em>
~~~