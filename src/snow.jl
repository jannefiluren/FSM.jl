function snow(ebm::EBM, Sf, Rf, Ta)

    ebm.Gsoil = ebm.Gsurf
    Roff = Rf * ebm.dt



    csnow = zeros(ebm.Nsmax)   ##### hack
    E = zeros(ebm.Nsmax)  ##### hack
    U = zeros(ebm.Nsmax)  ##### hack
    Gs = zeros(ebm.Nsmax)  ##### hack
    dTs = zeros(ebm.Nsmax)  ##### hack
    atmp = zeros(ebm.Nsmax)  ##### hack
    btmp = zeros(ebm.Nsmax)  ##### hack
    ctmp = zeros(ebm.Nsmax)  ##### hack
    rhs = zeros(ebm.Nsmax)  ##### hack

    if (ebm.Nsnow > 0)   # Existing snowpack
        # Heat capacity
        for k = 1:ebm.Nsnow
            csnow[k] = ebm.Sice[k] * hcap_ice + ebm.Sliq[k] * hcap_wat
        end

        # Heat conduction
        if (ebm.Nsnow == 1)
            Gs[1] = 2 / (ebm.Ds[1] / ebm.ksnow[1] + ebm.Dzsoil[1] / ebm.ksoil[1])
            dTs[1] = (ebm.Gsurf + Gs[1] * (ebm.Tsoil[1] - ebm.Tsnow[1])) * ebm.dt / (csnow[1] + Gs[1] * ebm.dt)
        else
            for k = 1:(ebm.Nsnow - 1)
                Gs[k] = 2 / (ebm.Ds[k] / ebm.ksnow[k] + ebm.Ds[k + 1] / ebm.ksnow[k + 1])
            end
            atmp[1] = 0
            btmp[1] = csnow[1] + Gs[1] * ebm.dt
            ctmp[1] = - Gs[1] * ebm.dt
            rhs[1] = (ebm.Gsurf - Gs[1] * (ebm.Tsnow[1] - ebm.Tsnow[2])) * ebm.dt
            for k = 2:(ebm.Nsnow - 1)
                atmp[k] = ctmp[k - 1]
                btmp[k] = csnow[k] + (Gs[k - 1] + Gs[k]) * ebm.dt
                ctmp[k] = - Gs[k] * ebm.dt
                rhs[k] = Gs[k - 1] * (ebm.Tsnow[k - 1] - ebm.Tsnow[k]) * ebm.dt + Gs[k] * (ebm.Tsnow[k + 1] - ebm.Tsnow[k]) * ebm.dt
            end
            k = ebm.Nsnow

            Gs[k] = 2 / (ebm.Ds[k] / ebm.ksnow[k] + ebm.Dzsoil[1] / ebm.ksoil[1])
            atmp[k] = ctmp[k - 1]
            btmp[k] = csnow[k] + (Gs[k - 1] + Gs[k]) * ebm.dt
            ctmp[k] = 0
            rhs[k] = Gs[k - 1] * (ebm.Tsnow[k - 1] - ebm.Tsnow[k]) * ebm.dt + Gs[k] * (ebm.Tsoil[1] - ebm.Tsnow[k]) * ebm.dt
            tridiag(ebm.Nsnow, ebm.Nsmax, atmp, btmp, ctmp, rhs, dTs)
        end


        for k = 1:ebm.Nsnow
            ebm.Tsnow[k] = ebm.Tsnow[k] + dTs[k]
        end
        ebm.Gsoil = Gs[ebm.Nsnow] * (ebm.Tsnow[ebm.Nsnow] - ebm.Tsoil[1])



        # Convert melting ice to liquid water
        dSice = ebm.Melt * ebm.dt
        for k = 1:ebm.Nsnow
            coldcont = csnow[k] * (Tm - ebm.Tsnow[k])
            if (coldcont < 0)
                # global dSice  ### HACK
                dSice = dSice - coldcont / Lf
                ebm.Tsnow[k] = Tm
            end
            if (dSice > 0)
                if (dSice > ebm.Sice[k])       # Layer melts completely
                    dSice = dSice - ebm.Sice[k]
                    ebm.Ds[k] = 0
                    ebm.Sliq[k] = ebm.Sliq[k] + ebm.Sice[k]
                    ebm.Sice[k] = 0
                else                       # Layer melts partially
                    ebm.Ds[k] = (1 - dSice / ebm.Sice[k]) * ebm.Ds[k]
                    ebm.Sice[k] = ebm.Sice[k] - dSice
                    ebm.Sliq[k] = ebm.Sliq[k] + dSice
                    dSice = 0                # Melt exhausted
                end
            end
        end


        # Remove snow by sublimation
        dSice = max(ebm.Esnow, 0) * ebm.dt
        if (dSice > 0)
            for k = 1:ebm.Nsnow
                if (dSice > ebm.Sice[k])       # Layer sublimates completely
                    # global dSice #### hack
                    dSice = dSice - ebm.Sice[k]
                    ebm.Ds[k] = 0
                    ebm.Sice[k] = 0
                else                       # Layer sublimates partially
                    ebm.Ds[k] = (1 - dSice / ebm.Sice[k]) * ebm.Ds[k]
                    ebm.Sice[k] = ebm.Sice[k] - dSice
                    dSice = 0                # Sublimation exhausted
                end
            end
        end

        # Snow hydraulics
        if ebm.hm == 0  #  Free-draining snow
            for k = 1:ebm.Nsnow
                # global Roff ### hack
                Roff = Roff + ebm.Sliq[k]
                ebm.Sliq[k] = 0
            end
        elseif ebm.hm == 1  #  Bucket storage
            for k = 1:ebm.Nsnow
                # global Roff ### hack
                phi = 0
                if (ebm.Ds[k] > eps(first(ebm.Ds)))
                    phi = 1 - ebm.Sice[k] / (rho_ice * ebm.Ds[k])
                end
                SliqMax = rho_wat * ebm.Ds[k] * phi * ebm.Wirr
                ebm.Sliq[k] = ebm.Sliq[k] + Roff
                Roff = 0
                if (ebm.Sliq[k] > SliqMax)       # Liquid capacity exceeded
                    Roff = ebm.Sliq[k] - SliqMax   # so drainage to next layer
                    ebm.Sliq[k] = SliqMax
                end
                coldcont = csnow[k] * (Tm - ebm.Tsnow[k])
                if (coldcont > 0)            # Liquid can freeze
                    # global dSice #### hack
                    dSice = min(ebm.Sliq[k], coldcont / Lf)
                    ebm.Sliq[k] = ebm.Sliq[k] - dSice
                    ebm.Sice[k] = ebm.Sice[k] + dSice
                    ebm.Tsnow[k] = ebm.Tsnow[k] + Lf * dSice / csnow[k]
                end
            end
        end


        # Snow compaction
        if ebm.dm == 0  # Fixed snow density
            for k = 1:ebm.Nsnow
                ebm.Ds[k] = (ebm.Sice[k] + ebm.Sliq[k]) / ebm.rho0
            end
        elseif ebm.dm == 1  # Prognostic snow density
            tau = 3600 * ebm.trho
            for k = 1:ebm.Nsnow
                if (ebm.Ds[k] > eps(first(ebm.Ds)))
                    rhos = (ebm.Sice[k] + ebm.Sliq[k]) / ebm.Ds[k]
                    if (ebm.Tsnow[k] >= Tm)
                        if (rhos < ebm.rmlt)
                            rhos = ebm.rmlt + (rhos - ebm.rmlt) * exp(-ebm.dt / tau)
                        end
                    else
                        if (rhos < ebm.rcld)
                            rhos = ebm.rcld + (rhos - ebm.rcld) * exp(-ebm.dt / tau)
                        end
                    end
                    ebm.Ds[k] = (ebm.Sice[k] + ebm.Sliq[k]) / rhos
                end
            end
        end
    end  # Existing snowpack

    # Add snowfall and frost to layer 1
    dSice = Sf * ebm.dt - min(ebm.Esnow, 0.) * ebm.dt
    ebm.Ds[1] = ebm.Ds[1] + dSice / ebm.rfs
    ebm.Sice[1] = ebm.Sice[1] + dSice

    # New snowpack
    if (ebm.Nsnow == 0 && ebm.Sice[1] > 0)
        ebm.Nsnow = 1
        ebm.Tsnow[1] = min(Ta, Tm)
    end

    # Calculate snow depth and SWE
    snowdepth = 0
    SWE = 0
    for k = 1:ebm.Nsnow
       # global SWE
       # global snowdepth
        snowdepth = snowdepth + ebm.Ds[k]
        SWE = SWE + ebm.Sice[k] + ebm.Sliq[k]
    end

    # Store state of old layers
    D = ebm.Ds[:]
    S = ebm.Sice[:]
    W = ebm.Sliq[:]

    for k = 1:ebm.Nsnow
        csnow[k] = ebm.Sice[k] * hcap_ice + ebm.Sliq[k] * hcap_wat
        E[k] = csnow[k] * (ebm.Tsnow[k] - Tm)
    end
    Nold = ebm.Nsnow

    # Initialise new layers
    ebm.Ds[:] .= 0
    ebm.Sice[:] .= 0
    ebm.Sliq[:] .= 0
    ebm.Tsnow[:] .= Tm
    U[:] .= 0
    ebm.Nsnow = 0

    if (SWE > 0)       # Existing or new snowpack

        # Re-assign and count snow layers
        dnew = snowdepth
        ebm.Ds[1] = dnew
        k = 1
        if (ebm.Ds[1] > ebm.Dzsnow[1])
            for k = 1:ebm.Nsmax
                # global dnew   ##########  hack

                ebm.Ds[k] = ebm.Dzsnow[k]
                dnew = dnew - ebm.Dzsnow[k]
                if (dnew <= ebm.Dzsnow[k] || k == ebm.Nsmax)
                    ebm.Ds[k] = ebm.Ds[k] + dnew
                    break   ##### hack: was previously exit
                end
            end
        end
        # Nsnow = k   hackhackhack
        ebm.Nsnow = sum(ebm.Ds .> 0)

        # Fill new layers from the top downwards
        knew = 1
        dnew = ebm.Ds[1]
        for kold = 1:Nold
            while true
                if (D[kold] < dnew)

                    # global dnew   ###### hack
                    # global knew   ###### hack


                    # Transfer all snow from old layer and move to next old layer
                    ebm.Sice[knew] = ebm.Sice[knew] + S[kold]
                    ebm.Sliq[knew] = ebm.Sliq[knew] + W[kold]
                    U[knew] = U[knew] + E[kold]
                    dnew = dnew - D[kold]
                    break   ##### hack   exit
                else
                    # Transfer some snow from old layer and move to next new layer
                    wt = dnew / D[kold]
                    ebm.Sice[knew] = ebm.Sice[knew] + wt * S[kold]
                    ebm.Sliq[knew] = ebm.Sliq[knew] + wt * W[kold]
                    U[knew] = U[knew] + wt * E[kold]
                    D[kold] = (1 - wt) * D[kold]
                    E[kold] = (1 - wt) * E[kold]
                    S[kold] = (1 - wt) * S[kold]
                    W[kold] = (1 - wt) * W[kold]
                    knew = knew + 1
                    if (knew > ebm.Nsnow)
                        break #### hack  exit
                    end
                    dnew = ebm.Ds[knew]
                end

            end
        end

        # Diagnose snow layer temperatures
        for k = 1:ebm.Nsnow
            csnow[k] = ebm.Sice[k] * hcap_ice + ebm.Sliq[k] * hcap_wat
            if (csnow[k] > eps(first(csnow)))
                ebm.Tsnow[k] = Tm + U[k] / csnow[k]
            end
        end

    end

    return snowdepth, SWE
end

