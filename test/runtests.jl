using Test
using FSM
using CSV
using DataFrames


data_ref = CSV.File("../data/out_CdP_0506.txt", header=["year", "month", "day", "hour", "alb", "Roff", "HS", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

data_force = CSV.File("../data/met_CdP_0506.csv") |> DataFrame

input = Input{Float32}(
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


ebm = EBM{Float32}()

snowdepth = zeros(Float32, length(input.Ta))
SWE = zeros(Float32, length(input.Ta))

run!(ebm, snowdepth, SWE, input)

@testset "complete sim" begin

    err = SWE - data_ref.SWE

    @test maximum(abs.(err)) < 10

    @info maximum(abs.(err))

end
