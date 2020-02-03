using SparseTimeSeries

y1 = EventSeries(sort(10*rand(5)), rand(5)) # create an EventSeries from a timestamps and a value array
push!(y1, Event(11.0, rand())) # push new value (more recent) to series
y1

##

y2 = EventSeries(0:2:10, ['A','A','A','B','B','C']) # removes repeated values by default

##

y = TaggedEventSeries()
y[:Random] = y1 # assign EventSeries by setindex!
y[:Characters] = y2
push!(y, TaggedEvent(:Integer, 3.0, 123)) # push value to new tag
push!(y, TaggedEvent(:Random, 12.0, rand())) # push new value (more recent) to existing tag
tagged_events(y) # sorts all events according to time

##

fill_forward(y, 2.0)

##

EventSeries(y)
