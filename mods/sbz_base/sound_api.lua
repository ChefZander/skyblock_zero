-- very similar to xcompat's sound api
-- sbz_api.sounds.node_sound_x_defaults(inp)

local sounds = {}
---@type fun(inp:table?)[]
sbz_api.sounds = sounds

local function register_sound_function(name, sounds_to_use)
    sounds[name] = function(input)
        return table.override(sounds_to_use, input)
    end
end

local function g1(x)
    return { name = x, gain = 1 }
end
local function csound(x, g)
    return { name = x, gain = g }
end

register_sound_function("matter", { -- also could be node_stone_defaults
    footstep = csound("step", 2),
    place = csound("step", 2),
})
register_sound_function("metal", {
    footstep = csound("step", 2),
    place = csound("step", 2),
})

register_sound_function("glass", {
    footstep = csound("step", 2),
    place = csound("step", 2),
})

register_sound_function("dirt", {
    footstep = csound("step", 2),
    place = csound("step", 2),
})

register_sound_function("tree", {
    footstep = csound("step", 2),
    place = csound("step", 2),
})

register_sound_function("leaves", {
    --    footstep = csound("step", 2),
    --    place = csound("step", 2),
})

register_sound_function("antimatter", {
    footstep = g1("antistep"),
    place = g1("antistep"),
})

register_sound_function("strange", {
    footstep = g1("antistep"),
    place = g1("antistep"),
})

register_sound_function("machine", {
    footstep = csound("step", 2),
    place = g1("machine_build"),
    rightclick = g1("machine_open"),
})

-- allow for a rightclick parameter too, so that its less annoying
minetest.register_on_mods_loaded(function()
    for k, v in pairs(minetest.registered_nodes) do
        if v.sounds and v.sounds.rightclick then
            local old_rightclick = v.on_rightclick or function(pos, node, clicker, itemstack, pointed_thing) end
            local function new_rightclick(pos, node, clicker, stack, pointed)
                if minetest.get_meta(pos):get_string("formspec") ~= "" then
                    minetest.sound_play(v.sounds.rightclick, {
                        pos = pos,
                    })
                end
                return old_rightclick(pos, node, clicker, stack, pointed)
            end
            minetest.override_item(k, {
                on_rightclick = new_rightclick,
            })
        end
    end
end)
