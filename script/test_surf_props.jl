using FSM

cn = Constants{Float64}()

ebm = EBM{Float64}(
    am=1,
    cm=1,
    dm=1,
    em=1,
    hm=1,
)

Sf = 1.0

@code_warntype surf_props(ebm, cn, Sf)

time_surf_props(ebm, cn, Sf) = @time surf_props(ebm, cn, Sf)

time_surf_props(ebm, cn, Sf)
time_surf_props(ebm, cn, Sf)
