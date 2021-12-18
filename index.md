@def title = "Home"
@def tags = ["syntax", "code"]

<!-- =============================
     ABOUT
    ============================== -->


~~~

<div class="swiffy-slider slider-item-reveal slider-nav-autoplay" data-slider-nav-autoplay-interval="7500">
    <ul class="slider-container">
        <li>
        <div class="code-carousel">
          <div class="top">
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="code-example-head" >JuliaActuary Example</span>
  </div>
~~~

```julia-repl
julia> using MortalityTables

julia> MortalityTables.table("2015 VBT Smoker Distinct Male Non-Smoker ALB")
MortalityTable (Insured Lives Mortality):
   Name:
       2015 VBT Smoker Distinct Male Non-Smoker ALB
   Fields:
       (:select, :ultimate, :metadata)
   Provider:
       American Academy of Actuaries along with the Society of Actuaries
   mort.SOA.org ID:
       3269
   mort.SOA.org link:
       https://mort.soa.org/ViewTable.aspx?&TableIdentity=3269
   Description:
       2015 Valuation Basic Table (VBT) Smoker Distinct Table...
```

~~~
       </div>
        </li>
        <li>
        <div class="code-carousel">
          <div class="top">
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="dot"></span>
        <span class="code-example-head" >JuliaActuary Example</span>
  </div>

~~~

```julia-repl

julia> using Yields

julia> maturities = [0.5, 1.0, 1.5, 2.0]
julia> rates      = [5.0, 5.8, 6.4, 6.8] ./ 100

julia> rf_curve = Yields.Zero(rates,maturities)

               ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀Yield Curve (Yields.YieldCurve)⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
               ┌────────────────────────────────────────────────────────────┐
           0.4 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ Zero rates
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠒⠋│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠤⠖⠊⠉⠁⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠔⠒⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠒⠊⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   Periodic(1) │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠖⠊⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠖⠊⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠒⠊⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡤⠤⠒⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠖⠒⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠀⢀⡠⠤⠒⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               │⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
             0 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
               └────────────────────────────────────────────────────────────┘
               ⠀0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀time⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀30⠀
```

~~~


        </div></li>
                <li>
        <div class="code-carousel">
                <div class="code-carousel">
          <div class="top">
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="dot"></span>
        <span class="code-example-head" >JuliaActuary Example</span>
  </div>
~~~

```julia-repl

julia> using ActuaryUtilities

julia> cashflows = [5, 5, 105]
julia> discount_rate = 0.03

julia> present_value(discount_rate, cashflows)           
105.65

julia> duration(Macaulay(), discount_rate, cashflows)    
2.86

julia> duration(discount_rate, cashflows)                
2.78

julia> convexity(discount_rate, cashflows)               
10.62
```

~~~


        </div></li>
                <li>
        <div class="code-carousel">
                <div class="code-carousel">
          <div class="top">
    <span class="dot"></span>
    <span class="dot"></span>
    <span class="dot"></span>
        <span class="code-example-head" >JuliaActuary Example</span>
  </div>
~~~

```julia
using LifeContingencies
using MortalityTables
using Yields

# load mortality rates from MortalityTables.jl
vbt2015 = MortalityTables.table("2015 VBT Smoker Distinct Male Non-Smoker ALB")

issue_age = 30
life = SingleLife(                       # The life underlying the risk
    mort = vbt2015.select[issue_age],    # -- Mortality rates
)

yield = Yields.Constant(0.05)            # Using a flat 5% interest rate

ins = Insurance(life, yield)             # alternate way to construct

# Summary Scalars
present_value(ins)                       # The actuarial present value
premium_net(lc)                          # Net whole life premium 
V(lc,5)                                  # Net premium reserve for whole life insurance at time 5
```

~~~


        </div></li>

    </ul>

    <button type="button" class="slider-nav"></button>
    <button type="button" class="slider-nav slider-nav-next"></button>

    <div class="slider-indicators">
        <button class="active"></button>
        <button></button>
        <button></button>
        <button></button>
    </div>
</div>
    
~~~
# About

> JuliaActuary is focused on building packages that enable actuaries everywhere to build solutions using open-source tools.

**Julia** as a language works as [an ideal language for Actuaries and other financial professionals](/blog/julia-actuaries/). 

**JuliaActuary** is an ecosystem of packages that makes Julia the easiest language to get started for actuarial workflows.

It is free, open-source software and you can [join the development on Github]("https://github.com/JuliaActuary/").

<!-- =============================
     PACKAGES
     ============================== -->
# Packages

These packages are available for use in your project.

[`MortalityTables.jl`](/packages#mortalitytablesjl)
  - Easily work with standard [mort.SOA.org](https://mort.soa.org/) tables and parametric models with common survival calculations.

[`LifeContingencies.jl`](#lifecontingenciesjl)
- Insurance, annuity, premium, and reserve maths.

[`ActuaryUtilities.jl`](#actuaryutilitiesjl)
- Robust and fast calculations for `internal_rate_of_return`, `duration`, `convexity`, `present_value`, `breakeven`, and more. 

[`Yields.jl`](#yieldsjl)※
- Simple and composable yield curves and calculations.

[`ExperienceAnalysis.jl`](#experienceanalysisjl)※
- Meeting your exposure calculation needs.


# JuliaActuary Community

If you want to:

- Learn Julia or the basics of programming
- See actuarial usage and examples
- Integrate with R or Python code
- Contribute to JuliaActuary
- Get help and ask questions

Then check out the [Community](/community) page!

# Blog

- [Coding the Future](/blog/coding-for-the-future/)
  - Building the insurance company of tomorrow by being a 10x actuary.
- [Julia for Actuaries](/blog/julia-actuaries/) 
  - Why Julia works so well for actuarial science. 
- [Getting Started with Julia for Actuaries](/blog/julia-getting-started-actuaries/)
  - Getting started with Julia with a bent towards things actuaries care about.
- [The Life Modeling Problem: A Comparison of Julia, Rust, Python, and R](/blog/life-modeling-problem/) 
  - Why Julia works so well for actuarial science.


~~~
<em>Subscribe to new posts via the <a href="feed.xml">JuliaActuary RSS Feed <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16"><path fill="none" d="M0 0h24v24H0z"/><path d="M3 3c9.941 0 18 8.059 18 18h-3c0-8.284-6.716-15-15-15V3zm0 7c6.075 0 11 4.925 11 11h-3a8 8 0 0 0-8-8v-3zm0 7a4 4 0 0 1 4 4H3v-4z"/></svg></a></em>
~~~