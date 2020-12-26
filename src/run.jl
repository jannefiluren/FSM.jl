function run!(ebm::EBM, snowdepth::Vector{Float32}, SWE::Vector{Float32}, in::Input)

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

        Qs = qsat(true, Ps, Ta)
        Qa = (RH / 100) * Qs

        surf_props(ebm, Sf)

        for i in 1:6
            surf_exch(ebm, Ta, Ua)
            surf_ebal(ebm, Ta, Qa, Ua, Ps, SW, LW)
        end

        snowdepth[i], SWE[i] = snow(ebm, Sf, Rf, Ta)

        soil(ebm)

    end

end
