
"""
    neighbors(vec::AbstractVector)

Returns an iterator over neighboring pairs.
```julia
julia> neighbors([1,2,3]) |> collect
2-element Array{Tuple{Int64,Int64},1}:
 (1, 2)
 (2, 3)
 ```
 """
function neighbors(itr::AbstractVector)
    first  = @view itr[1:end-1]
    second = @view itr[2:end]
    zip(first, second)
end
