module SparseTimeSeries

export
    Event,
    EventSeries,
    TaggedEvent,
    TaggedEventSeries,
    fill_forward,
    events

include("helpers.jl")
include("event_types.jl")
include("series_types.jl")

end # module
