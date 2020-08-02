# Coding for the Future (with Julia!)
**NOTE: This article is a draft and the website/URLs are a work in progress. Please do not share until published**


> "...the insurance business is perhaps the purest example of an 'information-based' industry - that is, an industry whose sole activity consists of gathering, processing, and distributing information." - Martin Campbell-Kelly, writing about the Prudential in the Victorian Era.[^1]

\toc

## The insurance industry: yesterday, today, and tomorrow

It might be odd to say that technology and its use in insurance is on a one-hundred-year cycle, but that seems to be the case.

130 years ago, actuaries crowded into a room at a meeting of the Actuarial Society of America to watch a demonstration that would revolutionize the industry: Herman Hollerith's tabulating punch card machine[^1]. 

For the next half-century, the increasing automation from tabulating machines to early-adopting mainframes and computers was a critical competitive differentiator. Companies like Prudential, MetLife, and others partnered with technology companies in the development of hardware and software[^2]. The dramatic embodiment of this information-driven cycle was portrayed in the infamous Billion Dollar Bubble movie, which uses the power and abstraction of the computer to commit millions of dollars of fraud by creating and maintaining fake insurance policies.

The movie also starts to hint at the oscillation away from the technological-competitive focus of insurance companies. I argue that the focus on technology was lost over the last 50 years with the rise of Wall Street finance, investment-oriented life insurance, industry consolidation, and explosion of financial structuring like derivatives, reserve financing, or advanced forms of reinsurance. Value-add came from the C-Suite, not from the underlying business processes, operations, and analysis. The result is why ever-more complicated reinsurance treaties are layered into mainframes and admin systems older than most of the actuaries interfacing with them.

The reversion to value-creation through technology has begun and is evident across many traditional sectors. Tesla claims it's a technology company; Amazon is the #1 product retailer because of its internal focus on information sharing between its internal teams[^3]; Airlines are so dependent on their systems that the skies become quieter on the rare occasion that their computers give way. 

Why is it, that company's that are so involved in *things* (cars, shopping) and *physical services* (flights) are so much more focused on improving their technological focus than insurance companies *whose very focus is 'information-based'*? **The market has rewarded those who have prioritized their internal technological solutions.**

Commoditized investing services and low yield environments have reduced insurance companies' comparative advantage to "manage money". Yield compression and the explosion of consumer-oriented investment services means a more competitive focus on the ability to manage the entire policy lifecycle efficiently (digitally), perform more real-time analysis of experience and risk management, and handle the growing product and regulatory complexity. These are problems that have technological solutions and are waiting for insurance company adoption.

Companies that treat data like coordinates on a grid (spreadsheets) *will get left behind*. Two main hurdles that have prevented technology companies from breaking into insurance - high regulatory barriers to entry and figuring out how to sell complex, value-added insurance products without traditional distribution. Once those two walls are breached, traditional insurance companies without a strong technology core will struggle to keep up. It's not just adding "developers" to an organization - it's going to be **getting domain experts like actuaries to be an integral part of the technology transformation.**

### What's coding got to do with this?

Everything. Programming is the optimal way to interact between the computer and actuary -  and importantly between computer and computer. Programming is the actionable expression of ideas, math, analysis, and information. Think of programming as the 21st-century leap in the Actuary's toolkit, just as spreadsheets were in the preceding 40 years. **The actuary of the future needs to have coding as one of their core skills.** Already today, the advances of business processes, insurance products, and financial ingenuity are written with lines of code - *not* spreadsheets. Not being able to code *necessarily* means that you are *following* behind what others are doing today.

### The coding Actuary
Despite the swing back towards needing to focus on technology, we still haven't left the finance-driven complexity behind. The business needs are increasingly complex and for that reason, there will be a large productivity difference between an actuary who can code and one who can't - simply because the former can react, create, synthesize, and model faster than the latter. From the efficiency of transforming administration extracts, summarizing and aggregating valuation output, to analyzing claims data in ways that spreadsheets simply can't handle, you can become a "**10x Actuary**"[^4].

Flipping switches in a graphical user interface versus being able to *build models* is the difference between having a surface-level familiarity and having full command over the analysis and the concepts involved - with the flexibility to do what your software can't. Your current software might be able to perform the first layer of analysis - but be at a loss when you want to visualize, perform sensitivity analysis, statistics, sensitivities, or stochastic analysis - things that, when done programmatically, are often done with just a few lines of additional code.

Do I advocate dropping the license for your software vendor? No, not yet anyway. But the ability to supplement and break out of the modeling box has been an increasingly important part of most actuaries' work.

Additionally, code-based solutions can leverage the entire-technology sector's progress to solve problems that are *hard* otherwise: version control and versioning, model change governance, reproducibility, scalability, data workflows, integration across functional areas, and more.

30-40 years ago, there were no vendor-supplied modeling solutions and so you had no choice but to build models internally. This shifted with the advent of vendor-supplied modeling solutions. Today, it's never been better for companies to leverage open source to support their custom modeling, risk analysis/monitoring, and reporting workflows.

### What about managers/leaders?

The ability to understand the concepts, capabilities, challenges, and lingo is not a dichotomy, it's a spectrum. Most actuaries, even at fairly high levels, are still often involved in analytical work and analysis. Above that, it's difficult to lead something that you don't understand.

## Julia as the Language of Choice for Actuaries

I have suggested that actuaries who are competent coders will differentiate both companies and individuals. Coding ability will be useful no matter what tools you utilize everyday (e.g. Python/R/C++/etc. and associated packages). However, the skilled craftsman is also thoughtful about their choice of tools. I'd like to now motivate why Julia is the best programming language for actuaries to learn.

### Julia Overview

Julia is a relatively new programming language compared to those that probably come to mind, and *it shows*. It's evident in its pragmatic, productivity-focused design choices, pleasant syntax, rich ecosystem, thriving communities, and its ability to both be very general purpose and power cutting edge computing.

Math-heavy computations *look like math*, it's easy to pick up, quick-to-prototype, packages work well together, and has great visualization libraries. There's a growing body of online references and tutorials, videos, and print media to learn from and it's popularity continues to grow across many fields.

Large financial services companies have already started to adopt the language: BlackRock's Aladdin portfolio modeling, the Federal Reserve's economic simulations, and Aviva's Solvency II-compliant modeling. The last of these has a [great talk on YouTube](https://www.youtube.com/watch?v=__gMirBBNXY) by Aviva's Tim Thornham showcasing an on-the-ground view of what difference the right choice of technology and programming language can make. Moving from their vendor-supplied modeling solution was **1000x faster, took 1/10 the amount of code, and was implemented 10x faster**[^5].

It's a language that's not just great for data science - but also not modeling, ETL, visualizations, package control/version management, machine learning, string manipulation, and many other use cases. Julia gets touted for "scientific computing" but that's just one aspect where it has no other choice as obvious.

### For the Actuary

As the [journal Nature said](https://www.nature.com/articles/d41586-019-02310-3), "Come for the Syntax, Stay for the Speed". Here, I'll first cover some of the nice things about the language, and then discuss the runtime (speed).

#### Expressiveness and Syntax

Go from idea in your head to end product faster. Encapsulate concepts naturally and dispatch functions on the data you are interested in. Compose functions and data naturally. It's hard to explain, but perhaps two short examples will illustrate.

##### Example: Retention Analysis

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

Now, some functions to calculate retention for policies and lives:

```julia:./post/julia-for-the-future/code/ex2
# define retention
function retained(pol::Policy)
  pol.face - sum(cession.ceded for cession in pol.cessions)
end

function retained(l::Life)
  sum(retained(policy) for policy in life.policies)
end

```

*See how natural that is?* It's almost exactly how you'd specify it English. No joins, no boilerplate, no fiddling with complicated syntax. You can express ideas and concepts the way that you think of them, not, for example, as a series of dataframe joins. 

> Part of the expressiveness is how we defined `retained` and adapted it to mean related, but different things depending on the specific context. That is, we didn't have to define `retained_life(...)` and `retained_pol(...)` because Julia can be *dispatch* based on what you give it. This is, as some would call it, [unreasonably effective](https://www.youtube.com/watch?v=kc9HwsxE1OY).

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


##### Example: Random Sampling

As another motivating example showcasing multiple dispatch, here's random number generation in Julia. We generate 100 random uniform, standard normal, and Bernoulli samples - all of which just use the `rand()` function:

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

#### More of Julia's benefits

Julia is easy to write, learn, and be productive in:

 - it's free and open-source
   - Very permissive licenses,  facilitating the use in commercial environments (same with most packages)
 - write how you like because it's multi-paradigm: vectorizable (R), object-oriented (Python), functional (Lisp), or detail-oriented (C)
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

Now, most workflows don't see a 1000x speedup, but 10x to 1000x is a very common range of speed differences vs R or Python or MATLAB. Sometimes you'll see less of a speed difference because R and Python already have acknowledged the speed issue and written most of what's important in low-level languages. This is an example of what's called the "two-language" problem where the language productive to write in isn't very fast. For example, [more than half of R packages use C/C++/Fortran](https://developer.r-project.org/Blog/public/2019/03/28/use-of-c---in-packages/) and core packages in Python like Pandas, PyTorch, NumPy, SciPy, etc. do this too.

Because Julia packages are written almost exclusively in Julia, the ecosystem of packages works well together without a big overhead organization (e.g. TidyVerse, Numpy, etc). And because the packages you are using are written in Julia, it's easy to see what's going on, learn from them, or even contribute a package of your own!

#### The Tradeoff

Julia is fast because it's compiled, unlike R and Python which the computer just (loosely speaking) reads one line at a time. Julia compiles things "just-in-time", which means that right before you use a function for the first time, it will take a moment to compile the code for the machine. Subsequent calls don't need to be re-compiled and are very fast.

Typically the compilation is very fast (milliseconds), but in the most complicated cases it can be several seconds. One of these is the "time-to-first-plot" issue because it's the most common one users encounter: super-flexible plotting libraries have a lot of things to pre-compile. So in the case of plotting, it can take several seconds to display the first plot after starting Julia, but then it's remarkably quick and easy to create an animation of your model results. The time-to-first plot is a solvable problem that's receiving a lot of attention from the core developers and will get better with future Julia releases.

For users working with a lot of data or complex calculations (like actuaries!), the runtime speedup is worth a few seconds at the start.

## Does Choice of Programming Language Matter?

I argue that the choice of programming language *does* matter. Productivity is one aspect, expressiveness is another, speed one more. There are many reasons to advocate for it, though seeing for yourself is probably the best way to get started. That said, Julia shouldn't be the only tool in your tool-kit. SQL will remain an important way to interact with databases. R and Python aren't going anywhere in the short term either!

**It will increasingly be essential for companies to modernize to remain competitive. That modernization isn't built with big black-box software packages - it will be with domain experts who can translate the expertise into new forms of analysis, doing it faster and more robustly than the competition.** SpaceX doesn't just hire rocket scientists - they hire rocket scientists who code.

**Be an actuary who codes.**

## What next?

This is intended to be the first of a series of articles introducing Julia to actuaries. Future articles planned include:

- An overview of useful general-purpose, data science, and mathematical Julia packages for actuaries
- A deeper dive into some of the packages available from the nascent [JuliaActuary](http://JuliaActuary.org) organization[^6].

In the meantime, some recommended resources to get started:

- [JuliaLang.org](https://julialang.org/), the home site with the downloads to get started, and links to learning resources.
- [JuliaHub](https://juliahub.com/ui/Home) indexes open-source Julia packages and makes the entire ecosystem and documentation searchable from one place.
- [JuliaAcademy](https://juliaacademy.com/courses), which has free short courses in Data Science, Introduction to Julia, DataFrames.jl, Machine Learning, and more.
- [Learn Julia in Y minutes](https://learnxinyminutes.com/docs/julia/), a great quick-start if you are already comfortable with coding.
- [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html), a free e-book (or paid print edition) book which introduces programming from the start and teaches you valuable ways of thinking.
- [Design Patterns and Best Practices](https://www.packtpub.com/application-development/hands-design-patterns-julia-10), a book that will help you as you transition from smaller, one-off scripts to designing larger packages and projects.


# Footnotes
[^1]: [Co-evolution of Information Processing Technology and Use: Interaction Between the Life Insurance and Tabulating Industries](https://dspace.mit.edu/bitstream/handle/1721.1/2472/swp-3575-28521189.pdf?sequence=1)
[^2]: [From Tabulators to Early Computers in the U.S. Life Insurance Industry](http://ccs.mit.edu/papers/CCSWP153.html)
[^3]: [Have you had your Bezos moment? What you can learn from Amazon](https://www.cio.com/article/3218667/have-you-had-your-bezos-moment-what-you-can-learn-from-amazon.html)
[^4]: [The 10x developer is NOT a myth](https://www.ybrikman.com/writing/2013/09/29/the-10x-developer-is-not-myth/)
[^5]: [Aviva Case Study](https://juliacomputing.com/case-studies/aviva.html)
[^6]: The author of this article contributes to JuliaActuary
