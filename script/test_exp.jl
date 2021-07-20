const file  = joinpath(dirname(@__FILE__), "..", "fortran", "FSM.so")

function exp_fortran(val)

    res = ccall((:exp, file), Float64, (Float64,), val)

    return res

end

val = -10.0000001

val_julia = exp(val)

val_fortran = exp_fortran(val)

val_fortran - val_julia
