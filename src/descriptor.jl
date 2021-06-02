baremodule Descriptors
    import ..SSGrB: load_global
    import ..Types
end

mutable struct GBDescriptor <: Abstract_GrB_Struct
    p::libgb.GrB_Descriptor
    function GBDescriptor(p::libgb.GrB_Descriptor)
        d = new(p)
        function f(descriptor)
            libgb.GrB_Descriptor_free(Ref(descriptor.p))
            vector.p = C_NULL
        end
        return finalizer(f, d)
    end
end

function loaddescriptors()
    builtins = ["GrB_DESC_T1",
    "GrB_DESC_T0",
    "GrB_DESC_T0T1",
    "GrB_DESC_C",
    "GrB_DESC_CT1",
    "GrB_DESC_CT0",
    "GrB_DESC_CT0T1",
    "GrB_DESC_S",
    "GrB_DESC_ST1",
    "GrB_DESC_ST0",
    "GrB_DESC_ST0T1",
    "GrB_DESC_SC",
    "GrB_DESC_SCT1",
    "GrB_DESC_SCT0",
    "GrB_DESC_SCT0T1",
    "GrB_DESC_R",
    "GrB_DESC_RT1",
    "GrB_DESC_RT0",
    "GrB_DESC_RT0T1",
    "GrB_DESC_RC",
    "GrB_DESC_RCT1",
    "GrB_DESC_RCT0",
    "GrB_DESC_RCT0T1",
    "GrB_DESC_RS",
    "GrB_DESC_RST1",
    "GrB_DESC_RST0",
    "GrB_DESC_RST0T1",
    "GrB_DESC_RSC",
    "GrB_DESC_RSCT1",
    "GrB_DESC_RSCT0",
    "GrB_DESC_RSCT0T1"]
    for name ∈ builtins
        simple = string(name[5:end])
        opname = Symbol(simple, "_T")
        exportedname = Symbol(simple)
        structquote = quote
            struct $opname <: Abstract_GrB_Descriptor
                p::Ptr{Cvoid}
                $opname() = new(C_NULL)
                $opname(p::Ptr{Cvoid}) = new(p)
            end
        end
        @eval(Types, $structquote)
        constquote = quote
            const $exportedname = Types.$opname(load_global($name))
        end
        @eval(Descriptors, $constquote)
    end
end
isloaded(d::Abstract_GrB_Descriptor) = d.p !== C_NULL
