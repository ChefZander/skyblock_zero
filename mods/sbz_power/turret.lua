minetest.register_entity("sbz_power:turret_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "turret.gltf",
        visual_size = { x = 5, y = 5 },
        --automatic_rotate = 0.2,
        glow = 14,
        physical = false,
        pointable = false,
        textures = {
            "turret.png",
        }
    },
    on_activate = function(self)
        local node = minetest.get_node(vector.round(self.object:get_pos())).name
        if node ~= "sbz_power:turret" then
            self.object:remove()
        end
        -- self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
    end,
    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        local node = minetest.get_node(vector.round(pos)).name
        if node ~= "sbz_power:turret" then
            self.object:remove()
        end
    end
})

local function set_turret_formspec(meta)
    meta:set_string("formspec", ([[
formspec_version[7]
size[8.2,7]
tooltip[target_players;Targets all players, excluding you, and if the area is protected, then it excludes all the people
that can access that area]
checkbox[0.2,0.5;target_players;Target \"enemy\" players;%s]
checkbox[0.2,1;target_meteorites;Target meteorites;%s]
style_type[list;spacing=.2;size=.8]
list[context;main;3.6,1.4;8,4;]
list[current_player;main;0.2,2.6;8,4;]
listring[]
]]):format(
        meta:get_int("target_players") == 1 and "true" or "false",
        meta:get_int("target_meteorites") == 1 and "true" or "false"
    ))
end

--- Side effect: creates turret entity when its not found
local function get_turret_entity(pos)
    local entities = core.get_objects_inside_radius(pos, 0.5)
    for k, v in pairs(entities) do
        if v:get_luaentity() then
            if v:get_luaentity().name == "sbz_power:turret_entity" then
                return v
            end
        end
    end

    return minetest.add_entity(pos, "sbz_power:turret_entity")
end

local range = 120
local power_use = 30
sbz_api.register_machine("sbz_power:turret", {
    description = "Automatic Turret",
    drawtype = "glasslike",
    info_extra = {
        "Shoots things like lasers.",
        "Range: " .. range .. " nodes",
    },
    power_needed = 50,
    tiles = { "gravitational_repulsor.png" },
    inventory_image = "gravitational_repulsor.png^turret_inv.png",
    wield_image = "gravitational_repulsor.png^turret_inv.png",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = { matter = 1, cracky = 3, charged = 1, transparent = 1 },
    input_inv = "main",
    output_inv = "main",
    on_construct = function(pos)
        get_turret_entity(pos)
        local meta = core.get_meta(pos)
        meta:get_inventory():set_size("main", 1)
        set_turret_formspec(meta)
    end,
    sounds = sbz_api.sounds.machine(),
    action = function(pos, node, meta, supply, demand)
        if supply < demand + power_use then
            meta:set_string("infotext", "Not enough power")
            return power_use
        end
        local targets_meteorites = meta:get_int("target_meteorites") == 1
        local targets_players = meta:get_int("target_players") == 1
        local target_list = {}
        for obj in core.objects_inside_radius(pos, range) do
            local is_player = obj:is_player()
            if is_player then
                if targets_players and sbz_api.line_of_sight(pos, obj:get_pos()) then
                    local pname = obj:get_player_name() or ""
                    if (pname ~= meta:get_string("owner")) and (core.is_protected(pos, pname) or not core.is_protected(pos, " ")) then
                        target_list[#target_list + 1] = obj
                    end
                end
            else
                local is_luaentity = obj:get_luaentity()
                if targets_meteorites then
                    if is_luaentity and obj:get_luaentity().name == "sbz_meteorites:meteorite" and sbz_api.line_of_sight(pos, obj:get_pos()) then
                        target_list[#target_list + 1] = obj
                    end
                end
            end
        end

        meta:set_string("infotext", "No targets nearby.")
        if #target_list > 0 then
            meta:set_string("infotext", "Active")
            local target = target_list[math.random(1, #target_list)]
            local dir = vector.normalize(vector.subtract(target:get_pos(), pos))
            if sbz_api.shoot_turret(pos, dir, meta:get_string("owner")) == false then
                meta:set_string("infotext", "Invalid/no item")
                return 0
            else
                return power_use
            end
        end

        return 0
    end,
    after_place_node = function(pos, placer)
        local meta = core.get_meta(pos)
        meta:set_string("owner", placer:get_player_name())
    end,
    on_receive_fields = function(pos, _, fields, sender)
        local meta = core.get_meta(pos)
        if fields.target_players then
            meta:set_int("target_players", fields.target_players == "true" and 1 or 0)
        elseif fields.target_meteorites then
            meta:set_int("target_meteorites", fields.target_meteorites == "true" and 1 or 0)
        end
        set_turret_formspec(meta)
    end
})


sbz_api.shoot_turret = function(pos, dir, owner)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()

    local item = inv:get_stack("main", 1)
    if item:get_definition().on_use then
        -- now...  call on_use
        -- prepare fake player n crap yknow how it goes
        local fakeplayer = fakelib.create_player {
            name = owner or "",
            position = pos,
            -- controls = maybe?,
            inventory = inv,
            wield_list = "main",
            wield_index = 1,
            -- what makes this different from the node breaker:
            direction = dir,
        }

        local pointed = {
            above = pos,
            under = pos,
            fake = true,
            swapped = false,
        } -- pointed_thing does not matter trust m

        -- these 2 lines copied from pipeworks

        item = item:get_definition().on_use(item, fakeplayer, pointed) or item
        fakeplayer:set_wielded_item(item)

        local turret_entity = get_turret_entity(pos)
        local rot = vector.dir_to_rotation(dir)
        turret_entity:set_rotation(rot)
    else
        return false
    end
end

core.register_craft {
    output = "sbz_power:turret",
    recipe = {
        { "pipeworks:nodebreaker",     "pipeworks:nodebreaker",            "pipeworks:nodebreaker" },
        { "sbz_resources:matter_blob", "sbz_resources:prediction_circuit", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_meteorites:antineutronium",    "sbz_resources:matter_blob" }
    }
}
