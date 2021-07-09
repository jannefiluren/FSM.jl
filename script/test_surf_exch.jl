using FSM

cn = Constants{Float64}()

ebm = EBM{Float64}(
    am=1,
    cm=1,
    dm=1,
    em=1,
    hm=1,
)

Ua = 5.0
Ta = 292.3

@code_warntype surf_exch(ebm, cn, Ta, Ua)

time_surf_exch(ebm, cn, Ta, Ua) = @time surf_exch(ebm, cn, Ta, Ua)

time_surf_exch(ebm, cn, Ta, Ua)
time_surf_exch(ebm, cn, Ta, Ua)
