# Functions related to observations and belief

function update_belief(observation_map,old_observations, new_observation, belief_map)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 

    observation_point = 0
    for i in 1:length(observation_map)
        if observation_map[i]>-1
            belief_map[i,:]=[observation_map[i],1]
            
        else
            # find the closest observation point and take that value
            j = 1
            while j+i<MAP_SIZE&i-j>MAP_SIZE
                if observation_map[i-j]!=-1
                    belief_map[i,1]=observation_map[i-j]

                end
                belief_map[i]= observation_map[j]    

            end
        end
        return belief_map
    end
end

function find_flat(belief_map)
    # finds the indices of the three equal heights
    temp = diff(belief_map)
    i1_zero = find(iszero,temp)+1
    temp = diff(temp)
    i2_zero = find(iszero,temp)+1
    index = findin(i2_zero,i1_zero)
    return i2_zero[index]
end

function make_observation(true_map, lander)
    # returns the new value of observation
    x = [max(1,lander.x-div(lander.z,2)); lander.x; min(lander.x + div(lander.z,2),100)]
    h = true_map[x]
    o = Observation(x,h)
end