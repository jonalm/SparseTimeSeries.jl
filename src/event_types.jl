
abstract type AbstractEvent{T,U} end

struct Event{T,U} <: AbstractEvent{T,U}
    timestamp::T
    value::U
end

struct TaggedEvent{T,U,V} <: AbstractEvent{U,V}
    tag::T
    timestamp::U
    value::V
end

TaggedEvent(tag, e::Event) = TaggedEvent(tag, e.timestamp, e.value)

@inline tag(e::TaggedEvent) = e.tag
@inline tag(e::Event) = nothing
@inline timestamp(e::AbstractEvent) = e.timestamp
@inline value(e::AbstractEvent) = e.value

Base.show(io::IO, e::Event) = print(io, "timestamp: $(e.timestamp), value: $(e.value)")
Base.show(io::IO, e::TaggedEvent) = print(io, "tag: $(e.tag), timestamp: $(e.timestamp), value: $(e.value)")
