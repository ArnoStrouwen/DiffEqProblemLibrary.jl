srand(100)

### ODE Examples

# Linear ODE
linear = (u,p,t) -> (1.01*u)
(f::typeof(linear))(::Type{Val{:analytic}},u0,p,t) = u0*exp(1.01*t)
"""
Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

with Float64s
"""
prob_ode_linear = ODEProblem(linear,1/2,(0.0,1.0))

const linear_bigα = parse(BigFloat,"1.01")
f_linearbig = (u,p,t) -> (linear_bigα*u)
(f::typeof(f_linearbig))(::Type{Val{:analytic}},u0,p,t) = u0*exp(linear_bigα*t)
"""
Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

with BigFloats
"""
prob_ode_bigfloatlinear = ODEProblem(f_linearbig,parse(BigFloat,"0.5"),(0.0,1.0))

f_2dlinear = (du,u,p,t) -> begin
  for i in 1:length(u)
    du[i] = 1.01*u[i]
  end
end
(f::typeof(f_2dlinear))(::Type{Val{:analytic}},u0,p,t) = u0*exp.(1.01*t)
"""
4x2 version of the Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

with Float64s
"""
prob_ode_2Dlinear = ODEProblem(f_2dlinear,rand(4,2),(0.0,1.0))

"""
100x100 version of the Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

with Float64s
"""
prob_ode_large2Dlinear = ODEProblem(f_2dlinear,rand(100,100),(0.0,1.0))

f_2dlinearbig = (du,u,p,t) -> begin
  for i in 1:length(u)
    du[i] = linear_bigα*u[i]
  end
end
(f::typeof(f_2dlinearbig))(::Type{Val{:analytic}},u0,p,t) = u0*exp.(1.01*t)
"""
4x2 version of the Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

with BigFloats
"""
prob_ode_bigfloat2Dlinear = ODEProblem(f_2dlinearbig,map(BigFloat,rand(4,2)).*ones(4,2)/2,(0.0,1.0))
f_2dlinear_notinplace = (u,p,t) -> 1.01*u
(f::typeof(f_2dlinear_notinplace))(::Type{Val{:analytic}},u0,p,t) = u0*exp.(1.01*t)
"""
4x2 version of the Linear ODE

```math
\\frac{du}{dt} = αu
```

with initial condition ``u0=1/2``, ``α=1.01``, and solution

```math
u(t) = u0e^{αt}
```

on Float64. Purposefully not in-place as a test.
"""
prob_ode_2Dlinear_notinplace = ODEProblem(f_2dlinear_notinplace,rand(4,2),(0.0,1.0))

## Lotka-Volterra


lotka = @ode_def_nohes LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a=>1.5 b=>1.0 c=>3.0 d=1.0

"""
Lotka-Voltera Equations

```math
\\frac{dx}{dt} = ax - bxy
\\frac{dy}{dt} = -cy + dxy
```

with initial condition ``x=y=1``
"""
prob_ode_lotkavoltera = ODEProblem(lotka,[1;1],(0.0,1.0))

## Fitzhugh-Nagumo

fitz = @ode_def_nohes FitzhughNagumo begin
  dv = v - v^3/3 -w + l
  dw = τinv*(v +  a - b*w)
end a=0.7 b=0.8 τinv=(1/12.5) l=0.5
"""
Fitzhugh-Nagumo

```math
\\frac{dv}{dt} = v - \\frac{v^3}{3} - w + I_{est}
τ \\frac{dw}{dt} = v + a -bw
```

with initial condition ``v=w=1``
"""
prob_ode_fitzhughnagumo = ODEProblem(fitz,[1.0;1.0],(0.0,1.0))

#Van der Pol Equations
van = @ode_def_noinvhes VanDerPol begin
  dy = μ*(1-x^2)*y - x
  dx = 1*y
end μ=>1.

"""
Van der Pol Equations

```math
\\begin{align}
\\frac{dx}{dt} &= y \\\\
\\frac{dy}{dt} &= μ(1-x^2)y -x
\\end{align}
```

with ``μ=1.0`` and ``u0=[0,\\sqrt{3}]``

Non-stiff parameters.
"""
prob_ode_vanderpol = ODEProblem(van,[0;sqrt(3)],(0.0,1.0))

van_stiff = VanDerPol(μ=1e6)
"""Van der Pol Equations

```math
\\begin{align}
\\frac{dx}{dt} &= y \\\\
\\frac{dy}{dt} &= μ(1-x^2)y -x
\\end{align}
```

with ``μ=10^6`` and ``u0=[0,\\sqrt{3}]``

Stiff parameters.
"""
prob_ode_vanderpol_stiff = ODEProblem(van_stiff,[0;sqrt(3)],(0.0,1.0))

# ROBER

rober = @ode_def_noinvjac Rober begin
  dy₁ = -k₁*y₁+k₃*y₂*y₃
  dy₂ =  k₁*y₁-k₂*y₂^2-k₃*y₂*y₃
  dy₃ =  k₂*y₂^2
end k₁=>0.04 k₂=>3e7 k₃=>1e4

"""
The Robertson biochemical reactions:

```math
\\begin{align}
\\frac{dy₁}{dt} &= -k₁y₁+k₃y₂y₃  \\\\
\\frac{dy₂}{dt} &=  k₁y₁-k₂y₂^2-k₃y₂y₃ \\\\
\\frac{dy₃}{dt} &=  k₂y₂^2
\\end{align}
```

where ``k₁=0.04``, ``k₂=3\\times10^7``, ``k₃=10^4``. For details, see:

Hairer Norsett Wanner Solving Ordinary Differential Equations I - Nonstiff Problems Page 129

Usually solved on `[0,1e11]`
"""
prob_ode_rober = ODEProblem(rober,[1.0;0.0;0.0],(0.0,1e11))

# Three Body
const threebody_μ = parse(BigFloat,"0.012277471"); const threebody_μ′ = 1 - threebody_μ

threebody = (du,u,p,t) -> begin
  # 1 = y₁
  # 2 = y₂
  # 3 = y₁'
  # 4 = y₂'
  D₁ = ((u[1]+threebody_μ)^2 + u[2]^2)^(3/2)
  D₂ = ((u[1]-threebody_μ′)^2 + u[2]^2)^(3/2)
  du[1] = u[3]
  du[2] = u[4]
  du[3] = u[1] + 2u[4] - threebody_μ′*(u[1]+threebody_μ)/D₁ - threebody_μ*(u[1]-threebody_μ′)/D₂
  du[4] = u[2] - 2u[3] - threebody_μ′*u[2]/D₁ - threebody_μ*u[2]/D₂
end
"""
The ThreeBody problem as written by Hairer:

```math
\\begin{align}
y₁′′ &= y₁ + 2y₂′ - μ′\\frac{y₁+μ}{D₁} - μ\\frac{y₁-μ′}{D₂} \\\\
y₂′′ &= y₂ - 2y₁′ - μ′\\frac{y₂}{D₁} - μ\\frac{y₂}{D₂} \\\\
D₁ &= ((y₁+μ)^2 + y₂^2)^{3/2} \\\\
D₂ &= ((y₁-μ′)^2+y₂^2)^{3/2} \\\\
μ &= 0.012277471 \\\\
μ′ &=1-μ
\\end{align}
```

From Hairer Norsett Wanner Solving Ordinary Differential Equations I - Nonstiff Problems Page 129

Usually solved on `t₀ = 0.0`; `T = parse(BigFloat,"17.0652165601579625588917206249")`
Periodic with that setup.
"""
prob_ode_threebody = ODEProblem(threebody,[0.994, 0.0, 0.0, parse(BigFloat,"-2.00158510637908252240537862224")],(parse(BigFloat,"0.0"),parse(BigFloat,"17.0652165601579625588917206249")))

# Rigid Body Equations

rigid = @ode_def_noinvjac RigidBody begin
  dy₁  = I₁*y₂*y₃
  dy₂  = I₂*y₁*y₃
  dy₃  = I₃*y₁*y₂
end I₁=>-2 I₂=>1.25 I₃=>-.5

"""
Rigid Body Equations

```math
\\begin{align}
\\frac{dy₁}{dt}  &= I₁y₂y₃ \\\\
\\frac{dy₂}{dt}  &= I₂y₁y₃ \\\\
\\frac{dy₃}{dt}  &= I₃y₁y₂
\\end{align}
```

with ``I₁=-2``, ``I₂=1.25``, and ``I₃=-1/2``.

The initial condition is ``y=[1.0;0.0;0.9]``.

From Solving Differential Equations in R by Karline Soetaert

or Hairer Norsett Wanner Solving Ordinary Differential Equations I - Nonstiff Problems Page 244

Usually solved from 0 to 20.
"""
prob_ode_rigidbody = ODEProblem(rigid,[1.0,0.0,0.9],(0.0,20.0))

# Pleiades Problem

pleiades = (du,u,p,t) -> begin
  x = view(u,1:7)   # x
  y = view(u,8:14)  # y
  v = view(u,15:21) # x′
  w = view(u,22:28) # y′
  du[1:7] .= v
  du[8:14].= w
  for i in 14:21
    du[i] = zero(u)
  end
  for i=1:7,j=1:7
    if i != j
      r = ((x[i]-x[j])^2 + (y[i] - y[j])^2)^(3/2)
      du[14+i] += j*(x[j] - x[i])/r
      du[21+i] += j*(y[j] - y[i])/r
    end
  end
end
"""
Pleiades Problem

```math
\\begin{align}
xᵢ′′ &= \\sum_{j≠i} mⱼ(xⱼ-xᵢ)/rᵢⱼ \\\\
yᵢ′′ &= \\sum_{j≠i} mⱼ(yⱼ-yᵢ)/rᵢⱼ
\\end{align}
```

where

```math
rᵢⱼ = ((xᵢ-xⱼ)^2 + (yᵢ-yⱼ)^2)^{3/2}
```

and initial conditions are

```math
\\begin{align}
x₁(0)&=3  \\\\
x₂(0)&=3  \\\\
x₃(0)&=-1  \\\\
x₄(0)&=-3  \\\\
x₅(0)&=2  \\\\
x₆(0)&=-2  \\\\
x₇(0)&=2  \\\\
y₁(0)&=3  \\\\
y₂(0)&=-3  \\\\
y₃(0)&=2  \\\\
y₄(0)&=0  \\\\
y₅(0)&=0  \\\\
y₆(0)&=-4  \\\\
y₇(0)&=4
\\end{align}
```

and with ``xᵢ′(0)=yᵢ′(0)=0`` except for

```math
\\begin{align}
x₆′(0)&=1.75 \\\\
x₇′(0)&=-1.5 \\\\
y₄′(0)&=-1.25 \\\\
y₅′(0)&=1
\\end{align}
```

From Hairer Norsett Wanner Solving Ordinary Differential Equations I - Nonstiff Problems Page 244

Usually solved from 0 to 3.
"""
prob_ode_pleiades = ODEProblem(pleiades,[3.0,3.0,-1.0,-3.0,2.0,-2.0,2.0,3.0,-3.0,2.0,0,0,-4.0,4.0,0,0,0,0,0,1.75,-1.5,0,0,0,-1.25,1,0,0],(0.0,3.0))


srand(100)
const mm_A = rand(4,4)
mm_linear = function (du,u,p,t)
  A_mul_B!(du,mm_A,u)
end
const MM_linear =full(Diagonal(0.5ones(4)))
(::typeof(mm_linear))(::Type{Val{:analytic}},u0,p,t) = expm(inv(MM_linear)*mm_A*t)*u0
prob_ode_mm_linear = ODEProblem(mm_linear,rand(4),(0.0,1.0),mass_matrix=MM_linear)
