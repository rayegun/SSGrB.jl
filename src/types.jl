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
