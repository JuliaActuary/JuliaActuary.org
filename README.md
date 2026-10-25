# JuliaActuary.org Website

This repository contains the Quarto website for JuliaActuary. Rendered pages are committed in `_site`, deployed by GitHub Actions, and served via Netlify.

## Contributing

Contributions are very welcome! This site is a basic Quarto website. New content can be added by creating a pull request with a new page in the `posts` folder. A blog post is distinguished from the other examples content by the simple virtue of having the `blog` category field in the topmatter of the `.qmd` file.

## Publishing

Set up the image build tools once, then render with that environment active:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r scripts/requirements.txt
quarto render
```

Commit the source changes and the generated `_site` changes. The workflow publishes `_site` after the commit reaches `master`. Examples run locally because some are too expensive for a free GitHub Actions runner. For a theme-only rebuild with existing execution caches, use `quarto render --use-freezer --no-clean`.

## Theme and post images

The palette, typography, and Bootstrap component defaults live in `assets/themes/cassette.scss`. Page layouts live in `styles.css`; the build-time syntax palette is `assets/themes/cassette.theme`.

The post-render step publishes the custom stylesheet with a content hash in its filename and updates every page to reference it. Theme changes therefore load under a new URL instead of reusing cached CSS. Keep the generated `_site/styles-*.css` files with the rendered pages; older versions remain available for previously cached HTML.

`quarto render` automatically runs `scripts/post-render.py`. It derives static 320px and 640px WebP listing previews from the images Quarto selects, adds intrinsic dimensions and loading hints, and makes generated tables and category filters accessible. Original article images remain intact. Content hashes regenerate a thumbnail when its source changes, so adding or updating a post requires no separate thumbnail step. Set `image:` in a post's front matter only when you want to choose a different preview image.

Describe charts in their Julia cell options:

```julia
#| fig-alt: "Discount factors by maturity for the fitted yield curves."
```

For an ordinary Markdown image without a visible caption, use `![](figure.png){fig-alt="Description of the figure."}`. Listing thumbnails are decorative because their neighboring article titles provide the accessible names. The post-render step reports article images that still need a description.

JuliaMono web subsets are committed, so normal renders need no font-generation step. They cover Latin, Greek, combining marks, common mathematical symbols, box drawing, and all characters in the current Quarto sources. To refresh them after adding unusual characters or updating the original fonts, run `python scripts/subset-fonts.py`. Other glyphs fall back to the system monospace font.

Run `python scripts/test-post-render.py` to check thumbnail regeneration, deferred listing images, and generated accessibility markup.

### Contributing in other ways

Pull requests of many kinds are welcome (design changes, layout changes, etc) but may require some HTML, Javascript, and CSS knowledge. Take a look at the [open issues](https://github.com/JuliaActuary/JuliaActuary.org/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) for ideas.
