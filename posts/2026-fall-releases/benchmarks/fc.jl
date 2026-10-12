# FinanceCore 2.8.0 versus 3.0.0 present-value workflows. Run through run.py.
using FinanceCore, Random
include(joinpath(@__DIR__, "perf_common.jl"))

const rng = MersenneTwister(30)
const amounts = randn(rng, 30) .* 100
const times = cumsum(rand(rng, 30))
const cfs = Cashflow.(amounts, times)
const cf = Cashflow(105.0, 7.5)
const r = Continuous(0.05)
const p2 = Periodic(0.05, 2)
const irr_flows = [-95.0; fill(4.0, 29); 104.0]
# Scalar cases read their inputs through a `Ref`, so the compiler cannot fold the call away.
const r_ref, p2_ref, cf_ref = Ref(r), Ref(p2), Ref(cf)

cases = Pair{String, Function}[
    "pv(0.05, amounts30) (periods 1:n)" => () -> pv(0.05, amounts),
    "pv(0.05, amounts30, times30)" => () -> pv(0.05, amounts, times),
    "pv(Continuous(0.05), amounts30, times30)" => () -> pv(r, amounts, times),
    "pv(Continuous(0.05), Cashflows30)" => () -> pv(r, cfs),
    "pv(Continuous(0.05), Cashflows30, times30)" => () -> pv(r, cfs, times),
    "pv(Continuous(0.05), Cashflow)" => () -> pv(r_ref[], cf_ref[]),
    "discount(Periodic(0.05, 2), 3, 7.5)" => () -> discount(p2_ref[], 3.0, 7.5),
    "accumulation(Continuous(0.05), 3, 7.5)" => () -> accumulation(r_ref[], 3.0, 7.5),
    "convert(Continuous(), Periodic(0.05, 2))" => () -> convert(Continuous(), p2_ref[]),
    "Cashflow + Cashflow (same time)" => () -> cf_ref[] + cf_ref[],
    "irr(31 amounts)" => () -> irr(irr_flows),
]

println("FinanceCore ", pkgversion(FinanceCore), " at ", pathof(FinanceCore))
run_cases(cases)
