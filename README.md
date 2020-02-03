# SparseTimeSeries

[![Build Status](https://api.travis-ci.com/jonalm/SparseTimeSeries.jl.svg?branch=master)](https://travis-ci.com/jonalm/SparseTimeSeries.jl)
[![Codecov](https://codecov.io/gh/jonalm/SparseTimeSeries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jonalm/SparseTimeSeries.jl)

This package provides some functionality to handle sparse time series, i.e. series with either (tag, timestamp, values) triplets or (timestamp, value) pairs which typically represents state changes in an arbitrary system. The (potentially tagged) value is considered to be "valid" in the time interval from the recorded timestamp until a new value (with the same tag) is present. In other words, "Forward fill" is assumed to be the natural imputation strategy.

If you are looking for general time series functionality, check out the much more mature
[TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl) package first.


## Example

```julia
julia> y1 = EventSeries(sort(10*rand(5)), rand(5)) # create an EventSeries from a timestamps and a value array
julia> push!(y1, Event(11.0, rand())) # push new value (more recent) to series
julia> y1
6-element EventSeries{Float64,Array{Float64,1},Float64,Array{Float64,1}}:
 timestamp: 0.962481301779119, value: 0.5631153437462539  
 timestamp: 1.053517472778529, value: 0.07833196666367415
 timestamp: 2.4618256389724302, value: 0.37136231074170767
 timestamp: 4.154249968719661, value: 0.4354765986620166  
 timestamp: 5.121409673387845, value: 0.19400449581379076
 timestamp: 11.0, value: 0.5496554897910313               

julia> y2 = EventSeries(0:2:10, ['A','A','A','B','B','C']) # removes repeated values by default
3-element EventSeries{Int64,Array{Int64,1},Char,Array{Char,1}}:
 timestamp: 0, value: A
 timestamp: 6, value: B
 timestamp: 10, value: C

julia> y = TaggedEventSeries()
julia> y[:Random] = y1 # assign EventSeries by setindex!
julia> y[:Characters] = y2
julia> push!(y, TaggedEvent(:Integer, 3.0, 123)) # push value to new tag
julia> push!(y, TaggedEvent(:Random, 12.0, rand())) # push new value (more recent) to existing tag

julia> tagged_events(y) # sorts all events according to time
11-element Array{TaggedEvent{Symbol,U,V} where V where U,1}:
 tag: Characters, timestamp: 0, value: A                               
 tag: Random, timestamp: 0.962481301779119, value: 0.5631153437462539  
 tag: Random, timestamp: 1.053517472778529, value: 0.07833196666367415
 tag: Random, timestamp: 2.4618256389724302, value: 0.37136231074170767
 tag: Integer, timestamp: 3.0, value: 123                              
 tag: Random, timestamp: 4.154249968719661, value: 0.4354765986620166  
 tag: Random, timestamp: 5.121409673387845, value: 0.19400449581379076
 tag: Characters, timestamp: 6, value: B                               
 tag: Characters, timestamp: 10, value: C                              
 tag: Random, timestamp: 11.0, value: 0.5496554897910313               
 tag: Random, timestamp: 12.0, value: 0.449464801332633                

julia> fill_forward(y, 2.0)
(Characters = 'A', Integer = nothing, Random = 0.07833196666367415)

julia> EventSeries(y) # creates an EventSeries where each value is a filled forward named tuple with values for each tag
11-element EventSeries{Real,Array{Real,1},NamedTuple{(:Characters, :Integer, :Random),T} where T<:Tuple,Array{NamedTuple{(:Characters, :Integer, :Random),T} where T<:Tuple,1}}:
 timestamp: 0, value: (Characters = 'A', Integer = nothing, Random = nothing)                             
 timestamp: 0.962481301779119, value: (Characters = 'A', Integer = nothing, Random = 0.5631153437462539)  
 timestamp: 1.053517472778529, value: (Characters = 'A', Integer = nothing, Random = 0.07833196666367415)
 timestamp: 2.4618256389724302, value: (Characters = 'A', Integer = nothing, Random = 0.37136231074170767)
 timestamp: 3.0, value: (Characters = 'A', Integer = 123, Random = 0.37136231074170767)                   
 timestamp: 4.154249968719661, value: (Characters = 'A', Integer = 123, Random = 0.4354765986620166)      
 timestamp: 5.121409673387845, value: (Characters = 'A', Integer = 123, Random = 0.19400449581379076)     
 timestamp: 6, value: (Characters = 'B', Integer = 123, Random = 0.19400449581379076)                     
 timestamp: 10, value: (Characters = 'C', Integer = 123, Random = 0.19400449581379076)                    
 timestamp: 11.0, value: (Characters = 'C', Integer = 123, Random = 0.5496554897910313)                   
 timestamp: 12.0, value: (Characters = 'C', Integer = 123, Random = 0.449464801332633)                    
```
