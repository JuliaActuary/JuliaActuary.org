# Nested Policy Projections

In this notebook, we define a term life policy, implement the mechanics for "outer" projected values, as well as "inner" projections so that we can determine a projection-based reserve. This is done with both a deterministic and stochastic "inner" loop.
tutorials/nested_stochastic/nested_stochastic.png
~~~
 <img src="/tutorials/_assets/nested_stochastic/nested_stochastic.png" />
~~~

The image above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook which shows how to project life insurance policy mechanics with an inner/outer loop (stochastically and deterministically).

## Instructions to Run

Assuming that you already have Julia installed but still need to install Pluto notebooks:

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add(["Pluto"]) 

# use and start Pluto
using Pluto; Pluto.run()                        
```

2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/Nested_Stochastic.jl
```
