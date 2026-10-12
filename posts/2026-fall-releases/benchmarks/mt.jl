# MortalityTables 2.6.0 versus the 3.0.0 release commit. Run through run.py.
using MortalityTables, Artifacts
const NEW = pkgversion(MortalityTables) >= v"3"
complete(m, age) = NEW ? complete_life_expectancy(m, age) : life_expectancy(m, age)
curtate(m, age) = NEW ? curtate_life_expectancy(m, age) : life_expectancy(m, age)
const udd = NEW ? MortalityTables.UniformDeaths() : MortalityTables.Uniform()
include(joinpath(@__DIR__, "perf_common.jl"))

const gompertz = Gompertz(a = 0.0003, b = log(1.07))
const makeham = Makeham()
const weibull = MortalityTables.Weibull(m = 50.0, σ = 10.0)
const kannisto = MortalityTables.Kannisto()
const beard = MortalityTables.Beard()
const cso = MortalityTables.table("1980 CSO Basic Table – Male, ANB")
const ult = cso.ultimate
const vbt = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")
# Read through a `Ref`, so the compiler cannot fold the call away.
const gompertz_ref, beard_ref = Ref(gompertz), Ref(beard)

cases = Pair{String, Function}[
    "survival(Gompertz, 40, 60)" => () -> survival(gompertz_ref[], 40, 60),
    "survival(Beard, 40, 50) (numerical cumhazard)" => () -> survival(beard_ref[], 40, 50),
    "life_expectancy(Gompertz, 40)" => () -> complete(gompertz, 40),
    "life_expectancy(Makeham, 65)" => () -> complete(makeham, 65),
    "life_expectancy(Weibull, 40)" => () -> complete(weibull, 40),
    "life_expectancy(Kannisto, 80)" => () -> complete(kannisto, 80),
    "survival(1980 CSO ult, 40, 60)" => () -> survival(ult, 40, 60),
    "survival(1980 CSO ult, 40.5, 60.25, Uniform)" => () -> survival(ult, 40.5, 60.25, udd),
    "life_expectancy(1980 CSO ult, 40)" => () -> curtate(ult, 40),
    "decrement(1980 CSO ult, 40, 60)" => () -> decrement(ult, 40, 60),
    "load table 1980 CSO (XTbML)" => () -> MortalityTables.table("1980 CSO Basic Table – Male, ANB"),
]

const DIR = artifact_path(artifact_hash("mort.soa.org", joinpath(pkgdir(MortalityTables), "Artifacts.toml")))
parse_uncached(path) = if NEW
    MortalityTables._read_xtbml(path)
else
    MortalityTables.XTbML_Table_To_MortalityTable(
        MortalityTables.parseXTbMLTable(MortalityTables.getXML(MortalityTables.open_and_read(path)), path))
end
for (label, name) in [("ultimate", "1980 CSO Basic Table – Male, ANB"),
        ("select and ultimate", "2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB")]
    path = joinpath(DIR, "t$(MortalityTables.table_source_map[name]).xml")
    @assert parse_uncached(path).ultimate == MortalityTables.table(name).ultimate
    push!(cases, "parse uncached XTbML $label" => () -> parse_uncached(path))
end
println("MortalityTables ", pkgversion(MortalityTables))
run_cases(cases)
