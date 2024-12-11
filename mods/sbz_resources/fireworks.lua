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
        exptime = { min = 20, max = 50 },
    },

}

local colors = { "red", "green", "lime", "yellow", "blue", "azure", "cyan", "pink", "magenta" }
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
        local suspense = 1.5
        local velocity = 11
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
