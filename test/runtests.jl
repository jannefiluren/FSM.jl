using Test
using FSM
using CSV
using DataFrames

data_force = CSV.File("../data/met_CdP_0506.csv") |> DataFrame

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

@testset "complete sim" begin

    path_ref = "../fortran/output/"
    files_ref = readdir(path_ref)

    for file_ref in files_ref

        # Initilize model

        ebm = EBM{Float64}(
            am=parse(Int, file_ref[14]),
            cm=parse(Int, file_ref[15]),
            dm=parse(Int, file_ref[16]),
            em=parse(Int, file_ref[17]),
            hm=parse(Int, file_ref[18]),
            zT=1.5,
            zvar=false,
            Tsoil=[282.98, 284.17, 284.70, 284.70]
        )

        cn = Constants{Float64}()

        snowdepth = similar(input.Ta)
        SWE = similar(input.Ta)
        Tsurf = similar(input.Ta)

        # Run model

        run!(ebm, cn, snowdepth, SWE, Tsurf, input)

        # Read reference data

        data_ref = CSV.File(joinpath(path_ref, file_ref), header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

        # Compute error

        println(file_ref)

        err_snowdepth = snowdepth - data_ref.snowdepth
        @test maximum(abs.(err_snowdepth)) < 0.01
        @info maximum(abs.(err_snowdepth))

        err_swe = SWE - data_ref.SWE
        @test maximum(abs.(err_swe)) < 0.01
        @info maximum(abs.(err_swe))

        err_Tsurf = Tsurf - (data_ref.Tsurf .+ 273.15)
        @test maximum(abs.(err_Tsurf)) < 0.01
        @info maximum(abs.(err_Tsurf))

    end

end
