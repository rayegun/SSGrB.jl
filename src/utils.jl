function suffix(T)
    if T == Bool
        return "BOOL"
    elseif T == Int8
        return "INT8"
    elseif T == UInt8
        return "UINT8"
    elseif T == Int16
        return "INT16"
    elseif T == UInt16
        return "UINT16"
    elseif T == Int32
        return "INT32"
    elseif T == UInt32
        return "UINT32"
    elseif T == Int64
        return "INT64"
    elseif T == UInt64
        return "UINT64"
    elseif  T == Float32
        return "FP32"
    elseif T == Float64
        return "FP64"
    elseif T == ComplexF32
        return "FC32"
    elseif T == ComplexF64
        return "FC64"
    else
        error("Not a valid GrB data type")
    end
end

function towrappertype(T)
    if T == Bool
        return :Bool
    elseif T == Int8
        return :Int8
    elseif T == UInt8
        return :UInt8
    elseif T == Int16
        return :Int16
    elseif T == UInt16
        return :UInt16
    elseif T == Int32
        return :Int32
    elseif T == UInt32
        return :UInt32
    elseif T == Int64
        return :Int64
    elseif T == UInt64
        return :UInt64
    elseif  T == Float32
        return :Cfloat
    elseif T == Float64
        return :Cdouble
    elseif T == ComplexF32
        return :GxB_FC32_t
    elseif T == ComplexF64
        return :GxB_FC64_t
    else
        error("Not a valid GrB data type")
    end
end

grb_ptr(x::Abstract_GrB_Struct) = x.p

function toGrB_Type(T)
    if T == Bool
        return BOOL
    elseif T == Int8
        return INT8
    elseif T == UInt8
        return UINT8
    elseif T == Int16
        return INT16
    elseif T == UInt16
        return UINT16
    elseif T == Int32
        return INT32
    elseif T == UInt32
        return UINT32
    elseif T == Int64
        return INT64
    elseif T == UInt64
        return UINT64
    elseif  T == Float32
        return FP32
    elseif T == Float64
        return FP64
    elseif  T == ComplexF32
        return FC32
    elseif T == ComplexF64
        return FC64
    else
        error("Not a valid GrB data type")
    end
end

function load_global(str, type = Cvoid)
    x =
    try
        dlsym(SSGraphBLAS_jll.libgraphblas_handle, str)
    catch e
        print("Symbol not available: " * str * "\n $e")
        return C_NULL
    end
    return unsafe_load(cglobal(x, Ptr{type}))
end


function splitconstant(str)
    return String.(split(str, "_"))
end

isGxB(name) = name[1:3] == "GxB"

# This is a bad idea. If someone sees this remind me to remove it or document it.
function arrrrrgh()
    eval(:(Base.show(io::IO, a::Unsigned) = print(io, Int(a))))
end
