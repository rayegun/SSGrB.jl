#NOTES:
#   Transposes give a GrB_DIMENSION_MISMATCH. So we do not provide a GBMatOrTrans arg.

@kwargs function apply!(C::GBVecOrMat, A::GBVecOrMat, op::UnaryUnion)
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.GrB_Vector_apply(C, mask, accum, op, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.GrB_Matrix_apply(C, mask, accum, op, A, desc)
    end
end
@kwargs apply!(A::GBVecOrMat, op::UnaryUnion) = apply!(A, A, op; mask, accum, desc)
@kwargs function apply(A::GBVecOrMat, op::UnaryUnion)
    C = similar(A)
    apply!(C, A, op; mask, accum, desc)
    return C
end

@kwargs function apply!(C::GBVecOrMat, x, A::GBVecOrMat, op::BinaryUnion)
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply1st[eltype(C)](C, mask, accum, op, x, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply1st[eltype(C)](C, mask, accum, op, x, A, desc)
    end
end

@kwargs function apply!(x, A::GBVecOrMat, op::BinaryUnion)
    apply!(A, x, A, op; mask, accum, desc)
end

@kwargs function apply(x, A::GBVecOrMat, op::BinaryUnion)
    C = similar(A)
    apply!(C, x, A, op; mask, accum, desc)
    return C
end

@kwargs function apply!(C::GBVecOrMat, A::GBVecOrMat, x, op::BinaryUnion)
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply2nd[eltype(C)](C, mask, accum, op, A, x, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply2nd[eltype(C)](C, mask, accum, op, A, x, desc)
    end
end

@kwargs function apply!(A::GBVecOrMat, x, op::BinaryUnion)
    apply!(A, A, x, op; mask, accum, desc)
end

@kwargs function apply(A::GBVecOrMat, x, op::BinaryUnion)
    C = similar(A)
    apply!(C, A, x, op; mask, accum, desc)
    return C
end

@kwargs function Base.broadcasted(::typeof(+), u::GBVecOrMat, x::valid_union)
    apply(u, x, BinaryOps.PLUS; mask, accum, desc)
end
@kwargs function Base.broadcasted(::typeof(+), x::valid_union, u::GBVecOrMat)
    apply(x, u, BinaryOps.PLUS; mask, accum, desc)
end

@kwargs function Base.broadcasted(::typeof(*), u::GBVecOrMat, x::valid_union)
    apply(u, x, BinaryOps.TIMES; mask, accum, desc)
end
@kwargs function Base.broadcasted(::typeof(*), x::valid_union, u::GBVecOrMat)
    apply(x, u, BinaryOps.TIMES; mask, accum, desc)
end

#NOT WORKING
function Base.broadcasted(::typeof(^), u::GBVecOrMat, x::valid_union)
    apply(u, x, BinaryOps.POW)
end
@kwargs function Base.broadcasted(::typeof(^), x::valid_union, u::GBVecOrMat)
    apply(x, u, BinaryOps.POW; mask, accum, desc)
end
