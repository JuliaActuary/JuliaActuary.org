### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ b513bc8a-f08d-4d27-8d05-d60885bb03df
begin
	using MortalityTables
	using Turing
	using UUIDs
	using DataFramesMeta
	using MCMCChains, Plots, StatsPlots
	using LinearAlgebra
	using PlutoUI; TableOfContents()
	using Pipe
	using StatisticalRethinking
	using StatsFuns
end

# ╔═╡ 74e4511f-cf5f-4544-8bd2-ea228dfa700e
md"""

## Generating fake data

The problem of interest is to look at mortality rates, which are given in terms of exposures (whether or not a life experienced a death in a given year).

We'll grab some example rates from an insurance table, which has a "selection" component: When someone enters observation, say at age 50, their mortality is path dependent (so for someone who started being observed at 50 will have a different risk/mortality rate at age 55 than someone who started being observed at 45).

Addtionally, there may be additional groups of interest, such as:
- high/medium/low risk classification
- sex
- group (e.g. company, data source, etc.)
- type of insurance product offered

The example data will start with only the risk classification above
"""

# ╔═╡ 3249443a-a8e5-48f1-9eed-379c86144e81
src = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")

# ╔═╡ c931c097-57a1-4f51-857c-b02d3547456f
src.select[50]

# ╔═╡ fdfd1e29-5f8a-405b-9212-7ac08e52ffab
n = 10_000

# ╔═╡ da661ce2-eadf-4ddb-a6c4-5c00dc2caae4
function generate_data_individual(tbl,issue_age=rand(50:55),inforce_years=rand(1:30),risklevel=rand(1:3))
	# risk_factors will scale the "true" parameter up or down
	# we observe the assigned risklevel, but not risk_factor
	risk_factors = [0.7,1.0,1.5]
	rf = risk_factors[risklevel]
	deaths = rand(inforce_years) .< (tbl.select[issue_age][issue_age .+ inforce_years .- 1 ] .* rf)
	
	endpoint = if sum(deaths) == 0
		last(inforce_years)
	else
		findfirst(deaths)
	end
	id= uuid1()
	map(1:endpoint) do i
		(
		issue_age=issue_age,
		risklevel = risklevel,
		att_age = issue_age + i -1,
		death = deaths[i],
		id = id,
	)
	end
	
end

# ╔═╡ 4a77aad1-1a1f-484d-b128-526ee9f3a4a8
exposures = vcat([generate_data_individual(src) for _ in 1:n]...) |> DataFrame

# ╔═╡ c7d8c2fe-838d-4521-beeb-e471e443107a
data = combine(groupby(exposures,[:issue_age,:att_age])) do subdf
	(exposures = nrow(subdf),
	deaths = sum(subdf.death),
	fraction = sum(subdf.death)/ nrow(subdf))
end
	

# ╔═╡ 45237199-f8e8-4f61-b644-89ab37c31a5d
data2 = combine(groupby(exposures,[:issue_age,:att_age,:risklevel])) do subdf
	(exposures = nrow(subdf),
	deaths = sum(subdf.death),
	fraction = sum(subdf.death)/ nrow(subdf))
end
	

# ╔═╡ d23aa389-edfe-4a0d-9924-451b88beb83b
md"
## 1: A single binomial parameter model

Estiamte $p$, the average mortality rate, not accounting for any variation within the population/sample:
"

# ╔═╡ c52bbfab-07f6-40d0-a666-24fbda2435c2
@model function mortality(data,deaths) 
	p ~ Beta(1,1)
	for i = 1:nrow(data)
		deaths[i] ~ Binomial(data.exposures[i],p)
	end
end

# ╔═╡ 18abd59e-ef16-462b-8357-157afc64812b
m1 = mortality(data,data.deaths)

# ╔═╡ 7e739879-241c-49fe-b48c-4245942edda4
num_chains = 4

# ╔═╡ dfa6c8c4-14b3-4c1b-922b-8582cc3243fb
md"### Sampling from the posterior

We use a No-U-Turn-Sampler (NUTS) technique to sample multile chains at once:"

# ╔═╡ 8184820b-0a52-431b-b000-243c7ea9e1ea
chain = sample(m1, NUTS(), 1000)

# ╔═╡ 0edd523e-92bd-4c9c-9cd9-0cd990e72706
plot(chain)

# ╔═╡ 35de8c2c-8e33-4f76-92ba-ce3dfa635cd8
md"### Plotting samples from the posterior

We can see that the sampling of possible posterior parameters doesn't really fit the data very well since our model was so simplified. The lines represent the posterior binomial probability.

This is saying that for the observed data, if there really is just a single probability `p` that governs the true process that came up with the data, there's a pretty narrow range of values it could possibly be:"

# ╔═╡ 74af0a79-292a-4fba-a052-991d3a74c9eb
let
	data_weight = data.exposures ./ sum(data.exposures)
	data_weight = .√(data_weight ./ maximum(data_weight) .* 20)
	
	p = scatter(
		data.att_age,
		data.fraction, 
		markersize = data_weight, 
		alpha = 0.5, 
		label = "Experience data point (size indicates relative exposure quantity)",
		xlabel="age",
		ylim=(0.0,0.25),
		ylabel="mortality rate", 
		title="Parametric Bayseian Mortality"
	)
	
	# show n samples from the posterior plotted on the graph
	n = 300
	ages = sort!(unique(data.att_age))
	
	for i in 1:n
		p_posterior = sample(chain,1)[:p][1]
		hline!([p_posterior],label="",alpha=0.1)
	end
	p
	
end

# ╔═╡ 5faa1505-dbde-48d7-a370-3215c5d73a8c
md"The posterior mean of `p` is of course very close to the simple proportoin of claims to exposures: "

# ╔═╡ 2c3a27a1-b626-4654-9822-2a391c55371d
mean(chain,:p)

# ╔═╡ 84d2dc52-a0c9-4c30-a3cf-7c174f4a046b
sum(data.deaths) / sum(data.exposures)

# ╔═╡ 49bf0bd3-ad5a-409e-a25e-54f7aea44eb3
md"## 2. Parametric model

In this example, we utilize a [MakehamBeard](https://juliaactuary.github.io/MortalityTables.jl/stable/ParametricMortalityModels/#MortalityTables.MakehamBeard) parameterization because it's already very similar in form to a [logistic function](https://en.wikipedia.org/wiki/Logistic_function). This is important because our desired output is a probability (ie the probablity of a death at a given age), so the value must be constrained to be in the interval between zero and one.

The **prior** values for `a`,`b`,`c`, and `k` are chosen to constrain the hazard (mortality) rate to be between zero and one. 

This isn't an ideal parameterization (e.g. we aren't including information about the select underwriting period), but is an example of utilizing Bayesian techniques on life experience data.
"

# ╔═╡ 599942d8-a8d9-40b0-b7fe-b893306dcbcf
@model function mortality2(data,deaths) 
	a ~ Exponential(0.1)
	b ~ Exponential(0.1)
	c = 0.
	k ~ truncated(Exponential(1),1,Inf)
	
	# use the variables to create a parametric mortality model
	m = MortalityTables.MakehamBeard(;a,b,c,k)

	# loop through the rows of the dataframe to let Turing observe the data 
	# and how consistent the parameters are with the data
	for i = 1:nrow(data)
		age = data.att_age[i]	
		q = MortalityTables.hazard(m,age)
		deaths[i] ~ Binomial(data.exposures[i],q)
	end
end

# ╔═╡ ef109946-7e12-4959-9cac-13bbbd436504
md" We combine the model with the data:"

# ╔═╡ ff8616f8-b813-4498-844b-04608986d970
m2 = mortality2(data,data.deaths)

# ╔═╡ cb1a6c73-1464-44a7-97a1-f66b7210f09d
md"### Sampling from the posterior

We use a No-U-Turn-Sampler (NUTS) technique to sample:"

# ╔═╡ 251b0b70-5ba5-415b-970b-e55280cba222
chain2 = sample(m2, NUTS(), 1000)

# ╔═╡ 229d8a8e-197d-42fd-8107-a7826a394c6a
summarize(chain2)

# ╔═╡ 657abb55-f4eb-44f9-83e1-6cfef7c2516d
plot(chain2)

# ╔═╡ d72f1350-83ca-4b4a-b16d-3d00b61b97b2
md"### Plotting samples from the posterior

We can see that the sampling of possible posterior parameters fits the data well:"

# ╔═╡ 85c29fd3-0045-4468-966f-64c2ccb9ce8b
let
	data_weight = data.exposures ./ sum(data.exposures)
	data_weight = .√(data_weight ./ maximum(data_weight) .* 20)
	
	p = scatter(
		data.att_age,
		data.fraction, 
		markersize = data_weight, 
		alpha = 0.5, 
		label = "Experience data point (size indicates relative exposure quantity)",
		xlabel="age",
		ylim=(0.0,0.25),
		ylabel="mortality rate", 
		title="Parametric Bayseian Mortality"
	)
	

	# show n samples from the posterior plotted on the graph
	n = 300
	ages = sort!(unique(data.att_age))
	
	for i in 1:n
		s = sample(chain2,1)
		a = only(s[:a])
		b = only(s[:b])
		k = only(s[:k])
		c = 0
		m = MortalityTables.MakehamBeard(;a,b,c,k)
		plot!(ages,age -> MortalityTables.hazard(m,age), alpha = 0.1,label="")
	end
	p
end

# ╔═╡ a4f7fefa-3f18-4d1c-a8d7-8ed334552966
md"## 3. Parametric model

This model extends the prior to create a multi-level model. Each risk class (`risklevel`) gets its own $a$ paramater in the `MakhamBeard` model. The prior for $a_i$ is determined by the hyperparameter $\bar{a}$.
"

# ╔═╡ 964df467-234c-4aac-a12b-c22f3ff1e07c
@model function mortality3(data,deaths) 
	risk_levels = length(levels(data.risklevel))
	b ~ Exponential(0.1)
	ā ~ Exponential(0.1)
	a ~ filldist(Exponential(ā), risk_levels)
	c = 0
	k ~ truncated(Exponential(1),1,Inf)
	
	# use the variables to create a parametric mortality model

	# loop through the rows of the dataframe to let Turing observe the data 
	# and how consistent the parameters are with the data
	for i = 1:nrow(data)
		risk = data.risklevel[i]
		
		m = MortalityTables.MakehamBeard(;a=a[risk],b,c,k)
		age = data.att_age[i]	
		q = MortalityTables.hazard(m,age)
		deaths[i] ~ Binomial(data.exposures[i],q)
	end
end

# ╔═╡ 5f4ddd19-86ae-4e05-81a2-cc730f4bc0c0
m3 = mortality3(data2,data2.deaths)

# ╔═╡ da15bdb5-c872-4837-a6bb-afe164d1d4cf
chain3 = sample(m3, NUTS(), 1000)

# ╔═╡ e98641db-b2f6-4783-8c29-e6d8b8b4c86d
summarize(chain3)

# ╔═╡ 30d0bd29-415b-4d48-a6b3-52d46fed246c
PRECIS(DataFrame(chain3))

# ╔═╡ 7b026314-3118-42c5-9214-2d5675df769d
let data = data2
	
	data_weight = data.exposures ./ sum(data.exposures)
	data_weight = .√(data_weight ./ maximum(data_weight) .* 20)
	color_i = data.risklevel
	
	p = scatter(
		data.att_age,
		data.fraction, 
		markersize = data_weight, 
		alpha = 0.5, 
		color=color_i,
		label = "Experience data point (size indicates relative exposure quantity)",
		xlabel="age",
		ylim=(0.0,0.25),
		ylabel="mortality rate", 
		title="Parametric Bayseian Mortality"
	)
	

	# show n samples from the posterior plotted on the graph
	n = 100
	
	ages = sort!(unique(data.att_age))
	for r in 1:3	
		for i in 1:n
			s = sample(chain3,1)
			a = only(s[Symbol("a[$r]")])
			b = only(s[:b])
			k = only(s[:k])
			c = 0
			m = MortalityTables.MakehamBeard(;a,b,c,k)
			if i == 1 
				plot!(ages,age -> MortalityTables.hazard(m,age),label="risk level $r", alpha = 0.2,color=r)
			else
				plot!(ages,age -> MortalityTables.hazard(m,age),label="", alpha = 0.2,color=r)
			end
		end
	end
	p
end

# ╔═╡ b888b185-9797-4b4a-8862-c320d427e828
md"## Handling non-unit exposures

The key is to use the Poisson distribution:
"

# ╔═╡ 6d2a0fdc-7627-4942-9b8a-5a6da3aebe85
@model function mortality4(data,deaths) 
	risk_levels = length(levels(data.risklevel))
	b ~ Exponential(0.1)
	ā ~ Exponential(0.1)
	a ~ filldist(Exponential(ā), risk_levels)
	c ~ Beta(4,18)
	k ~ truncated(Exponential(1),1,Inf)
	
	# use the variables to create a parametric mortality model

	# loop through the rows of the dataframe to let Turing observe the data 
	# and how consistent the parameters are with the data
	for i = 1:nrow(data)
		risk = data.risklevel[i]
		
		m = MortalityTables.MakehamBeard(;a=a[risk],b,c,k)
		age = data.att_age[i]	
		q = MortalityTables.hazard(m,age)
		deaths[i] ~ Poisson(data.exposures[i] * q)
	end
end

# ╔═╡ 80102168-610d-4956-9ea4-4f6e45e9968a
m4 = mortality4(data2,data2.deaths)

# ╔═╡ b7fda1be-4e6d-4c16-bfe0-4486c46c3d49
chain4 = sample(m4, NUTS(), 1000)

# ╔═╡ 210ca9dd-22c4-426f-86f9-6ef2b6f78a1a
PRECIS(DataFrame(chain4))

# ╔═╡ 7054d2a2-6fda-4d26-9583-f325ac9a5d9c
risk_factors4 = [mean(chain4[Symbol("a[$f]")]) for f in 1:3]

# ╔═╡ a84fa049-3465-4d19-8bc1-5b622362da63
risk_factors4 ./ risk_factors4[2]

# ╔═╡ 64b1f9d6-6249-438d-aacf-a185914601a8
let data = data2
	
	data_weight = data.exposures ./ sum(data.exposures)
	data_weight = .√(data_weight ./ maximum(data_weight) .* 20)
	color_i = data.risklevel
	
	p = scatter(
		data.att_age,
		data.fraction, 
		markersize = data_weight, 
		alpha = 0.5, 
		color=color_i,
		label = "Experience data point (size indicates relative exposure quantity)",
		xlabel="age",
		ylim=(0.0,0.25),
		ylabel="mortality rate", 
		title="Parametric Bayseian Mortality"
	)
	

	# show n samples from the posterior plotted on the graph
	n = 100
	
	ages = sort!(unique(data.att_age))
	for r in 1:3	
		for i in 1:n
			s = sample(chain4,1)
			a = only(s[Symbol("a[$r]")])
			b = only(s[:b])
			k = only(s[:k])
			c = 0
			m = MortalityTables.MakehamBeard(;a,b,c,k)
			if i == 1 
				plot!(ages,age -> MortalityTables.hazard(m,age),label="risk level $r", alpha = 0.2,color=r)
			else
				plot!(ages,age -> MortalityTables.hazard(m,age),label="", alpha = 0.2,color=r)
			end
		end
	end
	p
end

# ╔═╡ da87eff5-7da8-4c55-9f1c-bbbc0ada980e
md"## Predictions

We can generate predictive estimates by passing a vector of `missing` in place of the outcome variables and then calling `predict`. 

We get a table of values where each row is the the prediction implied by the corresponding chain sample, and the columns are the predicted value for each of the outcomes in our original dataset.
"

# ╔═╡ 5e4b89af-a1f4-4917-aa10-960d8899de5a
preds = predict(mortality4(data2,fill(missing,length(data2.deaths))),chain4)

# ╔═╡ d3aa1aaa-b7c9-411e-bf8a-1583728e3734
size(preds)

# ╔═╡ Cell order:
# ╠═b513bc8a-f08d-4d27-8d05-d60885bb03df
# ╟─74e4511f-cf5f-4544-8bd2-ea228dfa700e
# ╠═3249443a-a8e5-48f1-9eed-379c86144e81
# ╠═c931c097-57a1-4f51-857c-b02d3547456f
# ╠═fdfd1e29-5f8a-405b-9212-7ac08e52ffab
# ╠═da661ce2-eadf-4ddb-a6c4-5c00dc2caae4
# ╠═4a77aad1-1a1f-484d-b128-526ee9f3a4a8
# ╠═c7d8c2fe-838d-4521-beeb-e471e443107a
# ╠═45237199-f8e8-4f61-b644-89ab37c31a5d
# ╠═d23aa389-edfe-4a0d-9924-451b88beb83b
# ╠═c52bbfab-07f6-40d0-a666-24fbda2435c2
# ╠═18abd59e-ef16-462b-8357-157afc64812b
# ╠═7e739879-241c-49fe-b48c-4245942edda4
# ╟─dfa6c8c4-14b3-4c1b-922b-8582cc3243fb
# ╠═8184820b-0a52-431b-b000-243c7ea9e1ea
# ╠═0edd523e-92bd-4c9c-9cd9-0cd990e72706
# ╟─35de8c2c-8e33-4f76-92ba-ce3dfa635cd8
# ╟─74af0a79-292a-4fba-a052-991d3a74c9eb
# ╠═5faa1505-dbde-48d7-a370-3215c5d73a8c
# ╠═2c3a27a1-b626-4654-9822-2a391c55371d
# ╠═84d2dc52-a0c9-4c30-a3cf-7c174f4a046b
# ╟─49bf0bd3-ad5a-409e-a25e-54f7aea44eb3
# ╠═599942d8-a8d9-40b0-b7fe-b893306dcbcf
# ╟─ef109946-7e12-4959-9cac-13bbbd436504
# ╠═ff8616f8-b813-4498-844b-04608986d970
# ╟─cb1a6c73-1464-44a7-97a1-f66b7210f09d
# ╠═251b0b70-5ba5-415b-970b-e55280cba222
# ╠═229d8a8e-197d-42fd-8107-a7826a394c6a
# ╠═657abb55-f4eb-44f9-83e1-6cfef7c2516d
# ╟─d72f1350-83ca-4b4a-b16d-3d00b61b97b2
# ╠═85c29fd3-0045-4468-966f-64c2ccb9ce8b
# ╟─a4f7fefa-3f18-4d1c-a8d7-8ed334552966
# ╠═964df467-234c-4aac-a12b-c22f3ff1e07c
# ╠═5f4ddd19-86ae-4e05-81a2-cc730f4bc0c0
# ╠═da15bdb5-c872-4837-a6bb-afe164d1d4cf
# ╠═e98641db-b2f6-4783-8c29-e6d8b8b4c86d
# ╠═30d0bd29-415b-4d48-a6b3-52d46fed246c
# ╠═7b026314-3118-42c5-9214-2d5675df769d
# ╟─b888b185-9797-4b4a-8862-c320d427e828
# ╠═6d2a0fdc-7627-4942-9b8a-5a6da3aebe85
# ╠═80102168-610d-4956-9ea4-4f6e45e9968a
# ╠═b7fda1be-4e6d-4c16-bfe0-4486c46c3d49
# ╠═210ca9dd-22c4-426f-86f9-6ef2b6f78a1a
# ╠═7054d2a2-6fda-4d26-9583-f325ac9a5d9c
# ╠═a84fa049-3465-4d19-8bc1-5b622362da63
# ╟─64b1f9d6-6249-438d-aacf-a185914601a8
# ╟─da87eff5-7da8-4c55-9f1c-bbbc0ada980e
# ╠═5e4b89af-a1f4-4917-aa10-960d8899de5a
# ╠═d3aa1aaa-b7c9-411e-bf8a-1583728e3734
