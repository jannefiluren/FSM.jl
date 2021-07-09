function surf_ebal(ebm::EBM, cn::Constants, Ta, Qa, Ua, Ps, SW, LW)

    Qs = qsat(false, Ps, ebm.Tsurf, cn)

    psi = ebm.gs / (ebm.gs + ebm.CH * Ua)
    if (Qs < Qa || ebm.Sice[1] > 0.0)
        psi = 1.0
    end
    Lh = cn.Ls
    if (ebm.Tsurf > cn.Tm)
        Lh = cn.Lc
    end
    rho = Ps / (cn.Rgas * Ta)
    rKH = rho * ebm.CH * Ua

    # Surface energy balance without melt
    D = Lh * Qs / (cn.Rwat * ebm.Tsurf^2.0)
    Esurf = psi * rKH * (Qs - Qa)
    ebm.Gsurf = 2.0 * ebm.ksurf * (ebm.Tsurf - ebm.Ts1) / ebm.Dz1

    ebm.Hsurf = cn.cp * rKH * (ebm.Tsurf - Ta)
    ebm.LEsrf = Lh * Esurf
    ebm.Melt = 0.0
    ebm.Rnet = (1.0 - ebm.alb) * SW + LW - cn.sb * ebm.Tsurf^4.0
    dTs = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf) / ((cn.cp + Lh * psi * D) * rKH + 2 * ebm.ksurf / ebm.Dz1 + 4.0 * cn.sb * ebm.Tsurf^3.0)
    dE = psi * rKH * D * dTs
    dG = 2.0 * ebm.ksurf * dTs / ebm.Dz1
    dH = cn.cp * rKH * dTs
    dR = -cn.sb * ebm.Tsurf^3.0 * dTs

    # Surface melting
    if (ebm.Tsurf + dTs > cn.Tm && ebm.Sice[1] > 0.0)
        ebm.Melt = sum(ebm.Sice) / ebm.dt
        dTs = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf - cn.Lf * ebm.Melt) / ((cn.cp + cn.Ls * psi * D) * rKH + 2.0 * ebm.ksurf / ebm.Dz1 + 4.0 * cn.sb * ebm.Tsurf^3.0)
        dE = rKH * D * dTs
        dG = 2.0 * ebm.ksurf * dTs / ebm.Dz1
        dH = cn.cp * rKH * dTs
        if (ebm.Tsurf + dTs < cn.Tm)
            Qs = qsat(false, Ps, cn.Tm, cn)
            Esurf = rKH * (Qs - Qa)
            ebm.Gsurf = 2.0 * ebm.ksurf * (cn.Tm - ebm.Ts1) / ebm.Dz1
            ebm.Hsurf = cn.cp * rKH * (cn.Tm - Ta)
            ebm.LEsrf = cn.Ls * Esurf
            ebm.Rnet = (1.0 - ebm.alb) * SW + LW - cn.sb * cn.Tm^4.0
            ebm.Melt = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf) / cn.Lf
            ebm.Melt = max(ebm.Melt, 0.0)
            dE = 0.0
            dG = 0.0
            dH = 0.0
            dR = 0.0
            dTs = cn.Tm - ebm.Tsurf
        end
    end

    # Update surface temperature and fluxes
    ebm.Tsurf = ebm.Tsurf + dTs
    Esurf = Esurf + dE
    ebm.Gsurf = ebm.Gsurf + dG
    ebm.Hsurf = ebm.Hsurf + dH
    ebm.Rnet  = ebm.Rnet + dR
    ebm.Esnow = 0.0
    Esoil = 0.0
    if (ebm.Sice[1] > 0.0 || ebm.Tsurf < cn.Tm)
        ebm.Esnow = Esurf
        ebm.LEsrf = cn.Ls * Esurf
    else
        Esoil = Esurf
        ebm.LEsrf = cn.Lc * Esurf
    end

    return nothing

end
