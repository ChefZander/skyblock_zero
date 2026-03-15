do -- Engine recipe scope
    local Engine = 'jumpdrive:engine'
    local Ba = 'jumpdrive:backbone'
    local VA = 'sbz_power:very_advanced_battery'
    local WD = 'jumpdrive:warp_device'
    local Ne = 'sbz_meteorites:neutronium'
    local AG = 'sbz_power:antimatter_generator'
    core.register_craft({
        output = Engine,
        recipe = {
            { Ba, VA, Ba },
            { WD, Ne, WD },
            { WD, AG, WD },
        }
    })
end

do -- Backbone recipe scope
    local Backbone = 'jumpdrive:backbone'
    local TB = 'sbz_chem:titanium_block'
    local RS = 'sbz_power:reactor_shell'
    core.register_craft({
        output = Backbone,
        recipe = {
            { TB, RS, TB },
            { RS, RS, RS },
            { TB, RS, TB },
        }
    })
end

do -- Warp Device recipe scope
    local Warp_Device = 'jumpdrive:warp_device'
    local WC = 'sbz_resources:warp_crystal'
    local AG = 'sbz_power:antimatter_generator_off'
    core.register_craft({
        output = Warp_Device,
        recipe = {
            { WC, WC, WC },
            { WC, AG, WC },
            { WC, WC, WC },
        }
    })
end

do -- Fleet Controller recipe scope
    local Fleet_Controller = 'jumpdrive:fleet_controller'
    local Ba = 'jumpdrive:backbone'
    local LC = 'sbz_logic:lua_controller'
    core.register_craft({
        output = Fleet_Controller,
        recipe = {
            { Ba, Ba, Ba },
            { Ba, LC, Ba },
            { Ba, Ba, Ba },
        }
    })
end
