using FSM
using Plots
using ProgressMeter
using MAT
using Dates

# Helper functions

searchdir(path, key) = filter(x -> occursin(key, x), readdir(path))

function compute_psolid(ptot, ta, thres_prec=274.19, m_prec=0.1500)

    p_corr = 1.0
    tp = @. (ta - thres_prec) / m_prec
    p_multi = @. p_corr / (1 + exp(tp))

    return @. p_multi * ptot

end

function compute_pliquid(ptot, ta, thres_prec=274.19, m_prec=0.1500)

    p_corr = 1.0

    Tp = @. (ta - thres_prec) / m_prec
    p_multi = @. p_corr * exp(Tp) / (1 + exp(Tp))
    return @. p_multi * ptot

end

# Read mat files

nstat = 688

times = DateTime(2020, 9, 1, 1):Hour(1):DateTime(2021, 7, 1, 1)

SW = zeros(length(times), nstat)
LW = zeros(length(times), nstat)
Sf = zeros(length(times), nstat)
Rf = zeros(length(times), nstat)
Ta = zeros(length(times), nstat)
RH = zeros(length(times), nstat)
Ua = zeros(length(times), nstat)
Ps = zeros(length(times), nstat)

@showprogress "Reading meteo data..." for (i, t) in enumerate(times)

    # Read meteo

    folder = joinpath("K:/DATA_COSMO/OUTPUT_STAT_OSHD/PROCESSED_ANALYSIS/COSMO_1EFA", Dates.format(t, "yyyy.mm"))
    filename = searchdir(folder, "COSMODATA_" * Dates.format(t, "yyyymmddHHMM") * "_C1EFA_")

    meteo = matread(joinpath(folder, filename[1]))

    taix = meteo["tais"]["data"]
    rhux = meteo["rhus"]["data"]
    wnsx = meteo["wnsc"]["data"]
    sdrx = meteo["sdrd"]["data"]
    sdfx = meteo["sdfd"]["data"]
    lwrx = meteo["lwrc"]["data"]
    prcx = meteo["prcs"]["data"]
    paix = meteo["pail"]["data"]

    Ta[i, :] .= taix[1, :]
    RH[i, :] .= rhux[1, :]
    Ua[i, :] .= wnsx[1, :]
    SW[i, :] .= sdrx[1, :] .+ sdfx[1, :]
    LW[i, :] .= lwrx[1, :]
    Sf[i, :] .= compute_psolid(prcx[1, :], taix[1, :]) ./ 3600
    Rf[i, :] .= compute_pliquid(prcx[1, :], taix[1, :]) ./ 3600
    Ps[i, :] .= paix[1, :]

end

# Create struct array with input

inputs = Vector{Input{Float64}}(undef, nstat)

for i in range(1, nstat)

    inputs[i] = Input{Float64}(
        ones(length(times)),
        ones(length(times)),
        ones(length(times)),
        ones(length(times)),
        SW[:, i],
        LW[:, i],
        Sf[:, i],
        Rf[:, i],
        Ta[:, i],
        RH[:, i],
        Ua[:, i],
        Ps[:, i],
    )

end

# Setup model

ebm = EBM{Float64}(
        am=1,
        cm=1,
        dm=1,
        em=1,
        hm=1,
        zT=10.5,
        zvar=false,
        Tsoil=[282.98, 284.17, 284.70, 284.70]
    )

cn = Constants{Float64}()

snowdepth = ones(size(Ta))
SWE = ones(size(Ta))
Tsurf = ones(size(Ta))

snowdepth_tmp = similar(inputs[1].Ta)
SWE_tmp = similar(inputs[1].Ta)
Tsurf_tmp = similar(inputs[1].Ta)

ebm_vec = [deepcopy(ebm) for i=1:nstat]

# Run the model

@showprogress "Running model..." for i in range(1, nstat)

    run!(ebm_vec[i], cn, snowdepth_tmp, SWE_tmp, Tsurf_tmp, inputs[i])

    snowdepth[:,i] .= snowdepth_tmp
    SWE[:,i] .= SWE_tmp
    Tsurf[:,i] .= Tsurf_tmp

end

# Plot and save

@showprogress "Plotting result..." for i in range(1, nstat)

    plot(snowdepth[:, i])
    savefig("D:/FSMJL/point/station_" * string(i) * ".png")

end


