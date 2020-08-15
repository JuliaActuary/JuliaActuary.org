# # Introduction To Julia through Life Retention and Claims Analysis
# In this tutorial, we will introduce basic ways of working with Julia and develop a simple working example of how to perform retention analysis in a powerful and performant manner. This extends the example from [Julia as the Language of Choice for Actuaries](/blog/julia-actuaries/).

# ## Installation and Set-up
# There are many ways to work with Julia and you are not limited to a certain workflow or editor environement. However, for simplicity we will focus on four things here:
# 1. Installing Julia
# 2. The Julia REPL
# 3. Jupyter Notebooks
# 4. The Visual Stuido Code Editor

# ### Installing Julia
# Julia is a free and can be downloaded from [JuliaLang.org/downloads](https://julialang.org/downloads/). If you have Windows, you probably want the `64-bit (installer)` version. Download and install - that's it!

# ### The Julia REPL
# If your installation went well, you should be able to find Julia in your start menu. This starts the **REPL** or **Read, Eval, Print, Loop** which is a simple interface to perform calculations or run scripts. Generally, you won't *need* to use this but it ends up being really useful [as the most powerful and extensible calculator on your computer](https://krasjet.com/rnd.wlk/julia/). Learn more about the [basic usage of the REPL here](https://en.wikibooks.org/wiki/Introducing_Julia/The_REPL).

# ### Jupyter Notebooks
# Jupyter (**Ju**lia, **Py**thon, and **R**) notebooks have become incredibly widespread as a way to interactively edit code and do data analysis. To get started, open the Julia REPL and follow the [instructions to install IJulia](https://github.com/JuliaLang/IJulia.jl#installation), which is what powers Julia for Jupypter.

# ### Visual Studio Code
# Among many tools for writing code, Visual Studio Code (free from Microsoft) has [a nice Julia editor](https://www.julia-vscode.org/) that has things like auto-completion, plot views, dataset viewer, inline results, help text, and more (similar to RStudio if that's where you are coming from). [Instructions for instllation are here](https://github.com/julia-vscode/julia-vscode#installing-juliavs-codevs-code-julia-extension) (you have alraedy completed step 1 at this point).
# 
# Once installed, you can create a new file and save it with a `.jl` extension and the environement will load the Julia integrations. From there, you can [interactively run code blocks](https://www.julia-vscode.org/docs/stable/userguide/runningcode/) (similar to the interactivity in Jupyter) by hitting `Alt` +`Enter`.

# 
# 

# At this point you are free to use either Jupyter or VS Code to continue the tutorial - either editor should work.

# ## Retention Analysis

# ### Loading the sample data

# We start by loading the CSV and DataFrames packages so that we can load the data.
using CSV, DataFrames

# To read a CSV, we open the file and pass it (with `x |> f` is the same as `f(x)`) to make it a `DataFrame`[^1]. 
# *The font may render it like a triangle ligature, but `|>` is just `|` and `>` next to each other.*
df_pol = CSV.File(raw"tutorials\_data\retention\policies.csv") |> DataFrame!
first(df_pol,5)

# And the cessions:
df_cessions = CSV.File(raw"tutorials\_data\retention\cessions.csv") |> DataFrame!
first(df_cessions,5)

# ### Data Structures

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


# ### Data, meet Model. Model, meet Data.

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

# A dictionary, `Dict()` is a *really* versatile data structure which contains `key => value` pairs. In this case, we will use the id of each life from the data as the *key* and the `Life` data structure as the *value*.
lives = Dict() # will map life_id => Life



# The hardest part is now looping through the policy data and building the `Life`s and `Policy`s.

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

# ### Building the Retention Logic!

# Now, we define what `retained` means for both a `Policy` and a `Life`. We will define the same **function** (`retention`) to have two different **methods**, one that operates on a `Life` and one that operates on a `Policy`. This is called **multiple dispatch** and allows us to operate contextually and avoid a lot of `if/then` logic, or to have to define `retaiend_policy` and `retained_life` separately. For this case that's not a big deal, but sometimes it can get really unweildy writing out so many different function names.

function retained(pol::Policy)
    if ~isnothing(pol.cessions)
        pol.face - sum(cession.face for cession in pol.cessions)
    else
        pol.face
    end
end

# Note that in the above, there is no `return` statement. Julia will return the result of the last expression if there's no explicit `return`. Alternatively, we can specifiy it with `return`. It's a matter of choice, but in the long run having the explicit version can be more consistent and readable, if a little bit more verbose.

function retained(life::Life)
    return sum(retained.(life.policies))
end

# Let's also define a function that represents how much risk we would *like* to have at most for a given life. In words, let's say that our ruleset is the following:

# | Issue Age    | Single  | Joint     |
# |--------------|---------|-----------|
# | 0 to 60      | 750,000 | 1,000,000 |
# | 61 and above | 400,000 | 800,000   |

# To figure out the issue age (which we'll take as the first-issued policy in the case of multiple policies), we need to work with `Dates`.
using Dates

# To get the information we need for our chart, we have to work with the policies and do some date manimulation:
# 
# 1. To get the earliest issue date, we find the minimum `issue_date` of all the policeis that this life has
# 2. To get the issue_age, we count how many years are between the `first_issue_date` and the `life.birthdate`.
# 3. With that information, it's a simple `if/then` to get the value we want
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

# Now we can naturally work with the model data. For example, let's look at the retained face on life #74:

retained(lives[74])

# And for the first policy that this life has:

retained(lives[74].policies[1])

# Hmm. Those aren't the same - seems like that life actually has more than one policy. We can confirm that:

length(lives[74].policies)

# How would we see how much is retained on each policy? There's several ways:

# - `map(lives[74].policies,retained)` - We already talked about `map`, but here's another example of it in action.
# - `[retained(pol) for pol in lives[74].policies]` - build an array by using `retained` on each policy referenced in the life
# - `retained(lives[74].policies)` - **broadcast** the function across the array. Let's talk more about this one:

retained.(lives[74].policies)

# Broadcasting — the `.` in-between the function and the parenthesis — is a very powerful aspect of Julia - it means that you can move from operating on individual units to collections of units without redefining methods or needing to always work in vectors or always work with one thing at a time.

# ### Analyzing the inforce data

# That's it! now we can look at our retention very easily at a policy or life level. In the next block of code, we will:
# 
# 1. Map over the `values` which are the `Life`s in our `lives` dictionary.
#    - `Map` takes a collection and applies a function. In our case that function is what follows after the `do`.
# 2. Create a *named tuple* of relevant data that we want
#    - A *named tuple* is kind of like a light-weight dataframe. You can inspect the values like `life_retention[1].name` to get the name of the first processed `life`.
# 3. Pipe (`|>` again) into a DataFrame, mostly so that it will print nicely for this tutorial but there's no reason we couldn't work directly with the named tuple.
# 4. `sort!()` the DataFrame so that it will show the biggest `:retained` ones first (reverse order).
#    - Why is it `:retained` instead of `"retained"`? Actually it could be either! The former is a *Symbol* in Julia, which is similar in many ways to a string, but when working with it, Julia won't have to compare each individual character to decided if it's equal to another Symbol.
# 5. Show the top 10 most retained lives.



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

# Mr. Massimi has a lot coverage! A next step might be to figure out what cessions would need to be made in order to cede risk to a reinsurer. We will instead take the analysis a different direction and look at a stochasic mortality projection.

# ## Stochastic Mortality Analysis

# Something not commonly done with life insurance modeling is to take a life-oriented view of the block of business. You might consider it, however, because it can give you greater insight into your risk profile:

# - The distribution of claims can be different as one life might generate multiple simultaneous claims
# - Even without first-to-die reporting, you can infer status from the block:
#    - If you have a joint policy, and one or more of the lives *also* has a single policy, then you can infer the living status of that life.


# [^1]: The `!` in `DataFrame!` is used, by convention, to indicate that we are changing the object given, in this case the loaded CSV data.