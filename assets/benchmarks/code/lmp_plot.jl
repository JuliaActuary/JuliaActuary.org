# This file was generated, do not modify it. # hide
#hideall
using Plots
using DataFrames
p = plot(palette = :seaborn_colorblind,rotation=25,yaxis=:log)
# label equivalents to distance to make log scale more relatable
scatter!(
    fill("\n equivalents (ns → ft)",7),
    [1,1e1,1e2,1e3,.8e4,0.72e5,3.3e6],
    series_annotations=Plots.text.(["1 foot","basketball hoop","blue whale","Eiffel Tower","avg ocean depth","marathon distance","Space Station altitude"], :left, 8,:grey),
    marker=0,
    label="",
    left_margin=20Plots.mm,
    bottom_margin=20Plots.mm
    )

# plot mean, or median if not available
for g in groupby(benchmarks,:algorithm)
    scatter!(p,g.lang,
        ifelse.(ismissing.(g.mean),g.median,g.mean),
        label="$(g.algorithm[1])",
        ylabel="Nanoseconds (log scale)",
    marker = (:circle, 5, 0.7, stroke(0)))
end

savefig(joinpath(@OUTPUT,"lmp_benchmarks.svg"))