# Errors abort the run; unsupported APIs are explicitly excluded in the workload scripts.
using BenchmarkTools
function run_cases(cases; seconds = parse(Float64, get(ENV, "PERF_SECONDS", "1")))
    label, path = ARGS[1:2]
    smoke = get(ENV, "PERF_SMOKE", "false") == "true"
    open(path, "w") do io
        println(io, "version\tworkload\tminimum_ns\tmedian_ns\tallocations\tbytes")
        for (name, f) in cases
            value = f() # compile and check the workload before timing
            if smoke
                println("PASS ", name, ": ", first(sprint(show, value; context=:limit => true), 300))
                flush(stdout)
                continue
            end
            b = @benchmark $f() seconds = seconds
            lo, md = minimum(b), median(b)
            println(io, join((label, name, lo.time, md.time, lo.allocs, lo.memory), '\t'))
            flush(io)
            println(name, ": ", round(lo.time / 1e3; digits=3), " μs; ", lo.allocs, " allocations")
            flush(stdout)
        end
    end
end
