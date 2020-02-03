# SparseTimeSeries

[![Build Status](https://api.travis-ci.com/jonalm/SparseTimeSeries.jl.svg?branch=master)](https://travis-ci.com/jonalm/SparseTimeSeries.jl)
[![Codecov](https://codecov.io/gh/jonalm/SparseTimeSeries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jonalm/SparseTimeSeries.jl)

This package provides some functionality to handle sparse time series, i.e. series with either {tag, timestamp, value} triplets or {timestamp, value} pairs which typically represents state changes in an arbitrary system. The (potentially tagged) value is considered to be "valid" in the time interval from the recorded timestamp until a new value (with the same tag) is present. In other words, "Forward fill" is the natural imputation strategy.

If you are looking for general time series functionality, check out the much more mature
[TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl) package first.


## Example

```julia
julia> y1 = EventSeries(range(0, step=0.1, length=5) |> collect, rand(1:100, 5)) # create an EventSeries from a timestamps and a value array
5-element EventSeries{Float64,Array{Float64,1},Int64,Array{Int64,1}}:
 {timest.: 0.0, value: 53}
 {timest.: 0.1, value: 23}
 {timest.: 0.2, value: 37}
 {timest.: 0.3, value: 61}
 {timest.: 0.4, value: 34}

julia> y2 = EventSeries(range(0, step=0.05, length=6), ['A','A','A','B','B','C']) # removes repeated values by default
3-element EventSeries{Float64,Array{Float64,1},Char,Array{Char,1}}:
 {timest.: 0.0, value: A}
 {timest.: 0.15, value: B}
 {timest.: 0.25, value: C}


julia> y = TaggedEventSeries()
julia> y[:Rand] = y1 # assign EventSeries by setindex!
julia> y[:Char] = y2
julia> push!(y, TaggedEvent(:Int, 3.0, 123)) # push value to new tag
julia> push!(y, TaggedEvent(:Char, 10.0, 'D')) # push new value (more recent) to existing tag
julia> tagged_events(y) # sorts all events according to time
10-element Array{TaggedEvent{Float64,U} where U,1}:
 {tag: Char, timest.: 0.0, value: A}
 {tag: Rand, timest.: 0.0, value: 53}
 {tag: Rand, timest.: 0.1, value: 23}
 {tag: Char, timest.: 0.15, value: B}
 {tag: Rand, timest.: 0.2, value: 37}
 {tag: Char, timest.: 0.25, value: C}
 {tag: Rand, timest.: 0.3, value: 61}
 {tag: Rand, timest.: 0.4, value: 34}
 {tag: Int, timest.: 3.0, value: 123}
 {tag: Char, timest.: 10.0, value: D}

 julia> fill_forward_event(y, 2.0)
 (Char = {timest.: 0.25, value: C}, Int = nothing, Rand = {timest.: 0.4, value: 34})

 julia> fill_forward_value(y, 5.0)
 (Char = 'C', Int = 123, Rand = 34)
 
julia> EventSeries(y) # creates an EventSeries where each value is a filled forward named tuple with values for each tag
9-element EventSeries{Float64,Array{Float64,1},NamedTuple{(:Char, :Int, :Rand),T} where T<:Tuple,Array{NamedTuple{(:Char, :Int, :Rand),T} where T<:Tuple,1}}:
 {timest.: 0.0, value: (Char = 'A', Int = nothing, Rand = 53)}
 {timest.: 0.1, value: (Char = 'A', Int = nothing, Rand = 23)}
 {timest.: 0.15, value: (Char = 'B', Int = nothing, Rand = 23)}
 {timest.: 0.2, value: (Char = 'B', Int = nothing, Rand = 37)}
 {timest.: 0.25, value: (Char = 'C', Int = nothing, Rand = 37)}
 {timest.: 0.3, value: (Char = 'C', Int = nothing, Rand = 61)}
 {timest.: 0.4, value: (Char = 'C', Int = nothing, Rand = 34)}
 {timest.: 3.0, value: (Char = 'C', Int = 123, Rand = 34)}     
 {timest.: 10.0, value: (Char = 'D', Int = 123, Rand = 34)}
```
