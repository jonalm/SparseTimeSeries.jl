# SparseTimeSeries

[![Build Status](https://api.travis-ci.com/jonalm/SparseTimeSeries.jl.svg?branch=master)](https://travis-ci.com/jonalm/SparseTimeSeries.jl)
[![Codecov](https://codecov.io/gh/jonalm/SparseTimeSeries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jonalm/SparseTimeSeries.jl)

If you are looking for general time series functionality, check out the much more mature
[TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl) package first.

## Functionality overview

The package supports, `value` of arbitrary type and any `timestamp` which can be sorted.

The  key data types are the `Event`, which wraps a (timestamp, value) pair;
the `Segment` which wraps a (time start, time end, value) triplet;
the `EventSeries` (subtype of `AbstracVector`), which holds the time series.

The `EventSeries` has, in addition to the standard `AbstracVector` interface, the following methods:

- `align(::EventSeries...)` returns a tuple of `EventSeries` containing subsets of the corresponding series   input, such that the time domain of each output series corresponds to the largest common time domain of the input series. (See `select` below.)
- `cumtime(::EventSeries, value)` returns the cumulative time for which the series takes the input `value`.
- `fill_forward_event(::EventSeries, time)` returns the most recent `Event` prior to input `time`.
- `fill_forward_value(::EventSeries, time)` returns the most recent `value` prior to input `time`.
- `fuse(;named_eventseries)` returns a new a new `EventSeries` with time sorted `Event`s for each timestamp in the input series, where the values are named tuples containing the fill forward value of all input time series.
- `segments(events)` returns an iterator over all `Segement`s defined by consecutive `Event`s in the input.
- `select(::EventSeries, tstart, tend)` returns an `EventSeries` which is a subset of the input series, containing the `Events` in the time domain `[tstart, tend]`. The endpoint values are set by filling forward.
- `splice(;named_eventseries...)` returns a new a new `EventSeries` with time sorted `Event`s for each timestamp in the input series, where the values are values are name-value pairs.
