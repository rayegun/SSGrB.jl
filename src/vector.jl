function GBVector{T}(n) where {T}
    GBVector{T}(libgb.GrB_Vector_new(toGrB_Type(T),n))
end
GBVector{T}() where {T} = GBVector{T}(libgb.GxB_INDEX_MAX)

Base.unsafe_convert(::Type{libgb.GrB_Vector}, v::GBVector) = v.p

function Base.copy(v::GBVector{T}) where {T}
    return GBVector{T}(libgb.GrB_Vector_dup(v))
end

clear!(v::GBVector) = libgb.GrB_Vector_clear(v)

function Base.size(v::GBVector, dim = nothing)
    if dim === nothing || dim == 1
        return Int64(libgb.GrB_Vector_size(v))
    else
        return 1
    end
end

nnz(v::GBVector) = Int64(libgb.GrB_Vector_nvals(v))
Base.eltype(::Type{GBVector{T}}) where{T} = T

#Similar functions. This definition is kind of clunky, but there were overwrite errors if I did it in another way.
Base.similar(v::GBVector) = GBVector{eltype(v)}(size(v))
Base.similar(::GBVector{T}, dims::Integer) where {T} = GBVector{T}(dims)
Base.similar(v::GBVector, element_type::DataType) = GBVector{element_type}(size(v))
Base.similar(::GBVector, element_type::DataType, dims::Integer) = GBVector{element_type}(dims)

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
        function Base.setindex!(v::GBVector{$T}, x::$T, i::Integer)
            return libgb.$func(v, x, libgb.GrB_Index(i))
        end
    end
    func = Symbol(prefix, :_Vector_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i::Integer)
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

#Determine the length of output vector for indexing operations.
function wlength(u, I)
    if I == ALL
        wlen = size(u)
    else
        wlen = length(I)
    end
    return wlen
end

#Determine the index vector depending on type and contents of I.

@kwargs function extract!(w::GBVector, u::GBVector, I)
    I, ni = idx(I)
    libgb.GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    return w
end

@kwargs function extract(u::GBVector, I)
    wlen = wlength(u, I)
    w = similar(u, wlen)
    return extract!(w, u, I; mask, accum, desc)
end

@kwargs Base.getindex(u::GBVector, ::Colon) = extract(u, ALL; mask, accum, desc)
@kwargs function Base.getindex(u::GBVector, i::Union{Vector, UnitRange, StepRange})
    return extract(u, i; mask, accum, desc)
end

@kwargs function subassign!(w::GBVector, u, I)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)
    else
        libgb.scalarvecsubassign[eltype(u)](w, mask, accum, u, I, ni, desc)
    end
end

@kwargs function assign!(w::GBVector, u, I)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GrB_Vector_assign(w, mask, accum, u, I, ni, desc)
    else
        libgb.scalarvecassign[eltype(u)](w, mask, accum, u, I, ni, desc)
    end
end

#setindex! uses subassign rather than assign. This behavior may change in the future.
@kwargs Base.setindex!(u::GBVector, x, ::Colon) = subassign!(u, x, ALL; mask, accum, desc)
@kwargs function Base.setindex!(u::GBVector, x, I::Union{Vector, UnitRange, StepRange})
    subassign!(u, x, I; mask, accum, desc)
end

function GBVector(I::Vector, X::Vector{T}; dup = BinaryOps.PLUS) where {T}
    x = GBVector{T}(maximum(I))
    build(x, I, X, dup = dup)
    return x
end

#TEMPORARY: NEEDS IMPORT/EXPORT
function GBVector(X::Vector)
    return GBVector(collect(1:length(X)), X) #Collect... Ouch.
end

#TEMPORARY: NEEDS IMPORT/EXPORT
function GBVector(A::SparseVector)
    i, k = findnz(A)
    return GBVector(i, k)
end
function Base.deleteat!(v::GBVector, i)
    libgb.GrB_Vector_removeElement(v, libgb.GrB_Index(i))
    return v
end

function Base.resize!(v::GBVector, nrows_new)
    libgb.GrB_Vector_resize(v, nrows_new)
    return v
end

function diagonal(A::GBMatrix, k = 0, desc = C_NULL)
    return libgb.GxB_Vector_diag(A, k, desc)
end

function printtest(io::IO, M::GBVector)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        libgb.GxB_Vector_fprint(M, "Test", libgb.GxB_SHORT, cf)
        flush(f)
        seekstart(f)
        x = read(f, String)
        close(cf)
        x
    end
    print(str)
end

function Base.show(io::IO, M::GBVector)
    printtest(io, M)
end
