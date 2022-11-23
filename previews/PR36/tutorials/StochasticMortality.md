~~~
<!-- PlutoStaticHTML.Begin -->
<!--
    # This information is used for caching.
    [PlutoStaticHTML.State]
    input_sha = "0028f2ac237bd8d172dc32ab49d149d5debdec59eedf67319b24eab74e2a8c75"
    julia_version = "1.8.3"
-->

<div class="markdown"><h1>Stochastic claims projections demo</h1>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>begin
    using CSV, DataFrames
    using MortalityTables, ActuaryUtilities
    using Dates
    using ThreadsX
    using BenchmarkTools
end</code></pre>



<div class="markdown"><p>Define a datatype. Not strictly necessary, but will make extending the program with more functions easier.</p>
</div>


<div class="markdown"><p>Type annotations are optional, but providing them is able to coerce the values to be all plain bits &#40;i.e. simple, non-referenced values like arrays are&#41; when the type is constructed. This makes the whole data be stored in the stack and is an example of data-oriented design. It&#39;s much slower without the type annotations &#40;~0.5 million policies per second, ~50x slower&#41;</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>begin
    @enum Sex Female = 1 Male = 2 
    @enum Risk Standard = 1 Preferred = 2
end</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>struct Policy
    id::Int
    sex::Sex
    benefit_base::Float64
    COLA::Float64
    mode::Int
    issue_date::Date
    issue_age::Int
    risk::Risk
end</code></pre>



<div class="markdown"><p>Load the data:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>sample_csv_data = 
IOBuffer(
    raw"id,sex,benefit_base,COLA,mode,issue_date,issue_age,risk
        1,M,100000.0,0.03,12,1999-12-05,30,Std
        2,F,200000.0,0.03,12,1999-12-05,30,Pref"
)
</code></pre>
<pre id='var-sample_csv_data' class='pluto-output'>IOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=138, maxsize=Inf, ptr=1, mark=-1)</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>policies = let 

    # read CSV directly into a dataframe
    # df = CSV.read("sample_inforce.csv",DataFrame) # use local string for notebook
    df = CSV.read(sample_csv_data,DataFrame)

    # map over each row and construct an array of Policy objects
    map(eachrow(df)) do row
        Policy(
            row.id,
            row.sex == "M" ? Male : Female,
            row.benefit_base,
            row.COLA,
            row.mode,
            row.issue_date,
            row.issue_age,
            row.risk == "Std" ? Standard : Preferred,
        )
    end

    
end</code></pre>
<pre id='var-policies' class='pluto-output'>2-element Vector{Policy}:
 Policy(1, Male, 100000.0, 0.03, 12, Date("1999-12-05"), 30, Standard)
 Policy(2, Female, 200000.0, 0.03, 12, Date("1999-12-05"), 30, Preferred)</pre>


<div class="markdown"><p>Define what mortality gets used:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>mort = Dict(
    Male =&gt; MortalityTables.table(988).ultimate,
    Female =&gt; MortalityTables.table(992).ultimate,
)</code></pre>
<pre id='var-mort' class='pluto-output'>Dict{Sex, OffsetArrays.OffsetVector{Float64, Vector{Float64}}} with 2 entries:
  Female => [0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.…
  Male   => [0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.02…</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>function mortality(pol::Policy,params)
    return params.mortality[pol.sex]
end</code></pre>
<pre id='var-mortality' class='pluto-output'>mortality (generic function with 1 method)</pre>


<div class="markdown"><p>This defines the core logic of the policy projection and will write the results to the given <code>out</code> container &#40;here, a named tuple of arrays&#41;.</p>
<p>This is using a threaded approach where it could be operating on any of the computer&#39;s available threads, thus acheiving thread-based parallelism &#40;as opposed to multi-processor &#40;multi-machine&#41; or GPU-based computation which requires formulating the problem a bit differently &#40;array/matrix based&#41;. For the scale of computation here, I think I&#39;d apply this model of parallelism.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>function pol_project!(out,policy,params)
    # some starting values for the given policy
    dur = duration(policy.issue_date,params.val_date)
    start_age = policy.issue_age + dur - 1
    COLA_factor = (1+policy.COLA)
    cur_benefit = policy.benefit_base * COLA_factor ^ (dur-1)

    # get the right mortality vector
    qs = mortality(policy,params)

    # grab the current thread's id to write to results container without conflicting with other threads
    tid = Threads.threadid()
    
    ω = lastindex(qs) 

    # inbounds turns off bounds-checking, which makes hot loops faster but first write loop without it to ensure you don't create an error (will crash if you have the error without bounds checking)
    @inbounds for t in 1:min(params.proj_length,ω - start_age)
        
        q = qs[start_age + t] # get current mortality
        
        if (rand() &lt; q) 
            return # if dead then just return and don't increment the results anymore
        else
            # pay benefit, add a life to the output count, and increment the benefit for next year
            out.benefits[t,tid] += cur_benefit
            out.lives[t,tid] += 1
            cur_benefit *= COLA_factor
        end
    end
end</code></pre>
<pre id='var-pol_project!' class='pluto-output'>pol_project! (generic function with 1 method)</pre>


<div class="markdown"><p>Parameters for our projection:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>using Random</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>params = (
    val_date = Date(2021,12,31),
    proj_length = 100,
    mortality = mort,
)</code></pre>
<pre id='var-params' class='pluto-output'>(val_date = Date("2021-12-31"), proj_length = 100, mortality = Dict{Main.var"workspace#5".Sex, OffsetArrays.OffsetVector{Float64, Vector{Float64}}}(Female => [0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745, 0.00745  …  0.376246, 0.386015, 0.393507, 0.398308, 0.4, 0.4, 0.4, 0.4, 0.4, 1.0], Male => [0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571, 0.022571  …  0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4]))</pre>


<div class="markdown"><p>Check the number of threads we&#39;re using:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>Threads.nthreads()</code></pre>
<pre id='var-hash166540' class='pluto-output'>2</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>function project(policies,params)
    threads = Threads.nthreads()
    benefits = zeros(params.proj_length,threads)
    lives = zeros(Int,params.proj_length,threads)
    out = (;benefits,lives)
    ThreadsX.foreach(policies) do pol
        pol_project!(out,pol,params)
    end
    map(x-&gt;vec(reduce(+,x,dims=2)),out)
end</code></pre>
<pre id='var-project' class='pluto-output'>project (generic function with 1 method)</pre>


<div class="markdown"><p>Example of single projection:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>project(repeat(policies,100_000),params)</code></pre>
<pre id='var-hash143281' class='pluto-output'>(benefits = [5.6311405031178345e10, 5.6730349545068985e10, 5.713249147972351e10, 5.744719443368105e10, 5.7705637818755226e10, 5.7904339668278e10, 5.8007660705162605e10, 5.808509790517615e10, 5.8046040188633026e10, 5.799311373028989e10  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [195348, 190473, 185631, 180654, 175633, 170557, 165323, 160132, 154839, 149625  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])</pre>


<div class="markdown"><h2>Benchmarking</h2>
</div>


<div class="markdown"><p>Using a Macbook Air laptop, about 30 million policies able to be stochastically projected per second:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>let
    policies_to_benchmark = 3_000_000
    # adjust the `repeat` depending on how many policies are already in the array
    # to match the target number for the benchmark
    n = policies_to_benchmark ÷ length(policies)
    
    @benchmark project(p,r) setup=(p=repeat($policies,$n);r=$params)
end</code></pre>
<pre id='var-hash968469' class='pluto-output'>BenchmarkTools.Trial: 4 samples with 1 evaluation.
 Range (min … max):  1.255 s …   1.339 s  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     1.290 s              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.294 s ± 34.698 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █                    █   █                              █  
  █▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█ ▁
  1.26 s         Histogram: frequency by time        1.34 s <

 Memory estimate: 16.30 KiB, allocs estimate: 144.</pre>


<div class="markdown"><h2>Stochastic Set</h2>
<p>Loop through and calculate the reults <code>n</code> times &#40;this is only running the two policies in the sample data&quot; <code>n</code> times&#41;.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>function stochastic_proj(policies,params,n)

    ThreadsX.map(1:n) do i
        project(policies,params)
    end
end</code></pre>
<pre id='var-stochastic_proj' class='pluto-output'>stochastic_proj (generic function with 1 method)</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>stoch = stochastic_proj(policies,params,1000)</code></pre>
<pre id='var-stoch' class='pluto-output'>1000-element Vector{NamedTuple{(:benefits, :lives), Tuple{Vector{Float64}, Vector{Int64}}}}:
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 457585.53514745255, 471313.1012018761, 485452.49423793243, 500016.0690650704  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 1, 1, 1, 1  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 242726.24711896622, 250008.0345325352  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 1, 1  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 ⋮
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 209377.7929654216, 215659.12675438426, 222128.9005570158, 228792.76757372628, 235656.55060093806, 242726.24711896622, 250008.0345325352  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 1, 1, 1, 1, 1, 1, 1  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 706969.6518028142, 728178.7413568987, 750024.1035976056  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 (benefits = [574831.0226582347, 592075.9533379817, 609838.2319381211, 628133.3788962648, 646977.3802631528, 666386.7016710474, 686378.3027211789, 471313.1012018761, 485452.49423793243, 500016.0690650704  …  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], lives = [2, 2, 2, 2, 2, 2, 2, 1, 1, 1  …  0, 0, 0, 0, 0, 0, 0, 0, 0, 0])</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>using UnicodePlots</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>let
    v = [pv(0.03,s.benefits) for s in stoch]
    histogram(v,nbins=15)
end</code></pre>
<pre id='var-hash170662' class='pluto-output'>                  ┌                                        ┐ 
   [0.0  , 2.0e6) ┤███▋ 16                                   
   [2.0e6, 4.0e6) ┤████████████▎ 52                          
   [4.0e6, 6.0e6) ┤█████████████████▋ 76                     
   [6.0e6, 8.0e6) ┤███████████████████████████▍ 117          
   [8.0e6, 1.0e7) ┤████████████████████████████▉ 124         
   [1.0e7, 1.2e7) ┤███████████████████████████████████  150  
   [1.2e7, 1.4e7) ┤█████████████████████████████████▎ 142    
   [1.4e7, 1.6e7) ┤█████████████████████████████▊ 128        
   [1.6e7, 1.8e7) ┤████████████████████▊ 89                  
   [1.8e7, 2.0e7) ┤████████████▍ 53                          
   [2.0e7, 2.2e7) ┤███████▋ 33                               
   [2.2e7, 2.4e7) ┤███▌ 15                                   
   [2.4e7, 2.6e7) ┤▋ 3                                       
   [2.6e7, 2.8e7) ┤▌ 2                                       
                  └                                        ┘ 
                                   Frequency                 </pre>


<div class="markdown"><h1>Further Optimization</h1>
<p>In no particular order:</p>
<ul>
<li><p>the RNG could be made faster: https://bkamins.github.io/julialang/2020/11/20/rand.html</p>
</li>
<li><p>Could make the stochastic set distributed, but at the current speed the overhead of distributed computing is probably more time than it would save. Same thing with GPU projections</p>
</li>
<li><p>...</p>
</li>
</ul>
</div>
<div class='manifest-versions'>
<p>Built with Julia 1.8.3 and</p>
ActuaryUtilities 3.2.1<br>
BenchmarkTools 1.3.1<br>
CSV 0.10.4<br>
DataFrames 1.3.4<br>
MortalityTables 2.3.0<br>
ThreadsX 0.1.10<br>
UnicodePlots 2.11.2
</div>

<!-- PlutoStaticHTML.End -->
~~~