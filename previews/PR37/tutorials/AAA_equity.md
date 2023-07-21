~~~
<!-- PlutoStaticHTML.Begin -->
<!--
    # This information is used for caching.
    [PlutoStaticHTML.State]
    input_sha = "e9d4fbef82d715859cd7d2892e11bfdb8e64dffa103e1a97489dfcff9fc20f22"
    julia_version = "1.8.5"
-->

<div class="markdown"><h1>Replicating the AAA equtity generator</h1>
<p>This notebook replicates the model and parameters for the real world equity generator described in this <a href="https://www.actuary.org/sites/default/files/pdf/life/c3supp_march05.pdf">AAA 2005 reference paper</a>.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>using Distributions</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>using Random</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>using LabelledArrays</code></pre>



<div class="markdown"><h2>Stochastic Log Volatility Model</h2>
<p>Note that the <code>@.</code> and other broadcasting &#40;<code>.</code> symbol&#41; allows us to operate on multiple funds at once.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>function v(v_prior,params,Zₜ) 
    (;σ_v, σ_m,σ_p,σ⃰,ϕ,τ) = params
    
    v_m = log.(σ_m)
    v_p = log.(σ_p)
    v⃰ = log.(σ⃰)

    # vol are the odd values in the random array
    ṽ =  @. min(v_p, (1 - ϕ) * v_prior + ϕ * log(τ) ) + σ_v * Zₜ[[1,3,5,7]]
    
    v = @. max(v_m, min(v⃰,ṽ))

    return v
end</code></pre>
<pre id='var-v' class='pluto-output'>v (generic function with 1 method)</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>function scenario(params,Z;months=1200)
    (;σ_v,σ_0, ρ,A,B,C) = params

    n_funds = size(params,2)
    
    #initilize/pre-allocate
    Zₜ = rand(Z)
    v_t = log.(σ_0)
    σ_t = zeros(n_funds)
    μ_t = zeros(n_funds)
    
    log_returns = map(1:months) do t
        Zₜ = rand!(Z,Zₜ)
        v_t .= v(v_t,params,Zₜ)

        σ_t .= exp.(v_t)

        @. μ_t =  A + B * σ_t + C * (σ_t)^2

        # return are the even values in the random array
        log_return = @. μ_t / 12 + σ_t / sqrt(12) * Zₜ[[2,4,6,8]]
    end

    # convert vector of vector to matrix
    reduce(hcat,log_returns)
end</code></pre>
<pre id='var-scenario' class='pluto-output'>scenario (generic function with 1 method)</pre>


<div class="markdown"><h2>Scenarios and validation</h2>
<h3>A single scenario</h3>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>x = scenario(params,Z;months=1200)</code></pre>
<pre id='var-x' class='pluto-output'>4×1200 Matrix{Float64}:
 0.07219    -0.0183586   0.00641301  …   0.0269529   0.0451079  0.0116277
 0.0781784   0.0197746  -0.0514942      -0.00124526  0.0374688  0.0151881
 0.0712779   0.0176798  -0.0211841       0.0259013   0.0509245  0.00981782
 0.0429274   0.0687311  -0.189744        0.0588931   0.0407664  0.0205876</pre>


<div class="markdown"><h3>Validation of summary statistics</h3>
</div>


<div class="markdown"><p>The summary statistics expected &#40;per paper Table 8&#41;:</p>
<ul>
<li><p><code>μ ≈ &#91;0.0060, 0.0062, 0.0063, 0.0065&#93;</code></p>
</li>
<li><p><code>σ ≈ &#91;0.0436, 0.0492, 0.0590, 0.0724&#93;</code></p>
</li>
</ul>
</div>


<div class="markdown"><p>These computed values match very closely:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>let
    # generate 1000 scenarios and calculate summary statisics
    scens = [scenario(params,Z) for _ in 1:1000]
    
    μ = vec(mean(mean(x,dims=2) for x in scens))
    σ = vec(mean(std(x,dims=2) for x in scens))
    (;μ,σ)
end</code></pre>
<pre id='var-hash311898' class='pluto-output'>(μ = [0.0060654806168942, 0.006208191119999093, 0.006265235809466131, 0.006503700791977987], σ = [0.04353870212613763, 0.04907864314088451, 0.059053313181942284, 0.07223088853607842])</pre>


<div class="markdown"><h2>Appendices</h2>
<h3>Model Parameters</h3>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'># use a labelled array for easy reference of the parameters 
params = @LArray [
    0.12515 0.14506 0.16341 0.20201 		# τ
    0.35229 0.41676 0.3632 0.35277 			# ϕ
    0.32645 0.32634 0.35789 0.34302 		# σ_v
    -0.2488 -0.1572 -0.2756 -0.2843 		# ρ
    0.055 0.055 0.055 0.055 				# A
    0.56 0.466 0.67 0.715 					# B
    -0.9 -0.9 -0.95 -1.0 					# C
    0.1476 0.1688 0.2049 0.2496 			# σ_0
    0.0305 0.0354 0.0403 0.0492 			# σ_m
    0.3 0.3 0.4 0.55 						# σ_p
    0.7988 0.4519 0.9463 1.1387 			# σ⃰
] ( 
    # define the regions each label refers to
    τ = (1,:),
    ϕ = (2,:),
    σ_v = (3,:),
    ρ = (4,:),
    A = (5,:),
    B = (6,:),
    C = (7,:),
    σ_0 = (8,:),
    σ_m = (9,:),
    σ_p = (10,:),
    σ⃰ = (11,:)
)</code></pre>
<pre id='var-params' class='pluto-output'>11×4 LabelledArrays.LArray{Float64, 2, Matrix{Float64}, (τ = (1, Colon()), ϕ = (2, Colon()), σ_v = (3, Colon()), ρ = (4, Colon()), A = (5, Colon()), B = (6, Colon()), C = (7, Colon()), σ_0 = (8, Colon()), σ_m = (9, Colon()), σ_p = (10, Colon()), σ⃰ = (11, Colon()))}:
   :τ => 0.12515    :τ => 0.14506  …    :τ => 0.20201
   :ϕ => 0.35229    :ϕ => 0.41676       :ϕ => 0.35277
 :σ_v => 0.32645  :σ_v => 0.32634     :σ_v => 0.34302
   :ρ => -0.2488    :ρ => -0.1572       :ρ => -0.2843
      ⋮                            ⋱  
 :σ_m => 0.0305   :σ_m => 0.0354      :σ_m => 0.0492
 :σ_p => 0.3      :σ_p => 0.3         :σ_p => 0.55
   :σ⃰ => 0.7988     :σ⃰ => 0.4519   …    :σ⃰ => 1.1387</pre>


<div class="markdown"><h3>The Multivariate normal and covariance matrix</h3>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>    Z = MvNormal(
        zeros(11), #means for return and volatility
        cov_matrix # covariance matrix
        # full covariance matrix in AAA Excel workook on Parameters tab
    )
</code></pre>
<pre id='var-Z' class='pluto-output'>FullNormal(
dim: 11
μ: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
Σ: [1.0 -0.249 … 0.075 0.08; -0.249 1.0 … 0.192 0.393; … ; 0.075 0.192 … 1.0 0.697; 0.08 0.393 … 0.697 1.0]
)
</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'># 11 columns because it's got the bond returns in it
cov_matrix = [
    1.000	-0.249	0.318	-0.082	0.625	-0.169	0.309	-0.183	0.023	0.075	0.080;
    -0.249	1.000	-0.046	0.630	-0.123	0.829	-0.136	0.665	-0.120	0.192	0.393;
    0.318	-0.046	1.000	-0.157	0.259	-0.050	0.236	-0.074	-0.066	0.034	0.044;
    -0.082	0.630	-0.157	1.000	-0.063	0.515	-0.098	0.558	-0.105	0.130	0.234;
    0.625	-0.123	0.259	-0.063	1.000	-0.276	0.377	-0.180	0.034	0.028	0.054;
    -0.169	0.829	-0.050	0.515	-0.276	1.000	-0.142	0.649	-0.106	0.067	0.267;
    0.309	-0.136	0.236	-0.098	0.377	-0.142	1.000	-0.284	0.026	0.006	0.045;
    -0.183	0.665	-0.074	0.558	-0.180	0.649	-0.284	1.000	0.034	-0.091	-0.002;
    0.023	-0.120	-0.066	-0.105	0.034	-0.106	0.026	0.034	1.000	0.047	-0.028;
    0.075	0.192	0.034	0.130	0.028	0.067	0.006	-0.091	0.047	1.000	0.697;
    0.080	0.393	0.044	0.234	0.054	0.267	0.045	-0.002	-0.028	0.697	1.000;
]</code></pre>
<pre id='var-cov_matrix' class='pluto-output'>11×11 Matrix{Float64}:
  1.0    -0.249   0.318  -0.082   0.625  …   0.309  -0.183   0.023   0.075   0.08
 -0.249   1.0    -0.046   0.63   -0.123     -0.136   0.665  -0.12    0.192   0.393
  0.318  -0.046   1.0    -0.157   0.259      0.236  -0.074  -0.066   0.034   0.044
 -0.082   0.63   -0.157   1.0    -0.063     -0.098   0.558  -0.105   0.13    0.234
  0.625  -0.123   0.259  -0.063   1.0        0.377  -0.18    0.034   0.028   0.054
 -0.169   0.829  -0.05    0.515  -0.276  …  -0.142   0.649  -0.106   0.067   0.267
  0.309  -0.136   0.236  -0.098   0.377      1.0    -0.284   0.026   0.006   0.045
 -0.183   0.665  -0.074   0.558  -0.18      -0.284   1.0     0.034  -0.091  -0.002
  0.023  -0.12   -0.066  -0.105   0.034      0.026   0.034   1.0     0.047  -0.028
  0.075   0.192   0.034   0.13    0.028      0.006  -0.091   0.047   1.0     0.697
  0.08    0.393   0.044   0.234   0.054  …   0.045  -0.002  -0.028   0.697   1.0</pre>
<div class='manifest-versions'>
<p>Built with Julia 1.8.5 and</p>
Distributions 0.25.98<br>
LabelledArrays 1.14.0
</div>

<!-- PlutoStaticHTML.End -->
~~~