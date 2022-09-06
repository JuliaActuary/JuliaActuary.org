# Interactive Cashflow Analysis with *ActuaryUtilities.jl*

Scroll down below the sample image to see how to run it.

~~~
 <img src="/tutorials/_assets/CashflowAnalysis/demo.gif" />
~~~

The recording above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook demonstrating some of the basic cashflow-oriented features in `ActuaryUtilities.jl` and `Yields.jl`.

## Instructions to Run

Because JuliaActuary doesn't have an active server to run this on, you have to run it locally. Assuming that you already have Julia installed but still need to install Pluto notebooks:

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add(["Pluto"]) 

# use and start Pluto
using Pluto; Pluto.run()
```


2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/CashflowAnalysis.jl
```
