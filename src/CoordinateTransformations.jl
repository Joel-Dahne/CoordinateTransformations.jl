VERSION < v"0.7.0-beta2.199" && __precompile__()

module CoordinateTransformations

using StaticArrays
using Compat.LinearAlgebra
using Compat

using Rotations
export RotMatrix, Quat, SpQuat, AngleAxis, RodriguesVec,
       RotX, RotY, RotZ,
       RotXY, RotYX, RotZX, RotXZ, RotYZ, RotZY,
       RotXYX, RotYXY, RotZXZ, RotXZX, RotYZY, RotZYZ,
       RotXYZ, RotYXZ, RotZXY, RotXZY, RotYZX, RotZYX

# Core methods
export compose, ∘, transform_deriv, transform_deriv_params, recenter
export Transformation, IdentityTransformation

# 2D coordinate systems and their transformations
export Polar
export PolarFromCartesian, CartesianFromPolar

# 3D coordinate systems and their transformations
export Spherical, ISOSpherical, Cylindrical
export SphericalFromCartesian, CartesianFromSpherical,
       ISOSphericalFromCartesian,
       CylindricalFromCartesian, CartesianFromCylindrical,
       CylindricalFromSpherical, SphericalFromCylindrical,
       ISOSphericalFromCylindrical

# Common transformations
export AbstractAffineMap
export AffineMap, LinearMap, Translation
export PerspectiveMap, cameramap

include("core.jl")
include("coordinatesystems.jl")
include("affine.jl")
include("perspective.jl")

# Deprecations
export transform
Base.@deprecate_binding AbstractTransformation Transformation
Base.@deprecate transform(transformation::Transformation, x) transformation(x)

end # module
