module SparseTimeSeries

export
    Event,
    EventSeries,
    value,
    timestamp,
    fill_forward_event,
    fill_forward_value,
    select,
    align,
    cumtime

include("helpers.jl")
include("event_types.jl")
include("series_types.jl")

end # module
