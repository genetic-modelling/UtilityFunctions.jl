module UtilityFunctions

# Write your package code here.
export 
    count_unique, normalise_unique, shuffle!, has_any_nothing_fields, logistic_growth, normalise


    
    function count_unique(a)
        m,M=extrema(a)
        cu=zeros(Int,M-m+1)
        for i in eachindex(a)
            cu[a[i]-m+1]+=1
        end
        Pair.(eachindex(cu).+m.-1, cu)
    end


    function normalise_unique(x)
        cx = count_unique(x)
        firsts = [i.first for i in cx]
        seconded = [i.second for i in cx]
        total = sum(seconded)
        [Pair(firsts[i],seconded[i]/total) for i in eachindex(cx)]

    end


    function shuffle!(mv) 
        n = length(mv)
        (n == 0 || n == 1) && return mv
        
        for i in reverse(Base.OneTo(n))
            j = rand(1:i)
            mv[i],mv[j] = mv[j],mv[i]
        end
        mv
    end

    function has_any_nothing_fields(obj)
        any([field === nothing for field in getfield.(Ref(obj), fieldnames(typeof(obj)))])
    end



    function logistic_growth(carrying_capacity,initial_population,growth_rate,time)
        carrying_capacity / (1 + ((carrying_capacity - initial_population)/(initial_population)) * exp(-growth_rate * time))
    end

    normalise(x) = (x .- minimum(x)) ./ (maximum(x) .- minimum(x))


end
