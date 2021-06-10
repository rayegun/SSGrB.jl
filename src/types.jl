module Types
    import ...SSGrB: Abstract_GrB_Struct, AbstractUnaryOp, AbstractMonoid, AbstractSelectOp,
    AbstractSemiring, AbstractBinaryOp, AbstractDescriptor
    using ..libgb
end

mutable struct GBScalar{T} <: Abstract_GrB_Struct
    p::libgb.GxB_Scalar
    function GBScalar{T}(p::libgb.GxB_Scalar) where {T}
        s = new(p)
        function f(scalar)
            libgb.GxB_Scalar_free(Ref(scalar.p))
        end
        return finalizer(f, s)
    end
end

mutable struct GBVector{T} <: AbstractSparseArray{T, UInt64, 1}
    p::libgb.GrB_Vector
    function GBVector{T}(p::libgb.GrB_Vector) where {T}
        v = new(p)
        function f(vector)
            libgb.GrB_Vector_free(Ref(vector.p))
        end
        return finalizer(f, v)
    end
end

mutable struct GBMatrix{T} <: AbstractSparseArray{T, UInt64, 2}
    p::libgb.GrB_Matrix
    function GBMatrix{T}(p::libgb.GrB_Matrix) where {T}
        A = new(p)
        function f(matrix)
            libgb.GrB_Matrix_free(Ref(matrix.p))
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

const MonoidSemiringOrBinary = Union{
    libgb.GrB_Monoid,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    AbstractSemiring,
    AbstractBinaryOp,
    AbstractMonoid
}
const GBMatOrTrans = Union{<:GBMatrix, Transpose{<:Any, <:GBMatrix}}
const GBVecMatOrTrans = Union{<:GBVector, GBMatOrTrans}

function getoperator(op, t)
    #Default Semiring should be LOR_LAND for boolean
    if op == Semirings.PLUS_TIMES_SEMIRING
        if t == Bool
            op = Semirings.LOR_LAND_SEMIRING
        end
    end
    #Default BinaryOp should be LAND or LOR for boolean
    if op == BinaryOps.TIMES
        if t == Bool
            op = BinaryOps.LAND
        end
    elseif op == BinaryOps.PLUS
        if t == Bool
            op = BinaryOps.LOR
        end
    end
    #Default monoid should be LAND/LOR
    if op == Monoids.TIMES_MONOID
        if t == Bool
            op = Monoids.LAND_MONOID
        end
    elseif op == Monoids.PLUS_MONOID
        if t == Bool
            op = Monoids.LOR_MONOID
        end
    end

    if op isa AbstractOp
        return op[t]
    elseif op isa OpUnion
        return op
    else
        error("Not a valid GrB op/semiring")
    end
end
