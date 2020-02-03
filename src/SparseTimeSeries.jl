module SparseTimeSeries

export
    Event,
    EventSeries,
    TaggedEvent,
    TaggedEventSeries,
    fill_forward_event,
    fill_forward_value,
    tagged_events_itr,
    tagged_events,
    value,
    timestamp

include("helpers.jl")
include("event_types.jl")

include("series_types.jl")

end # module
