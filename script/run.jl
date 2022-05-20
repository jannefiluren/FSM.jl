using FSM
using CSV
using DataFrames
using Plots

fsm_path = dirname(pathof(FSM))

data_force = CSV.File(joinpath(fsm_path, "..", "data", "met_CdP_0506.csv")) |> DataFrame

data_ref = CSV.File(joinpath(fsm_path, "..", "fortran", "output", "out_CdP_0506_11111.txt"), header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

input = Input{Float64}(
    data_force.year,
    data_force.month,
    data_force.day,
    data_force.hour,
    data_force.SW,
    data_force.LW,
    data_force.Sf,
    data_force.Rf,
    data_force.Ta,
    data_force.RH,
    data_force.Ua,
    data_force.Ps,
    )

ebm = EBM{Float64}(
        am=1,
        cm=1,
        dm=1,
        em=1,
        hm=1,
        zT=1.5,
        zvar=false,
        Tsoil=[282.98, 284.17, 284.70, 284.70]
    )

cn = Constants{Float64}()

snowdepth = similar(input.Ta)
SWE = similar(input.Ta)
Tsurf = similar(input.Ta)

run!(ebm, cn, snowdepth, SWE, Tsurf, input)

plot(data_ref.SWE - SWE)
plot(data_ref.Tsurf - Tsurf .+ 273.15)
