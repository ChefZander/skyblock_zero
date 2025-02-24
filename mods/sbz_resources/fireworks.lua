local fx = {
    {
        amount = 1000,
        time = 0.01,
        glow = 14,
        size = 2,
        radius = 0.1,
        attract = {
            kind = "point",
            strength = -50,
            origin = "pls supply pos",
        },
        drag = { x = 1 / 10, y = 1 / 10, z = 1 / 10 },
        exptime = { min = 2, max = 7 },
        collisiondetection = true,
        bounce = 0.5,
    },
    {
        amount = 300,
        time = 0.5,
        glow = 14,
        size = 1,
        radius = 0.1,
        attract = {
            kind = "point",
            strength = -15,
            origin = "pls supply pos",
        },
        drag = { x = 1 / 10, y = 1 / 10, z = 1 / 10 },
        exptime = { min = 5, max = 15 },
        collisiondetection = true,
        bounce = 0.5,
    },
    {
        amount = 100,
        time = 0.01,
        glow = 14,
        size = 3,
        radius = 0.1,
        attract = {
            kind = "point",
            strength = -250,
            origin = "pls supply pos",
        },
        drag = { x = 1 / 10, y = 1 / 10, z = 1 / 10 },
        exptime = { min = 2, max = 7 },
        collisiondetection = true,
        bounce = 0.5,
    },
    {
        amount = 250,
        time = 0.01,
        glow = 14,
        size = 1,
        radius = 0.1,
        attract = {
            kind = "point",
            strength = -5,
            origin = "pls supply pos",
        },
        drag = { x = 1 / 20, y = 1 / 20, z = 1 / 20 },
        exptime = { min = 7, max = 8 },
        collisiondetection = true,
        bounce = 0.5,
    },
    {
        amount = 100,
        time = 0.3,
        minvel = {x = 6,  y = 5, z = -3},
        maxvel = {x = 12,  y = 8, z = 3},
        minacc = {x = 0,  y = -3, z = 0},
        maxacc = {x = 0,  y = -6, z = 0},
        minexptime = 1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 3,
        glow = 14,
    },
    {
        amount = 100,
        time = 0.3,
        minvel = {x = -12, y = 5, z = -3},
        maxvel = {x = -6, y = 8, z = 3},
        minacc = {x = 0,  y = -3, z = 0},
        maxacc = {x = 0,  y = -6, z = 0},
        minexptime = 1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 3,
        glow = 14,
    },
    {
        amount = 100,
        time = 0.3,
        minvel = {x = -3, y = 5, z = 6},
        maxvel = {x = 3, y = 8, z = 12},
        minacc = {x = 0,  y = -3, z = 0},
        maxacc = {x = 0,  y = -6, z = 0},
        minexptime = 1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 3,
        glow = 14,
    },
    {
        amount = 100,
        time = 0.3,
        minvel = {x = -3, y = 5, z = -12},
        maxvel = {x = 3, y = 8, z = -6},
        minacc = {x = 0,  y = -3, z = 0},
        maxacc = {x = 0,  y = -6, z = 0},
        minexptime = 1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 3,
        glow = 14,
    }

}

local colors = { "red", "lime", "yellow", "blue", "azure", "cyan", "pink", "magenta" }
local function random_color()
    return colors[math.random(1, #colors)]
end

local function make_fx(pos)
    local effect = fx[math.random(1, #fx)]
    effect.texture = {
        name = "star.png^[colorize:" .. random_color() .. ":255",
        --        blend = "screen"
    }

    effect = table.copy(effect)
    effect.pos = pos
    if effect.attract and effect.attract.origin == "pls supply pos" then
        effect.attract.origin = pos
    end

    core.sound_play("firework_explode", {
        pos = pos,
        gain = 32.0,
    }, true)
    core.sound_play("firework_explode", {
        pos = pos,
        gain = 32.0,
    }, true)
    core.add_particlespawner(effect)
end

core.register_craftitem("sbz_resources:firework", {
    info_extra = { "You can activate it by \"trying to dig with it\" it, you can also try node breakers, or better yet, logic builders..." },
    description = "Firework",
    inventory_image = "firework.png",
    stack_max = 365, -- ha get it, because 365~ish days in a year
    -- lets be real, this needs to be efficent cuz its going to get used probably 1000 times per second
    on_use = function(stack, user, pointed)
        local pos = pointed.above
        if pos == nil then return end

        local min = 1.10
        local max = 2.00
        local suspense = min + math.random() * (max - min)

        local velocity = 11

        core.sound_play("firework_launch", {
            pos = pos,
            gain = 0.5,
        }, true)
        core.add_particle {
            pos = pos,
            expirationtime = suspense,
            size = 8,
            texture = "firework.png",
            vertical = true,
            glow = 14,
            velocity = { x = 0, y = velocity, z = 0 }
        }
        local t = suspense
        core.after(t, make_fx, pos + vector.new(0, suspense * velocity, 0))
        stack:take_item(1)

        return stack
    end
})

core.register_craft {
    output = "sbz_resources:firework 8",
    type = "shapeless",
    recipe = {
        "sbz_resources:matter_blob", "sbz_resources:simple_circuit", "sbz_bio:pyrograss"
    }
}
