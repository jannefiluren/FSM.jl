using FSM

cn = Constants{Float64}()

ebm = EBM{Float64}(
    am=1,
    cm=1,
    dm=1,
    em=1,
    hm=1,
)

Ta = 292.3
Ua = 5.0
Ps = 87360.0
SW = 100.0
LW = 100.0
RH = 100.0
Rf = 0.0
Sf = 10.0

Qs = qsat(true, Ps, Ta, cn)
Qa = (RH / 100.0) * Qs

D = Vector{Float64}(undef, ebm.Nsmax)
S = Vector{Float64}(undef, ebm.Nsmax)
W = Vector{Float64}(undef, ebm.Nsmax)

surf_props(ebm, cn, Sf)
surf_exch(ebm, cn, Ta, Ua)
surf_ebal(ebm, cn, Ta, Qa, Ua, Ps, SW, LW)

@code_warntype snow(ebm, cn, Sf, Rf, Ta, D, S, W)

time_snow(ebm, cn, Sf, Rf, Ta, D, S, W) = @time snow(ebm, cn, Sf, Rf, Ta, D, S, W)

time_snow(ebm, cn, Sf, Rf, Ta, D, S, W)
time_snow(ebm, cn, Sf, Rf, Ta, D, S, W)
