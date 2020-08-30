# This file was generated, do not modify it. # hide
params(prem,int) = (
    int_rate = int,
    issue_date = Date(2010,1,1),
    face = 1e6,
    issue_age = 25,
    mort_assump = tables["2001 CSO Super Preferred Select and Ultimate - Male Nonsmoker, ANB"].ultimate,
    projection_years = 75,
    annual_prem = prem,
)