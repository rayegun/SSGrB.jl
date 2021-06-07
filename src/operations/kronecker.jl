@kwargs function kron!(C::GBMatrix, A::GBMatrix, B::GBMatrix, op = BinaryOps.TIMES)
    op = getoperator(op, eltype(C))
    if op isa Union{Abstract_GrB_BinaryOp, libgb.GrB_BinaryOp}
        libgb.GxB_kron(C, mask, accum, op, A, B, desc)
    elseif op isa Union{Abstract_GrB_Monoid, libgb.GrB_Monoid}
        libgb.GrB_Matrix_kronecker_Monoid(C, mask, accum, op, A, B, desc)
    elseif op isa Union{Abstract_GrB_Semiring, libgb.GrB_Semiring}
        libgb.GrB_Matrix_kronecker_Semiring(C, mask, accum, op, A, B, desc)
    end
end

@kwargs function kron(A::GBMatrix, B::GBMatrix, op = BinaryOps.TIMES)

end
