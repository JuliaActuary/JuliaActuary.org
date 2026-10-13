"""Recompute the article's QuantLib results and workflow benchmarks.

Run with the Python environment described in index.qmd. Output is TOML so the
Julia render can read and compare the independently generated reference values.
"""

import argparse
import datetime
import json
import math
import platform
import subprocess
import timeit
from pathlib import Path

import QuantLib as ql


def hardware():
    if platform.system() == "Darwin":
        return subprocess.check_output(
            ["sysctl", "-n", "machdep.cpu.brand_string"], text=True
        ).strip()
    return platform.processor() or platform.machine()


settle = ql.Date(1, 1, 2026)
ql.Settings.instance().evaluationDate = settle
day_count = ql.Thirty360(ql.Thirty360.BondBasis)
def make_bond(maturity_years):
    schedule = ql.Schedule(
        settle, settle + ql.Period(maturity_years, ql.Years), ql.Period(ql.Semiannual),
        ql.NullCalendar(), ql.Unadjusted, ql.Unadjusted,
        ql.DateGeneration.Backward, False,
    )
    return ql.FixedRateBond(0, 100.0, schedule, [0.04], day_count)


def zero_curve(years, zeros):
    dates = [settle + ql.Period(y, ql.Years) for y in years]
    return zero_curve_at_dates(dates, zeros)


def zero_curve_at_dates(dates, zeros):
    return ql.ZeroCurve(
        dates, zeros, day_count, ql.NullCalendar(), ql.Linear(), ql.Continuous
    )


def engine(curve):
    return ql.DiscountingBondEngine(ql.YieldTermStructureHandle(curve))


def make_krd_zerocurve(bond, years, zeros, shift=1e-5):
    """Central differences with the same flat-left hats as AU's KeyRates."""
    dates = [settle + ql.Period(y, ql.Years) for y in years]
    base_engine = engine(zero_curve_at_dates(dates, zeros))
    bond.setPricingEngine(base_engine)
    base_price = bond.NPV()

    def krd_zerocurve():
        out = []
        for i in range(1, len(years)):
            up, dn = zeros[:], zeros[:]
            up[i] += shift
            dn[i] -= shift
            if i == 1:
                # Moving the anchor too extends the first hat flat to time zero.
                up[0] += shift
                dn[0] -= shift
            bond.setPricingEngine(engine(zero_curve_at_dates(dates, up)))
            p_up = bond.NPV()
            bond.setPricingEngine(engine(zero_curve_at_dates(dates, dn)))
            p_dn = bond.NPV()
            out.append((p_dn - p_up) / (2 * shift * base_price))
        bond.setPricingEngine(base_engine)
        return out

    return krd_zerocurve


def make_krd_spread(bond, base_curve, pillars, shift=1e-5):
    """Reuse one curve and engine; change observable zero-spread quotes."""
    quotes = [ql.SimpleQuote(0.0) for _ in pillars]
    dates = [settle + ql.Period(y, ql.Years) for y in pillars]
    spread_curve = ql.PiecewiseZeroSpreadedTermStructure(
        ql.YieldTermStructureHandle(base_curve),
        [ql.QuoteHandle(q) for q in quotes], dates,
        ql.Continuous, ql.NoFrequency,
    )
    # This structure has linear interior spreads and flat endpoint spreads.
    bond.setPricingEngine(engine(spread_curve))
    base_price = bond.NPV()

    def krd_spread():
        out = []
        for quote in quotes:
            try:
                quote.setValue(shift)
                p_up = bond.NPV()
                quote.setValue(-shift)
                p_dn = bond.NPV()
                out.append((p_dn - p_up) / (2 * shift * base_price))
            finally:
                quote.setValue(0.0)
        return out

    return krd_spread


def assert_vectors_close(a, b):
    assert len(a) == len(b)
    assert all(math.isclose(x, y, rel_tol=1e-8, abs_tol=1e-8) for x, y in zip(a, b))


def benchmark_ns(fn):
    fn()  # Warm caches before either calibration or measurement.
    timer = timeit.Timer(fn)
    loops, _ = timer.autorange()
    return min(timer.repeat(repeat=7, number=loops)) / loops * 1e9


def main(output):
    bond = make_bond(5)
    term = zero_curve(
        [0, 1, 2, 3, 4, 5, 7],
        [0.025, 0.025, 0.027, 0.029, 0.030, 0.032, 0.034],
    )
    bond.setPricingEngine(engine(term))
    price = bond.NPV()
    ytm = bond.bondYield(day_count, ql.Continuous, ql.NoFrequency)
    ytm_ir = ql.InterestRate(ytm, day_count, ql.Continuous, ql.NoFrequency)
    ytm_duration = ql.BondFunctions.duration(bond, ytm_ir, ql.Duration.Modified)
    term_krd = make_krd_zerocurve(
        bond, list(range(11)),
        [0.025, 0.025, 0.027, 0.029, 0.030, 0.032, 0.033, 0.034, 0.034, 0.034, 0.034],
    )()
    term_krd_reuse = make_krd_spread(make_bond(5), term, list(range(1, 11)))()
    assert_vectors_close(term_krd, term_krd_reuse)
    flat = ql.FlatForward(settle, 0.03, day_count, ql.Continuous)
    flat_engine = engine(flat)
    bond.setPricingEngine(flat_engine)
    ir = ql.InterestRate(0.03, day_count, ql.Continuous, ql.NoFrequency)
    periodic_ir = ql.InterestRate(math.expm1(0.03), day_count, ql.Compounded, ql.Annual)
    values = {
        "term_price": price,
        "ytm": ytm,
        "ytm_duration": ytm_duration,
        "term_krd": term_krd,
        "term_krd_reuse": term_krd_reuse,
        "flat_price": bond.NPV(),
        "flat_duration": ql.BondFunctions.duration(bond, ir, ql.Duration.Modified),
        "flat_convexity": ql.BondFunctions.convexity(bond, ir),
        "periodic_convexity": ql.BondFunctions.convexity(bond, periodic_ir),
    }
    assert math.isclose(values["term_price"], 103.678179221670, abs_tol=1e-9)
    assert math.isclose(values["flat_convexity"], 22.228284058748, abs_tol=1e-10)
    assert math.isclose(sum(term_krd), 4.587323550496, abs_tol=1e-8)

    # Each benchmark owns its bond, so updating one engine cannot affect another.
    krd_jobs = {}
    for maturity in (5, 30):
        suffix = f"{maturity}y"
        rebuild = make_krd_zerocurve(make_bond(maturity), list(range(31)), [0.03] * 31)
        reuse = make_krd_spread(make_bond(maturity), flat, list(range(1, 31)))
        krd_jobs[f"krd_{suffix}_rebuild"] = rebuild
        krd_jobs[f"krd_{suffix}_reuse"] = reuse
        values[f"krd_{suffix}_rebuild"] = rebuild()
        values[f"krd_{suffix}_reuse"] = reuse()
        assert_vectors_close(values[f"krd_{suffix}_rebuild"], values[f"krd_{suffix}_reuse"])
        # A second call checks that the previous invocation restored all quotes.
        assert_vectors_close(values[f"krd_{suffix}_reuse"], reuse())
        check_bond = make_bond(maturity)
        check_bond.setPricingEngine(engine(flat))
        values[f"flat_price_{suffix}"] = check_bond.NPV()
        values[f"flat_duration_{suffix}"] = ql.BondFunctions.duration(check_bond, ir, ql.Duration.Modified)
        assert math.isclose(sum(values[f"krd_{suffix}_reuse"]), values[f"flat_duration_{suffix}"], rel_tol=2e-8)

    def reprice():
        bond.recalculate()
        return bond.NPV()

    timings = {
        "price_cached": benchmark_ns(bond.NPV),
        "price_recomputed": benchmark_ns(reprice),
        "duration": benchmark_ns(lambda: ql.BondFunctions.duration(bond, ir, ql.Duration.Modified)),
        "convexity": benchmark_ns(lambda: ql.BondFunctions.convexity(bond, ir)),
    }
    timings.update({name: benchmark_ns(fn) for name, fn in krd_jobs.items()})
    metadata = {
        "date": datetime.date.today().isoformat(),
        "python": platform.python_version(),
        "quantlib": ql.__version__,
        "hardware": hardware(),
        "os": platform.platform(),
        "method": "Minimum of seven timeit repeats; autorange chooses at least 0.2 s per repeat; warmed calls; ns/call.",
        "krd_shift": 1e-5,
        "krd_setup": "Dates, quote handles, base prices and initial engines are prepared before timing; 30 annual continuous-zero spread pillars, flat endpoint spreads; 5y and 30y semiannual bonds.",
    }
    # These values have a deliberately small TOML vocabulary: strings, numbers,
    # and number arrays, whose JSON spellings are also valid TOML values.
    sections = {"metadata": metadata, "values": values, "nanoseconds": timings}
    text = "\n".join(
        f"[{section}]\n" + "\n".join(f"{k} = {json.dumps(v)}" for k, v in data.items()) + "\n"
        for section, data in sections.items()
    )
    output.write_text(text)
    print(text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path(__file__).with_name("quantlib-results.toml"))
    main(parser.parse_args().output)
