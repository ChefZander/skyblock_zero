core.register_entity("sbz_resources:warp_crystal_entity", {
    initial_properties = {
        visual = "sprite",
        visual_size = { x = 1, y = 1, z = 1 },
        pointable = false,
        collide_with_objects = true,
        physical = true,
        textures = { "warp_crystal.png" },
        glow = 14,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = core.deserialize(staticdata)
        self.object:set_armor_groups { matter = 100, antimatter = 100 }
        self.owner = staticdata.owner
        self.direction = staticdata.direction
        self.object:set_acceleration(vector.new(0, -sbz_api.gravity, 0))
        self.object:set_velocity(vector.multiply(vector.add(vector.new(30, 30, 30), staticdata.vel), self.direction))
    end,
    on_punch = function(self)
        -- looks like your throwing got interrupted, teleport the owner
        if core.get_player_by_name(self.owner) then
            core.get_player_by_name(self.owner):set_pos(self.object:get_pos())
        end
        self.object:remove()
    end,
    on_death = function(self, killer)
        if core.get_player_by_name(self.owner) then
            core.get_player_by_name(self.owner):set_pos(self.object:get_pos())
        end
        self.object:remove()
    end,
    on_step = function(self, dtime, moveresult)
        if moveresult.collides then
            local player = core.get_player_by_name(self.owner)
            if player and player:is_valid() then
                for k, v in pairs(moveresult.collisions) do
                    if v.type == "object" and sbz_api.can_move_object(v.object:get_armor_groups()) then
                        local objpos = v.object:get_pos()
                        local playerpos = player:get_pos()
                        player:set_pos(objpos)
                        v.object:set_pos(playerpos)
                        self.object:remove()
                        return
                    end
                end
                player:set_pos(self.object:get_pos())

                self.object:remove()
            end
        end
    end
})

core.register_craftitem("sbz_resources:warp_crystal", {
    description = "Warp Crystal",
    inventory_image = "warp_crystal.png",
    info_extra = "You can throw it. Also if you throw it at an entity/player you will swap places.",
    on_use = function(stack, placer, pointed)
        local look_dir = placer:get_look_dir()
        local name = placer:get_player_name()
        if placer.is_fake_player then name = "" end
        core.add_entity(
            vector.add(sbz_api.get_pos_with_eye_height(placer), vector.multiply(look_dir, 0.1)),
            "sbz_resources:warp_crystal_entity",
            core.serialize { owner = name, direction = look_dir, vel = placer:get_velocity() })
        stack:set_count(stack:get_count() - 1)
        return stack
    end
})

unified_inventory.register_craft {
    type = "crystal_growing",
    output = "sbz_resources:warp_crystal",
    items = { "sbz_bio:warpshroom 9" }
}

core.register_craftitem(":sbz_chem:uranium_crystal", {
    description = "Uranium Crystal",
    inventory_image = "uranium_crystal.png",
})

core.register_craftitem(":sbz_chem:thorium_crystal", {
    description = "Thorium Crystal",
    inventory_image = "thorium_crystal.png",
})

core.register_craftitem(":sbz_chem:silicon_crystal", {
    description = "Silicon Crystal",
    inventory_image = "silicon_crystal.png",
})

for k, v in pairs({ "powder", "ingot" }) do
    unified_inventory.register_craft {
        type = "crystal_growing",
        output = "sbz_chem:silicon_crystal",
        items = { ("sbz_chem:silicon_%s 64"):format(v) }
    }

    unified_inventory.register_craft {
        type = "crystal_growing",
        output = "sbz_chem:thorium_crystal",
        items = { ("sbz_chem:thorium_%s 8"):format(v) }
    }

    unified_inventory.register_craft {
        type = "crystal_growing",
        output = "sbz_chem:uranium_crystal",
        items = { ("sbz_chem:uranium_%s 8"):format(v) }
    }
end
