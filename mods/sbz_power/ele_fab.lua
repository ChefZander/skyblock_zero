-- concept shamelessly borrowed from techage

local animation_def = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1,
}

sbz_api.register_stateful_machine("sbz_power:ele_fab", {
    description = "Ele Fab",
    info_extra = "Yeah the concept is from techage.",
    tiles = {
        "ele_fab_top.png",
        "ele_fab_top.png",
        "ele_fab.png^[verticalframe:8:1"
    },
    autostate = true,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 4)
        inv:set_size("output", 1)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    action = function(pos, node, meta, supply, demand)
        return 1
    end,
    groups = {
        matter = 1,
    }
}, {
    light_source = 14,
    tiles = {
        [3] = { name = "ele_fab.png", animation = animation_def },
    }
})
