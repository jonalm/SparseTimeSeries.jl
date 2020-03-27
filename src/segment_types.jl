
struct Segment{T,U}
    tstart::T
    tend::T
    value::U
end

@inline timestamp(s::Segment) = s.tstart
@inline value(s::Segment) = s.value
@inline duration(s::Segment) = s.tend - s.tstart
