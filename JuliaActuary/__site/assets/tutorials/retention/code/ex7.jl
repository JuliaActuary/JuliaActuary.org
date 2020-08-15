# This file was generated, do not modify it. # hide
for row in eachrow(df_pol) # loop through each row of the policies dataframe

    pol = Policy(  # Create a Polcy object
        row.id,                        # the policy id
        row.joint,                     # a true/false if the policy is joint
        row.face,                      # face amount
        row.issue_date,                # issue date
        haskey(cessions,row.id) ? cessions[row.id] : nothing # note the in-line "ternary" if statement
    )

    if ~haskey(lives,row.life1_id)      # create a new Life it it's not already in our `lives` dictionary
        lives[row.life1_id] = Life(
            row.life1_id,               # id
            row.life1_name,             # name
            [pol],                      # policies
            row.life1_sex,              # sex
            row.life1_risk,             # risk
            row.life1_smoke,            # smoke
            row.life1_birthday          # birthdate
        )
    else # append (push) to the existing life's policies
        push!(lives[row.life1_id].policies,pol)
    end

    if pol.is_joint  # only do something with a second life it we have a joint policy
        if ~haskey(lives,row.life2_id)      # create a new Life it it's not already in our `lives` dictionary
            lives[row.life2_id] = Life(
                row.life2_id,               # id
                row.life2_name,             # name
                [pol],                      # policies
                row.life2_sex,              # sex
                row.life2_risk,             # risk
                row.life2_smoke,            # smoke
                row.life2_birthday          # birthdate
            )

        else # append (push) to the existing life's policies
            push!(lives[row.life2_id].policies,pol)
        end
    end


end