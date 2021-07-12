using CSV
using DataFrames

files = readdir("test/output_float32")

for file in files

    data_float32 = CSV.File("test/output_float32/$(file)", header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

    data_float64 = CSV.File("test/output_float64/$(file)", header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

    @info maximum(abs.(data_float32.Tsurf .- data_float64.Tsurf))

end
