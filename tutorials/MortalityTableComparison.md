# Interactive Mortality Comparison Tool

Scroll down below the sample video to see how to run it.

~~~
 <img src="/tutorials/_assets/MortalityTableComparison/demo.gif" />
~~~

The recording above shows a [Pluto.jl](https://github.com/fonsp/Pluto.jl) notebook visualizing the difference between different mortality tables.

## Instructions to Run

Because JuliaActuary doesn't have an active server to run this on, you have to run it locally.

1. Open a Julia REPL and copy and paste the following:

```julia
# install these dependencies
import Pkg; Pkg.add("Pluto") 

# use and start Pluto
using Pluto; Pluto.run()
```


2. In the Pluto window that opens, enter this URL into the `Open from file:` box:

```
https://raw.githubusercontent.com/JuliaActuary/Learn/master/MortalityTableComparison.jl
```
