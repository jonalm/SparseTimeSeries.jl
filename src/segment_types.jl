
struct Segment{T,U}
    tstart::U
    tend::U
end
Segment(value, tstart::U, tend::U) where {U} = Segment{value, U}(tstart, tend)

@inline value(s::Segment{T}) where {T} = T
@inline timestamp(s::Segment) = s.tstart
@inline duration(s::Segment) = s.tend - s.tstart
