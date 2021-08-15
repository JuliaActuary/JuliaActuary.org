# Interactive Economic Scenario Generator

Scroll down below the sample video to see how to run it.

~~~
<video autoplay loop muted playsinline style=" object-fit: cover; height:50%; width:50%; border:2px solid;"
 >
 <source src="/tutorials/_assets/PlutoESG/PlutoESG.webm" type="video/webm">
 <source src="/tutorials/_assets/PlutoESG/PlutoESG.mp4" type="video/mp4">
 </video>
~~~

The recording above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook manipulating the long term mean reversion parameter for the Nelson-Siegel functional interest rate model, based on the American Academy of Actuaries' (AAA) [Economic Scenario Generator](https://www.actuary.org/content/economic-scenario-generators) (ESG).

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
https://raw.githubusercontent.com/JuliaActuary/Learn/master/AAA_ESG.jl
```
