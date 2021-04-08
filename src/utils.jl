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
    end
    return "FP64"
end

grb_ptr(x::Abstract_GrB_Struct) = x.p

function ptr_to_GrB_Type(T::DataType)
    if T == Bool
        return grb_ptr(BOOL)
    elseif T == Int8
        return grb_ptr(INT8)
    elseif T == UInt8
        return grb_ptr(UINT8)
    elseif T == Int16
        return grb_ptr(INT16)
    elseif T == UInt16
        return grb_ptr(UINT16)
    elseif T == Int32
        return grb_ptr(INT32)
    elseif T == UInt32
        return grb_ptr(UINT32)
    elseif T == Int64
        return grb_ptr(INT64)
    elseif T == UInt64
        return grb_ptr(UINT64)
    elseif  T == Float32
        return grb_ptr(FP32)
    end
    return grb_ptr(FP64)
end

function load_global(str)
    x =
    try
        dlsym(graphblas_lib, str)
    catch
        print("Symbol not available: " * str * "\n")
        return C_NULL
    end
    return unsafe_load(cglobal(x, Ptr{Cvoid}))
end


function splitconstant(str)
    return String.(split(str, "_"))
end

isGxB(name) = name[1:3] == "GxB"

