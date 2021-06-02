GBVector{T}(n) where {T} = GBVector{T}(libgb.GrB_Vector_new(toGrB_Type(T),n))

GBVector{T}() where {T} = GBVector{T}(libgb.GxB_INDEX_MAX)

Base.unsafe_convert(::Type{libgb.GrB_Vector}, v::GBVector) = v.p

Base.copy(v::GBVector{T}) where {T} = GBVector{T}(v.p)

function Base.deepcopy(v::GBVector{T}) where {T}
    return GBVector{T}(libgb.GrB_Vector_dup(v))
end

clear(v::GBVector) = libgb.GrB_Vector_clear(v)

Base.size(v::GBVector) = libgb.GrB_Vector_size(v)

nnz(v::GBVector) = libgb.GrB_Vector_nvals(v)
Base.eltype(::Type{GBVector{T}}) where{T} = T

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
            libgb.$func(v, Vector{libgb.GrB_Index}(I), X, length(X), dup[$T])
        end
    end
    func = Symbol(prefix, :_Vector_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(v::GBVector{$T}, x::$T, i)
            return libgb.$func(v, x, libgb.GrB_Index(i))
        end
    end
    func = Symbol(prefix, :_Vector_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i)
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

function GBVector(I::Vector, X::Vector{T}; dup = BinaryOps.PLUS) where {T}
    x = GBVector{T}(maximum(I))
    build(x, I, X, dup = dup)
    return x
end

function GBVector(X::Vector)
    return GBVector([1:length(X)...], X)
end

function Base.deleteat!(v::GBVector, i)
    libgb.GrB_Vector_removeElement(v, libgb.GrB_Index(i))
    return v
end

function Base.resize!(v::GBVector, nrows_new)
    libgb.GrB_Vector_resize(v, nrows_new)
    return v
end

function diagonal(A::GBMatrix, k = 0, desc = GrB_NULL)
    return libgb.GxB_Vector_diag(v, k, desc)
end

function printtest(io::IO, M::GBVector)
    str = mktemp() do fname, f
        cf = Libc.FILE(f)
        libgb.GxB_Vector_fprint(M, "Test", libgb.GxB_SHORT, cf)
        ccall(:fflush, Cint, (Ptr{Cvoid},), cf)
        seek(f, 0)
        read(f, String)
    end
    print(str)
end

function Base.show(io::IO, M::GBVector)
    printtest(io, M)
end
