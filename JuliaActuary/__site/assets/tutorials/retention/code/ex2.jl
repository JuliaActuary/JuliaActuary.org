# This file was generated, do not modify it. # hide
df_pol = CSV.File(raw"tutorials\_data\retention\policies.csv") |> DataFrame!
first(df_pol,5)