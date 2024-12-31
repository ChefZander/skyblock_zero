local armor = sbz_api.armor
local recipes = {}

armor.recipes = recipes

recipes.chestplate = function(mat)
    return {
        { mat, "",  mat },
        { mat, mat, mat },
        { mat, mat, mat }
    }
end

recipes.boots = function(mat)
    return {
        { "",  "", "" },
        { "",  "", "" },
        { mat, "", mat }
    }
end

recipes.leggings = function(mat)
    return {
        { mat, mat, mat },
        { mat, "",  mat },
        { mat, "",  mat }
    }
end

recipes.helmet = function(mat)
    return {
        { mat, mat, mat },
        { mat, "",  mat },
        { "",  "",  "" }
    }
end

local ratios = {
    chestplate = 8,
    boots = 2,
    leggings = 7,
    helmet = 5,
}

local sum = 8 + 2 + 7 + 5

recipes.get_protection = function(armor_groups, armor_type)
    armor_groups = table.copy(armor_groups)
    for group, value in pairs(armor_groups) do
        if group ~= "immortal" then
            armor_groups[group] = (value / sum) * ratios[armor_type]
        end
    end
    return armor_groups
end
