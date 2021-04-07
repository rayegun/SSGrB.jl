mutable struct GrB_Scalar{T} <: Abstract_GrB_Struct
    p::Ptr{Cvoid}
end

GrB_Scalar{T}() where {T} = GrB_Scalar{T}(C_NULL)

function GxB_Scalar_new(S::GrB_Scalar{T})
    S_ptr pointer_from_objref(S)