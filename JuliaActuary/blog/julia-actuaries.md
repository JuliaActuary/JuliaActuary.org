@def author = "Alec Loudenback"
@def date = "July 9, 2020"
@def title = "Julia as the Language of Choice for Actuaries"

# {{fill title}}

*By:  {{fill author}}*

*{{fill date}}*

~~~
<div class="alert alert-danger"> <strong> NOTE: </strong> This article is a draft and the website/URLs are a work in progress. </div>
~~~

I have suggested that actuaries who are competent coders will differentiate both companies and individuals. Coding ability will be useful no matter what tools you utilize everyday (e.g. Python/R/C++/etc. and associated packages) and I appreciate the communities and tools provided in all of them for their contribution to moving actuarial processes out of the Spreadsheet Age.

However, I'd like to motivate why Julia is the best programming language for actuaries to learn and use it as the *holotype* for the modern actuarial process.


## Julia Overview

Julia is a relatively new programming language[^1], and *it shows*. It is evident in its pragmatic, productivity-focused design choices, pleasant syntax, rich ecosystem, thriving communities, and its ability to both be very general purpose and power cutting edge computing.

Math-heavy computations *look like math*, it's easy to pick up, quick-to-prototype, packages work well together, and has great visualization libraries. There's a growing body of online references and tutorials, videos, and print media to learn from and it's popularity continues to grow across many fields.

Large financial services companies have already started realizing gains: BlackRock's Aladdin portfolio modeling, the Federal Reserve's economic simulations, and Aviva's Solvency II-compliant modeling. The last of these has a [great talk on YouTube](https://www.youtube.com/watch?v=__gMirBBNXY) by Aviva's Tim Thornham, which showcases an on-the-ground view of what difference the right choice of technology and programming language can make. Moving from their vendor-supplied modeling solution was **1000x faster, took 1/10 the amount of code, and was implemented 10x faster**[^2].

It's a language that's not just great for data science — but also not modeling, ETL, visualizations, package control/version management, machine learning, string manipulation, and many other use cases. Julia gets touted for "scientific computing" but that's just one aspect where it has no other choice as obvious.

## For the Actuary

As the [journal Nature said](https://www.nature.com/articles/d41586-019-02310-3), "Come for the Syntax, Stay for the Speed". Here, I'll first cover some of the nice things about the language, and then discuss the runtime (speed).

### Expressiveness and Syntax

**Expressiveness** is the *manner in which* and *scope of* ideas and concepts that can be represented in a programming language. **Syntax** refers to how the code *looks* on the screen and its readability.

In a language with high expressiveness and pleasant syntax, you: Go from idea in your head to end product faster. Encapsulate concepts naturally and dispatch functions on the data you are interested in. Compose functions and data naturally. Focus on the end-goal instead of fighting the tools.

It's hard to explain, but perhaps two short examples will illustrate.

#### Example: Retention Analysis

This is a really simple example relating `Cession`s, `Policy`s, and `Live`s to do simple retention analysis.

First, let's define our data:
```julia:./post/julia-for-the-future/code/ex1

# Define our data structures
struct Life
  policies
end

struct Policy
  face
  cessions
 end
 
struct Cession
  ceded
end

```

Now to calculate amounts retained. First, let's say what retention means for a `Policy`:

```julia:./post/julia-for-the-future/code/ex2
# define retention
function retained(pol::Policy)
  pol.face - sum(cession.ceded for cession in pol.cessions)
end
```

And then what retention means for a `Life`:

```julia:./post/julia-for-the-future/code/ex3
function retained(l::Life)
  sum(retained(policy) for policy in life.policies)
end

```

*See how natural that is?* It's almost exactly how you'd specify it English. No joins, no boilerplate, no fiddling with complicated syntax. You can express ideas and concepts the way that you think of them, not, for example, as a series of dataframe joins or as row/column coordinates on a spreadsheet.

> Expressiveness example: we defined `retained` and adapted it to mean related, but different things depending on the specific context. That is, we didn't have to define `retained_life(...)` and `retained_pol(...)` because Julia can be *dispatch* based on what you give it. This is, as some would call it, [unreasonably effective](https://www.youtube.com/watch?v=kc9HwsxE1OY).

Let's use the above code in practice then. 

*The `julia>` syntax indicates that we've moved into Julia's interactive mode (REPL mode):*

```julia-repl
# create two policies with two and one cesssions respectively
julia> pol_1 = Policy( 1000, [ Cession(100), Cession(500)] )
julia> pol_2 = Policy( 2500, [ Cession(1000) ] )

# create a life, which has the two policies
julia> life = Life([pol_1, pol_2])

```

```julia-repl
julia> retained(pol_1)
400
```

```julia-repl
julia> retained(life)
1900
 ```

And for the last trick, something called "broadcasting", which automatically vectorizes any function you write, no need to write loops or create `if` statements to handle a single vs repeated case:

```julia-repl
julia> retained.(life.policies) # retained amount for each policy
[400 ,  1500]
 ```


#### Example: Random Sampling

As another motivating example showcasing multiple dispatch, here's random number generation in Julia. We generate 100 random uniform, standard normal, and Bernoulli samples — all of which just use the `rand()` function:

```julia
# Julia
using Distributions
rand(100)
rand(Normal(), 100)
rand(Bernoulli(0.5), 100)
```

Contrast that with R, which needs to have a special function for each distribution:

```R
# R
runif(100)
rnorm(100)
rbern(100,0.5)
```

Without Googling, do you know how you'd do the Poisson distribution in Julia? In R? 

Just like with `rand()`, `pdf()`, `cdf()`, etc. will all work the same way and work on all distributions.

### More of Julia's benefits

Julia is easy to write, learn, and be productive in:

- It's free and open-source
  - Very permissive licenses,  facilitating the use in commercial environments (same with most packages)
- Very large and growing set of available packages
- Write how you like because it's multi-paradigm: vectorizable (R), object-oriented (Python), functional (Lisp), or detail-oriented (C)
- Built-in package manager, documentation, and testing-library
- Jupyter Notebook support (it's in the name! **Ju**lia-**Pyt**hon-**R**)
- Many small, nice things that add up:
  - Unicode characters like `α` or `β`
  - nice display of arrays
  - simple anonymous function syntax
  - wide range of text editor support
  - first-class support for `missing` values across the entire language
  - Literate programming support (like R-Markdown)
- Awesome, built-in `Dates` package that makes working with dates a breeze
- Directly call and use R and Python code/packages with the `PyCall` and `RCall` packages
- Error messages are helpful and tell you *what line* the error came from, not just what the error is

 For the power-users, advanced features are easily accessible: parallel programming, broadcasting, types, interfaces, metaprogramming, and more.

These are some of the things that make Julia one of the world's most loved languages on the [StackOverflow Developer Survey](https://insights.stackoverflow.com/survey/2020#technology-most-loved-dreaded-and-wanted-languages).

For those who are enterprise-minded: in addition to the liberal licensing mentioned above, there are professional products from organizations like [Julia Computing](https://juliacomputing.com/) that provide hands-on support, training, IT governance solutions, behind-the-firewall package management, and deployment/scaling assistance.

### The Speed

Julia is also *fast*. Being 1000x faster at something sounds impressive, but what does it mean? It's the difference between something taking *10 seconds* instead of *3 hours* — or *1 hour* instead of *42 days*. **What analysis would you like to do if it took less time? A stochastic analysis of life-level claims? Machine learning with your experience data? Monthly valuation instead of quarterly?**

Speaking from experience, it's not just great for production time improvements. It's really nice to know that I messed something up in a couple of seconds instead of 20 minutes when building something so that I can fix it!

Now, most workflows don't see a 1000x speedup, but 10x to 1000x is a very common range of speed differences vs R or Python or MATLAB.

Sometimes you'll see less of a speed difference because R and Python already have acknowledged the speed issue and written most of what's important in low-level languages. This is an example of what's called the "two-language" problem where the language productive to write in isn't very fast. For example, [more than half of R packages use C/C++/Fortran](https://developer.r-project.org/Blog/public/2019/03/28/use-of-c---in-packages/) and core packages in Python like Pandas, PyTorch, NumPy, SciPy, etc. do this too.

Because Julia packages are written almost exclusively in Julia, the ecosystem of packages works well together without a big overhead organization (e.g. TidyVerse, Numpy, etc). And because the packages you are using are written in Julia, it's easy to see what's going on, learn from them, or even contribute a package of your own!

### The Tradeoff

Julia is fast because it's compiled, unlike R and Python where (loosely speaking) the computer just reads one line at a time. Julia compiles things "just-in-time": right before you use a function for the first time, it will take a moment to pre-process the code section for the machine. Subsequent calls don't need to be re-compiled and are very fast.

An example: if you are doing 100,000 stochastic projections, the first projection might take 1 second to compile, but 1/100th of a second for the other 99,999 runs. In Python, that same calculation might take 1/10th of a second for each computation. The former would take about 15 minutes, the latter 2.75 hours — an example of just a 10x advantage.

Typically the compilation is very fast (milliseconds), but in the most complicated cases it can be several seconds. One of these is the "time-to-first-plot" issue because it's the most common one users encounter: super-flexible plotting libraries have a lot of things to pre-compile. So in the case of plotting, it can take several seconds to display the first plot after starting Julia, but then it's remarkably quick and easy to create an animation of your model results. The time-to-first plot is a solvable problem that's receiving a lot of attention from the core developers and will get better with future Julia releases.

For users working with a lot of data or complex calculations (like actuaries!), the runtime speedup is worth a few seconds at the start.

## Does Choice of Tools Matter?

I argue that the choice of programming language *does* matter. Productivity is one aspect, expressiveness is another, speed one more. There are many reasons to advocate for it, though seeing for yourself is probably the best way to get started.

That said, Julia shouldn't be the only tool in your tool-kit. SQL will remain an important way to interact with databases. R and Python aren't going anywhere in the short term and will always offer a different perspective on things!

In the [first article in this series](http://localhost:8000/blog/coding-for-the-future/), I talked about becoming a **10x Actuary**. In a large way, the choice of tools and paradigms that you focus on facilitate that growth.

It's said that you can't fully conceptualize something unless your language has a word for it. Similar to spoken language, you may find that breaking out of spreadsheet coordinates and dataframes lets you ask different questions and solve problems in innovative ways.

## What next?

This is intended to be the first of a series of articles introducing Julia to actuaries. Future articles planned include:

- An overview of useful general-purpose, data science, and mathematical Julia packages for actuaries
- A deeper dive into some of the packages available from the nascent [JuliaActuary](http://JuliaActuary.org) organization[^3].

In the meantime, some recommended resources to get started:

- [JuliaLang.org](https://julialang.org/), the home site with the downloads to get started and links to learning resources.
- [JuliaHub](https://juliahub.com/ui/Home) indexes open-source Julia packages and makes the entire ecosystem and documentation searchable from one place.
- [JuliaAcademy](https://juliaacademy.com/courses), which has free short courses in Data Science, Introduction to Julia, DataFrames.jl, Machine Learning, and more.
- [Learn Julia in Y minutes](https://learnxinyminutes.com/docs/julia/), a great quick-start if you are already comfortable with coding.
- [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html), a free e-book (or paid print edition) book which introduces programming from the start and teaches you valuable ways of thinking.
- [Design Patterns and Best Practices](https://www.packtpub.com/application-development/hands-design-patterns-julia-10), a book that will help you as you transition from smaller, one-off scripts to designing larger packages and projects.

# Footnotes

[^1]: Python first appeared in 1990. R is an implementation of S, which was created in 1976, though depending on when you want to place the start of an independent R project varies (1993, 1995, and 2000 are alternate dates). The history of these languages is long and substantial changes have occurred since these dates.
[^2]: [Aviva Case Study](https://juliacomputing.com/case-studies/aviva.html)
[^3]: The author of this article contributes to JuliaActuary.
