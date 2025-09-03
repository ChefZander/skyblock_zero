-- local at_every_load = false -- for lbms if ever needed
local function deprecate_entity(name)
    core.register_entity(':' .. name, {
        on_activate = function(self)
            self.object:remove()
        end,
    })
end

local function deprecate_item(name)
    core.register_craftitem(':' .. name, {
        description = 'Deprecated item, throw away',
        inventory_image = 'blank.png',
        stack_max = 1,
        groups = { not_in_creative_inventory = 1 },
    })
end

-- Epidermis - removed due to being buggy, and me(frog) not understanding the code

deprecate_entity 'epidermis:colorpicker'
deprecate_entity 'epidermis:paintable'
deprecate_item 'epidermis:spawner_paintable'

deprecate_item 'epidermis:spawner_colorpicker'
deprecate_item 'epidermis:guide'
deprecate_item 'epidermis:eraser'
deprecate_item 'epidermis:undo_redo'

deprecate_item 'epidermis:pen'
deprecate_item 'epidermis:filling_bucket'
deprecate_item 'epidermis:rectangle'
deprecate_item 'epidermis:line'
