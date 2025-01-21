module UtilityFunctions

using Chain

# Write your package code here.
export
    count_unique, normalise_unique, shuffle!, has_any_nothing_fields, logistic_growth, normalise, dms_to_radians, haversine_distance_with_altitude, generate_bounds_from_vector, compute_index_with_in_bounds, split_camel_case, find_non_zero_indices


function generate_bounds_from_vector(vec)
    @chain vec begin
        cumsum(_)
        [0, _]
        reduce(vcat, _)
        [(a, b) for (a, b) in zip(_[1:end-1], _[2:end])]
    end
end

function compute_index_with_in_bounds(vec::Vector{Int}, element::T) where {T<:Number}
    @chain element begin
        @assert _ ≥ 0 "Scalar value must be greater than zero, it is not."
    end
    @chain vec begin
        @aside @chain _ begin
            @assert element ≤ sum(_) "Vector argument, vec, has a sum = $(sum(_)) which must be greater then the scalar, which is $(element), it is not."
        end
        generate_bounds_from_vector(_)
        findall(x -> element > x[1] && element <= x[2], _)
        @aside @chain _ begin
            @assert length(_) > 0 "Scalar was not found with the tuples outputted from generate_bounds_from_vector. Thus the result is empty."
        end
        @aside @chain _ begin
            @assert length(_) == 1 "Must have 1 element"
        end
        _[1]
    end
end

function split_camel_case(input::String)::String
    return replace(input, r"(?<=[a-z])(?=[A-Z])" => " ")
end

function count_unique(a)
    m, M = extrema(a)
    cu = zeros(Int, M - m + 1)
    for i in eachindex(a)
        cu[a[i]-m+1] += 1
    end
    Pair.(eachindex(cu) .+ m .- 1, cu)
end


function normalise_unique(x)
    cx = count_unique(x)
    firsts = [i.first for i in cx]
    seconded = [i.second for i in cx]
    total = sum(seconded)
    [Pair(firsts[i], seconded[i] / total) for i in eachindex(cx)]

end


function shuffle!(mv)
    n = length(mv)
    (n == 0 || n == 1) && return mv

    for i in reverse(Base.OneTo(n))
        j = rand(1:i)
        mv[i], mv[j] = mv[j], mv[i]
    end
    mv
end

function has_any_nothing_fields(obj)
    any([field === nothing for field in getfield.(Ref(obj), fieldnames(typeof(obj)))])
end



function logistic_growth(carrying_capacity, initial_population, growth_rate, time)
    carrying_capacity / (1 + ((carrying_capacity - initial_population) / (initial_population)) * exp(-growth_rate * time))
end

normalise(x) = (x .- minimum(x)) ./ (maximum(x) .- minimum(x))



function dms_to_radians(coord::String)
    # Extract degrees, minutes, seconds, and direction using regular expressions
    regex = r"(\d+)°(\d+)'([\d.]+)\"([NSWE])"
    caps = match(regex, coord)

    if caps === nothing
        error("Invalid format. Expected format: 26°49'50.2\"S")
    end

    # Parse the components
    degrees = parse(Int, caps[1])
    minutes = parse(Int, caps[2])
    seconds = parse(Float64, caps[3])
    direction = caps[4]

    # Convert DMS to decimal degrees
    decimal_degrees = degrees + minutes / 60 + seconds / 3600

    # Apply the sign based on direction (S or W should be negative)
    if direction in ["S", "W"]
        decimal_degrees = -decimal_degrees
    end

    # Convert decimal degrees to radians
    radians = decimal_degrees * π / 180

    return radians
end


function haversine_distance_with_altitude(lat1::Float64, lon1::Float64, h1::Float64, lat2::Float64, lon2::Float64, h2::Float64)
    # Convert degrees to radians
    φ1 = lat1 * π / 180
    φ2 = lat2 * π / 180
    Δφ = (lat2 - lat1) * π / 180
    Δλ = (lon2 - lon1) * π / 180

    # Earth's radius in meters
    R = 6371000.0

    # Haversine formula for the horizontal distance
    a = sin(Δφ / 2)^2 + cos(φ1) * cos(φ2) * sin(Δλ / 2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))
    d_horizontal = R * c

    # Calculate altitude difference
    Δh = h2 - h1

    # Calculate 3D distance
    d_3D = sqrt(d_horizontal^2 + Δh^2)

    return d_3D
end


#= Example usage

el_manantial = ("26°49'50.2\"S","65°16'59.4\"W")
la_virginia =  ("26°45'07.8\"S","65°47'43.7\"W")

rads_el_man = dms_to_radians.(el_manantial)
rads_la_vir = dms_to_radians.(la_virginia)  

haversine_distance_with_altitude(rads_el_man..., 495.0, rads_la_vir...,398.0)
=#
# Find the indices of a Float64 vector that are nonzero
function find_non_zero_indices(vec::Vector{Float64}; tol=1e-8)
    if isempty(vec)
        @warn "Vector, `vec` is empty"
        return
    end
    if all(iszero.(vec))
        @warn "Vector `vec` is all zero"
        return
    end


    while !(any(tol .< vec))
        @warn "No value of vec is greater than tol ($(tol)), dividing by 10 and trying again"
        tol /= 10
    end
    outcome = findall(x -> tol < x, vec)
    if length(outcome) == 0
        @warn "No value of vec was greater than tolerance"
        return
    end
    outcome

end
end


















