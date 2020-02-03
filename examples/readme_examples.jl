using Revise
using SparseTimeSeries

y1 = EventSeries(range(0, step=0.1, length=5) |> collect, rand(1:100, 5)) # create an EventSeries from a timestamps and a value array

##

y2 = EventSeries(range(0, step=0.05, length=6), ['A','A','A','B','B','C']) # removes repeated values by default

##

y = TaggedEventSeries()
y[:Rand] = y1 # assign EventSeries by setindex!
y[:Char] = y2
push!(y, TaggedEvent(:Int, 3.0, 123)) # push value to new tag
push!(y, TaggedEvent(:Char, 10.0, 'D')) # push new value (more recent) to existing tag

tagged_events(y) # sorts all events according to time

##

fill_forward_event(y, 2.0)

##

fill_forward_value(y, 5.0)

##
EventSeries(y)
