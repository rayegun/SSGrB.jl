
struct MonoidContainer{T} <: Abstract_GrB_Container
    typed::Dict{DataType,T}
    MonoidContainer{T}() where {T<: Abstract_GrB_Monoid} = new(Dict{DataType,T}())
end

function loadmonoids()
    builtins = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY", "GrB_LOR", "GrB_LAND", "GrB_LXOR", "GrB_LXNOR", "GxB_EQ", "GxB_BOR", "GxB_BAND", "GxB_BXOR", "GxB_BXNOR"]
    booleans = ["GxB_ANY", "GrB_LOR", "GrB_LAND", "GrB_LXOR", "GrB_LXNOR", "GxB_EQ"]
    integers = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY"]
    unsignedintegers = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY", "GxB_BOR", "GxB_BAND", "GxB_BXOR", "GxB_BXNOR"]
    floats = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY"]

    for name ∈ builtins
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple * "_MONOID")
        exportedname = Symbol(simple * "_MONOID")
        structquote = quote
            struct $opname{T} <: Abstract_GrB_Monoid
                p::Ptr{Cvoid}
                $opname{T}() where {T} = new(C_NULL)
                $opname{T}(p::Ptr{Cvoid}) where {T} = new(p)
            end
            const $exportedname = $MonoidContainer{$opname}()
            export $exportedname
        end
        @eval($structquote)
    end
    for name ∈ booleans
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple * "_MONOID")
        exportedname = Symbol(simple * "_MONOID")
        constname = name * ((isGxB(name) ? "_BOOL_MONOID" : "_MONOID_BOOL"))
        boolquote = quote
            $exportedname.typed[Bool] = $opname{Bool}(load_global($constname))
        end
        @eval($boolquote)
    end

    for name ∈ integers
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple * "_MONOID")
        exportedname = Symbol(simple * "_MONOID")
        integerquote = quote 
            $exportedname.typed[Int8] = $opname{Int8}(load_global($(name * (isGxB(name) ? "_INT8_MONOID" : "_MONOID_INT8"))))
            $exportedname.typed[Int16] = $opname{Int16}(load_global($(name * (isGxB(name) ? "_INT16_MONOID" : "_MONOID_INT16"))))
            $exportedname.typed[Int32] = $opname{Int32}(load_global($(name * (isGxB(name) ? "_INT32_MONOID" : "_MONOID_INT32"))))
            $exportedname.typed[Int64] = $opname{Int64}(load_global($(name * (isGxB(name) ? "_INT64_MONOID" : "_MONOID_INT64"))))
        end
        @eval($integerquote)
    end

    for name ∈ unsignedintegers
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple * "_MONOID")
        exportedname = Symbol(simple * "_MONOID")
        unsignedintegerquote = quote 
            $exportedname.typed[UInt8] = $opname{UInt8}(load_global($(name * (isGxB(name) ? "_UINT8_MONOID" : "_MONOID_UINT8"))))
            $exportedname.typed[UInt16] = $opname{UInt16}(load_global($(name * (isGxB(name) ? "_UINT16_MONOID" : "_MONOID_UINT16"))))
            $exportedname.typed[UInt32] = $opname{UInt32}(load_global($(name * (isGxB(name) ? "_UINT32_MONOID" : "_MONOID_UINT32"))))
            $exportedname.typed[UInt64] = $opname{UInt64}(load_global($(name * (isGxB(name) ? "_UINT64_MONOID" : "_MONOID_UINT64"))))
        end
        @eval($unsignedintegerquote)
    end

    for name ∈ floats
        simple = splitconstant(name)[2]
        opname = Symbol("_" * simple * "_MONOID")
        exportedname = Symbol(simple * "_MONOID")
        floatquote = quote 
            $exportedname.typed[Float32] = $opname{Float32}(load_global($(name * (isGxB(name) ? "_FP32_MONOID" : "_MONOID_FP32"))))
            $exportedname.typed[Float64] = $opname{Float64}(load_global($(name * (isGxB(name) ? "_FP64_MONOID" : "_MONOID_FP64"))))
        end
        @eval($floatquote)
    end
end
