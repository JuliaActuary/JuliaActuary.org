# Reproduction of the paper's Appendix A microbenchmark: applying one
# quarter's fund-return ratios (10,) to every policy's fund balances.
import time

import numpy as np

num_inforces = 200_000
num_proj = 121
rng = np.random.default_rng(1)
inforce = rng.uniform(0, 10000, [num_inforces, 10])
ratios = rng.uniform(0.8, 1.2, [num_proj, 10])

# loop over policies (paper's "naive")
s = time.perf_counter()
for t in range(num_proj):
    for i in range(num_inforces):
        ret = ratios[t] * inforce[i]
loop_us = (time.perf_counter() - s) / num_inforces * 1e6

# broadcast over the whole portfolio (paper's "vectorization & broadcasting")
best = np.inf
for _ in range(5):
    s = time.perf_counter()
    for t in range(num_proj):
        ret = ratios[t] * inforce
    best = min(best, time.perf_counter() - s)
bcast_us = best / num_inforces * 1e6

print(f"python loop:      {loop_us:.2f} us per policy (paper: 77.70)")
print(f"python broadcast: {bcast_us:.3f} us per policy (paper: 1.604)")
