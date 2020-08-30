# This file was generated, do not modify it. # hide
p = params(
        8000.0, # 8,000 annual premium
        0.08    # 8% interest
        ) 

# calculate the number of days to project
projection_end_date = p.issue_date + Year(p.projection_years) 
days_to_project = Dates.value(projection_end_date - p.issue_date)
        
# the [0.0,..] are the initial conditions for the tracked variables
 prob = DiscreteProblem(policy_projection,[0.0,0.0,0],(0,days_to_project),p)
 proj = solve(prob,FunctionMap())

 plot(proj)

savefig( joinpath(@OUTPUT, "single_projection.svg")) # hide