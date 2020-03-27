
@testset  "select" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [0, 2, 3, 5]

    ts = EventSeries(time_, values_)

    ts1 = select(ts, 0, 5)
    @test ts1.timestamps == time_
    @test ts1.values == values_

    ts2 = select(ts, 1, 4)
    @test ts2.timestamps == [1, 2, 3, 4]
    @test ts2.values ==  [:a, 1.0, "hello", "hello"]

    ts3 = select(ts, 0, 4)
    @test ts3.timestamps == [0, 2, 3, 4]
    @test ts3.values ==  [:a, 1.0, "hello", "hello"]

    ts4 = select(ts, 2, 5)
    @test ts4.timestamps == [2, 3, 5]
    @test ts4.values ==  [1.0, "hello", 2]

    @test_throws AssertionError select(ts, -1, 4)
    @test_throws AssertionError select(ts, 1, 10)
    @test_throws AssertionError select(ts, -1, 10)


    values_ = [:a, :b]
    time_ = [0, 10]
    ts = EventSeries(time_, values_)
    ts5 = select(ts, 1,2)
    @test ts5.timestamps == [1,2]
    @test ts5.values ==  [:a, :a]
end

@testset  "align" begin
    t1_ = [0, 2, 4]
    v1_ = [1, 4, 5]

    t2_ = [1, 2, 3]
    v2_ = [4, 3, 6]

    ts1 = EventSeries(t1_, v1_)
    ts2 = EventSeries(t2_, v2_)

    ts1_, = align(ts1)
    @test ts1_.values == ts1.values
    @test ts1_.timestamps == ts1.timestamps

    ts1_, ts2_ = align(ts1, ts2)

    @test ts1_.timestamps == [1,2,3]
    @test ts1_.values == [1,4,4]

    @test ts2_.timestamps == [1,2,3]
    @test ts2_.values == v2_
end


@testset  "cumtime" begin
    t_ = 1:10 |> collect
    v_ = repeat([1,2], 5)
    ts = EventSeries(t_, v_)
    @test cumtime(ts, 1) == 5
    @test cumtime(ts, 2) == 4 # integration stops at last time stamp
end

@testset  "fuse and splice" begin
    t1 = [1,3,5]
    v1 = ['A', 'B', 'C']
    ts1 = EventSeries(t1, v1)

    t2 = [2,4,6]
    v2 = ['a', 'b', 'c']
    ts2 = EventSeries(t2, v2)

    ts3 = fuse(x=ts1, y=ts2)
    ts4 = splice(x=ts1, y=ts2)

    @test ts3.timestamps == sort([t1; t2])
    @test ts4.timestamps == sort([t1; t2])

    @test ts3.values == [(x = 'A', y = nothing)
                         (x = 'A', y = 'a')
                         (x = 'B', y = 'a')
                         (x = 'B', y = 'b')
                         (x = 'C', y = 'b')
                         (x = 'C', y = 'c')]

    @test ts4.values == [:x => 'A',
                         :y => 'a',
                         :x => 'B',
                         :y => 'b',
                         :x => 'C',
                         :y => 'c']
end

@testset  "segments" begin
    t = [1, 3, 5]
    v = ['A', 'B', 'C']
    ts = EventSeries(t, v)
    @test collect(segments(ts)) == [Segment(1,3,'A'), Segment(3,5,'B')]
end


@testset  "filter" begin
    t = [1, 3, 5]
    v = ['A', 'B', 'C']
    ts = EventSeries(t, v)
    ts2 = filter(x->x.value!='C', ts)
    @test ts2.values == ['A', 'B']
    @test ts2.timestamps == [1, 3]

end
