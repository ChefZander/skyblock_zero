local multiblocks = sbz_api.multiblocks

local uh = core.get_position_from_hash

core.register_entity("sbz_multiblocks:nametag_workaround", {
    initial_properties = {
        static_save = false,
        visual_size = { x = 0, y = 0, z = 0 },
        pointable = false,
        visual = "upright_sprite",
        textures = { "blank.png", "blank.png", }
    },
    on_activate = function(self, staticdata)
        self.object:set_properties { nametag = staticdata }
    end,
    on_detach = function(self, removal)
        self.object:remove()
    end
})

core.register_entity("sbz_multiblocks:node_ghost", {
    initial_properties = {
        static_save = false,
        pointable = false,
        visual = "cube",
        visual_size = { x = 0.8, y = 0.8, z = 0.8 }, -- little smaller than a node
        use_texture_alpha = true,
        glow = 14,
        damage_texture_modifier = "",
        shaded = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        self.object:set_armor_groups({ immortal = 1 })
        staticdata = core.deserialize(staticdata)
        local item_name = staticdata.item_name
        local def = core.registered_nodes[item_name]
        local textures = def.tiles

        local last_texture = nil
        for i = 1, 6 do
            textures[i] = textures[i] or last_texture
            last_texture = textures[i]
        end

        for k, v in ipairs(textures) do
            textures[k] = v .. (staticdata.texmod or "")
        end

        self.object:set_properties {
            wield_item = staticdata.item_name,
            textures = textures,
        }
        if not staticdata.no_nametag then
            local nametag = core.add_entity(
                self.object:get_pos() - vector.new(0, 0.5, 0), "sbz_multiblocks:nametag_workaround",
                def.short_description
            )
            nametag:set_attach(self.object, "", { x = 0, y = -10, z = 0 })
            core.after(staticdata.expiration or 5, function()
                if self.object:is_valid() then
                    self.object:remove()
                end
            end)
        end
    end,
})

function multiblocks.render_ghost(pos, itemname, no_nametag)
    core.add_entity(pos, "sbz_multiblocks:node_ghost", core.serialize {
        item_name = itemname,
        texmod = "^[multiply:#00FFFF^[opacity:250",
        expiration = 10,
        no_nametag = no_nametag
    })
end

function multiblocks.draw_schematic(start_pos, schematic, category_represent)
    for pos, node_match in pairs(schematic.data) do
        pos = uh(pos)
        local name = node_match
        if type(name) == "function" then name = "unifieddyes:colorium_blob" end
        if category_represent[name] then name = category_represent[name] end
        multiblocks.render_ghost(vector.add(start_pos, pos), name, type(node_match) == "function")
    end
end
