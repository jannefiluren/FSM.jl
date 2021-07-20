using FSM

cn = Constants{Float64}()

Ps  = 70000.0
Ta = 262.3

water = true

# @code_warntype qsat(water, Ps, Ta, cn)

# time_qsat(water, Ps, Ta, cn) = @time qsat(water, Ps, Ta, cn)

# time_qsat(water, Ps, Ta, cn)
# time_qsat(water, Ps, Ta, cn)

const file  = joinpath(dirname(@__FILE__), "..", "fortran", "FSM.so")

Qs_fortran = Ref{Float64}()

ccall((:qsat_, file), Cvoid, (Ref{Int32}, Ref{Float64}, Ref{Float64}, Ref{Float64}), convert(Int32, water), Ps, Ta, Qs_fortran)

Qs_julia = qsat(water, Ps, Ta, cn)

Qs_fortran[] - Qs_julia
