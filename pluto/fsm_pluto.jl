### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ dd29cb1a-4770-11eb-0db2-272859d3b045
begin
	using FSM
	using CSV
	using DataFrames
	using Plots
	using PlutoUI
end

# ╔═╡ a2eb46ba-4770-11eb-1d86-4d2e18f25bc1
md"""

### Flexible snow model


Here are some experiments with the Julia implementation of FSM...

"""

# ╔═╡ f126375a-4772-11eb-11f8-a71c6c86ba36
md"""
Snow albedo model
"""

# ╔═╡ 125fc900-4772-11eb-3d6b-d121f32c31c5
@bind am Select(["0", "1"])

# ╔═╡ 2b7b1710-49fd-11eb-072a-e320f2a80a3c
md"""
Snow conductivity model
"""

# ╔═╡ 36b71ff0-49fd-11eb-0cc8-9f7f0fdac201
@bind cm Select(["0", "1"])

# ╔═╡ 96f8c1f2-49fd-11eb-19ff-8db150ad53a3
md"""
Snow density model
"""

# ╔═╡ 9fd8aa12-49fd-11eb-32cb-bdd6f962d075
@bind dm Select(["0", "1"])

# ╔═╡ bfe40edc-49fd-11eb-0268-570ff06b4020
md"""
Surface exchange model
"""

# ╔═╡ c9ef08a0-49fd-11eb-07ed-252c5d4da577
@bind em Select(["0", "1"])

# ╔═╡ 1207461a-4773-11eb-3b2e-a181f28c29ba
md"""
Snow hydraulics model
"""

# ╔═╡ 1e2df4f4-4773-11eb-3f1f-dd30364bc006
@bind hm Select(["0", "1"])

# ╔═╡ 3db3b4e0-5825-11eb-22e3-b1fe7436794a
md"""
## Result plots...
"""

# ╔═╡ 556f9b8e-4773-11eb-2b6b-abe07b0efdc1
md"""Setup simulations..."""

# ╔═╡ 980e8ac4-4771-11eb-0a52-c35a9a0a00ea
begin
	
	# Load forcing data
	
	data_force = CSV.File("../data/met_CdP_0506.csv") |> DataFrame

	input = Input{Float32}(
		data_force.year,
		data_force.month,
		data_force.day,
		data_force.hour,
		data_force.SW,
		data_force.LW,
		data_force.Sf,
		data_force.Rf,
		data_force.Ta,
		data_force.RH,
		data_force.Ua,
		data_force.Ps,
		)
	
	# Initilize model for experiments

	ebm = EBM{Float32}(
		am=parse(Int, am),
		cm=parse(Int, cm),
		dm=parse(Int, dm),
		em=parse(Int, em),
		hm=parse(Int, hm),
		zT=1.5,
		zvar=false,
		Tsoil=[282.98, 284.17, 284.70, 284.70]
	)

	cn = Constants{Float32}()

	hs_exp = similar(input.Ta)
	swe_exp = similar(input.Ta)
	tsurf_exp = similar(input.Ta)
	
	run!(ebm, cn, hs_exp, swe_exp, tsurf_exp, input)
	
	hs_base = similar(input.Ta)
	swe_base = similar(input.Ta)
	tsurf_base = similar(input.Ta)

	ebm = EBM{Float32}(
		am=0,
		cm=0,
		dm=0,
		em=0,
		hm=0,
		zT=1.5,
		zvar=false,
		Tsoil=[282.98, 284.17, 284.70, 284.70]
	)

	run!(ebm, cn, hs_base, swe_base, tsurf_base, input)
	
end

# ╔═╡ 7c6e503c-55aa-11eb-040e-69123898c27b
begin
	file_ref = "out_CdP_0506_$(am)$(cm)$(dm)$(em)$(hm).txt"
	
	data_ref = CSV.File(joinpath("../test/data", file_ref), header=["year", "month", "day", "hour", "alb", "Roff", "snowdepth", "SWE", "Tsurf", "Tsoil"], delim=" ", ignorerepeated=true) |> DataFrame
	
	hs_ref = data_ref.snowdepth
	swe_ref = data_ref.SWE
	tsurf_ref = data_ref.Tsurf
end

# ╔═╡ 1a0e63e2-4771-11eb-0e89-cdac7083e1ae
begin
	plot(hs_ref, ylabel="Snow depth (m)", linewidth=2, label="Ref")
	plot!(hs_exp, label="Exp")
	plot!(hs_base, label="Base")
end

# ╔═╡ 4a1e7488-49ff-11eb-22f1-997033d28ca0
begin
	plot(swe_ref, ylabel="Snow water equivalent (mm)", linewidth=2, label="Ref")
	plot!(swe_exp, label="Exp")
	plot!(swe_base, label="Base")
end

# ╔═╡ 062a89c0-5825-11eb-30c0-1d2e3d30e3e6
begin
	plot(tsurf_ref.+273.15, ylabel="Surface temperature (K)", linewidth=2, label="Ref")
	plot!(tsurf_exp, label="Exp")
	plot!(tsurf_base, label="Base")
end

# ╔═╡ 0c4d506a-4a00-11eb-00bf-e92fb70b348c


# ╔═╡ Cell order:
# ╟─a2eb46ba-4770-11eb-1d86-4d2e18f25bc1
# ╟─f126375a-4772-11eb-11f8-a71c6c86ba36
# ╟─125fc900-4772-11eb-3d6b-d121f32c31c5
# ╟─2b7b1710-49fd-11eb-072a-e320f2a80a3c
# ╟─36b71ff0-49fd-11eb-0cc8-9f7f0fdac201
# ╟─96f8c1f2-49fd-11eb-19ff-8db150ad53a3
# ╟─9fd8aa12-49fd-11eb-32cb-bdd6f962d075
# ╟─bfe40edc-49fd-11eb-0268-570ff06b4020
# ╟─c9ef08a0-49fd-11eb-07ed-252c5d4da577
# ╟─1207461a-4773-11eb-3b2e-a181f28c29ba
# ╟─1e2df4f4-4773-11eb-3f1f-dd30364bc006
# ╟─3db3b4e0-5825-11eb-22e3-b1fe7436794a
# ╟─1a0e63e2-4771-11eb-0e89-cdac7083e1ae
# ╟─4a1e7488-49ff-11eb-22f1-997033d28ca0
# ╟─062a89c0-5825-11eb-30c0-1d2e3d30e3e6
# ╟─556f9b8e-4773-11eb-2b6b-abe07b0efdc1
# ╠═980e8ac4-4771-11eb-0a52-c35a9a0a00ea
# ╠═7c6e503c-55aa-11eb-040e-69123898c27b
# ╠═dd29cb1a-4770-11eb-0db2-272859d3b045
# ╠═0c4d506a-4a00-11eb-00bf-e92fb70b348c
