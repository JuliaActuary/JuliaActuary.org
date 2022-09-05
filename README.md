# JuliaActuary.org Website

This repository contains the Franklin.jl-based website. It is generated via Github Actions and served via Netlify.

## Contributing

Contributions are very welcome! It's very easy to contribute, especially via the notebook method below.

After creating a Pull Request with your changes, a preview website will be built and an automatic comment will be made pointing to the URL.

### Contributing via a Pluto Notebook

#### Static Notebooks

The easiest way to contribute is to simply create a Pluto notebook and put it in the `/tutorials/` folder. Note that notebooks created in this way are expected to be primarily static, as the website doesn't run a live Julia server.

#### Dynamic Notebooks

Dynamic, interactiven notebooks should be added to the [JuliaActuary/Learn](https://github.com/JuliaActuary/Learn) repository and then follow the pattern of the tutorials that point users to use the notebook interactively ([example](https://github.com/JuliaActuary/JuliaActuary.org/blob/master/tutorials/USTreasury.md)).

### Contributing a Blog Post

Just by using Markdown and Julia you can create a blog post. See [examples in `/blog`](https://github.com/JuliaActuary/JuliaActuary.org/tree/master/blog).


### Contributing in other ways

Pull requests of many kinds are welcome (design changes, layout changes, etc) but may require some HTML, Javascript, and CSS knowledge. Take a look at the [open issues](https://github.com/JuliaActuary/JuliaActuary.org/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) for ideas.