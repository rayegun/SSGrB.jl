
struct UnaryOpContainer{T} <: Abstract_GrB_Container
    typed::Dict{DataType,T}
    UnaryOpContainer{T}() where {T<: Abstract_GrB_UnaryOp} = new(Dict{DataType,T}())
end

function loadunaryops()
    builtins = ["GrB_IDENTITY", "GrB_AINV", "GxB_LNOT", "GrB_MINV", "GxB_ONE", "GrB_ABS", "GrB_BNOT", "GxB_SQRT", "GxB_LOG", "GxB_EXP", "GxB_LOG2", "GxB_SIN", "GxB_COS", "GxB_TAN", "GxB_ACOS", "GxB_ASIN", "GxB_ATAN", "GxB_SINH", "GxB_COSH", "GxB_TANH", "GxB_ASINH", "GxB_ACOSH", "GxB_ATANH", "GxB_SIGNUM", "GxB_CEIL", "GxB_FLOOR", "GxB_ROUND", "GxB_TRUNC", "GxB_EXP2", "GxB_EXPM1", "GxB_LOG10", "GxB_LOG1P", "GxB_LGAMMA", "GxB_TGAMMA", "GxB_ERF", "GxB_ERFC", "GxB_FREXPE", "GxB_FREXPX", "GxB_CONJ", "GxB_CREAL", "GxB_CIMAG", "GxB_CARG", "GxB_ISINF", "GxB_ISNAN", "GxB_ISFINITE","GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]

    booleans = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS"]
    integers = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GrB_BNOT"]
    unsignedintegers = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GrB_BNOT"]
    floats = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS", "GxB_SQRT", "GxB_LOG", "GxB_EXP", "GxB_LOG2", "GxB_SIN", "GxB_COS", "GxB_TAN", "GxB_ACOS", "GxB_ASIN", "GxB_ATAN", "GxB_SINH", "GxB_COSH", "GxB_TANH", "GxB_ASINH", "GxB_ACOSH", "GxB_ATANH", "GxB_SIGNUM", "GxB_CEIL", "GxB_FLOOR", "GxB_ROUND", "GxB_TRUNC", "GxB_EXP2", "GxB_EXPM1", "GxB_LOG10", "GxB_LOG1P", "GxB_LGAMMA", "GxB_TGAMMA", "GxB_ERF", "GxB_ERFC", "GxB_FREXPE", "GxB_FREXPX", "GxB_ISINF", "GxB_ISNAN", "GxB_ISFINITE"]
    positionals = [ "GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]

    for name ∈ builtins
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        structquote = quote
            struct $opname{T} <: Abstract_GrB_UnaryOp
                p::Ptr{Cvoid}
                $opname{T}() where {T} = new(C_NULL)
                $opname{T}(p::Ptr{Cvoid}) where {T} = new(p)
            end
            const $exportedname = $UnaryOpContainer{$opname}()
            export $exportedname
        end
        @eval($structquote)
    end
    for name ∈ booleans
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        constname = name * "_BOOL"
        boolquote = quote
            $exportedname.typed[Bool] = $opname{Bool}(load_global($constname))
        end
        @eval($boolquote)
    end

    for name ∈ integers
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        integerquote = quote 
            $exportedname.typed[Int8] = $opname{Int8}(load_global($(name * "_INT8")))
            $exportedname.typed[Int16] = $opname{Int16}(load_global($(name * "_INT16")))
            $exportedname.typed[Int32] = $opname{Int32}(load_global($(name * "_INT32")))
            $exportedname.typed[Int64] = $opname{Int64}(load_global($(name * "_INT64")))
        end
        @eval($integerquote)
    end

    for name ∈ unsignedintegers
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        unsignedintegerquote = quote 
            $exportedname.typed[UInt8] = $opname{UInt8}(load_global($(name * "_UINT8")))
            $exportedname.typed[UInt16] = $opname{UInt16}(load_global($(name * "_UINT16")))
            $exportedname.typed[UInt32] = $opname{UInt32}(load_global($(name * "_UINT32")))
            $exportedname.typed[UInt64] = $opname{UInt64}(load_global($(name * "_UINT64")))
        end
        @eval($unsignedintegerquote)
    end

    for name ∈ floats
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        floatquote = quote 
            $exportedname.typed[Float32] = $opname{Float32}(load_global($(name * "_FP32")))
            $exportedname.typed[Float64] = $opname{Float64}(load_global($(name * "_FP64")))
        end
        @eval($floatquote)
    end
end
