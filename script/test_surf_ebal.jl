using FSM

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

Qs = qsat(true, Ps, Ta)
Qa = (RH / 100.0) * Qs

surf_props(ebm, Sf)
surf_exch(ebm, Ta, Ua)

surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)

@code_warntype surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)

time_surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW) = @time surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)

time_surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)
time_surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)
