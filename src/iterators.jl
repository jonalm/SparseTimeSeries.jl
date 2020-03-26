struct Events{ES, T}
    ts::ES
    t1::T
    t2::T
    function Events(e::EventSeries{T}, t1::T, t2::T) where {T}
        @assert t1 < t2 "time boundary error"
        @assert e.timestamps[1] <= t1 "time boundary 't1' beforee first event"
        @assert t2 <= e.timestamps[end] "time boundary 't2' after first event"
        new{typeof(e), T}(e, t1, t2)
    end
end

Events(e::EventSeries) = Events(e, e.timestamps[1], e.timestamps[end])

macro return_nothing_if_noting(ex)
    quote
        result = $(esc(ex))
        result === nothing && return nothing
        result
    end
end

struct Neighbors{S}
    iter::S
end
Base.length(n::Neighbors) = length(n.iter)

function Base.iterate(n::Neighbors{S}) where {S}
    inner_val_1, inner_state_1 = @return_nothing_if_noting iterate(n.iter)
    inner_val_2, inner_state_2 = @return_nothing_if_noting iterate(n.iter,inner_state_1)
    return (inner_val_1, inner_val_2), (first_val=inner_val_1, previous_val=inner_val_2, iterstate=inner_state_2)
end

function Base.iterate(n::Neighbors{S}, state) where {S}
    state === nothing && return nothing
    tmp = iterate(n.iter, state.iterstate)
    tmp === nothing && return (state.previous_val, state.first_val), nothing
    inner_val, inner_state = tmp
    return (state.previous_val, inner_val), (first_val=state.first_val, previous_val=inner_val, iterstate=inner_state)
end



struct Segments
    e::Events
end

function Base.iterate(events::Events)
    @unpack ts, t1, t2 = events
    @show ts
    idx = searchsortedfirst(ts.timestamps, t1)
    if t1 == ts.timestamps[idx]
        return ts[idx], idx+1
    else
        return Event(timestamp=t1, value=ts[idx-1].value), idx
    end
end

function Base.iterate(events::Events, nextidx)
    @unpack ts, t1, t2 = events
    @show ts
    1 <= nextidx  <= length(ts) || return nothing
    e = ts[nextidx]
    return e.timestamp < t2 ? (e, nextidx+1) : e.timestamp == t2 ? (e, -1) : (Event(timestamp=t2,value=ts[nextidx-1].value), -1)
end
