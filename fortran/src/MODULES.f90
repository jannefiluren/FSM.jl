!-----------------------------------------------------------------------
! Physical constants
!-----------------------------------------------------------------------
module CONSTANTS

use, intrinsic :: iso_fortran_env, only: dp=>real64

real*8, parameter :: &
  cp = 1005_dp,         &! Specific heat capacity of dry air (J/K/kg)
  eps = 0.622_dp,       &! Ratio of molecular weights of water and dry air
  e0 = 611.213_dp,      &! Saturation vapour pressure at Tm (Pa)
  g = 9.81_dp,          &! Acceleration due to gravity (m/s^2)
  hcap_ice = 2100._dp,  &! Specific heat capacity of ice (J/K/kg)
  hcap_wat = 4180._dp,  &! Specific heat capacity of water (J/K/kg)
  hcon_air = 0.025_dp,  &! Thermal conductivity of air (W/m/K)
  hcon_clay = 1.16_dp,  &! Thermal conductivity of clay (W/m/K)
  hcon_ice = 2.24_dp,   &! Thermal conducivity of ice (W/m/K)
  hcon_sand = 1.57_dp,  &! Thermal conductivity of sand (W/m/K)
  hcon_wat = 0.56_dp,   &! Thermal conductivity of water (W/m/K)
  Lc = 2.501e6_dp,      &! Latent heat of condensation (J/kg)
  Lf = 0.334e6_dp,      &! Latent heat of fusion (J/kg)
  Ls = Lc + Lf,         &! Latent heat of sublimation (J/kg)
  R = 8.3145_dp,        &! Universal gas constant (J/K/mol)
  Rgas = 287_dp,        &! Gas constant for dry air (J/K/kg)
  Rwat = 462_dp,        &! Gas constant for water vapour (J/K/kg)
  rho_ice = 917._dp,    &! Density of ice (kg/m^3)
  rho_wat = 1000._dp,   &! Density of water (kg/m^3)
  sb = 5.67e-8_dp,      &! Stefan-Boltzmann constant (W/m^2/K^4)
  Tm = 273.15_dp,       &! Melting point (K)
  vkman = 0.4_dp         ! Von Karman constant
end module CONSTANTS

!-----------------------------------------------------------------------
! Daily diagnostics
!-----------------------------------------------------------------------
module DIAGNOSTICS
integer :: &
  Nave                ! Number of timesteps in average outputs
real*8 :: &
  diags(5),          &! Cumulated diagnostics
  SWint,             &! Cumulated incoming solar radiation (J/m^2)
  SWout               ! Cumulated reflected solar radiation (J/m^2)
end module DIAGNOSTICS

!-----------------------------------------------------------------------
! Meteorological driving variables
!-----------------------------------------------------------------------
module DRIVING
integer :: &
  year,              &! Year
  month,             &! Month of year
  day                 ! Day of month
logical :: &
  SnowMIP,           &! Read driving data in ESM-SnowMIP format
  zvar                ! Subtract snow depth from measurement height
real*8 :: &
  dt,                &! Timestep (s)
  hour,              &! Hour of day
  zT,                &! Temperature measurement height (m)
  zU                  ! Wind speed measurement height (m)
real*8 :: &
  LW,                &! Incoming longwave radiation (W/m^2)
  Ps,                &! Surface pressure (Pa)
  Qa,                &! Specific humidity (kg/kg)
  Rf,                &! Rainfall rate (kg/m^2/s)
  Sf,                &! Snowfall rate (kg/m^2/s)
  SW,                &! Incoming shortwave radiation (W/m^2)
  Ta,                &! Air temperature (K)
  Ua                  ! Wind speed (m/s)
end module DRIVING

!-----------------------------------------------------------------------
! Grid descriptors
!-----------------------------------------------------------------------
module GRID
integer, parameter :: &
  Nsmax = 3,         &! Maximum number of snow layers
  Nsoil = 4           ! Number of soil layers
real*8 :: &
  Dzsnow(Nsmax),     &! Minimum snow layer thicknesses (m)
  Dzsoil(Nsoil)       ! Soil layer thicknesses (m)
data Dzsnow / 0.1, 0.2, 0.4 /
data Dzsoil / 0.1, 0.2, 0.4, 0.8 /
end module GRID

!-----------------------------------------------------------------------
! Input / output unit numbers
!-----------------------------------------------------------------------
module IOUNITS
integer, parameter :: &
  udmp = 11,         &! Dump file unit number
  umet = 21,         &! Driving file unit number
  uout = 31,         &! Output file unit number
  ustr = 41           ! Start file unit number
end module IOUNITS

!-----------------------------------------------------------------------
! Model options
!-----------------------------------------------------------------------
module MODELS
integer :: &
  am,                &! Snow albedo model        0 - diagnostic
                      !                          1 - prognostic
  cm,                &! Snow conductivity model  0 - fixed
                      !                          1 - density function
  dm,                &! Snow density model       0 - fixed
                      !                          1 - prognostic
  em,                &! Surface exchange model   0 - fixed
                      !                          1 - stability correction
  hm                  ! Snow hydraulics model    0 - free draining
                      !                          1 - bucket storage
end module MODELS

!-----------------------------------------------------------------------
! Model parameters
!-----------------------------------------------------------------------
module PARAMETERS
! Snow parameters
real*8 :: &
  asmx,              &! Maximum albedo for fresh snow
  asmn,              &! Minimum albedo for melting snow
  bstb,              &! Stability slope parameter
  bthr,              &! Snow thermal conductivity exponent
  hfsn,              &! Snow cover fraction depth scale (m)
  kfix,              &! Fixed thermal conductivity of snow (W/m/K)
  rho0,              &! Fixed snow density (kg/m^3)
  rhof,              &! Fresh snow density (kg/m^3)
  rcld,              &! Maximum density for cold snow (kg/m^3)
  rmlt,              &! Maximum density for melting snow (kg/m^3)
  Salb,              &! Snowfall to refresh albedo (kg/m^2)
  Talb,              &! Albedo decay temperature threshold (C)
  tcld,              &! Cold snow albedo decay timescale (h)
  tmlt,              &! Melting snow albedo decay timescale (h)
  trho,              &! Snow compaction time scale (h)
  Wirr,              &! Irreducible liquid water content of snow
  z0sn                ! Snow roughness length (m)
! Surface parameters
real*8 :: &
  alb0,              &! Snow-free ground albedo
  gsat,              &! Surface conductance for saturated soil (m/s)
  z0sf                ! Snow-free roughness length (m)
end module PARAMETERS

!-----------------------------------------------------------------------
! Soil properties
!-----------------------------------------------------------------------
module SOIL_PARAMS
real*8 :: &
  b,                 &! Clapp-Hornberger exponent
  fcly,              &! Soil clay fraction
  fsnd,              &! Soil sand fraction
  hcap_soil,         &! Volumetric heat capacity of dry soil (J/K/m^3)
  hcon_soil,         &! Thermal conductivity of dry soil (W/m/K)
  sathh,             &! Saturated soil water pressure (m)
  Vcrit,             &! Volumetric soil moisture concentration at critical point
  Vsat                ! Volumetric soil moisture concentration at saturation
end module SOIL_PARAMS

!-----------------------------------------------------------------------
! Model state variables
!-----------------------------------------------------------------------
module STATE_VARIABLES
use GRID, only : &
  Nsmax,             &! Maximum number of snow layers
  Nsoil               ! Number of soil layers
! Surface state variables
real*8 :: &
  Tsurf               ! Surface skin temperature (K)
! Snow state variables
integer :: &
  Nsnow               ! Number of snow layers
real*8 :: &
  albs,              &! Snow albedo
  Ds(Nsmax),         &! Snow layer thicknesses (m)
  Sice(Nsmax),       &! Ice content of snow layers (kg/m^2)
  Sliq(Nsmax),       &! Liquid content of snow layers (kg/m^2)
  Tsnow(Nsmax)        ! Snow layer temperatures (K)
! Soil state variables
real*8 :: &
  theta(Nsoil),      &! Volumetric moisture content of soil layers
  Tsoil(Nsoil)        ! Soil layer temperatures (K)
end module STATE_VARIABLES
