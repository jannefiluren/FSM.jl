struct Input{T}
    year::Vector{Int}
    month::Vector{Int}
    day::Vector{Int}
    hour::Vector{Int}
    SW::Vector{T}
    LW::Vector{T}
    Sf::Vector{T}
    Rf::Vector{T}
    Ta::Vector{T}
    RH::Vector{T}
    Ua::Vector{T}
    Ps::Vector{T}
end


Base.@kwdef mutable struct EBM{T}

    ### Settings ##############################################################

    # Maximum number of snow layers
    Nsmax::Int = 3

    # Number of soil layers
    Nsoil::Int = 4

    # Time step (s)
    dt::T = 3600

    # Minimum snow layer thicknesses (m)
    Dzsnow::Vector{T} = [0.1, 0.2, 0.4]

    # Soil layer thicknesses (m)
    Dzsoil::Vector{T} = [0.1, 0.2, 0.4, 0.8]

    # Temperature measurement height (m)
    zT::T = 2

    # Wind measurement height (m)
    zU::T = 10

    # Subtract snow depth from measurement height
    zvar::Bool = true

    ### Snow parameters #######################################################

    # Maximum albedo for fresh snow
    asmx::T = 0.8

    # Minimum albedo for melting snow
    asmn::T = 0.5

    # Stability slope parameter
    bstb::T = 5

    # Snow thermal conductivity exponent
    bthr::T = 2

    # Snow cover fraction depth scale (m)
    hfsn::T = 0.1

    # Fixed thermal conductivity of snow (W/m/K)
    kfix::T = 0.24

    # Fixed snow density (kg/m^3)
    rho0::T = 300

    # Fresh snow density (kg/m^3)
    rhof::T = 100

    # Maximum density for cold snow (kg/m^3)
    rcld::T = 300

    # Maximum density for melting snow (kg/m^3)
    rmlt::T = 500

    # Snowfall to refresh albedo (kg/m^2)
    Salb::T = 10

    # Albedo decay temperature threshold (C)
    Talb::T = -2

    # Cold snow albedo decay timescale (h)
    tcld::T = 1000

    # Melting snow albedo decay timescale (h)
    tmlt::T = 100

    # Snow compaction time scale (h)
    trho::T = 200

    # Irreducible liquid water content of snow
    Wirr::T = 0.03

    # Snow roughness length (m)
    z0sn::T = 0.01

    ### Surface parameters ####################################################

    # Snow-free ground albedo
    alb0::T = 0.2

    # Surface conductance for saturated soil (m/s)
    gsat::T = 0.01

    # Snow-free roughness length (m)
    z0sf::T = 0.1

    ### Soil properties #######################################################

    # Soil clay fraction
    fcly::T = 0.3

    # Soil sand fraction
    fsnd::T = 0.6

    # Clapp-Hornberger exponent
    b::T = 7.630000000000001

    # Volumetric heat capacity of dry soil (J/K/m^3)
    hcap_soil::T = 2.2993333333333335e6

    # Saturated soil water pressure (m)
    sathh::T = 0.10789467222298288

    # Volumetric soil moisture concentration at saturation
    Vsat::T = 0.4087

    # Volumetric soil moisture concentration at critical point
    Vcrit::T = 0.2603859120641063

    # Thermal conductivity of dry soil (W/m/K)
    hcon_soil::T = 0.2740041303112452

    ### State variables #######################################################

    # Snow albedo
    albs::T = 0.8

    # Snow layer thicknesses (m)
    Ds::Vector{T} = fill(0, Nsmax)

    # Number of snow layers
    Nsnow::Int = 0

    # Ice content of snow layers (kg/m^2)
    Sice::Vector{T} = fill(0, Nsmax)

    # Liquid content of snow layers (kg/m^2)
    Sliq::Vector{T} = fill(0, Nsmax)

    # Volumetric moisture content of soil layers
    theta::Vector{T} = fill(0.5 * Vsat, Nsoil)

    # Snow layer temperatures (K)
    Tsnow::Vector{T} = fill(273.15, Nsmax)

    # Soil layer temperatures (K)
    Tsoil::Vector{T} = fill(285, Nsoil)

    # Surface skin temperature (K)
    Tsurf::T = Tsoil[1]

    ### Configurations ########################################################

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

    ### Internal variables ####################################################

    # Thermal conductivity of snow (W/m/K)
    ksnow::Vector{T} = fill(0, Nsmax)

    # Thermal conductivity of soil (W/m/K)
    ksoil::Vector{T} = fill(0, Nsoil)

    # Areal heat capacity of soil (J/K/m^2)
    csoil::Vector{T} = fill(0, Nsoil)

    # Surface moisture conductance (m/s)
    gs::T = 0

    # Effective albedo
    alb::T = 0

end
