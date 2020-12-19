mutable struct EBM

    # Settings
    Nsmax::Int               # Maximum number of snow layers
    Nsoil::Int               # Number of soil layers
    dt::Float32                  # Time step (s)
    Dzsnow::Vector{Float32}              # Minimum snow layer thicknesses (m)
    Dzsoil::Vector{Float32}              # Soil layer thicknesses (m)
    zT::Float32                  # Temperature measurement height (m)
    zU::Float32                  # Wind measurement height (m)
    zvar::Bool                # Subtract snow depth from measurement height


    # State variables
    albs::Float32                # Snow albedo
    Ds::Vector{Float32}                  # Snow layer thicknesses (m)
    Nsnow::Int               # Number of snow layers
    Sice::Vector{Float32}                # Ice content of snow layers (kg/m^2)
    Sliq::Vector{Float32}                # Liquid content of snow layers (kg/m^2)
    theta::Vector{Float32}               # Volumetric moisture content of soil layers
    Tsnow::Vector{Float32}               # Snow layer temperatures (K)
    Tsoil::Vector{Float32}               # Soil layer temperatures (K)
    Tsurf::Float32               # Surface skin temperature (K)

    # Snow parameters
    asmx::Float32                # Maximum albedo for fresh snow
    asmn::Float32                # Minimum albedo for melting snow
    bstb::Float32                # Stability slope parameter
    bthr::Float32                # Snow thermal conductivity exponent
    hfsn::Float32                # Snow cover fraction depth scale (m)
    kfix::Float32                # Fixed thermal conductivity of snow (W/m/K)
    rho0::Float32                # Fixed snow density (kg/m^3)
    rhof::Float32                # Fresh snow density (kg/m^3)
    rcld::Float32                # Maximum density for cold snow (kg/m^3)
    rmlt::Float32                # Maximum density for melting snow (kg/m^3)
    Salb::Float32                # Snowfall to refresh albedo (kg/m^2)
    Talb::Float32                # Albedo decay temperature threshold (C)
    tcld::Float32                # Cold snow albedo decay timescale (h)
    tmlt::Float32                # Melting snow albedo decay timescale (h)
    trho::Float32                # Snow compaction time scale (h)
    Wirr::Float32                # Irreducible liquid water content of snow
    z0sn::Float32                # Snow roughness length (m)

    # Surface parameters
    alb0::Float32                # Snow-free ground albedo
    gsat::Float32                # Surface conductance for saturated soil (m/s)
    z0sf::Float32                # Snow-free roughness length (m)

    # Soil properties
    b::Float32                   # Clapp-Hornberger exponent
    fcly::Float32                # Soil clay fraction
    fsnd::Float32                # Soil sand fraction
    hcap_soil::Float32           # Volumetric heat capacity of dry soil (J/K/m^3)
    hcon_soil::Float32           # Thermal conductivity of dry soil (W/m/K)
    sathh::Float32               # Saturated soil water pressure (m)
    Vcrit::Float32               # Volumetric soil moisture concentration at critical point
    Vsat::Float32               # Volumetric soil moisture concentration at saturation

    # Configurations
    am::Int                  # Snow albedo model
    cm::Int                  # Snow conductivity model
    dm::Int                  # Snow density model
    em::Int                  # Surface exchange model
    hm::Int                  # Snow hydraulics model

    # Other stuff

    ksnow::Vector{Float32}
    ksoil::Vector{Float32}
    csoil::Vector{Float32}

    function EBM(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)

        Nsmax = 3
        Nsoil = 4
        dt = 3600.0
        Dzsnow = [0.1, 0.2, 0.4]
        Dzsoil = [0.1, 0.2, 0.4, 0.8]
        zT = 2
        zU = 10
        zvar = true

        #= albs = 0.0
        Ds = fill(0.0, Nsmax)
        Nsnow = 0
        Sice = fill(0.0, Nsmax)
        Sliq = fill(0.0, Nsmax)
        theta = fill(0.0, Nsoil)
        Tsnow = fill(273.15, Nsmax)
        Tsoil = fill(273.15, Nsmax)
        Tsurf = 273.15 =#

        asmx = 0.8
        asmn = 0.5
        bstb = 5
        bthr = 2
        hfsn = 0.1
        kfix = 0.24
        rho0 = 300
        rhof = 100
        rcld = 300
        rmlt = 500
        Salb = 10
        Talb = -2
        tcld = 1000
        tmlt = 100
        trho = 200
        Wirr = 0.03
        z0sn = 0.01

        alb0 = 0.2
        gsat = 0.01
        z0sf = 0.1

        fcly = 0.3
        fsnd = 0.6

        if (fcly + fsnd > 1)
            fcly = 1 - fsnd
        end

        b = 3.1 + 15.7 * fcly - 0.3 * fsnd
        hcap_soil = (2.128 * fcly + 2.385 * fsnd) * 1E6 / (fcly + fsnd)
        sathh = 10^(0.17 - 0.63 * fcly - 1.58 * fsnd)
        Vsat = 0.505 - 0.037 * fcly - 0.142 * fsnd
        Vcrit = Vsat * (sathh / 3.364)^(1 / b)
        hcon_min = (hcon_clay^fcly) * (hcon_sand^(1 - fcly))
        hcon_soil = (hcon_air^Vsat) * (hcon_min^(1 - Vsat))

        ksnow = fill(0.0, Nsmax)
        ksoil = fill(0.0, Nsoil)
        csoil = fill(0.0, Nsoil)

        am = 1
        cm = 1
        dm = 1
        em = 1
        hm = 1

        new(Nsmax,
            Nsoil,
            dt,
            Dzsnow,
            Dzsoil,
            zT,
            zU,
            zvar,
            albs,
            Ds,
            Nsnow,
            Sice,
            Sliq,
            theta,
            Tsnow,
            Tsoil,
            Tsurf,
            asmx,
            asmn,
            bstb,
            bthr,
            hfsn,
            kfix,
            rho0,
            rhof,
            rcld,
            rmlt,
            Salb,
            Talb,
            tcld,
            tmlt,
            trho,
            Wirr,
            z0sn,
            alb0,
            gsat,
            z0sf,
            b,
            fcly,
            fsnd,
            hcap_soil,
            hcon_soil,
            sathh,
            Vcrit,
            Vsat,
            am,
            cm,
            dm,
            em,
            hm,
            ksnow,
            ksoil,
            csoil)
    end

end
