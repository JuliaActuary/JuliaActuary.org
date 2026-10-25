"""Optimize rendered listing images and improve generated HTML accessibility.

Quarto calls this automatically. Authors keep using normal image / fig-alt
metadata; thumbnails are derived from whichever image Quarto selects for a post.
"""

import hashlib
import io
import os
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit
import xml.etree.ElementTree as ET

from bs4 import BeautifulSoup
from PIL import Image, ImageOps
import pymupdf


PAPER = (240, 237, 227)
THUMBNAIL_SIZES = ((320, 192), (640, 384))


def local_asset(page, source, root):
    url = urlsplit(source)
    if url.scheme or url.netloc or not url.path:
        return None
    path = unquote(url.path)
    candidate = root / path.lstrip('/') if path.startswith('/') else page.parent / path
    candidate = candidate.resolve()
    return candidate if candidate.is_relative_to(root) and candidate.is_file() else None


def dimensions(path):
    if path.suffix.lower() == '.svg':
        svg = ET.parse(path).getroot()
        viewbox = svg.get('viewBox', '').replace(',', ' ').split()
        if len(viewbox) == 4:
            return tuple(round(float(value)) for value in viewbox[2:])
        # Makie also emits SVGs with point dimensions and no viewBox.
        return tuple(round(float(re.match(r'[\d.]+', svg.get(key, '')).group()))
                     for key in ('width', 'height'))
    with Image.open(path) as image:
        return image.size


def thumbnail(source, root):
    # Content hashes refresh previews whenever an author's plot changes.
    digest = hashlib.sha256(b'cassette-thumbnail-v1' + source.read_bytes()).hexdigest()[:20]
    directory = root / 'assets' / 'thumbnails'
    directory.mkdir(parents=True, exist_ok=True)
    targets = [directory / f'{digest}-{width}.webp' for width, _ in THUMBNAIL_SIZES]
    if all(target.exists() for target in targets):
        return targets

    if source.suffix.lower() == '.svg':
        with pymupdf.open(source) as document:
            page = document[0]
            scale = min(640 / page.rect.width, 384 / page.rect.height)
            pixels = page.get_pixmap(matrix=pymupdf.Matrix(scale, scale), alpha=True)
            image = Image.open(io.BytesIO(pixels.tobytes('png'))).convert('RGBA')
    else:
        with Image.open(source) as original:
            # Animated post images get a still preview; the article stays intact.
            image = ImageOps.exif_transpose(original).convert('RGBA')

    for target, size in zip(targets, THUMBNAIL_SIZES):
        preview = ImageOps.contain(image, size, Image.Resampling.LANCZOS)
        canvas = Image.new('RGB', size, PAPER)
        offset = ((size[0] - preview.width) // 2, (size[1] - preview.height) // 2)
        canvas.paste(preview, offset, preview)
        canvas.save(target, 'WEBP', quality=80, method=6)
    return targets


def relative_url(path, page):
    return Path(os.path.relpath(path, page.parent)).as_posix()


def publish_stylesheet(root):
    source = root / 'styles.css'
    content = source.read_bytes()
    digest = hashlib.sha256(content).hexdigest()[:16]
    target = root / f'styles-{digest}.css'
    if not target.exists():
        target.write_bytes(content)
    return target


def optimize_page(page, root, stylesheet=None):
    original = page.read_text()
    soup = BeautifulSoup(original, 'html.parser')
    main = soup.find('main')
    if not main:
        return 0
    if stylesheet is not None:
        for link in soup.select('link[rel~="stylesheet"][href]'):
            asset = local_asset(page, link['href'], root)
            if asset and asset.parent == root and re.fullmatch(r'styles(?:-[0-9a-f]{16})?\.css', asset.name):
                link['href'] = relative_url(stylesheet, page)
    previews = 0
    for index, image in enumerate(main.find_all('img')):
        is_thumbnail = bool(image.find_parent(class_='thumbnail'))
        if is_thumbnail:
            # The adjacent title names this link; the preview is decorative.
            image['alt'] = ''
        elif 'alt' not in image.attrs:
            figure = image.find_parent('figure')
            caption = figure.find('figcaption') if figure else None
            if caption:
                image['alt'] = caption.get_text(' ', strip=True)
            else:
                print(f'Image needs alt text: {page.relative_to(root)}: {image.get("src")}')
        image['decoding'] = 'async'
        image['loading'] = 'lazy' if is_thumbnail or index > 0 else 'eager'
        source_url = image.get('data-thumbnail-source') or image.get('src') or image.get('data-src', '')
        source = local_asset(page, source_url, root)
        if not source:
            continue
        if is_thumbnail and not source.is_relative_to(root / 'assets' / 'thumbnails'):
            small, large = thumbnail(source, root)
            # Preserve the source so incremental post renders can refresh an
            # existing listing even when Quarto does not regenerate its markup.
            image['data-thumbnail-source'] = relative_url(source, page)
            # Replace Quarto's pagination loader with native lazy loading so it
            # cannot later restore the full-size image from data-src.
            image.attrs.pop('data-src', None)
            image['src'] = relative_url(small, page)
            image['srcset'] = f'{relative_url(small, page)} 320w, {relative_url(large, page)} 640w'
            image['sizes'] = '176px'
            image['width'], image['height'] = '640', '384'
            previews += 1
        elif not (image.get('width') and image.get('height')):
            width, height = dimensions(source)
            image['width'], image['height'] = str(width), str(height)

    for table in main.find_all('table'):
        if table.find_parent(class_='table-scroll'):
            continue
        caption = table.find('caption')
        wrapper = soup.new_tag('div', attrs={
            'class': 'table-scroll', 'role': 'region', 'tabindex': '0',
            'aria-label': caption.get_text(' ', strip=True) if caption else 'Scrollable data table',
        })
        table.wrap(wrapper)

    # Quarto's category controls are emitted as divs; native buttons support
    # keyboard activation while retaining the existing category-filter handlers.
    for control in soup.select('div.listing-category[onclick], .quarto-listing-category div.category'):
        control.name = 'button'
        control['type'] = 'button'
    for field in soup.select('.quarto-listing-filter input'):
        field['aria-label'] = 'Filter posts'
    for preview in soup.select('.quarto-post .thumbnail'):
        if not preview.find('img'):
            preview.decompose()
    for empty in soup.select('.quarto-post .metadata, .quarto-post .listing-subtitle'):
        if not empty.get_text(strip=True):
            empty.decompose()
    # Empty thumbnail / metadata links duplicate the adjacent article title.
    for link in soup.select('.quarto-post .thumbnail > a, .quarto-post .metadata > a'):
        if not link.get_text(strip=True):
            link['aria-hidden'] = 'true'
            link['tabindex'] = '-1'

    updated = str(soup)
    if updated != original:
        page.write_text(updated)
    return previews


def main():
    root = Path(os.environ.get('QUARTO_PROJECT_OUTPUT_DIR', '_site')).resolve()
    if not root.is_dir():
        raise SystemExit(f'Quarto output directory does not exist: {root}')
    pages = sorted(root.rglob('*.html'))
    stylesheet = publish_stylesheet(root)
    count = sum(optimize_page(page, root, stylesheet) for page in pages)
    print(f'Optimized {len(pages)} HTML pages and {count} listing previews; theme: {stylesheet.name}.')


if __name__ == '__main__':
    main()
