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

# ╔═╡ 008f3956-4a5e-11eb-24ea-03e93ce450e1
begin
	using Pkg
	Pkg.add([ 
			"GraphRecipes"
			"PlutoUI"
			"Images"
			"Plots"
			"LinearAlgebra"
			])
	using PlutoUI
	using GraphRecipes
	using Images
	using Plots
	using LinearAlgebra
end

# ╔═╡ 15a3dbe6-4e35-11eb-1ec7-8fec8f864b9d
md"""
# Computational Thinking & Reinforcement Learning

### Marr's Levels of Analysis
1. Computational: what does the system do, and why does it do these things 
2. Algorithmic/representational level: how does the system do what it does
3. Implementational/physical level: how is the system physically realized

"""


# ╔═╡ 5d41cf54-4e3e-11eb-2eea-ab2e13cc25bd
html"""

<iframe width="100%" height="450px" src="" frameborder="0"></iframe>

"""


# ╔═╡ 1f206464-4df9-11eb-3d26-09e3d59d1040
md"Graph Size: $(@bind sz Slider(1:20; show_value=true)) Sparsity: $(@bind sparsity Slider(0:.01:1; show_value=true))"

# ╔═╡ 14583e2c-4df8-11eb-0666-cf93a37dbe1b
md"Start: $(@bind Start NumberField(1:sz)) End: $(@bind Terminal NumberField(1:sz))"

# ╔═╡ abe5ac8c-4df8-11eb-2b4c-77000fb32096
md"lamda: $(@bind l Slider(0:.01:1; show_value=true)) alpha: $(@bind a Slider(0:.01:1; show_value=true)) epsilon: $(@bind e Slider(0:.01:1; show_value=true))"

# ╔═╡ 7257b2b2-4e09-11eb-2748-abdc8ef6e67a
md"Run Sim: $(@bind run_sim CheckBox()) Iterations: $(@bind Iter NumberField(1:1000))"

# ╔═╡ 740f2128-4d8a-11eb-1f96-d92e5e1808cf
begin
	
	mutable struct GraphMaze
		AdjMat
		Terminal
		Start
		Path
	end
	
	function GraphMaze(AdjMat,Terminal,Start)
		GraphMaze(AdjMat,Terminal,Start,Start)	
	end
	
	function avalible_moves(G::GraphMaze)
		current_state=G.Path[end];
		return findall(!iszero,G.AdjMat[current_state,:]);
	end
	
	function move!(G::GraphMaze,nextstate)
		G.Path=vcat(G.Path,nextstate);
	end
	
	function isover(G::GraphMaze)
		return G.Path[end]==G.Terminal
	end
	
	function reset!(G::GraphMaze)
		G.Path=G.Start
	end
	
	function plot(G::GraphMaze)	
		sz=size(G.AdjMat,1);
		
		nodecolors=fill(color("white"),sz);
		nodecolors[G.Terminal]=color("gold");
		
		lp=length(G.Path);
		
		
		path_colors=cgrad(:Reds_3,2,categorical = true);
		for i=1:min(2,lp) nodecolors[G.Path[end-i+1]]=path_colors[end-i+1];end;
		
graphplot(G.AdjMat,method=:circular,nodeshape=:circle,nodecolor=nodecolors,names=1:sz,nodesize=.25)
	end
	
end 

# ╔═╡ 2966329c-4dad-11eb-1342-21c9ddd3d072
begin 
	
	mutable struct Agent
		λ
		α
		ϵ
		V
	end
	
	function Agent(λ,α,ϵ,s::Number)
		Agent(λ,α,ϵ,fill(0.0,s))
	end
	
	function choose_next_move(A::Agent,G::GraphMaze)
		
		aval_moves=avalible_moves(G);
		vals=A.V[aval_moves];
		max_moves=aval_moves[findall(x->x==max(vals...),vals)]
		
		if rand(Float64)<A.ϵ
			return rand(aval_moves)
		else
			return rand(max_moves)
		end
		
	end
	
	function update!(A::Agent,G::GraphMaze)
		current_state=G.Path[end];
		prior_state=G.Path[end-1];
		
		if isover(G)
			A.V[current_state]=1.0;
		end
		
		A.V[prior_state]=A.V[prior_state]+A.α*(A.λ*A.V[current_state]-A.V[prior_state]);
		
	end
	
	function step!(A::Agent,G::GraphMaze)
		
		if isover(G)
			reset!(G)
		end

		mv=choose_next_move(A,G);
		move!(G,mv);
		update!(A,G);

	end
	
	
end


		

# ╔═╡ 5166a7b8-4dc9-11eb-2a3a-67dc6c8bdcc4
function plot(A::Agent,G::GraphMaze)	
	sz=length(A.V);
		
		#nodecolors=fill(color("white"),Int(sz));
		#nodecolors[G.Terminal]=color("gold");
	    nodecolors=[cgrad([:white, :gold])[i] for i=A.V]
		
		lp=length(G.Path);
	
		path_colors=cgrad(:Reds_3,2,categorical = true);

		
	for i=1:min(2,lp) nodecolors[G.Path[end-i+1]]=path_colors[end-i+1];end;
	
	path_mat=fill(0,sz,sz);
	for i=1:sz
		path_mat[i,i]=1.0
	end
	
	if lp≥2
		for i=1:lp-1
			path_mat[G.Path[i],G.Path[i+1]]=1;
			#path_mat[G.Path[i+1],G.Path[i]]=1;
		end
	end
	
graphplot(path_mat,method=:circular,nodeshape=:circle,nodecolor=nodecolors,names=1:sz,nodesize=.3,self_edge_size=0.0)
end

# ╔═╡ 1a262604-4d8d-11eb-3152-4be667b62808
function remove_self_loops!(AdjMat)
	for i=1:size(AdjMat,1)
		AdjMat[i,i]=0;
	end
	return AdjMat
end

# ╔═╡ c86dec2a-4dd2-11eb-1268-cfd2b1371997
function gen_adj_mat(size,sparsity)
	remove_self_loops!(Symmetric((rand(Float64,size,size).≥(1-sparsity))))
end

# ╔═╡ 5b8a7b0c-4df8-11eb-1492-7d3f7c4d8720
AdjMat=gen_adj_mat(sz,sparsity);

# ╔═╡ 732135ce-4e22-11eb-313e-7d706453b230
begin
	G=GraphMaze(AdjMat,Terminal,Start);
	plot(G)
end

# ╔═╡ c81b67e4-4df9-11eb-3d33-a513b5e44b49
begin
reset!(G);
A=Agent(l,a,e,sz);
end

# ╔═╡ 4cea4ede-4e01-11eb-2627-594f161dc6c9
begin
	
	mutable struct Tracker
		GraphMaze
		Agent
		Steps
		Values
	end
	
	function Tracker(G::GraphMaze,A::Agent)
		Tracker(G,A,1,transpose(A.V))
	end
	
	function run!(T::Tracker)
		step!(T.Agent,T.GraphMaze)
		T.Steps=T.Steps+1
		T.Values=vcat(T.Values,transpose(T.Agent.V))
		
		legend=fill("",1,size(T.Values,2))
		for i=1:size(T.Values,2)
			legend[1,i]=string(i)
		end
		
		Plots.plot(
		plot(A,G),
		Plots.plot(1:T.Steps,T.Values,label=legend,lw=3,legend = :outertopright,xlabel="Step",ylabel="Est V(state)"),
			layout = @layout([a b])
			)
	end
	
	function run!(T::Tracker,numsteps::Int)
		
		anim= @animate for i=1:numsteps
			run!(T)
		end
		
		gif(anim, "GMTracker.gif", fps=8)	
		

	end

		
	
end

# ╔═╡ d380e4ea-4e05-11eb-2e16-d791f1d97a1a
if run_sim
	T=Tracker(G,A)
	run!(T,Iter)
end

# ╔═╡ Cell order:
# ╠═008f3956-4a5e-11eb-24ea-03e93ce450e1
# ╟─15a3dbe6-4e35-11eb-1ec7-8fec8f864b9d
# ╠═5d41cf54-4e3e-11eb-2eea-ab2e13cc25bd
# ╟─1f206464-4df9-11eb-3d26-09e3d59d1040
# ╟─5b8a7b0c-4df8-11eb-1492-7d3f7c4d8720
# ╟─14583e2c-4df8-11eb-0666-cf93a37dbe1b
# ╟─732135ce-4e22-11eb-313e-7d706453b230
# ╟─abe5ac8c-4df8-11eb-2b4c-77000fb32096
# ╟─c81b67e4-4df9-11eb-3d33-a513b5e44b49
# ╟─7257b2b2-4e09-11eb-2748-abdc8ef6e67a
# ╟─d380e4ea-4e05-11eb-2e16-d791f1d97a1a
# ╟─740f2128-4d8a-11eb-1f96-d92e5e1808cf
# ╟─2966329c-4dad-11eb-1342-21c9ddd3d072
# ╟─5166a7b8-4dc9-11eb-2a3a-67dc6c8bdcc4
# ╟─4cea4ede-4e01-11eb-2627-594f161dc6c9
# ╟─c86dec2a-4dd2-11eb-1268-cfd2b1371997
# ╟─1a262604-4d8d-11eb-3152-4be667b62808
