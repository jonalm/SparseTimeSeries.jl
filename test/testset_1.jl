
@testset "test helpers" begin
    @test SparseTimeSeries.neighbors(1:3) |> collect == [(1,2), (2,3)]
    @test SparseTimeSeries.neighbors(['A','B','C']) |> collect == [('A','B'), ('B','C')]
end

@testset "test Event, TaggedEventConstructor" begin
    e = Event(1,2)
    @test SparseTimeSeries.value(e) == 2
    @test SparseTimeSeries.timestamp(e) == 1
    te = SparseTimeSeries.TaggedEvent(:a, 1, 2)
    te_ = SparseTimeSeries.TaggedEvent(:a, e)
    e_ = Event(te_)

    for x in [te,te_, e_]
        @test SparseTimeSeries.value(e) == SparseTimeSeries.value(x)
        @test SparseTimeSeries.timestamp(e) == SparseTimeSeries.timestamp(x)
    end

    @test SparseTimeSeries.tag(e) == nothing
    @test SparseTimeSeries.tag(te) == :a
    @test SparseTimeSeries.tag(te_) == :a
    @test SparseTimeSeries.tag(e_) == nothing
    @test SparseTimeSeries.tag(nothing) == nothing
    @test SparseTimeSeries.timestamp(nothing) == nothing

end

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

    v = ['A','A','A','B','C','C']
    t = 1:length(v)
    y = EventSeries(t,v)
    @test y.values == ['A', 'B', 'C', 'C']

    y = EventSeries(t, v, keep_end=false)
    @test y.values == ['A', 'B', 'C']

    y = EventSeries(t, v, drop_repeated=false)
    @test y.values == ['A','A','A','B','C','C']

    y = EventSeries(t, v, drop_repeated=false, keep_end=false)
    @test y.values == ['A','A','A','B','C','C']
end


@testset "push!, append! and getindex, to EventSeries" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [1, 2, 3, 4]

    ts = EventSeries(copy(time_), values_)
    @test SparseTimeSeries.timestamptype(ts) == Int
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

    @test fill_forward_event(ts, 0.9) == nothing
    @test fill_forward_event(ts, 1) == Event(timestamp=1, value=:a)
    @test fill_forward_event(ts, 4) == Event(timestamp=4, value=2)
    @test fill_forward_event(ts, 5.123) == Event(timestamp=4, value=2)
    @test fill_forward_event(ts, 2) == Event(timestamp=2, value=1.0)
    @test fill_forward_event(ts, 2.5) == Event(timestamp=2, value=1.0)

    @test fill_forward_value(ts, 0.9) == nothing
    @test fill_forward_value(ts, 1) == :a
    @test fill_forward_value(ts, 4) == 2
    @test fill_forward_value(ts, 5.123) == 2
    @test fill_forward_value(ts, 2) == 1.0
    @test fill_forward_value(ts, 2.5) == 1.0
end

@testset  "TaggedEventSeries" begin
    l1 = 'A':'C'
    l2 = 'a':'c'
    t = 1:length(l1)
    y1 = EventSeries(t, l1)
    y2 = EventSeries(t .+ 0.5, l2)
    y = SparseTimeSeries.TaggedEventSeries()
    y[:capital] = y1
    y[:small] = y2
    @test value.(SparseTimeSeries.tagged_events(y)) == ['A', 'a', 'B', 'b','C','c']

    @test value.(EventSeries(y)) == [
    (capital='A', small=nothing),
    (capital='A', small='a'),
    (capital='B', small='a'),
    (capital='B', small='b'),
    (capital='C', small='b'),
    (capital='C', small='c'),
    ]

    ff = fill_forward_event(y, 2)
    @test ff.capital == Event(2, 'B')
    @test ff.small == Event(1.5, 'a')


    ff = fill_forward_value(y, 2)
    @test ff.capital ==  'B'
    @test ff.small ==  'a'

    @test issorted(SparseTimeSeries.timestamps(y))
    tidx = collect(SparseTimeSeries.sorted_tag_idx(y))
    @test length(tidx) == length(y)
    @test length(y) == 3+3
end

@testset  "TaggedEventSeries construct by kwargs" begin
    l1 = 'A':'C'
    l2 = 'a':'c'
    t = 1:length(l1)
    y1 = EventSeries(t, l1)
    y2 = EventSeries(t .+ 0.5, l2)
    y = SparseTimeSeries.TaggedEventSeries(capital=y1, small=y2)

    @test issorted(SparseTimeSeries.timestamps(y))
    tidx = collect(SparseTimeSeries.sorted_tag_idx(y))
    @test length(tidx) == length(y)
    @test length(y) == 3+3
end
