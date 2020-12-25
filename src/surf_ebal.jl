function surf_ebal(ebm::EBM, CH, ksurf, Ts1, Dz1, alb, Ta, Qa, Ua, Ps, SW, LW)

    Qs = qsat(false, Ps, ebm.Tsurf)

    psi = ebm.gs / (ebm.gs + CH * Ua)
    if (Qs < Qa || ebm.Sice[1] > 0)
        psi = 1
    end
    Lh = Ls
    if (ebm.Tsurf > Tm)
        Lh = Lc
    end
    rho = Ps / (Rgas * Ta)
    rKH = rho * CH * Ua

    # Surface energy balance without melt
    D = Lh * Qs / (Rwat * ebm.Tsurf^2)
    Esurf = psi * rKH * (Qs - Qa)
    Gsurf = 2 * ksurf * (ebm.Tsurf - Ts1) / Dz1

    Hsurf = cp * rKH * (ebm.Tsurf - Ta)
    LEsrf = Lh * Esurf
    Melt = 0
    Rnet = (1 - alb) * SW + LW - sb * ebm.Tsurf^4
    dTs = (Rnet - Hsurf - LEsrf - Gsurf) / ((cp + Lh * psi * D) * rKH + 2 * ksurf / Dz1 + 4 * sb * ebm.Tsurf^3)
    dE = psi * rKH * D * dTs
    dG = 2 * ksurf * dTs / Dz1
    dH = cp * rKH * dTs
    dR = -sb * ebm.Tsurf^3 * dTs

    # Surface melting
    if (ebm.Tsurf + dTs > Tm && ebm.Sice[1] > 0)
        Melt = sum(ebm.Sice) / ebm.dt
        dTs = (Rnet - Hsurf - LEsrf - Gsurf - Lf * Melt) / ((cp + Ls * psi * D) * rKH + 2 * ksurf / Dz1 + 4 * sb * ebm.Tsurf^3)
        dE = rKH * D * dTs
        dG = 2 * ksurf * dTs / Dz1
        dH = cp * rKH * dTs
        if (ebm.Tsurf + dTs < Tm)
            Qs = qsat(false, Ps, Tm)
            Esurf = rKH * (Qs - Qa)
            Gsurf = 2 * ksurf * (Tm - Ts1) / Dz1
            Hsurf = cp * rKH * (Tm - Ta)
            LEsrf = Ls * Esurf
            Rnet = (1 - alb) * SW + LW - sb * Tm^4
            Melt = (Rnet - Hsurf - LEsrf - Gsurf) / Lf
            Melt = max(Melt, 0.)
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
    Gsurf = Gsurf + dG
    Hsurf = Hsurf + dH
    Rnet  = Rnet + dR
    Esnow = 0
    Esoil = 0
    if (ebm.Sice[1] > 0 || ebm.Tsurf < Tm)
        Esnow = Esurf
        LEsrf = Ls * Esurf
    else
        Esoil = Esurf
        LEsrf = Lc * Esurf
    end

    return Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet
end
