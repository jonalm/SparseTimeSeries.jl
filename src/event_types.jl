
abstract type AbstractEvent{T,U} end


"""
    Event{T,U} <: AbstractEvent{T,U}

Wraps a timestamp and value pair, of arbitrary type.

# Constructor
    Event(timestamp, value)
    Event(e::TaggedEvent)

see `TaggedEvent`.
"""
struct Event{T,U} <: AbstractEvent{T,U}
    timestamp::T
    value::U
end

Event(;timestamp, value) = Event(timestamp, value)

"""
    TaggedEvent{T,U,V} <: AbstractEvent{U,V}

Wraps a tag, timestamp and value triplet, of arbitrary type.

# Constructor
    TaggedEvent(tag, timestamp, value)
    TaggedEvent(tag, event::Event)

See `Event`.
"""
struct TaggedEvent{T,U} <: AbstractEvent{T,U}
    tag::Symbol
    timestamp::T
    value::U
end

TaggedEvent(tag, e::Event) = TaggedEvent(tag, e.timestamp, e.value)
Event(e::TaggedEvent) =  Event(e.timestamp, e.value)

@inline tag(e::TaggedEvent) = e.tag
@inline tag(e::Event) = nothing
@inline tag(e::Nothing) = nothing
@inline timestamp(e::AbstractEvent) = e.timestamp
@inline timestamp(e::Nothing) = nothing
@inline value(e::AbstractEvent) = e.value
@inline value(e::Nothing) = nothing

Base.show(io::IO, e::Event) = print(io, "{timest.: $(e.timestamp), value: $(e.value)}")
Base.show(io::IO, e::TaggedEvent) = print(io, "{tag: $(e.tag), timest.: $(e.timestamp), value: $(e.value)}")
