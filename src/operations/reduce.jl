@kwargs function reduce!(
    w::GBVector,
    A::GBMatrix,
    op::Union{Abstract_GrB_Monoid, libgb.GrB_Monoid}
)
    op = getoperator(op, eltype(w))
    libgb.GrB_Matrix_reduce_Monoid(w, mask, accum, op, A, desc)
end

#TODO: Handle transposed reduction.
@kwargs function Base.reduce(op, A::GBMatrix; dims = 2, typeout = nothing, init = nothing)
    if typeout === nothing
        typeout = eltype(A)
    end
    if dims == 2
        w = GBVector{typeout}(size(A, 1))
        reduce!(w, A, op)
        return w
    elseif dims == 1 #Need Descriptor v2
        error("Implementation Not Ready")
    elseif dims == (1,2)
        if init === nothing
            c = Ref{typeout}()
            typec = typeout
        else
            c = Ref(init)
            typec = typeof(init)
        end
        op = getoperator(op, typec)
        libgb.scalarmatreduce[typeout](c, accum, op, A, desc)
        return c[]
    end
end

@kwargs function Base.reduce(
    op::Union{Abstract_GrB_Monoid, libgb.GrB_Monoid}, v::GBVector;
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
