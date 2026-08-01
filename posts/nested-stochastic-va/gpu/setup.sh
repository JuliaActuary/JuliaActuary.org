#!/usr/bin/env bash
# One-time setup on a fresh Lambda GPU instance (Ubuntu, CUDA driver present).
# Run from ~/nsva/gpu after rsyncing this directory (incl. data/) there.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v julia >/dev/null && [ ! -x "$HOME/.juliaup/bin/julia" ]; then
    curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel release
fi
export PATH="$HOME/.juliaup/bin:$PATH"
julia --version

# Julia project (first run downloads the CUDA runtime artifacts, a few minutes)
julia --project=. -e 'using Pkg; Pkg.instantiate(); using CUDA; CUDA.versioninfo()'

# Python side for the CuPy rung
python3 -m venv .venv
.venv/bin/pip install --quiet --upgrade pip
.venv/bin/pip install --quiet numpy pandas cupy-cuda12x
.venv/bin/python -c "import cupy; print('cupy', cupy.__version__, cupy.cuda.runtime.getDeviceProperties(0)['name'].decode())"

# data: rsynced with the bundle, or regenerate from scratch
[ -f data/inforce190k.csv ] || julia --project=. prep_data.jl
echo "setup complete"
