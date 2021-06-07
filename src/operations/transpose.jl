transpose(A::GBVecOrMat) = Transpose(A)

function Base.show(io::IO, ::MIME"text/plain", A::Transpose{<:Any, <:GBVecOrMat})
    if A.parent isa GBVector
        s = "$(size(A.parent)) × 1 "
    else
        s = "$(size(A.parent, 1)) × $(size(A.parent, 2)) "
    end
    print(io, s, "transpose($(typeof(A.parent))) with eltype $(eltype(A.parent)))")
end

@kwargs function Base.copy!(C::GBMatrix, A::LinearAlgebra.Transpose{T, GBMatrix{T}}) where{T}
    libgb.GrB_transpose(C, mask, accum, A.parent, desc)
end

@kwargs function Base.copy(A::LinearAlgebra.Transpose{T, GBMatrix{T}}) where {T}
    C = similar(A.parent, size(A.parent,2), size(A.parent, 1))
    copy!(C, A)
    return C
end

