# Policy Account Mechanics as a Differential Equation

This notebook (which might take a while to run the first time as it precompiles the DiffEq and Plots set of packages) demonstrates an example of defining a policy value roll like a discrete differential equation.

It then uses the [SciML DifferentialEquations](https://sciml.ai/) package to "solve" the policy projection given a single point, but also to see how the policy projection behaves under different premium and interest rate conditions.

```julia
using Dates, MortalityTables, DifferentialEquations,Plots, ColorSchemes, ActuaryUtilities
```