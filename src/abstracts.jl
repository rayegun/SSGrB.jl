
abstract type Abstract_GrB_Struct end
abstract type Abstract_GrB_Type <: Abstract_GrB_Struct end
abstract type Abstract_GrB_Descriptor <: Abstract_GrB_Struct end
abstract type Abstract_GrB_Op end
abstract type Abstract_GrB_UnaryOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_BinaryOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_SelectOp <: Abstract_GrB_Op end
abstract type Abstract_GrB_Monoid <: Abstract_GrB_Op end
abstract type Abstract_GrB_Semiring <: Abstract_GrB_Op end

abstract type Abstract_Semiring_Container <: Abstract_GrB_Semiring end
abstract type Abstract_UnaryOp_Container <: Abstract_GrB_UnaryOp end
abstract type Abstract_BinaryOp_Container <: Abstract_GrB_BinaryOp end
abstract type Abstract_Monoid_Container <: Abstract_GrB_Monoid end

isloaded(o::Abstract_GrB_Op) = !isempty(o.pointers)

function validtypes(o::Abstract_GrB_Op)
    isloaded(o) || load(o)
    return keys(o.pointers)
end

function Base.getindex(o::Abstract_GrB_Op, t::DataType)
    isloaded(o) || load(o)
    getindex(o.pointers, t)
end
