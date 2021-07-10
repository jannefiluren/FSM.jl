function run!(ebm::EBM, cn::Constants, snowdepth::Vector{Float64}, SWE::Vector{Float64}, Tsurf::Vector{Float64}, in::Input)

    for i in 1:length(in.year)

        year = in.year[i]
        month = in.month[i]
        day = in.day[i]
        hour = in.hour[i]
        SW = in.SW[i]
        LW = in.LW[i]
        Sf = in.Sf[i]
        Rf = in.Rf[i]
        Ta = in.Ta[i]
        RH = in.RH[i]
        Ua = in.Ua[i]
        Ps = in.Ps[i]

        Qs = qsat(true, Ps, Ta, cn)
        Qa = (RH / 100) * Qs

        Ua = max(Ua, 0.1)

        surf_props(ebm, cn, Sf)

        for i in 1:6
            surf_exch(ebm, cn, Ta, Ua)
            surf_ebal(ebm, cn, Ta, Qa, Ua, Ps, SW, LW)
        end

        snowdepth[i], SWE[i] = snow(ebm, cn, Sf, Rf, Ta)

        soil(ebm)

        Tsurf[i] = ebm.Tsurf

    end

end
