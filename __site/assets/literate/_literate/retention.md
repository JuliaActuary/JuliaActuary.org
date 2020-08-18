<!--This file was generated, do not modify it.-->
# Introduction To Julia through Life Retention Analysis
In this tutorial, we will introduce basic ways of working with Julia and develop a simple working example of how to perform retention analysis in a powerful and performant manner. This extends the example from [Julia as the Language of Choice for Actuaries](/blog/julia-actuaries/).

## Installation and Set-up
There are many ways to work with Julia and you are not limited to a certain workflow or editor environement. However, for simplicity we will focus on four things here:
1. Installing Julia
2. The Julia REPL
3. Jupyter Notebooks
4. The Visual Stuido Code Editor

### Installing Julia
Julia is a free and can be downloaded from [JuliaLang.org/downloads](https://julialang.org/downloads/). If you have Windows, you probably want the `64-bit (installer)` version. Download and install - that's it!

### The Julia REPL
If your installation went well, you should be able to find Julia in your start menu. This starts the **REPL** or **Read, Eval, Print, Loop** which is a simple interface to perform calculations or run scripts. Generally, you won't *need* to use this but it ends up being really useful [as the most powerful and extensible calculator on your computer](https://krasjet.com/rnd.wlk/julia/). Learn more about the [basic usage of the REPL here](https://en.wikibooks.org/wiki/Introducing_Julia/The_REPL).

### Jupyter Notebooks
Jupyter (**Ju**lia, **Py**thon, and **R**) notebooks have become incredibly widespread as a way to interactively edit code and do data analysis. To get started, open the Julia REPL and follow the [instructions to install IJulia](https://github.com/JuliaLang/IJulia.jl#installation), which is what powers Julia for Jupypter.

### Visual Studio Code
Among many tools for writing code, Visual Studio Code (free from Microsoft) has [a nice Julia editor](https://www.julia-vscode.org/) that has things like auto-completion, plot views, dataset viewer, inline results, help text, and more (similar to RStudio if that's where you are coming from). [Instructions for instllation are here](https://github.com/julia-vscode/julia-vscode#installing-juliavs-codevs-code-julia-extension) (you have alraedy completed step 1 at this point).

Once installed, you can create a new file and save it with a `.jl` extension and the environement will load the Julia integrations. From there, you can [interactively run code blocks](https://www.julia-vscode.org/docs/stable/userguide/runningcode/) (similar to the interactivity in Jupyter) by hitting `Alt` +`Enter`.

## Building the Analysis

At this point you are free to use either Jupyter or VS Code to continue the tutorial - either editor should work.

