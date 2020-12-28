using FSM
using CSV
using DataFrames
using Debugger
using UnicodePlots

am = 1
cm = 0
dm = 0
em = 0
hm = 0

input = CSV.File("data/met_CdP_0506.csv") |> DataFrame
reference = CSV.File("output/out_CdP_0506_$am$cm$dm$em$hm.txt", header=["year", "month", "day", "hour", "alb", "Roff", "HS", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

input = Input{Float32}(
    input.year,
    input.month,
    input.day,
    input.hour,
    input.SW,
    input.LW,
    input.Sf,
    input.Rf,
    input.Ta,
    input.RH,
    input.Ua,
    input.Ps,
)

snowdepth = zeros(Float32, length(input.Ta))
SWE = zeros(Float32, length(input.Ta))

ebm = EBM{Float32}(am=am, cm=cm, dm=dm, em=em, hm=hm)  ### TODO: something wrong with em!!!

run!(ebm, snowdepth, SWE, input)

plt = lineplot(SWE)
lineplot!(plt, reference.SWE)

@info maximum(abs.(SWE - reference.SWE))

