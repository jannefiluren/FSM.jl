struct Input
    year::Vector{Int}
    month::Vector{Int}
    day::Vector{Int}
    hour::Vector{Int}
    SW::Vector{Float32}
    LW::Vector{Float32}
    Sf::Vector{Float32}
    Rf::Vector{Float32}
    Ta::Vector{Float32}
    RH::Vector{Float32}
    Ua::Vector{Float32}
    Ps::Vector{Float32}
end


Base.@kwdef mutable struct EBM

    ### Settings #################################################

    # Maximum number of snow layers
    Nsmax::Int = 3

    # Number of soil layers
    Nsoil::Int = 4

    # Time step (s)
    dt::Float32 = 3600

    # Minimum snow layer thicknesses (m)
    Dzsnow::Vector{Float32} = [0.1, 0.2, 0.4]

    # Soil layer thicknesses (m)
    Dzsoil::Vector{Float32} = [0.1, 0.2, 0.4, 0.8]

    # Temperature measurement height (m)
    zT::Float32 = 2

    # Wind measurement height (m)
    zU::Float32 = 10

    # Subtract snow depth from measurement height
    zvar::Bool = true

    ### Snow parameters #################################################

    # Maximum albedo for fresh snow
    asmx::Float32 = 0.8

    # Minimum albedo for melting snow
    asmn::Float32 = 0.5

    # Stability slope parameter
    bstb::Float32 = 5

    # Snow thermal conductivity exponent
    bthr::Float32 = 2

    # Snow cover fraction depth scale (m)
    hfsn::Float32 = 0.1

    # Fixed thermal conductivity of snow (W/m/K)
    kfix::Float32 = 0.24

    # Fixed snow density (kg/m^3)
    rho0::Float32 = 300

    # Fresh snow density (kg/m^3)
    rhof::Float32 = 100

    # Maximum density for cold snow (kg/m^3)
    rcld::Float32 = 300

    # Maximum density for melting snow (kg/m^3)
    rmlt::Float32 = 500

    # Snowfall to refresh albedo (kg/m^2)
    Salb::Float32 = 10

    # Albedo decay temperature threshold (C)
    Talb::Float32 = -2

    # Cold snow albedo decay timescale (h)
    tcld::Float32 = 1000

    # Melting snow albedo decay timescale (h)
    tmlt::Float32 = 100

    # Snow compaction time scale (h)
    trho::Float32 = 200

    # Irreducible liquid water content of snow
    Wirr::Float32 = 0.03

    # Snow roughness length (m)
    z0sn::Float32 = 0.01

    ### Surface parameters #################################################

    # Snow-free ground albedo
    alb0::Float32 = 0.2

    # Surface conductance for saturated soil (m/s)
    gsat::Float32 = 0.01

    # Snow-free roughness length (m)
    z0sf::Float32 = 0.1

    ### Soil properties #################################################

    # Soil clay fraction
    fcly::Float32 = 0.3

    # Soil sand fraction
    fsnd::Float32 = 0.6

    # Clapp-Hornberger exponent
    b::Float32 = 7.630000000000001

    # Volumetric heat capacity of dry soil (J/K/m^3)
    hcap_soil::Float32 = 2.2993333333333335e6

    # Saturated soil water pressure (m)
    sathh::Float32 = 0.10789467222298288

    # Volumetric soil moisture concentration at saturation
    Vsat::Float32 = 0.4087

    # Volumetric soil moisture concentration at critical point
    Vcrit::Float32 = 0.2603859120641063

    # Thermal conductivity of dry soil (W/m/K)
    hcon_soil::Float32 = 0.2740041303112452

    ### State variables #################################################

    # Snow albedo
    albs::Float32 = 0.8

    # Snow layer thicknesses (m)
    Ds::Vector{Float32} = fill(0, Nsmax)

    # Number of snow layers
    Nsnow::Int = 0

    # Ice content of snow layers (kg/m^2)
    Sice::Vector{Float32} = fill(0, Nsmax)

    # Liquid content of snow layers (kg/m^2)
    Sliq::Vector{Float32} = fill(0, Nsmax)

    # Volumetric moisture content of soil layers
    theta::Vector{Float32} = fill(0.5 * Vsat, Nsoil)

    # Snow layer temperatures (K)
    Tsnow::Vector{Float32} = fill(273.15, Nsmax)

    # Soil layer temperatures (K)
    Tsoil::Vector{Float32} = fill(285, Nsoil)

    # Surface skin temperature (K)
    Tsurf::Float32 = Tsoil[1]

    ### Configurations #################################################

    # Snow albedo model
    am::Int = 0

    # Snow conductivity model
    cm::Int = 0

    # Snow density model
    dm::Int = 0

    # Surface exchange model
    em::Int = 0

    # Snow hydraulics model
    hm::Int = 0

    ### Other stuff #################################################

    ksnow::Vector{Float32} = fill(0, Nsmax)
    ksoil::Vector{Float32} = fill(0, Nsoil)
    csoil::Vector{Float32} = fill(0, Nsoil)

end
