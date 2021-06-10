@kwargs function select!(
    op::SelectUnion,
    C::GBVecOrMat,
    A::GBVecMatOrTrans;
    thunk::Union{GBScalar, Nothing} = nothing
)
    thunk === nothing && (thunk = C_NULL)
    A, desc, _ = _handletranspose(A, desc)
    if A isa GBVector && C isa GBVector
        libgb.GxB_Vector_select(C, mask, accum, op, A, thunk, desc)
    elseif A isa GBMatrix && C isa GBMatrix
        libgb.GxB_Matrix_select(C, mask, accum, op, A, thunk, desc)
    end
end

@kwargs function select(
    op::SelectUnion,
    A::GBVecMatOrTrans;
    thunk::Union{GBScalar, Nothing} = nothing
)
    C = similar(A)
    select!(op, C, A; thunk, accum, mask, desc)
    return C
end
