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

# ╔═╡ fff0ff7a-4a94-11eb-1821-fbc6796d2e2d
begin
	import Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    Pkg.instantiate()
	
	using FSM
	using PlutoUI
	using Plots
end

# ╔═╡ 7e7db788-4a96-11eb-3a41-2115cc7d3b58
md"""
# Albedo models
"""

# ╔═╡ f866f932-4ab0-11eb-0c58-0dd947ff1341
md"""
## Diagnostic albedo model
"""

# ╔═╡ 1427ffea-4ab1-11eb-1862-254bcabf97ac
md"""
## Prognostic albedo model
	
Add snow at hour = 100
"""

# ╔═╡ 5512e630-4ab3-11eb-2347-8f4afbd5f228
@bind Sf_one Slider(0:200, show_value=true)

# ╔═╡ fa0dd0ec-4ab2-11eb-34ce-d16073a73f39
md"""
## Actual computations
"""

# ╔═╡ 24c749a8-4a95-11eb-1fc8-f34a2d08bdbe
begin
	ebm = EBM{Float64}()
	cn = Constants{Float64}()
	nothing
end

# ╔═╡ 4e6b1406-4a95-11eb-0827-432daf4b223e
function compute_albedo(ebm::EBM, cn::Constants, Sf)

	if ebm.am == 0  # Diagnosed snow albedo
		ebm.albs = ebm.asmn + (ebm.asmx - ebm.asmn) * (ebm.Tsurf - cn.Tm) / ebm.Talb
	elseif ebm.am == 1  # Prognostic snow albedo
		tau = 3600 * ebm.tcld
		if (ebm.Tsurf >= cn.Tm)
			tau = 3600 * ebm.tmlt
		end
		rt = 1 / tau + Sf / ebm.Salb
		alim = (ebm.asmn / tau + Sf * ebm.asmx / ebm.Salb) / rt
		ebm.albs = alim + (ebm.albs - alim) * exp(-rt * ebm.dt)
	end

	if (ebm.albs < min(ebm.asmx, ebm.asmn))
		ebm.albs = min(ebm.asmx, ebm.asmn)
	end

	if (ebm.albs > max(ebm.asmx, ebm.asmn))
		ebm.albs = max(ebm.asmx, ebm.asmn)
	end

end

# ╔═╡ be13ab46-4aaf-11eb-1f96-752bcbef74f6
begin
	Tsurf = cn.Tm-10:0.01:cn.Tm+10
	Sf = 0
	
	albedo = []
	for T in Tsurf
		eb = EBM{Float64}(Tsurf = T, am = 0)
		compute_albedo(eb, cn, Sf)
		push!(albedo, eb.albs)
	end

	plot(Tsurf, albedo, xlabel = "Temperature (K)", ylabel = "Albedo (-)", title = "Albedo model = 0")
end

# ╔═╡ 2016de88-4ab2-11eb-3ca1-a75c6752bc71
begin
	eb_cold = EBM{Float64}(Tsurf = 271.15, am = 1)
	eb_warm = EBM{Float64}(Tsurf = 273.15, am = 1)
	albs_cold = [eb_cold.albs]
	albs_warm = [eb_warm.albs]
	t_prog = [0]
	for t in 1:24*10
		
		if t == 100
			Sf = Sf_one/3600
		else
			Sf = 0
		end
			
		
		compute_albedo(eb_cold, cn, Sf)
		compute_albedo(eb_warm, cn, Sf)
		push!(albs_cold, eb_cold.albs)
		push!(albs_warm, eb_warm.albs)
		push!(t_prog, t)
	end
	
	plot(t_prog, albs_cold)
	plot!(t_prog, albs_warm)
	plot!(xlabel = "Temperature (K)", ylabel = "Albedo (-)", title = "Albedo model = 1")
	plot!(ylim = (0, 1))
end

# ╔═╡ Cell order:
# ╟─7e7db788-4a96-11eb-3a41-2115cc7d3b58
# ╟─f866f932-4ab0-11eb-0c58-0dd947ff1341
# ╟─be13ab46-4aaf-11eb-1f96-752bcbef74f6
# ╟─1427ffea-4ab1-11eb-1862-254bcabf97ac
# ╟─5512e630-4ab3-11eb-2347-8f4afbd5f228
# ╟─2016de88-4ab2-11eb-3ca1-a75c6752bc71
# ╟─fa0dd0ec-4ab2-11eb-34ce-d16073a73f39
# ╟─24c749a8-4a95-11eb-1fc8-f34a2d08bdbe
# ╟─4e6b1406-4a95-11eb-0827-432daf4b223e
# ╟─fff0ff7a-4a94-11eb-1821-fbc6796d2e2d
