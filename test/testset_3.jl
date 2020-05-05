
@testset "previous" begin
    t = [0, 2, 4]
    v = ['a', 'b', 'c']
    ts = EventSeries(t, v)

    @test previous(ts, -10) == nothing
    @test previous(ts, 0) == nothing
    @test previous(ts, 1) == Event(timestamp=0, value='a')
    @test previous(ts, 1, include_boundary=true) == Event(timestamp=0, value='a')
    @test previous(ts, 0, include_boundary=true) == Event(timestamp=0, value='a')
    @test previous(ts, 2) == Event(timestamp=0, value='a')
    @test previous(ts, 2, include_boundary=true) == Event(timestamp=2, value='b')
    @test previous(ts, 10) ==  Event(timestamp=4, value='c')
    @test previous(ts, 10, include_boundary=true) == Event(timestamp=4, value='c')
end

@testset "next" begin
    t = [0, 2, 4]
    v = ['a', 'b', 'c']
    ts = EventSeries(t, v)

    @test next(ts, 0) == Event(timestamp=2,value='b')
    @test next(ts, 0, include_boundary=true) == Event(timestamp=0,value='a')
    @test next(ts, 1) == Event(timestamp=2, value='b')
    @test next(ts, 1, include_boundary=true) == Event(timestamp=2, value='b')
    @test next(ts, 2, include_boundary=true) == Event(timestamp=2, value='b')
    @test next(ts, 2) == Event(timestamp=4, value='c')
    @test next(ts, 10) == nothing
    @test next(ts, 10, include_boundary=true) == nothing
end
