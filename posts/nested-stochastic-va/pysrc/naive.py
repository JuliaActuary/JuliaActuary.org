# Faithful port of VAPayoutCalculation from va_calculator_naive.py in
# https://github.com/rranxxi/soa_nested_stochastic (BSD-3-Clause).
# Differences from the original, applied so results are well defined:
#   * fund weights are 0 when the account value hits 0 (original divides 0/0
#     and propagates NaN; its RISP sibling already guards this way)
#   * data comes from model.policy_inputs instead of the author's local files
# The loop structure and operation sequence are unchanged: this is the
# "naive brute force" rung of the paper's ladder.

import numpy as np

from model import T, accum_discount, discount_from


def va_payout_naive(p, merged_returns):
    """merged_returns: (120, 121, 10) fund return ratios for every switch-point
    path of one (RW, RN) pair. Returns pv_payout (120, 121)."""
    if_fund_np = p["funds"]
    if_fund_fee = p["fees"]
    tp = p["tp"]
    surv = p["surv"]
    q = p["q"]

    npaths = merged_returns.shape[0]
    proj_fund = np.zeros_like(merged_returns)          # (120, 121, 10)
    account_values = np.zeros(merged_returns.shape[0:2])  # (120, 121)
    withdrawal_from_av = np.zeros_like(account_values)
    gmwb = np.zeros_like(account_values)
    gmwb_withdrawal = np.zeros_like(account_values)
    gmwb_balance = np.zeros_like(account_values)
    gmwb_payout = np.zeros_like(account_values)
    prev_fund_weight = np.zeros_like(if_fund_np)

    within_withdrawal_phase = p["withdrawal"] > 0
    for i in range(npaths):
        for t in range(tp + 1):
            if t == 0:
                proj_fund[i, t] = if_fund_np
                withdrawal_from_av[i, t] = 0.0
                gmwb[i, 0] = p["gb_amt"]
                gmwb_withdrawal[i, 0] = p["withdrawal"]
                gmwb_balance[i, 0] = p["gmwb_balance"]
                gmwb_payout[i, t] = 0.0
                sum_av = np.sum(if_fund_np)
                account_values[i, t] = sum_av
                for j in range(len(if_fund_np)):
                    prev_fund_weight[j] = if_fund_np[j] / sum_av if sum_av > 0 else 0.0
            else:
                fund_growth = proj_fund[i, t - 1] * merged_returns[i, t]
                fund_withdraw = prev_fund_weight * withdrawal_from_av[i, t - 1]
                fund_remain = fund_growth * (1.0 - if_fund_fee) - fund_withdraw
                proj_fund[i, t] = np.maximum(0.0, fund_remain)

                account_values[i, t] = np.sum(proj_fund[i, t])
                av = account_values[i, t]
                for j in range(len(if_fund_np)):
                    prev_fund_weight[j] = proj_fund[i, t, j] / av if av > 0 else 0.0

                if within_withdrawal_phase:
                    gmwb[i, t] = gmwb[i, t - 1] - gmwb_withdrawal[i, t - 1]
                else:
                    gmwb[i, t] = max(account_values[i, t], gmwb[i, t - 1])
                gmwb_withdrawal[i, t] = gmwb[i, t] * p["wd_rate"]
                gmwb_balance[i, t] = max(0.0, gmwb_balance[i, t - 1] - gmwb_withdrawal[i, t - 1])
                gmwb_payout[i, t] = max(0.0, gmwb_withdrawal[i, t] - account_values[i, t]) * surv[t]
                withdrawal_from_av[i, t] = min(account_values[i, t], gmwb_withdrawal[i, t])

    # benefits.gmdbCalculation, inlined
    mbdb = gmwb_balance if p["wd_rate"] > 0.0 else gmwb
    gmdb_payout = np.zeros_like(account_values)
    gmmb_payout = np.zeros_like(account_values)
    for i in range(npaths):
        gmdb_payout[i, 1:] = np.maximum(0.0, mbdb[i, 1:] - account_values[i, 1:]) * q[1:] * surv[1:]
        gmmb_payout[i, tp] = (mbdb[i, tp] - account_values[i, tp]) * surv[tp]
    total_payout = gmmb_payout + gmdb_payout + gmwb_payout

    disc = accum_discount()
    pv_payout = np.zeros_like(total_payout)
    for i in range(total_payout.shape[0]):
        pv_payout[i] = total_payout[i] * discount_from(disc, i + 1)
    return pv_payout
