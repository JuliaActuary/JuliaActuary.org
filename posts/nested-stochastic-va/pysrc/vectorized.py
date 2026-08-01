# Vectorized ("broadcasting") NumPy implementation of the nested stochastic
# valuation, following the reverse-inner-switch-point (RISP) structure of
# va_calculator_risp.py in https://github.com/rranxxi/soa_nested_stochastic
# (BSD-3-Clause). The published file is an unfinished demo (hardcoded N=10, a
# pdb.set_trace() inside the loop, no payout accumulation); this version
# completes it in the way most favorable to NumPy:
#   * one shared step() used by the real-world pass and every inner restart
#   * payouts accumulated during stepping instead of full-array re-scans
#   * the guarded fund-weight division done in one pass
# State arrays are indexed by time; because switch points run T-1 down to 1,
# rows below the current switch point still hold real-world values, so each
# inner path only recomputes rows [sp, T). That is the RISP reuse trick.

import numpy as np

from model import RISK_FREE, T, VAL_FREQ, mortality_path


class VectorizedModel:
    def __init__(self, inforce, qx_by_age):
        I = len(inforce)
        self.I = I
        self.funds0 = inforce[[f"FundValue{j}" for j in range(1, 11)]].to_numpy(dtype=float)
        self.fees = inforce.iloc[0][[f"FundFee{j}" for j in range(1, 11)]].to_numpy(dtype=float)
        self.gb_amt = inforce["gbAmt"].to_numpy(dtype=float)
        self.gmwb_balance0 = inforce["gmwbBalance"].to_numpy(dtype=float)
        self.wd_rate = inforce["wbWithdrawalRate"].to_numpy(dtype=float) / VAL_FREQ
        self.withdrawal0 = inforce["withdrawal"].to_numpy(dtype=float)
        self.wd_phase = self.withdrawal0 > 0
        self.use_gb = self.wd_rate > 0.0

        tp = np.minimum(np.ceil(inforce["ProjectionMonths"].to_numpy() / 3.0), T - 1).astype(int)
        tgrid = np.arange(T)[:, None]
        self.valid = (tgrid <= tp[None, :]).astype(float)      # (T, I)
        self.attained = (tgrid == tp[None, :]).astype(float)   # (T, I)

        self.q = np.zeros((T, I))
        self.surv = np.zeros((T, I))
        for i in range(I):
            qi, si = mortality_path(qx_by_age, int(inforce["AttainedAge"].iloc[i]),
                                    inforce["gender"].iloc[i] == "M")
            self.q[:, i] = qi
            self.surv[:, i] = si

        # time-indexed state arrays (the RISP backbone)
        self.fund = np.zeros((T, I, 10))
        self.weights = np.zeros((T, I, 10))
        self.av = np.zeros((T, I))
        self.wav = np.zeros((T, I))
        self.B = np.zeros((T, I))     # gmwb benefit base
        self.W = np.zeros((T, I))     # gmwb withdrawal amount
        self.GB = np.zeros((T, I))    # gmwb balance

    def init_t0(self):
        self.fund[0] = self.funds0
        av0 = self.funds0.sum(axis=1)
        self.av[0] = av0
        with np.errstate(divide="ignore", invalid="ignore"):
            self.weights[0] = np.where(av0[:, None] > 0, self.funds0 / av0[:, None], 0.0)
        self.B[0] = self.gb_amt
        self.W[0] = self.withdrawal0
        self.GB[0] = self.gmwb_balance0
        self.wav[0] = 0.0

    def step(self, t, ret_row):
        """Advance every policy from row t-1 to row t under fund returns
        ret_row (10,). Returns this period's guarantee payout (I,)."""
        g = self.fund[t - 1] * ret_row
        fw = self.weights[t - 1] * self.wav[t - 1][:, None]
        f = np.maximum(0.0, g * (1.0 - self.fees) - fw)
        self.fund[t] = f
        av_t = f.sum(axis=1)
        self.av[t] = av_t
        with np.errstate(divide="ignore", invalid="ignore"):
            self.weights[t] = np.where(av_t[:, None] > 0, f / av_t[:, None], 0.0)

        self.B[t] = np.where(self.wd_phase, self.B[t - 1] - self.W[t - 1],
                             np.maximum(av_t, self.B[t - 1]))
        self.W[t] = self.B[t] * self.wd_rate
        self.GB[t] = np.maximum(0.0, self.GB[t - 1] - self.W[t - 1])
        wpay = np.maximum(0.0, self.W[t] - av_t) * self.surv[t]
        self.wav[t] = np.minimum(av_t, self.W[t])

        mbdb = np.where(self.use_gb, self.GB[t], self.B[t])
        gmdb = np.maximum(0.0, mbdb - av_t) * self.q[t] * self.surv[t]
        gmmb = (mbdb - av_t) * self.surv[t] * self.attained[t]
        return (wpay + gmdb) * self.valid[t] + gmmb

    def valuation(self, rw_returns, rn_returns_list):
        """One outer scenario against every inner scenario and switch point.
        rw_returns: (T, 10) fund return ratios; rn_returns_list: list of (T, 10).
        Returns (R, Vvec): R[n, sp-1] is the switch-point-sp inner PV (summed
        over policies); Vvec[n, t] accumulates payout PVs by calendar time for
        the paper's aggregate metric."""
        N = len(rn_returns_list)
        disc = np.exp(-RISK_FREE / VAL_FREQ * np.arange(T))
        R = np.zeros((N, T - 1))
        Vvec = np.zeros((N, T))

        self.init_t0()
        for t in range(1, T):          # real-world backbone pass
            self.step(t, rw_returns[t])

        for sp in range(T - 1, 0, -1):  # reverse switch points: rows < sp stay RW
            for n in range(N):
                rn = rn_returns_list[n]
                for t in range(sp, T):
                    payout = self.step(t, rn[t])
                    pv = payout.sum() * disc[t - sp]
                    R[n, sp - 1] += pv
                    Vvec[n, t] += pv
        return R, Vvec
