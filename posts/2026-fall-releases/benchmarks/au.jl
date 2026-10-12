# ActuaryUtilities 5.12.0 versus 6.0.0 workflows. Run through run.py.
# Labels retain baseline names; the calls below explicitly map to the AU 6 APIs.
# README.md explains derivative orders, signs and removed two-curve forms.
using ActuaryUtilities, FinanceCore, FinanceModels, Random
include(joinpath(@__DIR__, "perf_common.jl"))
const NEW = pkgversion(ActuaryUtilities) >= v"6"

const cfs30 = [fill(4.0, 29); 104.0]
const times30 = collect(1.0:30.0)
const cfs10 = [fill(5.0, 9); 105.0]
const times10 = collect(1.0:10.0)
const flows = Cashflow.(cfs30, times30)
const irr_flows = [-95.0; cfs30]
const tenors = [1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 20.0, 30.0]
const curve = ZeroRateCurve([0.02, 0.022, 0.025, 0.028, 0.03, 0.032, 0.035, 0.036], tenors)
const credit = ZeroRateCurve(fill(0.01, length(tenors)), tenors)
const kr = KeyRates(tenors)
const bond = Bond.Fixed(0.04, Periodic(2), 10.0)
const floater = Bond.Floating(0.005, Periodic(2), 10.0, "SOFR")
const hw = ShortRate.HullWhite(0.1, 0.01, curve)
const xs = randn(Xoshiro(1), 1000)
const ys = randn(Xoshiro(2), 1000) .+ 0.1
const ixs = rand(Xoshiro(3), 0:100, 1000)
const iys = rand(Xoshiro(4), 0:100, 1000)
on_curve(c) = pv(c, cfs30, times30)
two_curve(b, c) = pv(b + c, cfs30, times30)

hw_sensitivities() = NEW ?
    sensitivities(SecondOrder(), kr, ActuaryUtilities.Scenarios(hw; horizon = 11.0, n_scenarios = 100, rng = Xoshiro(1)), cfs10, times10) :
    sensitivities(kr, hw, cfs10, times10; n_scenarios = 100, rng = Xoshiro(1))

cases = Pair{String, Function}[
    "duration(Modified(), 0.04, cfs30, times30)" => () -> duration(Modified(), 0.04, cfs30, times30),
    "duration(0.04, cfs30) (periods 1:n)" => () -> duration(0.04, cfs30),
    "duration(0.04, Cashflows30)" => () -> duration(0.04, flows),
    "duration(Macaulay(), Periodic(0.04, 2), cfs30, times30)" => () -> duration(Macaulay(), Periodic(0.04, 2), cfs30, times30),
    "convexity(Periodic(0.04, 2), cfs30, times30)" => () -> convexity(Periodic(0.04, 2), cfs30, times30),
    "duration(DV01(), 0.04, cfs30, times30)" => () -> duration(DV01(), 0.04, cfs30, times30),
    "duration(DV01(), Continuous(0.04), cfs30, times30)" => () -> duration(DV01(), Continuous(0.04), cfs30, times30),
    "duration(curve, cfs30, times30)" => () -> duration(curve, cfs30, times30),
    "duration(DV01(), curve, cfs30, times30)" => () -> duration(DV01(), curve, cfs30, times30),
    "convexity(curve, cfs30, times30)" => () -> convexity(curve, cfs30, times30),
    "duration(KeyRates, curve, cfs30, times30)" => () -> duration(kr, curve, cfs30, times30),
    "sensitivities(KeyRates, curve, cfs30, times30)" => () -> NEW ? sensitivities(SecondOrder(), kr, curve, cfs30, times30) : sensitivities(kr, curve, cfs30, times30),
    "duration(IR01(), curve, credit, cfs30, times30)" => () -> NEW ? duration(DV01(), curve + credit, cfs30, times30) : duration(IR01(), curve, credit, cfs30, times30),
    "convexity(curve, credit, cfs30, times30)" => () -> NEW ? convexity(curve + credit, cfs30, times30) : convexity(curve, credit, tenors, cfs30, times30),
    "sensitivities(KeyRates, curve, credit, cfs30, times30)" => () -> NEW ? sensitivities(SecondOrder(), kr, curve + credit, cfs30, times30) : sensitivities(kr, curve, credit, cfs30, times30),
    "duration(callback, curve)" => () -> duration(on_curve, curve),
    "convexity(callback, curve)" => () -> convexity(on_curve, curve),
    "duration(callback, DV01(), curve)" => () -> NEW ? duration(on_curve, DV01(), curve) : duration(DV01(), curve, on_curve),
    "duration(callback, IR01(), curve, credit)" => () -> NEW ? duration(two_curve, IR01(), curve, credit) : duration(two_curve, IR01(), curve, credit, tenors),
    "sensitivities(callback, KeyRates, curve)" => () -> NEW ? sensitivities(on_curve, SecondOrder(), kr, curve) : sensitivities(on_curve, kr, curve),
    "duration(Effective(), bond, curve)" => () -> NEW ? duration(Effective(), curve, bond) : duration(Effective(), bond, curve, tenors),
    "duration(Effective(), floater, curve)" => () -> NEW ? duration(Effective(), curve, floater) : duration(Effective(), floater, curve, tenors),
    "duration(Spread(), floater, curve)" => () -> NEW ? duration(Spread(), curve, floater) : duration(Spread(), floater, curve, tenors),
    "convexity(Effective(), floater, curve)" => () -> NEW ? convexity(Effective(), curve, floater) : convexity(Effective(), floater, curve, tenors),
    "sensitivities(KeyRates, bond, curve)" => () -> NEW ? sensitivities(kr, curve, bond) : sensitivities(bond, curve, tenors),
    "sensitivities(KeyRates, floater, curve, credit)" => () -> NEW ? sensitivities(kr, credit, floater; index = curve) : sensitivities(floater, curve, credit, tenors),
    "Hull-White key rates, 100 paths, 10y cashflows" => hw_sensitivities,
    "irr(31 amounts)" => () -> irr(irr_flows),
    "wasserstein(1000 Float64, 1000 Float64)" => () -> wasserstein(xs, ys),
    "wasserstein(1000 Int, 1000 Int; p = 2)" => () -> wasserstein(ixs, iys; p = 2),
]

println("ActuaryUtilities at ", pathof(ActuaryUtilities), " | FinanceModels ", pkgversion(FinanceModels), " | FinanceCore ", pkgversion(FinanceCore))
run_cases(cases)
