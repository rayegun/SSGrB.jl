function GBMatrix{T}(nrows, ncols) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_new(toGrB_Type(T), nrows, ncols))
end

GBMatrix{T}() where {T} = GBMatrix{T}(libgb.GxB_INDEX_MAX, libgb.GxB_INDEX_MAX)

Base.unsafe_convert(::Type{libgb.GrB_Matrix}, A::GBMatrix) = A.p

function Base.deepcopy(A::GBMatrix{T}) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_dup(A))
end

clear(A::GBMatrix) = libgb.GrB_Matrix_clear(A)

Base.size(A::GBMatrix) = (libgb.GrB_Matrix_nrows(A), libgb.GrB_Matrix_ncols(A))
function Base.size(A::GBMatrix, dim)
    if dim == 1
        return size(A)[1]
    elseif dim == 2
        return size(A)[2]
    end
end

nnz(A::GBMatrix) = libgb.GrB_Matrix_nvals(A)
Base.eltype(::Type{GBMatrix{T}}) where{T} = T

for T ∈ valid_vec
    if T ∈ GxB_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    func = Symbol(prefix, :_Matrix_build_, suffix(T))
    @eval begin
        function build(A::GBMatrix{$T}, I::Vector, J::Vector, X::Vector{$T};
                dup = BinaryOps.PLUS
            )
            nnz(A) == 0 || error("Cannot build matrix with existing elements")
            length(X) == length(I) == length(J) ||
                DimensionMismatch("I, J and X must have the same length")
            libgb.$func(
                A,
                Vector{libgb.GrB_Index}(I),
                Vector{libgb.GrB_Index}(J),
                X,
                length(X),
                dup[$T],
            )
        end
    end
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(A::GBMatrix{$T}, x::$T, i, j)
            return libgb.$func(A, x, libgb.GrB_Index(i), libgb.GrB_Index(j))
        end
    end
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(A::GBMatrix{$T}, i, j)
            return libgb.$func(A, libgb.GrB_Index(i), libgb.GrB_Index(j))
        end
    end
    func = Symbol(prefix, :_Vector_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(A::GBMatrix{$T})
            return libgb.$func(A)
        end
    end
end

function GBMatrix(
        I::Vector, J::Vector, X::Vector{T};
        dup = BinaryOps.PLUS, nrows = maximum(I), ncols = maximum(J)
    ) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, X, dup = dup)
    return A
end

function Base.deleteat!(A::GBMatrix, i, j)
    libgb.GrB_Matrix_removeElement(A, i, j)
    return A
end

function Base.resize!(A::GBMatrix, nrows_new, ncols_new)
    libgb.GrB_Matrix_resize(A, nrows_new, ncols_new)
    return A
end

#TODO: Matrix_concat, Matrix_split

function diagonal(v::GBVector, k = 0, desc = GrB_NULL)
    return libgb.GxB_Matrix_diag(v, k, desc)
end

function printtest(io::IO, M::GBMatrix)
    str = mktemp() do fname, f
        cf = Libc.FILE(f)
        libgb.GxB_Matrix_fprint(M, "Test", libgb.GxB_SHORT, cf)
        ccall(:fflush, Cint, (Ptr{Cvoid},), cf)
        seek(f, 0)
        read(f, String)
    end
    print(str)
end

function Base.show(io::IO, M::GBMatrix)
    printtest(io, M)
end
