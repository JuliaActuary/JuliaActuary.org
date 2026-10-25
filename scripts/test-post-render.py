"""Integration checks for thumbnail updates and generated HTML accessibility."""

import importlib.util
from pathlib import Path
import tempfile
import unittest

from bs4 import BeautifulSoup
from PIL import Image

spec = importlib.util.spec_from_file_location('post_render', Path(__file__).with_name('post-render.py'))
post_render = importlib.util.module_from_spec(spec)
spec.loader.exec_module(post_render)


class PostRenderTests(unittest.TestCase):
    def test_thumbnail_updates_incrementally_and_preserves_original(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            source = root / 'plot.svg'
            source.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="600">'
                              '<rect width="1200" height="600" fill="red"/></svg>')
            original = source.read_bytes()
            page = root / 'examples.html'
            page.write_text('<main><div class="quarto-post"><div class="thumbnail">'
                            '<a href="post.html"><img data-src="plot.svg"></a></div>'
                            '<h3><a href="post.html">Example</a></h3></div></main>')
            post_render.optimize_page(page, root)
            first = BeautifulSoup(page.read_text(), 'html.parser').img
            self.assertEqual(first['alt'], '')
            self.assertEqual(first['loading'], 'lazy')
            self.assertNotIn('data-src', first.attrs)
            self.assertEqual(source.read_bytes(), original)
            for width, height in post_render.THUMBNAIL_SIZES:
                target = root / first['src'].replace('-320.webp', f'-{width}.webp')
                with Image.open(target) as image:
                    self.assertEqual(image.size, (width, height))
            # No manual listing rebuild: changing the plot updates its preview.
            source.write_text(source.read_text().replace('red', 'blue'))
            post_render.optimize_page(page, root)
            second = BeautifulSoup(page.read_text(), 'html.parser').img
            self.assertNotEqual(first['src'], second['src'])
            self.assertEqual(second['data-thumbnail-source'], 'plot.svg')
            stable = page.read_bytes()
            post_render.optimize_page(page, root)
            self.assertEqual(page.read_bytes(), stable)

    def test_semantics_dimensions_and_keyboard_controls(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            Image.new('RGB', (800, 400)).save(root / 'figure.png')
            page = root / 'article.html'
            page.write_text('<main><img src="figure.png" alt="Yield curves by tenor.">'
                            '<table><caption>Curve quotes</caption><tr><th>Tenor</th></tr>'
                            '<tr><td>10</td></tr></table>'
                            '<div class="listing-category" onclick="filter()">curves</div>'
                            '<div class="quarto-listing-filter"><input></div></main>')
            post_render.optimize_page(page, root)
            soup = BeautifulSoup(page.read_text(), 'html.parser')
            self.assertEqual(soup.img['alt'], 'Yield curves by tenor.')
            self.assertEqual((soup.img['width'], soup.img['height']), ('800', '400'))
            self.assertEqual(soup.img['loading'], 'eager')
            self.assertEqual(soup.table.parent['role'], 'region')
            self.assertEqual(soup.table.parent['tabindex'], '0')
            self.assertEqual(soup.table.parent['aria-label'], 'Curve quotes')
            self.assertEqual(soup.select_one('.listing-category').name, 'button')
            self.assertEqual(soup.input['aria-label'], 'Filter posts')
            self.assertEqual(soup.table.td.get_text(), '10')

    def test_external_and_outside_paths_are_not_processed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            page = root / 'index.html'
            self.assertIsNone(post_render.local_asset(page, 'https://example.com/image.svg', root))
            self.assertIsNone(post_render.local_asset(page, '../outside.svg', root))

    def test_theme_updates_replace_cached_stylesheet_urls(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            source = root / 'styles.css'
            source.write_text('.thumbnail img { height: 384px; object-fit: cover; }')
            pages = [root / 'examples.html', root / 'posts' / 'example' / 'index.html']
            for page in pages:
                page.parent.mkdir(parents=True, exist_ok=True)
                href = post_render.relative_url(source, page)
                page.write_text(f'<link rel="stylesheet" href="{href}"><main>Example</main>')
            old = post_render.publish_stylesheet(root)
            for page in pages:
                post_render.optimize_page(page, root, old)
            source.write_text('.thumbnail img { height: auto; object-fit: contain; }')
            current = post_render.publish_stylesheet(root)
            self.assertNotEqual(old.name, current.name)
            self.assertTrue(old.exists())  # Previously cached HTML keeps working.
            for page in pages:
                post_render.optimize_page(page, root, current)
                soup = BeautifulSoup(page.read_text(), 'html.parser')
                linked = post_render.local_asset(page, soup.link['href'], root)
                self.assertEqual(linked, current)
                self.assertEqual(linked.read_bytes(), source.read_bytes())
                stable = page.read_bytes()
                post_render.optimize_page(page, root, current)
                self.assertEqual(page.read_bytes(), stable)


if __name__ == '__main__':
    unittest.main()
