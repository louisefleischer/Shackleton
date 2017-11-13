#Lander
Type Lander
    pos::Vector{Float64}
    vel::Vector{Float64}
end

function move(lander::Lander,t)
    lander.pos += lander.vel*t
end

function impulse(lander::Lander,delta_v)
    lander.vel+=delta_v
end

