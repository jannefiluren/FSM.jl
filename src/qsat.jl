function qsat(water, P, T)

    Tc = T - Tm
    if (Tc > 0.0 || water)
        es = e0 * exp(17.5043 * Tc / (241.3 + Tc))
    else
        es = e0 * exp(22.4422 * Tc / (272.186 + Tc))
    end
    Qs = epsm * es / P

    return Qs

end
