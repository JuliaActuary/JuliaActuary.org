# Timing harness. Examples:
#   python bench.py naive --policies 3 --rn 2
#   python bench.py vec --I 38000 --rn 10
# Prints JSON with best-of-reps wall times.

import argparse
import json
import time

import numpy as np

from model import T, load_fund_map, load_inforce, load_mortality, load_scenarios, merge_scenarios, policy_inputs
from naive import va_payout_naive
from vectorized import VectorizedModel


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("impl", choices=["naive", "vec"])
    ap.add_argument("--I", type=int, default=1000)
    ap.add_argument("--policies", type=int, default=3)
    ap.add_argument("--rn", type=int, default=2)
    ap.add_argument("--reps", type=int, default=3)
    args = ap.parse_args()

    inforce = load_inforce()
    qx = load_mortality()
    fund_map = load_fund_map()
    rw = load_scenarios("scenarios_rw.csv")
    rn = load_scenarios("scenarios_rn.csv")
    to_fund = lambda s: np.exp(s @ fund_map)
    rw1 = to_fund(rw[0])
    rns = [to_fund(rn[n]) for n in range(args.rn)]

    if args.impl == "naive":
        merged = [merge_scenarios(rw1, r) for r in rns]
        pols = [policy_inputs(inforce, qx, i) for i in range(args.policies)]
        best = np.inf
        for _ in range(args.reps):
            t0 = time.perf_counter()
            acc = 0.0
            for p in pols:
                for m in merged:
                    acc += va_payout_naive(p, m).sum()
            best = min(best, time.perf_counter() - t0)
        unit = best / (args.policies * args.rn)
        print(json.dumps({"impl": "naive", "policies": args.policies, "rn": args.rn,
                          "total_s": best, "per_policy_per_rn_s": unit, "check": acc}))
    else:
        vm = VectorizedModel(inforce.iloc[0:args.I], qx)
        best = np.inf
        for _ in range(args.reps):
            t0 = time.perf_counter()
            R, Vvec = vm.valuation(rw1, rns)
            best = min(best, time.perf_counter() - t0)
        print(json.dumps({"impl": "vec", "I": args.I, "rn": args.rn, "total_s": best,
                          "per_policy_per_rn_s": best / (args.I * args.rn),
                          "check": float(R.sum())}))


if __name__ == "__main__":
    main()
