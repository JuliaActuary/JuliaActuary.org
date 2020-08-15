# This file was generated, do not modify it. # hide
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