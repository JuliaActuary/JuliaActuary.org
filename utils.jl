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


"""
    lx_pluto(com, _)

Embed a Pluto notebook via:
https://github.com/rikhuijzer/PlutoStaticHTML.jl
"""
function lx_pluto(com, _)
    file = string(Franklin.content(com.braces[1]))::String
    notebook_path = joinpath("notebooks", "$file.jl")
    log_path = joinpath("notebooks", "$file.log")

    return """
        ```julia:pluto
        # hideall

        using PlutoStaticHTML: notebook2html

        path = "$notebook_path"
        log_path = "$log_path"
        @assert isfile(path)
        @info "→ evaluating Pluto notebook at (\$path)"
        html = open(log_path, "w") do io
            redirect_stdout(io) do
                html = notebook2html(path)
                return html
            end
        end
        println("~~~\n\$html\n~~~\n")
        ```
        \\textoutput{pluto}
        """
end

"""
    lx_readhtml(com, _)

Embed a Pluto notebook via:
https://github.com/rikhuijzer/PlutoStaticHTML.jl
"""
function lx_readhtml(com, _)
    file = string(Franklin.content(com.braces[1]))::String
    dir = joinpath("posts", "notebooks")
    filename = "$(file).jl"

    return """
        ```julia:pluto
        # hideall

        filename = "$filename"
        html = read(filename, String)
        println("~~~\n\$html\n~~~\n")
        ```
        \\textoutput{pluto}
        """
end