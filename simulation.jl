
true_map = [[1:3];[3;3;3];[3:10];[40:50];[50;50];[50:15]];

# Initialize
# Lander is at altitude 100, terrain is set to zero altitude, its bounds are from zero to 50 m high. 

lander.x = 50
#lander.y = 0
lander.z = 100

observation_map = Array{Float64,100,1}
belief_map = zeros(100,1)

function update_belief(observation_map)
    # updates the belief_map based on the new observations made
    # aferwards it will be probability map 
end

function find_flat(belief_map)
    # finds the 3 cases terrains
end

function make_observation(true_map, position)
    # returns the new value of observation
    o.x = [ position.x-position.z; position.x; position.x + position.z]
    o.h = true_map[o.x]
end

function take_action(flat_place, position)
    # returns the next action
    #find closest one
    action = -1;
    return action
end

while lander.z>(true_map[lander.x])
    o = make_observation(true_map, position)
    observation_map[o.x] = o.h
    end

    belief_map = update_belief(observation_map)

    # here if we had some probabilities we would look for the best path

    flat = find_flat(belief_map)
    position.x = position.x + take_action(flat, position)
    position.z -= 1
end 