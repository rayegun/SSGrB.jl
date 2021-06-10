mutable struct SelectOp <: AbstractSelectOp
    p::libgb.GxB_SelectOp
    function SelectOp(p::libgb.GxB_SelectOp)
        d = new(p)
        function f(selectop)
            libgb.GxB_SelectOp_free(Ref(selectop.p))
        end
        return finalizer(f, d)
    end
end

const SelectUnion = Union{AbstractSelectOp, libgb.GxB_SelectOp}

function SelectOp()
    return SelectOp(libgb.GxB_SelectOp_new())
end

Base.unsafe_convert(::Type{libgb.GxB_SelectOp}, selectop::SelectOp) = selectop.p

baremodule SelectOps
import ..SSGrB: load_global, SelectOp
import ..Types
import ..libgb: GB_SelectOp_opaque
end

function loadselectops()
    builtins = ["GxB_TRIL",
    "GxB_TRIU",
    "GxB_DIAG",
    "GxB_OFFDIAG",
    "GxB_NONZERO",
    "GxB_EQ_ZERO",
    "GxB_GT_ZERO",
    "GxB_GE_ZERO",
    "GxB_LT_ZERO",
    "GxB_LE_ZERO",
    "GxB_NE_THUNK",
    "GxB_EQ_THUNK",
    "GxB_GT_THUNK",
    "GxB_GE_THUNK",
    "GxB_LT_THUNK",
    "GxB_LE_THUNK"]
    for name ∈ builtins
        simple = Symbol(string(name[5:end]))
        constquote = quote
            const $simple = SelectOp(load_global($name, GB_SelectOp_opaque))
        end
        @eval(SelectOps, $constquote)
    end
end
isloaded(d::AbstractSelectOp) = d.p !== C_NULL
function Base.getindex(o::AbstractSelectOp)
    o.p
end
function validtypes(::AbstractSelectOp)
    return nothing
end

function printtest(io::IO, M::SelectOp)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        libgb.GxB_SelectOp_fprint(M, "", libgb.GxB_SHORT, cf)
        flush(f)
        seekstart(f)
        x = read(f, String)
        close(cf)
        x
    end
    print(io, str)
end

function Base.show(io::IO, d::SelectOp)
    printtest(io, d)
end
