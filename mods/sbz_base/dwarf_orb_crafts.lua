local oldcraft = core.register_craft

function core.register_craft(def)
    local dwarf_recipe
    if def.type == nil or def.type == "shaped" then
        for i1, v in ipairs(def.recipe) do
            for i2, item in ipairs(v) do
                if item == "sbz_resources:matter_annihilator" then
                    dwarf_recipe = dwarf_recipe or table.copy(def.recipe)
                    dwarf_recipe[i1][i2] = "sbz_planets:dwarf_orb"
                end
            end
        end
    end
    if dwarf_recipe then
        local dwarf_craft = table.copy(def)
        dwarf_craft.recipe = dwarf_recipe
        oldcraft(dwarf_craft)
    end
    oldcraft(def)
end
