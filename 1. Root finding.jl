### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 14d058ad-8ef9-4929-8975-c63f5b4b45ac
begin
	using Pkg
	Pkg.add("ForwardDiff")
end

# ╔═╡ 631af3ab-cf2d-47c5-bdb9-014ec30bf2b7
md"""
# Intermediate Julia for scientific computing
"""

# ╔═╡ adadf28b-fc27-487a-8264-92747c0df902
md"""
This workshop is designed to introduce two fundamental concepts in Julia: **types** and **metaprogramming**.

In order to cover various key uses of types in Julia, we have chosen to frame the discussion around a concrete topic in scientific computing, namely **root-finding**. 
The goal is *not* to learn algorithms for root finding *per se*, but rather to have a (pseudo-)real context in which to explore various concepts centered around types and how they arise naturally in real applications of Julia, in particular applications of **multiple dispatch**, which is one of the core choices in Julia that differentiate it from other common languages.

We will implement a couple of root-finding algorithms just to have something to work with. These will just be toy implementations that are far away from the best implementations. 

Instead we should use one of the high-quality packages that are available in Julia for this purpose. The large number of them shows the importance of root finding. The ones that I am aware of are the following (in alphabetical order):
"""

# ╔═╡ 63574266-dcf4-4430-994e-001f20bad887
md"""
- Single root of a nonlinear function:
    - [`NLsolve.jl`](https://github.com/JuliaNLSolvers/NLsolve.jl)
    - [`Roots.jl`](https://github.com/JuliaMath/Roots.jl)

- All roots of polynomial:
    - [`HomotopyContinuation.jl`](https://www.juliahomotopycontinuation.org)
    - [`PolynomialRoots.jl`](https://github.com/giordano/PolynomialRoots.jl)
    - [`Polynomials.jl`](https://github.com/JuliaMath/Polynomials.jl)
    
- All roots of a nonlinear function:
    - [`ApproxFun.jl`](https://github.com/JuliaApproximation/ApproxFun.jl)
    - [`IntervalRootFinding.jl`](https://github.com/JuliaIntervals/IntervalRootFinding.jl)
    - [`MDBM.jl`](https://github.com/bachrathyd/MDBM.jl)
    - [`Roots.jl`](https://github.com/JuliaMath/Roots.jl)
"""

# ╔═╡ 1cf19f60-7e52-406b-b2c9-baad3544aea8
md"""
Each of these uses different techniques, with different advantages and disadvantages.
"""

# ╔═╡ 77899e06-1642-4336-b5ca-daed74fad1b4
md"""
The challenge exercise for the workshop is: develop a package which integrates all of these disparate packages into a coherent whole!
"""

# ╔═╡ c235a33d-8e07-4018-ad5e-8617e084f573
md"""
### Logistics of the workshop
"""

# ╔═╡ c9f7f7e3-b5c3-4296-a56a-d941fae5efb0
md"""
The workshop is based around a series of exercises to be done during the workshop. We will pause to work on the exercises and then I will discuss possible solutions during the workshop.
"""

# ╔═╡ f5ec31bb-d2d4-4372-aeb6-940a6d9ccaa9
md"""
These techniques are useful for both users and developers; indeed, in Julia the distinction between users and developers is not useful, since it's much easier than in other languages to join the two categories together.
"""

# ╔═╡ 31266442-3d7a-449e-8135-88301250f5b3
md"""
### Outline
"""

# ╔═╡ 77261e8f-a2f5-48bb-a2ac-67808cfb78b4
md"""
We will start by quickly reviewing roots of functions and quickly reviewing one of the standard algorithms, **Newton's algorithm**. We will restrict to finding roots of 1D functions for simplicity.

Newton's algorithm requires the calculation of derivatives, for which several choices of algorithm are available. We will see how to encode the choice of algorithm using dispatch.

Then we will define types which will contain all information about a root-finding problem.
"""

# ╔═╡ 572b5bcc-5443-4194-bd3a-d735aa7363a4
md"""
## Roots
"""

# ╔═╡ 641b531f-a2f1-486f-a2c9-b5d566ac323a
md"""
Given a function ``f: \mathbb{R} \to \mathbb{R}`` (i.e. that accepts a single real number as argument and returns another real number), recall that a **root** or **zero** of the function is a number $x^*$ such that

$$f(x^*) = 0,$$

i.e. it is a solution of the equation $f(x) = 0$.

In general it is impossible to solve this equation exactly for $x^*$, so we use iterative numerical algorithms instead.
"""

# ╔═╡ 204fafc2-4005-4c97-8835-8c51dd6ba43b
md"""
#### Example
"""

# ╔═╡ f269a3f7-491e-476a-8251-bf7d892526ec
md"""
Recall that the function $f$ given by $f(x) := x^2 - 2$ has exactly two roots, at $x^*_1 = +\sqrt{2}$ and $x^*_2 = -\sqrt{2}$. Note that it is impossible to represent these values exactly using floating-point arithmetic.
"""

# ╔═╡ 8a123283-a780-4ec4-8ca1-693c661087c3
md"""
## Newton algorithm
"""

# ╔═╡ 6e8e8929-d22e-45d6-afd0-fd56a2317efd
md"Based on the following first order approximation:"

# ╔═╡ e44493cf-f7fa-40fa-8b33-3ee76052d24b
md"""
$${f(x_{n+1})} = f(x_n) + (x_{n+1} - x_n) {f'(x_n)}$$
"""

# ╔═╡ 45e4574f-f352-437b-92f8-2bbf3dc650cd
md"""
Hypothesizing ``x_{n+1}`` is a root

``{f(x_{n+1})} = f(x_n) + (x_{n+1} - x_n) {f'(x_n)} = 0``
"""

# ╔═╡ c4aa101d-7f7c-4aff-ada3-f1253962859c
md"""
The Newton algorithm for (possibly) finding a root of a nonlinear function $f(x)$ in 1D is the following iteration:
"""

# ╔═╡ 76159eac-ae3f-4999-af01-19c3617aeaab
md"""
$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)},$$

where $f'$ is the derivative of $f$. We start from an initial guess $x_0$ that can be almost anything (except points for which $f'(x_0) = 0$).
"""

# ╔═╡ 1f78d275-7b6f-48cf-8358-60d7ef2c51d1
md"""
#### Exercise 1
"""

# ╔═╡ 1a5f54d4-434e-4a3d-98df-b2b70f023d10
md"""
1. Implement the Newton algorithm for a fixed number $n$ of steps in a function `newton`, starting from a given starting point $x_0$.  

    Hint: Which information does the function require?


2. Does your function work with other number types, such as `BigFloat`? What do you need in order to run it with those types? Use it to calculate $\sqrt{2}$. How many decimal places are correct with the standard precision of `BigFloat`?
"""

# ╔═╡ e67d1b09-aa18-4914-811e-b695d256d801
f(x) = x^2 - 2

# ╔═╡ 5e738a26-487a-4879-8806-785dab351683
df(x) = 2x

# ╔═╡ ef85ca3b-f7af-4205-8dbe-b928a6df3f9a
"""
	newton_steps(f::Function, df::Function, x0::Float64, nsteps::Int64=10)

Newton root-finding of function `f`
with explicit derivative fn `df`.
Starting from `x₀`,
Returns `nsteps` toward root x: f(x) == 0.0
"""
function newton_steps(f::Function, df::Function, x₀::Float64, nsteps::Int64=10)
	x = x₀
	for n in 1:nsteps
		x = x - f(x)/df(x)
	end	
	return x
end

# ╔═╡ 15e80f75-f150-43a5-95ec-1eded7a2ee3d
"""
	newton(f::Function, df::Function, x0::Float64, n::Int64=10)

Newton root-finding of function `f`
with explicit derivative fn `df`.
Returns root x: f(x) == 0.0
"""
function newton(f::Function, df::Function, x0::Float64, n::Int64=10)
	x = x0
	x_new = -3.5

	num_iterations = 0

	for i in 1:n
		x_new = x - f(x) / df(x)

		x = x_new
	end

	return x_new
end

# ╔═╡ c2de19e1-cb00-4435-89a1-dedd7248fe66


# ╔═╡ 68e23b8d-e74e-495d-acec-5f608cea36fe
md"This algorithm oscillates between two near solutions, at numerical precision."

# ╔═╡ 3121853d-5bd1-4c16-9a0e-e5239bb450b7
newton_steps(f, df, 3.0, 7)

# ╔═╡ 3cb7e4a1-fecd-4a55-a0fa-759819c96fee
newton_steps(f, df, 3.0, 8)

# ╔═╡ de25cfec-8080-4cce-acf8-56e0028a3a3d
newton_steps(f, df, 3.0)

# ╔═╡ f0b69144-d578-4808-b7e2-13d16abf4abc
1e-128

# ╔═╡ 3417b888-c922-4e00-9053-afbda8038fcf
f(newton_steps(f, df, 3.0, 9)) # ≈ 0.0

# ╔═╡ 784b5ef2-e53d-431b-bedf-71c85045bfb0
sqrt(2)

# ╔═╡ a892e53e-9f96-408e-87b2-affc1340554b
md"""
## Calculating derivatives
"""

# ╔═╡ a5c74608-47c6-4034-b046-2a9885c0da9d
md"""
The Newton algorithm requires us to specify the derivative of a function. If $f$ is a complicated function, we certainly don't want to do that by hand.

One standard solution is to use a *finite-difference approximation* of the first derivative:

$$f'(a) \simeq \frac{f(a + h) - f(a - h)}{2h}.$$
Here we use the two-sided finite-difference approximation.
"""

# ╔═╡ 83f25a9b-24ca-45e9-bed6-c81fa283761f
md"""
#### Exercise 2
"""

# ╔═╡ 48bb1b5c-63d7-4fc7-a75b-13f71105095f
md"""
1. Implement a function `finite_difference` with a default value $h = 0.001$.


2. Implement a version of `newton` that does not take the derivative as argument and uses `finite_difference` to calculate the derivative. This version of `newton` should **re-use** the previous version by defining the function `fp` and calling that version.
"""

# ╔═╡ 3b84e81a-3e36-41c2-b16b-20a4e8c95f5c
"""
	finite_difference(f::Function, a::Float64, h::Float64=0.001)

two-side finite difference of `f` at `a`, step-size `h`.
"""
function finite_difference(f::Function, a::Float64, h::Float64=0.001)
    return ( f(a + h) - f(a - h) ) / (2h)
end

# ╔═╡ df21662e-3f94-4765-8925-9ab648e82752
"""
	newton(f::Function, x0::Float64, n::Int64=10)

Newton root-finding of function `f`
without explict derivative (use finite difference approx).
Returns root x: f(x) == 0.0
"""
function newton(f::Function, x0::Float64, n::Int64=10)
	x = x0
	x_new = -3.5

	num_iterations = 0

	for i in 1:n
		df = finite_difference(f, x)

		x_new = x - f(x) / df

		x = x_new
	end

	return x_new
end

# ╔═╡ aad415a8-bdd1-4698-a097-4f1a4ad4e3d9
begin
	g(x) = x^2 - 2
	dg(x) = 2x
end

# ╔═╡ 9e72e71f-cb58-4f88-a997-f69dc7b8ca6f
begin
	a = 3.0
	finite_difference(g, a)
end

# ╔═╡ 6d76b715-960f-4d27-bdb4-6da34af3959f
dg(a)

# ╔═╡ 8a03afb2-76ed-4a73-a909-22f6f0f0b56c
# finite diff with a larger step-size (less accurate)
finite_difference(g, a, 0.01)

# ╔═╡ 97151bb9-6905-48d7-a193-6b25985b2986
md"""
Mathematically: $x \mapsto f\prime(x)$
"""

# ╔═╡ a9368f4d-350e-4978-bec8-1bc873fa32a1
# this version defines the derivative fn as the finite diff,
# and then calls the newton method with the fn and its (approx) derivative.

function newton(f::Function, x0::Float64)
    # we need to calculate the derivative function dg
    df = x -> finite_difference(f, x)
    
    return newton(f, df, x0)   # using the previous method we defined
end

# ╔═╡ f3232e7a-2e69-4337-9352-4a4a9cc2e7ff
md"""
`newton` is a **generic function**
"""

# ╔═╡ e7d1b1be-ebc1-4f62-83a5-4e758047e1f1
md"""
### Algorithmic differentiation
"""

# ╔═╡ 85104806-f773-4785-885c-9d32cf51b93d
md"""
An alternative way to calculate derivatives is by using [**algorithmic differentiation**](https://en.wikipedia.org/wiki/Automatic_differentiation) (also called **automatic differentiation** or **computational differentiation**). This gives exact results (up to rounding error).


We will implement this algorithm in the next notebook, but for now let's just use the implementation in the excellent [`ForwardDiff.jl` package](https://github.com/JuliaDiff/ForwardDiff.jl).

"""

# ╔═╡ d394a4e8-c08c-4086-95a8-39901994b2ca
md"""
#### Exercise 3
"""

# ╔═╡ 6b5aa387-8f48-45fe-b9be-b0d427e833f1
md"""
1. Install `ForwardDiff.jl` if necessary.


2. Import it.


3. Define a function `forwarddiff` that uses the `ForwardDiff.derivative` function to calculate a derivative.
"""

# ╔═╡ 481a94d9-bc4f-4b0b-b808-65b4c80ec0ac
# ]add ForwardDiff

# ╔═╡ bdcce296-bffa-45fe-a658-1116331d9bb6
import ForwardDiff

# ╔═╡ 63ccc7f4-8cad-4cb3-b815-deff9f3f9a59
forwarddiff(f, x) = ForwardDiff.derivative(f, x)

# ╔═╡ 6cf3f90d-9c30-4cfe-a3eb-940f51b49dea
forwarddiff(g, a)

# ╔═╡ 064994f6-3823-4e43-a71d-00774804fd20
md"""
### Choosing between algorithms
"""

# ╔═╡ 718cec78-ed34-455f-9c24-c75b8b7d1f71
md"""
We now have two different algorithms available to calculate derivatives. This kind of situation is common in scientific computing; for example, the [`DifferentialEquations.jl`](http://docs.juliadiffeq.org/latest/) ecosystem has some 300 algorithms for solving differential equations. One of the techniques we will learn is how to easily be able to specify different algorithms.
"""

# ╔═╡ 92ecf5cd-d25d-45f9-95dc-504c354183cf
md"""
One possible solution is just by specifying the *function* to use as an argument to another function:
"""

# ╔═╡ 6189f7b2-9331-4f2b-bb58-760e46b03d82
md"""
#### Exercise 4
"""

# ╔═╡ a36de957-9ba5-45ad-8c82-3a21d3090fb7
md"""
1. Make a version of the Newton algorithm that takes an argument which is the algorithm to use to calculate the derivative. 

    Hint: Here we will just pass in the function as an argument by giving its name as a parameter.
"""

# ╔═╡ c6fbb9e8-91a3-4c67-981b-40043198a1bf
md"""
Make this a keyword argument
"""

# ╔═╡ 200bd89d-a14a-4e4f-ac5c-a0b5e769e2ad
function newton(f, x, derivative::Function)
     df = x -> derivative(f, x)
    
    return newton(f, df, x)
end

# ╔═╡ e2d57494-2109-41c7-afea-4e4b7f014538
newton(f, df, 3.0)

# ╔═╡ 90ca5a0b-41ca-49f7-b673-31a0c5bd97cc
newton(f, df, 3.0) ≈ sqrt(2)

# ╔═╡ d4dca943-58fe-40d1-b23a-eeb3c21a273a
methods(newton)

# ╔═╡ 651df39c-60ca-4e0d-a6fd-0f13722a7572
newton(g, a)

# ╔═╡ 81a95d09-e0f7-418e-bcf7-dca908c6384c
@which newton(g, a)

# ╔═╡ a9eca302-7939-4d9b-9b3c-48680c734379
methods(newton)

# ╔═╡ c266a1bf-94e6-43fd-ae7f-a5ccdef7cf4b
methods(newton)

# ╔═╡ d5bf6a90-e938-43dd-a852-8f5b2f13bb49
newton(g, a; derivative=forwarddiff)

# ╔═╡ b2c9ee3b-6805-4bd1-9bee-06714190cbe8
newton(g, a; derivative=finite_difference)

# ╔═╡ ef59ee59-1364-47aa-af21-7742e90a108e
newton(g, a, forwarddiff)

# ╔═╡ 6034cc3d-6153-4a71-a200-9f15a643677c
@which newton(g, a; derivative=forwarddiff)

# ╔═╡ 9b639977-9310-4682-a5a6-32ea7c4f7ae3
@which newton(g, a, forwarddiff)

# ╔═╡ bc4461c8-e563-4cf9-a53b-2a70b343efd7
md"""
For some purposes this technique of passing functions may be sufficient. In a later notebook we will see a more powerful technique to specify different algorithms.
"""

# ╔═╡ Cell order:
# ╟─631af3ab-cf2d-47c5-bdb9-014ec30bf2b7
# ╟─adadf28b-fc27-487a-8264-92747c0df902
# ╟─63574266-dcf4-4430-994e-001f20bad887
# ╟─1cf19f60-7e52-406b-b2c9-baad3544aea8
# ╟─77899e06-1642-4336-b5ca-daed74fad1b4
# ╟─c235a33d-8e07-4018-ad5e-8617e084f573
# ╟─c9f7f7e3-b5c3-4296-a56a-d941fae5efb0
# ╟─f5ec31bb-d2d4-4372-aeb6-940a6d9ccaa9
# ╟─31266442-3d7a-449e-8135-88301250f5b3
# ╟─77261e8f-a2f5-48bb-a2ac-67808cfb78b4
# ╟─572b5bcc-5443-4194-bd3a-d735aa7363a4
# ╟─641b531f-a2f1-486f-a2c9-b5d566ac323a
# ╟─204fafc2-4005-4c97-8835-8c51dd6ba43b
# ╟─f269a3f7-491e-476a-8251-bf7d892526ec
# ╟─8a123283-a780-4ec4-8ca1-693c661087c3
# ╟─6e8e8929-d22e-45d6-afd0-fd56a2317efd
# ╟─e44493cf-f7fa-40fa-8b33-3ee76052d24b
# ╟─45e4574f-f352-437b-92f8-2bbf3dc650cd
# ╟─c4aa101d-7f7c-4aff-ada3-f1253962859c
# ╟─76159eac-ae3f-4999-af01-19c3617aeaab
# ╟─1f78d275-7b6f-48cf-8358-60d7ef2c51d1
# ╟─1a5f54d4-434e-4a3d-98df-b2b70f023d10
# ╠═e67d1b09-aa18-4914-811e-b695d256d801
# ╠═5e738a26-487a-4879-8806-785dab351683
# ╠═ef85ca3b-f7af-4205-8dbe-b928a6df3f9a
# ╠═15e80f75-f150-43a5-95ec-1eded7a2ee3d
# ╠═c2de19e1-cb00-4435-89a1-dedd7248fe66
# ╠═df21662e-3f94-4765-8925-9ab648e82752
# ╠═e2d57494-2109-41c7-afea-4e4b7f014538
# ╟─68e23b8d-e74e-495d-acec-5f608cea36fe
# ╠═3121853d-5bd1-4c16-9a0e-e5239bb450b7
# ╠═3cb7e4a1-fecd-4a55-a0fa-759819c96fee
# ╠═de25cfec-8080-4cce-acf8-56e0028a3a3d
# ╠═f0b69144-d578-4808-b7e2-13d16abf4abc
# ╠═3417b888-c922-4e00-9053-afbda8038fcf
# ╠═784b5ef2-e53d-431b-bedf-71c85045bfb0
# ╠═90ca5a0b-41ca-49f7-b673-31a0c5bd97cc
# ╟─a892e53e-9f96-408e-87b2-affc1340554b
# ╟─a5c74608-47c6-4034-b046-2a9885c0da9d
# ╟─83f25a9b-24ca-45e9-bed6-c81fa283761f
# ╟─48bb1b5c-63d7-4fc7-a75b-13f71105095f
# ╠═3b84e81a-3e36-41c2-b16b-20a4e8c95f5c
# ╠═aad415a8-bdd1-4698-a097-4f1a4ad4e3d9
# ╠═9e72e71f-cb58-4f88-a997-f69dc7b8ca6f
# ╠═6d76b715-960f-4d27-bdb4-6da34af3959f
# ╠═8a03afb2-76ed-4a73-a909-22f6f0f0b56c
# ╟─97151bb9-6905-48d7-a193-6b25985b2986
# ╠═a9368f4d-350e-4978-bec8-1bc873fa32a1
# ╠═d4dca943-58fe-40d1-b23a-eeb3c21a273a
# ╠═651df39c-60ca-4e0d-a6fd-0f13722a7572
# ╠═81a95d09-e0f7-418e-bcf7-dca908c6384c
# ╟─f3232e7a-2e69-4337-9352-4a4a9cc2e7ff
# ╠═a9eca302-7939-4d9b-9b3c-48680c734379
# ╟─e7d1b1be-ebc1-4f62-83a5-4e758047e1f1
# ╟─85104806-f773-4785-885c-9d32cf51b93d
# ╟─d394a4e8-c08c-4086-95a8-39901994b2ca
# ╟─6b5aa387-8f48-45fe-b9be-b0d427e833f1
# ╠═14d058ad-8ef9-4929-8975-c63f5b4b45ac
# ╠═481a94d9-bc4f-4b0b-b808-65b4c80ec0ac
# ╠═bdcce296-bffa-45fe-a658-1116331d9bb6
# ╠═63ccc7f4-8cad-4cb3-b815-deff9f3f9a59
# ╠═6cf3f90d-9c30-4cfe-a3eb-940f51b49dea
# ╟─064994f6-3823-4e43-a71d-00774804fd20
# ╟─718cec78-ed34-455f-9c24-c75b8b7d1f71
# ╟─92ecf5cd-d25d-45f9-95dc-504c354183cf
# ╟─6189f7b2-9331-4f2b-bb58-760e46b03d82
# ╟─a36de957-9ba5-45ad-8c82-3a21d3090fb7
# ╠═c266a1bf-94e6-43fd-ae7f-a5ccdef7cf4b
# ╟─c6fbb9e8-91a3-4c67-981b-40043198a1bf
# ╠═d5bf6a90-e938-43dd-a852-8f5b2f13bb49
# ╠═b2c9ee3b-6805-4bd1-9bee-06714190cbe8
# ╠═200bd89d-a14a-4e4f-ac5c-a0b5e769e2ad
# ╠═ef59ee59-1364-47aa-af21-7742e90a108e
# ╠═6034cc3d-6153-4a71-a200-9f15a643677c
# ╠═9b639977-9310-4682-a5a6-32ea7c4f7ae3
# ╟─bc4461c8-e563-4cf9-a53b-2a70b343efd7
