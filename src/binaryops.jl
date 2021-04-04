
struct BinaryOpContainer{T} <: Abstract_GrB_Container
    typed::Dict{DataType,T}
    BinaryOpContainer{T}() where {T<: Abstract_GrB_BinaryOp} = new(Dict{DataType,T}())
end

function loadbinaryops()
    builtins = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GxB_ATAN2", "GxB_HYPOT", "GxB_FMOD", "GxB_REMAINDER", "GxB_LDEXP", "GxB_COPYSIGN", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE", "GxB_CMPLX", "GxB_FIRSTI", "GxB_FIRSTI1", "GxB_FIRSTJ", "GxB_FIRSTJ1", "GxB_SECONDI", "GxB_SECONDI1", "GxB_SECONDJ", "GxB_SECONDJ1"]

    booleans = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    integers = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    unsignedintegers = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GrB_BOR", "GrB_BAND", "GrB_BXOR", "GrB_BXNOR", "GxB_BGET", "GxB_BSET", "GxB_BCLR", "GxB_BSHIFT", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE"]
    floats = ["GrB_FIRST", "GrB_SECOND", "GxB_POW", "GrB_PLUS", "GrB_MINUS", "GrB_TIMES", "GrB_DIV", "GxB_RMINUS", "GxB_RDIV", "GxB_PAIR", "GxB_ANY", "GxB_ISEQ", "GxB_ISNE", "GxB_ISGT", "GxB_ISLT", "GxB_ISGE", "GxB_ISLE", "GrB_MIN", "GrB_MAX", "GxB_LOR", "GxB_LAND", "GxB_LXOR", "GxB_ATAN2", "GxB_HYPOT", "GxB_FMOD", "GxB_REMAINDER", "GxB_LDEXP", "GxB_COPYSIGN", "GrB_EQ", "GrB_NE", "GrB_GT", "GrB_LT", "GrB_GE", "GrB_LE", "GxB_CMPLX"]

    positionals = ["GxB_FIRSTI", "GxB_FIRSTI1", "GxB_FIRSTJ", "GxB_FIRSTJ1", "GxB_SECONDI", "GxB_SECONDI1", "GxB_SECONDJ", "GxB_SECONDJ1"]

    for name ∈ builtins
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        structquote = quote
            struct $opname{T} <: Abstract_GrB_BinaryOp
                p::Ptr{Cvoid}
                $opname{T}() where {T} = new(C_NULL)
                $opname{T}(p::Ptr{Cvoid}) where {T} = new(p)
            end
            const $exportedname = $BinaryOpContainer{$opname}()
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
