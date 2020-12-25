function surf_exch(ebm::EBM, Ta, Ua)

    zTs = ebm.zT
    if (ebm.zvar)
        zTs = ebm.zT - sum(ebm.Ds)
        zTs = max(zTs, 1.0)
    end

    # Neutral exchange coefficients
    z0h = 0.1 * ebm.z0
    CD = (vkman / log(ebm.zU / ebm.z0))^2
    ebm.CH = vkman^2 / (log(ebm.zU / ebm.z0) * log(zTs / z0h))

    # Stability correction (Louis et al. 1982, quoted by Beljaars 1992)
    if (ebm.em == 1)
        RiB = g * (Ta - ebm.Tsurf) * ebm.zU^2 / (zTs * Ta * Ua^2)
        if (RiB > 0)
            fh = 1 / (1 + 3 * ebm.bstb * RiB * sqrt(1 + ebm.bstb * RiB))
        else
            fh = 1 - 3 * ebm.bstb * RiB / (1 + 3 * ebm.bstb^2 * CD * sqrt(-RiB * ebm.zU / ebm.z0))
        end
        ebm.CH = fh * ebm.CH
    end

end
