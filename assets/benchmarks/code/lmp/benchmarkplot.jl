# This file was generated, do not modify it. # hide
#hideall
# Reference Grace Hopper explains the nanosecond
p = plot(palette = :seaborn_colorblind,rotation=15)
# label equivalents to distance to make log scale more relatable
scatter!(fill("\n equivalents (ns → ft)",7),[1,1e1,1e2,1e3,.8e4,0.72e5,3.3e6],series_annotations=Plots.text.(["1 foot","basketball hoop","blue whale","Eiffle Tower","avg ocean depth","marathon distance","Space Station altitude"], :left, 8,:grey),marker=0,label="",left_margin=20mm)

# plot mean, or median if not available
for g in groupby(benchmarks,:algorithm)
    scatter!(g.lang,
        ifelse.(ismissing.(g.mean),g.median,g.mean),
        label="$(g.algorithm[1])",
        yaxis=:log,
        ylabel="Nanoseconds (log scale)",
    marker = (:circle, 5, 0.5, stroke(0)))
end
savefig(p,joinpath(@OUTPUT, "benchmarks.svg")) # hide