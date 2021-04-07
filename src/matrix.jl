mutable struct GrB_Matrix{T} <: Abstract_GrB_Struct
    p::Ptr{Cvoid}
end

GrB_Matrix{T}() where {T} = GrB_Matrix{T}(C_NULL)
