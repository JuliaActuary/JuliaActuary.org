@def author = "Alec Loudenback"
@def date = "July 13, 2023"
@def title = "Modern Bayesian Statistics for Actuaries"

@def rss_pubdate = Date(2020,9,27)
@def rss = "Evolving actuarial analysis by going back to the statistical basics"

# Modern Bayesian Statistics for Actuaries

One of the first probabilistic theorems everyone learns is Bayes' Theorem, but that theorem is conspicuously absent from most applications and practice. The reason for this is that outside of trivial introductory examples ("you tested positive for a disease...") is that Bayes' Theorem becomes intractably complicated to calculate the posterior distribution. Modern advances in computing power, algorithms, and open-source libraries have made it possible to start applying the most powerful theorem to much more complex problems.

The advantage of this is that actuaries can now apply these techniques to problems in a principled and flexible way to understand uncertainty better than we have before by explicitly looking at the posterior distribution of the parameters in our model. This would serve to enhance risk management via moving away from singular estimates of model parameters to a culture of considering the parameter distribution of modeled risk.

## What is modern Bayesian Statistics?

A Bayesian statistical model has four main components to focus on:

1. **Prior** encoding assumptions about the random variables related to the problem at hand, before conditioning on the data.
2. A **Model** which defines how the random variables give rise to the observed outcome
3. **Data** which we use to update our prior assumptions
4. **Posterior** distributions of our random variables, conditioned on the observed data and our model

Having defined the first two components and collected our data, the workflow involves computationally sampling the posterior distribution, often using a technique called Markov Chain Monte-Carlo (MCMC). The result is a series of values that are sampled statistically from the posterior distribution.

## Advantages of the Bayesian Approach

The main advantages of this approach over traditional actuarial techniques are:

1. **Focus on distributions rather than point estimates of the posterior's mean or mode.** We are often interested in the distribution of the parameters and a focus on a single parameter estimate will understate the risk distribution.
2. **Model flexibility.** A Bayesian model can be as simple as an ordinary linear regression, but as complex as modeling a full insurance mechanics.
3. **Simpler mental model.** Fundamentally, Bayes' theorem could be distilled down to an approach where you count the ways that things could occur and update the probabilities accordingly.
4. **Explicit Assumptions.**: Enumerating the random variables in your model and explicitly parameterizing prior assumptions avoids ambiguity of the assumptions inside the statistical model.

## Challenges with the Bayesian Approach

With the Bayesian approach, there are a handful of things that are challenging. Many of the listed items are not unique to the Bayesian approach, but there are different facets of the issues that arise.

1. **Model Construction** - One must be thoughtful about the model and how variables interact. However, with the flexibility of modeling, you can apply (actuarial) science to makes better models! 
2. **Model Diagnostics** - Instead of R^2 values, there are unique diagnostics that one must monitor to ensure that the posterior sampling worked as intended.
3. **Model Complexity and Size of Data** - The sampling algorithms are computationally intensive - as the amount of data grows and model complexity grows, the runtime demands cluster computing.
4. **Model Representation** - The statistical derivation of the posterior can only reflect the complexity of the world as defined by your model. A Bayesian model won't automatically infer all possible real-world relationships and constraints.

## Why now?

There are both philosophical and practical reasons why Bayesian analysis is rapidly changing the statistical landscape.

*Philosophically*, one of the main reasons why Bayesian thinking is appealing is its ability to provide a straightforward interpretation of statistical conclusions.

For example, when estimating an unknown quantity, a Bayesian probability interval can be directly understood as having a high probability of containing that quantity. In contrast, a frequentist confidence interval is typically interpreted only in the context of a series of similar inferences that could be made in repeated practice. In recent years, there has been a growing emphasis on interval estimation rather than hypothesis testing in applied statistics. This shift has strengthened the Bayesian perspective since it is likely that many users of standard confidence intervals intuitively interpret them in a manner consistent with Bayesian thinking.

Another meaningful way to understand the contrast between Bayesian and frequentist approaches is through the lens of decision theory, specifically how each view treats the concept of randomness. This perspective pertains to whether you regard the data being random or the parameters being random.

Frequentist statistics treats parameters as fixed and unknown, and the data as random - this is reflective of the view that data you collect is but one realization of an infinitely repeatable random process. Consequently, frequentist procedures, like hypothesis testing or confidence intervals, are generally based on the idea of long-run frequency or repeatable sampling.

Conversely, Bayesian statistics turns this on its head by treating the data as fixed - after all, once you've collected your data, it's no longer random but a fixed observed quantity. Parameters, which are unknown, are treated as random variables. The Bayesian approach then allows us to use probability to quantify our uncertainty about these parameters.

The Bayesian approach tends to align more closely with our intuitive way of reasoning about problems. Often, you are given specific data and you want to understand what that particular set of data tells you about the world. You're likely less interested in what might happen if you had infinite data, but rather in drawing the best conclusions you can from the data you do have.

*Practically*, recent advances in computational power, algorithm development, and open-source libraries have enabled practitioners to adapt the Bayesian workflow.

Deriving the posterior distribution is analytically intractable so computational methods must be used. Advances in raw computing power only in the 1990's made non-trivial Bayesian analysis possible, and recent advances in algorithms have made the computations more efficient. For example, one of the most popular algorithms, NUTS, was only published in the 2010's. 

Many problems require the use of compute clusters to manage runtime, but if there is any place to invest in understanding posterior probability distributions, its insurance companies trying to manage risk!

Moreover, the availability of open-source libraries, such as Turing.jl, PyMC3, and Stan provide access to the core routines in an accessible interface.

## Subjectivity of the Priors?

Two ways one might react to subjectivity in a Bayesian context: it's a feature that should be embraced or it’s a flaw that should be avoided.

### Subjectivity as a feature

**A Bayesian approach to defining a statistical model is an approach that allows for explicitly incorporating actuarial judgment.** Encoding assumptions into a Bayesian model forces the actuary to be explicit about otherwise fuzzy predilections. The explicit assumption is also more amenable to productive debate about its merits and biases than an implicit judgmental override.

### Subjectivity as a flaw

Subjectivity is inherent in all useful statistical methods. Subjectivity in traditional approaches include how the data was collected, which hypothesis to test, what significant levels to use, and assumptions about the data-generating processes. 

In fact, the "objective" approach to null hypothesis testing is so prone to abuse and misinterpretation that in 2016, the American Statistical Association issued a statement intended to steer statistical analysis into a "post p<0.05 era". That "p<0.05" approach is embedded in most traditional approaches to actuarial credibility[^1] and therefore should be similarly reconsidered.

### Maximum Entropy Distributions

Further, when assigning a prior assumption to a random variable, there are mathematically most conservative choices to pull from. These are called Maximum Entropy Distributions (MED) and it can be shown that for certain minimal constraints these are the information-theoretic least informative choices. Least informative means that the prior will have the least influence on the resulting posterior distribution. 

For example, if all you know is that the mean of a random process is positive, then the Exponential Distribution is your MED. If you know that a mean and variance must exist for the process, then the Normal distribution is your MED. If you know nothing at all, you can use a Uniform distribution for the possible values.

## Bayesian vs Machine Learning

Machine learning (ML) is *fully compatible* with Bayesian analysis - one can derive posterior distributions for the ML parameters like any other statistical model and the combination of approaches may be fruitful in practice.

However, to the extent that actuaries have leaned on ML approaches due to the shortcomings of traditional actuarial approaches, Bayesian modeling may provide an attractive alternative without resorting to notoriously finicky and difficult-to-explain ML models. The Bayesian framework provides an explainable model and offers several analytic extensions beyond the scope of this introductory article:

- Causal Modeling: identifying not just correlated relationships, but causal ones, in contexts where a traditional experiment is unavailable
- Bayes Action: optimizing a parameter for, e.g., a CTE95 level instead of a parameter mean
- Information Criterion: principled techniques to compare model fit and complexity
- Missing data: mechanisms to handle the different kinds of missing data
- Model averaging: posteriors can be combined from different models to synthesize different approaches

## Implications for Risk Management

Like Bayes' Formula itself, another aspect of actuarial literature that is taught but often glossed over in practice is the difference between process risk (volatility), parameter risk, and model formulation risk. Often when performing analysis that relies on stochastic result, in practice only process/volatility risk is assessed. 

Bayesian statistics provides the tools to help actuaries address parameter risk and model formulation. The posterior distribution of parameters derived is consistent with the observed data and modeled relationships. This posterior distribution of parameters can then be run as an additional dimension to the risk analysis. 

Additionally, best practices include skepticism of the model construction itself, and testing different formulation of the modeled relationships and variable combinations to identify models which are best fit for purpose. Tools such as Information Criterion, posterior predictive checks, Bayes factors, and other statistical diagnostics can inform the actuary about tradeoffs between different choices of model. 

## Paving the way forward for Actuaries

Bayesian approaches to statistical problems are rapidly changing the professional statistical field. To the extent that the actuarial profession incorporates statistical procedures we should consider adopting the same practices. The benefits of this are a better understanding of the distribution of risks, results that are more interpretable and explainable, and techniques that can applied to a wider range of problems. The combination of these things would serve to enhance actuarial best practices related to understanding and communicating about risk.

For actuaries interested in learning more, there are number of available resources to be found. Textbooks recommended by the author are:

- Statistical Rethinking (McElreath)
- Bayes Rules! (Johnson, Ott, Dogucu)
- Bayesian Data Analysis (Gelman, et. al.)

Additionally, the author has published a few examples of Bayesian analysis in an actuarial context on JuliaActuary.org

[^1]: Note that the approach discussed here is much more encompassing than the Bühlmann-Straub Bayesian approach described in the Actuarial literature.
