# Fitting Yield Curves to rates

Given rates and maturities, we can fit the yield curves with different techniques in [Yields.jl](https://juliaactuary.org/packages/#yieldsjl).

Below, we specify that the rates should be interpreted as `Continuous`ly compounded zero rates:

```julia
using Yields

rates = Continuous.([0.01, 0.01, 0.03, 0.05, 0.07, 0.16, 0.35, 0.92, 1.40, 1.74, 2.31, 2.41] ./ 100)
mats = [1/12, 2/12, 3/12, 6/12, 1, 2, 3, 5, 7, 10, 20, 30]
```

Then fit the rates under four methods:

- Nelson-Siegel
- Nelson-Siegel-Svennson
- Boostrapping with splines (the default `Bootstrap` option)
- Bootstrapping with linear splines

```
ns = Yields.Zero(NelsonSiegel(),rates,mats);
nss = Yields.Zero(NelsonSiegelSvensson(),rates,mats);
b = Yields.Zero(Bootstrap(),rates,mats);
bl = Yields.Zero(Bootstrap(Yields.LinearSpline()),rates,mats);
```

That's it! We've fit the rates using four different techniques. These can now be used in a variety of ways, such as calculating the `present_value`, `duration`, or `convexity` of different cashflows if you imported [ActuaryUtilities.jl](https://github.com/JuliaActuary/ActuaryUtilities.jl)

A visualization of the different curves:


~~~
 <img src="/tutorials/_assets/yield-curve-fitting/anim_fps2.gif" />
~~~

## Associated Pluto Notebook

This example, complete with the code to plot/animate the curves is in the notebook below. To use Pluto to run the notebook:

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add("Pluto") 

# use and start Pluto
using Pluto; Pluto.run()
```


2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/Yield_Curve_fitting.jl
```
