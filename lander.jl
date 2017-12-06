using Colors, Compose
using Reel


# Object Lander 
type Lander
    pos::Vector{Float64}
    vel::Vector{Float64}
end

function move(lander::Lander,t)
    lander.pos += lander.vel*t
end

function impulse(lander::Lander,delta_v)
    lander.vel+=delta_v
end

moon_lander = Lander([10, 10, 10], [0, 0, -2])
print(moon_lander)

move(moon_lander,1)

print(moon_lander)


roll(fps=30, duration=10.0) do t, dt
    compose(context(),
        (context(), rectangle(0,0,1000,1000), fill("blue")),
        (context(), rectangle(t,t, 3,2),fill("white")))
end