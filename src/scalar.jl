GBScalar{T}() where {T} = GBScalar{T}(libgb.GxB_Scalar_new(toGrB_Type(T)))

Base.unsafe_convert(::Type{libgb.GxB_Scalar}, s::GBScalar) = s.p

Base.copy(s::GBScalar{T}) where {T} = GBScalar{T}(s.p)

function GBScalar(v::T) where {T <: valid_union}
    x = GBScalar{T}()
    x[] = v
    return x
end

function Base.deepcopy(s::GBScalar{T}) where {T}
    return GBScalar{T}(libgb.GxB_Scalar_dup(s))
end

#dup(s::GBScalar) = Base.deepcopy(s)

clear(s::GBScalar) = libgb.GxB_Scalar_clear(s)

for T ∈ valid_vec
    func = Symbol(:GxB_Scalar_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(value::GBScalar{$T}, s::$T)
            libgb.$func(value, s)
        end
    end
    func = Symbol(:GxB_Scalar_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(value::GBScalar{$T})
            libgb.$func(value)
        end
    end
end


Base.eltype(::Type{GBScalar{T}}) where{T} = T
#type(s::GBScalar{T}) = eltype(s)

function Base.show(io::IO, ::MIME"text/plain", s::GBScalar{T}) where {T}
    print(io, "GBScalar{", string(T), "}: ", string(s[]))
end

#I don't love this for multiple reasons. nnz is a misnomer, it should really be nzvals.
# The second reason is that I'm not sure if I should provide a length or size. Since
# the length can be zero, but it's a scalar... Uncomment if needed somewhere.

#nvals(s::GBScalar) = libgb.GxB_Scalar_nvals(s)
nnz(s::GBScalar) = libgb.GxB_Scalar_nvals(s)
#Base.length(s::GBScalar) = nnz(s)
