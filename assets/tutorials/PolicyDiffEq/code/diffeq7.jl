# This file was generated, do not modify it. # hide
using ColorSchemes # for Turbo colors, which emphasize readability

viz = plot(layout=2) # side by side plot

# 
contour!(viz[1],int_range,
    prem_range,
    end_av ./ 1e6, # scale to millions for readability

    contour_labels=true,
    c=cgrad(ColorSchemes.turbo.colors),
    fill=true,
    title="AV at age 100 (\$M)",
    ylabel="Annual Premium (\$)",
    

)

contour!(viz[2],int_range,
    prem_range,
    end_age, 

    contour_labels=true,
    c=cgrad(ColorSchemes.turbo.colors),
    fill=true,
    yaxis=false,
    title="Age at Lapse",
)

annotate!(viz[2],0.055,7000,Plots.text("Doesn't lapse \nbefore age 100", 8, :white, :center))
savefig( joinpath(@OUTPUT, "prem_int_sensitivity.svg")) # hide