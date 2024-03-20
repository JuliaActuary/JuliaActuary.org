# This file was generated, do not modify it. # hide
#hideall
using CSV, DataFrames
using PrettyTables
file = download("https://raw.githubusercontent.com/JuliaActuary/Learn/master/Benchmarks/LifeModelingProblem/benchmarks.csv")
benchmarks = CSV.read(file,DataFrame)

benchmarks.relative_mean = benchmarks.mean ./ minimum(benchmarks.mean)
header = (["Language", "Algorithm", "Function name", "Median","Mean","Relative Mean"],
                 [ "",       "",    "",      "[nanoseconds]","[nanoseconds]",""]);
pretty_table(benchmarks;header,formatters = ft_printf("%0.1d"))