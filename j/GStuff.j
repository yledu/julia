function compareFunctions(fun1, fun2,start,en)
    for i = start:en
        x = rand(i,i)
        println("fun1 ", @time fun1(x), "func2 ", @time fun2(x))
    end
end



function countoff(x)
    for i = 1:numel(x)
        x[i] = i
    end
    x
end

let _tranpose_ = nothing
    global transpose2
    
    function transpose_one(x,p,hidis,lendis,hilen,lenlen)
        #println("hidis $hidis,lendis $lendis, hilen $hilen, lenlen $lenlen")
        for i = hidis:hilen+hidis-1
            for j = lendis:lenlen+lendis-1
                p[j,i] = x[i,j]
            end
        end
    end

    function transpose2(x::AbstractMatrix)
        s = size(x)
        p = zeros(s[2],s[1])
        #TODO
        ##calculate actual maxlen
        maxlen = 64
        transpose_helper(p,x, 1,1, size(x)..., maxlen)
        p
    end

    function transpose_helper(p, x, hidis,lendis, hilen, lenlen, maxlen)
        if ( hilen <= maxlen && lenlen <= maxlen)
            transpose_one(x,p,hidis,lendis,hilen,lenlen)
        elseif (hilen < lenlen)
            transpose_helper(p, x, hidis, lendis, hilen, div(lenlen,2),maxlen)
            transpose_helper(p, x, hidis, lendis+div(lenlen,2), hilen, lenlen-div(lenlen,2), maxlen)
        else
            transpose_helper(p, x, hidis, lendis, div(hilen,2) ,lenlen, maxlen) 
            transpose_helper(p, x, hidis+div(hilen,2), lendis, hilen-div(hilen,2), lenlen,maxlen)
        end
    end

end










let permute2_cache = nothing
global permute2
function permute2(A::AbstractArray, perm)
    dimsA = size(A)
    ndimsA = length(dimsA)
    dimsP = ntuple(ndimsA, i->dimsA[perm[i]])
    P = similar(A, dimsP)
    ranges = ntuple(ndimsA, i->(Range1(1,dimsP[i])))

    strides = Array(Int32,0)
    for dim = 1:length(perm)
        stride = 1
        for dim_size = 1:(dim-1)
            stride = stride*dimsA[dim_size]
        end
        push(strides, stride)
    end

    #must create offset, because indexing starts at 1
    offset = 0
    for i = strides
    offset+=i
    end
    offset = 1-offset

    function permute2_one(ivars)
        s = { (x = ivars[i]; quote total+= $x*(strides[perm[$i]]) end) | i = 1:ndimsA}
    quote
        total=offset
        $(s...)
        #println(total)
        P[count] = A[total]
        count+=1
    end
    end

    if is(permute2_cache,nothing)
    permute2_cache = HashTable()
    end

    gen_cartesian_map(permute2_cache, permute2_one, ranges, {:A, :P, :perm, :count, :strides, :offset}, A, P, perm,1, strides, offset)
    return P
end
#end let
end