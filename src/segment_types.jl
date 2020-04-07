
struct Segment{T,U}
    value::T
    tstart::U
    tend::U
end

@inline value(s::Segment) = s.value
@inline timestamp(s::Segment) = s.tstart
@inline duration(s::Segment) = s.tend - s.tstart
