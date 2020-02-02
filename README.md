# SparseTimeSeries

[![Build Status](https://api.travis-ci.com/jonalm/SparseTimeSeries.jl.svg?branch=master)](https://travis-ci.com/jonalm/SparseTimeSeries.jl)
[![Codecov](https://codecov.io/gh/jonalm/SparseTimeSeries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jonalm/SparseTimeSeries.jl)

This package provides some functionality to handle sparse time series, i.e. series with either (tag, timestamp, values) triplets or (timestamp, value) pairs which typically represents state changes in an arbitrary system. The (potentially tagged) value is considered to be "valid" in the time interval from the recorded timestamp until a new value (with the same tag) is present. In other words, "Forward fill" is assumed to be the natural imputation strategy.

If you are looking for general time series functionality, check out the much more mature
[TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl) package first.
