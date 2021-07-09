function surf_props(ebm::EBM, cn::Constants, Sf)

    # Snow albedo

    if ebm.am == 0  # Diagnosed snow albedo
        ebm.albs = ebm.asmn + (ebm.asmx - ebm.asmn) * (ebm.Tsurf - cn.Tm) / ebm.Talb
    elseif ebm.am == 1  # Prognostic snow albedo
        tau = 3600.0 * ebm.tcld
        if (ebm.Tsurf >= cn.Tm)
            tau = 3600.0 * ebm.tmlt
        end
        rt = 1.0 / tau + Sf / ebm.Salb
        alim = (ebm.asmn / tau + Sf * ebm.asmx / ebm.Salb) / rt
        ebm.albs = alim + (ebm.albs - alim) * exp(-rt * ebm.dt)
    end

    if (ebm.albs < min(ebm.asmx, ebm.asmn))
        ebm.albs = min(ebm.asmx, ebm.asmn)
    end

    if (ebm.albs > max(ebm.asmx, ebm.asmn))
        ebm.albs = max(ebm.asmx, ebm.asmn)
    end

    # Density of fresh snow

    if (ebm.dm == 0)
        ebm.rfs = ebm.rho0
    elseif (ebm.dm == 1)
        ebm.rfs = ebm.rhof
    end

    # Thermal conductivity of snow

    ebm.ksnow[:] .= ebm.kfix
    if (ebm.cm == 0) # Fixed
        ebm.ksnow[:] .= ebm.kfix
    elseif (ebm.cm == 1)  # Density function
        for k in 1:ebm.Nsnow
            rhos = ebm.rfs
            if (ebm.dm == 1 && ebm.Ds[k] > eps(first(ebm.Ds)))
                rhos = (ebm.Sice[k] + ebm.Sliq[k]) / ebm.Ds[k]
            end
            ebm.ksnow[k] = cn.hcon_ice * (rhos / cn.rho_ice)^ebm.bthr
        end
    end

    # Partial snow cover

    snowdepth = sum(ebm.Ds)
    ebm.fsnow = tanh(snowdepth / ebm.hfsn)
    ebm.alb = ebm.fsnow * ebm.albs + (1.0 - ebm.fsnow) * ebm.alb0
    ebm.z0 = (ebm.z0sn^ebm.fsnow) * (ebm.z0sf^(1.0 - ebm.fsnow))

    # Soil

    dPsidT = - cn.rho_ice * cn.Lf / (cn.rho_wat * cn.g * cn.Tm)

    for k in 1:ebm.Nsoil
        ebm.csoil[k] = ebm.hcap_soil * ebm.Dzsoil[k]
        ebm.ksoil[k] = ebm.hcon_soil
        if (ebm.theta[k] > eps(first(ebm.theta)))
            dthudT = 0.0
            sthu = ebm.theta[k]
            sthf = 0.0
            Tc = ebm.Tsoil[k] - cn.Tm
            Tmax = cn.Tm + (ebm.sathh / dPsidT) * (ebm.Vsat / ebm.theta[k])^ebm.b
            if (ebm.Tsoil[k] < Tmax)
                dthudT = (-dPsidT * ebm.Vsat / (ebm.b * ebm.sathh)) * (dPsidT * Tc / ebm.sathh)^(-1 / ebm.b - 1)
                sthu = ebm.Vsat * (dPsidT * Tc / ebm.sathh)^(-1.0 / ebm.b)
                sthu = min(sthu, ebm.theta[k])
                sthf = (ebm.theta[k] - sthu) * cn.rho_wat / cn.rho_ice
            end
            Mf = cn.rho_ice * ebm.Dzsoil[k] * sthf
            Mu = cn.rho_wat * ebm.Dzsoil[k] * sthu
            ebm.csoil[k] = ebm.hcap_soil * ebm.Dzsoil[k] + cn.hcap_ice * Mf + cn.hcap_wat * Mu + cn.rho_wat * ebm.Dzsoil[k] * ((cn.hcap_wat - cn.hcap_ice) * Tc + cn.Lf) * dthudT
            Smf = cn.rho_ice * sthf / (cn.rho_wat * ebm.Vsat)
            Smu = sthu / ebm.Vsat
            thice = 0.0
            if (Smf > 0.0)
                thice = ebm.Vsat * Smf / (Smu + Smf)
            end
            thwat = 0.0
            if (Smu > 0.0)
                thwat = ebm.Vsat * Smu / (Smu + Smf)
            end
            hcon_sat = ebm.hcon_soil * (cn.hcon_wat^thwat) * (cn.hcon_ice^thice) / (cn.hcon_air^ebm.Vsat)
            ebm.ksoil[k] = (hcon_sat - ebm.hcon_soil) * (Smf + Smu) + ebm.hcon_soil
            if (k == 1)
                ebm.gs = ebm.gsat * max((Smu * ebm.Vsat / ebm.Vcrit)^2.0, 1.0)
            end
        end
    end

    # Surface layer

    ebm.Dz1 = max(ebm.Dzsoil[1], ebm.Ds[1])

    ebm.Ts1 = ebm.Tsoil[1] + (ebm.Tsnow[1] - ebm.Tsoil[1]) * ebm.Ds[1] / ebm.Dzsoil[1]

    ebm.ksurf = ebm.Dzsoil[1] / (2.0 * ebm.Ds[1] / ebm.ksnow[1] + (ebm.Dzsoil[1] - 2 * ebm.Ds[1]) / ebm.ksoil[1])

    if (ebm.Ds[1] > 0.5 * ebm.Dzsoil[1])
        ebm.ksurf = ebm.ksnow[1]
    end

    if (ebm.Ds[1] > ebm.Dzsoil[1])
        ebm.Ts1 = ebm.Tsnow[1]
    end

    return nothing

end
