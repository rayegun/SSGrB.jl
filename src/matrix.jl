function GBMatrix{T}(nrows, ncols) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_new(toGrB_Type(T), nrows, ncols))
end

GBMatrix{T}() where {T} = GBMatrix{T}(libgb.GxB_INDEX_MAX, libgb.GxB_INDEX_MAX)

Base.unsafe_convert(::Type{libgb.GrB_Matrix}, A::GBMatrix) = A.p

function Base.copy(A::GBMatrix{T}) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_dup(A))
end

clear!(A::GBMatrix) = libgb.GrB_Matrix_clear(A)

function Base.size(A::GBMatrix, dim = nothing)
    if dim === nothing
        return (Int64(libgb.GrB_Matrix_nrows(A)), Int64(libgb.GrB_Matrix_ncols(A)))
    elseif dim == 1
        return Int64(libgb.GrB_Matrix_nrows(A))
    elseif dim == 2
        return Int64(libgb.GrB_Matrix_ncols(A))
    else
        return 1
    end
end

nnz(A::GBMatrix) = libgb.GrB_Matrix_nvals(A)
Base.eltype(::Type{GBMatrix{T}}) where{T} = T

Base.similar(A::GBMatrix) = GBMatrix{eltype(A)}(size(A)...)
Base.similar(::GBMatrix{T}, dims...) where {T} = GBMatrix{T}(dims...)

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
        function Base.getindex(A::GBMatrix{$T}, i::Integer, j::Integer)
            return libgb.$func(A, libgb.GrB_Index(i), libgb.GrB_Index(j))
        end
    end
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(A::GBMatrix{$T})
            return libgb.$func(A)
        end
    end
end
function wlength(A, I, J)
    if I == ALL
        Ilen = size(A, 1)
    else
        Ilen = length(I)
    end
    if J == ALL
        Jlen = size(A, 2)
    else
        Jlen = length(J)
    end
    return Ilen, Jlen
end
@kwargs function extract!(C::GBMatrix, A::GBMatrix, I, J)
    I, ni = idx(I)
    J, nj = idx(J)
    libgb.GrB_Matrix_extract(C, mask, accum, A, I, ni, J, nj, desc)
    return C
end

@kwargs function extract(A, I, J)
    Ilen, Jlen = wlength(A, I, J)
    C = similar(A, Ilen, Jlen)
    return extract!(C, A, I, J; mask, accum, desc)
end

@kwargs Base.getindex(A::GBMatrix, ::Colon, j) = extract(A, ALL, j; mask, accum, desc)
@kwargs Base.getindex(A::GBMatrix, i, ::Colon) = extract(A, i, ALL; mask, accum, desc)
@kwargs Base.getindex(A::GBMatrix, ::Colon, ::Colon) = extract(A, ALL, ALL; mask, accum, desc)

@kwargs function Base.getindex(
    A,
    i::Union{Vector, UnitRange, StepRange},
    j::Union{Vector, UnitRange, StepRange}
)
    return extract(A, i, j; mask, accum, desc)
end

@kwargs function subassign!(C::GBMatrix, A, I, J)
    I, ni = idx(I)
    J, nj = idx(J)
    A isa Vector && (A = GBVector(A))
    if A isa GBVector
        if !(I isa Vector) && (J isa Vector)
            libgb.GxB_Row_subassign(C, mask, accum, A, I, J, nj, desc)
        elseif !(J isa Vector) && (I isa Vector)
            libgb.GxB_Col_subassign(C, mask, accum, A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GxB_Matrix_subassign(C, mask, accum, A, I, ni, J, nj, desc)
    else
        libgb.scalarmatsubassign[eltype(A)](C, mask, accum, A, I, ni, J, nj, desc)
    end
end



@kwargs function assign!(C::GBMatrix, A, I, J)
    I, ni = idx(I)
    J, nj = idx(J)
    A isa Vector && (A = GBVector(A))
    if A isa GBVector
        if !(I isa Vector) && (J isa Vector)
            libgb.GrB_Row_assign(C, mask, accum, A, I, J, nj, desc)
        elseif !(J isa Vector) && (I isa Vector)
            libgb.GrB_Col_assign(C, mask, accum, A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GrB_Matrix_assign(C, mask, accum, A, I, ni, J, nj, desc)
    else
        libgb.scalarmatassign[eltype(A)](C, mask, accum, A, I, ni, J, nj, desc)
    end
end

#setindex! uses subassign rather than assign. This behavior may change in the future.
@kwargs function Base.setindex!(C::GBMatrix, A, ::Colon, J)
    subassign!(C, A, ALL, J; mask, accum, desc)
end
@kwargs function Base.setindex!(C::GBMatrix, A, I, ::Colon)
    subassign!(C, A, I, ALL; mask, accum, desc)
end
@kwargs function Base.setindex!(C::GBMatrix, A, ::Colon, ::Colon)
    subassign!(C, A, ALL, ALL; mask, accum, desc)
end

@kwargs function Base.setindex!(
    C::GBMatrix,
    A,
    I::Union{Vector, UnitRange, StepRange},
    J::Union{Vector, UnitRange, StepRange}
)
    subassign!(C, A, I, J; mask, accum, desc)
end

function GBMatrix(
    I::Vector, J::Vector, X::Vector{T};
    dup = BinaryOps.PLUS, nrows = maximum(I), ncols = maximum(J)
) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, X, dup = dup)
    return A
end

#TEMPORARY: NEEDS IMPORT/EXPORT
function GBMatrix(A::SparseMatrixCSC)
    i, j, k = findnz(A)
    return GBMatrix(i, j, k)
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
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        libgb.GxB_Matrix_fprint(M, "Test", libgb.GxB_SHORT, cf)
        ccall(:fflush, Cint, (Ptr{Cvoid},), cf)
        seek(f, 0)
        x = read(f, String)
        close(cf)
        x
    end
    print(str)
end

function Base.show(io::IO, M::GBMatrix)
    printtest(io, M)
end
