using FSM
using CSV
using DataFrames
using Debugger

data = CSV.File("data/met_CdP_0506.txt", header=["year", "month", "day", "hour", "SW", "LW", "Sf", "Rf", "Ta", "RH", "Ua", "Ps"], delim=" ", ignorerepeated=true) |> DataFrame

input = Input(
    data.year,
    data.month,
    data.day,
    data.hour,
    data.SW,
    data.LW,
    data.Sf,
    data.Rf,
    data.Ta,
    data.RH,
    data.Ua,
    data.Ps,
)

albs = 0.8
Ds = [0, 0, 0]
Nsnow = 0
Sice = [0, 0, 0]
Sliq = [0, 0, 0]
theta = [0.2, 0.2, 0.2, 0.2]
Tsnow = [273.15, 273.15, 273.15]
Tsoil = [282.0, 284.0, 284.0, 284.0]
Tsurf = 275.0

ebm = EBM(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)

rfs, fsnow, gs, CH, z0, Esnow, Gsurf, Hsurf, LEsrf, Melt, Rnet, snowdepth, SWE, SWEall = run!(ebm, input)
# @run run!(ebm, input)
