mutable struct EBM

    # Settings
    Nsmax               # Maximum number of snow layers
    Nsoil               # Number of soil layers
    dt                  # Time step (s)
    Dzsnow              # Minimum snow layer thicknesses (m)
    Dzsoil              # Soil layer thicknesses (m)


    # State variables
    albs                # Snow albedo
    Ds                  # Snow layer thicknesses (m)
    Nsnow               # Number of snow layers
    Sice                # Ice content of snow layers (kg/m^2)
    Sliq                # Liquid content of snow layers (kg/m^2)
    theta               # Volumetric moisture content of soil layers
    Tsnow               # Snow layer temperatures (K)
    Tsoil               # Soil layer temperatures (K)
    Tsurf               # Surface skin temperature (K)

    # Snow parameters
    asmx                # Maximum albedo for fresh snow
    asmn                # Minimum albedo for melting snow
    bstb                # Stability slope parameter
    bthr                # Snow thermal conductivity exponent
    hfsn                # Snow cover fraction depth scale (m)
    kfix                # Fixed thermal conductivity of snow (W/m/K)
    rho0                # Fixed snow density (kg/m^3)
    rhof                # Fresh snow density (kg/m^3)
    rcld                # Maximum density for cold snow (kg/m^3)
    rmlt                # Maximum density for melting snow (kg/m^3)
    Salb                # Snowfall to refresh albedo (kg/m^2)
    Talb                # Albedo decay temperature threshold (C)
    tcld                # Cold snow albedo decay timescale (h)
    tmlt                # Melting snow albedo decay timescale (h)
    trho                # Snow compaction time scale (h)
    Wirr                # Irreducible liquid water content of snow
    z0sn                # Snow roughness length (m)

    # Surface parameters
    alb0                # Snow-free ground albedo
    gsat                # Surface conductance for saturated soil (m/s)
    z0sf                # Snow-free roughness length (m)

    # Soil properties
    b                   # Clapp-Hornberger exponent
    fcly                # Soil clay fraction
    fsnd                # Soil sand fraction
    hcap_soil           # Volumetric heat capacity of dry soil (J/K/m^3)
    hcon_soil           # Thermal conductivity of dry soil (W/m/K)
    sathh               # Saturated soil water pressure (m)
    Vcrit               # Volumetric soil moisture concentration at critical point
    Vsat                # Volumetric soil moisture concentration at saturation

    # Configurations
    am                  # Snow albedo model
    cm                  # Snow conductivity model
    dm                  # Snow density model
    em                  # Surface exchange model
    hm                  # Snow hydraulics model

    # Other stuff

    ksnow
    ksoil
    csoil

    function EBM(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)

        Nsmax = 3
        Nsoil = 4
        dt = 3600.0
        Dzsnow = [0.1, 0.2, 0.4]
        Dzsoil = [0.1, 0.2, 0.4, 0.8]

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
