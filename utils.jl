using Artifacts: @artifact_str

"""
    hfun_artifact(params::Vector{String})::String
Return a (relative) URL to an artifact.
For example, for JuliaMono, use
```
{{artifact JuliaMono juliamono-0.042 webfonts JuliaMono-Regular.woff2}}
```
where JuliaMono is the name of the Artifact in Artifacts.toml.
This method copies the artifact, puts it into `_assets` and returns a relative URL.
"""
function hfun_artifact(params::Vector{String})::String
    name = params[1]
    dir = @artifact_str(name)
    from = joinpath(dir, params[2:end]...)
    @assert isfile(from)
    location = params[2:end]
    to = joinpath(@__DIR__, "__site", "assets", name, location...)
    mkpath(dirname(to))
    cp(from, to; force=true)
    parts = ["assets"; name; location]
    url = string('/', join(parts, '/'))
    return url
end

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end
