# Execute the article's Julia examples without requiring Quarto.
cd(@__DIR__) do
    source = read("index.qmd", String)
    chunks = collect(eachmatch(r"(?ms)^```\{julia\}\n(.*?)^```\s*$", source))
    for (index, chunk) in enumerate(chunks)
        println(stderr, "Running Julia chunk $index/$(length(chunks))")
        include_string(Main, chunk.captures[1], "index.qmd:chunk$index")
    end
    println(stderr, "All Julia examples and comparison assertions passed.")
end
