module SparseTimeSeries

export
    Event,
    Segment,
    EventSeries,
    timestamp,
    value,
    align,
    cumtime,
    fill_forward_event,
    fill_forward_value,
    fuse,
    segments,
    select,
    splice

include("helpers.jl")
include("event_types.jl")
include("segment_types.jl")
include("series_types.jl")

end # module
