struct GrB_No_Value_Exception <: Exception end
struct GrB_Uninitialized_Object_Exception <: Exception end
struct GrB_Invalid_Object_Exception <: Exception end
struct GrB_Null_Pointer_Exception <: Exception end
struct GrB_Invalid_Value_Exception <: Exception end
struct GrB_Invalid_Index_Exception <: Exception end
struct GrB_Dimension_Mismatch_Exception <: Exception end
struct GrB_Domain_Mismatch_Exception <: Exception end
struct GrB_Output_Not_Empty_Exception <: Exception end
struct GrB_Out_Of_Memory_Exception <: Exception end
struct GrB_Insufficient_Space_Exception <: Exception end
struct GrB_Index_Out_Of_Bounds_Exception <: Exception end
struct GrB_Panic_Exception <: Exception end

function checkinfo(i::GrB_Info)
    if i == GrB_NO_VALUE
        throw(GrB_No_Value_Exception())
    elseif i == GrB_UNINITIALIZED_OBJECT
        throw(GrB_Uninitialized_Object_Exception())
    elseif i == GrB_INVALID_OBJECT
        throw(GrB_Invalid_Object_Exception())
    elseif i == GrB_NULL_POINTER
        throw(GrB_Null_Pointer_Exception())
    elseif i == GrB_INVALID_VALUE
        throw(GrB_Invalid_Value_Exception())
    elseif i == GrB_INVALID_INDEX
        throw(GrB_Invalid_Index_Exception())
    elseif i == GrB_DOMAIN_MISMATCH
        throw(GrB_Domain_Mismatch_Exception())
    elseif i == GrB_DIMENSION_MISMATCH
        throw(GrB_Dimension_Mismatch_Exception())
    elseif i == GrB_OUTPUT_NOT_EMPTY
        throw(GrB_Output_Not_Empty_Exception())
    elseif i == GrB_OUT_OF_MEMORY
        throw(GrB_Out_Of_Memory_Exception())
    elseif i == GrB_INSUFFICIENT_SPACE
        throw(GrB_Insufficient_Space_Exception())
    elseif i == GrB_INDEX_OUT_OF_BOUNDS
        throw(GrB_Index_Out_Of_Bounds_Exception())
    elseif i == GrB_PANIC
        throw(GrB_Panic_Exception())
    else return GrB_SUCCESS
    end
end

#TODO - This one will probably be tricky. Do any of the other wrappers implement this?
function GrB_error()

end