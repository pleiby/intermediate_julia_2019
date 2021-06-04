### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ cac0bc38-ead9-4f99-a939-fc2645874efd
md"""
# Types in Julia
"""

# ╔═╡ ecb2b8d9-ceda-4008-8137-b29bd7ef3ba9
# Uses of types.jl

# ╔═╡ b4f0668c-8b25-4588-9176-52bc7bfe797b
md"""
In this notebook we will start exploring types by implementing a type to implement algorithmic differentiation.
"""

# ╔═╡ 0ece0b55-ede7-4db1-9b48-61e1d4534761
md"""
### What is a type?
"""

# ╔═╡ 6dcc01fe-c551-43d2-930b-ff1c93d15077
md"""
A *type* can be thought of as a label that is associated with data stored in memory; this label tells Julia how to interpret the data. For example:
"""

# ╔═╡ 0d352bcc-dfc1-429f-ad6c-40dc8c4cd038
begin
	x = 1
	y = 1.3
end

# ╔═╡ 81863f06-8dac-48fd-a6e1-cf5df30c63f6
sizeof(x), sizeof(y)

# ╔═╡ 3de40205-6b5d-4d99-b886-1a1dc6a07955
typeof(x), typeof(y)

# ╔═╡ d4c280cf-910c-4bbf-8dca-b01b14711296
# rinterpret the bit-representation of x (an int) as another type, e.g. Float64 
z = reinterpret(Float64, x)

# ╔═╡ 7082e444-6268-4721-a278-2511a22daf68
bitstring(x)

# ╔═╡ 43538919-4349-43f1-a196-759fe65d3be3
bitstring(z)

# ╔═╡ e0c1df0c-ff62-4982-8f3d-3ccbb44b8d2f
md"""
Both variables are stored in 8 bytes (64 bits), but one is interpreted as an integer and the other as a floating-point number.  Similarly, a pair of two numbers may be intepreted as a complex number, or an interval, or a dual number, or...; although the same information may be stored (two numbers), we want each of these different *kinds* or *types* of objects to be treated differently. 
"""

# ╔═╡ e6281275-0b87-47f4-a081-bb366ced3466
md"""
## Algorithmic differentiation
"""

# ╔═╡ 6056ff4a-858f-447c-85cc-0f3f6e0e53ca
md"""
In the previous notebook we used `ForwardDiff.jl` to automatically differentiate a function. Here we will see how to implement a simple version of this.
"""

# ╔═╡ db17c624-91b6-44b1-bd10-4d72f4cb9776
md"""
The idea is to approximate a (nice enough) function $f$ near a point $a$ by a Taylor series of order 1, i.e. a straight line passing through $(a, f(a))$, with slope equal to the derivative $f'(a)$:
    
$f(x) \simeq f(a) + \epsilon f'(a)$,

where $\epsilon := x - a$.

We now use this to derive the standard rules for the derivative of a sum and product:

$$f(x) + g(x) \simeq [f(a) + g(a)] + \epsilon [f'(a) + g'(a)]$$

$$f(x) \cdot g(x) \simeq [f(a) \cdot g(a)] + \epsilon [f(a) g'(a) + g(a) f'(a)],$$

where we suppose that $\epsilon$ is small enough that $\epsilon^2 = 0$, or alternatively just "take the linear part".
"""

# ╔═╡ b3b15bf5-115d-4831-9115-36c88e9b899c
md"""
### Defining a composite type
"""

# ╔═╡ 70843c81-6abe-40b2-8d0b-8d779fccedc8
md"""
We see that by using just two pieces of information, namely the value $f(a)$ and the derivative $f'(a)$, we can represent a function $f$ near a given point $a$. 

The pair $(f(a), f'(a))$ is often called a **dual number**. We see that is has certain **behaviours** under arithmetic operations. Whenever we have a new behaviour, a *new type is lurking*!

We group the two values into a **composite type**. We can think of a composite type as specifying the structure of a box containing several pieces of information (data) inside. Defining a composite type with two **fields** (pieces of information) has the following syntax:
"""

# ╔═╡ 82c79506-68ea-41dd-888d-840371c08430
struct MyType
    a
    b::Int
end

# ╔═╡ 291315e0-ad0e-4a57-b100-2baa5af04c04
md"""
Here we have additionally specified that the information stored in the field `b` must be of type `Int` using the **type annotation operator**, `::`.
"""

# ╔═╡ f2421fbf-5cfc-4332-be60-b61fa4e02d8c
md"""
Creating an object of that type is accomplished as follows:
"""

# ╔═╡ 710612bd-4856-4e51-b2d6-2bdc972f196d
x1 = MyType(3, 4)

# ╔═╡ 70eb5167-6288-4f84-b140-21b4b329cb45
md"""
We can extract information as follows:
"""

# ╔═╡ 9fb42f3c-c7ff-4f31-b5e6-9e96de16bac5
x1.a

# ╔═╡ 07808ac8-c910-4e92-ac34-c9ff225f4be8
typeof(x1.a)

# ╔═╡ 8777c6a7-90e3-4dc7-ab61-3d12531f2ea9
md"""
#### Exercise 1

1. Define a composite type `Dual` with fields `value` and `deriv` of type `Float64`.


2. Create two `Dual` numbers `x` and `y`.


3. What happens if you try to add `x` and `y` together?


4. Make a function `add` that adds `x` and `y` and returns a new `Dual` number, following the rules we found above.
"""

# ╔═╡ 5488c55f-8d0a-4c9b-8f8b-40ed4fe14e67
struct Dual
    value::Float64
    deriv::Float64
end

# ╔═╡ 4f5e5eea-13df-477e-baea-c37ab6074aea
x_D = Dual(3, 4)

# ╔═╡ da932afe-990f-4ca7-aa81-9d85e1ca3bac
methods(Dual)

# ╔═╡ fac29cb2-dc57-4a06-9728-567169ac3768
convert(Float64, 3)

# ╔═╡ 4118613c-e58a-4f63-81d1-0e197e66cf98
# this raises an error
convert(Float64, "hello")

# ╔═╡ ac8fa4de-d8ef-44f2-b709-aceb1e0ecb04
y_D = Dual(5, 6)

# ╔═╡ 92aa5678-478c-4cb6-9187-3285534aac8c
x_D + y_D

# ╔═╡ 04a21e57-a45c-4e4b-977a-42c6ee228b4a
newadd(x::Dual, y::Dual) = Dual(x.value + y.value, x.deriv + y.deriv)

# ╔═╡ 915bfb27-7234-43ea-a052-093f89d7bdcd
newadd(x_D, y_D)

# ╔═╡ 9b213fb9-382a-4c5b-93fe-22252d29d0c6
md"""
## Implementing arithmetic for a type
"""

# ╔═╡ 8eed2b5c-dde2-437e-8383-4ed206ce72de
md"""
We would like to be able to use `+` and `*` for our new `Dual` type, rather than typing `add(x, y)`. To do so, we need to do the following
"""

# ╔═╡ 62a97a4b-dfa6-404d-958b-b7b4ab7d25ca
# +(x::Dual, y::Dual) = Dual(x.value + y.value, x.deriv + y.deriv)

# ╔═╡ 9b0d361a-8c30-4ec0-a183-ac3890895f0e
# Base.+(x::Dual, y::Dual) = Dual(x.value + y.value, x.deriv + y.deriv)

# ╔═╡ 9b8f41b5-9ade-4f34-8d09-cb548bd6c242
# or
# +(x::Dual, y::Dual) = add(x, y)

# ╔═╡ 5b29f183-bda6-4ffb-bb78-5199980039d3
# or
# function +(x::Dual, y::Dual)
#    return add(x, y)
# end

# ╔═╡ fc624260-ba8a-4057-8a1f-2659e2343654
md"""
In Julia, `+` and `*` are just functions. They are defined in `Base` (a module containing basic function definitions) and must be `import`ed before being **extended**. They consist of many different **methods** (versions):
"""

# ╔═╡ abcbc0a1-33e7-430f-b0a8-e8b65c8666b2
@which +(3)

# ╔═╡ 17498a94-5db9-4c5e-9268-e588fddeae54
-(3)

# ╔═╡ c847f0c2-1eac-4900-b80c-7f89846b2924
methods(+)

# ╔═╡ 6caea9da-3edc-4309-bad8-f348693960b2
x

# ╔═╡ 17cce3ab-1b4f-402d-bcc3-c7905360a441
y

# ╔═╡ 526a204c-6a72-4cde-900a-568667e45c64
x + y

# ╔═╡ 86aa82b1-caae-4124-b48a-14497420f471
md"""
We can add more methods that work on our own types. (We are not allowed to modify their behaviour on combinations of types that to not contain our user-defined types; doing so is known as "type piracy" and can affect other people's code in unexpected ways.)
"""

# ╔═╡ e359dd62-65f0-4033-98c2-aff400ed0bb7
md"""
#### Exercise 2

1. Import the `+` and `*` functions from `Base` and implement them for the `Dual` type.
They should return a new `Dual` object.


2. Check that the number of methods has changed. 


3. Use `@which x + y` to check that Julia knows which method to use when adding two `Dual`s.


4. Can you define `x + a` for a `Dual` number `x` and a real number `a`? What happens 
"""

# ╔═╡ 86141559-f6f4-43a6-8291-550adf31b25b


# ╔═╡ cee6af83-0079-4acd-9e14-cd7b7eb6947f
begin
	value(f::Dual) = f.value
	deriv(f::Dual) = f.deriv
end

# ╔═╡ 4e222c6a-054b-41e6-bef4-b0726344ee94
let
	∂(f::Dual) = f.deriv
	*(f::Dual, g::Dual) = Dual(value(f) * value(g),
    	                     value(f) * ∂(g) + ∂(f) * value(g))
	42 # return this to avoid conflict
end

# ╔═╡ a1b1b945-ba2e-4668-8698-4df02660d379
md"""
(Try using `@code_llvm`)
"""

# ╔═╡ 8857e0aa-da38-4ae6-8ef9-efa66dd51cfc
begin
	f = Dual(3.0, 4.0)
	g = Dual(5.0, 6.0)
end

# ╔═╡ ad671591-a625-4de2-9b18-84c7773cb4b8
f, g

# ╔═╡ 053e90a7-5fa6-4063-9634-63d48ee16690
f + g

# ╔═╡ d521f0e3-1636-4e8b-b8f3-639a90780690
f * g

# ╔═╡ b7b81d9d-354d-4ec0-b50c-302dbcb8f0c4
md"""
Amazingly, we now have enough to be able to differentiate simple Julia functions involving only `+` and `*`. Define
"""

# ╔═╡ d67fa8a9-f43e-4eca-bb0e-1603c9f7da5d
begin
	a = 3.0
	xx = Dual(a, 1.0)  # "the identity function x ↦ x, with derivative 1"
end

# ╔═╡ 3bc3d5a3-9b9f-4d07-9d59-f24d5c005038
md"""
We initialize the derivative as 1.0 when we make a `Dual`. If we use `x` then we automatically differentiate!
"""

# ╔═╡ fd34be78-af76-4d46-bdbd-19fd19155785
md"""
#### Exercise 3
"""

# ╔═╡ caccd695-118c-46a8-b59f-376e4cbc83ce
md"""
1. Define `a = 3.0` and `xx = Dual(a, 1.0)`.

    (i) Compute `xx + xx`. The result should have the value $2a$ and the derivative $2$ -- write a test that it does so.
    
    (ii) Do the same for `xx * xx`. 
    
    
2. Define the function `f(x) = x * x + x`. Compute `f(xx)` and check that it gives the correct value and derivative!


3. Does this work for the function `f(x) = x^2 + x`?  What do you need to do?


4. What happens for `f(x) = x^2 + 2x`? What do you need to do?


5. What should you do for `f(x) = sin(x) + x`?
"""

# ╔═╡ 6418d0a4-8dd3-4816-8e5b-092cb769ebb6
a = 3.0
xx = Dual(a, 1.0)

# ╔═╡ 8ebb42e9-11ec-434d-87c9-4259c26f6526
xx + xx

# ╔═╡ 84b6a870-4515-4e6c-b306-d6b6d2a0fb8d
xx * xx

# ╔═╡ a0865cb0-7077-44ff-a130-eb73cbbc3179
xx * xx + xx  # the function x ↦ x^2 + x,  derivative 2x + 1

# ╔═╡ f1fc7637-4804-4fc1-81ac-14874e66f9d6
ff(x) = x*x*x + x*x + x*x  # x^3 + 2x^2

# ╔═╡ ded7adc0-619f-4735-bd93-9c26c4c21858
ff(xx)

# ╔═╡ 1284374b-ab26-46b8-a74e-119655f5112e
ff(a)

# ╔═╡ 4e06b4f6-9753-4847-8c6c-120208520dc5
n = 4
fff(x) = x^n

# ╔═╡ 420c0ef0-3f7e-4044-be30-c2873636c6e8
dff(x) = 3x^2 + 4x

# ╔═╡ f426bed2-05f1-4598-9817-bb90262911ef
dff(a)

# ╔═╡ 09bfa122-ca5b-4b4a-a9eb-09b1b5482a76
fff(x) = x^2

# ╔═╡ d08a434c-c816-4f43-9c93-2d0eda57723c
fff(xx)

# ╔═╡ 131373df-8e58-49b0-be5f-3cd8d8deb61d
fff(xx)

# ╔═╡ 76a7a87b-0283-4a85-9d88-0eec06ef689f
fff4(x) = x^4

# ╔═╡ d608bc38-5653-4ad5-b6e4-6b2236299e4c
fff4(xx)

# ╔═╡ bf697142-0eaf-4717-9434-eaa89946beb4
md"""
`Base.literal_pow`
"""

# ╔═╡ 108212df-c86f-4b75-8576-65f3964687e9
md"""
#### Exercise 4
"""

# ╔═╡ eb94cc27-ac9e-4202-acdc-248809eebdb9
md"""
1. Define a function `differentiate` that differentiates a function `f` at a point `a` using `Dual` numbers, by following the above pattern. (It should return just the derivative at the given point.)
"""

# ╔═╡ d7f6c80a-4922-42be-9bce-e493e603c373


# ╔═╡ 70ec3ada-f7ae-4526-be35-5aa8cd4533ca
md"""
This is the basis of ("forward-mode") automatic differentiation. The `ForwardDiff.jl` method contains a sophisticated implementation of this method.
"""

# ╔═╡ 5011cf98-128e-4c94-bae0-109016427c50
md"""
### Parametric types
"""

# ╔═╡ d57937d8-3f1e-4f85-bf6b-afc8cfe3e99d
md"""
For simplicity, in the above we fixed the fields in the `Dual` type to be of type `Float64`. By doing so we are actually *losing power*. Instead we should let Julia "fill in" the types. 

To do so, we specify that we want to use a **type parameter** `T`. We can think of this as a "special kind of variable" that can only take on certain kinds of values. We specify this with the following syntax: 
"""

# ╔═╡ df1c033c-8a99-4b45-bc9c-3287a3a959ec
struct MyType2{T}
    a::T
    b::T
end

# ╔═╡ b0902a74-01e0-456a-a027-a5030d494d7f
md"""
[Note that we have not reused the name `MyType` since Julia *does not allow types to be redefined in a different way*.]
"""

# ╔═╡ 9226e5a3-4445-4420-9b54-be31468e6b07
md"""
Here we are specifying that both fields `a` and `b` must share the same type `T`, but we have not restricted what values `T` can take. When we create an object, Julia will *infer* (work out) the type:
"""

# ╔═╡ ccc258fa-c928-4175-a48e-bd72b7d22f31
x_M = MyType2(3, 4)

# ╔═╡ c9f3dde8-7989-45e8-9831-894d82e57e90
y_M = MyType2(3.1, 4.2)

# ╔═╡ 2d3876d6-5fcf-4bfb-8dba-4bdf252c73fc
z_M = MyType2(1, 5.3)

# ╔═╡ a0d7a33a-e067-4e69-9c70-14005f41a2c6
struct MyType3{S,T}
    a::S
    b::T
end

# ╔═╡ 812149d8-0040-4d67-b2a2-f1304af4b225
x_M2 = MyType3(1, 5.3)

# ╔═╡ 75fa60fe-6583-4a6a-b6b0-06fb81006218
md"""
Note that `x` and `y` have *different* types.
"""

# ╔═╡ 4146cf8f-ab2f-457d-97ef-e6d39e93246e
md"""
We can define functions acting on parametric types without necessarily talking about the type parameter:
"""

# ╔═╡ 3e61a354-ca21-410b-b422-92ea362b8c10
md"""
#### Exercise 5

1. Define a function that takes an object of type `MyType2`, *without* mentioning the type parameter, and returns the sum of the two fields.

   What happens when you apply this function to `x` and `y`?
   
   
2. Define a type `Dual2` with a type parameter `T` and the same functions `+` and `*` as before.


3. Define the function `f(x) = x * x + x`. What happens if you pass in `Dual` numbers with different type parameters?
"""

# ╔═╡ 907f65aa-e1a1-4838-a1a0-cdaa0a1cfa45
struct DualReal
    value::Real
    deriv::Real
end
    

# ╔═╡ fc5839ce-935a-46aa-bbe7-01f203b0fdb5
DualReal(big(1.0), big"1.4")

# ╔═╡ c445bab5-c012-4890-89bc-e7d6950fa7b4
DualReal(3.1, big"1.4")

# ╔═╡ 9008cc1d-e7c2-4b24-ad08-968c085baa36
struct DualUntyped
    value
    deriv
end
    

# ╔═╡ d5cb6844-6f9d-422e-a241-96450aff70f5
DualUntyped("hello", "David")

# ╔═╡ 7b2f03b4-d3dd-4fa6-a569-c878fc9f6557
struct DualBig
    value::BigFloat
    deriv::BigFloat
end
    

# ╔═╡ 97097783-2948-4e9c-b769-8085c7943227
begin
	struct Dual3{T<:Real}
	    a::T
    	b::T
	end

	Dual3(a::Real, b::Real) = Dual3(promote(a, b))

	# Dual3(a::Real, b::Real) = Dual3(promote(a, b)...)
end

# ╔═╡ 4bdb5bfc-82c2-4de5-982a-4a69872749d1
Dual3("a", "b")

# ╔═╡ 9c05cca8-76d9-4abd-8774-28e7f41d3b09
Dual3(big"1.0", big"1.4")

# ╔═╡ 05db96f7-3eeb-47aa-a4dc-dd67b0f02a2b
Dual3(1, 3.1)

# ╔═╡ b490d647-85f5-4b82-ab29-2d18ce1c7db4
methods(Dual3)

# ╔═╡ d981b89c-4833-4e38-9f80-246ed5f09445
Dual3(3, 4.5)

# ╔═╡ 9bfe7470-afec-4a24-9f96-43272e2f9ecd
promote(1, 3.4)

# ╔═╡ 61cc131f-2d02-4de1-b79a-9105d6decc15
@which promote_type(Int, Float64)

# ╔═╡ a5c1c463-2393-499d-852c-16e69549819a
Complex(3, 4.5)

# ╔═╡ 749ba068-6deb-4a7d-a650-412e5fbdb670
@which Complex(3, 4.5)

# ╔═╡ 226f5af6-702f-431c-a269-5dd4cafa2699
v = Dual(3, 4)

# ╔═╡ c3831c37-8e09-4846-963d-27e1d4a824ac
v isa Number

# ╔═╡ fd8bf8f8-68dd-4925-aa9b-8eca1937c577
subtypes(Real)

# ╔═╡ e3d64165-170e-4ee0-a9bc-ef759ce6afd7
subtypes(AbstractFloat)

# ╔═╡ 713dc49e-6038-40b7-a917-299277f7ea7a
subtypes(Float64)

# ╔═╡ 68d54b7c-4003-49e8-b2f9-666b882a5737
isconcretetype(Float64)

# ╔═╡ 7ae57ebb-d6bc-4b9b-913a-f9c4bb11d380
q = 3.1

# ╔═╡ 99dd8229-8658-4efe-9133-3eb8cd00b6b3
typeof(q)

# ╔═╡ ef28ca54-38dd-4e8e-a5e8-897c802f81e1
q isa AbstractFloat

# ╔═╡ a31cfb26-9914-441c-aea8-6f341f2635fb
gg(x::AbstractFloat) = sqrt(x)

# ╔═╡ b05dcbc4-0149-48a3-8533-1bd6515d0b32
gg(x::T) where {T <: AbstractFloat} = sqrt(x)

# ╔═╡ f44efbd4-7ce2-44db-ac0e-eeb4aeafef70
gg(π)

# ╔═╡ 7df9a91e-01d4-471f-9ad5-55ac56c245d3
struct Hello{T}
    a::T
    b::T
    c::T
end

# ╔═╡ ef1c3d05-7020-4339-b431-63ad63b244cc
add(x::Hello, y::Hello) = x.a + y.a, x.b + y.b, ...

# ╔═╡ 186148a4-698e-460b-82dd-7b203698de45
w = Hello(3, 4, 45)

# ╔═╡ b9ac03c2-d93e-4372-a3cb-4568baf015bb
myfields = fieldnames(typeof(w))

# ╔═╡ 522a7a5c-8400-4e1b-9ebd-6d76b33cb87f
getfield(w, :a)

# ╔═╡ d70384a3-51fc-4f71-a3d6-d14b03719495
x

# ╔═╡ ab382c7f-933e-4611-af23-fe31967ff8cc
[getfield(x, name) for name in myfields]

# ╔═╡ 8df1bf08-5ee2-4cfe-a273-62c71dc9b8fb
abstract type AbstractDual{S<:Real,T<:Real}

struct Dual5{S<:Real, T<:Real} <: AbstractDual{S,T}
    a::S
    b::T
end

# ╔═╡ babed906-7888-431b-8b11-d6e5889073fa
getfield.(myfields)

# ╔═╡ d7e3e2b2-6f3f-4761-9141-924ae1448343


# ╔═╡ ce4bd2c6-6269-47e3-8f43-50969a19487a
x::Dual ^ n::Integer = ..

# ╔═╡ 555aa973-a5ce-41f9-aab7-261a697758cc
*(f::Dual, g::Dual) = Dual(f.value * g.value,
                         f.value * g.deriv + f.deriv * g.value)

# Alternatively and equivalently
# *(f::Dual, g::Dual) = Dual(value(f) * value(g),
#                          value(f) * deriv(g) + deriv(f) * value(g))

# ╔═╡ eea59dfb-acc7-4d56-82b2-59f0ed40afc7
import Base: +, *

# ╔═╡ b0c794fb-0d77-4667-9d47-0bcdfaa8fecb
begin
	import Base: ^
	^(x::Dual, n::Integer) = Base.power_by_squaring(x, n)
end

# ╔═╡ Cell order:
# ╟─cac0bc38-ead9-4f99-a939-fc2645874efd
# ╠═ecb2b8d9-ceda-4008-8137-b29bd7ef3ba9
# ╟─b4f0668c-8b25-4588-9176-52bc7bfe797b
# ╟─0ece0b55-ede7-4db1-9b48-61e1d4534761
# ╟─6dcc01fe-c551-43d2-930b-ff1c93d15077
# ╠═0d352bcc-dfc1-429f-ad6c-40dc8c4cd038
# ╠═81863f06-8dac-48fd-a6e1-cf5df30c63f6
# ╠═3de40205-6b5d-4d99-b886-1a1dc6a07955
# ╠═d4c280cf-910c-4bbf-8dca-b01b14711296
# ╠═7082e444-6268-4721-a278-2511a22daf68
# ╠═43538919-4349-43f1-a196-759fe65d3be3
# ╟─e0c1df0c-ff62-4982-8f3d-3ccbb44b8d2f
# ╟─e6281275-0b87-47f4-a081-bb366ced3466
# ╟─6056ff4a-858f-447c-85cc-0f3f6e0e53ca
# ╟─db17c624-91b6-44b1-bd10-4d72f4cb9776
# ╟─b3b15bf5-115d-4831-9115-36c88e9b899c
# ╟─70843c81-6abe-40b2-8d0b-8d779fccedc8
# ╠═82c79506-68ea-41dd-888d-840371c08430
# ╟─291315e0-ad0e-4a57-b100-2baa5af04c04
# ╟─f2421fbf-5cfc-4332-be60-b61fa4e02d8c
# ╠═710612bd-4856-4e51-b2d6-2bdc972f196d
# ╟─70eb5167-6288-4f84-b140-21b4b329cb45
# ╠═9fb42f3c-c7ff-4f31-b5e6-9e96de16bac5
# ╠═07808ac8-c910-4e92-ac34-c9ff225f4be8
# ╟─8777c6a7-90e3-4dc7-ab61-3d12531f2ea9
# ╠═5488c55f-8d0a-4c9b-8f8b-40ed4fe14e67
# ╠═4f5e5eea-13df-477e-baea-c37ab6074aea
# ╠═da932afe-990f-4ca7-aa81-9d85e1ca3bac
# ╠═fac29cb2-dc57-4a06-9728-567169ac3768
# ╠═4118613c-e58a-4f63-81d1-0e197e66cf98
# ╠═ac8fa4de-d8ef-44f2-b709-aceb1e0ecb04
# ╠═92aa5678-478c-4cb6-9187-3285534aac8c
# ╠═04a21e57-a45c-4e4b-977a-42c6ee228b4a
# ╠═915bfb27-7234-43ea-a052-093f89d7bdcd
# ╟─9b213fb9-382a-4c5b-93fe-22252d29d0c6
# ╟─8eed2b5c-dde2-437e-8383-4ed206ce72de
# ╠═eea59dfb-acc7-4d56-82b2-59f0ed40afc7
# ╠═62a97a4b-dfa6-404d-958b-b7b4ab7d25ca
# ╠═9b0d361a-8c30-4ec0-a183-ac3890895f0e
# ╠═9b8f41b5-9ade-4f34-8d09-cb548bd6c242
# ╠═5b29f183-bda6-4ffb-bb78-5199980039d3
# ╟─fc624260-ba8a-4057-8a1f-2659e2343654
# ╠═abcbc0a1-33e7-430f-b0a8-e8b65c8666b2
# ╠═17498a94-5db9-4c5e-9268-e588fddeae54
# ╠═c847f0c2-1eac-4900-b80c-7f89846b2924
# ╠═6caea9da-3edc-4309-bad8-f348693960b2
# ╠═17cce3ab-1b4f-402d-bcc3-c7905360a441
# ╠═526a204c-6a72-4cde-900a-568667e45c64
# ╟─86aa82b1-caae-4124-b48a-14497420f471
# ╟─e359dd62-65f0-4033-98c2-aff400ed0bb7
# ╠═86141559-f6f4-43a6-8291-550adf31b25b
# ╠═cee6af83-0079-4acd-9e14-cd7b7eb6947f
# ╠═555aa973-a5ce-41f9-aab7-261a697758cc
# ╠═4e222c6a-054b-41e6-bef4-b0726344ee94
# ╟─a1b1b945-ba2e-4668-8698-4df02660d379
# ╠═8857e0aa-da38-4ae6-8ef9-efa66dd51cfc
# ╠═ad671591-a625-4de2-9b18-84c7773cb4b8
# ╠═053e90a7-5fa6-4063-9634-63d48ee16690
# ╠═d521f0e3-1636-4e8b-b8f3-639a90780690
# ╟─b7b81d9d-354d-4ec0-b50c-302dbcb8f0c4
# ╠═d67fa8a9-f43e-4eca-bb0e-1603c9f7da5d
# ╟─3bc3d5a3-9b9f-4d07-9d59-f24d5c005038
# ╟─fd34be78-af76-4d46-bdbd-19fd19155785
# ╟─caccd695-118c-46a8-b59f-376e4cbc83ce
# ╠═6418d0a4-8dd3-4816-8e5b-092cb769ebb6
# ╠═8ebb42e9-11ec-434d-87c9-4259c26f6526
# ╠═84b6a870-4515-4e6c-b306-d6b6d2a0fb8d
# ╠═a0865cb0-7077-44ff-a130-eb73cbbc3179
# ╠═f1fc7637-4804-4fc1-81ac-14874e66f9d6
# ╠═ded7adc0-619f-4735-bd93-9c26c4c21858
# ╠═1284374b-ab26-46b8-a74e-119655f5112e
# ╠═420c0ef0-3f7e-4044-be30-c2873636c6e8
# ╠═f426bed2-05f1-4598-9817-bb90262911ef
# ╠═09bfa122-ca5b-4b4a-a9eb-09b1b5482a76
# ╠═d08a434c-c816-4f43-9c93-2d0eda57723c
# ╠═b0c794fb-0d77-4667-9d47-0bcdfaa8fecb
# ╠═4e06b4f6-9753-4847-8c6c-120208520dc5
# ╠═131373df-8e58-49b0-be5f-3cd8d8deb61d
# ╠═76a7a87b-0283-4a85-9d88-0eec06ef689f
# ╠═d608bc38-5653-4ad5-b6e4-6b2236299e4c
# ╠═ce4bd2c6-6269-47e3-8f43-50969a19487a
# ╟─bf697142-0eaf-4717-9434-eaa89946beb4
# ╟─108212df-c86f-4b75-8576-65f3964687e9
# ╟─eb94cc27-ac9e-4202-acdc-248809eebdb9
# ╠═d7f6c80a-4922-42be-9bce-e493e603c373
# ╟─70ec3ada-f7ae-4526-be35-5aa8cd4533ca
# ╟─5011cf98-128e-4c94-bae0-109016427c50
# ╟─d57937d8-3f1e-4f85-bf6b-afc8cfe3e99d
# ╠═df1c033c-8a99-4b45-bc9c-3287a3a959ec
# ╟─b0902a74-01e0-456a-a027-a5030d494d7f
# ╟─9226e5a3-4445-4420-9b54-be31468e6b07
# ╠═ccc258fa-c928-4175-a48e-bd72b7d22f31
# ╠═c9f3dde8-7989-45e8-9831-894d82e57e90
# ╠═2d3876d6-5fcf-4bfb-8dba-4bdf252c73fc
# ╠═a0d7a33a-e067-4e69-9c70-14005f41a2c6
# ╠═812149d8-0040-4d67-b2a2-f1304af4b225
# ╟─75fa60fe-6583-4a6a-b6b0-06fb81006218
# ╟─4146cf8f-ab2f-457d-97ef-e6d39e93246e
# ╟─3e61a354-ca21-410b-b422-92ea362b8c10
# ╠═907f65aa-e1a1-4838-a1a0-cdaa0a1cfa45
# ╠═fc5839ce-935a-46aa-bbe7-01f203b0fdb5
# ╠═c445bab5-c012-4890-89bc-e7d6950fa7b4
# ╠═9008cc1d-e7c2-4b24-ad08-968c085baa36
# ╠═d5cb6844-6f9d-422e-a241-96450aff70f5
# ╠═7b2f03b4-d3dd-4fa6-a569-c878fc9f6557
# ╠═97097783-2948-4e9c-b769-8085c7943227
# ╠═4bdb5bfc-82c2-4de5-982a-4a69872749d1
# ╠═9c05cca8-76d9-4abd-8774-28e7f41d3b09
# ╠═05db96f7-3eeb-47aa-a4dc-dd67b0f02a2b
# ╠═b490d647-85f5-4b82-ab29-2d18ce1c7db4
# ╠═d981b89c-4833-4e38-9f80-246ed5f09445
# ╠═9bfe7470-afec-4a24-9f96-43272e2f9ecd
# ╠═61cc131f-2d02-4de1-b79a-9105d6decc15
# ╠═a5c1c463-2393-499d-852c-16e69549819a
# ╠═749ba068-6deb-4a7d-a650-412e5fbdb670
# ╠═226f5af6-702f-431c-a269-5dd4cafa2699
# ╠═c3831c37-8e09-4846-963d-27e1d4a824ac
# ╠═fd8bf8f8-68dd-4925-aa9b-8eca1937c577
# ╠═e3d64165-170e-4ee0-a9bc-ef759ce6afd7
# ╠═713dc49e-6038-40b7-a917-299277f7ea7a
# ╠═68d54b7c-4003-49e8-b2f9-666b882a5737
# ╠═7ae57ebb-d6bc-4b9b-913a-f9c4bb11d380
# ╠═99dd8229-8658-4efe-9133-3eb8cd00b6b3
# ╠═ef28ca54-38dd-4e8e-a5e8-897c802f81e1
# ╠═a31cfb26-9914-441c-aea8-6f341f2635fb
# ╠═f44efbd4-7ce2-44db-ac0e-eeb4aeafef70
# ╠═b05dcbc4-0149-48a3-8533-1bd6515d0b32
# ╠═7df9a91e-01d4-471f-9ad5-55ac56c245d3
# ╠═ef1c3d05-7020-4339-b431-63ad63b244cc
# ╠═186148a4-698e-460b-82dd-7b203698de45
# ╠═b9ac03c2-d93e-4372-a3cb-4568baf015bb
# ╠═522a7a5c-8400-4e1b-9ebd-6d76b33cb87f
# ╠═d70384a3-51fc-4f71-a3d6-d14b03719495
# ╠═ab382c7f-933e-4611-af23-fe31967ff8cc
# ╠═8df1bf08-5ee2-4cfe-a273-62c71dc9b8fb
# ╠═babed906-7888-431b-8b11-d6e5889073fa
# ╠═d7e3e2b2-6f3f-4761-9141-924ae1448343
