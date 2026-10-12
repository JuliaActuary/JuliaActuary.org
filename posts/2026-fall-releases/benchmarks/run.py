#!/usr/bin/env python3
"""Run from any directory with Julia 1.13.1; results are written beside this script."""
import argparse
import datetime
import json
import os
from pathlib import Path
import platform
import subprocess

root = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--smoke', action='store_true', help='execute every case once without timing')
parser.add_argument('--packages', nargs='+', default=['fc', 'fm', 'au', 'mt'])
parser.add_argument('--seconds', type=float, default=1.0)
parser.add_argument('--rounds', type=int, default=3)
parser.add_argument('--julia', default='julia')
args = parser.parse_args()
out = root / ('smoke' if args.smoke else 'results')
out.mkdir(exist_ok=True)
env = dict(os.environ, JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1',
           PERF_SECONDS=str(args.seconds), PERF_SMOKE=str(args.smoke).lower())
try:
    cpu = subprocess.check_output(['sysctl', '-n', 'machdep.cpu.brand_string'],text=True,stderr=subprocess.DEVNULL).strip() if platform.system()=='Darwin' else platform.processor()
except (OSError, subprocess.CalledProcessError):
    cpu = os.environ.get('BENCHMARK_CPU', platform.processor())
metadata = dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                platform=platform.platform(), processor=platform.processor(),
                julia=subprocess.check_output([args.julia, '--version'], text=True).strip(),
                seconds=args.seconds, rounds=1 if args.smoke else args.rounds,
                threads=1, cpu=cpu)
(out/'metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
for pkg in args.packages:
    for round in range(1, (1 if args.smoke else args.rounds)+1):
        for label in ['baseline', 'release']:
            name=f'{pkg}-{label}-{round}'
            print(name, flush=True)
            with (out/f'{name}.log').open('w') as log:
                cmd=[args.julia, f'--project={root/label}', '--startup-file=no', str(root/f'{pkg}.jl'), label, str(out/f'{name}.tsv')]
                result=subprocess.run(cmd, cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
            if result.returncode:
                print((out/f'{name}.log').read_text(), flush=True)
                raise SystemExit(result.returncode)
print('All workflows passed.', flush=True)
