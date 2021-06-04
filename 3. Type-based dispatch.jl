### A Pluto.jl notebook ###
# v0.10.0

using Markdown

# ╔═╡ 2f6fc837-618f-4744-858e-28dad9d2f775
md"""
# Structuring programs using types and dispatch
"""

# ╔═╡ c73da430-e748-4429-8ff3-f63281bc6f8d
md"""
Previously we specified an algorithm directly using a function. In many Julia packages it is common to use *dispatch* to do this. 

In Julia, **dispatch** refers to choosing which **method** (version) of a function to use, according to the type of the arguments. (**Multiple dispatch** is when the types of several different arguments are involved.)
"""

# ╔═╡ 4fa51095-fe68-4c4c-bae0-0c0be56d657d
md"""
Let's define some types to represent different differentiation methods.
"""

# ╔═╡ 88898edb-b537-4e97-a517-f680a6f6cadb
struct Dual 
    v::Float64
    d::Float64
end

# ╔═╡ 1163960f-1cc9-4be0-ab34-2017d946bd97
methods(Dual)

# ╔═╡ 70960c97-8a26-4184-b3e0-04e082be3ae3
md"""
#### Exercise 1

1. Define an abstract type `DifferentiationAlgorithm`.


2. Define subtypes `FiniteDifference`, `MyAutoDiff` (for our implementation) and `AutoDiff` (for the `ForwardDiff` implementation).


3. Implement the function `derivative(f, x, algorithm)` using **dispatch**: for each of the three types, define a version of this function in which `algorithm` is specified to be of that type by using the type annotation operator `::`.


4. Verify that these work by writing tests for them.
"""

# ╔═╡ 8ec4c43a-ced8-40e9-909b-407fd9fd5e3e
md"""
You could do:
"""

# ╔═╡ 8f8bb606-529b-48a4-b764-58b7b8e8a3c4
function derivative(f, x, algorithm)
    if algorithm == :newton
        ...
    elseif algorithm == :bisection
        ...
    elseif
        ...
    end
end

# ╔═╡ 4694a1a4-6cfd-4a4c-903e-cbc05273c805
abstract type DifferentiationAlgorithm end

# ╔═╡ ad270cbe-50c4-420e-8933-32311059edfc
struct FiniteDifference <: DifferentiationAlgorithm 
    h::Float64
end

# ╔═╡ b4baeb03-5440-473f-b647-ec26cf4723d2
struct AutoDiff <: DifferentiationAlgorithm end

# ╔═╡ 863168d7-3edf-4cf6-9ba8-7e4c70bd4a08
finite_difference(f, a, h) = (f(a + h) - f(a - h)) / (2h)

# ╔═╡ 059440d0-0608-42c0-8116-9579655587e0
using ForwardDiff
forwarddiff(f, x) = ForwardDiff.derivative(f, x)

# ╔═╡ dad1d696-95f4-42f5-84f1-1d6c9fefa064
function derivative(f, x, algorithm::AutoDiff)
    return forwarddiff(f, x)
end

# ╔═╡ 853ccf31-b2e9-4992-973f-90f276387baa
g(x) = x^2 - 2
a = 3.0

# ╔═╡ 2af17124-72e6-481e-b51a-0be606aa4d60
derivative(g, a, AutoDiff)

# ╔═╡ 8f0f06e7-702e-4a5e-9094-7b186c73c1d2
typeof(AutoDiff)

# ╔═╡ 1d4433e2-b975-459b-97c7-64dd1d3ef7e5
autodiff = AutoDiff()

# ╔═╡ abc977e2-4a6d-4f65-be87-3a60578678c9
typeof(autodiff)

# ╔═╡ 1819d25e-a6af-49f1-b539-10fcd7b8314c
derivative(g, a, autodiff)

# ╔═╡ 5309a69c-91c3-4f96-ac66-b3d0a3f35e5e
derivative(g, a, AutoDiff())

# ╔═╡ e8051097-4880-4743-b01f-667f1deeaa19
function derivative(f, x, algorithm::FiniteDifference)
    h = algorithm.h
    return finite_difference(f, x, h)
end

# ╔═╡ 82bcfbe5-0c8e-4de1-a0a3-5af79bb47d99
derivative(g, a, FiniteDifference())

# ╔═╡ 774b85de-6092-4ba4-bb54-535ac8a1da55
derivative(g, a, FiniteDifference(0.01))

# ╔═╡ 177204fd-80de-4af1-b6e8-f927c27ab176
algorithm = FiniteDifference(0.01)

# ╔═╡ aecf2e46-7b43-495e-97c3-e3b5d9760169
typeof(algorithm)

# ╔═╡ 2ac3a6ba-ac97-4ee3-a2ef-025239249e4b
algorithm.h

# ╔═╡ d34812a8-d0a9-420d-b45d-1b3537469c1b
fieldnames(typeof(algorithm))

# ╔═╡ 494373c4-ad57-4ccf-aed0-a03a40a36a21
FiniteDifference()

# ╔═╡ c36879fc-2bfd-440d-9b8a-6af436a1bf33
methods(FiniteDifference)

# ╔═╡ f738c7ca-7f57-4ba4-b0b1-a3111c5b92ee
FiniteDifference() = FiniteDifference(0.001)

# ╔═╡ f1cf1db1-fe38-43e1-a889-8be440808920
methods(FiniteDifference)

# ╔═╡ af011373-9e85-41d0-aec2-f51c82fdf309
FiniteDifference()

# ╔═╡ 93b2eebb-c897-4fae-a5ce-15de2a1fb7d2
derivative(g, a, FiniteDifference() )

# ╔═╡ 27e7305b-f45a-4bdf-b7bb-f04276e47155
methods(derivative)

# ╔═╡ 920ae67c-7eb7-4a96-aa39-39f7ca5d7e4f
md"""
#### Exercise 2
"""

# ╔═╡ e5239a2e-e8cb-475f-b233-f15ad1f3a341
md"""
1. Write a version of the Newton algorithm that takes an optional keyword argument `algorithm` specifying the differentiation algorithm to use, and which has a default value of `AutoDiff`.
"""

# ╔═╡ 479e76bb-04c6-4fb4-bd63-ffdcb26e8698
function newton(f, x0, n=10; 
                    algorithm::DifferentiationAlgorithm=AutoDiff())
    
    df = x -> derivative(f, x, algorithm)
    
#     newton(f, df, x0)
    
end

# ╔═╡ c62ce657-e2cc-4ce1-bb49-da559de9468d
newton(g, a)

# ╔═╡ 8f798db9-7bd7-4600-85bb-dc05f4ab78d8


# ╔═╡ 77537c19-12d9-44df-8416-dc83420da1c1
md"""
## Functions as types
"""

# ╔═╡ 03d223a9-7e83-44fd-a64b-ad2fa4fa84b1
md"""
How could we differentiate the `sin` function? Of course, we can do it using e.g. finite differences, but in cases like this we actually know the exact, analytical derivative, in this case `cos`, i.e $\sin'(x) = \cos(x)$.
Is there are a way to tell Julia to use this directly? I.e. if `f` is equal to the `sin` function, then we should make a special version of our `derivative` function.

It turns out that there is, using dispatch, by checking what *type* the `sin` function has:
"""

# ╔═╡ 6394c964-76ee-4407-ad7e-c40dd604437e
md"""
#### Exercise 3

1. Use `typeof` to find the type of the `sin` function.


2. Use this to make a special dispatch for `derivative(sin, x)`.
"""

# ╔═╡ bb6fc1f5-3187-4ff5-b55d-dac2ba4760df
typeof(sin)

# ╔═╡ 2f9cbeea-2c70-41db-bfff-396a230cb082
derivative(::typeof(sin), x) = cos(x)

# ╔═╡ d12d4eaf-01a7-4a68-8ec4-cb6cbfcb4212


# ╔═╡ 453d9e55-6a41-45be-8a6b-31e4e43c9b46
md"""
The package [`ChainRules.jl`](https://github.com/JuliaDiff/ChainRules.jl) contains definitions like this and is used inside `ForwardDiff.jl` and other packages that need to know the derivatives of functions.
"""

# ╔═╡ 66b7df82-c476-4e94-9f54-fbc26042a1ba
md"""
## Representing a problem using a type
"""

# ╔═╡ 4bc25a40-68fb-46c5-8099-b4b2c82120ee
md"""
A root-finding problem requires several pieces of information: a function, a starting point, a root-finding algorithm to use, possibly a derivative, etc. We could just pass all of these as arguments to a function.
An alternative is to wrap up the various pieces of information into a new composite type.
"""

# ╔═╡ 0cdcf1aa-560f-4b0b-8421-3d341d5bd8be
md"""
#### Exercise 4

1. Make a `RootAlgorithm` abstract type.


2. Make a `Newton` subtype.


3. Make `Newton` a *callable* type using the syntax

    ```
    function (algorithm::Newton)(x)
        ...
     end
     
     ```
    
    This means that you will be able to call an object of type `Newton` as if it were a standard function, by passing in an argument. (You can add further arguments as necessary.)


4. Make a `RootProblem` type that contains the necessary information for a root problem. Do not specify types for the fields in this type yet. One of the fields should be called `algorithm`. 


5. Make a function `solve` that calls the field `algorithm` as a function.
"""

# ╔═╡ 97f36276-9aa5-49f4-8f23-15d335f62c27
struct MyNewton
end

# ╔═╡ 308a165a-e8a6-43c9-afdf-9c34ec819ff7
mynewton = MyNewton()

# ╔═╡ 4acd3dc0-9c46-4618-976c-ec24bf63570b
function (f::MyNewton)(x)
    return 3x
end

# ╔═╡ 62785950-0d7a-4ec1-85dd-979d9c519b6c
mynewton(10)

# ╔═╡ 78cd10a3-05f7-4ec7-a669-3b46e142ffc7
md"""
Make FiniteDifference into a callable thing:
"""

# ╔═╡ b5165819-a98a-4904-bfbd-efb797dcc8b1
fd = FiniteDifference()

# ╔═╡ f2621394-b96e-425d-a196-60975900643e
md"""
If I try to treat `fd` as a function, what happens?
"""

# ╔═╡ 399ec36c-ee7b-4fbb-8cf2-382653e32371
fd(10)

# ╔═╡ c5b06522-a43d-4f65-bb70-8325d606557c
md"""
Tell Julia how to treat it as a function:
"""

# ╔═╡ 10cfb96c-4e9b-4b32-a907-0e8a328bb7c4
function (fd::FiniteDifference)(f, x)
    h = fd.h
    finite_difference(f, x, h)
end

# ╔═╡ 9093de1d-1811-4b22-bf7e-fc869ddd7ba6
fd(g, a)

# ╔═╡ 8bfc9dd2-6424-4b0a-b27b-e7cdbb125a29
abstract type RootAlgorithm end

# ╔═╡ c4f02525-372d-4898-abc2-f7033154854b
struct Newton <: RootAlgorithm end

# ╔═╡ c214dde9-3d0d-4053-aaa7-9f38083ace47
(n::Newton)(args...) = ( @show args; newton(args...) )

# ╔═╡ 1b2406ce-d813-4987-94bf-efeb89754fca
n = Newton()
methods(Newton)

# ╔═╡ 9e8f4e36-0837-4de3-9d5a-05ff1edec0bf
newt = Newton()

newt(g, a)

# ╔═╡ c7b21854-321f-4783-9135-d060ed66f034
struct RootProblem
    f
    x0
    algorithm::RootAlgorithm
end

# ╔═╡ f81b8e5f-2375-49a4-8b21-51f1f3d41f8c
function solve(prob::RootProblem)
    prob.algorithm(prob.f, prob.x0)
end

# ╔═╡ 3f184e2b-76ee-46ff-98d4-e58abfaa8d73
prob = RootProblem(g, a, Newton())

# ╔═╡ dd296e6c-33e8-4f41-a820-d3e4f16e7b80
solve(prob)

# ╔═╡ 0ae7d2b1-6210-454b-94fa-8c0743c3aecf
md"""
### Type-based dispatch
"""

# ╔═╡ 44831459-6eef-450e-8b93-adf1771333cf
md"""
So far we are not using the types to their full advantage: we wish to *dispatch* on the *type* of `algorithm`. We can do so by **parametrising the type**:
"""

# ╔═╡ 609fb3c6-5a45-41c3-9eb2-147957cd012f
struct RootProblem2{T<:RootAlgorithm}
    ...
    algorithm::T
end

# ╔═╡ 0d4312c7-56d9-456f-a0ba-a6c1f788b6e2
md"""
When we create an object of type `RootProblem2`, we will get a specialised version with the correct type. We can now use that in dispatch:
"""

# ╔═╡ c67483cc-1e7d-476c-a73b-cfd0e7aba933
solve(prob::RootProblem2{Newton}) = ...

# ╔═╡ 52580580-f402-4394-a2fc-205d04e9304a
solve(prob::RootProblem2{Bisection}) = ...

# ╔═╡ 0bf9e88b-fa0a-4293-a8c4-7f192d6aed88
struct RootProblem2{F, X<:Real, T<:RootAlgorithm}
    f::F
    x0::X
    algorithm::T
end

# ╔═╡ fadf50c1-e771-486a-86fb-85f356475031


# ╔═╡ be8eca99-4cef-48d3-a321-9f2acbd5f625
md"""
#### Exercise 5

1. Implement this.


2. Put everything together to be able to solve a root problem using a particular derivative algorithm.
"""

# ╔═╡ 85eda3df-39d5-46c3-b3ea-af5e1e26c07d


# ╔═╡ acf279c4-9d73-43bb-909d-b427dc07665a
md"""
#### Exercise 6

1. Implement a `MultipleRootProblem` type that specifies an interval over which we would like to find all roots.


2. Write a simple implementation of the algorithm using multiple starting points in the interval and making a list of unique roots found by that procedure.


3. Load the `Polynomials.jl` package and write a dispatch that specialises on polynomials and calls the root finder in that package.
"""

# ╔═╡ bbe2511a-6480-4bc3-93a0-dc411ebcd937
using Polynomials

# ╔═╡ 7baac62a-533c-463d-a7cc-1c28781388fe
p = Poly([1, 2, 3])

# ╔═╡ 09eabee2-ea45-4044-9418-531bac81bf0d
p(10)

# ╔═╡ 0c952637-a28c-4518-ab97-fca5ff0bdfb4
p isa Function

# ╔═╡ b738e7f6-dd9d-46f5-8156-80c7fe00f079
md"""
## Other uses of types
"""

# ╔═╡ b81073b6-e1b7-4a8f-ae57-8f30a92f3bba
md"""
Other examples of different usages of types include:

- [`ModelingToolkit.jl`](https://github.com/JuliaDiffEq/ModelingToolkit.jl)

    Types are introduced to represent variables and operations. In this way it is relatively simple to build up a way to output symbolic expressions from standard Julia functions.
    
    
- https://github.com/MikeInnes/diff-zoo defines types to represent "tapes" recording sequences of operations. This is a precursor to tools such as [`Zygote.jl`](https://github.com/FluxML/Zygote.jl), which performs advanced automatic differentiation on code at a lower level.
"""

# ╔═╡ a9086b60-a405-422b-bf7a-20170f1eccb5
md"""
### Traits
"""

# ╔═╡ c6932e29-76fb-46f1-8b46-40a0983f8b23
md"""
An important use of types that we have not addressed here is to define **traits**. These are labels that can be assigned to different types that may then be dispatched on, even if those types are not in a Julia type hierarchy.

See e.g. the implementation in [`SimpleTraits.jl`](https://github.com/mauro3/SimpleTraits.jl).
"""

# ╔═╡ Cell order:
# ╟─2f6fc837-618f-4744-858e-28dad9d2f775
# ╟─c73da430-e748-4429-8ff3-f63281bc6f8d
# ╟─4fa51095-fe68-4c4c-bae0-0c0be56d657d
# ╠═88898edb-b537-4e97-a517-f680a6f6cadb
# ╠═1163960f-1cc9-4be0-ab34-2017d946bd97
# ╟─70960c97-8a26-4184-b3e0-04e082be3ae3
# ╟─8ec4c43a-ced8-40e9-909b-407fd9fd5e3e
# ╠═8f8bb606-529b-48a4-b764-58b7b8e8a3c4
# ╠═4694a1a4-6cfd-4a4c-903e-cbc05273c805
# ╠═ad270cbe-50c4-420e-8933-32311059edfc
# ╠═b4baeb03-5440-473f-b647-ec26cf4723d2
# ╠═863168d7-3edf-4cf6-9ba8-7e4c70bd4a08
# ╠═059440d0-0608-42c0-8116-9579655587e0
# ╠═dad1d696-95f4-42f5-84f1-1d6c9fefa064
# ╠═853ccf31-b2e9-4992-973f-90f276387baa
# ╠═2af17124-72e6-481e-b51a-0be606aa4d60
# ╠═8f0f06e7-702e-4a5e-9094-7b186c73c1d2
# ╠═1d4433e2-b975-459b-97c7-64dd1d3ef7e5
# ╠═abc977e2-4a6d-4f65-be87-3a60578678c9
# ╠═1819d25e-a6af-49f1-b539-10fcd7b8314c
# ╠═5309a69c-91c3-4f96-ac66-b3d0a3f35e5e
# ╠═e8051097-4880-4743-b01f-667f1deeaa19
# ╠═82bcfbe5-0c8e-4de1-a0a3-5af79bb47d99
# ╠═774b85de-6092-4ba4-bb54-535ac8a1da55
# ╠═177204fd-80de-4af1-b6e8-f927c27ab176
# ╠═aecf2e46-7b43-495e-97c3-e3b5d9760169
# ╠═2ac3a6ba-ac97-4ee3-a2ef-025239249e4b
# ╠═d34812a8-d0a9-420d-b45d-1b3537469c1b
# ╠═494373c4-ad57-4ccf-aed0-a03a40a36a21
# ╠═c36879fc-2bfd-440d-9b8a-6af436a1bf33
# ╠═f738c7ca-7f57-4ba4-b0b1-a3111c5b92ee
# ╠═f1cf1db1-fe38-43e1-a889-8be440808920
# ╠═af011373-9e85-41d0-aec2-f51c82fdf309
# ╠═93b2eebb-c897-4fae-a5ce-15de2a1fb7d2
# ╠═27e7305b-f45a-4bdf-b7bb-f04276e47155
# ╟─920ae67c-7eb7-4a96-aa39-39f7ca5d7e4f
# ╟─e5239a2e-e8cb-475f-b233-f15ad1f3a341
# ╠═479e76bb-04c6-4fb4-bd63-ffdcb26e8698
# ╠═c62ce657-e2cc-4ce1-bb49-da559de9468d
# ╠═8f798db9-7bd7-4600-85bb-dc05f4ab78d8
# ╟─77537c19-12d9-44df-8416-dc83420da1c1
# ╟─03d223a9-7e83-44fd-a64b-ad2fa4fa84b1
# ╟─6394c964-76ee-4407-ad7e-c40dd604437e
# ╠═bb6fc1f5-3187-4ff5-b55d-dac2ba4760df
# ╠═2f9cbeea-2c70-41db-bfff-396a230cb082
# ╠═d12d4eaf-01a7-4a68-8ec4-cb6cbfcb4212
# ╟─453d9e55-6a41-45be-8a6b-31e4e43c9b46
# ╟─66b7df82-c476-4e94-9f54-fbc26042a1ba
# ╟─4bc25a40-68fb-46c5-8099-b4b2c82120ee
# ╟─0cdcf1aa-560f-4b0b-8421-3d341d5bd8be
# ╠═97f36276-9aa5-49f4-8f23-15d335f62c27
# ╠═308a165a-e8a6-43c9-afdf-9c34ec819ff7
# ╠═4acd3dc0-9c46-4618-976c-ec24bf63570b
# ╠═62785950-0d7a-4ec1-85dd-979d9c519b6c
# ╟─78cd10a3-05f7-4ec7-a669-3b46e142ffc7
# ╠═b5165819-a98a-4904-bfbd-efb797dcc8b1
# ╟─f2621394-b96e-425d-a196-60975900643e
# ╠═399ec36c-ee7b-4fbb-8cf2-382653e32371
# ╟─c5b06522-a43d-4f65-bb70-8325d606557c
# ╠═10cfb96c-4e9b-4b32-a907-0e8a328bb7c4
# ╠═9093de1d-1811-4b22-bf7e-fc869ddd7ba6
# ╠═8bfc9dd2-6424-4b0a-b27b-e7cdbb125a29
# ╠═c4f02525-372d-4898-abc2-f7033154854b
# ╠═c214dde9-3d0d-4053-aaa7-9f38083ace47
# ╠═1b2406ce-d813-4987-94bf-efeb89754fca
# ╠═9e8f4e36-0837-4de3-9d5a-05ff1edec0bf
# ╠═c7b21854-321f-4783-9135-d060ed66f034
# ╠═f81b8e5f-2375-49a4-8b21-51f1f3d41f8c
# ╠═3f184e2b-76ee-46ff-98d4-e58abfaa8d73
# ╠═dd296e6c-33e8-4f41-a820-d3e4f16e7b80
# ╟─0ae7d2b1-6210-454b-94fa-8c0743c3aecf
# ╟─44831459-6eef-450e-8b93-adf1771333cf
# ╠═609fb3c6-5a45-41c3-9eb2-147957cd012f
# ╟─0d4312c7-56d9-456f-a0ba-a6c1f788b6e2
# ╠═c67483cc-1e7d-476c-a73b-cfd0e7aba933
# ╠═52580580-f402-4394-a2fc-205d04e9304a
# ╠═0bf9e88b-fa0a-4293-a8c4-7f192d6aed88
# ╠═fadf50c1-e771-486a-86fb-85f356475031
# ╟─be8eca99-4cef-48d3-a321-9f2acbd5f625
# ╠═85eda3df-39d5-46c3-b3ea-af5e1e26c07d
# ╟─acf279c4-9d73-43bb-909d-b427dc07665a
# ╠═bbe2511a-6480-4bc3-93a0-dc411ebcd937
# ╠═7baac62a-533c-463d-a7cc-1c28781388fe
# ╠═09eabee2-ea45-4044-9418-531bac81bf0d
# ╠═0c952637-a28c-4518-ab97-fca5ff0bdfb4
# ╟─b738e7f6-dd9d-46f5-8156-80c7fe00f079
# ╟─b81073b6-e1b7-4a8f-ae57-8f30a92f3bba
# ╟─a9086b60-a405-422b-bf7a-20170f1eccb5
# ╟─c6932e29-76fb-46f1-8b46-40a0983f8b23
