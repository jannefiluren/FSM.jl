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
md"""Select albedo model:"""

# ╔═╡ 125fc900-4772-11eb-3d6b-d121f32c31c5
begin
	@bind am Select(["0", "1"])
end

# ╔═╡ 1207461a-4773-11eb-3b2e-a181f28c29ba
md"""Select snow hydraulics model"""

# ╔═╡ 1e2df4f4-4773-11eb-3f1f-dd30364bc006
begin
	@bind hm Select(["0", "1"])
end

# ╔═╡ 272a733e-4773-11eb-2f85-3f545cfd9f3c
md"""Select density model"""

# ╔═╡ 322cd664-4773-11eb-1cc7-f1e2b491f18d
begin
	@bind dm Select(["0", "1"])
end

# ╔═╡ 0d2b10b4-4774-11eb-11a3-75df2e665679
@bind Wirr Slider(0:0.001:0.10, default=0.03)

# ╔═╡ dfdf8d0a-4774-11eb-1c45-d51492077dd3
md"""Wirr = $Wirr"""

# ╔═╡ 556f9b8e-4773-11eb-2b6b-abe07b0efdc1
md"""Setup simulations..."""

# ╔═╡ 980e8ac4-4771-11eb-0a52-c35a9a0a00ea
begin
	data = CSV.File("data/met_CdP_0506.csv") |> DataFrame
	
	input = Input{Float32}(
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
	
	hs_ref = zeros(Float32, length(input.Ta))
	swe_ref = zeros(Float32, length(input.Ta))

	ebm = EBM{Float32}(am=0, cm=0, dm=0, em=0, hm=0)

	run!(ebm, hs_ref, swe_ref, input)
	
	
	hs_exp = zeros(Float32, length(input.Ta))
	swe_exp = zeros(Float32, length(input.Ta))

	ebm = EBM{Float32}(
		am=parse(Int, am), 
		cm=0,
		dm=parse(Int, dm),
		em=0,
		hm=parse(Int, hm),
		Wirr=Wirr)

	run!(ebm, hs_exp, swe_exp, input)
end

# ╔═╡ 1a0e63e2-4771-11eb-0e89-cdac7083e1ae
begin
	plot(hs_ref)
	plot!(hs_exp)
end

# ╔═╡ Cell order:
# ╟─a2eb46ba-4770-11eb-1d86-4d2e18f25bc1
# ╟─f126375a-4772-11eb-11f8-a71c6c86ba36
# ╟─125fc900-4772-11eb-3d6b-d121f32c31c5
# ╟─1207461a-4773-11eb-3b2e-a181f28c29ba
# ╟─1e2df4f4-4773-11eb-3f1f-dd30364bc006
# ╟─272a733e-4773-11eb-2f85-3f545cfd9f3c
# ╟─322cd664-4773-11eb-1cc7-f1e2b491f18d
# ╟─dfdf8d0a-4774-11eb-1c45-d51492077dd3
# ╟─0d2b10b4-4774-11eb-11a3-75df2e665679
# ╟─1a0e63e2-4771-11eb-0e89-cdac7083e1ae
# ╟─556f9b8e-4773-11eb-2b6b-abe07b0efdc1
# ╠═980e8ac4-4771-11eb-0a52-c35a9a0a00ea
# ╠═dd29cb1a-4770-11eb-0db2-272859d3b045
