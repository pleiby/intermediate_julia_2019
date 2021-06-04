### A Pluto.jl notebook ###
# v0.10.0

using Markdown

# ╔═╡ 148d5d63-2af4-42dc-82b7-66048377a773
md"""
# Introduction to metaprogramming: "Code that creates code" 
"""

# ╔═╡ a5fa90ce-e4bc-490a-b86a-9a1acefc3b9c
md"""
Julia has strong **metaprogramming** capabilities. What does this mean?

> **meta**: something on a higher level

**metaprogramming** = "higher-level programming"

i.e. writing code (a program) to manipulate not data, but code (that itself manipulates data)

"""

# ╔═╡ 054538b8-6e2a-475c-96bd-b1a063b5e454
md"""
## Motivating example: Interact.jl
"""

# ╔═╡ 819b2c2a-40f8-4a9c-be30-b8bd54efb53e
md"""
#### Exercise 1

1. Install the `Interact.jl` package.


2. Run the following code
"""

# ╔═╡ f4531836-3fde-40df-8b96-1587cc4d2037
for i in 1:10
    j = i^2
    println("The square of $i is $(j)")
end

# ╔═╡ c9260621-2249-4a37-9bc8-e67967c5ccae
using Interact

@manipulate for i in 1:10
    j = i^2
    "The square of $i is $(j)"
end

# ╔═╡ 1e9b883b-0799-46fd-ba28-0652fcdc89d5


# ╔═╡ fdffa5b5-0ec9-4f0a-b170-f958e5709495
md"""
You should see a slider appear with the label `i`. When you manipulate the slider, the caption should show the value of `i` and its square, and should update when you move the slider.
"""

# ╔═╡ 4a82f384-7872-4730-9daf-5c5d9a148b9b
md"""
What happened here? A `for` loop iterates over its values. Somehow the `@manipulate` command, which is a **macro**, took the object "code for the `for` loop" and replaced it with "code for a slider with the same range"; in other words, `@manipulate` operated on code to produce some different code that did something useful -- it took in a program and replaced it by a different program.
"""

# ╔═╡ 7f2ee2d3-050c-47b1-ab77-51858651660f
md"""
We can see the result of the `@manipulate` by "expanding" the effect of the macro using `@macroexpand`. To make it easier to read, we will suppress some line information using the `MacroTools` package:
"""

# ╔═╡ 3b19a1ce-4950-46bc-aac3-56f9dd335563
code = @macroexpand @manipulate for i in 1:10
    j = i^2
    "The square of $i is $j"
end;

using MacroTools
MacroTools.striplines(code)

# ╔═╡ 5c2243f3-2fbb-4c1b-a51b-62516eb618c9
md"""
We see that the `for` loop has been replaced by code for manipulating a widget. The information about the variable name `i`,  the range `1:10` and and the code inside the `for` loop have been preserved, but they have been embedded in a certain way into a new *piece of code*.
"""

# ╔═╡ 5f53981e-b61e-4b23-8c1a-e2b24da67d1c
md"""
In order to carry out a *code transformation* like this, Julia allows us to *manipulate Julia code from within Julia*: we need to be able to get inside a piece of Julia code and modify it, *before* that code reaches the Julia compiler.

Finally we need to see how to wrap the result up into a macro. 
"""

# ╔═╡ ae487af5-0f68-44c7-8693-ed499de7b0b5
md"""
## Expressions 
"""

# ╔═╡ 522811ea-32aa-4501-843f-20e0c7f1cc69
i

# ╔═╡ d2c93c05-c245-4bd5-b655-12a39128f915
j = i^2

# ╔═╡ e342b2b1-f75e-49e9-968d-00feb6d77939
md"""
Let's start with just the part `j = i^2`. If we type this code into a *fresh* Julia session, we get the following error:
```
julia> j  = i^2
ERROR: UndefVarError: i not defined
Stacktrace:
 [1] top-level scope at none:0
```
since Julia is trying to *evaluate* the code using the values for the variables `i` and `j`, which are not defined.

[If instead we type this after running the above `@manipulate` command, `i` is interpreted as a slider and we get a different error.]
"""

# ╔═╡ ecb42fef-b833-467b-b4cf-339c61224997
md"""
For metaprogramming purposes, we do not wish to *evaluate* the code; instead, we just want to treat the code as unevaluated symbolic expressions, which will gain meaning only later. Julia allows us to construct unevaluated pieces of code as follows:
"""

# ╔═╡ b27af88b-130f-4874-8265-f675e993ef63
quote 
    j = i^2
end

# ╔═╡ 87942a87-aa67-4c3a-94e2-5573256168c8
md"""
or with the following shorthand syntax:
"""

# ╔═╡ 90dd1959-b677-4e8e-8969-9ad38bf4c268
:(j = i^2)

# ╔═╡ cec66c72-a710-4772-81e5-cb80e38f7360
md"""
#### Exercise 2

1. Define a variable `code` to be `:(j = i^2)`. 


2. What type is the object `code`? Note that `code` is just a normal Julia variable, of a particular special type.


3. Use the `dump` function to see what there is inside `code`. 
Remembering that `code` is just a particular kind of Julia object, use the Julia to play around interactively, seeing how you can extract pieces of the `code` object.


4. How is the operation `i^2` represented? What kind of object is that subpiece?


5. Copy `code` into a variable `code2`. *Modify* this to replace the power `2` with a power `3`. Make sure that the original `code` variable is *not* also modified.


6. Copy `code2` to a variable `code3`. Replace `i` with `i + 1` in `code3`.


7. Define a variable `i` with the value `4`. *Evaluate* the different `code` expressions using the `eval` function and check the *value* of the variable `j`.

"""

# ╔═╡ 5ce56321-b125-4fc9-a67e-af3bd8ff0b52
code = Meta.parse("j = i^2")

# ╔═╡ 70007757-cef8-4a61-a22c-97557c10cde7
typeof(code)

# ╔═╡ a75957ce-df3c-4d06-ab37-24c28223c70c
dump(code)

# ╔═╡ a396823a-255c-474c-95c4-740dc32c918a
code.head

# ╔═╡ cdb6135b-ab18-47cc-bb22-548a2c3933d7
typeof(ans)

# ╔═╡ 80c70710-7393-4744-bf04-c2733ef29555
:+

# ╔═╡ 09e9f3e0-627a-46de-8245-7b318853a14d
typeof(ans)

# ╔═╡ afc9966e-1a44-43f3-9679-93d99b3457e1
+

# ╔═╡ 392fdf9e-b09e-468f-b2b0-da74853329d2
code.args

# ╔═╡ 906ba4d2-cc31-481c-920a-db27d7bea71d
typeof(code.args)

# ╔═╡ 9150e575-ec71-4c2f-9464-818b9dac368d
code.args[1]

# ╔═╡ aebe63a2-6546-4855-8956-b0f2a1f6b699
typeof(code.args[1])

# ╔═╡ f916093d-c950-45c2-9a07-14a8b0c9d961
code.args[2]

# ╔═╡ ecf7d993-f186-4c7b-90cd-ebbf391362b6
typeof(code.args[2])

# ╔═╡ 4176cf1d-2d9f-4054-bedb-48aa561b5612
code.args[2].head

# ╔═╡ d5d7cd00-403d-410a-93be-3f4b7bbfa7a6
code.args[2].args

# ╔═╡ 58ba1f17-87dd-4395-a77e-e733a94b82ff
code.args[2].args[3]

# ╔═╡ 72357f57-94ec-4807-b923-e315691bf892
code.args[2].args[3] = 3

# ╔═╡ adf9f854-1252-4a9d-8bdd-4d2d637d63c8
code

# ╔═╡ 0440a738-05d6-4011-8d9c-3c4440fa50d8
code.args[2].args[2] = :(i + 1)

# ╔═╡ 0df91dca-4baf-4d38-a4b0-ff77e2c8fbb0
code

# ╔═╡ 6ccc334b-6512-4f01-a73a-4b94c4469e30
dump(ans)

# ╔═╡ c3251450-8347-4a4f-af52-adadf8fa17fa
md"""
We have just taken a (very simple) program, represented by `code`, and produced two new programs, `code2` and `code3`, which we ran using `eval`. This is the basis of all metaprogramming: taking in a piece of code, and modifying it to produce a new piece of code.
"""

# ╔═╡ 9ab8441f-7dc9-4a8d-a522-29e668ae123a


# ╔═╡ 8e9507d6-4a5d-4885-80e3-31d3603e17da
md"""
## Walking a syntax tree 
"""

# ╔═╡ d7e95362-16f1-445a-874b-bd321bcaac45
md"""
In the previous exercise, we modified a single `i` to `i + 1`. But in general we might have a more complicated expression like `i^2 + (i * (i - 3))` and we may wish to modify *all* of the `i`s in the expression to `(i+1)`s or to `k`s to produce the new expression. The problem is that they may be buried arbitrarily deeply. We thus need to find a way of walking through the whole expression to examine each subpiece of it. 
"""

# ╔═╡ ebda6433-c48f-4fee-bf8b-e9e774ae300a
code = :( i^2 + (i * (i - 3)) )

# ╔═╡ fbfe77dc-0f53-4014-a77f-e1604e613bfd
dump(code)

# ╔═╡ 66385c35-dcf1-44c2-85fe-203761bb3ea2
md"""
#### Exercise 3 

1. Write a function `walk!` that takes an expression object and replaces **all** of the `:x`s by `:z`s. 

    Hint: This function should be *recursive*: at some point it will need to call itself if it finds that a piece of the expression is itself an `Expr`.
    
    
2. Make this function into a more general pattern matcher that looks for a given sub-expression and replaces it by another.
"""

# ╔═╡ 4c8bde82-c96c-43a9-a006-6956208bba7f
3 isa Expr

# ╔═╡ 6fa34d03-ecb9-49cf-bb19-b37fdf5684b0
3 isa Symbol

# ╔═╡ dfb63c97-48e1-412e-a49c-915a183ffa08
3 isa Number

# ╔═╡ 1f2ed81a-31ec-42e6-8cf4-e7213d708b69
:x isa Expr

# ╔═╡ c9ffc07e-f6ac-4b4d-8c3b-3c05b352b9bf
:x isa Symbol

# ╔═╡ aed407de-294e-4041-9403-da51f1a0ec18
:(x + 1) isa Expr

# ╔═╡ 3cd54d83-85e0-4bc9-8bdc-8cf62ac4c307
function walk!(ex::Expr)
    for arg in ex.args
        @show arg
        if arg == :x
            arg = :z
        end
        
        if arg isa Expr
            walk!(arg)
        end
    end
end

# ╔═╡ d79bf8c7-262b-4f1f-b031-78c8a1f9cdad
ex = :(x*x + x)

# ╔═╡ d6a523e3-e6b1-4c00-9ba2-b24680af1ac0
walk!(ex)

# ╔═╡ 752265e0-4302-4958-8876-f4107bcf2100
ex

# ╔═╡ 70dc8adb-ab2f-4944-923f-924db65f7079
function walk!(ex::Expr)
    
    args = ex.args
    
    for i in 1:length(args)

        if args[i] == :x
            args[i] = :z
        end
        
        if args[i] isa Expr
            walk!(args[i])
        end
    end
    
    return ex
end

# ╔═╡ dcbba42d-ccb4-4b6f-8b64-2c4e2cd3570e
walk!(ex)

# ╔═╡ 35ffc623-d9ab-4bda-917a-96fb9ac9d569
ex

# ╔═╡ 5eb80f60-928d-4369-9f39-c2c22d7a62c6


# ╔═╡ 7dcd3307-8fe5-44f6-8175-641173eb40ae
md"""
#### Exercise 4
Julia by default uses standard 64-bit (or 32-bit) integers, which leads to surprising overflow behaviour, e.g.
"""

# ╔═╡ 4b68fe1c-12d8-4741-a81e-ed3e82e36cda
2^32 * 2^31

# ╔═╡ e2df3d00-c59b-4985-976d-96cc5aa7590c
md"""
No warning is given that there was an overflow in this calculation. 

However, in `Base` there are *checked* operations, such as `checked_mul`, which do throw an exception on overflow:
"""

# ╔═╡ fb785eed-cca1-49a9-b7eb-83f2780683c2
Base.checked_mul(2^60, 2^60)

# ╔═╡ 9e96a2aa-dffe-4933-b8c6-0c18ac674ee0
md"""
1. Write a function `make_checked` that replaces standard functions (`-`, `+`, `*`, `/`) in an expression by their corresponding checked counterparts.
"""

# ╔═╡ 49cbc031-d11e-4bd1-9749-e46064a51279
code

# ╔═╡ 7bd84e40-b5d1-4a26-baa1-2bc58eb320d8
ex = :(x + x * x)

# ╔═╡ a58e651c-3d98-43d0-9b7e-05afd43b0995
eval(ex)

# ╔═╡ 7383fb43-ae28-4781-aca7-70bd9cb3fe59
x = 3

# ╔═╡ b9a90b60-c11f-49c5-a766-57c9cd610f35
eval(ex)

# ╔═╡ 296048c5-8895-4d86-8d80-70c34f79214b
walk!(ex)

# ╔═╡ f3658d71-2c0d-43c1-ac3c-fd86070ef59f
ex

# ╔═╡ ea14f593-fcaa-481d-954e-134ab0d66106
eval(z)

# ╔═╡ 213524c6-163e-44a7-b302-2777dbeaac18
z = 5

# ╔═╡ 04688e15-47d9-43f6-84d2-703f4fd446ab
eval(z)

# ╔═╡ 778dab36-8746-4e96-9b1e-b7dd6b3c295e
md"""
## Generating repetitive code
"""

# ╔═╡ 5cd6868c-1d49-4346-9790-941a5186b160
md"""
One common application of basic metaprogramming in Julia is generating repetitive code. For example, there are situations in which it's useful to wrap on object of one type into a user-defined type in order to modify its behaviour in some way. 

e.g. Let's define a wrapper type `MyFloat` of `Float64`:
"""

# ╔═╡ 64a34288-39e3-49f1-9d02-1c31c2821a98
struct MyFloat
    x::Float64
end

# ╔═╡ e8b2d0ee-26dd-4c8c-a43b-21889598d4aa
md"""
We can generate objects of this type:
"""

# ╔═╡ ada46c0e-1ff5-43c9-91f8-4590c61013c6
a = MyFloat(3)
b = MyFloat(4)

# ╔═╡ 54117856-f2f8-4c31-9387-86bdbc6cb92a
md"""
But arithmetic operations are not defined:
"""

# ╔═╡ 3438cb89-4318-42f3-bda2-864e64947550
a + b

# ╔═╡ f708517a-49a4-4457-979a-2dcc4ddfbe4b
md"""
We can define them in the natural way:
"""

# ╔═╡ 7ed8f940-133f-4d7a-b405-209b014b711f
import Base: +, -, *, /

+(a::MyFloat, b::MyFloat) = a.x + b.x
-(a::MyFloat, b::MyFloat) = a.x - b.x

# ╔═╡ a6140e94-4125-4a94-8ac1-4637f7552f6f
md"""
But this will quickly get dull, and we could easily make a mistake. 
As usual, whenever we are repeating something more than twice, we should try to automate it.

We have some code of the form

    op(a::MyFloat, b::MyFloat) = op(a.x, b.x)
    
where `op` denotes the operator. Julia allows us to do this almost literally; we just need to substitute in the *value* of the *variable* `op`! 
"""

# ╔═╡ 28915673-0d98-4c01-a456-f7699491d466
md"""
#### Exercise 5

1. Let `op` be the symbol `:+`, which is an unevaluated version of the `+` operator.


2. Let `code` be the expression corresponding to `op(a::MyFloat, b::MyFloat) = op(a.x, b.x)`.


3. Substitute the *value* of `op` by replacing `op` by `$(op)`. Check that `code` contains the correct result.


4. Evaluate the code in order to generate the new method. Check that the method works for objects of type `MyFloat`.


5. We can replace the two steps "define `code`" and "evaluate `code`" by one step, `@eval` of the expression that defines `code`.


6. Write a loop over the operations `+`, `-`, `*` and `/` to define them all for our wrapper type.
"""

# ╔═╡ e921585b-6995-4daf-be67-9ace3f344a07
md"""
Finally we need to evaluate the code. The combination of `eval` and `:(...)` that we used above can be abbreviated to `@eval`:
"""

# ╔═╡ 5f5f3202-1257-4bf3-8f7d-cf811b181f9c
md"""
## Macros
"""

# ╔═╡ 8bc47e2d-bd01-4d6e-a623-3564156471c8
md"""
Finally let's return to macros. Recall that macros begin with `@` and behave like "super-functions", which take in a piece of code and replace it with another piece of code.
In fact, the effect of a macro call will be to insert the new piece of code in place of the old code, which is consequently compiled by the Julia compiler. 

Note that the user *does not need to explicitly pass an `Expr`ession object*; Julia turns the code that follows the macro call into an expression.
"""

# ╔═╡ 6db221b4-bc11-4920-99bd-2f9ca7eec9f0
md"""
To see this, let's define the simplest macro:
"""

# ╔═╡ c46ea253-0daf-4f0a-a1db-bf878b177beb
macro simple(expr)
    @show expr, typeof(expr)
    nothing   # return nothing for the moment
end

# ╔═╡ 2ea1d8eb-41e5-4f47-8a5d-6445506ff0fb
md"""
and run it with the following simple code:
"""

# ╔═╡ f83d327c-d1b1-4a05-9af0-49049864f90d
result = @simple yy = xx^2

# ╔═╡ b686cba3-8e28-4043-a200-9da1e08db156
result

# ╔═╡ 7aaeb0a2-9cb8-4d7e-802b-06aa72abd81f
macro walk!(expr)
    @show expr
    result = walk!(expr)
    @show result
    return result
end

# ╔═╡ 63e2d127-4178-4ebb-9c8c-c8f247505ced
@walk! x + x

# ╔═╡ 308ab0a8-a29c-45e4-a9c9-12156a6f53bc
@macroexpand @walk! x + x

# ╔═╡ 19187987-1d3c-4ba2-b3a1-87b4bf1d3649
md"""
We see that the Julia code that follows the macro call is passed to the macro, *already having been parsed into an `Expr` object*.
"""

# ╔═╡ 01efdcad-c996-4577-8722-56e81f100ab5
md"""
#### Exercise 6
"""

# ╔═╡ 9e5096f5-061e-4365-bc7c-81c509c2354d
md"""
1. Define a macro `@simple2` that returns the expression that was passed to it.


2. What happens when you call `@simple2 yy = xx^2`?


3. Define a variable `xx` with the value `3`. Does the macro work now?


4. Does the variable `xx` now exist?


5. To see what's happening, use `@macroexpand`.
"""

# ╔═╡ 51f3ef0d-8f8b-43ea-ac8c-7e41efbbce4c
macro simple2(expr)
    return expr
end

# ╔═╡ 27583f6a-6666-4582-a545-f27348e3d2cb
@simple2 yy = xx^2

# ╔═╡ 5251e228-0a44-4447-9992-2296ab89e58d
xx = 10

# ╔═╡ ba7e5c53-f6e4-4178-9155-8e2c777345ec
@simple2 yy = xx^2

# ╔═╡ 40e5af42-fc50-4987-948e-28729441da83
yy

# ╔═╡ d7a0bf86-9571-43eb-bab1-39ab842ce814
@macroexpand @simple2 yy = xx^2

# ╔═╡ 491ed759-d61e-4b7c-865f-79e3183c5cf0
md"""
You should find that the variable `yy` does *not* now exist, even though it seems like it should, since the code `yy = xx^2` was evaluated. However, macros by default do not "touch" variables in the context from where they are called, since this may have unintended consequences. We refer to macro **hygiene** (they do not "infect" code where they are not welcome).

Nonetheless, often we may *wish* them to modify variables in the context from which they are called, in which case we can "escape" from this hygiene using `esc`:
"""

# ╔═╡ 8e7f6916-94c1-4a66-9b37-9c71bc3e4859
op = :+

# ╔═╡ 719ab988-4cd1-4356-ac31-996e36cf5efa
code = :($op(x, y))

# ╔═╡ 42e5f45a-b8fe-45e1-b43e-2ede631a18cc


# ╔═╡ 769024b2-5631-4e17-84f1-dca6187329db
macro simple3(expr)
    return :($(esc(expr)))
end

# ╔═╡ f823d1ae-eaf0-4333-9692-a00febd96c36
@simple3 yy = xx^2

# ╔═╡ e7ad8810-5610-448e-b6f5-7e65fc31b68f
yy

# ╔═╡ 67d660a9-cd5f-448c-978e-78d9f1028ae5
@macroexpand @simple3 yy = xx^2

# ╔═╡ b8e79fd4-8d7d-4183-afe6-941fa7ebc03e
md"""
Note that once again the macro must return an *expression*. 
"""

# ╔═╡ 18ab2d1e-0fec-42ae-96b4-50853a0fb6c7
md"""
#### Exercise 7

1. Check that `@simple3` does create a variable `yy`.
"""

# ╔═╡ 3b62459d-584a-4107-b9c8-78e0c18be1d4


# ╔═╡ a1e1182b-63d5-4e3a-ab53-785edeff34ef
md"""
When writing macros, it is common to treat the macro as simply a wrapper around a function that does the hard work of transforming one `Expr` into another`:
"""

# ╔═╡ ecb6004a-19bd-4898-bc81-dc163a261341
md"""
#### Exercise 8

1. Write a macro `@walk!` that uses the function `walk!` defined above to replace terms in an expression. Apply it to `yy = xx^2`, replacing `xx` by `xx + 1`.


2. Write a macro `@checked` that replaces all arithmetic operations with checked operations.
"""

# ╔═╡ Cell order:
# ╟─148d5d63-2af4-42dc-82b7-66048377a773
# ╟─a5fa90ce-e4bc-490a-b86a-9a1acefc3b9c
# ╟─054538b8-6e2a-475c-96bd-b1a063b5e454
# ╟─819b2c2a-40f8-4a9c-be30-b8bd54efb53e
# ╠═f4531836-3fde-40df-8b96-1587cc4d2037
# ╠═c9260621-2249-4a37-9bc8-e67967c5ccae
# ╠═1e9b883b-0799-46fd-ba28-0652fcdc89d5
# ╟─fdffa5b5-0ec9-4f0a-b170-f958e5709495
# ╟─4a82f384-7872-4730-9daf-5c5d9a148b9b
# ╟─7f2ee2d3-050c-47b1-ab77-51858651660f
# ╠═3b19a1ce-4950-46bc-aac3-56f9dd335563
# ╟─5c2243f3-2fbb-4c1b-a51b-62516eb618c9
# ╟─5f53981e-b61e-4b23-8c1a-e2b24da67d1c
# ╟─ae487af5-0f68-44c7-8693-ed499de7b0b5
# ╠═522811ea-32aa-4501-843f-20e0c7f1cc69
# ╠═d2c93c05-c245-4bd5-b655-12a39128f915
# ╟─e342b2b1-f75e-49e9-968d-00feb6d77939
# ╟─ecb42fef-b833-467b-b4cf-339c61224997
# ╠═b27af88b-130f-4874-8265-f675e993ef63
# ╟─87942a87-aa67-4c3a-94e2-5573256168c8
# ╠═90dd1959-b677-4e8e-8969-9ad38bf4c268
# ╟─cec66c72-a710-4772-81e5-cb80e38f7360
# ╠═5ce56321-b125-4fc9-a67e-af3bd8ff0b52
# ╠═70007757-cef8-4a61-a22c-97557c10cde7
# ╠═a75957ce-df3c-4d06-ab37-24c28223c70c
# ╠═a396823a-255c-474c-95c4-740dc32c918a
# ╠═cdb6135b-ab18-47cc-bb22-548a2c3933d7
# ╠═80c70710-7393-4744-bf04-c2733ef29555
# ╠═09e9f3e0-627a-46de-8245-7b318853a14d
# ╠═afc9966e-1a44-43f3-9679-93d99b3457e1
# ╠═392fdf9e-b09e-468f-b2b0-da74853329d2
# ╠═906ba4d2-cc31-481c-920a-db27d7bea71d
# ╠═9150e575-ec71-4c2f-9464-818b9dac368d
# ╠═aebe63a2-6546-4855-8956-b0f2a1f6b699
# ╠═f916093d-c950-45c2-9a07-14a8b0c9d961
# ╠═ecf7d993-f186-4c7b-90cd-ebbf391362b6
# ╠═4176cf1d-2d9f-4054-bedb-48aa561b5612
# ╠═d5d7cd00-403d-410a-93be-3f4b7bbfa7a6
# ╠═58ba1f17-87dd-4395-a77e-e733a94b82ff
# ╠═72357f57-94ec-4807-b923-e315691bf892
# ╠═adf9f854-1252-4a9d-8bdd-4d2d637d63c8
# ╠═0440a738-05d6-4011-8d9c-3c4440fa50d8
# ╠═0df91dca-4baf-4d38-a4b0-ff77e2c8fbb0
# ╠═6ccc334b-6512-4f01-a73a-4b94c4469e30
# ╟─c3251450-8347-4a4f-af52-adadf8fa17fa
# ╠═9ab8441f-7dc9-4a8d-a522-29e668ae123a
# ╟─8e9507d6-4a5d-4885-80e3-31d3603e17da
# ╟─d7e95362-16f1-445a-874b-bd321bcaac45
# ╠═ebda6433-c48f-4fee-bf8b-e9e774ae300a
# ╠═fbfe77dc-0f53-4014-a77f-e1604e613bfd
# ╟─66385c35-dcf1-44c2-85fe-203761bb3ea2
# ╠═4c8bde82-c96c-43a9-a006-6956208bba7f
# ╠═6fa34d03-ecb9-49cf-bb19-b37fdf5684b0
# ╠═dfb63c97-48e1-412e-a49c-915a183ffa08
# ╠═1f2ed81a-31ec-42e6-8cf4-e7213d708b69
# ╠═c9ffc07e-f6ac-4b4d-8c3b-3c05b352b9bf
# ╠═aed407de-294e-4041-9403-da51f1a0ec18
# ╠═3cd54d83-85e0-4bc9-8bdc-8cf62ac4c307
# ╠═d79bf8c7-262b-4f1f-b031-78c8a1f9cdad
# ╠═d6a523e3-e6b1-4c00-9ba2-b24680af1ac0
# ╠═752265e0-4302-4958-8876-f4107bcf2100
# ╠═70dc8adb-ab2f-4944-923f-924db65f7079
# ╠═dcbba42d-ccb4-4b6f-8b64-2c4e2cd3570e
# ╠═35ffc623-d9ab-4bda-917a-96fb9ac9d569
# ╠═5eb80f60-928d-4369-9f39-c2c22d7a62c6
# ╟─7dcd3307-8fe5-44f6-8175-641173eb40ae
# ╠═4b68fe1c-12d8-4741-a81e-ed3e82e36cda
# ╟─e2df3d00-c59b-4985-976d-96cc5aa7590c
# ╠═fb785eed-cca1-49a9-b7eb-83f2780683c2
# ╟─9e96a2aa-dffe-4933-b8c6-0c18ac674ee0
# ╠═49cbc031-d11e-4bd1-9749-e46064a51279
# ╠═7bd84e40-b5d1-4a26-baa1-2bc58eb320d8
# ╠═a58e651c-3d98-43d0-9b7e-05afd43b0995
# ╠═7383fb43-ae28-4781-aca7-70bd9cb3fe59
# ╠═b9a90b60-c11f-49c5-a766-57c9cd610f35
# ╠═296048c5-8895-4d86-8d80-70c34f79214b
# ╠═f3658d71-2c0d-43c1-ac3c-fd86070ef59f
# ╠═ea14f593-fcaa-481d-954e-134ab0d66106
# ╠═213524c6-163e-44a7-b302-2777dbeaac18
# ╠═04688e15-47d9-43f6-84d2-703f4fd446ab
# ╟─778dab36-8746-4e96-9b1e-b7dd6b3c295e
# ╟─5cd6868c-1d49-4346-9790-941a5186b160
# ╠═64a34288-39e3-49f1-9d02-1c31c2821a98
# ╟─e8b2d0ee-26dd-4c8c-a43b-21889598d4aa
# ╠═ada46c0e-1ff5-43c9-91f8-4590c61013c6
# ╟─54117856-f2f8-4c31-9387-86bdbc6cb92a
# ╠═3438cb89-4318-42f3-bda2-864e64947550
# ╟─f708517a-49a4-4457-979a-2dcc4ddfbe4b
# ╠═7ed8f940-133f-4d7a-b405-209b014b711f
# ╟─a6140e94-4125-4a94-8ac1-4637f7552f6f
# ╟─28915673-0d98-4c01-a456-f7699491d466
# ╟─e921585b-6995-4daf-be67-9ace3f344a07
# ╟─5f5f3202-1257-4bf3-8f7d-cf811b181f9c
# ╟─8bc47e2d-bd01-4d6e-a623-3564156471c8
# ╟─6db221b4-bc11-4920-99bd-2f9ca7eec9f0
# ╠═c46ea253-0daf-4f0a-a1db-bf878b177beb
# ╟─2ea1d8eb-41e5-4f47-8a5d-6445506ff0fb
# ╠═f83d327c-d1b1-4a05-9af0-49049864f90d
# ╠═b686cba3-8e28-4043-a200-9da1e08db156
# ╠═7aaeb0a2-9cb8-4d7e-802b-06aa72abd81f
# ╠═63e2d127-4178-4ebb-9c8c-c8f247505ced
# ╠═308ab0a8-a29c-45e4-a9c9-12156a6f53bc
# ╟─19187987-1d3c-4ba2-b3a1-87b4bf1d3649
# ╟─01efdcad-c996-4577-8722-56e81f100ab5
# ╟─9e5096f5-061e-4365-bc7c-81c509c2354d
# ╠═51f3ef0d-8f8b-43ea-ac8c-7e41efbbce4c
# ╠═27583f6a-6666-4582-a545-f27348e3d2cb
# ╠═5251e228-0a44-4447-9992-2296ab89e58d
# ╠═ba7e5c53-f6e4-4178-9155-8e2c777345ec
# ╠═40e5af42-fc50-4987-948e-28729441da83
# ╠═d7a0bf86-9571-43eb-bab1-39ab842ce814
# ╟─491ed759-d61e-4b7c-865f-79e3183c5cf0
# ╠═8e7f6916-94c1-4a66-9b37-9c71bc3e4859
# ╠═719ab988-4cd1-4356-ac31-996e36cf5efa
# ╠═42e5f45a-b8fe-45e1-b43e-2ede631a18cc
# ╠═769024b2-5631-4e17-84f1-dca6187329db
# ╠═f823d1ae-eaf0-4333-9692-a00febd96c36
# ╠═e7ad8810-5610-448e-b6f5-7e65fc31b68f
# ╠═67d660a9-cd5f-448c-978e-78d9f1028ae5
# ╟─b8e79fd4-8d7d-4183-afe6-941fa7ebc03e
# ╟─18ab2d1e-0fec-42ae-96b4-50853a0fb6c7
# ╠═3b62459d-584a-4107-b9c8-78e0c18be1d4
# ╟─a1e1182b-63d5-4e3a-ab53-785edeff34ef
# ╟─ecb6004a-19bd-4898-bc81-dc163a261341
