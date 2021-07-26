using FSM

ebm = EBM{Float64}(
    am=1,
    cm=1,
    dm=1,
    em=1,
    hm=1,
)

@code_warntype soil(ebm)

time_soil(ebm) = @time soil(ebm)

time_soil(ebm)
time_soil(ebm)
