function run!(ebm::EBM)

    year = 2005
    month = 10
    day = 1
    hour = 0
    SW::Float32 = 0.0
    LW::Float32 = 300.0
    Sf::Float32 = 0.02
    Rf::Float32 = 0.0
    Ta::Float32 = 273.8
    RH::Float32 = 78.2
    Ua::Float32 = 0.6
    Ps::Float32 = 87480.0

    Qs = qsat(true, Ps, Ta)
    Qa = (RH / 100) * Qs

    @show Qa

    rfs, fsnow, z0, gs, ksurf, Ts1, Dz1, alb = surf_props(ebm, Sf)

    # for i in 1:6
    CH, z0 = surf_exch(ebm, Ta, Ua, z0)
    Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet = surf_ebal(ebm, CH, gs, ksurf, Ts1, Dz1, alb, Ta, Qa, Ua, Ps, SW, LW)

    # end



    return rfs, fsnow, gs, CH, z0, Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet

end
