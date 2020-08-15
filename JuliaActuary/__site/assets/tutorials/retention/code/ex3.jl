# This file was generated, do not modify it. # hide
df_cessions = CSV.File(raw"tutorials\_data\retention\cessions.csv") |> DataFrame!
first(df_cessions,5)