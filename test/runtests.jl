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

rfs, fsnow, gs, CH, z0, Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet = run!(ebm)

@testset "FSM.jl" begin

    @test ebm.albs ≈ 0.799584329 atol = 0.01
    @test rfs ≈ 100.000000 atol = 0.01
    @test ebm.ksnow ≈ [2.66384762E-02, 0.106553905, 0.117475674] atol = 0.01
    @test fsnow ≈ 0.999329329 atol = 0.01
    @test ebm.ksoil ≈ [0.617699385, 0.617699385, 0.617699385, 0.617699385] atol = 0.01
    @test ebm.csoil ≈ [313533.375, 627066.750, 1254133.50, 2508267.00] atol = 1

end

@testset "surf_props" begin

    @test gs ≈ 9.99999978E-03 atol = 0.01

end

@testset "surf_exch" begin

    @test z0 ≈ 1.00154541E-02 atol = 0.01
    @test CH ≈ 1.86191276E-02 atol = 0.00001

end

@testset "surf_ebal" begin

    @test Esnow ≈ 4.57266378E-06 atol = 0.0001
    @test Gsurf ≈ -0.566179335 atol = 0.0001
    @test Hsurf ≈ -21.4068260 atol = 0.0001
    @test LEsrf ≈ 12.9635019 atol = 0.0001
    @test Melt ≈ 0.00000000 atol = 0.0001
    @test Rnet ≈ -20.8406448 atol = 0.0001

end
