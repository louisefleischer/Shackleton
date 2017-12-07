function build_map()
    true_map=zeros(100)
    true_map[1]=rand(1:25)
    for ii=2:100
        rnumb=rand(1:7)
        if rnumb<=2
            true_map[ii]=true_map[ii-1]
        elseif rnumb<=4
            true_map[ii]=true_map[ii-1]+1
        elseif rnumb<=6
            true_map[ii]=max(1,true_map[ii-1]-1)
        else
            true_map[ii]=rand(1:25)
        end
    end
    return true_map
end