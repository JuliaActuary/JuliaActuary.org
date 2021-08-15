@def author = "Alec Loudenback"
@def date = "July 18, 2021"
@def title = "A tour of the Julia Ecosystem"

@def rss_pubdate = Date(2021,7,18)
@def rss = "Julia is a new programming language that's ideally suited for most actuarial workflows."

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*7

> **!! Note that this article is a draft**

The article titled [Julia for Actuaries](/blog/julia-actuaries) gave a longer introduction to why Julia works so well in Actuarial Workflows. In summary: Julia's attributes are "evident in its pragmatic, productivity-focused design choices, pleasant syntax, rich ecosystem, thriving communities, and its ability to be both very general purpose and power cutting edge computing".

In the [2021 Stack Overflow Survey](https://insights.stackoverflow.com/survey/2021?_ga=2.236209345.190202062.1628102352-126161871.1625855113#technology-most-loved-dreaded-and-wanted), Julia was the 5th most loved language. This was ahead of other languages commonly used in actuarial contexts, such as Python (6th), R (28th), C++ (25th), Matlab (36th), or VBA (37th).

This set of articles will introduce three aspects of the Julia ecosystem:

1. Basic tooling and general packages of interest
2. Actuarial focused packages

## Reminder of "why Julia?"

There are three main reasons to consider using Julia:

1) **The language itself offers expressiveness, pleasant syntax, and less boilerplate than many alternatives.** Multiple dispatch is an evolution of object-oriented approaches that's more amenable to a wide range of programming styles, including functional and vectorized approaches.

2) **High performance Julia code, instead of needing libraries written in C/Cython/etc..** For lots of problems, especially "toy" problems as you learn a language, the speed of Matlab/Python/R is fast enough. However, in real usage, particularly actuarial problems, you might find that when you need the performance it's too late[^1]

3) **The tooling and ecosystem is very modern, mature, and broad.** A built-in package manager, packages that work together without needing to know about each other, differentiable programming, first-class GPU/parallel support, and wide range of packages relevant (and specialized for) actuarial workloads.

Why Julia works so well in actuarial contexts was discussed in the prior article, [Julia for Actuaries](/blog/julia-actuaries). The rest of this article is going to focus on getting oriented to using Julia, and the next article in the series will introduce actuarial packages available.

## Julia's ecosystem

### Basic Tooling

#### Installation

Julia is open source and can be downloaded from [JuliaLang.org](https://JuliaLang.org) and is available for all major operating systems. After you download and install, then you have Julia installed and can access the **REPL**, or Read-Eval-Print-Loop, which can run complete programs or [function as powerful day-to-day calculator](https://krasjet.com/rnd.wlk/julia/). However, many people find it more comfortable to work in a text editor or **IDE** (Integrated Development Environment).

If you want a pre-packaged solution with a curated set of packages, consider the JuliaPro installation available from [Julia Computing](https://juliacomputing.com/), which has optional upgrades for more turn-key enterprise support.

### The language itself

Julia is a high level language, with syntax that should feel familiar to someone coming from R, Python, or Matlab. There's a ton of great references online, such as:

- [Matlab-Python-Julia Cheatsheet](https://cheatsheets.quantecon.org/)
- [Learn Julia in Y minutes](https://learnxinyminutes.com/docs/julia/)
- [Julia Official Documenation](https://docs.julialang.org/en/v1/manual/getting-started/)

Julia code is compiled on-the-fly, generating efficient code for the specific data that you are currently working with. This is kind of an in-between of a fully interpreted language (like pure Python or R) and a complied language like C++ which must compile everything in advance.

Born of a desire to have the niceties of high level languages with the performance of low level compiled code, there are many built-in data structures and functions related to numerical computing like that used in finance, insurance, and statistics.

If you want a ground-up introduction, the e-book [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html) starts simple and builds up. If you prefer a learn-by-example, the interactive, free, online course [Introduction to Computational Thinking](https://computationalthinking.mit.edu/Spring21/) by MIT will have you working on everything from data science to climate modeling.

Lastly, [JuliaAcademy.com](https://juliaacademy.com/) has a number of free courses that introduce the language via data science, machine learning, or "nervous beginners".

### Package Management

Julia comes with `Pkg`, a built-in package manger. With it, you can install packages, pin certain versions, recreate environments with the same set of dependencies, and upgrade/remove/develop packages easily. It's one of the things that *just works* and makes Julia stand out versus alternative languages that don't have a de-facto way of managing or installing packages.

Package installation is accomplished interactively in the REPL or executing commands.

- In the REPL, you can change to the Package Management Mode by hitting `]` and, e.g., `add DataFrames CSV` to install the two packages. Hit backspace to exit that mode in the REPL.
- To execute certain commands, the above would be the same as `using Pkg; Pkg.add(["DataFrames", "CSV"])`

Related to packages, is **environments** which are a self-contained workspace for your code. This lets you install only packages that are relevant to the current work. It also lets you 'remember' the exact set of packages and versions that you used. In fact, you can share the environment with others, and it will be able to recreate the same environment as when you ran the code. This is accomplished via a `Project.toml` file, which tracks the direct dependencies you've added, along with details about your project like its version number. The `Manifest.toml` tracks the entire dependency tree.

#### Editors

Because Julia is very extensible and amenable to analysis of its own code, you can typically find plugins for whatever tool you prefer to write code in. I will mention a few here:

##### Visual Studio Code

Visual Studio Code is a free editor from Microsoft. There's a full-featured Julia plugin available, which will help with auto-completion, warnings, and other code hints that you might find in a dedicated editor (e.g. PyCharm or RStudio). Like those tools, you can view plots, show datasets, debug, and manage version control.

##### Notebooks

Notebooks are typically more interactive environments than text editors - you can write code in cells and see the results side-by-side.

The most popular notebook tool is Jupyter ("Julia, Python, R"). It is widely used and fits in well with exploratory data analysis or other interactive workflows. It can be installed by adding the [`IJulia.jl`](https://github.com/JuliaLang/IJulia.jl) package.

[`Pluto.jl`](https://plutojl.org/) is a newer tool, which adds reactivity and interactivity. It is also more amenable to version control than Jupyter notebooks are. Pluto is unique to Julia because of the language's ability to introspect and analyze dependencies in its own code.

### A whirlwind tour of general-purpose packages

The Julia ecosystem favors composability and interoperability as an emergent aspect, enabled by multiple dispatch. In other words, because it's really easy to specialize functionality based on the type of data you are working with, there's much less need to bundle a lot of features within a single package. As you'll see, Julia packages tend to be less vertically integrated because its easier to pass data around. Counterexamples of this in Python and R:

- "numpy" compatible packages that are designed to work with the subset of numerically fast libraries in Python
- special functions in Pandas to read CSV, JSON, database connections, etc. 
- The "tidyverse" in R has a tightly coupled set of packages that works well together but has limitations with some other R packages

Julia is not perfect in this regard, but it's neat to see how frequently things *just work*. It's not magic, but because of Julia features outside the scope of this article it's easy for package developers (and you!) to do this.

Julia also has language-level support for documentation, so packages can follow a consistent style of help text and have the docs be auto-generated into web pages available online.

The following highlighted packages were chosen for their relevance to typical actuarial work, with a bias towards those I've personally used am familiar with. This is a small sampling of the over 6000 registered Julia Packages[^2]

#### Data

Starting with getting data in and out of your code, `CSV.jl` offers top-class read and write performance. `ODBC.jl` lets you connect to any database.

`DataFrames.jl` is a mature package for working with dataframes, comparable to Pandas or dplyr. 

`Dates` is a built-in package which builds on years of pain-points related to date manipulation into a straightforward and complete interface.

#### Plotting

`Plots.jl` isn't really a plotting tool - more specifically it's an interface to consistently work with several plotting backends, depending if you are trying to emphasize interactivity on the web or print-quality output. You can very easily add animations or change almost any feature of a plot.

`Makie.jl` is an up-and-coming package that supports GPU-accelerated plotting and can create very rich, beautiful visualizations, but it's a little less beginner friendly.

#### Statistics

Julia has first-class support for `missing` values, which follows the rules of [three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic) so other packages don't need to do anything special to incorporate missing values.

`StatsBase.jl` and `Distributions.jl` are essentials for a range of statistics functions and probability distributions respectively.

`Turing.jl`, a Bayesian Stats library, is outstanding in it's combination of clear model syntax with performance. `GLM.jl` is useful for any type of linear modeling.

#### Differentiable Progamming

Sensitivity testing is very common in actuarial workflows, but essentially it's often getting at understanding the change in one variable in relation to another. In other words, the derivative!

Julia has unique capabilities where almost across the entire language and ecosystem, you can take the derivate of entire functions or scripts. For example, the following is real Julia code to automatically calculate the sensitivity of the ending account value with respect to the inputs:

```julia-repl
julia> using Zygote

julia> function policy_av(pol)
	COIs = [0.00319,0.00345,0.0038,0.00419,0.0047,0.00532]
	av = 0.0
	for (i,coi) in enumerate(COIs)
		av += av * (pol.credit_rate)
		av += pol.annual_premium
		av -= (pol.face) * coi
	end
	return av                # return the final account value
end

julia> pol= (annual_premium = 1000, face = 100_000, credit_rate = 0.05);

julia> policy_av(pol)        # the ending account value
4048.08

julia> policy_av'(pol)       # the derivative of the account value with respect to the inputs
(annual_premium = 6.802, face = -0.0275, credit_rate = 10972.52)
```

When executing the code above, Julia isn't just adding a small amount and calculating the finite difference. Differentiation can be applied to entire programs through extensive use of basic derivatives and the chain rule. This concept, **automatic differentiation**, has a lot potential uses in optimization, machine learning, sensitivity testing, and risk analysis.

#### Machine Learning

`Flux.jl`, `Gen.jl`, `Knet`, and `MLJ` are all very popular machine learning libraries. Many of these libraries take advantage of the automatic differentiation mentioned above. There are also packages for PyTorch, Tensorflow, and SciKitML available.

#### Utilities

There are also a lot of nice quality-of-life packages, like `Revise.jl` which lets you edit code on the fly without needing to re-run entire scripts.

`BenchmarkTools.jl` makes it incredibly easy to benchmark your code - simply add `@benchmark` in front of what you want to test, and you will be presented with detailed statistics. For example:

```julia
julia> @benchmark present_value(0.05,[10,10,10])

BenchmarkTools.Trial: 10000 samples with 994 evaluations.
 Range (min … max):  33.492 ns … 829.015 ns  ┊ GC (min … max): 0.00% … 95.40%
 Time  (median):     34.708 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   36.599 ns ±  33.686 ns  ┊ GC (mean ± σ):  4.40% ±  4.55%

  ▁▃▆▆▆██▇▄▃▂         ▁                                        ▂
  █████████████▆▆▇█▇████▇██▇█▇█▇▇▆▆▅▅▅▅▅▄▅▄▄▅▅▅▅▄▄▁▅▄▄▅▄▄▅▅▆▅▆ █
  33.5 ns       Histogram: log(frequency) by time      45.6 ns <

 Memory estimate: 112 bytes, allocs estimate: 1.

```

`Test` is a built-in package for performing testsets, while `Documenter` will build high-quality documentation based on your inline documentation.

`ClipData.jl` lets you copy and paste from spreadsheets to Julia sessions.

#### Other packages

Julia is a general-purpose language, so you will find packages for web development, graphics, game development, audio production, and much more.

### Acturial packages

Saving the best for last, the next article in the series will dive deeper into actuarial packages, such as those published by [JuliaActaury](https://JuliaActuary.org) for easy mortality table manipulation, common actuarial functions, financial math, and experience analysis.

[^1]: https://ocw.mit.edu/courses/mathematics/18-335j-introduction-to-numerical-methods-spring-2019/week-1/Julia-intro.pdf
[^2]: As of July 2021.