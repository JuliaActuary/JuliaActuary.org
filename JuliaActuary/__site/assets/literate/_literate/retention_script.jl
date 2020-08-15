# This file was generated, do not modify it.

using CSV, DataFrames

df_pol = CSV.File(raw"tutorials\_data\retention\policies.csv") |> DataFrame!
first(df_pol,5)

df_cessions = CSV.File(raw"tutorials\_data\retention\cessions.csv") |> DataFrame!
first(df_cessions,5)

struct Life
    id
    name
    policies
    sex
    risk
    smoke
    birthdate
end

struct Policy
    id
    is_joint
    face
    issue_date
    cessions
end

struct Cession
    pol_id
    face
    company
end

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

lives = Dict() # will map life_id => Life

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

function retained(pol::Policy)
    if ~isnothing(pol.cessions)
        pol.face - sum(cession.face for cession in pol.cessions)
    else
        pol.face
    end
end

function retained(life::Life)
    return sum(retained.(life.policies))
end

using Dates

function retention_limit(life::Life)
    first_issue_date = minimum(pol.issue_date for pol in life.policies)
    issue_age = length(life.birthdate:Year(1):first_issue_date) - 1 # Count of Years between the two dates minus 1

    if any(pol.is_joint for pol in life.policies)  # if any of the policies are joint
        if issue_age > 60
            return 8.0e5  # scientific notation
        else
            return 1_000_000.0 # the underscores are just for readability
        end
    else # not joint
        if issue_age > 60
            return 4.0e5
        else
            return 7.5e5
        end
    end
end

retained(lives[74])

retained(lives[74].policies[1])

length(lives[74].policies)

retained.(lives[74].policies)

life_retention = map(values(lives)) do life # Loop through the values of the lives pairs
    (
        id = life.id,
        name = life.name,
        sex = life.sex,
        pol_count = length(life.policies),
        total_face = sum(pol.face for pol in life.policies),
        retained = retained(life),
        desired_limit = retention_limit(life)
    )
end |> DataFrame

sort!(life_retention,:retained,rev=true)
sort!(life_retention,"retained",rev=true)

first(life_retention,10)

