#############################
### 2D Coordinate systems ###
#############################
"""
`Polar{T}(r::T, θ::T)` - 2D polar coordinates
"""
struct Polar{T}
    r::T
    θ::T
end
Base.show(io::IO, x::Polar) = print(io, "Polar(r=$(x.r), θ=$(x.θ) rad)")
Base.isapprox(p1::Polar, p2::Polar; kwargs...) = isapprox(p1.r, p2.r; kwargs...) && isapprox(p1.θ, p2.θ; kwargs...)
Base.eltype(::Polar{T}) where {T} = T
Base.eltype(::Type{Polar{T}}) where {T} = T

"`PolarFromCartesian()` - transformation from `AbstractVector` of length 2 to `Polar` type"
struct PolarFromCartesian <: Transformation; end
"`CartesianFromPolar()` - transformation from `Polar` type to `SVector{2}` type"
struct CartesianFromPolar <: Transformation; end

Base.show(io::IO, trans::PolarFromCartesian) = print(io, "PolarFromCartesian()")
Base.show(io::IO, trans::CartesianFromPolar) = print(io, "CartesianFromPolar()")

function (::PolarFromCartesian)(x::AbstractVector)
    length(x) == 2 || error("Polar transform takes a 2D coordinate")

    Polar(sqrt(x[1]*x[1] + x[2]*x[2]), atan(x[2], x[1]))
end

function transform_deriv(::PolarFromCartesian, x::AbstractVector)
    length(x) == 2 || error("Polar transform takes a 2D coordinate")

    r = sqrt(x[1]*x[1] + x[2]*x[2])
    f = x[2] / x[1]
    c = one(eltype(x))/(x[1]*(one(eltype(x)) + f*f))
    @SMatrix [ x[1]/r    x[2]/r ;
              -f*c       c      ]
end
transform_deriv_params(::PolarFromCartesian, x::AbstractVector) = error("PolarFromCartesian has no parameters")

function (::CartesianFromPolar)(x::Polar)
    s,c = sincos(x.θ)
    SVector(x.r * c, x.r * s)
end
function transform_deriv(::CartesianFromPolar, x::Polar)
    sθ, cθ = sincos(x.θ)
    @SMatrix [cθ  -x.r*sθ ;
              sθ   x.r*cθ ]
end
transform_deriv_params(::CartesianFromPolar, x::Polar) = error("CartesianFromPolar has no parameters")

Base.inv(::PolarFromCartesian) = CartesianFromPolar()
Base.inv(::CartesianFromPolar) = PolarFromCartesian()

compose(::PolarFromCartesian, ::CartesianFromPolar) = IdentityTransformation()
compose(::CartesianFromPolar, ::PolarFromCartesian) = IdentityTransformation()

# For convenience
Base.convert(::Type{Polar}, v::AbstractVector) = PolarFromCartesian()(v)
@inline Base.convert(::Type{V}, p::Polar) where {V <: AbstractVector} = convert(V, CartesianFromPolar()(p))
@inline Base.convert(::Type{V}, p::Polar) where {V <: StaticVector} = convert(V, CartesianFromPolar()(p))


#############################
### 3D Coordinate Systems ###
#############################
"""
Spherical(r, θ, ϕ) - 3D spherical coordinates
"""
struct Spherical{T}
    r::T
    θ::T
    ϕ::T
end
Base.show(io::IO, x::Spherical) = print(io, "Spherical(r=$(x.r), θ=$(x.θ) rad, ϕ=$(x.ϕ) rad)")
Base.isapprox(p1::Spherical, p2::Spherical; kwargs...) = isapprox(p1.r, p2.r; kwargs...) && isapprox(p1.θ, p2.θ; kwargs...) && isapprox(p1.ϕ, p2.ϕ; kwargs...)
Base.eltype(::Spherical{T}) where {T} = T
Base.eltype(::Type{Spherical{T}}) where {T} = T

"""
ISOSpherical(r, θ, ϕ) - 3D spherical coordinates
"""
struct ISOSpherical{T}
    r::T
    θ::T
    ϕ::T
end
Base.show(io::IO, x::ISOSpherical) = print(io, "ISOSpherical(r=$(x.r), θ=$(x.θ) rad, ϕ=$(x.ϕ) rad)")
Base.isapprox(p1::ISOSpherical, p2::ISOSpherical; kwargs...) = isapprox(p1.r, p2.r; kwargs...) && isapprox(p1.θ, p2.θ; kwargs...) && isapprox(p1.ϕ, p2.ϕ; kwargs...)
Base.eltype(::ISOSpherical{T}) where {T} = T
Base.eltype(::Type{ISOSpherical{T}}) where {T} = T

"""
Cylindrical(r, θ, z) - 3D cylindrical coordinates
"""
struct Cylindrical{T}
    r::T
    θ::T
    z::T
end
Base.show(io::IO, x::Cylindrical) = print(io, "Cylindrical(r=$(x.r), θ=$(x.θ) rad, z=$(x.z))")
Base.isapprox(p1::Cylindrical, p2::Cylindrical; kwargs...) = isapprox(p1.r, p2.r; kwargs...) && isapprox(p1.θ, p2.θ; kwargs...) && isapprox(p1.z, p2.z; kwargs...)
Base.eltype(::Cylindrical{T}) where {T} = T
Base.eltype(::Type{Cylindrical{T}}) where {T} = T

"`SphericalFromCartesian()` - transformation from 3D point to `Spherical` type"
struct SphericalFromCartesian <: Transformation; end
"`ISOSphericalFromCartesian()` - transformation from 3D point to `ISOSpherical` type"
struct ISOSphericalFromCartesian <: Transformation; end
"`CartesianFromSpherical()` - transformation from `Spherical` or `ISOSpherical` type to `SVector{3}` type"
struct CartesianFromSpherical <: Transformation; end
"`CylindricalFromCartesian()` - transformation from 3D point to `Cylindrical` type"
struct CylindricalFromCartesian <: Transformation; end
"`CartesianFromCylindrical()` - transformation from `Cylindrical` type to `SVector{3}` type"
struct CartesianFromCylindrical <: Transformation; end
"`CylindricalFromSpherical()` - transformation from `Spherical` or `ISOSpherical` type to `Cylindrical` type"
struct CylindricalFromSpherical <: Transformation; end
"`SphericalFromCylindrical()` - transformation from `Cylindrical` type to `Spherical` type"
struct SphericalFromCylindrical <: Transformation; end
"`ISOSphericalFromCylindrical()` - transformation from `Cylindrical` type to `ISOSpherical` type"
struct ISOSphericalFromCylindrical <: Transformation; end

Base.show(io::IO, trans::SphericalFromCartesian) = print(io, "SphericalFromCartesian()")
Base.show(io::IO, trans::ISOSphericalFromCartesian) = print(io, "ISOSphericalFromCartesian()")
Base.show(io::IO, trans::CartesianFromSpherical) = print(io, "CartesianFromSpherical()")
Base.show(io::IO, trans::CylindricalFromCartesian) = print(io, "CylindricalFromCartesian()")
Base.show(io::IO, trans::CartesianFromCylindrical) = print(io, "CartesianFromCylindrical()")
Base.show(io::IO, trans::CylindricalFromSpherical) = print(io, "CylindricalFromSpherical()")
Base.show(io::IO, trans::SphericalFromCylindrical) = print(io, "SphericalFromCylindrical()")
Base.show(io::IO, trans::ISOSphericalFromCylindrical) = print(io, "ISOSphericalFromCylindrical()")

# Cartesian <-> Spherical
function (::SphericalFromCartesian)(x::AbstractVector)
    length(x) == 3 || error("Spherical transform takes a 3D coordinate")

    Spherical(sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3]), atan(x[2],x[1]), atan(x[3]/sqrt(x[1]*x[1] + x[2]*x[2])))
end
function transform_deriv(::SphericalFromCartesian, x::AbstractVector)
    length(x) == 3 || error("Spherical transform takes a 3D coordinate")
    T = eltype(x)

    r = sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3])
    rxy = sqrt(x[1]*x[1] + x[2]*x[2])
    fxy = x[2] / x[1]
    cxy = one(T)/(x[1]*(one(T) + fxy*fxy))
    f = -x[3]/(rxy*r*r)

    @SMatrix [ x[1]/r   x[2]/r  x[3]/r;
          -fxy*cxy  cxy     zero(T);
           f*x[1]   f*x[2]  rxy/(r*r) ]
end
transform_deriv_params(::SphericalFromCartesian, x::AbstractVector) = error("SphericalFromCartesian has no parameters")

function (::ISOSphericalFromCartesian)(x::AbstractVector{T}) where {T}
    length(x) == 3 || error("ISOSpherical transform takes a 3D coordinate")
    r = sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3])
    ISOSpherical{T}(r, acos(x[3]/r), atan(x[2], x[1]))
end
function transform_deriv(::ISOSphericalFromCartesian, x::AbstractVector)
    length(x) == 3 || error("ISOSpherical transform takes a 3D coordinate")
    T = eltype(x)
    error("Not implemented yet!")
    r = sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3])
    rxy = sqrt(x[1]*x[1] + x[2]*x[2])
    fxy = x[2] / x[1]
    cxy = one(T)/(x[1]*(one(T) + fxy*fxy))
    f = -x[3]/(rxy*r*r)

    @SMatrix [ x[1]/r   x[2]/r  x[3]/r;
          -fxy*cxy  cxy     zero(T);
           f*x[1]   f*x[2]  rxy/(r*r) ]
end
transform_deriv_params(::ISOSphericalFromCartesian, x::AbstractVector) = error("ISOSphericalFromCartesian has no parameters")

function (::CartesianFromSpherical)(x::Spherical)
    sθ, cθ = sincos(x.θ)
    sϕ, cϕ = sincos(x.ϕ)
    SVector(x.r * cθ * cϕ, x.r * sθ * cϕ, x.r * sϕ)
end
function transform_deriv(::CartesianFromSpherical, x::Spherical{T}) where T
    sθ, cθ = sincos(x.θ)
    sϕ, cϕ = sincos(x.ϕ)
    @SMatrix [cθ*cϕ -x.r*sθ*cϕ -x.r*cθ*sϕ ;
              sθ*cϕ  x.r*cθ*cϕ -x.r*sθ*sϕ ;
              sϕ     zero(T)    x.r * cϕ  ]
end
transform_deriv_params(::CartesianFromSpherical, x::Spherical) = error("CartesianFromSpherical has no parameters")

function (::CartesianFromSpherical)(x::ISOSpherical)
    sθ, cθ = sincos(x.θ)
    sϕ, cϕ = sincos(x.ϕ)
    SVector(x.r * sθ * cϕ, x.r * sθ * sϕ, x.r * cθ)
end
function transform_deriv(::CartesianFromSpherical, x::ISOSpherical{T}) where T
    error("Not implemented yet!")
    sθ, cθ = sincos(x.θ)
    sϕ, cϕ = sincos(x.ϕ)
    @SMatrix [cθ*cϕ -x.r*sθ*cϕ -x.r*cθ*sϕ ;
              sθ*cϕ  x.r*cθ*cϕ -x.r*sθ*sϕ ;
              sϕ     zero(T)    x.r * cϕ  ]
end
transform_deriv_params(::CartesianFromSpherical, x::ISOSpherical) = error("CartesianFromSpherical has no parameters")

# Cartesian <-> Cylindrical
function (::CylindricalFromCartesian)(x::AbstractVector)
    length(x) == 3 || error("Cylindrical transform takes a 3D coordinate")

    Cylindrical(sqrt(x[1]*x[1] + x[2]*x[2]), atan(x[2],x[1]), x[3])
end

function transform_deriv(::CylindricalFromCartesian, x::AbstractVector)
    length(x) == 3 || error("Cylindrical transform takes a 3D coordinate")
    T = eltype(x)

    r = sqrt(x[1]*x[1] + x[2]*x[2])
    f = x[2] / x[1]
    c = one(T)/(x[1]*(one(T) + f*f))
    @SMatrix [ x[1]/r   x[2]/r   zero(T) ;
              -f*c      c        zero(T) ;
               zero(T)  zero(T)  one(T)  ]
end
transform_deriv_params(::CylindricalFromCartesian, x::AbstractVector) = error("CylindricalFromCartesian has no parameters")

function (::CartesianFromCylindrical)(x::Cylindrical)
    sθ, cθ = sincos(x.θ)
    SVector(x.r * cθ, x.r * sθ, x.z)
end
function transform_deriv(::CartesianFromCylindrical, x::Cylindrical{T}) where {T}
    sθ, cθ = sincos(x.θ)
    @SMatrix [cθ      -x.r*sθ  zero(T) ;
              sθ       x.r*cθ  zero(T) ;
              zero(T)  zero(T) one(T)  ]
end
transform_deriv_params(::CartesianFromPolar, x::Cylindrical) = error("CartesianFromCylindrical has no parameters")

# Spherical <-> Cylindrical (TODO direct would be faster)
function (::CylindricalFromSpherical)(x::Spherical)
    CylindricalFromCartesian()(CartesianFromSpherical()(x))
end
function transform_deriv(::CylindricalFromSpherical, x::Spherical)
    M1 = transform_deriv(CylindricalFromCartesian(), CartesianFromSpherical()(x))
    M2 = transform_deriv(CartesianFromSpherical(), x)
    return M1*M2
end
transform_deriv_params(::CylindricalFromSpherical, x::Spherical) = error("CylindricalFromSpherical has no parameters")

function (::CylindricalFromSpherical)(x::ISOSpherical)
    CylindricalFromCartesian()(CartesianFromSpherical()(x))
end
function transform_deriv(::CylindricalFromSpherical, x::ISOSpherical)
    M1 = transform_deriv(CylindricalFromCartesian(), CartesianFromSpherical()(x))
    M2 = transform_deriv(CartesianFromSpherical(), x)
    return M1*M2
end
transform_deriv_params(::CylindricalFromSpherical, x::ISOSpherical) = error("CylindricalFromSpherical has no parameters")

function (::SphericalFromCylindrical)(x::Cylindrical)
    SphericalFromCartesian()(CartesianFromCylindrical()(x))
end
function transform_deriv(::SphericalFromCylindrical, x::Cylindrical)
    M1 = transform_deriv(SphericalFromCartesian(), CartesianFromCylindrical()(x))
    M2 = transform_deriv(CartesianFromCylindrical(), x)
    return M1*M2
end
transform_deriv_params(::SphericalFromCylindrical, x::Cylindrical) = error("SphericalFromCylindrical has no parameters")

function (::ISOSphericalFromCylindrical)(x::Cylindrical)
    ISOSphericalFromCartesian()(CartesianFromCylindrical()(x))
end
function transform_deriv(::ISOSphericalFromCylindrical, x::Cylindrical)
    M1 = transform_deriv(ISOSphericalFromCartesian(), CartesianFromCylindrical()(x))
    M2 = transform_deriv(CartesianFromCylindrical(), x)
    return M1*M2
end
transform_deriv_params(::ISOSphericalFromCylindrical, x::Cylindrical) = error("ISOSphericalFromCylindrical has no parameters")

Base.inv(::SphericalFromCartesian)      = CartesianFromSpherical()
Base.inv(::ISOSphericalFromCartesian)   = CartesianFromSpherical()
# TODO: How should we invert this?
Base.inv(::CartesianFromSpherical)      = SphericalFromCartesian()
Base.inv(::CylindricalFromCartesian)    = CartesianFromCylindrical()
Base.inv(::CartesianFromCylindrical)    = CylindricalFromCartesian()
Base.inv(::CylindricalFromSpherical)    = SphericalFromCylindrical()
# TODO: How should we invert this?
Base.inv(::SphericalFromCylindrical)    = CylindricalFromSpherical()
Base.inv(::ISOSphericalFromCylindrical) = CylindricalFromSpherical()

# Inverse composition
compose(::SphericalFromCartesian,      ::CartesianFromSpherical)      = IdentityTransformation()
compose(::ISOSphericalFromCartesian,   ::CartesianFromSpherical)      = IdentityTransformation()
compose(::CartesianFromSpherical,      ::SphericalFromCartesian)      = IdentityTransformation()
compose(::CartesianFromSpherical,      ::ISOSphericalFromCartesian)   = IdentityTransformation()
compose(::CylindricalFromCartesian,    ::CartesianFromCylindrical)    = IdentityTransformation()
compose(::CartesianFromCylindrical,    ::CylindricalFromCartesian)    = IdentityTransformation()
compose(::CylindricalFromSpherical,    ::SphericalFromCylindrical)    = IdentityTransformation()
compose(::CylindricalFromSpherical,    ::ISOSphericalFromCylindrical) = IdentityTransformation()
compose(::SphericalFromCylindrical,    ::CylindricalFromSpherical)    = IdentityTransformation()
compose(::ISOSphericalFromCylindrical, ::CylindricalFromSpherical)    = IdentityTransformation()

# Cyclic compositions
compose(::SphericalFromCartesian,      ::CartesianFromCylindrical)    = SphericalFromCylindrical()
compose(::ISOSphericalFromCartesian,   ::CartesianFromCylindrical)    = SphericalFromCylindrical()
compose(::CartesianFromSpherical,      ::SphericalFromCylindrical)    = CartesianFromCylindrical()
compose(::CartesianFromSpherical,      ::ISOSphericalFromCylindrical) = CartesianFromCylindrical()
compose(::CylindricalFromCartesian,    ::CartesianFromSpherical)      = CylindricalFromSpherical()
compose(::CartesianFromCylindrical,    ::CylindricalFromSpherical)    = CartesianFromSpherical()
compose(::CylindricalFromSpherical,    ::SphericalFromCartesian)      = CylindricalFromCartesian()
compose(::CylindricalFromSpherical,    ::ISOSphericalFromCartesian)   = CylindricalFromCartesian()
compose(::SphericalFromCylindrical,    ::CylindricalFromCartesian)    = SphericalFromCartesian()
compose(::ISOSphericalFromCylindrical, ::CylindricalFromCartesian)    = SphericalFromCartesian()

# For convenience
Base.convert(::Type{Spherical}, v::AbstractVector) = SphericalFromCartesian()(v)
Base.convert(::Type{ISOSpherical}, v::AbstractVector) = ISOSphericalFromCartesian()(v)
Base.convert(::Type{Cylindrical}, v::AbstractVector) = CylindricalFromCartesian()(v)

Base.convert(::Type{V}, s::Spherical) where {V <: AbstractVector} = convert(V, CartesianFromSpherical()(s))
Base.convert(::Type{V}, s::ISOSpherical) where {V <: AbstractVector} = convert(V, CartesianFromSpherical()(s))
Base.convert(::Type{V}, c::Cylindrical) where {V <: AbstractVector} = convert(V, CartesianFromCylindrical()(c))
Base.convert(::Type{V}, s::Spherical) where {V <: StaticVector} = convert(V, CartesianFromSpherical()(s))
Base.convert(::Type{V}, s::ISOSpherical) where {V <: StaticVector} = convert(V, CartesianFromSpherical()(s))
Base.convert(::Type{V}, c::Cylindrical) where {V <: StaticVector} = convert(V, CartesianFromCylindrical()(c))

Base.convert(::Type{Spherical}, c::Cylindrical) = SphericalFromCylindrical()(c)
Base.convert(::Type{ISOSpherical}, c::Cylindrical) = ISOSphericalFromCylindrical()(c)
Base.convert(::Type{Cylindrical}, s::Spherical) = CylindricalFromSpherical()(s)
Base.convert(::Type{Cylindrical}, s::ISOSpherical) = CylindricalFromSpherical()(s)
