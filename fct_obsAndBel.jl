# Functions related to observations and belief

function update_belief(observation_map,model)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 
    belief_map = zeros(length(observation_map),2)
    previous_obs = 0
    current_obs=0
    for i in 1:length(observation_map)
        if observation_map[i]>-1 
            current_obs = i
            belief_map[i,:]=[observation_map[i],1]
            # back propagate to the left edge
            if previous_obs == 0
                if !(i==1)
                    for j=i-1:1
                    belief_map[j,:]=[observation_map[current_obs],0.5*belief_map[j+1,2]]
                    end
                end
             else
                # associate the closest value 
                if model== "linear"
                    # a few notation shortcuts
                    z_c = observation_map[current_obs]
                    z_p = observation_map[previous_obs]
                    dz_dp = (z_c-z_p)/(current_obs-previous_obs)
                    middle_point = floor(Int,(current_obs-previous_obs)/2)
                    j_max = floor(Int, (current_obs-previous_obs)/6)
                    reste = (current_obs-previous_obs)%6

                    # observations more than 6 cases appart
                    if !(middle_point==0)
                        for j = 1:j_max
                                for i_flat in 1:3
                                    belief_map[previous_obs+3*(j-1)+i_flat,:]=[observation_map[previous_obs]+floor((3*(j-1)+2)*dz_dp),0.5^i_flat*belief_map[previous_obs+3*(j-1),2]]
                                    belief_map[current_obs-3*(j-1)-i_flat,:]=[observation_map[current_obs]-floor((3*(j-1)+2)*dz_dp),0.5^i_flat*belief_map[current_obs-3*(j-1),2]]
                                end   
                        end
                    end

                    # deal with the discontinuity at the middle
                    if !(reste==0)
                        for i_flat in 1:reste
                                belief_map[previous_obs+3*j_max+i_flat,:]=[(z_c+z_p)/2,0.5^middle_point*belief_map[previous_obs+3*j_max,2]]
                        end
                    end

                elseif model=="flat"
                    
                    for j = 1:floor(Int,(current_obs-previous_obs)/2)
                        belief_map[previous_obs+j,:]=[observation_map[previous_obs],0.5*belief_map[previous_obs+j-1,2]]
                        belief_map[current_obs-j,:]=[observation_map[current_obs],0.5*belief_map[current_obs-j+1,2]]
                    end

                    # deal with center anomaly
                    center = floor(Int,(current_obs-previous_obs)/2)
                    if (current_obs-previous_obs)%2==1&!(center==0)
                        belief_map[center+1,:]=[belief_map[center],0.5*belief_map[center,2]]
                    end
                else
                    
                    for j = 1:floor(Int,(current_obs-previous_obs)/2)
                        belief_map[previous_obs+j,:]=[observation_map[previous_obs],0.5*belief_map[previous_obs+j-1,2]]
                        belief_map[current_obs-j,:]=[observation_map[current_obs],0.5*belief_map[current_obs-j+1,2]]
                    end

                    # deal with center anomaly
                    center = floor(Int,(current_obs-previous_obs)/2)
                    if (current_obs-previous_obs)%2==1
                        belief_map[center+1,:]=[belief_map[center],0.5*belief_map[center,2]]
                    end
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