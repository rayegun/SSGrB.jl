struct GrB_No_Value_Exception <: Exception end
struct GrB_Uninitialized_Object_Exception <: Exception end
struct GrB_Invalid_Object_Exception <: Exception end


#TODO - This one will probably be tricky. Do any of the other wrappers implement this?
function GrB_error()

end
