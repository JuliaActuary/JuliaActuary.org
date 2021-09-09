# Universal Life (UL) Policy Mechanics as a Differential Equation

The screenshot below shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook that replicates basic universal life policy mechanics, but hooks into the rich DiffEq/SciML ecosystem that Julia has. With that, one could perform many types of analysis of the behavior of the dynamical system that is a modern life insurance product. This type of approach may be too "heavy" for most workflows, but may be worth investigating.

~~~
 <img src="/tutorials/_assets/DiffEq/DiffEq.PNG" />
~~~



## Instructions to Run

Because JuliaActuary doesn't have a beefy server to run this on and let anybody run/visualize thousands of stochastic scenarios, for this one you have to run it locally. This notebook hooks into a lot of dependency packages so may take a moment to run the first time you open.

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add(["Pluto"]) 

# use and start Pluto
using Pluto; Pluto.run()
```

2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/DiffEq.jl
```
