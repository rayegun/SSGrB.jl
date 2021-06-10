@kwargs function reduce!(
    op::MonoidUnion,
    w::GBVector,
    A::GBMatOrTrans)
    A, desc, _ = _handletranspose(A, desc, nothing)
    op = getoperator(op, eltype(w))
    libgb.GrB_Matrix_reduce_Monoid(w, mask, accum, op, A, desc)
end

@kwargs function Base.reduce(op::MonoidUnion, A::GBMatOrTrans;
    dims = 2, typeout = nothing, init = nothing
)
    if typeout === nothing
        typeout = eltype(A)
    end
    if dims == 2
        w = GBVector{typeout}(size(A, 1))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == 1
        desc = desc + Descriptors.T0
        w = GBVector{typeout}(size(A, 2))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == (1,2)
        if init === nothing
            c = Ref{typeout}()
            typec = typeout
        else
            c = Ref(init)
            typec = typeof(init)
        end
        op = getoperator(op, typec)
        A, desc, _ = _handletranspose(A, desc, nothing)
        libgb.scalarmatreduce[typeout](c, accum, op, A, desc)
        return c[]
    end
end

@kwargs function Base.reduce(
    op::MonoidUnion, v::GBVector;
    typeout = nothing, init = nothing
)
    if typeout === nothing
        typeout = eltype(v)
    end
    if init === nothing
        c = Ref{typeout}()
        typec = typeout
    else
        c = Ref(init)
        typec = typeof(init)
    end
    op = getoperator(op, typec)
    libgb.scalarvecreduce[typeout](c, accum, op, v, desc)
    return c[]
end
