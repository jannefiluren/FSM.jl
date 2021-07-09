using FSM
# using Traceur
# using BenchmarkTools

cn = Constants{Float64}()

Ps  = 87360.0
Ta = 292.3

water = true

@code_warntype qsat(water, Ps, Ta, cn)

time_qsat(water, Ps, Ta, cn) = @time qsat(water, Ps, Ta, cn)

time_qsat(water, Ps, Ta, cn)
time_qsat(water, Ps, Ta, cn)
