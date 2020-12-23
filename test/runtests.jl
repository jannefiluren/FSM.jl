using Test
using FSM
using CSV
using DataFrames

data_ref = CSV.File("../data/out_CdP_0506.txt", header=["year", "month", "day", "hour", "alb", "Roff", "HS", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

data_force = CSV.File("../data/met_CdP_0506.txt", header=["year", "month", "day", "hour", "SW", "LW", "Sf", "Rf", "Ta", "RH", "Ua", "Ps"], delim=" ", ignorerepeated=true) |> DataFrame

input = Input(
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

#= albs = 0.8
Ds = [0, 0, 0]
Nsnow = 0
Sice = [0, 0, 0]
Sliq = [0, 0, 0]
theta = [0.2, 0.2, 0.2, 0.2]
Tsnow = [273.15, 273.15, 273.15]
Tsoil = [282.0, 284.0, 284.0, 284.0]
Tsurf = 275.0

ebm = EBM(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf) =#

ebm = EBM()

rfs, fsnow, gs, CH, z0, Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet, snowdepth, SWE, SWEall = run!(ebm, input)

@testset "surf_props cold" begin

    err = SWEall - data_ref.SWE

    @test maximum(abs.(err)) < 10

end
