# Dump reference results for cross-language validation.
#   naive_pv.csv : sparse nonzero entries of the naive per-policy PV matrices
#                  for 19 representative policies x 3 inner scenarios
#   vec_R.csv    : vectorized model's per-switch-point inner PVs, 500 policies x 3 inner
# Julia implementations are compared against both.

import numpy as np
import pandas as pd

from model import load_fund_map, load_inforce, load_mortality, load_scenarios, merge_scenarios, policy_inputs
from naive import va_payout_naive
from vectorized import VectorizedModel

inforce = load_inforce()
qx = load_mortality()
fund_map = load_fund_map()
rw = load_scenarios("scenarios_rw.csv")
rn = load_scenarios("scenarios_rn.csv")

to_fund_returns = lambda scen: np.exp(scen @ fund_map)  # (T,5) log-idx -> (T,10) fund ratios

POLICIES = list(range(0, 38000, 2000))  # first policy of each product-type block
N_RN = 3

rw1 = to_fund_returns(rw[0])
rows = []
for pid in POLICIES:
    p = policy_inputs(inforce, qx, pid)
    for n in range(N_RN):
        merged = merge_scenarios(rw1, to_fund_returns(rn[n]))
        pv = va_payout_naive(p, merged)
        sp_idx, t_idx = np.nonzero(pv)
        for s, t in zip(sp_idx, t_idx):
            rows.append((pid + 1, n + 1, s + 1, t, pv[s, t]))
pd.DataFrame(rows, columns=["policy", "rn", "sp", "t", "pv"]).to_csv("../_data/naive_pv.csv", index=False)
print(f"naive_pv.csv: {len(rows)} nonzero entries")

vm = VectorizedModel(inforce.iloc[0:500], qx)
R, Vvec = vm.valuation(rw1, [to_fund_returns(rn[n]) for n in range(N_RN)])
out = pd.DataFrame({"rn": np.repeat(np.arange(1, N_RN + 1), R.shape[1]),
                    "sp": np.tile(np.arange(1, R.shape[1] + 1), N_RN),
                    "R": R.ravel()})
out.to_csv("../_data/vec_R.csv", index=False)
print("vec_R.csv written; total R:", R.sum())
