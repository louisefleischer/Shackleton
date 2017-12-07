#using PyPlot

mutable struct Lander
 x::Int
 z::Int
end

mutable struct Observation
    x
    h
end



MAP_SIZE = 100
true_map = vcat([1, 2, 3, 3, 3, 4, 5, 6, 6, 5],
    collect(linspace(1,50,(100-38))),
    [4, 3, 2, 1, 1, 1, 2, 3, 4, 5, 6, 5, 4, 6, 10, 11, 15, 22, 30, 30, 32, 31, 25, 20, 15, 1,1, 1])

#true_map = collect(linspace(1,50,100))

# Initialize
# Lander is at altitude 100, terrain is set to zero altitude, its bounds are from zero to 50 m high. 
lander= Lander(50,50)
#observation_map = zeros(MAP_SIZE,1)-1 #if no observation, set to -1
old_observations = zeros(MAP_SIZE,2)

# build a belief map with heights and a confidence value
belief_map = zeros(MAP_SIZE,2)
x_path = [lander.x]
z_path = [lander.z]

function update_belief(observation_map,old_observations, new_observation, belief_map)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 

<<<<<<< HEAD
    belief_map[new_observation[:,1],:]=[new_observation[:,2],1]


    # for i in 1:length(observation_map)
    #     if observation_map[i]>-1
    #         belief_map[i,:]=[observation_map[i],1]

    #     else
    #         # find the closest observation point and take that value
    #         j = 1
    #         while j+i<MAP_SIZE&i-j>MAP_SIZE
    #             if observation_map[i-j]!=-1
    #                 belief_map[i,1]=observation_map[i-j]

    #         end
    #         belief_map[i,1]= observation_map[j]    
            
    #     end
    # end
    return belief_map
=======
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
>>>>>>> 838866cb5aaf708c716872129cac2bd893eb88d0
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
    x = [lander.x-div(lander.z,2); lander.x; lander.x + div(lander.z,2)]
    h = true_map[x]
    o = Observation(x,h)
end

function compute_reward(obs,lander,action)
    # backpropagation of rewards
end
function U_ground(belief_map,x)
    # Calculate utility of potential landing site
end
function update_utility(belief_map,lander)
    #Update utility map from bottom to top
end
function take_action(flat_place, lander)
    # returns the next action
    #find closest one
    (A,i_min) = findmin(abs.(flat_place-lander.x))
    action = sign(flat_place[i_min]-lander.x);
    return action
end

iteration = 0
while lander.z>(true_map[lander.x])

<<<<<<< HEAD
if iteration%3=0
# observe
o = make_observation(true_map, lander)
observation_map[o.x] = o.h
new_observation = [o.x,o.h]

# update your belief
belief_map = update_belief(observation_map, old_observations, new_observation, belief_map)
belief_map = true_map
old_observations = vcat(old_observations;new_observation)
end
=======
    # observe
    o = make_observation(true_map, lander)
    observation_map[o.x] = o.h

    # update your belief
    belief_map = update_belief(observation_map, belief_map)
    belief_map = true_map
>>>>>>> 838866cb5aaf708c716872129cac2bd893eb88d0

    # find flat parts in the belief map 
    flat = find_flat(belief_map)

<<<<<<< HEAD
# make your decision
lander.x = lander.x + take_action(flat, lander)



lander.z -= 1
=======
    # make your decision
    lander.x = lander.x + take_action(flat, lander)
    lander.z -= 1
>>>>>>> 838866cb5aaf708c716872129cac2bd893eb88d0

    # keep in memory for plotting
    x_path = hcat(x_path,[lander.x])
    z_path = hcat(z_path,[lander.z])
end 

println("The lander has arrived at x=",lander.x," and z=", lander.z)

#    hold(true)
#    plot(x_path',z_path')
#    plot(collect(1:MAP_SIZE), true_map)