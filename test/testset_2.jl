
@testset  "prune" begin
    values_ = [:a, 1.0, "hello", 2]
    time_ = [0, 2, 3, 5]

    ts = EventSeries(time_, values_)

    ts1 = prune(ts, 0, 5)
    @test ts1.timestamps == time_
    @test ts1.values == values_

    ts2 = prune(ts, 1, 4)
    @test ts2.timestamps == [1, 2, 3, 4]
    @test ts2.values ==  [:a, 1.0, "hello", "hello"]

    ts3 = prune(ts, 0, 4)
    @test ts3.timestamps == [0, 2, 3, 4]
    @test ts3.values ==  [:a, 1.0, "hello", "hello"]

    ts4 = prune(ts, 2, 5)
    @test ts4.timestamps == [2, 3, 5]
    @test ts4.values ==  [1.0, "hello", 2]

    @test_throws AssertionError prune(ts, -1, 4)
    @test_throws AssertionError prune(ts, 1, 10)
    @test_throws AssertionError prune(ts, -1, 10)


    values_ = [:a, :b]
    time_ = [0, 10]
    ts = EventSeries(time_, values_)
    ts5 = prune(ts, 1,2)
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