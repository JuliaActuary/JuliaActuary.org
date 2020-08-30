# This file was generated, do not modify it. # hide
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