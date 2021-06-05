function emul!(
    w::GBVector, u::GBVector, v::GBVector, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
    )
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    if operator === nothing
        operator = getbinaryop(eltype(w))
    else
        getoperator(operator, eltype(w))
    end
    print(operator)
    if operator isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseMult_Semiring(w, mask, accum, operator, u, v, desc)
        return w
    elseif operator isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseMult_Monoid(w, mask, accum, operator, u, v, desc)
        return w
    elseif operator isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, operator, u, v, desc)
        return w
    else
        error("Unreachable")
    end
end

function emul(
    u::GBVector, v::GBVector, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc= C_NULL
    )
    if operator !== nothing
        t = ztype(operator)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return emul!(w, u, v, operator, mask = mask, accum = accum, desc = desc)
end

function emul!(
    C::GBMatrix, A::GBMatrix, B::GBMatrix, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
    )
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    if operator === nothing
        operator = getbinaryop(eltype(C))
    else
        getoperator(operator, eltype(C))
    end
    print(operator)
    if operator isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseMult_Semiring(C, mask, accum, operator, A, B, desc)
        return C
    elseif operator isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseMult_Monoid(C, mask, accum, operator, A, B, desc)
        return C
    elseif operator isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseMult_BinaryOp(C, mask, accum, operator, A, B, desc)
        return C
    else
        error("Unreachable")
    end
end

function emul(
    A::GBMatrix, B::GBMatrix, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc= C_NULL
    )
    if operator !== nothing
        t = ztype(operator)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBVector{t}(size(A))
    return emul!(C, A, B, operator, mask = mask, accum = accum, desc = desc)
end

function eadd!(
    w::GBVector, u::GBVector, v::GBVector, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
    )
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    if operator === nothing
        operator = getbinaryop(eltype(w))
    else
        getoperator(operator, eltype(w))
    end
    print(operator)
    if operator isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseAdd_Semiring(w, mask, accum, operator, u, v, desc)
        return w
    elseif operator isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseAdd_Monoid(w, mask, accum, operator, u, v, desc)
        return w
    elseif operator isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, operator, u, v, desc)
        return w
    else
        error("Unreachable")
    end
end

function eadd(
    u::GBVector, v::GBVector, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc= C_NULL
    )
    if operator !== nothing
        t = ztype(operator)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return eadd!(w, u, v, operator, mask = mask, accum = accum, desc = desc)
end

function eadd!(
    C::GBMatrix, A::GBMatrix, B::GBMatrix, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc = C_NULL
    )
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    if operator === nothing
        operator = getbinaryop(eltype(C))
    else
        getoperator(operator, eltype(C))
    end
    print(operator)
    if operator isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseAdd_Semiring(C, mask, accum, operator, A, B, desc)
        return C
    elseif operator isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseAdd_Monoid(C, mask, accum, operator, A, B, desc)
        return C
    elseif operator isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseAdd_BinaryOp(C, mask, accum, operator, A, B, desc)
        return C
    else
        error("Unreachable")
    end
end

function eadd(
    A::GBMatrix, B::GBMatrix, operator = nothing;
    mask = C_NULL, accum = C_NULL, desc= C_NULL
    )
    if operator !== nothing
        t = ztype(operator)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBVector{t}(size(A))
    return eadd!(C, A, B, operator, mask = mask, accum = accum, desc = desc)
end


Base.broadcasted(::typeof(+), u::GBVector, v::GBVector) = eadd(u, v)
Base.broadcasted(::typeof(*), u::GBVector, v::GBVector) = emul(u, v)

Base.broadcasted(::typeof(+), A::GBMatrix, B::GBMatrix) = eadd(A, B)
Base.broadcasted(::typeof(*), A::GBMatrix, B::GBMatrix) = emul(A, B)
