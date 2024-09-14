local logic = sbz_api.logic


minetest.register_craftitem("sbz_logic:data_disk", {
    description = "Empty Data Disk",
    info_extra = {
        "Can hold 1mb of anything.",
        "Can be configured to override editor or normal code on use.",
        "Insert into a luacontroller to configure",
    },
    can_hold = 1024 * 20, -- 20 kilobytes
    on_use = function(stack, user, pointed)
        if pointed.type ~= "node" then return end
        local stack_meta = stack:get_meta()
        local override_code,
        override_editor = stack_meta:get_int("override_code") == 1,
            stack_meta:get_int("override_editor") == 1

        local target = pointed.under
        if minetest.is_protected(target, user:get_player_name()) then
            minetest.record_protection_violation(target, user:get_player_name())
            return
        end
        local node = minetest.get_node(target)
        if not minetest.get_item_group(node.name, "sbz_luacontroller") == 1 then return end

        if override_editor then
            logic.override_editor(target, stack_meta:get_string("data"))
        end
        if override_code then
            logic.override_code(target, stack_meta:get_string("data"))
        end
    end,
    inventory_image = "data_disk.png",
    groups = { sbz_disk = 1 },
})

function logic.register_system_disk(name, desc, source, punch_editor, punch_code)
    local def = {
        description = "System Code Disk - " .. desc,
        inventory_image = "system_code_disk.png",
        info_extra = {
            "Immutable",
        },
        groups = { sbz_disk = 1, sbz_disk_immutable = 1 },
        source = source,
        punches_editor = punch_editor,
        punches_code = punch_code,
        on_use = function(stack, user, pointed)
            if pointed.type ~= "node" then return end
            local target = pointed.under
            if minetest.is_protected(target, user:get_player_name()) then
                minetest.record_protection_violation(target, user:get_player_name())
                return
            end

            local node = minetest.get_node(target)
            if minetest.get_item_group(node.name, "sbz_luacontroller") ~= 1 then return end

            if punch_editor then
                logic.override_editor(target, source)
            end
            if punch_code then
                logic.override_code(target, source)
            end
        end,

    }
    minetest.register_craftitem(name, def)
end

local file = assert(io.open(minetest.get_modpath("sbz_logic") .. "/disks/default_editor.sandboxed.lua", "r"), "wtf??")
local default_editor_code = file:read("*a")
file:close()

logic.register_system_disk("sbz_logic:basic_editor_disk", "Basic Editor Disk\n(Go make your own editor!)",
    default_editor_code,
    true, false)
