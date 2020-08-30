# This file was generated, do not modify it. # hide
prem_range = 1000.0:100.0:9000.0
int_range = 0.02:0.0025:0.08

function ending_av(ann_prem,int,days_to_project)
    p = params(ann_prem,int)
    prob = DiscreteProblem(policy_projection,[0.0,0.0,0],(0,days_to_project),p)
    proj = solve(prob,FunctionMap())
    end_av = proj[end][1] 
    if end_av == 0.0
        lapse_time = findfirst(isequal(0.0),proj[1,2:end])
    else
        lapse_time = length(proj)
    end
    duration = proj[3,lapse_time]
    end_age = p.issue_age + duration - 1.0
    
    return end_av,end_age
    
end

end_age = zeros(length(prem_range),length(int_range))
end_av = zeros(length(prem_range),length(int_range))

# loop through each projection we did and fill our ranges with the ending AV and ending age
for (i,vp) in enumerate(prem_range)
    for (j,vi) in enumerate(int_range)
        (end_av[i,j],end_age[i,j]) = ending_av(vp,vi,days_to_project)
    end
end