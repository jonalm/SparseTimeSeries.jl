
struct Segment{T,U}
    value::T
    tstart::U
    tend::U
end
#Segment(value::T, tstart::U, tend::U) where {T, U} = Segment{T,U}(tstart, tend)

@inline value(s::Segment) = s.value
@inline timestamp(s::Segment) = s.tstart
@inline duration(s::Segment) = s.tend - s.tstart
