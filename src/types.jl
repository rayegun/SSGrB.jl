module Types
    import ...SSGrB: Abstract_GrB_Struct, Abstract_GrB_UnaryOp, Abstract_GrB_Monoid, Abstract_GrB_SelectOp,
    Abstract_GrB_Semiring, Abstract_GrB_BinaryOp, Abstract_GrB_Descriptor
    using ..libgb
end

mutable struct GBScalar{T} <: Abstract_GrB_Struct
    p::libgb.GxB_Scalar
    function GBScalar{T}(p::libgb.GxB_Scalar) where {T}
        s = new(p)
        function f(scalar)
            libgb.GxB_Scalar_free(Ref(scalar.p))
            scalar.p = C_NULL
        end
        return finalizer(f, s)
    end
end

mutable struct GBVector{T} <: Abstract_GrB_Struct
    p::libgb.GrB_Vector
    function GBVector{T}(p::libgb.GrB_Vector) where {T}
        v = new(p)
        function f(vector)
            libgb.GrB_Vector_free(Ref(vector.p))
            vector.p = C_NULL
        end
        return finalizer(f, v)
    end
end

mutable struct GBMatrix{T} <: Abstract_GrB_Struct
    p::libgb.GrB_Matrix
    function GBMatrix{T}(p::libgb.GrB_Matrix) where {T}
        A = new(p)
        function f(matrix)
            libgb.GrB_Matrix_free(Ref(matrix.p))
            matrix.p = C_NULL
        end
        return finalizer(f, A)
    end
end

const GBVecOrMat = Union{GBVector{T}, GBMatrix{T}} where T
const OpUnion = Union{
    libgb.GrB_Monoid,
    libgb.GrB_UnaryOp,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    libgb.GxB_SelectOp
}


function getsemiring(t, semiring = nothing)
    if semiring === nothing
        if t == Bool
            return Semirings.LOR_LAND_SEMIRING[t]
        else
            return Semirings.PLUS_TIMES_SEMIRING[t]
        end
    end
    return getoperator(semiring, t)
end
function getsemiring(A::GBVecOrMat, B::GBVecOrMat, semiring = nothing)
    t = optype(eltype(A), eltype(B))
    return getsemiring(t, semiring)
end

function getbinaryop(t, op = nothing)
    if op === nothing
        if t == Bool
            return BinaryOps.LAND[t]
        else
            return BinaryOps.TIMES[t]
        end
    end
    return getoperator(op, t)
end
function getbinaryop(A::GBVecOrMat, B::GBVecOrMat, op = nothing)
    t = optype(eltype(A), eltype(B))
    return getbinaryop(t, op)
end

function getmonoid(t, monoid = nothing)
    if monoid === nothing
        if t == Bool
            return Monoids.LAND_MONOID[t]
        else
            return Monoids.TIMES_MONOID[t]
        end
    end
    return getoperator(monoid, t)
end
function getmonoid(A::GBVecOrMat, B::GBVecOrMat, monoid = nothing)
    t = optype(eltype(A), eltype(B))
    return getmonoid(t, monoid)
end

function getoperator(op, t)
    if op isa Abstract_GrB_Op
        return op[t]
    elseif op isa OpUnion
        return op
    else
        error("Not a valid GrB op/semiring")
    end
end
