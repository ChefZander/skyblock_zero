--[[
Luanti Mod Storage Drawers - A Mod adding storage drawers

Original Mod:
Copyright (C) 2021 by Pandorabox
Copyright (C) 2017-2020 Linus Jahn <lnj@kaidan.im>

Modifications for Skyblock: Zero:
Copyright (C) 2026 Skyblock: Zero Contributors

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local S = core.get_translator('drawers')

local function upgrade_desc(material, multiplier)
    return S("@1 Drawer Upgrade (@2x)", material, tostring(multiplier))
end

--
-- Register drawers
--

drawers.register_drawer("drawers:drawer", {
    description = S("Matter Drawer"),
    tiles1 = drawers.node_tiles_front_other("drawers_matter_front_1.png", "drawers_matter.png"),
    tiles2 = drawers.node_tiles_front_other("drawers_matter_front_2.png", "drawers_matter.png"),
    tiles4 = drawers.node_tiles_front_other("drawers_matter_front_4.png", "drawers_matter.png"),
    groups = { matter = 1, oddly_breakable_by_hand = 2 },
    sounds = sbz_api.sounds.tree(),
    drawer_stack_max_factor = 32, -- 4 * 8 normal chest size
    material = "sbz_resources:reinforced_matter",
    info_extra = S("If you aren't seeing drawer visuals, try using /drawers_fix")
})

-- Register Drawer Connector ("Drawer Trim" from the original drawers mod)
-- Drawer Controllers can transfer through these blocks.
drawers.register_connector("drawers:drawer_connector", {
    description = S("Drawer Connector"),
    tiles = { "drawers_matter_connector.png" },
    groups = { matter = 1, oddly_breakable_by_hand = 2 },
    material = "sbz_resources:reinforced_matter",
    info_extra = S("For use with the Drawer Controller; transfers items through it to adjacent drawers.")
})

-- Register drawer upgrades

drawers.register_drawer_upgrade("drawers:bronze_upgrade", {
    description = upgrade_desc(S("Bronze"), 2),
    inventory_image = "drawers_upgrade_bronze.png",
    groups = { drawer_upgrade = 100 },
    recipe_item = "sbz_chem:bronze_ingot"
})

drawers.register_drawer_upgrade("drawers:stemfruit_upgrade", {
    description = upgrade_desc(S("Stemfruit"), 3),
    inventory_image = "drawers_upgrade_stemfruit.png",
    groups = { drawer_upgrade = 200 },
    recipe_item = "sbz_bio:stemfruit"
})

drawers.register_drawer_upgrade("drawers:upgrade_colorium", {
    description = upgrade_desc(S("Colorium"), 4),
    inventory_image = "drawers_upgrade_colorium.png",
    groups = { drawer_upgrade = 300 },
    recipe_item = "unifieddyes:colorium_blob",
    info_extra = S("Sorry, but it doesn't actually make the drawer color-able..."),
})

drawers.register_drawer_upgrade("drawers:warpshroom_upgrade", {
    description = upgrade_desc(S("Warpshroom"), 8),
    inventory_image = "drawers_upgrade_warpshroom.png",
    groups = { drawer_upgrade = 700 },
    recipe_item = "sbz_bio:warpshroom"
})

-- TODO: DIAMOND UPGRADE in-between as 16x

drawers.register_drawer_upgrade("drawers:neutronium_upgrade", { -- neutronium is super expensive so yea
    description = upgrade_desc(S("Neutronium"), 32),
    inventory_image = "drawers_upgrade_neutronium.png",
    groups = { drawer_upgrade = 3100 },
    recipe_item = "sbz_meteorites:neutronium"
})

drawers.register_drawer_upgrade("drawers:infinite_upgrade", {
    description = upgrade_desc(S("Creative"), 1000000),
    inventory_image = "drawers_upgrade_infinite.png",
    groups = { drawer_upgrade = 1000100, creative = 1 },
    no_craft = true,
})

-- Register drawer upgrade template

core.register_craftitem('drawers:upgrade_template', {
    description = S('Drawer Upgrade Template'),
    inventory_image = 'drawers_upgrade_template.png'
})

do -- Drawer Upgrade Template recipe scope
    local Drawer_Upgrade_Template = 'drawers:upgrade_template'
    local amount = 4
    local GI = 'sbz_chem:gold_ingot'
    local NI = 'sbz_chem:nickel_ingot'
    local St = 'sbz_resources:storinator'
    core.register_craft({
        output = Drawer_Upgrade_Template .. ' ' .. tostring(amount),
        recipe = {
            { GI, NI, GI },
            { NI, St, NI },
            { GI, NI, GI },
        }
    })
end
