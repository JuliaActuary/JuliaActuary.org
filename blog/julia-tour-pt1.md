@def author = "Alec Loudenback"
@def date = "July 18, 2021"
@def title = "A tour of the Julia Ecosystem"

@def rss_pubdate = Date(2020,9,27)
@def rss = "Julia is a new programming language that's ideally suited for most actuarial workflows."

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*7

The article titled [Julia for Actuaries](/blog/julia-actuaries) gave a longer introduction to why Julia works so well in Actuarial Workflows. In summary: Julia's attribtutes are "evident in its pragmatic, productivity-focused design choices, pleasant syntax, rich ecosystem, thriving communities, and its ability to be both very general purpose and power cutting edge computing."

This set of articles will introduce three aspects of the Julia ecosystem:

1. Basic tooling and general packages of interest
2. Actuarial focused packages

## Julia's ecosystem

### Basic Tooling

#### Installation

Julia is open source and can be downloaded from [JuliaLang.org](https://JuliaLang.org) and is available for all major operating systems. After you download and install, then you have Julia installed and can access the **REPL**, or Read-Eval-Print-Loop, which can run complete programs or [function as powerful day-to-day calculator](https://krasjet.com/rnd.wlk/julia/). However, many people find it more comfortable to work in a text editor or **IDE** (Integrated Development Environment).

If you want a pre-packaged solution with a curated set of packages, consider the JuliaPro installation available from [Julia Computing](https://juliacomputing.com/), which has optional upgrades for more turn-key enterprise support.

### Package Management

Julia comes with `Pkg`, a built-in package amanger. With it, you can install packages, pin certain versions, recreate environmnets with the same set of dependencies, and upgrade/remove/develop packages easily. It's one of the things that *just works* and makes Julia stand out versus alternative languages that don't have a de-facto way of managing or installing packages.

Package installation is accomplished interatvely in the REPL, or executing commands.

- In the REPL, you can change to the Package Management Mode by hitting `]` and, e.g., `add DataFrames CSV` to install the two packages. Hit backspace to exit that mode in the REPL.
- To execute certain commands, the above would be the same as `using Pkg; Pkg.add(["DataFrames", "CSV"])`

Related to packages, is **environments** which are a self-contained workspace for your code. This lets you install only packages that are relevant to the current work. It also lets you 'remember' the exact set of packages and versions that you used. In fact, you can share the environment with others and it will be able to recreate the same environment as when you ran the code. This is accomplished via a `Project.toml` file, which tracks the direct dependencies you've added, along with details about your project like its version number. The `Manifest.toml` tracks the entire dependency tree.

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
- The "tidyverse" in R has a tightly coupled set of pacakges that works well together but has limitations with some other R packages

Julia is not perfect in this regard, but it's really neat to see how frequently things *just work*. It's not magic, but because of Julia features outside the scope of this article it's easy for package developers (and you!) to do this.

Julia also has language-level support for documentation, so packages are able to follow a consistent style of help text and have the docs be auto-generated into web pages available online.

#### Data

Starting with getting data in and out of your code, `CSV.jl` offers top-class read and write performance. `ODBC.jl` lets you connect to any database.

`DataFrames.jl` is a mature package for working with dataframes, comparable to Pandas or dplyr. 

`Dates` is a built-in package which builds on years of pain-points related to date manipulation into a straightforward and complete interface.

#### Plotting

`Plots.jl` isn't really a plotting tool - more specifically it's an interface to consistently work with a number of plotting backends, depending if you are trying to emphasize interactivity on the web or print-quality output. You can very easily add animations or change almost any feature of a plot.

`Makie.jl` is an up-and-coming package that supports GPU-accelerated plotting and can create very rich, beautful visualizations, but it's a little less beginner friendly.


#### Statistics

Julia has first-class suport for `missing` values, which follows the rules of [three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic) so other pacakges don't need to do anything special to incorporate missing values.



#### Utilities

`Revise.jl`
`BenchmarkTools.jl`