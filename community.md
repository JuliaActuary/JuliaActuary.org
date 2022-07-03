@def title = "Community"
@def tags = ["syntax", "code"]

# Community 

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


After installing Julia from the official website, head to the [Packages](/packages) to see how to install JuliaActuary packages.

## Actuarial Usage and Examples

> See Julia in action in actuarial contexts

### Documentation

Each package includes examples on the Github site and in the documentation.

### Walkthroughs and tutorials

- [Getting MortalityTables.jl data into a dataframes](/tutorials/MortalityTablesDataFrame/)
- [Exposure Calculation with ExperienceAnalysis.jl](/tutorials/exposure_calculation/)
- [Fitting Survival Data](/tutorials/SurvivalFitting/)
- [Stochastic Mortality Projections](/tutorials/StochasticMortality/)
- [Bayesian Markov-Chain-Monte-Carlo and Claims Data](/tutorials/Bayesian/)
- [Fitting Interest Rates to Yield Curves](/tutorials/yield-curve-fitting/)
- [Nested Policy Projections](/tutorials/nested_stochastic/)

### Benchmarks

Benchmarks of Actuarial workflows can be found on the [Benchmarks](/benchmarks/) page.

### Miscellaneous

- [Interactive exploration](/tutorials/PlutoESG/) of the AAA's Economic Scenario Generator
- [A comparison](/tutorials/USTreasury/) of U.S. Treasury CMT rates
- [Interactive mortality table comparison tool](/tutorials/MortalityTableComparison/) for any `mort.soa.org` table
- [Interactive cashflow analysis](/tutorials/CashflowAnalysis/)
- [Universal Life Policy Account Mechanics as a Differential Equation](/tutorials/PolicyDiffEq/)

### Other Repositories of Interest for Actuaries

- [RMInsurance](https://github.com/mkriele/RMInsurance.jl) is the code and examples for the second edition of the book "Value-Oriented Risk Management of Insurance Companies"
- [LifeTable.jl](https://github.com/klpn/LifeTable.jl) will caculate life tables from the Human Mortality Database.

## Get Help

> Ask questions or suggest ideas

### Discussion and Questions

If you have other ideas or questions, join the [JuliaActuary Github Discussions](https://github.com/orgs/JuliaActuary/discussions). Or come say hello on the community [Zulip](https://julialang.zulipchat.com/#narrow/stream/249536-actuary) or [Slack #actuary channel](https://julialang.org/slack/). We welcome all actuarial and related disciplines!

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


## Integration with R and Python

> Use other languages seamlessly

Julia integrates with other languages, allowing you to leverage existing scripts and packages in R via [RCall](https://github.com/JuliaInterop/RCall.jl) and in Python  via [PyCall](https://github.com/JuliaPy/PyCall.jl).

<!-- =============================
     Contributing
    ============================== -->

## Contributing

> Contribute code or report issues.

~~~
<mark>Thank you</mark> for your interest in modern actuarial solutions, no matter how you participate in the community.</p>
~~~

### Pull Requests

JuliaActuary is open source; you are free to modify, use, or change your copy of the code - but if you make enhancements please consider opening a pull request ([basic walkthrough here](https://kshyatt.github.io/post/firstjuliapr/)). Beginners are welcome and we can help with your first pull request!

### Issues

If you find issues, please open an issue on the relevant package's repository and we will try and address it as soon as possible.

### Project Board

See the [Good first Issues](https://github.com/orgs/JuliaActuary/projects/2) project board on Github for simple, self-contained ways to contribute such as adding small new features, improving the documentation, or writing up a tutorial on how to do something simple!


## Other Inquiries

For more directed inquires, please send email to [inquiry@JuliaActuary.org](mailto:inquiry@juliaactuary.org).

## Share 

Follow [JuliaActuary](https://www.linkedin.com/company/juliaactuary) on LinkedIn for updates and to share with colleagues!