#Alternative version where left and right allow you to hover instead of diagonal
#UNFINISHED, do not use

function next_state(x,z,action)
    # compute the next state
    # input: state coordinates, action
    return [x-(action==1)+(action==3);z-(action==2)]
end

function compute_reward_action(action)
    R_hover=-3
    return R_hover*(action==1 || action==3)
end

function compute_reward(x,z,lander,action,belief_map,R_newobs)
    #OBSOLETE
    # compute reward based on potential observation and action
    # set constants
    R_hover=-3
    R_timeinflight=0
    # Cost of action
    R_action=R_hover*((action!=2))
    # Reward for observation
    R_obs=0
    sp=next_state(x,z,action)
    xp=sp[1]
    zp=sp[2]
    if abs(lander.z-zp)+abs(lander.x-xp)==3
        xobs = [max(1,xp-div(zp,2)); xp; min(xp + div(zp,2),100)]
        b1=belief_map[xobs[1],2]
        b2=belief_map[xobs[2],2]
        b3=belief_map[xobs[3],2]
        R_obs=R_newobs*((b1<1)/(b1+1)+3*(b2<1)/(b2+1)+(b3<1)/(b3+1))
    end
    #check bounds
    if xp<=2 || xp>=99
        return -600
    end
    return R_obs+R_action+R_timeinflight
end

function U_ground(belief_map,x)
    #This function builds the "value" of a landing site
    U_valid = 200;
    U_invalid = -200;
    U_maybe_3 = 100;
    U_maybe_2 = 50;
    U_maybe_1 = 0;

    if x<=1 || x>=100
        #map edge is always invalid
        return U_invalid 
    end
    
    h1 = belief_map[x-1,1] #height 1
    h2 = belief_map[x,1] #height 2
    h3 = belief_map[x+1,1] #height 3

    b1 = belief_map[x-1,2] #probability 1
    b2 = belief_map[x,2] #probability 2
    b3 = belief_map[x+1,2] #probability 3
    
    if h1 == h2 && h2 == h3 && b1 == 1 && b2 == 1 && b3 == 1 
        #Giving large reward for a valid landing sight where we are
        #certain (belief probability = 1) that 3 adjacent heights are
        #the same
        return U_valid
    elseif (h1 != h2 && b1 == 1 && b2 == 1) || (h2 != h3 && b2==1 && b3==1) ||( h1 != h3 && b1 == 1  && b3 == 1)
        #Giving large negative reward for an invalid landing sight
        #where we are certain (belief probability = 1) that 3 adjacent
        #heights are different
        return U_invalid
    elseif h1 == h2 && h2 == h3 && h1 == h3 && (b1 < 1 || b2 < 1 || b3 < 1)
        #Giving medium reward for a landing sight where we have
        #probabilities that 3 adjacent heights are the same
        return U_maybe_3*b1*b2*b3
    elseif (h1 == h2) || (h2 == h3) || (h1 == h3)
        #Giving medium reward for a landing sight where we have
        #probabilities that 2 adjacent heights are the same
        return U_maybe_2*(b1*b2*(h1==h2)+b2*b3*(h2==h3)+b3*b1*(h1==h3))
    else
        #Giving medium reward for a landing site where we have
        #probabilities that 2 adjacent heights are the same
        return U_maybe_1
    end
end

function update_utility(belief_map,lander,gamma,R_obsmap)
    #Update utility map from bottom to top
    U_crash=-600
    U=zeros(100,100)
    U_search=zeros(3,1)
    deltaU_tol=1e-5
    for z = 1:lander.z
        sky_at_z=[]
        for x = 1:100
            h=belief_map[x,1]
            if z<h
                U[x,z]=U_crash
            elseif z==h
                U[x,z]=U_ground(belief_map,x)
            else
                push!(sky_at_z,[x])
            end
        end
        deltaU=deltaU_tol*10
        iteration=0
        while (deltaU>deltaU_tol && length(sky_at_z)>0 && iteration<20) || iteration<3
            U_old=U
            for ii =1:length(sky_at_z)
                x=sky_at_z[ii]
                for action=1:3
                    sp=next_state(x,z,action)
                    xp=sp[1]
                    zp=sp[2]
                    if xp<1 || xp >100
                        U_search[action]=-600
                    elseif zp==0
                        U_search[action]=0
                    else
                        U_search[action]=compute_reward_action(action)+R_obsmap[xp,zp]+gamma*U[xp,zp]
                    end
                end
                U[x,z]=maximum(U_search)
            end
            deltaU=maximum(abs.(U_old-U))
            iteration+=1
        end
    end
    return U
end

function choose_action(x,z,U_curr,R_obsmap)
    # returns the next action
    # find closest one
    U_next=zeros(3,1)
    for action=1:3
        sp=next_state(x,z,action)
        xp=sp[1]
        zp=sp[2]
        if xp<2 || xp>99
            U_next[action]=-600
        else
            U_next[action]=U_curr[xp,zp]+R_obsmap[xp,zp]+compute_reward_action(action)
        end
    end
    return indmax(U_next)
end