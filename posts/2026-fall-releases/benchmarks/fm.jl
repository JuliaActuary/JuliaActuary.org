# FinanceModels 6.5.0 versus 7.0.0. Run through run.py.
# The script adapts where the valuation API changed (Projection(c; index) before, Models after).
# Inputs are `const`; scalar-only inputs are read through Ref to prevent constant folding.
using FinanceModels, FinanceCore, Random
include(joinpath(@__DIR__, "perf_common.jl"))
const NEW = isdefined(FinanceModels, :Models)

value_with_index(d, index, c) = NEW ? present_value(FinanceModels.Models(d; index), c) : present_value(d, Projection(c; index))

const tenors = [0.5, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 12.0, 15.0, 20.0, 25.0, 30.0]
const rates = 0.03 .+ 0.01 .* (1 .- exp.(-tenors ./ 5))
const lin = ZeroRateCurve(rates, tenors, Spline.Linear())
const cub = ZeroRateCurve(rates, tenors, Spline.Cubic())
const mc = ZeroRateCurve(rates, tenors, Spline.MonotoneConvex())
const ns = Yield.NelsonSiegel(1.5, 0.04, -0.01, 0.005)
const bond = Bond.Fixed(0.04, Periodic(2), 15.0)
const floater = Bond.Floating(0.004, Periodic(4), 5.0, :index)
# FinanceModels 6.5 swaps are quarterly and take no frequency; 7 requires one, so both use 4
const swap = NEW ? InterestRateSwap(lin, 10.0; frequency = 4, model_key = :index) :
    InterestRateSwap(lin, 10.0; model_key = :index)
const book = [bond, floater, swap]
const comp = FinanceCore.Composite(bond, floater)
const fwd = Forward(2.0, floater)
const amounts30 = fill(4.0, 30)
const times30 = 0.5:0.5:15.0
const qs = CMTYield.(rates, tenors)
const zq = ZCBYield.(rates[1:6], tenors[1:6])
const fitted_lin = fit(Spline.Linear(), qs)
# 6.5 cannot refit an existing spline: repeat its supported fresh fit.
# 7.0 reuses the previously fitted curve as its starting point.
const refit_curve = NEW ? fitted_lin : Spline.Linear()
const bumped = CMTYield.(rates .+ 0.0001, tenors)
const bsm0 = Equity.BlackScholesMerton(0.01, 0.02, Volatility.Constant())
const bsm = Equity.BlackScholesMerton(0.01, 0.02, 0.15)
const call = Option.EuroCall(CommonEquity(), 1.05, 1.0)
const bq = [Quote(pv(bsm, call), call)]
const vas = ShortRate.Vasicek(0.1, 0.03, 0.01, 0.04)
const hw = ShortRate.HullWhite(0.1, 0.01, lin)
const cir0_ref = Ref(ShortRate.CoxIngersollRoss(0.1, 0.03, 0.0, 0.04))
const cir = ShortRate.CoxIngersollRoss(0.1, 0.03, 0.05, 0.04)
const swaption = Option.Swaption(1.0, 2.0, 0.011, 4)
const cap = Option.Cap(0.03, 4, 3.0)
const eurusd = FX.Pair(:EUR, :USD)
const fx = FX.Forwards(eurusd, 1.1, Yield.Constant(Continuous(0.05)), Yield.Constant(Continuous(0.03)))
const fxfwd = FX.Forward(eurusd, 1.2, 2.0)
const conv_bond = FX.Converted(bond, eurusd, :fx)
const fxstore = Dict(:fx => fx)
const zcb10 = Cashflow(1.0, 10.0)
# Scalar cases read their inputs through a `Ref`, so the compiler cannot fold the call away.
const ns_ref, vas_ref, cir_ref, fx_ref, fxfwd_ref, bsm_ref, call_ref = Ref(ns), Ref(vas), Ref(cir), Ref(fx), Ref(fxfwd), Ref(bsm), Ref(call)

cases = Pair{String, Function}[
    "discount(Linear, 7.3)" => () -> discount(lin, 7.3),
    "discount(Cubic, 7.3)" => () -> discount(cub, 7.3),
    "discount(MonotoneConvex, 7.3)" => () -> discount(mc, 7.3),
    "discount(NelsonSiegel, 7.3)" => () -> discount(ns_ref[], 7.3),
    "zero(Linear, 7.3)" => () -> zero(lin, 7.3),
    "forward(Linear, 2, 3)" => () -> forward(lin, 2.0, 3.0),
    "discount(Vasicek, 10)" => () -> discount(vas_ref[], 10.0),
    "discount(CIR zero volatility, 10)" => () -> discount(cir0_ref[], 10.0),
    "discount(CIR, 10)" => () -> discount(cir_ref[], 10.0),
    "discount(HullWhite, 7.3)" => () -> discount(hw, 7.3),
    "discount(HullWhite, 2, 3, r)" => () -> discount(hw, 2.0, 3.0, 0.03),
    "pv(Linear, 15y semiannual bond)" => () -> pv(lin, bond),
    "pv(MonotoneConvex, 15y bond)" => () -> pv(mc, bond),
    "pv(Linear, 30 amounts, times)" => () -> pv(lin, amounts30, times30),
    "pv floater on its index" => () -> value_with_index(lin, lin, floater),
    "pv 10y swap on its index" => () -> value_with_index(lin, lin, swap),
    "pv portfolio [bond, floater, swap]" => () -> value_with_index(lin, lin, book),
    "pv Composite(bond, floater)" => () -> value_with_index(lin, lin, comp),
    "pv Forward(2, floater)" => () -> value_with_index(lin, lin, fwd),
    "pv FX.Converted(bond)" => () -> NEW ? present_value(FinanceModels.Models(fx.domestic, fxstore), conv_bond) : present_value(fx.domestic, Projection(conv_bond, fxstore, CashflowProjection())),
    "pv FX.Forward" => () -> pv(fx_ref[], fxfwd_ref[]),
    "pv BSM call" => () -> pv(bsm_ref[], call_ref[]),
    "pv Vasicek swaption" => () -> pv(vas, swaption),
    "pv HullWhite cap (3y quarterly)" => () -> pv(hw, cap),
    "collect(15y bond)" => () -> collect(bond),
    "fit NelsonSiegel to 6 ZCB yields (LBFGS)" => () -> fit(Yield.NelsonSiegel(), zq),
    "fit BSM implied vol (Fminbox LBFGS)" => () -> fit(bsm0, bq),
    "fit Linear, 12 CMT quotes (Newton)" => () -> fit(Spline.Linear(), qs),
    "fit MonotoneConvex, 12 CMT quotes" => () -> fit(Spline.MonotoneConvex(), qs),
    "refit Linear, unchanged quotes" => () -> fit(refit_curve, qs),
    "refit Linear, 1bp" => () -> fit(refit_curve, bumped),
    "bootstrap Linear, 12 CMT quotes" => () -> fit(Spline.Linear(), qs, Fit.Bootstrap()),
    "pv_mc Vasicek 10y ZCB, 200 scenarios" => () -> pv_mc(vas, zcb10; n_scenarios = 200, rng = Xoshiro(1)),
]

println("FinanceModels ", pkgversion(FinanceModels), " at ", pathof(FinanceModels), " | FinanceCore ", pkgversion(FinanceCore))
run_cases(cases)
