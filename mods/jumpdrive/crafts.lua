minetest.register_craft({
    output = 'jumpdrive:engine',
    recipe = {
        { 'jumpdrive:backbone',    'sbz_power:very_advanced_battery', 'jumpdrive:backbone' },
        { 'jumpdrive:warp_device', 'sbz_meteorites:neutronium',       'jumpdrive:warp_device' },
        { 'jumpdrive:warp_device', 'sbz_power:antimatter_generator',  'jumpdrive:warp_device' },
    }
})

minetest.register_craft({
    output = 'jumpdrive:backbone',
    recipe = {
        { 'sbz_chem:titanium_block', 'sbz_power:reactor_shell', 'sbz_chem:titanium_block' },
        { 'sbz_power:reactor_shell', 'sbz_power:reactor_shell', 'sbz_power:reactor_shell' },
        { 'sbz_chem:titanium_block', 'sbz_power:reactor_shell', 'sbz_chem:titanium_block' }
    }
})

minetest.register_craft({
    output = 'jumpdrive:warp_device',
    recipe = {
        { 'sbz_resources:warp_crystal', 'sbz_resources:warp_crystal',         'sbz_resources:warp_crystal' },
        { 'sbz_resources:warp_crystal', 'sbz_power:antimatter_generator_off', 'sbz_resources:warp_crystal' },
        { 'sbz_resources:warp_crystal', 'sbz_resources:warp_crystal',         'sbz_resources:warp_crystal' }
    }
})

minetest.register_craft({
    output = 'jumpdrive:fleet_controller',
    recipe = {
        { 'jumpdrive:backbone', 'jumpdrive:backbone',       'jumpdrive:backbone' },
        { 'jumpdrive:backbone', 'sbz_logic:lua_controller', 'jumpdrive:backbone' },
        { 'jumpdrive:backbone', 'jumpdrive:backbone',       'jumpdrive:backbone' }
    }
})
