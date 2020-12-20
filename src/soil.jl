function soil(ebm::EBM, Gsoil)

    a = zeros(ebm.Nsoil)  ##### hack
    b = zeros(ebm.Nsoil)  ##### hack
    c = zeros(ebm.Nsoil)  ##### hack
    Gs = zeros(ebm.Nsoil)  ##### hack
    rhs = zeros(ebm.Nsoil)  ##### hack
    dTs = zeros(ebm.Nsoil)  ##### hack

    for k = 1:(ebm.Nsoil - 1)
        Gs[k] = 2 / (ebm.Dzsoil[k] / ebm.ksoil[k] + ebm.Dzsoil[k + 1] / ebm.ksoil[k + 1])
    end
    a[1] = 0
    b[1] = ebm.csoil[1] + Gs[1] * ebm.dt
    c[1] = - Gs[1] * ebm.dt
    rhs[1] = (Gsoil - Gs[1] * (ebm.Tsoil[1] - ebm.Tsoil[2])) * ebm.dt
    for k = 2:(ebm.Nsoil - 1)
        a[k] = c[k - 1]
        b[k] = ebm.csoil[k] + (Gs[k - 1] + Gs[k]) * ebm.dt
        c[k] = - Gs[k] * ebm.dt
        rhs[k] = Gs[k - 1] * (ebm.Tsoil[k - 1] - ebm.Tsoil[k]) * ebm.dt + Gs[k] * (ebm.Tsoil[k + 1] - ebm.Tsoil[k]) * ebm.dt
    end
    k = ebm.Nsoil
    Gs[k] = ebm.ksoil[k] / ebm.Dzsoil[k]
    a[k] = c[k - 1]
    b[k] = ebm.csoil[k] + (Gs[k - 1] + Gs[k]) * ebm.dt
    c[k] = 0
    rhs[k] = Gs[k - 1] * (ebm.Tsoil[k - 1] - ebm.Tsoil[k]) * ebm.dt
    tridiag(ebm.Nsoil, ebm.Nsoil, a, b, c, rhs, dTs)
    for k = 1:ebm.Nsoil
        ebm.Tsoil[k] = ebm.Tsoil[k] + dTs[k]
    end

end
