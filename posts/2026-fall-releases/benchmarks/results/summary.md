# Release benchmark results

Speedup = baseline minimum / release minimum. Less than 1 means slower.

| Package | Workload | Baseline (μs) | Release (μs) | Speedup | Allocations (old → new) |
|---|---|---:|---:|---:|---:|
| au | duration(Modified(), 0.04, cfs30, times30) | 0.131 | 0.134 | 0.98× | 0 → 0 |
| au | duration(0.04, cfs30) (periods 1:n) | 0.136 | 0.131 | 1.04× | 2 → 0 |
| au | duration(0.04, Cashflows30) | 0.141 | 0.133 | 1.06× | 2 → 0 |
| au | duration(Macaulay(), Periodic(0.04, 2), cfs30, times30) | 0.071 | 0.071 | 1.00× | 0 → 0 |
| au | convexity(Periodic(0.04, 2), cfs30, times30) | 0.071 | 0.072 | 0.99× | 0 → 0 |
| au | duration(DV01(), 0.04, cfs30, times30) | 0.445 | 0.133 | 3.35× | 8 → 0 |
| au | duration(DV01(), Continuous(0.04), cfs30, times30) | 0.487 | 0.071 | 6.87× | 8 → 0 |
| au | duration(curve, cfs30, times30) | 0.711 | 0.326 | 2.18× | 6 → 0 |
| au | duration(DV01(), curve, cfs30, times30) | 1.050 | 0.327 | 3.21× | 8 → 0 |
| au | convexity(curve, cfs30, times30) | 1.121 | 0.327 | 3.43× | 8 → 0 |
| au | duration(KeyRates, curve, cfs30, times30) | 0.548 | 0.524 | 1.05× | 5 → 4 |
| au | sensitivities(KeyRates, curve, cfs30, times30) | 0.783 | 0.604 | 1.30× | 15 → 10 |
| au | duration(IR01(), curve, credit, cfs30, times30) | 1.558 | 0.489 | 3.19× | 9 → 0 |
| au | convexity(curve, credit, cfs30, times30) | 1.267 | 0.490 | 2.59× | 11 → 0 |
| au | sensitivities(KeyRates, curve, credit, cfs30, times30) | 1.292 | 0.735 | 1.76× | 22 → 10 |
| au | duration(callback, curve) | 0.651 | 0.356 | 1.83× | 5 → 0 |
| au | convexity(callback, curve) | 1.300 | 0.830 | 1.57× | 10 → 0 |
| au | duration(callback, DV01(), curve) | 1.296 | 0.347 | 3.74× | 10 → 0 |
| au | duration(callback, IR01(), curve, credit) | 4.679 | 1.050 | 4.46× | 41 → 0 |
| au | sensitivities(callback, KeyRates, curve) | 5.562 | 4.565 | 1.22× | 47 → 29 |
| au | duration(Effective(), bond, curve) | 17.667 | 0.323 | 54.78× | 91 → 0 |
| au | duration(Effective(), floater, curve) | 38.208 | 0.930 | 41.08× | 119 → 0 |
| au | duration(Spread(), floater, curve) | 38.250 | 0.792 | 48.32× | 119 → 0 |
| au | convexity(Effective(), floater, curve) | 2.403 | 1.950 | 1.23× | 8 → 0 |
| au | sensitivities(KeyRates, bond, curve) | 17.875 | 1.792 | 9.98× | 90 → 28 |
| au | sensitivities(KeyRates, floater, curve, credit) | 38.917 | 3.417 | 11.39× | 118 → 28 |
| au | Hull-White key rates, 100 paths, 10y cashflows | 1098.917 | 1346.208 | 0.82× | 2800 → 1870 |
| au | irr(31 amounts) | 0.493 | 0.493 | 1.00× | 0 → 0 |
| au | wasserstein(1000 Float64, 1000 Float64) | 15.500 | 15.375 | 1.01× | 24 → 24 |
| au | wasserstein(1000 Int, 1000 Int; p = 2) | 2.990 | 3.703 | 0.81× | 8 → 8 |
| fc | pv(0.05, amounts30) (periods 1:n) | 0.069 | 0.069 | 1.00× | 0 → 0 |
| fc | pv(0.05, amounts30, times30) | 0.245 | 0.077 | 3.18× | 4 → 0 |
| fc | pv(Continuous(0.05), amounts30, times30) | 0.243 | 0.077 | 3.16× | 4 → 0 |
| fc | pv(Continuous(0.05), Cashflows30) | 0.070 | 0.070 | 1.00× | 0 → 0 |
| fc | pv(Continuous(0.05), Cashflows30, times30) | 0.245 | 0.075 | 3.26× | 4 → 0 |
| fc | pv(Continuous(0.05), Cashflow) | 0.003 | 0.003 | 1.00× | 0 → 0 |
| fc | discount(Periodic(0.05, 2), 3, 7.5) | 0.003 | 0.003 | 1.00× | 0 → 0 |
| fc | accumulation(Continuous(0.05), 3, 7.5) | 0.003 | 0.003 | 1.00× | 0 → 0 |
| fc | convert(Continuous(), Periodic(0.05, 2)) | 0.002 | 0.002 | 1.00× | 0 → 0 |
| fc | Cashflow + Cashflow (same time) | 0.002 | 0.002 | 1.00× | 0 → 0 |
| fc | irr(31 amounts) | 0.493 | 0.493 | 1.00× | 0 → 0 |
| fm | discount(Linear, 7.3) | 0.009 | 0.010 | 0.94× | 0 → 0 |
| fm | discount(Cubic, 7.3) | 0.012 | 0.012 | 0.99× | 0 → 0 |
| fm | discount(MonotoneConvex, 7.3) | 0.012 | 0.012 | 0.98× | 0 → 0 |
| fm | discount(NelsonSiegel, 7.3) | 0.007 | 0.007 | 0.98× | 0 → 0 |
| fm | zero(Linear, 7.3) | 0.008 | 0.004 | 1.85× | 0 → 0 |
| fm | forward(Linear, 2, 3) | 0.014 | 0.015 | 0.94× | 0 → 0 |
| fm | discount(Vasicek, 10) | 0.007 | 0.009 | 0.75× | 0 → 0 |
| fm | discount(CIR zero volatility, 10) | 0.006 | 0.019 | 0.33× | 0 → 0 |
| fm | discount(CIR, 10) | 0.021 | 0.024 | 0.85× | 0 → 0 |
| fm | discount(HullWhite, 7.3) | 0.009 | 0.010 | 0.94× | 0 → 0 |
| fm | discount(HullWhite, 2, 3, r) | 0.052 | 0.030 | 1.74× | 0 → 0 |
| fm | pv(Linear, 15y semiannual bond) | 0.403 | 0.412 | 0.98× | 0 → 0 |
| fm | pv(MonotoneConvex, 15y bond) | 0.499 | 0.452 | 1.10× | 0 → 0 |
| fm | pv(Linear, 30 amounts, times) | 0.300 | 0.410 | 0.73× | 2 → 0 |
| fm | pv floater on its index | 0.874 | 0.758 | 1.15× | 5 → 0 |
| fm | pv 10y swap on its index | 3.203 | 1.967 | 1.63× | 5 → 0 |
| fm | pv portfolio [bond, floater, swap] | 7.052 | 3.375 | 2.09× | 46 → 14 |
| fm | pv Composite(bond, floater) | 1.850 | 1.192 | 1.55× | 5 → 0 |
| fm | pv Forward(2, floater) | 0.803 | 1.113 | 0.72× | 5 → 0 |
| fm | pv FX.Converted(bond) | 0.354 | 0.364 | 0.97× | 0 → 0 |
| fm | pv FX.Forward | 0.011 | 0.009 | 1.21× | 0 → 0 |
| fm | pv BSM call | 0.018 | 0.018 | 1.00× | 0 → 0 |
| fm | pv Vasicek swaption | 3.062 | 0.848 | 3.61× | 2 → 3 |
| fm | pv HullWhite cap (3y quarterly) | 0.558 | 0.531 | 1.05× | 0 → 0 |
| fm | collect(15y bond) | 0.165 | 0.189 | 0.87× | 5 → 8 |
| fm | fit NelsonSiegel to 6 ZCB yields (LBFGS) | 775.125 | 634.167 | 1.22× | 25429 → 18560 |
| fm | fit BSM implied vol (Fminbox LBFGS) | 24.250 | 23.667 | 1.02× | 771 → 744 |
| fm | fit Linear, 12 CMT quotes (Newton) | 806.125 | 405.125 | 1.99× | 794 → 678 |
| fm | fit MonotoneConvex, 12 CMT quotes | 2801.208 | 1284.167 | 2.18× | 2524 → 1989 |
| fm | refit Linear, unchanged quotes | 800.833 | 405.333 | 1.98× | 794 → 676 |
| fm | refit Linear, 1bp | 641.125 | 406.041 | 1.58× | 690 → 676 |
| fm | bootstrap Linear, 12 CMT quotes | 50.917 | 41.000 | 1.24× | 996 → 1063 |
| fm | pv_mc Vasicek 10y ZCB, 200 scenarios | 139.584 | 142.333 | 0.98× | 1214 → 1614 |
| mt | survival(Gompertz, 40, 60) | 0.165 | 0.012 | 14.10× | 17 → 0 |
| mt | survival(Beard, 40, 50) (numerical cumhazard) | 10.750 | 0.556 | 19.32× | 1295 → 6 |
| mt | life_expectancy(Gompertz, 40) | 72.625 | 5.090 | 14.27× | 7719 → 6 |
| mt | life_expectancy(Makeham, 65) | 27.041 | 1.867 | 14.49× | 2957 → 5 |
| mt | life_expectancy(Weibull, 40) | 33.417 | 2.551 | 13.10× | 3726 → 6 |
| mt | life_expectancy(Kannisto, 80) | 47.000 | 5.479 | 8.58× | 5135 → 6 |
| mt | survival(1980 CSO ult, 40, 60) | 0.003 | 0.003 | 1.00× | 0 → 0 |
| mt | survival(1980 CSO ult, 40.5, 60.25, Uniform) | 0.003 | 0.009 | 0.34× | 0 → 0 |
| mt | life_expectancy(1980 CSO ult, 40) | 0.560 | 0.021 | 26.10× | 0 → 0 |
| mt | decrement(1980 CSO ult, 40, 60) | 0.003 | 0.003 | 1.00× | 0 → 0 |
| mt | load table 1980 CSO (XTbML) | 3.781 | 3.713 | 1.02× | 73 → 72 |
| mt | parse uncached XTbML ultimate | 144.125 | 60.541 | 2.38× | 3252 → 2758 |
| mt | parse uncached XTbML select and ultimate | 26905.583 | 1242.250 | 21.66× | 78720 → 65924 |
