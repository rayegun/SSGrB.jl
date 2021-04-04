const valid_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64}

struct GrB_Type{T} <: Abstract_GrB_Type
    p::Ptr{Cvoid}
    
end
GrB_Type{T}(name::AbstractString) where {T<:valid_types} = GrB_Type{T}(load_global(name))
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

        global NULL = GrB_Type{Nothing}(C_NULL)

        global ALL = GrB_ALL_Type(load_global("GrB_ALL"))
end