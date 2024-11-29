### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ fc72c7b0-d9c8-11ec-1e41-07be1f03aeb5
begin
    import Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    Pkg.instantiate()

	using FSM
	using CSV
	using DataFrames
	using PlutoUI
	using Dates
	using CairoMakie
end

# ╔═╡ 9bfc0a63-02a7-4e0a-8af9-5aaf13a86aa6
md"""
# Flexible snow model
"""

# ╔═╡ 41499d7f-77f3-472d-8e89-dd0eeec60595
md"""
Snow albedo model: $(@bind am_tmp Select([0,1])) \
Snow conductivity model: $(@bind cm_tmp Select([0,1])) \
Snow density model: $(@bind dm_tmp Select([0,1])) \
Surface exchange model: $(@bind em_tmp Select([0,1])) \
Snow hydraulics model: $(@bind hm_tmp Select([0,1])) \
Longwave offset (add): $(@bind LW_offset NumberField(-20:2:20; default=0)) \
Short wave offset (multiply): $(@bind SW_offset NumberField(0.5:0.1:1.5; default=1)) \
Air temperature offset (add): $(@bind Ta_offset NumberField(-3:0.5:3; default=0)) \
Wind speed offset (multiply): $(@bind Ua_offset NumberField(0.0:0.2:5; default=1.0))\
"""

# ╔═╡ 4be3cfe4-810c-4f2b-84e6-57fa6f65329c
md"""
## Results...
"""

# ╔═╡ 0b1516f2-041a-4358-9e30-5d3dcb24db1e
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(swe_ref, ylabel="Snow water equivalent (mm)", linewidth=2, label="Ref")
	#plot!(swe_exp, label="Exp")
	#plot!(swe_base, label="Base")
end
  ╠═╡ =#

# ╔═╡ 5ebbb041-d1ad-495f-a1d8-821dbf9904d0
begin

	# Setup

	fsm_path = dirname(pathof(FSM))
	
	# Get physics options

	am = string(am_tmp)
	cm = string(cm_tmp)
	dm = string(dm_tmp)
	em = string(em_tmp)
	hm = string(hm_tmp)

	# Load forcing data

	file_input = joinpath(fsm_path, "..", "data", "met_CdP_0506.csv") 

	df_input = CSV.File(file_input) |> DataFrame

	df_input.time = DateTime.(
		df_input.year,
		df_input.month,
		df_input.day,
		df_input.hour)

	input = Input{Float64}(
		df_input.year,
		df_input.month,
		df_input.day,
		df_input.hour,
		df_input.SW .* SW_offset,
		df_input.LW .+ LW_offset,
		df_input.Sf,
		df_input.Rf,
		df_input.Ta .+ Ta_offset,
		df_input.RH,
		df_input.Ua .* Ua_offset,
		df_input.Ps)

	# Initilize model for experiments

	ebm = EBM{Float64}(
		am=parse(Int, am),
		cm=parse(Int, cm),
		dm=parse(Int, dm),
		em=parse(Int, em),
		hm=parse(Int, hm),
		zT=1.5,
		zvar=false,
		Tsoil=[282.98, 284.17, 284.70, 284.70]
	)

	cn = Constants{Float64}()

	df_output = DataFrame(
		time=df_input.time,
		hs_exp=similar(input.Ta),
		swe_exp=similar(input.Ta),
		tsurf_exp=similar(input.Ta))

	timing = @elapsed run!(ebm, cn, df_output.hs_exp, df_output.swe_exp, df_output.tsurf_exp, input)

	# Load observations

	file_obs = joinpath(fsm_path, "..", "data", "obs_CdP_0506.txt")
	header = ["year","month","day","alb","rof","hs","swe","tsf","tsl"]
	
	df_obs = CSV.File(
		file_obs,
		header=header,
		delim=" ",
		ignorerepeated=true) |> DataFrame
	
	df_obs.time = DateTime.(df_obs.year, df_obs.month, df_obs.day)
	df_obs = ifelse.(df_obs .== -99, missing, df_obs)

	nothing

end

# ╔═╡ 03a37641-b20a-4108-9250-bbbe212505c0
md"""Model run time: $(timing) seconds"""

# ╔═╡ 41c73e0c-d179-49a3-9d71-3ccaa664fb77
begin
	f = Figure()
	ax = Axis(f[1, 1],
		title = "Col de Porte",
    	ylabel = "Snow depth (m)",
	)
	lines!(ax,df_obs.time, df_obs.hs, label = "Observation")
	lines!(ax,df_output.time, df_output.hs_exp, label = "Simulation")
	axislegend(position = :rt)
	f
end

# ╔═╡ Cell order:
# ╟─9bfc0a63-02a7-4e0a-8af9-5aaf13a86aa6
# ╟─41499d7f-77f3-472d-8e89-dd0eeec60595
# ╟─03a37641-b20a-4108-9250-bbbe212505c0
# ╟─4be3cfe4-810c-4f2b-84e6-57fa6f65329c
# ╟─41c73e0c-d179-49a3-9d71-3ccaa664fb77
# ╟─0b1516f2-041a-4358-9e30-5d3dcb24db1e
# ╟─5ebbb041-d1ad-495f-a1d8-821dbf9904d0
# ╟─fc72c7b0-d9c8-11ec-1e41-07be1f03aeb5
