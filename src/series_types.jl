
abstract type ConstructionFlag end
struct TrustInput <: ConstructionFlag end

"""
    EventSeries(timestamps, values; drop_repeated=true, keep_end=true)

EventSeries holds a vector of values toghether with its corresponding timestamps.

# Constructors
    EventSeries(timestamps::U, values::W, ::TrustInput)
    EventSeries(timestamps, values; drop_repeated=true, keep_end=true)

Both constructors assumes that  both `timestamps` and `values` are
`AbstractVector`s.

The second constructor, without the `TrustInput` argument, checks that:
    - `timestamps` and `values` are of equal length
    - `timestamps` must be sorted

Otherwise an `AssertionError` is thrown.

# Arguments
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
    function EventSeries(
        timestamps::U,
        values::W,
        ::TrustInput
        ) where {T, U<:AbstractVector{T}, V,  W<:AbstractVector{V}}

        new{T, U, V, W}(timestamps, values)
    end
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


struct TaggedEventSeries{S, T, U, V}
    data::V
    function TaggedEventSeries(
        data::V
        ) where {S, T, U<:AbstractVector{T}, V<:Dict{S, EventSeries{T, U}}}
        new{S, T, U, V}(data)
    end
end

Base.getindex(tts::TaggedEventSeries, args...) = getindex(tts.data, args...)
Base.setindex!(tts::TaggedEventSeries, args...) = setindex!(tts.data, args...)

function Base.push!(tts::TaggedEventSeries, e::Event)
    if e.tag in keys(tts.data)
        push!(tts[e.tag], (e.timestamp, e.value))
    else
        tts[e.tag] = EventSeries([e.timestamp], [e.value])
    end
end



function sorted_indices(tts::TaggedEventSeries)
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
    event_itr(tts::TaggedEventSeries)

Returns a time sorted iterator over all TaggedEvents in the tts TaggedEventSeries.

see also events(tts::TaggedEventSeries)
"""
event_itr(tts::TaggedEventSeries) = (Event(tag, tts[tag][idx]...) for (tag, idx) in sorted_indices(tts))
event_times(tts::TaggedEventSeries) = (tts[tag].timestamps[idx] for (tag, idx) in sorted_indices(tts))

"""
    events(tts::TaggedEventSeries)

Returns a time sorted vector of all TaggedEvents in the tts TaggedEventSeries.

see also events_itr(tts::TaggedEventSeries)
"""
function events(tts::TaggedEventSeries)
    sort(vcat([[Event(tag, e...) for e in ts] for (tag, ts) in tts.data]...), by=x->x.timestamp)
end



function fill_forward(ts::EventSeries, time)
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

fill_forward(tts::TaggedEventSeries, time) = fill_forward(tts, time, sort(collect(keys(tts.data))))
fill_forward(tts::TaggedEventSeries, time, skeys) = Tuple(tag=>fill_forward(tts[tag], time) for tag in skeys)


"""
    fill_forward(ts, time)
    fill_forward(ts, time)

# Argument

Returns a Tuple of TaggedEvent. One for each tag and corresponding fill_forward
Event from each EventSeries contained in the tss TaggedEventSeries.

The Tuple is sorted by tag value.

Returns the most recent Event in the ts EventSeries, with respect to time. If time
is before the first timestamp in ts, then nothing is returned.
"""
