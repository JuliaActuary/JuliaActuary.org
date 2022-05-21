# Stochastic Mortality Projection

Stochastically project 30 million policies per second (benchmarked on a 2020 MacBook Air laptop).

~~~
 <img src="/tutorials/_assets/StochasticMortality/demo.png" />
~~~

The image above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook which shows how to calculate stochastic claims results for a sample payout annuity for demo inforce data.

## Instructions to Run

Because JuliaActuary doesn't have a beefy server to run this on and let anybody run/visualize thousands of stochastic scenarios, for this one you have to run it locally. Assuming that you already have Julia installed but still need to install Pluto notebooks:

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add(["Pluto"]) 

# use and start Pluto
using Pluto; Pluto.run()                        
```

2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/stochastic_claims_demo.jl
```
