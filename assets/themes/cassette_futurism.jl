#=
Cassette futurism / NASA-punk Makie theme.

Aesthetic notes
---------------
Apollo-era flight plans, plotter pens on manila paper, amber CRT terminals,
Bauhaus restraint, draftsman tick marks. Ink-on-paper, not glow-on-glass:
the colors are saturated but the background is warm and matte.

Fonts
-----
JuliaMono stands in for a future "draftsman" hand — a single monospace family
across titles, axes, and legends gives the engineering-document feel.

Usage
-----
This file is `include`d from posts that have already done `using CairoMakie`,
so `Theme` is in scope. It does not `using Makie` so Makie need not be a
direct dep — CairoMakie's re-exports are enough.
=#

# Emit figures as SVG instead of PNG so they stay crisp at any zoom and on
# high-DPI displays. Caller must have done `using CairoMakie` first.
CairoMakie.activate!(type = "svg")

const CF_PAPER       = "#F0EDE3"  # fresh technical-paper white, faintly warm
const CF_PAPER_DEEP  = "#E6E2D5"  # secondary panel fill
const CF_INK         = "#1B2A3A"  # deep navy "ink"
const CF_INK_SOFT    = "#3C4A5C"  # muted ink for secondary marks
const CF_RULE        = "#B6AD90"  # graph-paper rule color

# Apollo / NASA-punk accent palette — instrument panel pigments.
const CF_RED      = "#C8351C"  # warning red / NASA worm
const CF_ORANGE   = "#E07A1F"  # rocket exhaust
const CF_AMBER    = "#D4A017"  # CRT amber
const CF_GREEN    = "#3F7D4E"  # plotter green / phosphor at rest
const CF_BLUE     = "#1F4E79"  # cosmos blue
const CF_TEAL     = "#3B7C7A"  # oscilloscope teal
const CF_PLUM     = "#6B3A5C"  # console plum

const CASSETTE_PALETTE = [
    CF_RED, CF_BLUE, CF_AMBER, CF_GREEN, CF_PLUM, CF_ORANGE, CF_TEAL,
]

"""
    cassette_futurism_theme(; font="JuliaMono")

Return a Makie `Theme` styled after Apollo-era technical documents:
warm paper background, navy ink, plotter-pen accent palette, full-frame
axes with outward tick marks, and a single monospace family throughout.

`font` is the family name passed to Makie; install JuliaMono system-wide or
pre-register it before using the theme.
"""
function cassette_futurism_theme(; font::String = "JuliaMono")
    font_bold = font  # JuliaMono variants are selected via weight, not family name
    Theme(
        backgroundcolor       = CF_PAPER,
        textcolor             = CF_INK,
        fontsize              = 13,
        fonts = (
            regular    = font,
            bold       = font_bold,
            italic     = font,
            bold_italic = font_bold,
        ),
        palette = (
            color      = CASSETTE_PALETTE,
            patchcolor = CASSETTE_PALETTE,
        ),
        linewidth = 1.6,

        Axis = (
            backgroundcolor      = CF_PAPER,
            xgridcolor           = (CF_RULE, 0.30),
            ygridcolor           = (CF_RULE, 0.30),
            xminorgridcolor      = (CF_RULE, 0.12),
            yminorgridcolor      = (CF_RULE, 0.12),
            xminorgridvisible    = true,
            yminorgridvisible    = true,
            xminorticksvisible   = true,
            yminorticksvisible   = true,
            xticksvisible        = true,
            yticksvisible        = true,
            xtickalign           = 1.0,        # outward — draftsman style
            ytickalign           = 1.0,
            xminortickalign      = 1.0,
            yminortickalign      = 1.0,
            xtickwidth           = 0.9,
            ytickwidth           = 0.9,
            xticksize            = 5,
            yticksize            = 5,
            xminorticksize       = 3,
            yminorticksize       = 3,
            xtickcolor           = CF_INK,
            ytickcolor           = CF_INK,
            xminortickcolor      = CF_INK_SOFT,
            yminortickcolor      = CF_INK_SOFT,
            spinewidth           = 1.1,
            leftspinecolor       = CF_INK,
            rightspinecolor      = CF_INK,
            topspinecolor        = CF_INK,
            bottomspinecolor     = CF_INK,
            xlabelcolor          = CF_INK,
            ylabelcolor          = CF_INK,
            xticklabelcolor      = CF_INK,
            yticklabelcolor      = CF_INK,
            titlecolor           = CF_INK,
            titlealign           = :left,
            titlefont            = font_bold,
            titlesize            = 15,
            titlegap             = 8,
            xlabelfont           = font,
            ylabelfont           = font,
            xticklabelfont       = font,
            yticklabelfont       = font,
            xticklabelsize       = 11,
            yticklabelsize       = 11,
            xlabelsize           = 12,
            ylabelsize           = 12,
            xlabelpadding        = 6,
            ylabelpadding        = 6,
        ),

        Legend = (
            backgroundcolor   = CF_PAPER_DEEP,
            framecolor        = CF_INK,
            framewidth        = 0.9,
            labelcolor        = CF_INK,
            labelfont         = font,
            labelsize         = 11,
            titlefont         = font_bold,
            titlecolor        = CF_INK,
            titlesize         = 12,
            patchsize         = (18, 12),
            padding           = (10, 10, 8, 8),
        ),

        Colorbar = (
            spinewidth      = 1.0,
            tickcolor       = CF_INK,
            tickalign       = 1.0,
            ticklabelcolor  = CF_INK,
            ticklabelfont   = font,
            labelcolor      = CF_INK,
            labelfont       = font,
        ),

        Lines    = (linewidth = 1.8,),
        Scatter  = (strokewidth = 0.8, strokecolor = CF_INK, markersize = 9),
        BarPlot  = (strokewidth = 0.8, strokecolor = CF_INK, gap = 0.18),
        Hist     = (strokewidth = 0.8, strokecolor = CF_INK),
        Density  = (strokewidth = 1.6, strokecolor = CF_INK),
        Heatmap  = (colormap = :lajolla,),
        Contour  = (color = CF_INK, linewidth = 1.0),

        Figure = (
            backgroundcolor = CF_PAPER,
            figure_padding  = 18,
        ),
    )
end
