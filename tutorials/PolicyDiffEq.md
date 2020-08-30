@def title = "Universal Life Policy Account Mechanics as a Differential Equation"

# {{fill title}}

\toc

## Introduction

This demonstrates an example of defining an universal life policy value roll like a discrete differential equation. 

It then uses the [SciML DifferentialEquations](https://sciml.ai/) package to "solve" the policy projection given a single point, but also to see how the policy projection behaves under different premium and interest rate conditions.

```julia:./code/diffeq1
using Dates, MortalityTables, DifferentialEquations,Plots, ActuaryUtilities
Date(2000,1,1)
```

Let's use the 2001 CSO table as the basis for cost of insurance charges:

```julia:./code/diffeq2
tables = MortalityTables.tables()
cso = tables["2001 CSO Super Preferred Select and Ultimate - Male Nonsmoker, ANB"]
```
\show{./code/diffeq2}

Next, policy mechanics are coded. It's essentially a discrete differential equation, so it leverages [`DifferentialEquations.jl`](https://diffeq.sciml.ai/dev/)

The projection is coded in the [Discrete DifferentialEquation format](https://diffeq.sciml.ai/dev/types/discrete_types/):

$$ u_{n+1} = f(u,p,t_{n+1}) $$

In the code below, this translates to:

- $u$ is the *state* of the system. We  will track three variables to represent the `state`:
   - `state[1]` is the account value
   - `state[2]` is the premium paid
   - `state[3]` is the policy duration
- $p$ are the parameters of the system.
- $t$ is the time, which will represent days since policy issuance


```julia:./code/diffeq3
function policy_projection(state,p,t)
    # grab the state from the inputs
    av = state[1] 
    
    # calculated variables
    cur_date = p.issue_date + Day(t)
    dur = duration(p.issue_date,cur_date)
    att_age = p.issue_age + dur - 1
	
	# lapse if AV <= 0 
    lapsed = (av <= 0.0 ) & (t > 1) 
    
    if !lapsed 

        monthly_coi_rate = (1 - (1-p.mort_assump[att_age]) ^ (1/12))

		## Periodic Policy elements
		
        # annual events
        if Dates.monthday(cur_date) == Dates.monthday(p.issue_date) || 
			cur_date ==p.issue_date + Day(1) # OR first issue date
			
            premium = p.annual_prem
        else
            premium = 0.0
        end

        # monthly_events
        if Dates.day(cur_date) == Dates.day(p.issue_date)
            coi = max((p.face - av) * monthly_coi_rate,0.0)
        else
            coi = 0.0
        end

        # daily events
        int(av) = av * ((1 + p.int_rate) ^ (1 / 360) - 1.0)


        
        # av
        new_av = max(0.0,av - coi + premium + int(av-coi)) 
	
				# new state
		return [new_av, premium, dur] # AV, Prem, Dur
        
    else
		# new state
		return [0.0, 0.0, dur] # AV, Prem, Dur
        
    end
	
    
end
```

The following function will create a named tuple of parameters given a varying `prem` (premium) and `int` (credit rate).

```julia:./code/diffeq4
params(prem,int) = (
    int_rate = int,
    issue_date = Date(2010,1,1),
    face = 1e6,
    issue_age = 25,
    mort_assump = tables["2001 CSO Super Preferred Select and Ultimate - Male Nonsmoker, ANB"].ultimate,
    projection_years = 75,
    annual_prem = prem,
)
```

## Running the system

An example of a single projection:

```julia:./code/diffeq5
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

```



This results in the following plot. The tracked output variables `u1` and `u2` represent the two `vars` that we tracked above: account value and cumulative premium.
\fig{output/single_projection.svg}

## Moving up the ladder of abstraction

An excellent way to understand the behavior of a model is to [move up the ladder of abstraction](http://worrydream.com/LadderOfAbstraction/). Below, we will see what happens to the projection at varying levels of credit rates and annual premiums.

```julia:./code/diffeq6
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
```

Now let's plot the result:


```julia:./code/diffeq7
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
```

\fig{output/prem_int_sensitivity.svg}

Not surprising, interest has a huge effect on the policy projection. Premium is also a major influence.


One thing that's remarkable is how going from `2000` premium to just `~2200` of premium results in about a \$5m difference at `8%` interest. 

## Conclusion 

This shows how universal life mechanics are a dynamic system. the growth/decay is governed by two competing feedback loops:

- Growth: the force of interest lets the balance grow exponentially over long periods of time
- Decay: low balances increase the net amount at risk and the resulting COI charges.

## Endnotes

This is not meant to represent any particular insurance product, nor fully replicate typical account mechanics.