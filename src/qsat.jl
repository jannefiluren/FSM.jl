function qsat(water, P, T, cn::Constants)

    Tc = T - cn.Tm
    if (Tc > 0.0 || water)
        es = cn.e0 * exp(17.5043 * Tc / (241.3 + Tc))
    else
        es = cn.e0 * exp(22.4422 * Tc / (272.186 + Tc))
    end
    Qs = cn.eps * es / P

    return Qs

end
