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

GBVector{T}(n) where {T} = GBVector{T}(libgb.GrB_Vector_new(toGrB_Type(T),n))

Base.unsafe_convert(::Type{libgb.GrB_Vector}, v::GBVector) = v.p

Base.copy(v::GBVector{T}) where {T} = GBVector{T}(v.p)

function Base.deepcopy(v::GBVector{T}) where {T}
    return GBVector{T}(libgb.GrB_Vector_dup(v))
end

#dup(v::GBVector) = Base.deepcopy(v)

clear(v::GBVector) = libgb.GrB_Vector_clear(v)

Base.size(v::GBVector) = libgb.GrB_Vector_size(v)

#nval(v::GBVector) = libgb.GrB_Vector_nvals(v)
nnz(v::GBVector) = libgb.GrB_Vector_nvals(v)
Base.eltype(::Type{GBVector{T}}) where{T} = T

#type(v::GBVector{T}) = eltype(v)


for T ∈ valid_vec
    if T ∈ GxB_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    func = Symbol(prefix, :_Vector_build_, suffix(T))
    @eval begin
        function build(v::GBVector{$T}, I::Vector, X::Vector{$T}; dup = BinaryOps.PLUS)
            nnz(v) == 0 || error("Cannot build vector with existing elements")
            length(X) == length(I) || DimensionMismatch("I and X must have the same length")
            I .-= 1
            libgb.$func(v, Vector{libgb.GrB_Index}(I), X, length(X), dup[$T])
        end
    end
    func = Symbol(prefix, :_Vector_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(v::GBVector{$T}, x::$T, i)
            i -= 1
            return libgb.$func(v, x, libgb.GrB_Index(i))
        end
    end
    func = Symbol(prefix, :_Vector_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i)
            i -= 1
            return libgb.$func(v, libgb.GrB_Index(i))
        end
    end
    func = Symbol(prefix, :_Vector_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(v::GBVector{$T})
            return libgb.$func(v)
        end
    end
end

function GBVector(I, X::Vector{T}; dup = BinaryOps.PLUS) where {T <: valid_union}
    x = GBVector{T}(maximum(I))
    build(x, I, X, dup = dup)
    return x
end

function GBVector(X::Vector)
    return GBVector([1:length(X)...], X)
end

function Base.deleteat!(v::GBVector, i)
    i -= 1
    libgb.GrB_Vector_removeElement(v, libgb.GrB_Index(i))
end
