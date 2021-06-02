baremodule BinaryOps
    using ..Types
end

BinaryUnion = Union{Abstract_GrB_BinaryOp, libgb.GrB_BinaryOp}

function binarynames(name)
    simple = splitconstant(name)[2]
    containername = Symbol(simple, "_BINARY_T")
    exportedname = Symbol(simple)
    return containername, exportedname
end
function createbinaryops()
    builtins = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GxB_ATAN2", "GxB_HYPOT", "GxB_FMOD", "GxB_REMAINDER", "GxB_LDEXP", "GxB_COPYSIGN", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE", "GxB_CMPLX", "GxB_FIRSTI", "GxB_FIRSTI1", "GxB_FIRSTJ", "GxB_FIRSTJ1", "GxB_SECONDI", "GxB_SECONDI1", "GxB_SECONDJ", "GxB_SECONDJ1"]
    for name ∈ builtins
        containername, exportedname = binarynames(name)
        structquote = quote
            struct $containername <: Abstract_GrB_BinaryOp
                pointers::Dict{DataType, Ptr{libgb.GrB_BinaryOp}}
                name::String
                $containername() = new(Dict{DataType, Ptr{libgb.GrB_BinaryOp}}(), $name)
            end
        end
        @eval(Types, $structquote)
        constquote = quote
            const $exportedname = Types.$containername()
            export $exportedname
        end
        @eval(BinaryOps,$constquote)
    end
end
function load(binary::Abstract_GrB_BinaryOp)
    booleans = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    integers = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    unsignedintegers = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    floats = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GxB_ATAN2", "GxB_HYPOT", "GxB_FMOD", "GxB_REMAINDER", "GxB_LDEXP", "GxB_COPYSIGN", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE", "GxB_CMPLX"]

    positionals = ["GxB_FIRSTI", "GxB_FIRSTI1", "GxB_FIRSTJ", "GxB_FIRSTJ1", "GxB_SECONDI", "GxB_SECONDI1", "GxB_SECONDJ", "GxB_SECONDJ1"]
    name = binary.name
    if name ∈ booleans
        binary.pointers[Bool] = load_global(name * "_BOOL")
    end

    if name ∈ integers
        binary.pointers[Int8] = load_global(name * "_INT8")
        binary.pointers[Int16] = load_global(name * "_INT16")
        binary.pointers[Int32] = load_global(name * "_INT32")
        binary.pointers[Int64] = load_global(name * "_INT64")
    end

    if name ∈ unsignedintegers
        binary.pointers[UInt8] = load_global(name * "_UINT8")
        binary.pointers[UInt16] = load_global(name * "_UINT16")
        binary.pointers[UInt32] = load_global(name * "_UINT32")
        binary.pointers[UInt64] = load_global(name * "_UINT64")
    end

    if name ∈ floats
        binary.pointers[Float32] = load_global(name * "_FP32")
        binary.pointers[Float64] = load_global(name * "_FP64")
    end
end

xtype(op::BinaryUnion) = ptrtogbtype[libgb.GxB_BinaryOp_xtype(op)]
ytype(op::BinaryUnion) = ptrtogbtype[libgb.GxB_BinaryOp_ytype(op)]
ztype(op::BinaryUnion) = ptrtogbtype[libgb.GxB_BinaryOp_ztype(op)]
