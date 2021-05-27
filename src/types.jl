const valid_union = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64}
const valid_vec = [Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64]
const GxB_union = Union{ComplexF32, ComplexF64}
const GxB_vec = [ComplexF32, ComplexF64]

struct GrB_Type{T} <: Abstract_GrB_Type
    p::libgb.GrB_Type
end

Base.unsafe_convert(::Type{libgb.GrB_Type}, s::Abstract_GrB_Type) = s.p

GrB_Type{T}(name::AbstractString) where {T<:valid_union} = GrB_Type{T}(load_global(name))
show(io::IO, ::GrB_Type{T}) where T = print("GrB_Type{" * string(T) * "}")

struct GrB_ALL_Type <: Abstract_GrB_Type
    p::Ptr{Cvoid}
end
show(io::IO, ::GrB_ALL_Type) = print("GrB_ALL")

function load_globaltypes()

        global BOOL = GrB_Type{Bool}("GrB_BOOL")
        global INT8 = GrB_Type{Int8}("GrB_INT8")
        global UINT8 = GrB_Type{UInt8}("GrB_UINT8")
        global INT16 = GrB_Type{Int16}("GrB_INT16")
        global UINT16 = GrB_Type{UInt16}("GrB_UINT16")
        global INT32 = GrB_Type{Int32}("GrB_INT32")
        global UINT32 = GrB_Type{UInt32}("GrB_UINT32")
        global INT64 = GrB_Type{Int64}("GrB_INT64")
        global UINT64 = GrB_Type{UInt64}("GrB_UINT64")
        global FP32 = GrB_Type{Float32}("GrB_FP32")
        global FP64 = GrB_Type{Float64}("GrB_FP64")
        global FC32 = GrB_Type{ComplexF32}("GxB_FC64")
        global FC64 = GrB_Type{ComplexF32}("GxB_FC64")

        global NULL = GrB_Type{Nothing}(C_NULL)

        global ALL = GrB_ALL_Type(load_global("GrB_ALL"))
end
