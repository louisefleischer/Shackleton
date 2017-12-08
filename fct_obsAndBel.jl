# Functions related to observations and belief

function update_belief(observation_map)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 
    belief_map = zeros(length(observation_map),2)
    previous_obs = 0
    for i in 1:length(observation_map)
        if observation_map[i]>-1 
            current_obs = i
            # back propagate to the left edge
            if previous_obs == 0
                for j=i-1:1
                belief_map[j,:]=[observation_map[i],0.5*belief_map[j+1,2]]
                end
             else
                # associate the closest value ! what if not even
                for j = 1:floor((current_obs-previous_obs)/2)
                    belief_map[previous_obs+j,:]=[observation_map[previous_obs],0.5*belief_map[previous_obs+j,1]]
                    belief_map[current_obs-j,:]=[observation_map[current_obs],0.5*belief_map[current_obs+j,1]]
                end
             end
             previous_obs = i 
        end             
    end

    # forward propagation to the right edge
    for j = current_obs+1:length(observation_map)
        belief_map[j,:]= belief_map[current_obs,0.5*belief_map[j-1,2]]
    end
    return belief_map
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