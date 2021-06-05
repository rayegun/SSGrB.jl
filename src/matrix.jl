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
        return Int64.(libgb.GrB_Matrix_nrows(A), libgb.GrB_Matrix_ncols(A))
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

Base.similar(v::GBMatrix) = GBMatrix{eltype(v)}(size(v))
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
        function Base.getindex(A::GBMatrix{$T}, i, j)
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

function extract!(
    C::GBMatrix, A::GBMatrix, I, ni, J, nj;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
)
    if I != ALL
        I = Vector{libgb.GrB_Index}(I)
    end
    if J != ALL
        J = Vector{libgb.GrB_Index}(J)
    end
    libgb.GrB_Matrix_extract(C, mask, accum, A, I, ni, J, nj, desc)
    return C
end

function extract(
    A, I, J, ni = nothing, nj = nothing;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
)
    if I == ALL
        Ilen = size(A,1)
        ni = 1
    elseif ni == libgb.GxB_RANGE && length(I) == 2
        Ilen = length(I[1]:I[2])
    elseif ni == libgb.GxB_STRIDE && length(I) == 3
        Ilen = length(I[1]:I[3]:I[2])
        I[3] += 1
    elseif ni == libgb.GxB_BACKWARDS && length(I) == 3
        Ilen = length(I[1]:I[3]:I[2])
        I[3] = -I[3] + 1
    else
        ni = length(I)
        Ilen = ni
    end
    if J == ALL
        Jlen = size(A,2)
        nj = 1
    elseif nj == libgb.GxB_RANGE && length(J) == 2
        Jlen = length(J[1]:J[2])
    elseif nj == libgb.GxB_STRIDE && length(J) == 3
        Jlen = length(J[1]:J[3]:J[2])
        J[3] += 1
    elseif nj == libgb.GxB_BACKWARDS && length(J) == 3
        Jlen = length(J[1]:J[3]:J[2])
        J[3] = -J[3] + 1
    else
        nj = length(J)
        Jlen = nj
    end
    C = similar(A, Ilen, Jlen)
    return extract!(C, A, I, ni, J, nj; mask = mask, accum = accum, desc = desc)
end

Base.getindex(A::GBMatrix, ::Colon, j::Union{Integer, Vector}) = extract(A, ALL, j)
Base.getindex(A::GBMatrix, i::Union{Integer, Vector}, ::Colon) = extract(A, i, ALL)
Base.getindex(A::GBMatrix, ::Colon, ::Colon) = extract(ALL, ALL)



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
