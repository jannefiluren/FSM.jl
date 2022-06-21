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

function read_meteo(t)

    folder = joinpath("K:/DATA_COSMO/OUTPUT_GRID_OSHD_0250/PROCESSED_ANALYSIS/COSMO_1EFA", Dates.format(t, "yyyy.mm"))
    filename = searchdir(folder, "COSMODATA_" * Dates.format(t, "yyyymmddHHMM") * "_C1EFA_")

    meteo = matread(joinpath(folder, filename[1]))

    Ta = meteo["tais"]["data"]
    RH = meteo["rhus"]["data"]
    Ua = meteo["wnsc"]["data"]
    SW = meteo["sdrd"]["data"] .+ meteo["sdfd"]["data"]
    LW = meteo["lwrc"]["data"]
    Sf = compute_psolid(meteo["prcs"]["data"], meteo["tais"]["data"]) ./ 3600
    Rf = compute_pliquid(meteo["prcs"]["data"], meteo["tais"]["data"]) ./ 3600
    Ps = meteo["pail"]["data"]

    return Ta, RH, Ua, SW, LW, Sf, Rf, Ps

end

# Setting up model

times = DateTime(2020, 9, 1, 1):Hour(1):DateTime(2021, 7, 1, 1)

nrows = 1088
ncols = 1460

ebm_template = EBM{Float64}(
        am=1,
        cm=1,
        dm=1,
        em=1,
        hm=1,
        zT=10.5,
        zvar=false,
        Tsoil=[282.98, 284.17, 284.70, 284.70]
    )

ebm_mat = [deepcopy(ebm_template) for i=1:nrows, j=1:ncols]

cn = Constants{Float64}()

snowdepth = ones(nrows, ncols)
SWE = ones(nrows, ncols)
Tsurf = ones(nrows, ncols)


# Run the model

@showprogress "Running model..." for t in times

    Ta, RH, Ua, SW, LW, Sf, Rf, Ps = read_meteo(t)

    run!(ebm_mat, cn, snowdepth, SWE, Tsurf, SW, LW, Sf, Rf, Ta, RH, Ua, Ps)

    if hour(t) == 0
        file = matopen("D:/FSMJL/grid/" * Dates.format(t, "yyyymmdd") * "_hs.mat", "w")
        write(file, "snowdepth", snowdepth)
        close(file)
    end

end
