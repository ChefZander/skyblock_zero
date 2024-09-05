local ghost_removal_delay = 5

minetest.register_entity("sbz_power:node_ghost", {
    initial_properties = {
        hp_max = 1,
        pointable = true,
        visual = "cube",
        use_texture_alpha = true,
        glow = 14,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = minetest.deserialize(staticdata)
        self.object:set_properties({ textures = staticdata })
        minetest.after(ghost_removal_delay, function()
            self.object:remove()
        end)
    end
})

local emittrium_reactor_schem = { -- x
    {                             -- y
        {},                       -- z
        {},
        {}
    }
}

function sbz_api.render_ghost(pos, textures)
    for k, v in ipairs(textures) do
        textures[k] = textures[k] .. "^[colorize:blue:10^[opacity:127"
    end
    minetest.add_entity(pos, "sbz_power:node_ghost", minetest.serialize(textures))
end
