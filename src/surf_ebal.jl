function surf_ebal(ebm::EBM, Ta, Qa, Ua, Ps, SW, LW)

    Qs = qsat(false, Ps, ebm.Tsurf)

    psi = ebm.gs / (ebm.gs + ebm.CH * Ua)
    if (Qs < Qa || ebm.Sice[1] > 0)
        psi = 1
    end
    Lh = Ls
    if (ebm.Tsurf > Tm)
        Lh = Lc
    end
    rho = Ps / (Rgas * Ta)
    rKH = rho * ebm.CH * Ua

    # Surface energy balance without melt
    D = Lh * Qs / (Rwat * ebm.Tsurf^2)
    Esurf = psi * rKH * (Qs - Qa)
    ebm.Gsurf = 2 * ebm.ksurf * (ebm.Tsurf - ebm.Ts1) / ebm.Dz1

    ebm.Hsurf = cp * rKH * (ebm.Tsurf - Ta)
    ebm.LEsrf = Lh * Esurf
    ebm.Melt = 0
    ebm.Rnet = (1 - ebm.alb) * SW + LW - sb * ebm.Tsurf^4
    dTs = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf) / ((cp + Lh * psi * D) * rKH + 2 * ebm.ksurf / ebm.Dz1 + 4 * sb * ebm.Tsurf^3)
    dE = psi * rKH * D * dTs
    dG = 2 * ebm.ksurf * dTs / ebm.Dz1
    dH = cp * rKH * dTs
    dR = -sb * ebm.Tsurf^3 * dTs

    # Surface melting
    if (ebm.Tsurf + dTs > Tm && ebm.Sice[1] > 0)
        ebm.Melt = sum(ebm.Sice) / ebm.dt
        dTs = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf - Lf * ebm.Melt) / ((cp + Ls * psi * D) * rKH + 2 * ebm.ksurf / ebm.Dz1 + 4 * sb * ebm.Tsurf^3)
        dE = rKH * D * dTs
        dG = 2 * ebm.ksurf * dTs / ebm.Dz1
        dH = cp * rKH * dTs
        if (ebm.Tsurf + dTs < Tm)
            Qs = qsat(false, Ps, Tm)
            Esurf = rKH * (Qs - Qa)
            ebm.Gsurf = 2 * ebm.ksurf * (Tm - ebm.Ts1) / ebm.Dz1
            ebm.Hsurf = cp * rKH * (Tm - Ta)
            ebm.LEsrf = Ls * Esurf
            ebm.Rnet = (1 - ebm.alb) * SW + LW - sb * Tm^4
            ebm.Melt = (ebm.Rnet - ebm.Hsurf - ebm.LEsrf - ebm.Gsurf) / Lf
            ebm.Melt = max(ebm.Melt, 0.)
            dE = 0
            dG = 0
            dH = 0
            dR = 0
            dTs = Tm - ebm.Tsurf
        end
    end

    # Update surface temperature and fluxes
    ebm.Tsurf = ebm.Tsurf + dTs
    Esurf = Esurf + dE
    ebm.Gsurf = ebm.Gsurf + dG
    ebm.Hsurf = ebm.Hsurf + dH
    ebm.Rnet  = ebm.Rnet + dR
    ebm.Esnow = 0
    Esoil = 0
    if (ebm.Sice[1] > 0 || ebm.Tsurf < Tm)
        ebm.Esnow = Esurf
        ebm.LEsrf = Ls * Esurf
    else
        Esoil = Esurf
        ebm.LEsrf = Lc * Esurf
    end

end
