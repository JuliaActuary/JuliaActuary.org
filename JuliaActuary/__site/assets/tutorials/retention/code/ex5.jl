# This file was generated, do not modify it. # hide
cessions = Dict() # will map pol_id => [cessions]

for row in eachrow(df_cessions)
    c = Cession(
            row.pol_id,
            row.ceded,
            row.company
        )
    if ~haskey(cessions,row.pol_id)
        cessions[row.pol_id]  = [c]
    else
        push!(cessions[row.pol_id],c)
    end


end