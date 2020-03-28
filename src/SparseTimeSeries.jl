module SparseTimeSeries
using JSON3

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

JSON3.StructType(::Type{<:Event}) = JSON3.Struct()
JSON3.StructType(::Type{<:Segment}) = JSON3.Struct()
JSON3.StructType(::Type{<:EventSeries}) = JSON3.Struct()

end # module
