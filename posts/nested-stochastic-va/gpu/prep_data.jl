# Portable data preparation for the GPU follow-up run.
# Produces everything the benchmark and full-run scripts need in gpu/data/:
#   inforce.csv          38,000-policy Gan-Valdez block with derived fields
#   inforce190k.csv      the 38K block tiled 5x (matches the paper's 190K scale;
#                        same 19 product types, same maturity mix)
#   mortality.csv, fundmap.csv
#   scenarios_rw.csv     8 outer scenarios (matches the blog post exactly)
#   scenarios_rw1000.csv 1,000 outer scenarios for the full run (separate seed)
#   scenarios_rn.csv     500 inner scenarios (matches the blog post exactly)
# Identical logic to the data-prep cell in ../index.qmd.

using Downloads, ZipArchives, CSV, DataFrames, Dates, Random, LinearAlgebra, Statistics

const DATA = joinpath(@__DIR__, "data")
const VAMC_URL = "https://www2.math.uconn.edu/~gan/datasets/vamc20180422.zip"
const VAMC_ZIP = joinpath(DATA, "vamc20180422.zip")

isdir(DATA) || mkpath(DATA)
isfile(VAMC_ZIP) || Downloads.download(VAMC_URL, VAMC_ZIP)

archive = ZipReader(read(VAMC_ZIP))
zread(name) = zip_readentry(archive, "vamc20180422/demo/InforceValuationSoS/" * name)
xldate(n) = Date(1899, 12, 30) + Day(n)

inforce = CSV.read(IOBuffer(zread("inforce38k.csv")), DataFrame)
let cur = xldate.(inforce.currentDate), birth = xldate.(inforce.birthDate), mat = xldate.(inforce.matDate)
    inforce.AttainedAge = [floor(Int, Dates.value(c - b) / 365.25) for (c, b) in zip(cur, birth)]
    inforce.ProjectionMonths = [12 * (year(m) - year(c)) + (month(m) - month(c)) for (c, m) in zip(cur, mat)]
end

function read_iam(name)
    lines = split(String(zread(name)), r"\r?\n")
    istart = findfirst(l -> startswith(l, "Row\\Column"), lines) + 1
    pairs = [parse.(Float64, split(l, ",")) for l in lines[istart:end] if occursin(",", l)]
    Dict(Int(a) => q for (a, q) in pairs)
end
male, female = read_iam("1996iammale.csv"), read_iam("1996iamfemale.csv")
ages = 0:145
fill_q(tbl) = [get(tbl, clamp(a, 5, 115), NaN) for a in ages]
CSV.write(joinpath(DATA, "mortality.csv"),
    DataFrame(age=collect(ages), male=fill_q(male), female=fill_q(female)))

fundmap10x5 = Matrix{Float64}(CSV.read(IOBuffer(zread("FundMap.csv")), DataFrame)[:, 2:end])
CSV.write(joinpath(DATA, "fundmap.csv"), DataFrame(permutedims(fundmap10x5), ["fund$i" for i in 1:10]))

stats_lines = split(String(zread("RW/indexStatistics.csv")), r"\r?\n")
parserow(l) = parse.(Float64, split(l, ",")[2:6])
μ, σ = parserow(stats_lines[1]), parserow(stats_lines[2])
C = vcat([parserow(l)' for l in stats_lines[3:7]]...)

const RISK_FREE = 0.03
const T = 121

function gen_scenarios(rng, n, drift)
    L = cholesky(Symmetric(C)).L
    σq, μq = σ ./ 2, (drift .- σ .^ 2 ./ 2) ./ 4
    scen = zeros(n, T, 5)
    for s in 1:n, t in 2:T
        scen[s, t, :] = μq .+ σq .* (L * randn(rng, 5))
    end
    scen
end

function write_scen(path, scen)
    n, _, K = size(scen)
    df = DataFrame(scenario=repeat(1:n, inner=T), t=repeat(0:T-1, n))
    for k in 1:K
        df[!, "idx$k"] = vec(permutedims(scen[:, :, k]))
    end
    CSV.write(path, df)
end

# same seed and draw order as the blog post -> identical rw/rn sets
rng = Xoshiro(20210731)
write_scen(joinpath(DATA, "scenarios_rw.csv"), gen_scenarios(rng, 8, μ))
write_scen(joinpath(DATA, "scenarios_rn.csv"), gen_scenarios(rng, 500, fill(RISK_FREE, 5)))
# a fresh, documented seed for the 1,000-outer full run
write_scen(joinpath(DATA, "scenarios_rw1000.csv"), gen_scenarios(Xoshiro(19052021), 1000, μ))

cols = [:recordID, :productType, :gender, :AttainedAge, :ProjectionMonths,
    :gbAmt, :gmwbBalance, :wbWithdrawalRate, :withdrawal,
    [Symbol("FundValue$i") for i in 1:10]..., [Symbol("FundFee$i") for i in 1:10]...]
CSV.write(joinpath(DATA, "inforce.csv"), inforce[:, cols])

tiled = reduce(vcat, [inforce[:, cols] for _ in 1:5])
tiled.recordID = 1:nrow(tiled)
CSV.write(joinpath(DATA, "inforce190k.csv"), tiled)

println("prepared: ", nrow(inforce), " policies (+ tiled ", nrow(tiled), "), ",
    "scenarios 8/1000 outer, 500 inner")