function suffix(T::DataType)
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

grb_ptr(x::Abstract_GrB_Struct) = x.p

function toGrB_Type(T::DataType)
    if T == Bool
        BOOL
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

function load_global(str)
    x =
    try
        dlsym(SSGraphBLAS_jll.libgraphblas_handle, str)
    catch e
        print("Symbol not available: " * str * "\n $e")
        return C_NULL
    end
    return unsafe_load(cglobal(x, Ptr{Cvoid}))
end


function splitconstant(str)
    return String.(split(str, "_"))
end

isGxB(name) = name[1:3] == "GxB"
