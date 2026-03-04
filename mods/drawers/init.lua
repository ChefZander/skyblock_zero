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

local MP = core.get_modpath(core.get_current_modname())

drawers = {}
drawers.drawer_visuals = {}
drawers.enable_1x1 = true
drawers.enable_1x2 = true
drawers.enable_2x2 = true
drawers.CONTROLLER_RANGE = 40
drawers.CHEST_ITEMSTRING = "sbz_resources:storinator"

dofile(MP .. "/helpers.lua")    -- Basic utilities
dofile(MP .. "/formspecs.lua")  -- Modular, complex formspec panes
dofile(MP .. "/visuals.lua")    -- Item/Node contents indicator visuals
dofile(MP .. "/api.lua")        -- Registration templates (register_drawer)
dofile(MP .. "/controller.lua") -- The Controller node logic
dofile(MP .. "/nodes.lua")      -- The actual items (Matter Drawer, Upgrades)
