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
        visual_size = { x = 0.9, y = 0.9, z = 0.9 }, -- little smaller than a node
        use_texture_alpha = true,
        glow = 14,
        damage_texture_modifier = "",
        shaded = false,
        backface_culling = true,
    },
    on_activate = function(self, staticdata, dtime_s)
        self.object:set_armor_groups({ immortal = 1 })
        staticdata = core.deserialize(staticdata)
        local item_name = staticdata.item_name
        local def = core.registered_nodes[item_name]
        local textures = {}

        local last_texture = nil
        if def.drawtype == "glasslike_framed" then
            for i = 1, 6 do
                textures[i] = def.tiles[2]
            end
        else
            for i = 1, 6 do
                textures[i] = def.tiles[i] or last_texture
                last_texture = textures[i]
            end
        end

        for k, v in ipairs(textures) do
            textures[k] = v .. (staticdata.texmod or "")
        end


        local viz_size = { x = 0.9, y = 0.9, z = 0.9 }
        if staticdata.render_slightly_bigger then
            viz_size = { x = 1.2, y = 1.2, z = 1.2 }
        end
        self.object:set_properties {
            wield_item = staticdata.item_name,
            textures = textures,
            visual_size = viz_size,
        }
        if not staticdata.no_nametag then
            local nametag = core.add_entity(
                self.object:get_pos() - vector.new(0, 0.5, 0), "sbz_multiblocks:nametag_workaround",
                def.short_description
            )
            nametag:set_attach(self.object, "", { x = 0, y = -10, z = 0 })
        end
        core.after(staticdata.expiration or 8, function()
            if self.object:is_valid() then
                self.object:remove()
            end
        end)
    end,
})

function multiblocks.render_ghost(pos, itemname, render_slightly_bigger, no_nametag)
    return core.add_entity(pos, "sbz_multiblocks:node_ghost", core.serialize {
        item_name = itemname,
        texmod = "^[opacity:120",
        expiration = 8,
        no_nametag = true, --no_nametag
        render_slightly_bigger = render_slightly_bigger,
    })
end

function multiblocks.draw_schematic(start_pos, schematic)
    for pos, node_match in pairs(schematic.data) do
        pos = vector.add(start_pos, uh(pos))
        local node = sbz_api.get_node_force(pos)
        if node then
            local visual_item_name = node_match
            if type(visual_item_name) == "function" then visual_item_name = "unifieddyes:colorium_blob" end
            if schematic.categories[visual_item_name] then
                visual_item_name = schematic.categories[visual_item_name].default
            end
            local correct
            if type(node_match) == "function" then
                correct = node_match(pos, node)
            else
                correct = visual_item_name == node.name
            end
            if not correct then
                local ndef = core.registered_nodes[node.name]
                local render_slightly_bigger = true
                if not ndef then
                    render_slightly_bigger = false
                elseif ndef.buildable_to == true then
                    render_slightly_bigger = false
                end
                multiblocks.render_ghost(pos, visual_item_name, render_slightly_bigger,
                    type(node_match) == "function")
            end
        end
    end
end
