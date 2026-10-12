#!/usr/bin/env python3
"""Summarize the three runs; retain medians and ranges to expose unstable minima."""
import csv
from pathlib import Path
from statistics import median
root=Path(__file__).resolve().parent
results={}
for p in sorted((root/'results').glob('*-*-*.tsv')):
    pkg,label,round=p.stem.split('-')
    with p.open() as f:
        for row in csv.DictReader(f,delimiter='\t'):
            results.setdefault((pkg,row['workload']),{}).setdefault(label,[]).append(row)
fields=['package','workload','baseline_ns','release_ns','speedup','baseline_median_ns','release_median_ns','baseline_min_range','release_min_range','baseline_allocations','release_allocations','baseline_bytes','release_bytes']
rows=[]
for (pkg,name),versions in results.items():
    assert set(versions)=={'baseline','release'}, (pkg,name,versions.keys())
    assert all(len(v)==3 for v in versions.values()), (pkg,name)
    old,new=[min(versions[v],key=lambda x:float(x['minimum_ns'])) for v in ['baseline','release']]
    medians={v:median(float(x['median_ns']) for x in xs) for v,xs in versions.items()}
    ranges={v:max(float(x['minimum_ns']) for x in xs)/min(float(x['minimum_ns']) for x in xs) for v,xs in versions.items()}
    rows.append(dict(zip(fields,[pkg,name,float(old['minimum_ns']),float(new['minimum_ns']),float(old['minimum_ns'])/float(new['minimum_ns']),medians['baseline'],medians['release'],ranges['baseline'],ranges['release'],old['allocations'],new['allocations'],old['bytes'],new['bytes']])))
with (root/'results'/'summary.csv').open('w') as f:
    w=csv.DictWriter(f,fields,lineterminator="\n");w.writeheader();w.writerows(rows)
lines=['# Release benchmark results','', 'Speedup = baseline minimum / release minimum. Less than 1 means slower.', '', '| Package | Workload | Baseline (μs) | Release (μs) | Speedup | Allocations (old → new) |', '|---|---|---:|---:|---:|---:|']
for r in rows:
    lines.append(f"| {r['package']} | {r['workload']} | {r['baseline_ns']/1000:.3f} | {r['release_ns']/1000:.3f} | {r['speedup']:.2f}× | {r['baseline_allocations']} → {r['release_allocations']} |")
(root/'results'/'summary.md').write_text('\n'.join(lines)+'\n')
print(f'Summarized {len(rows)} workloads.')
