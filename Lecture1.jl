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
			"Plots"
			"LinearAlgebra"
			])
	using PlutoUI
	using GraphRecipes
	using Plots
	using LinearAlgebra
end

# ╔═╡ 5e4a2940-4e49-11eb-344d-ed607b1378b3
md"""
# Algorithms in Neuroscience 

The goal of this lecture is to learn how to use computational principals to understand natural phenomena.

Biological systems, of all scales, have evolved to solve the challenges posed by their environments inorder to give themselves the best chance of survival and reproduction. **Algorithms** are processes or sets of rules used to solve classes of problems, which makes them a powerful tool to systemitize and describe these natural strategies. 

"""

# ╔═╡ 15a3dbe6-4e35-11eb-1ec7-8fec8f864b9d
md"""

## Marr's Levels of Analysis

1. Computational: what does the system do, and why does it do these things 
2. Algorithmic/representational level: how does the system do what it does
3. Implementational/physical level: how is the system physically realized

"""

# ╔═╡ 5d41cf54-4e3e-11eb-2eea-ab2e13cc25bd
html"""
<p align="center">
<img src="https://github.com/lbreston/MFCN-2021/blob/main/MarrLevels.png?raw=true">
</p>
"""


# ╔═╡ 27b8a530-4e41-11eb-1cfb-d97730a51570
md"""

## Reinforcement Learning 

**Reinforcement Learning (RL)** is the process by which an **agent** learns to act in its environment such that it maximizes its cummulative reward. 

Understanding RL is a fundamental challenge for neuroscience because it underpins how the brain learns to behave!

**Challenges Facing RL**
1. Curse of Dimensionality _i.e._ the world is way too complex brute force for trial and error
2. **Temporal Credit Assignment** 
3. Imperfect Information 
4. **Exploration-Exploitation Dilemma**
5. ...

"""

# ╔═╡ 2c4139f8-4e50-11eb-0ec6-1bfbffaee0d4
md"""

#### Temporal Credit Assignment 
Using Marr's framework what **Computational** problem must RL solve? 

An agent must bind rewards to temporally distal prior states and actions. 

We must introduce some symbols to describe this problem algebraically

Let $S_{t}$ be the state of the agent and environment at time $t$. Let $\pi$ be a policy, or a set of state-action pairs, $r_{t}$ be the reward at $S_{t}$, and $\lambda$ be the discount rate. $V^{\pi}\left(S_{t}\right)$ is the value of the state $S_{t}$ under the policy $\pi$.

$V^{\pi}\left(S_{t}\right)=\sum_{t'=0}^{\infty} \lambda^{t'}r_{t+t'}$

That is the value of the current state is the discounted sum of all the expected future rewards. 

To derive an **Algorithm** to learn $V^{\pi}\left(S_{t}\right)$ we start by splitting the sum.

$V^{\pi}\left(S_{t}\right)=r_{t}+\sum_{t'=0}^{\infty} \lambda^{(t+1)+t'}r_{(t+1)+t'}$

We can now recursively define the function as 

$V^{\pi}\left(S_{t}\right)=r_{t}+V^{\pi}\left(S_{t+1}\right)$

This recursive formulation gives us the simple learning rule 

$V^{\pi}\left(S_{t}\right)=V^{\pi}\left(S_{t}\right)+\alpha\left[r_{t}+\lambda V^{\pi}\left(S_{t+1}\right)\text{-}V^{\pi}\left(S_{t}\right)\right]$

where $\alpha$ is the learning rate and $\left[r_{t}+\lambda V^{\pi}\left(S_{t+1}\right)\text{-}V^{\pi}\left(S_{t}\right)\right]$ is the reward prediction error.

This **Temporal-Difference (TD) Learning**!


"""

# ╔═╡ 6bea0ad8-4e5e-11eb-230a-51f2820c6ec7
md"""

#### TD Learning in the Brain 

How might TD learning be **implemented** in the brain?

Dopaminergic activity in the sNC has been shown to indicate reward prediction error which could provide a substrate for neural TD learning. 

"""


# ╔═╡ 95b7acda-4e60-11eb-09f7-d168de63b57b
html"""
<p align="center">
<img src="https://github.com/lbreston/MFCN-2021/blob/main/TDdopamine.png?raw=true">
</p>
"""

# ╔═╡ 1e02451c-4e61-11eb-1fd0-e705e87fa33e
md"""

#### Exploration-Exploitation Dilemma

To find the most optimal policy, agents must thoroughly search the space of possible states. However, practical contstraints require the agent to balance this exploration against prioritize known, high value states. 

A common solution is to randomly sample states in porportion to their known value. One of the simplest sampling algorithms is called **$\bf{\varepsilon}$-greedy**. This algorithm samples the highest value state with probability $1-\varepsilon$ and samples a random state with probability $\varepsilon$.

"""

# ╔═╡ 91d6acd2-4e64-11eb-0b39-3f6955a15873
md"""

## TD Learning Example

Below is an implementation of TD learning to find the shortest path between two nodes on a graph. The Agent begins at the Start node, marked in red, and travels along the edges, from node to node, until it reaches the Terminal node, marked in blue, and recieves a reward. After each move the Agent updates its estimates for the value of each node which corresponds to how many moves it is away from the reward. 

"""


# ╔═╡ 1f206464-4df9-11eb-3d26-09e3d59d1040
md"Graph Size: $(@bind sz Slider(1:20; show_value=true)) Sparsity: $(@bind sparsity Slider(0:.01:1; show_value=true))"

# ╔═╡ 14583e2c-4df8-11eb-0666-cf93a37dbe1b
md"Start: $(@bind Start NumberField(1:sz)) End: $(@bind Terminal NumberField(1:sz;default=Int(floor(sz/2))))"

# ╔═╡ abe5ac8c-4df8-11eb-2b4c-77000fb32096
md"lamda: $(@bind l Slider(0:.01:1; default=0.8, show_value=true)) alpha: $(@bind a Slider(0:.01:1; show_value=true, default=.2)) epsilon: $(@bind e Slider(0:.01:1; show_value=true, default=.2))"

# ╔═╡ 7257b2b2-4e09-11eb-2748-abdc8ef6e67a
md"Run Sim: $(@bind run_sim CheckBox()) Iterations: $(@bind Iter NumberField(1:1000; default=100))"

# ╔═╡ 4778e366-4e6a-11eb-0c9a-8b3e8c5ec8e9
md"""
Defines **Graph Maze**
"""

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
		nodecolors[G.Terminal]=color("blue");
		
		nodecolors[G.Start]=cgrad(:Reds_3,2,categorical = true)[2]

graphplot(G.AdjMat,method=:circular,nodeshape=:circle,nodecolor=nodecolors,names=1:sz,nodesize=.25)
	end
	
end 

# ╔═╡ 24600f80-4e6a-11eb-0166-4799f5b6ce6d
md"""
Defines **Agent** 
"""

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
	
	function reset!(A::Agent)
		A.V=fill(0.0,length(A.V))
	end
	
end

# ╔═╡ d82dfc44-4e69-11eb-3960-ab41b32db40d
md"""
Implements **$\bf{\varepsilon}$-greedy** algorithm
"""

# ╔═╡ 17f20dee-4e69-11eb-25b2-b72383a37c87
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

# ╔═╡ fef53478-4e69-11eb-39cb-430341613636
md"""
Implements **TD Learning**
"""

# ╔═╡ 3d5e899a-4e69-11eb-03ea-7be5e5cdbd26
function update!(A::Agent,G::GraphMaze)
	current_state=G.Path[end];
	prior_state=G.Path[end-1];
		
	if isover(G)
		A.V[current_state]=1.0;
	end
		
	A.V[prior_state]=A.V[prior_state]+A.α*(A.λ*A.V[current_state]-A.V[prior_state]);
		
end

# ╔═╡ 5d11481a-4e6c-11eb-3d0d-55b99ec2f895
function step!(A::Agent,G::GraphMaze)
		
		if isover(G)
			reset!(G)
		end

		mv=choose_next_move(A,G);
		move!(G,mv);
		update!(A,G);

end
	

# ╔═╡ 5166a7b8-4dc9-11eb-2a3a-67dc6c8bdcc4
function plot(A::Agent,G::GraphMaze)	
	sz=length(A.V);
		
		
	    nodecolors=[cgrad([:white, :blue])[i] for i=A.V]
		
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

# ╔═╡ 5167ac6a-4e6d-11eb-0d17-a59befdd80f3
begin
	T=Tracker(G,A)
	run!(T)
end

# ╔═╡ d380e4ea-4e05-11eb-2e16-d791f1d97a1a
if run_sim
	reset!(G)
	reset!(A)
	T2=Tracker(G,A)
	run!(T2,Iter)
end

# ╔═╡ Cell order:
# ╟─008f3956-4a5e-11eb-24ea-03e93ce450e1
# ╟─5e4a2940-4e49-11eb-344d-ed607b1378b3
# ╟─15a3dbe6-4e35-11eb-1ec7-8fec8f864b9d
# ╟─5d41cf54-4e3e-11eb-2eea-ab2e13cc25bd
# ╟─27b8a530-4e41-11eb-1cfb-d97730a51570
# ╟─2c4139f8-4e50-11eb-0ec6-1bfbffaee0d4
# ╟─6bea0ad8-4e5e-11eb-230a-51f2820c6ec7
# ╟─95b7acda-4e60-11eb-09f7-d168de63b57b
# ╟─1e02451c-4e61-11eb-1fd0-e705e87fa33e
# ╟─91d6acd2-4e64-11eb-0b39-3f6955a15873
# ╟─1f206464-4df9-11eb-3d26-09e3d59d1040
# ╟─5b8a7b0c-4df8-11eb-1492-7d3f7c4d8720
# ╟─14583e2c-4df8-11eb-0666-cf93a37dbe1b
# ╟─732135ce-4e22-11eb-313e-7d706453b230
# ╟─abe5ac8c-4df8-11eb-2b4c-77000fb32096
# ╟─c81b67e4-4df9-11eb-3d33-a513b5e44b49
# ╠═5167ac6a-4e6d-11eb-0d17-a59befdd80f3
# ╟─7257b2b2-4e09-11eb-2748-abdc8ef6e67a
# ╟─d380e4ea-4e05-11eb-2e16-d791f1d97a1a
# ╟─4778e366-4e6a-11eb-0c9a-8b3e8c5ec8e9
# ╟─740f2128-4d8a-11eb-1f96-d92e5e1808cf
# ╟─24600f80-4e6a-11eb-0166-4799f5b6ce6d
# ╟─2966329c-4dad-11eb-1342-21c9ddd3d072
# ╟─d82dfc44-4e69-11eb-3960-ab41b32db40d
# ╠═17f20dee-4e69-11eb-25b2-b72383a37c87
# ╟─fef53478-4e69-11eb-39cb-430341613636
# ╠═3d5e899a-4e69-11eb-03ea-7be5e5cdbd26
# ╟─5d11481a-4e6c-11eb-3d0d-55b99ec2f895
# ╟─5166a7b8-4dc9-11eb-2a3a-67dc6c8bdcc4
# ╟─4cea4ede-4e01-11eb-2627-594f161dc6c9
# ╟─c86dec2a-4dd2-11eb-1268-cfd2b1371997
# ╟─1a262604-4d8d-11eb-3152-4be667b62808
