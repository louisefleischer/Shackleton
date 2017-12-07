#using PyPlot

mutable struct Lander
 x::Int
 z::Int
end

mutable struct Observation
    x
    h
end





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

function next_state(x,z,action)
    # compute the next state
    # input: state coordinates, action
    return [x-2+action;z-1]
end

function compute_reward(x,z,lander,action,belief_map)
    # compute reward based on potential observation and action
    # set constants
    R_thrust=-.5
    R_newobs=20
    # Cost of action
    R_action=R_thrust*(2-R_thrust*(action==2))
    # Reward for observation
    R_obs=0
    sp=next_state(x,z,action)
    xp=sp[1]
    zp=sp[2]
    if zp==lander.z-3
        xobs = [max(1,xp-div(zp,2)); xp; min(xp + div(zp,2),100)]
        R_obs=R_newobs*count(x->x<1,belief_map[xobs,2])
    end
    #check bounds
    if x<1 || x>100
        return -1000
    end
    return R_obs+R_action
end

function U_ground(belief_map,x)
    #This function builds the "value" of a landing site
    U_valid = 200;
    U_invalid = -50;
    U_maybe_3 = 100;
    U_maybe_2 = 50;
    U_maybe_1 = 0;

    #Test vectors
    #scan belief_map vector and find rows that have the same height
    #belief_map = zeros(100,2)
    #belief_map[:,1] = rand(1:30,map_size,1)
    #belief_map[:,2] = rand(100,1);

    if x<=1 || x>=100
        #map edge is always invalid
        return U_invalid 
    end
    
    h1 = belief_map[x-1,1]; #height 1
    h2 = belief_map[x,1]; #height 2
    h3 = belief_map[x+1,1]; #height 3

    b1 = belief_map[x-1,2]; #probability 1
    b2 = belief_map[x,2]; #probability 2
    b3 = belief_map[x+1,2]; #probability 3
    
    if h1 == h2 && h2 == h3 && b1 == 1 && b2 == 1 && b3 == 1 
        #Giving large reward for a valid landing sight where we are
        #certain (belief probability = 1) that 3 adjacent heights are
        #the same
        return U_valid;
    elseif (h1 != h2 && b1 == 1 && b2 == 1) || (h2 != h3 && b2==1 && b3==1) ||( h1 != h3 && b1 == 1  && b3 == 1)
        #Giving large negative reward for an invalid landing sight
        #where we are certain (belief probability = 1) that 3 adjacent
        #heights are different
        return U_invalid;
    elseif h1 == h2 && h2 == h3 && h1 == h3 && (b1 < 1 || b2 < 1 || b3 < 1)
        #Giving medium reward for a landing sight where we have
        #probabilities that 3 adjacent heights are the same
        return U_maybe_3*b1*b2*b3;
    elseif (h1 == h2 && (b1<1||b2<1)) || (h2 == h3&& (b3<1||b2<1)) || (h1 == h3&& (b3<1||b1<1))
        #Giving medium reward for a landing sight where we have
        #probabilities that 2 adjacent heights are the same
        return U_maybe_2*(b1*b2*(h1==h2)/abs(h1-h3+1)+b2*b3*(h2==h3)/abs(h2-h1+1)+b3*b1*(h1==h3)/abs(h3-h2+1));
    else
        #Giving medium reward for a landing site where we have
        #probabilities that 2 adjacent heights are the same
        return U_maybe_1;
    end
    
    #Combined height, belief probability and utility vector
    #height_belief_utility = hcat(belief_map, u_ground)
    return u_ground
end

function update_utility(belief_map,lander)
    #Update utility map from bottom to top
    U_crash=-1000
    U=zeros(100,100)
    U_search=zeros(3,1)
    for z = 1:lander.z-1
        for x = max(1,lander.x-lander.z):min(100,lander.x+lander.z)
            h=belief_map[x,1]
            if z<h
                U[x,z]=U_crash
            elseif z==h
                U[x,z]=U_ground(belief_map,x)
            else
                for action=1:3
                    sp=next_state(x,z,action)
                    xp=sp[1]
                    zp=sp[2]
                    if xp<1 || xp >100
                        U_search[action]=-1000
                    elseif zp==0
                        U_search[action]=0
                    else
                        U_search[action]=compute_reward(x,z,lander,action,belief_map)+U[xp,zp]
                    end
                end
                U[x,z]=maximum(U_search)
            end
        end
    end
    return U
end

MAP_SIZE = 100
true_map = vcat([1, 2, 3, 3, 3, 4, 5, 6, 6, 5],
    collect(ceil.(linspace(1,50,(100-38)))),
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

function choose_action(lander,U_curr)
    # returns the next action
    # find closest one
    U_next=zeros(3,1)
    for action=1:3
        sp=next_state(lander.x,lander.z,action)
        xp=sp[1]
        zp=sp[2]
        U_next[action]=U_curr[xp,zp]
    end
    return indmax(U_next)
end

iteration = 0
U_curr=zeros(100,100)
while lander.z>(true_map[lander.x]) && iteration<110
    if iteration%3==0
        # observe
        #o = make_observation(true_map, lander)
        #observation_map[o.x] = o.h

        # update your belief
        #belief_map = update_belief(observation_map, belief_map)
        belief_map=hcat(true_map,ones(100,1))

        U_curr=update_utility(belief_map,lander)
        # find flat parts in the belief map (obsolete)
        #flat = find_flat(belief_map)
    end
    # make your decision
    opt_action=choose_action(lander,U_curr)
    #println(op_action)
    sp=next_state(lander.x,lander.z,opt_action)
    xp=sp[1]
    zp=sp[2]
    lander.x = xp
    lander.z = zp

    # keep in memory for plotting
    x_path = hcat(x_path,[lander.x])
    z_path = hcat(z_path,[lander.z])
    iteration+=1
    #println(iteration)
end 

println("The lander has arrived at x=",lander.x," and z=", lander.z," in ", iteration, " iterations")
println("Measurements made : ",count(x->x==1,belief_map[:,2]))
h1=true_map[lander.x-1]
h2=true_map[lander.x]
h3=true_map[lander.x+1]

if h1==h2 && h2==h3
    println("Safe landing!")
else
    println("Crash! h1=",h1, " h2=",h2, " h3=",h3)
end

#    hold(true)
#    plot(x_path',z_path')
#    plot(collect(1:MAP_SIZE), true_map)