# Functions related to the map

function build_map(max_height)
    true_map=zeros(100)
    true_map[1]=rand(1:max_height)
    for ii=2:100
        rnumb=rand(1:10)
        if rnumb<=3
            true_map[ii]=true_map[ii-1]
        elseif rnumb<=5
            true_map[ii]=min(true_map[ii-1]+1,max_height)
        elseif rnumb<=6
            true_map[ii]=min(true_map[ii-1]+2,max_height)
        elseif rnumb<=8
            true_map[ii]=max(1,true_map[ii-1]-1)
        elseif rnumb<=9
            true_map[ii]=max(1,true_map[ii-1]-2)
        else
            true_map[ii]=rand(1:max_height)
        end
    end
    return true_map
end