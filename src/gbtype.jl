const valid_union = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64}
const valid_vec = [Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64]
const GxB_union = Union{ComplexF32, ComplexF64}
const GxB_vec = [ComplexF32, ComplexF64]

const nonboolean = Union{Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64}

struct GrB_Type{T} <: Abstract_GrB_Type
    p::libgb.GrB_Type
end

Base.unsafe_convert(::Type{libgb.GrB_Type}, s::Abstract_GrB_Type) = s.p

GrB_Type{T}(name::AbstractString) where {T<:valid_union} = GrB_Type{T}(load_global(name))
show(io::IO, ::GrB_Type{T}) where T = print("GrB_Type{" * string(T) * "}")

struct GrB_ALL_Type <: Abstract_GrB_Type
    p::Ptr{libgb.GrB_Index}
end
show(io::IO, ::GrB_ALL_Type) = print(io, "GrB_ALL")
Base.unsafe_convert(::Type{Ptr{libgb.GrB_Index}}, s::GrB_ALL_Type) = s.p

function load_globaltypes()
    global ptrtogbtype = Dict{Ptr, Abstract_GrB_Type}()

    global BOOL = GrB_Type{Bool}("GrB_BOOL")
    ptrtogbtype[BOOL.p] = BOOL
    global INT8 = GrB_Type{Int8}("GrB_INT8")
    ptrtogbtype[INT8.p] = INT8
    global UINT8 = GrB_Type{UInt8}("GrB_UINT8")
    ptrtogbtype[UINT8.p] = UINT8
    global INT16 = GrB_Type{Int16}("GrB_INT16")
    ptrtogbtype[INT16.p] = INT16
    global UINT16 = GrB_Type{UInt16}("GrB_UINT16")
    ptrtogbtype[UINT16.p] = UINT16
    global INT32 = GrB_Type{Int32}("GrB_INT32")
    ptrtogbtype[INT32.p] = INT32
    global UINT32 = GrB_Type{UInt32}("GrB_UINT32")
    ptrtogbtype[UINT32.p] = UINT32
    global INT64 = GrB_Type{Int64}("GrB_INT64")
    ptrtogbtype[INT64.p] = INT64
    global UINT64 = GrB_Type{UInt64}("GrB_UINT64")
    ptrtogbtype[UINT64.p] = UINT64
    global FP32 = GrB_Type{Float32}("GrB_FP32")
    ptrtogbtype[FP32.p] = FP32
    global FP64 = GrB_Type{Float64}("GrB_FP64")
    ptrtogbtype[FP64.p] = FP64
    global FC32 = GrB_Type{ComplexF32}("GxB_FC64")
    ptrtogbtype[FC32.p] = FC32
    global FC64 = GrB_Type{ComplexF32}("GxB_FC64")
    ptrtogbtype[FC64.p] = FC64
    global NULL = GrB_Type{Nothing}(C_NULL)
    ptrtogbtype[NULL.p] = NULL
    global ALL = GrB_ALL_Type(load_global("GrB_ALL", libgb.GrB_Index))
    ptrtogbtype[ALL.p] = ALL
end

juliatype(::GrB_Type{T}) where {T} = T

function optype(atype, btype)
    #If atype is signed, optype must be signed and at least big enough.
    if atype <: Integer || btype <: Integer
        if atype <: Signed || btype <: Signed
            return signed(promote_type(atype, btype))
        else
            return promote_type(atype, btype)
        end
    else
        return promote_type(atype, btype)
    end
end
