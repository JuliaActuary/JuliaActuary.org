# The paper's third rung on modern hardware: the completed vectorized RISP
# implementation running on CuPy. Parameterized over the array module so the
# identical class validates on NumPy first:
#
#   python bench_cupy.py numpy --I 500   --rn 3     # correctness reference
#   python bench_cupy.py cupy  --I 500   --rn 3     # must match numpy
#   python bench_cupy.py cupy  --I 38000 --rn 10
#   python bench_cupy.py cupy  --I 190000 --rn 10 --inforce inforce190k.csv
#
# Self-contained port of ../pysrc/vectorized.py + the loaders it needs
# (BSD-3 heritage: github.com/rranxxi/soa_nested_stochastic).

import argparse
import json
import os
import time

import numpy as np
import pandas as pd

DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
RISK_FREE = 0.03
VAL_FREQ = 4
T = 121


def load_mortality():
    df = pd.read_csv(os.path.join(DATA, "mortality.csv"))
    qx = {}
    for sex in ("male", "female"):
        v = np.zeros(146)
        v[df["age"].to_numpy()] = df[sex].to_numpy()
        qx[sex] = v
    return qx


def mortality_path(qx_by_age, attained_age, is_male):
    rate = qx_by_age["male" if is_male else "female"][attained_age:]
    rate3 = np.repeat(rate[0:31] / VAL_FREQ, VAL_FREQ)[0:T].copy()
    rate3[0] = 0.0
    surv = np.empty_like(rate3)
    surv[0] = 1.0
    for i in range(1, len(rate3)):
        surv[i] = surv[i - 1] * (1.0 - rate3[i])
    return rate3, surv


def load_scenarios(name):
    df = pd.read_csv(os.path.join(DATA, name))
    n = df["scenario"].max()
    return df[[f"idx{k}" for k in range(1, 6)]].to_numpy().reshape(n, T, 5)


class VectorizedModelXP:
    """vectorized.py with the array module (numpy or cupy) injected."""

    def __init__(self, xp, inforce, qx_by_age, dtype):
        self.xp = xp
        self.dtype = dtype
        I = len(inforce)
        self.I = I
        A = lambda a: xp.asarray(a, dtype=dtype)
        self.funds0 = A(inforce[[f"FundValue{j}" for j in range(1, 11)]].to_numpy())
        self.fees = A(inforce.iloc[0][[f"FundFee{j}" for j in range(1, 11)]].to_numpy(dtype=float))
        self.gb_amt = A(inforce["gbAmt"].to_numpy())
        self.gmwb_balance0 = A(inforce["gmwbBalance"].to_numpy())
        self.wd_rate = A(inforce["wbWithdrawalRate"].to_numpy() / VAL_FREQ)
        self.withdrawal0 = A(inforce["withdrawal"].to_numpy())
        self.wd_phase = xp.asarray(inforce["withdrawal"].to_numpy() > 0)
        self.use_gb = xp.asarray(inforce["wbWithdrawalRate"].to_numpy() > 0.0)

        tp = np.minimum(np.ceil(inforce["ProjectionMonths"].to_numpy() / 3.0), T - 1).astype(int)
        tgrid = np.arange(T)[:, None]
        self.valid = A((tgrid <= tp[None, :]).astype(float))
        self.attained = A((tgrid == tp[None, :]).astype(float))

        q = np.zeros((T, I))
        surv = np.zeros((T, I))
        for i in range(I):
            qi, si = mortality_path(qx_by_age, int(inforce["AttainedAge"].iloc[i]),
                                    inforce["gender"].iloc[i] == "M")
            q[:, i] = qi
            surv[:, i] = si
        self.q, self.surv = A(q), A(surv)

        Z = lambda *shape: xp.zeros(shape, dtype=dtype)
        self.fund = Z(T, I, 10)
        self.weights = Z(T, I, 10)
        self.av = Z(T, I)
        self.wav = Z(T, I)
        self.B = Z(T, I)
        self.W = Z(T, I)
        self.GB = Z(T, I)

    def init_t0(self):
        xp = self.xp
        self.fund[0] = self.funds0
        av0 = self.funds0.sum(axis=1)
        self.av[0] = av0
        with np.errstate(divide="ignore", invalid="ignore"):
            self.weights[0] = xp.where(av0[:, None] > 0, self.funds0 / av0[:, None], 0.0)
        self.B[0] = self.gb_amt
        self.W[0] = self.withdrawal0
        self.GB[0] = self.gmwb_balance0
        self.wav[0] = 0.0

    def step(self, t, ret_row):
        xp = self.xp
        g = self.fund[t - 1] * ret_row
        fw = self.weights[t - 1] * self.wav[t - 1][:, None]
        f = xp.maximum(0.0, g * (1.0 - self.fees) - fw)
        self.fund[t] = f
        av_t = f.sum(axis=1)
        self.av[t] = av_t
        with np.errstate(divide="ignore", invalid="ignore"):
            self.weights[t] = xp.where(av_t[:, None] > 0, f / av_t[:, None], 0.0)
        self.B[t] = xp.where(self.wd_phase, self.B[t - 1] - self.W[t - 1],
                             xp.maximum(av_t, self.B[t - 1]))
        self.W[t] = self.B[t] * self.wd_rate
        self.GB[t] = xp.maximum(0.0, self.GB[t - 1] - self.W[t - 1])
        wpay = xp.maximum(0.0, self.W[t] - av_t) * self.surv[t]
        self.wav[t] = xp.minimum(av_t, self.W[t])
        mbdb = xp.where(self.use_gb, self.GB[t], self.B[t])
        gmdb = xp.maximum(0.0, mbdb - av_t) * self.q[t] * self.surv[t]
        gmmb = (mbdb - av_t) * self.surv[t] * self.attained[t]
        return ((wpay + gmdb) * self.valid[t] + gmmb).sum()

    def valuation(self, rw_returns, rn_returns):
        xp = self.xp
        N = rn_returns.shape[0]
        disc = np.exp(-RISK_FREE / VAL_FREQ * np.arange(T))
        R = np.zeros((N, T - 1))
        self.init_t0()
        for t in range(1, T):
            self.step(t, rw_returns[t])
        for sp in range(T - 1, 0, -1):
            for n in range(N):
                rn = rn_returns[n]
                for t in range(sp, T):
                    R[n, sp - 1] += float(self.step(t, rn[t])) * disc[t - sp]
        return R


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("xp", choices=["numpy", "cupy"])
    ap.add_argument("--I", type=int, default=2000)
    ap.add_argument("--rn", type=int, default=10)
    ap.add_argument("--inforce", default="inforce.csv")
    ap.add_argument("--dtype", default="float64", choices=["float64", "float32"])
    ap.add_argument("--reps", type=int, default=2)
    args = ap.parse_args()

    xp = np if args.xp == "numpy" else __import__("cupy")
    sync = (lambda: None) if args.xp == "numpy" else xp.cuda.Stream.null.synchronize

    inforce = pd.read_csv(os.path.join(DATA, args.inforce)).iloc[0:args.I]
    qx = load_mortality()
    fmap = pd.read_csv(os.path.join(DATA, "fundmap.csv")).to_numpy()
    to_fund = lambda s: np.exp(s @ fmap)
    rw1 = xp.asarray(to_fund(load_scenarios("scenarios_rw.csv")[0]), dtype=args.dtype)
    rns = xp.asarray(np.stack([to_fund(s) for s in load_scenarios("scenarios_rn.csv")[0:args.rn]]),
                     dtype=args.dtype)

    vm = VectorizedModelXP(xp, inforce, qx, args.dtype)
    best = float("inf")
    for _ in range(args.reps):
        sync()
        t0 = time.perf_counter()
        R = vm.valuation(rw1, rns)
        sync()
        best = min(best, time.perf_counter() - t0)
    print(json.dumps({"xp": args.xp, "dtype": args.dtype, "I": args.I, "rn": args.rn,
                      "inforce": args.inforce, "total_s": best,
                      "us_per_policy_scenario": best / args.I / args.rn * 1e6,
                      "R_sum": float(R.sum()), "R_sp1": float(R[:, 0].sum())}))


if __name__ == "__main__":
    main()
