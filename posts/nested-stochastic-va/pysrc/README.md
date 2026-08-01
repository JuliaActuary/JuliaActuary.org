# Python reference implementations

NumPy ports of the [SOA nested stochastic VA model](https://github.com/rranxxi/soa_nested_stochastic)
(BSD-3-Clause) used as the comparison baseline for the blog post in the parent
directory. `naive.py` is a faithful port of the reference per-policy loop;
`vectorized.py` completes the repo's unfinished RISP broadcasting implementation
(see the post for the deltas).

To reproduce:

```sh
# 1. render the post once (or run its data-prep cell) so ../_data is populated
# 2. then:
uv venv .venv && uv pip install -p .venv numpy pandas
.venv/bin/python validate_dump.py        # writes reference results to ../_data
.venv/bin/python bench.py naive --policies 8 --rn 2
.venv/bin/python bench.py vec --I 38000 --rn 10
.venv/bin/python microbench.py           # the paper's Appendix A comparison
```

The archived copies of `validate_dump.py`'s outputs used by the post's
render-time cross-checks live in `../ref/`.
