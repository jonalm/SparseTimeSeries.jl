using SparseTimeSeries
using Test

@testset "constructing EventSeries" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [1, 2, 3, 4]

    ts = EventSeries(time_, values_)
    @test ts.timestamps === time_
    @test ts.values === values_

    # not equal lenght of input
    @test_throws AssertionError EventSeries([1, 2, 3], values_)

    # not sorted times
    @test_throws AssertionError EventSeries([1, 2, 3, -1], values_)

    # TrustInput avoids assertions
    time_ = [1, 2, -1]
    @test EventSeries(time_, values_, SparseTimeSeries.TrustInput()).timestamps === time_

    # Equal times works
    @test EventSeries(ones(4), values_).timestamps == ones(4)

end

@testset "push!, append! and getindex, to EventSeries" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [1, 2, 3, 4]

    ts = EventSeries(copy(time_), values_)
    @test ts[3] == Event(timestamp=3, value="hello")

    # decreasing timestep
    @test_throws AssertionError push!(ts, Event(3, 3))

    # errs when pushing incopatible time type
    let err = nothing
        try
             push!(ts, Event(31.2, 3))
        catch err
        end
        @test err isa Exception
    end

    t, v =  6, :foo
    push!(ts, Event(t,v))
    @test last(ts.timestamps) == t
    @test last(ts.values) == v

    ts2 = EventSeries(collect(6:8), rand(3))
    append!(ts, ts2)
    @test ts.timestamps == [time_; [t];  6:8]

    ts3 = ts[end-2:end]
    @test ts3.timestamps == ts2.timestamps

    # setindex should throw error
    @test_throws ErrorException ts3[3] = :b
end

@testset "fill forward EventSeries" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [1, 2, 3, 4]
    ts = EventSeries(copy(time_), values_)

    @test fill_forward(ts, 0.9) == nothing
    @test fill_forward(ts, 1) == Event(timestamp=1, value=:a)
    @test fill_forward(ts, 4) == Event(timestamp=4, value=2)
    @test fill_forward(ts, 5.123) == Event(timestamp=4, value=2)
    @test fill_forward(ts, 2) == Event(timestamp=2, value=1.0)
    @test fill_forward(ts, 2.5) == Event(timestamp=2, value=1.0)
end
