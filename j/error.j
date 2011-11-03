## native julia error handling ##

error(e::Exception) = throw(e)
error{E<:Exception}(::Type{E}) = throw(E())
error(s...) = throw(ErrorException(cstring(s...)))

## system error handling ##

errno() = ccall(:jl_errno, Int32, ())
strerror(e::Int) = ccall(:jl_strerror, Any, (Int32,), int32(e))::ByteString
strerror() = strerror(errno())
system_error(p, b::Bool) = b ? error(SystemError(string(p))) : nothing

## assertion functions and macros ##

assert(x::Bool) = assert(x, '?')
assert(x::Bool, label) = x ? nothing : error("assertion failed: ", label)

macro assert(ex)
    :(assert($ex, $string(ex)))
end
