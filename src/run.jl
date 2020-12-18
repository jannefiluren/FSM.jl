function run!(ebm::EBM)

    year = 2005
    month = 10
    day = 1
    hour = 0
    SW = 0.0
    LW = 300.0
    Sf = 0.02
    Rf = 0.0
    Ta = 273.8
    RH = 78.2
    Ua = 0.6
    Ps = 87480.0

    rfs, fsnow, z0 = surf_props(ebm, Sf)

    for i in 1:6
        CH, z0 = surf_exch(ebm, Ta, Ua, z0)
    end



    return rfs, fsnow

end
