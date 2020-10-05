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

Because JuliaActuary doesn't have a beefy server to run this on and let anybody run/visualize thousands of stochastic scenarios, for this one you have to run it locally.

1. Open a Julia REPL and copy and paste the following:

```julia
import Pkg; Pkg.add(["Pluto","Plots","UnPack"]) # install these dependencies
using Pluto; Pluto.run()                        # use and start Pluto
```

2. Navigate to [your local Pluto instance](localhost:1234) (if the link doesn't work, check the REPL for the URL you should go to). 

3. In the Pluto window, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/AAA_ESG.jl
```
