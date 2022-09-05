# Fitting survival data with *MortalityTables.jl*

~~~
 <img src="/tutorials/_assets/SurvivalFitting/FittingSurvivalData.png" />
~~~

The screenshot above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook demonstrating how to use parametric mortality/survival models in MortalityTables.jl to fit observed data.

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
https://raw.githubusercontent.com/JuliaActuary/Learn/master/FittingSurivalData.jl
```
