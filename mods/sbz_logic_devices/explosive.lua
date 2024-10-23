-- License: LGPLv3 or later
-- from: https://github.com/mt-mods/digistuff/tree/master
local explosion_time = 1
local function explode(pos)
	minetest.remove_node(pos)
	local placer = minetest.get_meta(pos):get_string("placer")
	if placer == "" then placer = ".explosive" end
	for _ = 1, 100 do
        local raycast = minetest.raycast(pos, pos + vector.random_direction() * 8, false)
        local wear = 0
        for pointed in raycast do
            if pointed.type == "node" then
                local nodename = minetest.get_node(pointed.under).name
                wear = wear + (1 / minetest.get_item_group(nodename, "explody"))
                --the explody group hence signifies roughly how many such nodes in a straight line it can break before stopping
                --although this is very random
				if nodename == "sbz_logic_devices:explosive" then explode(pointed.under) end
                if wear > 1 or minetest.is_protected(pointed.under, placer) then break end
                minetest.set_node(pointed.under, { name = minetest.registered_nodes[nodename]._exploded or "air" })
            end
        end
    end
	minetest.sound_play({ name = "distant-explosion-47562", gain = 0.1 })
	minetest.add_particlespawner({
        amount = 500,
        time = 0.2,
        minpos = { x = pos.x - 1 / 3, y = pos.y - 1 / 3, z = pos.z - 1 / 3 },
        maxpos = { x = pos.x + 1 / 3, y = pos.y + 1 / 3, z = pos.z + 1 / 3 },
		minvel = { x = -10, y = -10, z = -10 },
        maxvel = { x = 10, y = 10, z = 10 },
        minacc = { x = -1, y = -1, z = -1 },
        maxacc = { x = 1, y = 1, z = 1 },
		minexptime = 5,
        maxexptime = 10,
        minsize = 0.5,
        maxsize = 1.5,
        collisiondetection = false,
        vertical = false,
        texture = "star.png",
        glow = 10,
		drag = 0.2,
    })
end

minetest.register_node("sbz_logic_devices:explosive", {
    description = "Annihilation Explosive",
    info_extra = "Explodes when right-clicked or sent any logic messages",
    tiles = {
        "explosive_top.png",
        "explosive_bottom.png",
        "explosive_side.png",
    },
    groups = { matter = 1, explody = 16 },
    on_logic_send = explode,
	on_rightclick = explode,
	after_place_use = function(pos, placer)
		if placer and placer:get_player_name() ~= "" then
			minetest.meta(pos):set_string("placer", placer:get_player_name())
		end
	end,
})

minetest.register_craft({
    output = "sbz_logic_devices:explosive 2",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" },
        { "",                          "sbz_meteorites:neutronium", ""                          },
        { "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob", "sbz_resources:antimatter_blob" }
    }
})

