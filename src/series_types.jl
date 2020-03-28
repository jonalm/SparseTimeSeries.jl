
abstract type ConstructionFlag end
struct TrustInput <: ConstructionFlag end



"""
`EventSeries` holds a vector of `values` toghether with its corresponding
`timestamps`. `EventSeries` is subtype `AbstractVector`, and of both `timestamps`
and `values` must be subtypes of `AbstractVector`.

EventSeries(timestamps::U, values::W, ::TrustInput)

    - Assumes that `timestamps` and `values` are of equal
      length, and that `timestamps` is sorted.

EventSeries(timestamps, values; drop_repeated=true, keep_end=true)

    - Checks that `timestamps` and `values` are of equal length
    - Checks that `timestamps` is sorted
    - Throws `AssertionError` if any of the above mentioned checks failss.
    - If `drop_repeated` is true (default) all repeated values in values,
      and corresponding timestamps, are removed before construction.
    - If `keep_end` is true (default), the last value in values (with its
      corresponding timestamp) is kept regardless of whether it equals the
      previous value. Keep_end will only be considered if `drop_repeated`
      is true.
"""
struct EventSeries{T, U, V, W} <: AbstractVector{Tuple{T, V}}
    timestamps::U
    values::W
end

function EventSeries(
    timestamps::U,
    values::W,
    ::TrustInput
    ) where {T, U<:AbstractVector{T}, V,  W<:AbstractVector{V}}
    EventSeries{T, U, V, W}(timestamps, values)
end

function EventSeries(timestamps, values; drop_repeated=true, keep_end=true)
    @assert issorted(timestamps)
    @assert length(timestamps) == length(values)
    if drop_repeated
        select = [true; [a!=b for (a,b) in neighbors(values)]]
        keep_end && (select[end] = true)
        timestamps, values = all(select) ? (timestamps, values) : (timestamps[select],  values[select])
    end
    EventSeries(timestamps, values, TrustInput())
end

Base.size(ts::EventSeries) = size(ts.timestamps)
Base.getindex(ts::EventSeries, i::Number) = Event(timestamp=ts.timestamps[i], value=ts.values[i])
Base.getindex(ts::EventSeries, I) = EventSeries(ts.timestamps[I], ts.values[I])
Base.IndexStyle(ts::EventSeries) = IndexStyle(ts.timestamps)

function Base.push!(ts::EventSeries, e::Event)
    isempty(ts.timestamps) || @assert last(ts.timestamps) <= e.timestamp
    push!(ts.timestamps, e.timestamp)
    push!(ts.values, e.value)
end

function Base.append!(ts1::EventSeries, ts2::EventSeries)
    @assert last(ts1.timestamps) <= first(ts2.timestamps)
    append!(ts1.timestamps, ts2.timestamps)
    append!(ts1.values, ts2.values)
end

"""
    timestamptype(y::EventSeries)

Returns time type of the EventSeries, which equals `eltype(y.timestamps)`.
"""
timestamptype(::EventSeries{T}) where {T} = T


"""
`TaggedEventSeries{T}` holds a mapping from `tag::T` to an `eventseries::EventSeries`.

Assumes that the `timestamptype(eventseries)` can be compared betweeen types.

# Constructors

TaggedEventSeries(d::Dict{Symbol, EventSeries})
TaggedEventSeries()

"""
struct TaggedEventSeries
    data::Dict{Symbol, EventSeries}
end
function TaggedEventSeries(;kwargs...)
    tes = TaggedEventSeries(Dict{Symbol, EventSeries}())
    for (k,v) in kwargs
        tes[k] = v
    end
    tes
end

Base.length(tts::TaggedEventSeries) = sum(length(v) for v in values(tts.data))
Base.size(tts::TaggedEventSeries) = (length(tts),)

Base.getindex(tts::TaggedEventSeries, args...) = getindex(tts.data, args...)
Base.setindex!(tts::TaggedEventSeries, args...) = setindex!(tts.data, args...)

function Base.push!(tts::TaggedEventSeries, e::TaggedEvent)
    if e.tag in keys(tts.data)
        push!(tts[e.tag], Event(e.timestamp, e.value))
    else
        tts[e.tag] = EventSeries([e.timestamp], [e.value])
    end
end

function EventSeries(tts::TaggedEventSeries)
    timestamps_ = timestamps(tts) |> collect
    values_ = fill_forward_value.(Ref(tts), timestamps_)
    EventSeries(timestamps_, values_)
end

"""
    sorted_tag_idx(tts::TaggedEventSeries)

Returns a time sorted iterator over all (tag, index_in_event_series) pairs in the
input TaggedEventSeries.
"""
function sorted_tag_idx(tts::TaggedEventSeries)
    Channel() do c
        state = Dict(t=>(tts[t].timestamps[1], 1, length(tts[t])) for t in keys(tts.data))
        while !isempty(state)
            (time, idx, len), tag = findmin(state)
            put!(c, (tag, idx))
            if idx == len
                delete!(state, tag)
            else
                idx = idx + 1
                state[tag] = (tts[tag].timestamps[idx], idx, len)
            end
        end
    end
end

"""
    tagged_events_itr(tts::TaggedEventSeries)

Returns a time sorted iterator over all TaggedEvents in the input TaggedEventSeries.

see also `tagged_events(tts::TaggedEventSeries)`.
"""
tagged_events_itr(tts::TaggedEventSeries) = (TaggedEvent(tag, tts[tag][idx]) for (tag, idx) in sorted_tag_idx(tts))
timestamps(tts::TaggedEventSeries) = (tts[tag].timestamps[idx] for (tag, idx) in sorted_tag_idx(tts))

"""
    tagged_events(tts::TaggedEventSeries)

Returns a time sorted vector of all TaggedEvents in the input TaggedEventSeries.

see also tagged_events_itr(tts::TaggedEventSeries)
"""
function tagged_events(tts::TaggedEventSeries)
    sort(vcat([[TaggedEvent(tag, e) for e in ts] for (tag, ts) in tts.data]...), by=x->x.timestamp)
end

function fill_forward_event(ts::EventSeries, time)
    t0, t1 =  first(ts.timestamps), last(ts.timestamps)
    if time <= t0
        return time < t0 ? nothing : ts[1]
    elseif t1 <= time
        return ts[end]
    else
        idx = searchsortedfirst(ts.timestamps, time)
        return time == ts.timestamps[idx] ? ts[idx] : ts[idx-1]
    end
end
fill_forward_event(tts::TaggedEventSeries, time) = _fill_forward_event(tts, time, sort(collect(keys(tts.data))))
_fill_forward_event(tts::TaggedEventSeries, time, skeys) = NamedTuple{Tuple(skeys)}(Tuple(fill_forward_event(tts[tag], time) for tag in skeys))

"""
    fill_forward_event(ts::EventSeries, time)

Returns the prior (with respect to `time`) `Event` in the input `EventSeries`).

    fill_forward_event(ts::TaggedEventSeries, time)

Returns a named tuple with the prior (with respect to `time`) `Event`s for each
tag in the input `TaggedEventSeries`.

If `time` is before the first timestamp in `EventSeries` / `TaggedEventSeries`,
then `nothing` is returned.
"""
fill_forward_event

fill_forward_value(ts::EventSeries, time) = value(fill_forward_event(ts, time))
fill_forward_value(tts::TaggedEventSeries, time) = _fill_forward_value(tts, time, sort(collect(keys(tts.data))))
_fill_forward_value(tts::TaggedEventSeries, time, skeys) = NamedTuple{Tuple(skeys)}(Tuple(fill_forward_value(tts[tag], time) for tag in skeys))

"""
    fill_forward_value(ts::EventSeries, time)

Returns the prior (with respect to `time`) `value` in the input `EventSeries`).

    fill_forward_value(ts::TaggedEventSeries, time)

Returns a named tuple with the prior (with respect to `time`) `values`s for each
tag in the input `TaggedEventSeries`.

If `time` is before the first timestamp in `EventSeries` / `TaggedEventSeries`,
then `nothing` is returned.
"""
fill_forward_value

"""
     select(y::EventSeries, t1, t2)

returns an EventSeries which is a subset of the input series, containing the `Event`s
in the time domain [tstart, tend]. The endpoint values are set by filling forward
Assumes that the input time domain `[t1, t2]` is contained in the input EventSeries.
"""
function select(y::EventSeries, t1, t2)
    @assert y.timestamps[1] <= t1 < t2 <= y.timestamps[end] "invaid time limits"
    v1 = fill_forward_value(y, t1)
    v2 = fill_forward_value(y, t2)
    select = [t1 < e.timestamp < t2 for e in y]
    EventSeries([t1; y.timestamps[select]; t2], [v1; y.values[select]; v2])
end

"""
    align(ys::EventSeries{T}...)

Returns a tuple of EventSeries containing subsets of the corresponding series input,
such that the time domain of each output series corresponds to the largest common time
domain of the input series. See `select`.
"""
function align(ys::EventSeries{T}...) where T
    tmin = maximum(y.timestamps[1] for y in ys)
    tmax = minimum(y.timestamps[end] for y in ys)
    Tuple(select(y, tmin, tmax) for y in ys)
end

"""
    cumtime(es::EventSeries{T}, val)

Returns cummulative time of EventSeries where the value equals `val`
"""
function cumtime(es::EventSeries{T}, val) where T
    eventpairs = SparseTimeSeries.neighbors(es)
    durations = (e2.timestamp-e1.timestamp for (e1,e2) in eventpairs if e1.value==val)
    isempty(durations) ? zero(T) : sum(durations)
end


function fuse(;kwargs...)
    tes = TaggedEventSeries(;kwargs...)
    EventSeries(tes)
end

function splice(;kwargs...) where {T}
    tes = TaggedEventSeries(;kwargs...)
    taggedevents = tagged_events(tes)
    EventSeries([e.timestamp for e in taggedevents], [e.tag=>e.value for e in taggedevents])
end

function Base.filter(f, y::EventSeries)
    select = [f(e) for e in y]
    EventSeries(y.timestamps[select], y.values[select])
end

segments(y::EventSeries) = (Segment(e1.timestamp, e2.timestamp, e1.value) for (e1, e2) in neighbors(y))
