@kwargs function emul!(
    w::GBVector,
    u::GBVector,
    v::GBVector;
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseMult_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseMult_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    else
        error("Unreachable")
    end
end

@kwargs function emul(
    u::GBVector,
    v::GBVector;
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
)
    if op isa OpUnion
        t = ztype(op)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return emul!(w, u, v; op, mask , accum, desc)
end

@kwargs function emul!(
    C::GBMatrix,
    A::GBMatOrTrans,
    B::GBMatOrTrans;
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseMult_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseMult_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseMult_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    end
end

@kwargs function emul(
    A::GBMatOrTrans,
    B::GBMatOrTrans;
    op::MonoidSemiringOrBinary = BinaryOps.TIMES
)
    if op isa OpUnion
        t = ztype(op)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBMatrix{t}(size(A))
    return emul!(C, A, B; op, mask, accum, desc)
end

@kwargs function eadd!(
    w::GBVector,
    u::GBVector,
    v::GBVector;
    op::MonoidSemiringOrBinary = BinaryOps.PLUS
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseAdd_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseAdd_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    else
        error("Unreachable")
    end
end

@kwargs function eadd(
    u::GBVector,
    v::GBVector;
    op::MonoidSemiringOrBinary = BinaryOps.PLUS
)
    if op isa OpUnion
        t = ztype(op)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return eadd!(w, u, v; op, mask, accum, desc)
end

@kwargs function eadd!(
    C::GBMatrix,
    A::GBMatOrTrans,
    B::GBMatOrTrans;
    op::MonoidSemiringOrBinary = BinaryOps.PLUS
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseAdd_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseAdd_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseAdd_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    else
        error("Unreachable")
    end
end

@kwargs function eadd(
    A::GBMatOrTrans,
    B::GBMatOrTrans;
    op::MonoidSemiringOrBinary = BinaryOps.PLUS
)
    if op isa OpUnion
        t = ztype(op)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBMatrix{t}(size(A))
    return eadd!(C, A, B; op, mask, accum, desc)
end


@kwargs Base.broadcasted(::typeof(+), u::GBVector, v::GBVector) = eadd(u, v)
@kwargs Base.broadcasted(::typeof(*), u::GBVector, v::GBVector) = emul(u, v)

@kwargs Base.broadcasted(::typeof(+), A::GBMatOrTrans, B::GBMatOrTrans) = eadd(A, B)
@kwargs Base.broadcasted(::typeof(*), A::GBMatOrTrans, B::GBMatOrTrans) = emul(A, B)
