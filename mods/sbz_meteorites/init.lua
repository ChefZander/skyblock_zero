minetest.register_entity("sbz_meteorites:meteorite", {
    initial_properties = {
        visual = "cube",
        visual_size = {x=2, y=2},
        automatic_rotate = 0.2,
        glow = 15,
        physical = true
    },
    on_activate = function (self, staticdata)
        self.object:set_rotation(vector.new(math.random()*2, math.random(), math.random()*2)*math.pi)
        if staticdata and staticdata ~= "" then
            self.type = staticdata
        else
            local types = {"matter_blob", "emitter"}
            self.type = types[math.random(#types)]
        end
        local texture = self.type..".png^meteorite.png"
        self.object:set_properties({textures={texture, texture, texture, texture, texture, texture}})
        self.object:set_armor_groups({immortal=1})
    end,
    get_staticdata = function (self)
        return self.texture
    end
})