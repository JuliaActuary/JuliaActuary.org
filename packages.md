@def title = "Packages Overview"
@def tags = ["syntax", "code"]

<!-- =============================
     PACKAGES
     ============================== -->
# Packages

These packages are available for use in your project. Scroll down for more information on each one.

[`MortalityTables.jl`](/packages/#mortalitytablesjl)
  - Easily work with standard [mort.SOA.org](https://mort.soa.org/) tables and parametric models with common survival calculations.

[`LifeContingencies.jl`](/packages/#lifecontingenciesjl)
- Insurance, annuity, premium, and reserve maths.

[`ActuaryUtilities.jl`](/packages/#actuaryutilitiesjl)
- Robust and fast calculations for `internal_rate_of_return`, `duration`, `convexity`, `present_value`, `breakeven`, and more. 

[`Yields.jl`](/packages/#yieldsjl)※
- Simple and composable yield curves and calculations.

[`ExperienceAnalysis.jl`](/packages/#experienceanalysisjl)※
- Meeting your exposure calculation needs.


~~~
<div class="alert alert-info">
 

<p><strong>Note:</strong> packages marked with ※ are developing: the functionality is built-out and tested, but the API may change. </p>

<p>For consistency, you can lock any package in its current state and not worry about breaking changes to any code that you write. Julia's package manager lets you <a href="https://julialang.github.io/Pkg.jl/v1/toml-files/#Manifest.toml-1" >exactly recreate a set of code and its dependencies.</a> (<a href="https://stackoverflow.com/questions/63485891/how-do-i-ensure-repeatability-of-julia-code-and-assoicated-dependencies">More</a>).</p>
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


### Features

- Full set of SOA mort.soa.org tables included
- `survival` and `decrement` functions to calculate decrements over period of time
- Partial year mortality calculations (Uniform, Constant, Balducci)
- Friendly syntax and flexible usage
- Extensive set of parametric mortality models.

### Quickstart

Load and see information about a particular table:

```julia
julia> vbt2001 = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")

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

```julia
julia> vbt2001.select[35]          # vector of rates for issue age 35
 0.00036
 0.00048
 ⋮
 0.94729
 1.0
 
julia> vbt2001.select[35][35]      # issue age 35, attained age 35
 0.00036
 
julia> vbt2001.select[35][50:end] # issue age 35, attained age 50 through end of table
0.00316
0.00345
 ⋮
0.94729
1.0

julia> vbt2001.ultimate[95]        # ultimate vectors only need to be called with the attained age
 0.24298
```

Calculate the force of mortality or survival over a range of time:

```julia
julia> survival(vbt2001.ultimate,30,40) # the survival between ages 30 and 40
0.9894404665434904

julia> decrement(vbt2001.ultimate,30,40) # the decrement between ages 30 and 40
0.010559533456509618
```

Non-whole periods of time are supported when you specify the assumption (`Constant()`, `Uniform()`, or `Balducci()`) for fractional periods:

```julia
julia> survival(vbt2001.ultimate,30,40.5,Uniform()) # the survival between ages 30 and 40.5
0.9887676470262408
```

### Parametric Models

Over 20 different models included. Example with the `Gompertz` model

```julia
m = MortalityTables.Gompertz(a=0.01,b=0.2)

m[20]                 # the mortality rate at age 20
decrement(m,20,25)    # the five year cumulative mortality rate
survival(m,20,25) # the five year survival rate
```
\\
[MortalityTables package on Github 🡭](https://github.com/JuliaActuary/MortalityTables.jl)


<!-- =============================
     ActuaryUtilities
    ============================== -->

## ActuaryUtilities.jl

> A collection of common functions/manipulations used in Actuarial Calculations.

### Financial Maths
- `duration`:
  - Calculate the `Macaulay`, `Modified`, or `DV01` durations for a set of cashflows
- `convexity` for price sensitivity
- Flexible interest rate options via the [`Yields.jl`](https://github.com/JuliaActuary/Yields.jl) package.
- `internal_rate_of_return` or `irr` to calculate the IRR given cashflows (including at timepoints like Excel's `XIRR`)
- `breakeven` to calculate the breakeven time for a set of cashflows
- `accum_offset` to calculate accumulations like survivorship from a mortality vector

### Risk Measures

- Calculate risk measures for a given vector of risks:
  - `CTE` for the Conditional Tail Expectation, or
  - `VaR` for the percentile/Value at Risk.

### Insurance mechanics

- `duration`:
  - Calculate the duration given an issue date and date (a.k.a. policy duration)
  
\\
[ActuaryUtilities package on GitHub 🡭](https://github.com/JuliaActuary/ActuaryUtilities.jl)


<!-- =============================
     LifeContingencies
    ============================== -->

## LifeContingencies.jl

> Common life contingent calculations with a convenient interface.


### Features

- Integration with other JuliaActuary packages such as [MortalityTables.jl](https://github.com/JuliaActuary/MortalityTables.jl)
- Fast calculations, with some parts utilizing parallel processing power automatically
- Use functions that look more like the math you are used to (e.g. `A`, `ä`) with [Unicode support](https://docs.julialang.org/en/v1/manual/unicode-input/index.html)
- All of the power, speed, convenience, tooling, and ecosystem of Julia
- Flexible and modular modeling approach

### Package Overview

- Leverages [MortalityTables.jl](https://github.com/JuliaActuary/MortalityTables.jl) for
the mortality calculations
- Contains common insurance calculations such as:
  - `Insurance(life,yield)`: Whole life
  - `Insurance(life,yield,n)`: Term life for `n` years
  - `ä(life,yield)`: Life contingent annuity due
  - `ä(life,yield)`: Life contingent annuity due for `n` years
- Contains various commutation functions such as `D(x)`,`M(x)`,`C(x)`, etc.
- `SingleLife` and `JointLife` capable
- Interest rate mechanics via [`Yields.jl`](https://github.com/JuliaActuary/Yields.jl)
- More documentation available by clicking the DOCS badges at the top of this README

### Examples

#### Basic Functions

Calculate various items for a 30-year-old male nonsmoker using 2015 VBT base table and a 5% interest rate

```julia

using LifeContingencies
using MortalityTables
using Yields
import LifeConingencies: V, ä      # pull the shortform notation into scope

# load mortality rates from MortalityTables.jl
tbls = MortalityTables.tables()
vbt2001 = tbls["2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB"]

issue_age = 30
life = SingleLife(                 # The life underlying the risk
    mort = vbt2001.select[issue_age],    # -- Mortality rates
)

yield = Yields.Constant(0.05)      # Using a flat 5% interest rate

lc = LifeContingency(life, yield)  # LifeContingency joins the risk with interest


ins = Insurance(lc)                # Whole Life insurance
ins = Insurance(life, yield)       # alternate way to construct
```

With the above life contingent data, we can calculate vectors of relevant information:

```julia
cashflows(ins)                     # A vector of the unit cashflows
timepoints(ins)                    # The timepoints associated with the cashflows
survival(ins)                      # The survival vector
benefit(ins)                       # The unit benefit vector
probability(ins)                   # The probability of beneift payment
```

Or calculate summary scalars:

```julia
present_value(ins)                 # The actuarial present value
premium_net(lc)                    # Net whole life premium 
V(lc,5)                            # Net premium reserve for whole life insurance at time 5
```

Other types of life contingent benefits:

```julia
Insurance(lc,n=10)                   # 10 year term insurance
AnnuityImmediate(lc)               # Whole life annuity due
AnnuityDue(lc)                     # Whole life annuity due
ä(lc)                              # Shortform notation
ä(lc, n=5)                         # 5 year annuity due
ä(lc, n=5, certain=5,frequency=4)  # 5 year annuity due, with 5 year certain payable 4x per year
...                                # and more!
```

#### Constructing Lives

```julia
SingleLife(vbt2001.select[50])                 # no keywords, just a mortality vector
SingleLife(vbt2001.select[50],issue_age = 60)  # select at 50, but now 60
SingleLife(vbt2001.select,issue_age = 50)      # use issue_age to pick the right select vector
SingleLife(mort=vbt2001.select,issue_age = 50) # mort can also be a keyword

```
\\
[LifeContingencies package on GitHub 🡭](https://github.com/JuliaActuary/LifeContingencies.jl)


<!-- =============================
     Yields
    ============================== -->

## Yields.jl

> Flexible and composable yield curves and interest functions.

Provides a simple interface for constructing, manipulating, and using yield curves for modeling purposes. Includes bootstrapping methods and kernel methods like Smith-Wilson, which is used in Solvency II reporting.

It's intended to provide common functionality around modeling interest rates, spreads, and miscellaneous yields across the JuliaActuary ecosystem (though not limited to use in JuliaActuary packages).

### QuickStart

```julia
using Yields

riskfree_maturities = [0.5, 1.0, 1.5, 2.0]
riskfree    = [5.0, 5.8, 6.4, 6.8] ./ 100     #spot rates

spread_maturities = [0.5, 1.0, 1.5, 3.0]      # different maturities
spread    = [1.0, 1.8, 1.4, 1.8] ./ 100       # spot spreads

rf_curve = Yields.Zero(riskfree,riskfree_maturities)
spread_curve = Yields.Zero(spread,spread_maturities)


yield = rf_curve + spread_curve               # additive combination of the two curves

discount(yield,1.0) # 1 / (1 + 0.058 + 0.018)
```

\\
[Yields package on GitHub 🡭](https://github.com/JuliaActuary/Yields.jl)


<!-- =============================
     ExperienceAnalysis
    ============================== -->

## ExperienceAnalysis.jl

> Meeting your exposure calculation needs.


### QuickStart

```julia
using ExperienceAnalysis
using Dates

issue = Date(2016, 7, 4)
termination = Date(2020, 1, 17)
basis = ExperienceAnalysis.Anniversary(Year(1))
exposure(basis, issue, termination)
```
This will return an array of tuples with a `from` and `to` date:

```julia
4-element Array{NamedTuple{(:from, :to),Tuple{Date,Date}},1}:
 (from = Date("2016-07-04"), to = Date("2017-07-04"))
 (from = Date("2017-07-04"), to = Date("2018-07-04"))
 (from = Date("2018-07-04"), to = Date("2019-07-04"))
 (from = Date("2019-07-04"), to = Date("2020-01-17"))
```

### Available Exposure Basis

- `ExperienceAnalysis.Anniversary(period)` will give exposures periods based on the first date
- `ExperienceAnalysis.Calendar(period)` will follow calendar periods (e.g. month or year)
- `ExperienceAnalysis.AnniversaryCalendar(period,period)` will split into the smaller of the calendar or policy period.

Where `period` is a [Period Type from the Dates standard library](https://docs.julialang.org/en/v1/stdlib/Dates/#Period-Types).

Calculate exposures with `exposures(basis,from,to,continue_exposure)`. 

- `continue_exposures` indicates whether the exposure should be extended through the full exposure period rather than terminate at the `to` date.

\\
[ExperienceAnalysis package on GitHub 🡭](https://github.com/JuliaActuary/ExperienceAnalysis.jl)

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
- [Getting MortalityTables.jl data into a dataframes](/tutorials/MortalityTablesDataFrame/) 

#### Benchmarks

Benchmarks of Actuarial workflows can be found on the [Benchmarks](/benchmarks/) page.

#### Miscellaneous

- [Interactive exploration](/tutorials/PlutoESG/) of the AAA's Economic Scenario Generator
- [Interactive mortality table comparison tool](/tutorials/MortalityTableComparison/) for any `mort.soa.org` table
- [Interactive cashflow analysis](/tutorials/CashflowAnalysis/)
- [Universal Life Policy Account Mechanics as a Differential Equation](/tutorials/PolicyDiffEq/)

### Help mode

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
  it must have existed and survived to the point of being able to be decremented.

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

### Other Repositories of Interest for Actuaries

- [RMInsurance](https://github.com/mkriele/RMInsurance.jl) is the code and examples for the second edition of the book "Value-Oriented Risk Management of Insurance Companies"
- [LifeTable.jl](https://github.com/klpn/LifeTable.jl) will caculate life tables from the Human Mortality Database.