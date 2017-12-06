using PyPlot

mutable struct Lander
         x::Int
         z::Int
end

mutable struct Observation
    x
    h
end
y = collect(linspace(1,100,(100-38)))
true_map = vcat([1, 2, 3, 3, 3, 4, 5, 6, 6, 5, 4, 3, 2, 1, 1, 1, 2, 3, 4, 5, 6, 5, 4, 6, 10, 11, 15, 22, 30, 30, 32, 31, 25, 20, 15, 1,1, 1],y)

#true_map = collect(linspace(1,50,100))

# Initialize
# Lander is at altitude 100, terrain is set to zero altitude, its bounds are from zero to 50 m high. 
lander= Lander(50,50)
observation_map = zeros(100,1)-1 #if no observation, set to -1
belief_map = zeros(100,1)
x_path = [lander.x]
z_path = [lander.z]

function update_belief(observation_map,belief_map)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 
    # DEFINITELY A WAY TO IMPROVE!
    for i in 1:length(observation_map)
        if observation_map[i]>-1
            belief_map[i]=observation_map[i]
        end
    end
    return belief_map
end

function find_flat(belief_map)
    # finds the indices of the three equal heights
    temp = diff(belief_map)
    i1_zero = find(iszero,temp)+1
    temp = diff(temp)
    i2_zero = find(iszero,temp)+1
    println(i1_zero)
    println(i2_zero)
    index = findin(i2_zero,i1_zero)
    println("same numbers: ",i2_zero[index])
    return i2_zero[index]
end

function make_observation(true_map, lander)
    # returns the new value of observation
    x = [ lander.x-div(lander.z,2); lander.x; lander.x + div(lander.z,2)]
    h = true_map[x]
    o = Observation(x,h)
end

function take_action(flat_place, lander)
    # returns the next action
    #find closest one
    (A,i_min) = findmin(abs.(flat_place-lander.x))

    action = sign(flat_place[i_min]-lander.x);
    println("action: ",action)
    return action
end

while lander.z>(true_map[lander.x])
    println("lander x: ",lander.x, " z: ",lander.z)

o = make_observation(true_map, lander)
observation_map[o.x] = o.h


belief_map = update_belief(observation_map, belief_map)
belief_map = true_map
# here if we had some probabilities we would look for the best path 
flat = find_flat(belief_map)
lander.x = lander.x + take_action(flat, lander)
lander.z -= 1
x_path = push!([lander.x])
z_path = push!([lander.z])
end 

print(lander.x)

plot(x_path,z_path)
