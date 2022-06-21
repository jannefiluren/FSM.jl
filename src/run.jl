function run!(ebm::EBM, cn::Constants, snowdepth::Vector{Float64}, SWE::Vector{Float64}, Tsurf::Vector{Float64}, in::Input)

    D = zeros(ebm.Nsmax)
    S = zeros(ebm.Nsmax)
    W = zeros(ebm.Nsmax)

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

        snowdepth[i], SWE[i] = snow(ebm, cn, Sf, Rf, Ta, D, S, W)

        soil(ebm)

        Tsurf[i] = ebm.Tsurf

    end

end


function run!(ebm::Matrix{EBM{Float64}}, cn::Constants, snowdepth::Matrix{Float64}, SWE::Matrix{Float64}, Tsurf::Matrix{Float64}, 
    SW::Matrix{Float64}, LW::Matrix{Float64}, Sf::Matrix{Float64}, Rf::Matrix{Float64}, Ta::Matrix{Float64}, RH::Matrix{Float64}, Ua::Matrix{Float64}, Ps::Matrix{Float64})

    D = zeros(ebm[1, 1].Nsmax)
    S = zeros(ebm[1, 1].Nsmax)
    W = zeros(ebm[1, 1].Nsmax)

    Ua = max.(Ua, 0.1)

    for i in eachindex(ebm)

        Qs = qsat(true, Ps[i], Ta[i], cn)
        Qa = (RH[i] / 100) * Qs
        
        surf_props(ebm[i], cn, Sf[i])

        for i in 1:6
            surf_exch(ebm[i], cn, Ta[i], Ua[i])
            surf_ebal(ebm[i], cn, Ta[i], Qa, Ua[i], Ps[i], SW[i], LW[i])
        end

        snowdepth[i], SWE[i] = snow(ebm[i], cn, Sf[i], Rf[i], Ta[i], D, S, W)

        soil(ebm[i])

        Tsurf[i] = ebm[i].Tsurf

    end

end
