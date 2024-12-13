# Factorial Snow Model

This is a Julia implementation of the Factorial Snow Model (FSM), a multi-physics energy balance model of accumulation and melt of snow on the ground. The original code and more information about the model can be found [here](https://github.com/RichardEssery/FSM).

## Installation

If you have not yet installed Julia, please [follow the instructions for your operating system](https://julialang.org/downloads/). We recommend using the latest stable release of Julia.

Start Julia, enter `]` to bring up the [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/),
and add the FSM package in development mode:

```julia
julia> ]
(v1.10) pkg> dev https://github.com/jannefiluren/FSM.jl.git
```

This clones the code to `<your_home>\julia\.dev\FSM`. Exit Julia, and change directory to the location of the FSM code. Restart Julia using the following command:

```julia
julia --project=.
```

This starts Julia and activates the development environment of FSM.

## Run a first test

Run a first simulation by typing the following command:

```julia
include("script/run.jl")
```

## Explore the model in Pluto

Run the model in a [Pluto](https://github.com/fonsp/Pluto.jl) notebook by typing the following command:

```julia
using Pluto
Pluto.run(notebook="./notebooks/fsm_pluto.jl")
```
