function surf_props(ebm::EBM, Sf)

    gs = 0  # TODO: Fix later if possible... perhaps remove from here...

    # Snow albedo

    if ebm.am == 0  # Diagnosed snow albedo
        ebm.albs = ebm.asmn + (ebm.asmx - ebm.asmn) * (ebm.Tsurf - Tm) / ebm.Talb
    elseif ebm.am == 1  # Prognostic snow albedo
        tau = 3600 * ebm.tcld
        if (ebm.Tsurf >= Tm)
            tau = 3600 * ebm.tmlt
        end
        rt = 1 / tau + Sf / ebm.Salb
        alim = (ebm.asmn / tau + Sf * ebm.asmx / ebm.Salb) / rt
        albs = alim + (ebm.albs - alim) * exp(-rt * ebm.dt)
    end

    if (ebm.albs < min(ebm.asmx, ebm.asmn))
        ebm.albs = min(ebm.asmx, ebm.asmn)
    end

    if (ebm.albs > max(ebm.asmx, ebm.asmn))
        ebm.albs = max(ebm.asmx, ebm.asmn)
    end

    # Density of fresh snow

    if (ebm.dm == 0)
        rfs = ebm.rho0
    elseif (ebm.dm == 1)
        rfs = ebm.rhof
    end

    # Thermal conductivity of snow

    ebm.ksnow[:] .= ebm.kfix
    if (ebm.cm == 0) # Fixed
        ebm.ksnow[:] .= ebm.kfix
    elseif (ebm.cm == 1)  # Density function
        for k in 1:ebm.Nsnow
            rhos = rfs
            if (ebm.dm == 1 && ebm.Ds[k] > eps(Float64))
                rhos = (ebm.Sice[k] + ebm.Sliq[k]) / ebm.Ds[k]
            end
            ebm.ksnow[k] = hcon_ice * (rhos / rho_ice)^ebm.bthr
        end
    end

    # Partial snow cover

    snowdepth = sum(ebm.Ds)
    fsnow = tanh(snowdepth / ebm.hfsn)
    alb = fsnow * ebm.albs + (1 - fsnow) * ebm.alb0
    z0 = (ebm.z0sn^fsnow) * (ebm.z0sf^(1 - fsnow))

    # Soil

    dPsidT = - rho_ice * Lf / (rho_wat * g * Tm)

    for k in 1:ebm.Nsoil
        ebm.csoil[k] = ebm.hcap_soil * ebm.Dzsoil[k]
        ebm.ksoil[k] = ebm.hcon_soil
        if (ebm.theta[k] > eps(Float64))
            dthudT = 0
            sthu = ebm.theta[k]
            sthf = 0
            Tc = ebm.Tsoil[k] - Tm
            Tmax = Tm + (ebm.sathh / dPsidT) * (ebm.Vsat / ebm.theta[k])^ebm.b
            if (ebm.Tsoil[k] < Tmax)
                dthudT = (-dPsidT * ebm.Vsat / (ebm.b * ebm.sathh)) * (dPsidT * Tc / ebm.sathh)^(-1 / b - 1)
                sthu = ebm.Vsat * (dPsidT * Tc / ebm.sathh)^(-1 / b)
                sthu = min(sthu, ebm.theta[k])
                sthf = (ebm.theta[k] - sthu) * rho_wat / rho_ice
            end
            Mf = rho_ice * ebm.Dzsoil[k] * sthf
            Mu = rho_wat * ebm.Dzsoil[k] * sthu
            ebm.csoil[k] = ebm.hcap_soil * ebm.Dzsoil[k] + hcap_ice * Mf + hcap_wat * Mu + rho_wat * ebm.Dzsoil[k] * ((hcap_wat - hcap_ice) * Tc + Lf) * dthudT
            Smf = rho_ice * sthf / (rho_wat * ebm.Vsat)
            Smu = sthu / ebm.Vsat
            thice = 0
            if (Smf > 0)
                thice = Vsat * Smf / (Smu + Smf)
            end
            thwat = 0
            if (Smu > 0)
                thwat = ebm.Vsat * Smu / (Smu + Smf)
            end
            hcon_sat = ebm.hcon_soil * (hcon_wat^thwat) * (hcon_ice^thice) / (hcon_air^ebm.Vsat)
            ebm.ksoil[k] = (hcon_sat - ebm.hcon_soil) * (Smf + Smu) + ebm.hcon_soil
            if (k == 1)
                # global gs  # HACKHACK TODO
                gs = ebm.gsat * max((Smu * ebm.Vsat / ebm.Vcrit)^2, 1.)
            end
        end
    end

    # Surface layer

    Dz1 = max(ebm.Dzsoil[1], ebm.Ds[1])


    @bp
    Ts1 = ebm.Tsoil[1] + (ebm.Tsnow[1] - ebm.Tsoil[1]) * ebm.Ds[1] / ebm.Dzsoil[1]


    ksurf = ebm.Dzsoil[1] / (2 * ebm.Ds[1] / ebm.ksnow[1] + (ebm.Dzsoil[1] - 2 * ebm.Ds[1]) / ebm.ksoil[1])

    if (ebm.Ds[1] > 0.5 * ebm.Dzsoil[1])
        ksurf = ebm.ksnow[1]
    end

    if (ebm.Ds[1] > ebm.Dzsoil[1])
        Ts1 = ebm.Tsnow[1]
    end

    return rfs, fsnow, z0, gs, ksurf, Ts1, Dz1, alb
end
