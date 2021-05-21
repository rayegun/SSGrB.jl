baremodule SelectOps
    import ..SSGrB: load_global
    import ..Containers
end

function loadselectops()
    builtins = ["GxB_TRIL", "GxB_TRIU", "GxB_DIAG", "GxB_OFFDIAG", "GxB_NONZERO", "GxB_EQ_ZERO", "GxB_GT_ZERO", "GxB_GE_ZERO", "GxB_LT_ZERO", "GxB_LE_ZERO", "GxB_NE_THUNK", "GxB_EQ_THUNK", "GxB_GT_THUNK", "GxB_GE_THUNK", "GxB_LT_THUNK", "GxB_LE_THUNK"]

    for name ∈ builtins
        simple = string(name[5:end])
        opname = Symbol("_" * simple)
        exportedname = Symbol(simple)
        structquote = quote
            struct $opname <: Abstract_GrB_SelectOp
                p::Ptr{Cvoid}
                $opname() = new(C_NULL)
                $opname(p::Ptr{Cvoid}) = new(p)
            end
        end
        @eval(Containers, $structquote)
        constquote = quote
            const $exportedname = Containers.$opname(load_global($name))
        end
        @eval(SelectOps, $constquote)
    end
end
isloaded(o::Abstract_GrB_SelectOp) = o.p !== C_NULL
function Base.getindex(o::Abstract_GrB_SelectOp, t)
    m.p
end
function validtypes(o::Abstract_GrB_SelectOp)
    return nothing
end
