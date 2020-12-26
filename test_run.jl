using FSM
using CSV
using DataFrames
using Debugger
using UnicodePlots

data = CSV.File("data/met_CdP_0506.csv") |> DataFrame

# data = CSV.File("data/met_CdP_0506.txt", header=["year", "month", "day", "hour", "SW", "LW", "Sf", "Rf", "Ta", "RH", "Ua", "Ps"], delim=" ", ignorerepeated=true) |> DataFrame

input = Input{Float32}(
    data.year,
    data.month,
    data.day,
    data.hour,
    data.SW,
    data.LW,
    data.Sf,
    data.Rf,
    data.Ta,
    data.RH,
    data.Ua,
    data.Ps,
)

snowdepth = zeros(Float32, length(input.Ta))
SWE = zeros(Float32, length(input.Ta))

ebm = EBM{Float32}(am=0, cm=0, dm=0, em=0, hm=0)  ### TODO: something wrong with em!!!

run!(ebm, snowdepth, SWE, input)

lineplot(SWE)
# @run run!(ebm, input)
