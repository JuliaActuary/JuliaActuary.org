~~~
<!-- PlutoStaticHTML.Begin -->
<!--
    # This information is used for caching.
    [PlutoStaticHTML.State]
    input_sha = "9919ce1b8f34efce340e5f8291c0715ed9c9ef897f4fb3be30834533ef64c286"
    julia_version = "1.8.1"
-->

<div class="markdown"><h1>Using MortaltiyTables.jl with DataFrames</h1>
<h2>MortalityTables.jl standard representation</h2>
<p>MortalityTables.jl stores the rates in a very efficient manner as a collection of vectors indexed by attained age.</p>
</div>


<div class="markdown"><p>First, we include the package, and then we&#39;ll pick a table, where all of the <code>mort.soa.org</code> tables are mirrored into your MortalityTables.jl installation.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>begin
    using MortalityTables

    vbt = MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB") #or any other table
end</code></pre>
<pre id='var-vbt' class='pluto-output'>MortalityTable (Insured Lives Mortality):
   Name:
       2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB
   Fields: 
       (:select, :ultimate, :metadata)
   Provider:
       Society of Actuaries
   mort.SOA.org ID:
       1118
   mort.SOA.org link:
       https://mort.soa.org/ViewTable.aspx?&TableIdentity=1118
   Description:
       2001 Valuation Basic Table (VBT) Residual Standard Select and Ultimate Table -  Male Nonsmoker. Basis: Age Nearest Birthday. Minimum Select Age: 0. Maximum Select Age: 99. Minimum Ultimate Age: 25. Maximum Ultimate Age: 120
</pre>


<div class="markdown"><p>To see how the data is represented, we can look at the the select data for a 55 year old and see the attained age and mortality rates:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>vbt.select[55]</code></pre>
<pre id='var-hash107198' class='pluto-output'>66-element OffsetArray(::Vector{Float64}, 55:120) with eltype Float64 with indices 55:120:
 0.00139
 0.00218
 0.00288
 0.00344
 0.00403
 0.00485
 0.00599
 ⋮
 0.75603
 0.79988
 0.84627
 0.89536
 0.94729
 1.0</pre>


<div class="markdown"><p>This is very efficient and convienent for modeling, but a lot of times you want the data matched up with policy data in a DataFrame.</p>
</div>


<div class="markdown"><h2>Getting data into a dataframe</h2>
</div>


<div class="markdown"><h3>Generate sample data</h3>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>using DataFrames</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>sample_size = 10_000</code></pre>
<pre id='var-sample_size' class='pluto-output'>10000</pre>

<pre class='language-julia'><code class='julia hljs pluto-input'>sample_data = let
    # generate fake data
    df = DataFrame(
        "sex" =&gt; rand(["Male","Female"],sample_size),
        "smoke" =&gt; rand(["Smoker","Nonsmoker"],sample_size),
        "issue_age" =&gt; rand(25:65,sample_size),
        )
    
    # a random offset of issue age is the current attained age
    df.attained_age = df.issue_age .+ rand(1:10,sample_size)
    df
end</code></pre>
<table>
<tr>
<th></th>
<th>sex</th>
<th>smoke</th>
<th>issue_age</th>
<th>attained_age</th>
</tr>
<tr>
<td>1</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>52</td>
<td>61</td>
</tr>
<tr>
<td>2</td>
<td>"Male"</td>
<td>"Nonsmoker"</td>
<td>32</td>
<td>33</td>
</tr>
<tr>
<td>3</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>36</td>
<td>44</td>
</tr>
<tr>
<td>4</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>54</td>
<td>58</td>
</tr>
<tr>
<td>5</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>63</td>
<td>71</td>
</tr>
<tr>
<td>6</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>46</td>
<td>56</td>
</tr>
<tr>
<td>7</td>
<td>"Female"</td>
<td>"Smoker"</td>
<td>26</td>
<td>27</td>
</tr>
<tr>
<td>8</td>
<td>"Female"</td>
<td>"Nonsmoker"</td>
<td>42</td>
<td>45</td>
</tr>
<tr>
<td>9</td>
<td>"Female"</td>
<td>"Nonsmoker"</td>
<td>36</td>
<td>44</td>
</tr>
<tr>
<td>10</td>
<td>"Male"</td>
<td>"Nonsmoker"</td>
<td>43</td>
<td>50</td>
</tr>
<tr>
<td>...</td>
</tr>
<tr>
<td>10000</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>61</td>
<td>71</td>
</tr>
</table>



<div class="markdown"><h3>Define the table set you want to use</h3>
</div>


<div class="markdown"><p>There are a lot of different possible combinations of parameters that you might want to use, such as rates that vary by sex, risk class, table set &#40;VBT/CSO/etc&#41;, smoking status, relative risk, ALB/ANB, etc.</p>
<p>It&#39;s easy to define the parameters applicable to your assumption set. Here, we&#39;ll use a dictionary to define the relationship:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>rate_map = Dict(
    "Male" =&gt; Dict(
        "Smoker" =&gt; MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Smoker, ANB"),
        "Nonsmoker" =&gt; MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Male Nonsmoker, ANB"),
        ),
    
    "Female" =&gt; Dict(
        "Smoker" =&gt; MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Female Smoker, ANB"),
        "Nonsmoker" =&gt; MortalityTables.table("2001 VBT Residual Standard Select and Ultimate - Female Nonsmoker, ANB"),
        )
    );
        </code></pre>



<div class="markdown"><p>and then we&#39;ll define a function to look up the relevant rate. Note how the function matches the levels we defined for the assumption set dictionary above.</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>function rate_lookup(assumption_map,sex,smoke,issue_age,attained_age)
    # pick the relevant table
    table = assumption_map[sex][smoke]
    
    # check if the select rate exists, otherwise look to the ulitmate table
    if issue_age in eachindex(table.select)
        table.select[issue_age][attained_age]
    else
        table.ultimate[attained_age]
    end
end
    
    </code></pre>
<pre id='var-rate_lookup' class='pluto-output'>rate_lookup (generic function with 1 method)</pre>


<div class="markdown"><h3>Lining up with dataframe</h3>
<p>By mapping each row&#39;s data to the lookup function, we get a vector of rates for our data:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>rates = map(eachrow(sample_data)) do row
    rate_lookup(rate_map,row.sex,row.smoke,row.issue_age,row.attained_age)
end</code></pre>
<pre id='var-rates' class='pluto-output'>10000-element Vector{Float64}:
 0.01501
 0.00042
 0.00316
 0.00805
 0.03201
 0.0109
 0.00033
 ⋮
 0.0073
 0.00655
 0.00906
 0.00151
 0.00087
 0.03845</pre>


<div class="markdown"><p>And finally, we can just add this to the dataframe:</p>
</div>

<pre class='language-julia'><code class='julia hljs pluto-input'>sample_data.expectation = rates;</code></pre>


<pre class='language-julia'><code class='julia hljs pluto-input'>sample_data</code></pre>
<table>
<tr>
<th></th>
<th>sex</th>
<th>smoke</th>
<th>issue_age</th>
<th>attained_age</th>
<th>expectation</th>
</tr>
<tr>
<td>1</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>52</td>
<td>61</td>
<td>0.01501</td>
</tr>
<tr>
<td>2</td>
<td>"Male"</td>
<td>"Nonsmoker"</td>
<td>32</td>
<td>33</td>
<td>0.00042</td>
</tr>
<tr>
<td>3</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>36</td>
<td>44</td>
<td>0.00316</td>
</tr>
<tr>
<td>4</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>54</td>
<td>58</td>
<td>0.00805</td>
</tr>
<tr>
<td>5</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>63</td>
<td>71</td>
<td>0.03201</td>
</tr>
<tr>
<td>6</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>46</td>
<td>56</td>
<td>0.0109</td>
</tr>
<tr>
<td>7</td>
<td>"Female"</td>
<td>"Smoker"</td>
<td>26</td>
<td>27</td>
<td>0.00033</td>
</tr>
<tr>
<td>8</td>
<td>"Female"</td>
<td>"Nonsmoker"</td>
<td>42</td>
<td>45</td>
<td>0.00084</td>
</tr>
<tr>
<td>9</td>
<td>"Female"</td>
<td>"Nonsmoker"</td>
<td>36</td>
<td>44</td>
<td>0.00112</td>
</tr>
<tr>
<td>10</td>
<td>"Male"</td>
<td>"Nonsmoker"</td>
<td>43</td>
<td>50</td>
<td>0.00251</td>
</tr>
<tr>
<td>...</td>
</tr>
<tr>
<td>10000</td>
<td>"Male"</td>
<td>"Smoker"</td>
<td>61</td>
<td>71</td>
<td>0.03845</td>
</tr>
</table>


<pre class='language-julia'><code class='julia hljs pluto-input'>begin
    # add a table of contents to the page
    using PlutoUI
    TableOfContents()
end</code></pre>
<script>const getParentCell = el => el.closest("pluto-cell")

const getHeaders = () => {
	const depth = Math.max(1, Math.min(6, 3)) // should be in range 1:6
	const range = Array.from({length: depth}, (x, i) => i+1) // [1, ..., depth]
	
	const selector = range.map(i => `pluto-notebook pluto-cell h${i}`).join(",")
	return Array.from(document.querySelectorAll(selector))
}

const indent = true
const aside = true

const render = (el) => html`${el.map(h => {
	const parent_cell = getParentCell(h)

	const a = html`<a 
		class="${h.nodeName}" 
		href="#${parent_cell.id}"
	>${h.innerText}</a>`
	/* a.onmouseover=()=>{
		parent_cell.firstElementChild.classList.add(
			'highlight-pluto-cell-shoulder'
		)
	}
	a.onmouseout=() => {
		parent_cell.firstElementChild.classList.remove(
			'highlight-pluto-cell-shoulder'
		)
	} */
	a.onclick=(e) => {
		e.preventDefault();
		h.scrollIntoView({
			behavior: 'smooth', 
			block: 'center'
		})
	}

	return html`<div class="toc-row">${a}</div>`
})}`

const tocNode = html`<nav class="plutoui-toc">
	<header>Table of Contents</header>
	<section></section>
</nav>`
tocNode.classList.toggle("aside", aside)
tocNode.classList.toggle("indent", aside)

const updateCallback = () => {
	tocNode.querySelector("section").replaceWith(
		html`<section>${render(getHeaders())}</section>`
	)
}
updateCallback()


const notebook = document.querySelector("pluto-notebook")


// We have a mutationobserver for each cell:
const observers = {
	current: [],
}

const createCellObservers = () => {
	observers.current.forEach((o) => o.disconnect())
	observers.current = Array.from(notebook.querySelectorAll("pluto-cell")).map(el => {
		const o = new MutationObserver(updateCallback)
		o.observe(el, {attributeFilter: ["class"]})
		return o
	})
}
createCellObservers()

// And one for the notebook's child list, which updates our cell observers:
const notebookObserver = new MutationObserver(() => {
	updateCallback()
	createCellObservers()
})
notebookObserver.observe(notebook, {childList: true})

// And finally, an observer for the document.body classList, to make sure that the toc also works when if is loaded during notebook initialization
const bodyClassObserver = new MutationObserver(updateCallback)
bodyClassObserver.observe(document.body, {attributeFilter: ["class"]})

invalidation.then(() => {
	notebookObserver.disconnect()
	bodyClassObserver.disconnect()
	observers.current.forEach((o) => o.disconnect())
})

return tocNode
</script><style>@media screen and (min-width: 1081px) {
	.plutoui-toc.aside {
		position:fixed; 
		right: 1rem;
		top: 5rem; 
		width:25%; 
		padding: 10px;
		border: 3px solid rgba(0, 0, 0, 0.15);
		border-radius: 10px;
		box-shadow: 0 0 11px 0px #00000010;
		/* That is, viewport minus top minus Live Docs */
		max-height: calc(100vh - 5rem - 56px);
		overflow: auto;
		z-index: 50;
		background: white;
	}
}

.plutoui-toc header {
	display: block;
	font-size: 1.5em;
	margin-top: 0.67em;
	margin-bottom: 0.67em;
	margin-left: 0;
	margin-right: 0;
	font-weight: bold;
	border-bottom: 2px solid rgba(0, 0, 0, 0.15);
}

.plutoui-toc section .toc-row {
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	padding-bottom: 2px;
}

.highlight-pluto-cell-shoulder {
	background: rgba(0, 0, 0, 0.05);
	background-clip: padding-box;
}

.plutoui-toc section a {
	text-decoration: none;
	font-weight: normal;
	color: gray;
}
.plutoui-toc section a:hover {
	color: black;
}

.plutoui-toc.indent section a.H1 {
	font-weight: 700;
	line-height: 1em;
}

.plutoui-toc.indent section a.H1 {
	padding-left: 0px;
}
.plutoui-toc.indent section a.H2 {
	padding-left: 10px;
}
.plutoui-toc.indent section a.H3 {
	padding-left: 20px;
}
.plutoui-toc.indent section a.H4 {
	padding-left: 30px;
}
.plutoui-toc.indent section a.H5 {
	padding-left: 40px;
}
.plutoui-toc.indent section a.H6 {
	padding-left: 50px;
}
</style>
<div class='manifest-versions'>
<p>Built with Julia 1.8.1 and</p>
DataFrames 1.2.2<br>
MortalityTables 2.1.4<br>
PlutoUI 0.7.9
</div>

<!-- PlutoStaticHTML.End -->
~~~