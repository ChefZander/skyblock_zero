local modpath = minetest.get_modpath("sbz_power")

function sbz_api.register_machine(name, def)
    def.groups = def.groups or {}
    def.groups.sbz_machine = 1
    def.groups.pipe_conducts = 1
    def.groups.pipe_connects = 1
    if not def.control_action_raw then
        local old_action = def.action

        function def.action(pos, node, meta, supply, demand)
            if (demand + def.power_needed) > supply then
                meta:set_string("infotext", "Not enough power, needs: " .. def.power_needed)
                return def.power_needed
            else
                meta:set_string("infotext", "Running")
                local count = meta:get_int("count")
                if count >= def.action_interval then
                    old_action(pos, node, meta, supply, demand)
                    meta:set_int("count", 0)
                else
                    meta:set_int("count", count + 1)
                end
                return def.power_needed
            end
        end
    end
    minetest.register_node(name, def)
end

function sbz_api.register_generator(name, def)
    def.groups.sbz_machine = 1
    def.groups.sbz_generator = 1
    def.groups.pipe_conducts = 1
    def.groups.pipe_connects = 1
    if def.power_generated then
        def.action = function(pos, node, meta, ...)
            meta:set_string("infotext", "Running")
            return def.power_generated
        end
    end
    minetest.register_node(name, def)
end

dofile(modpath.."/vm.lua")
dofile(modpath.."/switching_station.lua")
dofile(modpath.."/power_pipes.lua")
dofile(modpath.."/batteries.lua")
dofile(modpath.."/extractor.lua")
dofile(modpath.."/generator.lua")
dofile(modpath.."/connectors.lua")
dofile(modpath.."/infinite_storinator.lua")
dofile(modpath.."/misc.lua")

--aliases for fixing worlds, remove in a few releases
for _, n in ipairs({
    "switching_station",
    "power_pipe",
    "battery",
    "advanced_battery",
    "creative_battery",
    "simple_matter_extractor",
    "advanced_matter_extractor",
    "simple_charge_generator",
    "simple_charged_field",
    "starlight_collector",
    "connector_off",
    "connector_on",
    "infinite_storinator",
    "phosphor_off",
    "phosphor_on"
}) do
    minetest.register_alias("sbz_resources:"..n, "sbz_power:"..n)
end