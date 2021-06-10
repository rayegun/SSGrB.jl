@kwargs function mul!(
    C::GBMatrix,
    A::GBMatOrTrans,
    B::GBMatOrTrans;
    op::SemiringUnion = Semirings.PLUS_TIMES_SEMIRING
)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch())
    size(A, 1) == size(C, 1) || throw(DimensionMismatch())
    size(B, 2) == size(C, 2) || throw(DimensionMismatch())
    op = getoperator(op, eltype(C))
    A, desc, B = _handletranspose
    libgb.GrB_mxm(C, mask, accum, op, A, B, desc)
end

@kwargs function mul!(
    w::GBVector,
    u::GBVector,
    A::GBMatOrTrans;
    op::SemiringUnion = Semirings.PLUS_TIMES_SEMIRING
)
    size(u) == size(A, 1) || throw(DimensionMismatch())
    size(w) == size(A, 2) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    u, desc, A = _handletranspose
    libgb.GrB_vxm(w, mask, accum, op, u, A, desc)
end

@kwargs function mul!(
    w::GBVector,
    A::GBMatOrTrans,
    u::GBVector;
    op::SemiringUnion = Semirings.PLUS_TIMES_SEMIRING
)
    size(u) == size(A, 2) || throw(DimensionMismatch())
    size(w) == size(A, 1) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    A, desc, u = _handletranspose
    libgb.GrB_mxv(w, mask, accum, op, A, u, desc)
end

@kwargs function mul(
    A::GBVecMatOrTrans,
    B::GBVecMatOrTrans;
    op::SemiringUnion = Semirings.PLUS_TIMES_SEMIRING
)
    op = getoperator(op, optype(eltype(A), eltype(B)))
    t = juliatype(ztype(op))
    if A isa GBVector && B isa GBMatOrTrans
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatOrTrans && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatOrTrans && B isa GBMatOrTrans
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    end
    A, desc, B = _handletranspose(A, desc, B)
    mul!(C, A, B; op, mask, accum, desc)
    return C
end
