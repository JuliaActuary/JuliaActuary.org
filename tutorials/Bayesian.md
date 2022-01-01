# Bayesian Claims analysis using Turing.jl

Analyze life claims experience data using Bayesian Markov-Chain-Monte-Carlo (MCMC) techniques.

~~~
 <img src="/tutorials/_assets/Bayesian/bayesian_notebook.png" />
~~~

The image above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook which shows how to calculate posterior parameters for mortality rates.

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
https://raw.githubusercontent.com/JuliaActuary/Learn/master/Bayesian%20Mortality%20Experience.jl
```
