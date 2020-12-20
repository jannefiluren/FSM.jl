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

rfs, fsnow, gs, CH, z0, Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet, snowdepth, SWE = run!(ebm)

@testset "surf_props" begin

    @test ebm.albs ≈ 0.799584329 atol = 0.01
    @test rfs ≈ 100.000000 atol = 0.01
    @test ebm.ksnow ≈ [2.66384762E-02, 0.106553905, 0.117475674] atol = 0.01
    @test fsnow ≈ 0.999329329 atol = 0.01
    @test ebm.ksoil ≈ [0.617699385, 0.617699385, 0.617699385, 0.617699385] atol = 0.01
    @test ebm.csoil ≈ [313533.375, 627066.750, 1254133.50, 2508267.00] atol = 1
    @test gs ≈ 9.99999978E-03 atol = 0.01

end

@testset "surf_exch" begin

    @test z0 ≈ 1.00154541E-02 atol = 0.01
    @test CH ≈ 8.34332866E-07 atol = 0.00001

end

@testset "surf_ebal" begin

    @test Esnow ≈ -1.11710710E-10 atol = 0.0001
    @test Gsurf ≈ -1.64053345 atol = 0.0001
    @test Hsurf ≈ -2.08867830E-03 atol = 0.0001
    @test LEsrf ≈ -3.16699850E-04 atol = 0.0001
    @test Melt ≈ 0.00000000 atol = 0.0001
    @test Rnet ≈ -1.64294291 atol = 0.0001

end

@testset "snow" begin

    @test ebm.Sliq ≈ [0.00000000, 0.00000000, 9.68967229E-02] atol = 0.0001
    @test ebm.Sice ≈ [10.0120592, 20.0241184, 113.866928] atol = 0.0001
    @test snowdepth ≈ 1.11644852 atol = 0.01  # not very exact...
    @test SWE ≈ 144.000000 atol = 0.001

end

@testset "soil" begin
    @test ebm.Tsoil ≈ [281.988373, 283.954071, 283.999725, 284.000000] atol = 0.0001
end
