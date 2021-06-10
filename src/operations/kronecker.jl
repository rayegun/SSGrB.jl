@kwargs function kron!(C::GBMatOrTrans,
    A::GBMatOrTrans,
    B::GBMatOrTrans,
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
)
    op = getoperator(op, eltype(C))
    A, desc, B = _handletranspose(A, desc, B)
    if op isa Union{Abstract_GrB_BinaryOp, libgb.GrB_BinaryOp}
        libgb.GxB_kron(C, mask, accum, op, A, B, desc)
    elseif op isa Union{Abstract_GrB_Monoid, libgb.GrB_Monoid}
        libgb.GrB_Matrix_kronecker_Monoid(C, mask, accum, op, A, B, desc)
    elseif op isa Union{Abstract_GrB_Semiring, libgb.GrB_Semiring}
        libgb.GrB_Matrix_kronecker_Semiring(C, mask, accum, op, A, B, desc)
    end
end

@kwargs function kron(
    A::GBMatOrTrans,
    B::GBMatOrTrans,
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
    )
    op = getoperator(op, optype(eltype(A), eltype(B)))
    t = juliatype(ztype(op))
    C = GBMatrix{t}(size(A,1) * size(B, 1), size(A, 2) * size(B, 2))
end
