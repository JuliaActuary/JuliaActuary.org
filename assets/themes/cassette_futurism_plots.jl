#=
Cassette futurism / NASA-punk Plots.jl theme — sibling of
assets/themes/cassette_futurism.jl (which targets Makie). Color
constants are duplicated here so the file is self-contained; keep
them in sync with the Makie theme.

Usage
-----
This file is `include`d from posts that have already done `using Plots`,
so `default` is in scope. Colors are passed as hex strings so `Colors.jl`
need not be a direct dep.
=#

const CF_PAPER       = "#F0EDE3"
const CF_PAPER_DEEP  = "#E6E2D5"
const CF_INK         = "#1B2A3A"
const CF_INK_SOFT    = "#3C4A5C"
const CF_RULE        = "#B6AD90"

const CF_RED    = "#C8351C"
const CF_ORANGE = "#E07A1F"
const CF_AMBER  = "#D4A017"
const CF_GREEN  = "#3F7D4E"
const CF_BLUE   = "#1F4E79"
const CF_TEAL   = "#3B7C7A"
const CF_PLUM   = "#6B3A5C"

const CASSETTE_PALETTE = [
    CF_RED, CF_BLUE, CF_AMBER, CF_GREEN, CF_PLUM, CF_ORANGE, CF_TEAL,
]

"""
    cassette_futurism_plots!(; font="JuliaMono")

Apply the cassette-futurism Plots.jl defaults: warm paper background,
deep navy ink, plotter-pen palette, outward draftsman tick marks,
full-frame axes, monospace throughout.
"""
function cassette_futurism_plots!(; font::String = "JuliaMono")
    default(
        background_color           = CF_PAPER,
        background_color_inside    = CF_PAPER,
        background_color_outside   = CF_PAPER,
        background_color_subplot   = CF_PAPER,
        background_color_legend    = CF_PAPER_DEEP,
        foreground_color           = CF_INK,
        foreground_color_axis      = CF_INK,
        foreground_color_border    = CF_INK,
        foreground_color_grid      = CF_RULE,
        foreground_color_text      = CF_INK,
        foreground_color_legend    = CF_INK,
        foreground_color_title     = CF_INK,
        foreground_color_guide     = CF_INK,
        gridalpha                  = 0.25,
        minorgrid                  = false,   # opt in per-plot; log scales explode it
        minorgridalpha             = 0.10,
        framestyle                 = :box,
        tick_direction             = :out,
        palette                    = CASSETTE_PALETTE,
        fontfamily                 = font,
        guidefontfamily            = font,
        tickfontfamily             = font,
        titlefontfamily            = font,
        legendfontfamily           = font,
        titlefontsize              = 13,
        guidefontsize              = 11,
        tickfontsize               = 10,
        legendfontsize             = 10,
        gridlinewidth              = 0.5,
        size                       = (720, 420),
        linewidth                  = 1.8,
        markersize                 = 4,
        markerstrokewidth          = 0.8,
        markerstrokecolor          = CF_INK,
        titlelocation              = :left,
    )
    return nothing
end
