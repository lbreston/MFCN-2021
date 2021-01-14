### A Pluto.jl notebook ###
# v0.12.18

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

# ╔═╡ e247f032-54a3-11eb-118a-ad95856adfdf
begin
	using PlutoUI
	using Plots
	using LinearAlgebra
	using Markdown
	using Pkg
	Pkg.add(["LaTeXStrings"
			 "WAV"
	         "Distributions"])
	using Statistics
    using Distributions 
	using WAV
	using LaTeXStrings
	
end

# ╔═╡ 776dd5ac-55d8-11eb-19f1-cddcdfe4a8bd
begin	
	v1_slider = @bind v1 Slider(-2:0.1:2, default=1, show_value=false)
	v2_slider = @bind v2 Slider(-2:0.1:2, default=1, show_value=false)
	

	md"""**Vectors in $\mathbb{R}^2$**
	
	`v1` = $(v1_slider) `v2` = $(v2_slider)
	
	"""
end

# ╔═╡ bccda064-55d8-11eb-2c24-7786668da45f
begin
	s = [string(v1), string(v2)]
	pad = maximum([4, maximum(map(length,s))])
	for i=1:length(s)
		s[i] = " "^(pad - length(s[i])) * s[i]
	end
	
	top = join("V = [$(s[1])]")
	bot = join("    [$(s[2])]")
	Text(join([top, bot], "\n"))	
end

# ╔═╡ 79941490-55d8-11eb-1480-1baa319e5937
let
	
	lims = (
		-2,
		 2
	)
	

	scatter([0], [0], xlims = lims, ylims = lims, legend = false,   aspect_ratio=:equal, 
		title = latexstring("Vectors\\ in\\ \\mathbb{R}^2")) 

	quiver!([0], [0], quiver = ([v1],[0]), color = [:blue],linewidth=2)
	
	quiver!( [0], [0], quiver = ([0],[v2]), color = [:orange],linewidth=2)
	
	quiver!([0], [0], quiver = ([v1],[v2]), color = [:black],linewidth=2)
	
	quiver!([0], [v2], quiver = ([v1],[0]), color = [:blue],linewidth=1,linestyle=:dash)
	
	quiver!( [v1], [0], quiver = ([0],[v2]), color =[:orange],linewidth=1,linestyle=:dash)
	
	

	
end

# ╔═╡ c00af2a8-5519-11eb-24d8-1352cb94a088
md"""**Color Vectors**"""

# ╔═╡ 1e68d4de-551a-11eb-2ff9-3beb9e8206ae
begin
	
	function Base.:+(c1::RGB,c2::RGB)
		RGB(c1.r+c2.r,c1.g+c2.g,c1.b+c2.b)
	end
	
	function Base.:*(a::Number,c::RGB)
		RGB(c.r*a,c.g*a,c.b*a)
	end
	
	function Base.:*(c::RGB,a::Number)
		RGB(c.r*a,c.g*a,c.b*a)
	end

end

# ╔═╡ afe83b70-5515-11eb-1e49-bd2fa096234d
ColorVectors=(RGB(1,0,0),RGB(0,1,0),RGB(0,0,1))

# ╔═╡ 9d8569de-5516-11eb-36d6-49d3df2de67e
begin	
	c1_slider = @bind c_1 Slider(-1:0.01:1, default=.9, show_value=true)
	c2_slider = @bind c_2 Slider(-1:0.01:1, default=.8, show_value=true)
	c3_slider = @bind c_3 Slider(-1:0.01:1, default=.8, show_value=true)
	
	

	md"""**Color Vectors**
	
	`C_1` = $(c1_slider) `C_2` = $(c2_slider) `C_3` = $(c3_slider) 
	
	"""
end

# ╔═╡ 043c7b04-5517-11eb-37d6-53e588672ad3
c_1*ColorVectors[1]+c_2*ColorVectors[2]+c_3*ColorVectors[3]

# ╔═╡ 51f40df6-551e-11eb-2327-4530109f4f30
pts=vcat([i*ColorVectors[1]+j*ColorVectors[2]+k*ColorVectors[3] for i=0:.05:1, j=0:.05:1,k=0:.05:1]...);

# ╔═╡ cd33c204-55d7-11eb-1c7c-a7432a04c390
begin
	showspan = @bind sspan CheckBox(default=false)
	md""" Show Span $(showspan)"""
end

# ╔═╡ aab4934c-551f-11eb-25cb-9589a45b14fc
begin
	
	if sspan
		gr()
 		scatter(map(x->x.r,pts),map(x->x.g,pts), map(x->x.b,pts),color=pts,colorbar=false,legend=false)
	end

end



# ╔═╡ 48870198-551a-11eb-24c3-c75e10239646
md"""**Music Vectors**"""

# ╔═╡ 33c0e8c4-551a-11eb-2557-e5c962e07b91
begin
	struct Tone
		wave
	end
	
	function Tone(f::Number)
		Tone(genwave(f))
	end

	function Base.:+(s1::Tone,s2::Tone)
		Tone(s1.wave.+s2.wave)
	end
	
	function Base.:*(s::Tone,a::Real)
		Tone(a*s.wave)
	end
	
	function Base.:*(a::Real,s::Tone)
		Tone(a*s.wave)
	end
	
	function plottone(s::Tone)
		plot(s.wave[1:60000],legend=false)
	end
	
	function play(s::Tone)
		wavplay(s.wave,20e3)
	end
	
	function genwave(f)
	fs = 20e3
	t = 0.0:1/fs:prevfloat(6.0)
	y = sin.(2pi * f * t) * 0.2
	end
	
end

# ╔═╡ ef75069e-5509-11eb-0f5a-39051b6cdc4c
begin

	C=Tone(261.6256)
	D=Tone(293.6648)
	E=Tone(329.6276)
	F=Tone(349.2282)
	G=Tone(391.9954)
	A=Tone(440.0000)
	B=Tone(493.8833)
	
	C_slider = @bind c Slider(0:.1:1, default=1, show_value=false)
	D_slider = @bind d Slider(0:0.1:1, default=0, show_value=false)
	E_slider = @bind e Slider(0:0.1:1, default=1, show_value=false)
	F_slider = @bind f Slider(0:0.1:1, default=0, show_value=false)
	G_slider = @bind g Slider(0:0.1:1, default=1, show_value=false)
	A_slider = @bind a Slider(0:0.1:1, default=0, show_value=false)
	B_slider = @bind b Slider(0:0.1:1, default=0, show_value=false)
	
	playbutton = @bind playbtn CheckBox(default=false)
	
	
	md"""
	
	`C` = $(C_slider) `D` = $(D_slider) `E` = $(E_slider) `F` = $(F_slider)\
	 `G` = $(G_slider) `A` = $(A_slider) `B` = $(B_slider)\
	 Play $(playbutton)
	
	"""
end

# ╔═╡ 46b962c4-550f-11eb-21b2-a3bca303fc03
begin
	gr()
	Chord=c*C+d*D+e*E+f*F+g*G+a*A+b*B
	plottone(Chord)
end

# ╔═╡ fb421b38-54fd-11eb-3032-8d3a768de998
begin
	if playbtn
		play(Chord)
	end
end

# ╔═╡ 9b1d59a6-54ba-11eb-3cd3-adc95a1f7f42
md""" **2-D Linear Transformations**"""

# ╔═╡ e8dedb72-55dc-11eb-183d-cb5b6074c6ac
begin
	showeig = @bind seig CheckBox(default=false)
	md""" Show Eigenvectors $(showeig)"""
end

# ╔═╡ 56104088-54b2-11eb-0689-8d5f75f2412f
begin
	
	function scale(k::Number)
		[k 0; 0 k]
	end
	
	function scale(k1::Number,k2::Number)
		[k1 0; 0 k2]
	end
	
	function rotate(θ::Number)
		round.([cos(θ) -sin(θ); sin(θ) cos(θ)],digits=3)
	end
	
	function shear(k1::Number,k2::Number)
		[1 k1; k2 1]
	end
	
	function reflect(l::Vector)
		(1/norm(l)^2)*[l[1]^2-l[2]^2 2*l[1]*l[2]; 2*l[1]*l[2] l[2]^2-l[1]^2]
	end
	
	function project(u::Vector)
		(1/norm(u)^2)*[u[1]^2 u[1]*u[2]; u[1]*u[2] u[2]^2]
	end

end

# ╔═╡ 0d092c9e-55dc-11eb-2027-a7b6037cba45
T=rotate(pi/2)

# ╔═╡ f4567bd0-5585-11eb-342c-9f12345215da
md"""**Other Transformations**"""

# ╔═╡ fe8b293c-5582-11eb-123e-1f8cc099673b
begin
	function threeDproject()
		rand(Float64,3,2)
	end
	
	function changebasis(newbasis::Matrix)
		newbasis^-1
	end
	
	function randSymmetric(n::Number)
		Symmetric(rand(Float64,n,n))
	end

end

# ╔═╡ 5c04e126-5585-11eb-04d9-a91a21785791
begin
	function gennormdist(dim::Number,numpts::Number)
		rand(Normal(),numpt,dim)
	end

	function gennormdist(dim::Number,numpts::Number,cov)
		(cov*rand(Normal(),numpts,dim)')'
	end
end

# ╔═╡ 686c07fa-55d7-11eb-18c4-f7ab471791a6
md"""**Principal Component Analysis**"""

# ╔═╡ bb11b3f4-5584-11eb-2d7d-d1145cf6ee6e
let
	dist=gennormdist(2,1000,randSymmetric(2))
	P1=scatter(dist[:,1],dist[:,2],aspect_ratio=:equal,legend=false,xlabel="X_1",ylabel="X_2",title="Data")
	empcov=cov(dist)
	ev=eigvecs(empcov)
	
		quiver!([0], [0], quiver = ([ev[1,2]],[ev[2,2]]),color=:orange,linewidth=3,label="PC 1")
	quiver!([0], [0], quiver = ([ev[1,1]],[ev[2,1]]),color=:red,linewidth=3,label="PC 2")

	
	disteigen=(changebasis(ev)*dist')'
	P2=scatter(disteigen[:,2],disteigen[:,1],legend=false,aspect_ratio=:equal,xlabel="PC_1",ylabel="PC_2",title="Data in Eigenbasis")
	
	plot(P1,P2)

end


# ╔═╡ 827d267e-55d7-11eb-1ffa-1bf666255485
md"""**Dimensionality Reduction**"""

# ╔═╡ 3268cc04-54e9-11eb-0ebe-7d59264c3633
function hyperbolic(x)
	[log.(sqrt.(x[1,:]./x[2,:]))';sqrt.(x[1,:].*x[2,:])']
end

# ╔═╡ eade9934-54e3-11eb-0675-edc5ac2b5154
	function hline(y,xlims,numpts)
		X=reshape(collect(range(xlims[1], xlims[2], length=numpts)),1,numpts)
		Y=y*ones(1,numpts)
		return vcat(X,Y)
	end

# ╔═╡ f4c7c026-54e3-11eb-28a0-51e1f8647bbb

	function vline(x,ylims,numpts)
		X=x*ones(1,numpts)
		Y=reshape(collect(range(ylims[1], ylims[2], length=numpts)),1,numpts)
		return vcat(X,Y)
	end

# ╔═╡ 51b04b00-54b7-11eb-0019-c73281da5d9f
begin
	
	mutable struct Grid
		gridlines
	end
	
	function Grid(xlim,ylim,numpts)
		hlines=[hline(i,xlim,numpts) for i = ylim[1]:1:ceil(ylim[2])]
		vlines=[vline(i,ylim,numpts) for i = xlim[1]:1:ceil(xlim[2])]
		glines=vcat(hlines,vlines)
		Grid(glines)
	end
	
	function Grid(lim::Number,numpts)
		xlim=(-lim,lim)
		ylim=(-lim,lim)
		hlines=[hline(i,xlim,numpts) for i = floor(ylim[1]):1:ceil(ylim[2])]
		vlines=[vline(i,ylim,numpts) for i = floor(xlim[1]):1:ceil(xlim[2])]
		glines=vcat(hlines,vlines)
		Grid(glines)
	end
	
	function transform!(G::Grid,f::Function)
		G.gridlines=map(x->f(x),G.gridlines)
	end
	
	function transform!(G::Grid,M::Matrix)
		G.gridlines=map(x->M*x,G.gridlines)
	end
	
	function plotgrid(G::Grid)
		plot(hcat(map(x->x[1,:],G.gridlines)...),hcat(map(x->x[2,:],G.gridlines)...),color=:grey)
	end
	
	function plotgrid!(G::Grid)
		plot!(hcat(map(x->x[1,:],G.gridlines)...),hcat(map(x->x[2,:],G.gridlines)...),color=:grey2,linewidth=.5)
	end
	

end

# ╔═╡ 3fd29710-55db-11eb-1721-3db5b2ca8d4e
begin
	
	G1=Grid(10,2)
	
	transform!(G1,T)
	
	evt=eigvecs(T)
		
	evv=eigvals(T)
	
	lims = (
		-3,
		 3
	)
	
	S=scatter([0], [0], xlims = lims, ylims = lims, legend = false,   aspect_ratio=:equal) 
	
	plotgrid!(G1)

	quiver!([0], [0], quiver = ([T[1,1]],[T[2,1]]), color = [:blue],linewidth=2)
	
	quiver!( [0], [0], quiver = ([T[1,2]],[T[2,2]]), color = [:orange],linewidth=2)
	
	if seig
		if isa(evv[1],Real)
		quiver!([0], [0], quiver = ([evt[1,1]],[evt[2,1]]), color = [:red],linewidth=2)
		end
		if isa(evv[2],Real)
		quiver!( [0], [0], quiver = ([evt[1,2]],[evt[2,2]]), color = [:green],linewidth=2)
		end
	end
	
	plot(S)
	
	
end

# ╔═╡ 34ebf146-5592-11eb-35c0-d13a7c5b5319
let
	dist=gennormdist(3,1000,randSymmetric(3))
			P1=scatter(dist[:,1], dist[:,2], dist[:,3], aspect_ratio=:equal, legend=false, xlabel="X_1", ylabel="X_2", zlabel="X_3", title="Data")
		empcov=cov(dist)
	ev=eigvecs(empcov)
		quiver!([0], [0], quiver = ([ev[1,3]],[ev[2,3]],[ev[3,3]]), color=:orange, linewidth=3)
	quiver!([0], [0], quiver = ([ev[1,2]],[ev[2,2]],[ev[3,2]]), color=:red,linewidth=3)
	quiver!([0], [0], quiver = ([ev[1,1]],[ev[2,1]],[ev[3,1]]), color=:yellow, linewidth=3)
	
	G=Grid(4,2)
	
	transform!(G,ev[:,2:3])
	
	plotgrid!(G)
	
	disteigen=(changebasis(ev)*dist')'
	P2=scatter(disteigen[:,3], disteigen[:,2], aspect_ratio=:equal, legend=false,xlabel="PC_1", ylabel="PC_2", title="2D Projection")
	
	plot(P1, P2)
end
	

# ╔═╡ Cell order:
# ╟─e247f032-54a3-11eb-118a-ad95856adfdf
# ╟─776dd5ac-55d8-11eb-19f1-cddcdfe4a8bd
# ╟─bccda064-55d8-11eb-2c24-7786668da45f
# ╟─79941490-55d8-11eb-1480-1baa319e5937
# ╟─c00af2a8-5519-11eb-24d8-1352cb94a088
# ╟─1e68d4de-551a-11eb-2ff9-3beb9e8206ae
# ╠═afe83b70-5515-11eb-1e49-bd2fa096234d
# ╟─9d8569de-5516-11eb-36d6-49d3df2de67e
# ╟─043c7b04-5517-11eb-37d6-53e588672ad3
# ╟─51f40df6-551e-11eb-2327-4530109f4f30
# ╟─cd33c204-55d7-11eb-1c7c-a7432a04c390
# ╟─aab4934c-551f-11eb-25cb-9589a45b14fc
# ╟─48870198-551a-11eb-24c3-c75e10239646
# ╟─33c0e8c4-551a-11eb-2557-e5c962e07b91
# ╟─ef75069e-5509-11eb-0f5a-39051b6cdc4c
# ╟─46b962c4-550f-11eb-21b2-a3bca303fc03
# ╟─fb421b38-54fd-11eb-3032-8d3a768de998
# ╟─9b1d59a6-54ba-11eb-3cd3-adc95a1f7f42
# ╠═0d092c9e-55dc-11eb-2027-a7b6037cba45
# ╟─e8dedb72-55dc-11eb-183d-cb5b6074c6ac
# ╟─3fd29710-55db-11eb-1721-3db5b2ca8d4e
# ╠═56104088-54b2-11eb-0689-8d5f75f2412f
# ╟─f4567bd0-5585-11eb-342c-9f12345215da
# ╟─fe8b293c-5582-11eb-123e-1f8cc099673b
# ╟─5c04e126-5585-11eb-04d9-a91a21785791
# ╟─686c07fa-55d7-11eb-18c4-f7ab471791a6
# ╟─bb11b3f4-5584-11eb-2d7d-d1145cf6ee6e
# ╟─827d267e-55d7-11eb-1ffa-1bf666255485
# ╠═34ebf146-5592-11eb-35c0-d13a7c5b5319
# ╟─51b04b00-54b7-11eb-0019-c73281da5d9f
# ╟─3268cc04-54e9-11eb-0ebe-7d59264c3633
# ╟─eade9934-54e3-11eb-0675-edc5ac2b5154
# ╟─f4c7c026-54e3-11eb-28a0-51e1f8647bbb
