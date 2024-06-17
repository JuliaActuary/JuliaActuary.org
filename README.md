# JuliaActuary.org Website

This repository contains the Franklin.jl-based website. It is generated via Github Actions and served via Netlify.

## Contributing

Contributions are very welcome! This site is a basic Quarto website. New content can be added by creating a pull request with a new page in the `posts` folder. A blog post is distinguished from the other examples content by the simple virtue of having the `blog` category field in the topmatter of the `.qmd` file.

## Publishing

After the repository is edited, a maintainer needs to run `quarto render gh-pages` which will render the site and push to the `gh-pages` branch. The reason for this manual step and not an automated deployment is that many of the examples are too computationally expensive for a free Github Action to run. Therefore, the code needs to be run locally and then pushed to the branch which will automatically be deployed after that.

### Contributing in other ways

Pull requests of many kinds are welcome (design changes, layout changes, etc) but may require some HTML, Javascript, and CSS knowledge. Take a look at the [open issues](https://github.com/JuliaActuary/JuliaActuary.org/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) for ideas.