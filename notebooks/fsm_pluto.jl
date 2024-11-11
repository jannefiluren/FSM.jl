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
    # activate the shared project environment
    Pkg.activate("/home/jannefiluren/.julia/dev/FSM")
    # instantiate, i.e. make sure that all packages are downloaded
    # Pkg.instantiate()

	using FSM
	using CSV
	using DataFrames
	using Plots
	using PlutoUI	
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
Longwave offset: $(@bind LW_offset NumberField(-20:2:20; default=0)) \
Short wave offset: $(@bind SW_offset NumberField(0.5:0.1:1.5; default=1)) \
Air temperature offset: $(@bind Ta_offset NumberField(-3:0.5:3; default=0)) \
Wind speed offset: $(@bind Ua_offset NumberField(0.2:0.1:2; default=1.0))\
"""

# ╔═╡ 4be3cfe4-810c-4f2b-84e6-57fa6f65329c
md"""
## Results...
"""

# ╔═╡ 5ebbb041-d1ad-495f-a1d8-821dbf9904d0
begin

	# Get physics options

	am = string(am_tmp)
	cm = string(cm_tmp)
	dm = string(dm_tmp)
	em = string(em_tmp)
	hm = string(hm_tmp)

	# Load forcing data

	fsm_path = dirname(pathof(FSM))

	data_force = CSV.File(joinpath(fsm_path, "..", "data", "met_CdP_0506.csv")) |> DataFrame

	input = Input{Float64}(
		data_force.year,
		data_force.month,
		data_force.day,
		data_force.hour,
		data_force.SW .* SW_offset,
		data_force.LW .+ LW_offset,
		data_force.Sf,
		data_force.Rf,
		data_force.Ta .+ Ta_offset,
		data_force.RH,
		data_force.Ua .* Ua_offset,
		data_force.Ps,
		)

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

	hs_exp = similar(input.Ta)
	swe_exp = similar(input.Ta)
	tsurf_exp = similar(input.Ta)

	run!(ebm, cn, hs_exp, swe_exp, tsurf_exp, input)

	hs_base = similar(input.Ta)
	swe_base = similar(input.Ta)
	tsurf_base = similar(input.Ta)

	ebm = EBM{Float64}(
		am=0,
		cm=0,
		dm=0,
		em=0,
		hm=0,
		zT=1.5,
		zvar=false,
		Tsoil=[282.98, 284.17, 284.70, 284.70]
	)

	timing = @elapsed run!(ebm, cn, hs_base, swe_base, tsurf_base, input)

	# Load reference simulations from fortran code

	file_ref = "out_CdP_0506_$(am)$(cm)$(dm)$(em)$(hm).txt"

	data_ref = CSV.File(joinpath(fsm_path, "..", "test", "data", file_ref), header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame

	hs_ref = data_ref.snowdepth
	swe_ref = data_ref.SWE
	tsurf_ref = data_ref.Tsurf

	nothing

end

# ╔═╡ 03a37641-b20a-4108-9250-bbbe212505c0
md"""Model run time: $(timing) seconds"""

# ╔═╡ 41c73e0c-d179-49a3-9d71-3ccaa664fb77
begin
	plot(hs_ref, ylabel="Snow depth (m)", linewidth=2, label="Ref")
	plot!(hs_exp, label="Exp")
	plot!(hs_base, label="Base")
end

# ╔═╡ 0b1516f2-041a-4358-9e30-5d3dcb24db1e
begin
	plot(swe_ref, ylabel="Snow water equivalent (mm)", linewidth=2, label="Ref")
	plot!(swe_exp, label="Exp")
	plot!(swe_base, label="Base")
end

# ╔═╡ ff129b48-7221-4803-8766-45acc210d512
begin
		plot(tsurf_ref .+ 273.15, ylabel="Surface temperature (K)", linewidth=2, label="Ref")
		plot!(tsurf_exp, label="Exp")
		plot!(tsurf_base, label="Base")
end

# ╔═╡ Cell order:
# ╟─9bfc0a63-02a7-4e0a-8af9-5aaf13a86aa6
# ╟─41499d7f-77f3-472d-8e89-dd0eeec60595
# ╟─03a37641-b20a-4108-9250-bbbe212505c0
# ╟─4be3cfe4-810c-4f2b-84e6-57fa6f65329c
# ╟─41c73e0c-d179-49a3-9d71-3ccaa664fb77
# ╟─0b1516f2-041a-4358-9e30-5d3dcb24db1e
# ╟─ff129b48-7221-4803-8766-45acc210d512
# ╟─5ebbb041-d1ad-495f-a1d8-821dbf9904d0
# ╟─fc72c7b0-d9c8-11ec-1e41-07be1f03aeb5
