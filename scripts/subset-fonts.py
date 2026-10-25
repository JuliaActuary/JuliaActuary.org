"""Regenerate the committed JuliaMono web subsets (requires fonttools[woff])."""

from pathlib import Path
from fontTools import subset

# Include Latin, Greek, combining marks, arrows, mathematical operators,
# box-drawing characters for future Julia posts; add other current characters.
RANGES = ((0x0000, 0x024F), (0x0300, 0x03FF), (0x1D00, 0x1D7F),
          (0x2000, 0x22FF), (0x2500, 0x259F))
UNICODES = {code for start, end in RANGES for code in range(start, end + 1)}

project = Path(__file__).resolve().parents[1]
for source in project.rglob('*.qmd'):
    if not any(part in ('.quarto', '_site', '.venv') for part in source.relative_to(project).parts):
        UNICODES.update(map(ord, source.read_text()))
root = project / 'assets' / 'webfonts'
for weight in ('Regular', 'Bold'):
    options = subset.Options()
    options.flavor = 'woff2'
    options.hinting = False
    options.drop_tables.append('SVG')  # Color-logo glyphs are outside the web subset.
    font = subset.load_font(str(root / f'JuliaMono-{weight}.woff2'), options)
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=UNICODES)
    subsetter.subset(font)
    destination = root / f'JuliaMono-{weight}-Web.woff2'
    subset.save_font(font, str(destination), options)
    print(f'{destination.name}: {destination.stat().st_size:,} bytes')
