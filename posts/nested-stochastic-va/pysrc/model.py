# Shared data loading and assumptions for the SOA nested-stochastic VA model.
# Adapted from https://github.com/rranxxi/soa_nested_stochastic (BSD-3-Clause,
# (c) 2021 rranxxi), reworked to read the prepared CSVs in ../_data and to be
# importable without CUDA. Model semantics follow va_calculator_naive.py.

import os
import numpy as np
import pandas as pd

DATA = os.path.join(os.path.dirname(__file__), "..", "_data")

RISK_FREE = 0.03
VAL_FREQ = 4
PROJ_YEARS = 30
T = VAL_FREQ * PROJ_YEARS + 1  # 121 grid points, t = 0..120


def load_inforce():
    return pd.read_csv(os.path.join(DATA, "inforce.csv"))


def load_fund_map():
    # 5 indices x 10 funds; scenario (T x 5) @ map -> T x 10 fund log-returns
    return pd.read_csv(os.path.join(DATA, "fundmap.csv")).to_numpy()


def load_scenarios(name):
    df = pd.read_csv(os.path.join(DATA, name))
    n = df["scenario"].max()
    out = df[[f"idx{k}" for k in range(1, 6)]].to_numpy().reshape(n, T, 5)
    return out


def load_mortality():
    df = pd.read_csv(os.path.join(DATA, "mortality.csv"))
    qx = {}
    for sex in ("male", "female"):
        v = np.zeros(146)
        v[df["age"].to_numpy()] = df[sex].to_numpy()
        qx[sex] = v
    return qx


def mortality_path(qx_by_age, attained_age, is_male):
    """Quarterly mortality and survivorship vectors, per the SOA repo's
    Mortality.getMortalityRateFromAge: annual qx / 4, repeated 4x, first
    element zeroed, survivorship as the running product of (1 - q)."""
    rate = qx_by_age["male" if is_male else "female"][attained_age:]
    rate2 = rate[0 : PROJ_YEARS + 1] / VAL_FREQ
    rate3 = np.repeat(rate2, VAL_FREQ)[0:T].copy()
    rate3[0] = 0.0
    surv = np.empty_like(rate3)
    surv[0] = 1.0
    for i in range(1, len(rate3)):
        surv[i] = surv[i - 1] * (1.0 - rate3[i])
    return rate3, surv


def accum_discount():
    return np.exp(-RISK_FREE / VAL_FREQ * np.arange(T))


def discount_from(disc, sp):
    """Zero before the switch point sp, exp(-r (t-sp)/4) at and after it."""
    out = np.zeros_like(disc)
    out[sp:] = disc[0 : T - sp]
    return out


def merge_scenarios(rw, rn):
    """All 120 switch-point paths for one (RW, RN) pair: path sp uses RW rows
    [0, sp) and RN rows [sp, T). Row t holds the log-returns applied during
    quarter t. Follows sos_utils.merge_rw_rn_scenario_full."""
    merged = np.empty((T - 1, T, rw.shape[1]))
    for sp in range(1, T):
        merged[sp - 1, :sp] = rw[:sp]
        merged[sp - 1, sp:] = rn[sp:]
    return merged


def policy_inputs(inforce, qx_by_age, i):
    """Bundle one policy's model inputs, mirroring VAPayoutCalculation's setup."""
    row = inforce.iloc[i]
    funds = row[[f"FundValue{j}" for j in range(1, 11)]].to_numpy(dtype=float)
    fees = row[[f"FundFee{j}" for j in range(1, 11)]].to_numpy(dtype=float)
    q, surv = mortality_path(qx_by_age, int(row["AttainedAge"]), row["gender"] == "M")
    tp = min(int(np.ceil(row["ProjectionMonths"] / (12 / VAL_FREQ))), T - 1)
    return dict(
        funds=funds,
        fees=fees,
        gb_amt=float(row["gbAmt"]),
        gmwb_balance=float(row["gmwbBalance"]),
        wd_rate=float(row["wbWithdrawalRate"]) / VAL_FREQ,
        withdrawal=float(row["withdrawal"]),
        q=q,
        surv=surv,
        tp=tp,
    )
