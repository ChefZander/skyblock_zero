local sprouts = {
    "sbz_bio:pyrograss_1",
    "sbz_bio:stemfruit_plant_1"
}

local up = vector.new(0, 1, 0)


local fert_use = function(itemstack, user, pointed)
    if pointed.type ~= "node" then return end

    local pos = pointed.under
    local node = core.get_node(pos)
    local name = node.name
    local def = core.registered_nodes[node.name] or {}


    if core.get_item_group(name, "soil") > 0
        and core.registered_nodes[core.get_node(pos + up).name].buildable_to
        and core.get_item_group(name, "fertilizer_no_sprout") <= 0
    then
        if not (sbz_api.get_node_heat(pos) > 7 and sbz_api.is_hydrated(pos)) then return end
        core.set_node(pos + up, { name = sprouts[math.random(#sprouts)] })
        --   elseif core.get_item_group(name, "plant") > 0 and def.grow then
        --        def.grow(pos, node)
    elseif core.get_item_group(name, "sapling") > 0 then
        def.grow(pos)
    elseif def.spread then
        if def.spread(pos) == false then return end
    else
        return
    end
    itemstack:take_item()
    core.sound_play({
        name = 'gen_subtle_fart', {
            pos = pos,
            gain = 1.0,
            pitch = 1.0
        }
    })
    return itemstack
end
core.register_craftitem("sbz_bio:fertilizer", {
    description = "Fertilizer",
    inventory_image = "fertilizer.png",
    on_place = sbz_api.on_place_precedence(fert_use),
    on_use = fert_use,
    groups = { ui_bio = 1 },
})

do -- Fertilizer recipe scope
    local Fertilizer = 'sbz_bio:fertilizer'
    local Al = 'sbz_bio:algae'
    core.register_craft({
        type = 'shapeless',
        output = Fertilizer,
        recipe = { Al, Al, Al }
    })
end
