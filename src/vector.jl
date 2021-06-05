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
        function Base.setindex!(v::GBVector{$T}, x::$T, i)
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

function extract!(
    w::GBVector, u::GBVector, I, ni = length(I);
    mask = C_NULL, accum = C_NULL, desc = C_NULL
    )
    if I != ALL
        I = Vector{libgb.GrB_Index}(I)
    end
    libgb.GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    return w
end

function extract(u::GBVector, I, ni = nothing; mask = C_NULL, accum = C_NULL, desc = C_NULL)
    if I == ALL
        wlen = size(u)
        ni = 1
    elseif ni == libgb.GxB_RANGE && length(I) == 2
        wlen = length(I[1]:I[2])
    elseif ni == libgb.GxB_STRIDE && length(I) == 3
        wlen = length(I[1]:I[3]:I[2])
        I[3] += 1
    elseif ni == libgb.GxB_BACKWARDS && length(I) == 3
        wlen = length(I[1]:I[3]:I[2])
        I[3] = -I[3] + 1
    else
        ni = length(I)
        wlen = ni
    end
    w = similar(u, wlen)
    return extract!(w, u, I, ni; mask = mask, accum = accum, desc = desc)
end

Base.getindex(u::GBVector, ::Colon) = extract(u, ALL)
Base.getindex(u::GBVector, i::Vector) = extract(u, i)
function Base.getindex(u::GBVector, i::UnitRange)
    i.start <= i.stop || throw(BoundsError(u, i))
    return extract(u, [i.start, i.stop], libgb.GxB_RANGE)
end
function Base.getindex(u::GBVector, i::StepRange)
    if i.start <= i.stop && i.step > 0
        return extract(u, [i.start, i.stop, i.step], libgb.GxB_STRIDE)
    elseif i.start >= i.stop && i.step < 0
        return extract(u, [i.start, i.stop, i.step], libgb.GxB_BACKWARDS)
    else
        throw(BoundsError(u, i))
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
    return libgb.GxB_Vector_diag(A, k, desc)
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
