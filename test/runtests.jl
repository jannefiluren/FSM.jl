using FSM
using Test


albs = 0.8
Ds = [0.1, 0.1, 0.2]
Nsnow = 3
Sice = [10.0, 20.0, 42.0]
Sliq = [0.0, 0.0, 0.0]
theta = [0.2, 0.2, 0.2, 0.2]
Tsnow = [273.15, 273.15, 273.15]
Tsoil = [282.0, 284.0, 284.0, 284.0]
Tsurf = 275.0

ebm = EBM(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)

rfs, fsnow = run!(ebm)

@testset "FSM.jl" begin

    @test ebm.albs ≈ 0.799584329 atol = 0.01
    @test rfs ≈ 100.000000 atol = 0.01
    @test ebm.ksnow ≈ [2.66384762E-02, 0.106553905, 0.117475674] atol = 0.01
    @test fsnow ≈ 0.999329329 atol = 0.01
    @test ebm.ksoil ≈ [0.617699385, 0.617699385, 0.617699385, 0.617699385] atol = 0.01
    @test ebm.csoil ≈ [313533.375, 627066.750, 1254133.50, 2508267.00] atol = 1



end
