baremodule UnaryOps
    using ..Types
end

UnaryUnion = Union{AbstractUnaryOp, libgb.GrB_UnaryOp}

function unarynames(name)
    simple = splitconstant(name)[2]
    containername = Symbol(simple, "_UNARY_T")
    exportedname = Symbol(simple)
    return containername, exportedname
end

function createunaryops()
    builtins = ["GrB_IDENTITY", "GrB_AINV", "GxB_LNOT", "GrB_MINV", "GxB_ONE", "GrB_ABS", "GrB_BNOT", "GxB_SQRT", "GxB_LOG", "GxB_EXP", "GxB_LOG2", "GxB_SIN", "GxB_COS", "GxB_TAN", "GxB_ACOS", "GxB_ASIN", "GxB_ATAN", "GxB_SINH", "GxB_COSH", "GxB_TANH", "GxB_ASINH", "GxB_ACOSH", "GxB_ATANH", "GxB_SIGNUM", "GxB_CEIL", "GxB_FLOOR", "GxB_ROUND", "GxB_TRUNC", "GxB_EXP2", "GxB_EXPM1", "GxB_LOG10", "GxB_LOG1P", "GxB_LGAMMA", "GxB_TGAMMA", "GxB_ERF", "GxB_ERFC", "GxB_FREXPE", "GxB_FREXPX", "GxB_CONJ", "GxB_CREAL", "GxB_CIMAG", "GxB_CARG", "GxB_ISINF", "GxB_ISNAN", "GxB_ISFINITE","GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]
    for name ∈ builtins
        containername, exportedname = unarynames(name)
        structquote = quote
            struct $containername <: AbstractUnaryOp
                pointers::Dict{DataType, libgb.GrB_UnaryOp}
                name::String
                $containername() = new(Dict{DataType, libgb.GrB_UnaryOp}(), $name)
            end
        end
        @eval(Types, $structquote)
        constquote = quote
            const $exportedname = Types.$containername()
            export $exportedname
        end
        @eval(UnaryOps, $constquote)
    end
end

function load(unaryop::AbstractUnaryOp)
    booleans = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS"]
    integers = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GrB_BNOT"]
    unsignedintegers = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GrB_BNOT"]
    floats = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GxB_SQRT", "GxB_LOG", "GxB_EXP", "GxB_LOG2", "GxB_SIN", "GxB_COS", "GxB_TAN", "GxB_ACOS", "GxB_ASIN", "GxB_ATAN", "GxB_SINH", "GxB_COSH", "GxB_TANH", "GxB_ASINH", "GxB_ACOSH", "GxB_ATANH", "GxB_SIGNUM", "GxB_CEIL", "GxB_FLOOR", "GxB_ROUND", "GxB_TRUNC", "GxB_EXP2", "GxB_EXPM1", "GxB_LOG10", "GxB_LOG1P", "GxB_LGAMMA", "GxB_TGAMMA", "GxB_ERF", "GxB_ERFC", "GxB_FREXPE", "GxB_FREXPX", "GxB_ISINF", "GxB_ISNAN", "GxB_ISFINITE"]
    positionals = ["GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]
    name = unaryop.name
    if name ∈ booleans
        constname = name * "_BOOL"
        unaryop.pointers[Bool] = load_global(constname)
    end

    if name ∈ integers
        unaryop.pointers[Int8] = load_global(name * "_INT8")
        unaryop.pointers[Int16] = load_global(name * "_INT16")
        unaryop.pointers[Int32] = load_global(name * "_INT32")
        unaryop.pointers[Int64] = load_global(name * "_INT64")
    end

    if name ∈ unsignedintegers
        unaryop.pointers[UInt8] = load_global(name * "_UINT8")
        unaryop.pointers[UInt16] = load_global(name * "_UINT16")
        unaryop.pointers[UInt32] = load_global(name * "_UINT32")
        unaryop.pointers[UInt64] = load_global(name * "_UINT64")
    end

    if name ∈ floats
        unaryop.pointers[Float32] = load_global(name * "_FP32")
        unaryop.pointers[Float64] = load_global(name * "_FP64")
    end
end

ztype(op::UnaryUnion) = ptrtogbtype(libgb.GxB_UnaryOp_ztype(op))
xtype(op::UnaryUnion) = ptrtogbtype(libgb.GxB_UnaryOp_xtype(op))
