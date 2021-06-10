transpose(A::GBVecOrMat) = Transpose(A)

@kwargs function Base.copy!(C::GBMatrix, A::LinearAlgebra.Transpose{<:Any, <:GBMatrix})
    libgb.GrB_transpose(C, mask, accum, A.parent, desc)
end

@kwargs function Base.copy(A::LinearAlgebra.Transpose{<:Any, <:GBMatrix})
    C = similar(A.parent, size(A.parent,2), size(A.parent, 1))
    copy!(C, A)
    return C
end

function _handletranspose(
    A::GBVecMatOrTrans,
    desc::Union{Descriptor, Nothing} = nothing,
    B::Union{GBVecMatOrTrans, Nothing} = nothing
)
    if A isa Transpose
        desc = desc + Descriptors.T0
        A = A.parent
    end
    if B isa Transpose
        desc = desc + Descriptors.T1
        B = B.parent
    end
    @show desc
    return A, desc, B
end
