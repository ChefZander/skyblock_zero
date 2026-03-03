-- Drawer Upgrades GUI Pane (refactored from helpers.lua)

--[[ To get, roughly:
┌─────────────────────────────────────────────────────┐
│                                                     │
│            ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐            │
│            │ ⇧ │ │ ⇧ │ │ ⇧ │ │ ⇧ │ │ ⇧ │            │
│            └───┘ └───┘ └───┘ └───┘ └───┘            │
│                                                     │
│                                                     │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
│   │   │ │   │ │   │ │   │ │   │ │   │ │   │ │   │   │
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘   │
│                                                     │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
│   │   │ │   │ │   │ │   │ │   │ │   │ │   │ │   │   │
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘   │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
│   │   │ │   │ │   │ │   │ │   │ │   │ │   │ │   │   │
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘   │
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │
│   │   │ │   │ │   │ │   │ │   │ │   │ │   │ │   │   │
│   └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
]]
function drawers.upgrades_gui_pane()
    -- Engine hard-coded formspec units
    local inv_slot_w = 1.0
    local inv_slot_h = 1.0

    -- Space between components
    local separation_spacing = 0.5
    local relational_spacing = 0.25

    -- Upgrade arrow image overlays
    local upgrades = 5
    local x = 1.98 -- hacky adjustment
    local y = separation_spacing
    local w = inv_slot_w
    local h = inv_slot_h
    local overlay_image = 'drawers_upgrade_slot_bg.png'
    local fs_upgrade_arrows = ''
    for i = 0, (upgrades - 1) do
        fs_upgrade_arrows = fs_upgrade_arrows ..
            string.format('image[%.2f,%.2f;%.2f,%.2f;%s]',
                x + i, y, w, h, overlay_image)
    end

    -- Modifiables
    local hotbar_y = inv_slot_h * 2 + separation_spacing
    local inventory_size = 32
    local hotbar_slots = 8 -- TODO: Figure out how to get from player meta
    local slots_per_row = 8

    -- Derived
    local remaining_slots = inventory_size - hotbar_slots
    local hotbar_rows = math.ceil(hotbar_slots / slots_per_row)
    local inv_remaining_rows = math.ceil(remaining_slots / slots_per_row)

    -- Derived Values
    local inv_remaining_y = hotbar_y + hotbar_rows + relational_spacing
    local inv_remaining_i = hotbar_slots

    -- API, regarding Formspec's `list` element:
    --     "W and H are in inventory slots, not in coordinates."

    -- Formspec params
    local inventory_location = 'current_player'
    local list_name = 'main'
    x = separation_spacing -- (from side of GUI pane)
    y = hotbar_y        -- (supplied as a param for some reason)
    w = slots_per_row   -- (`list` takes w as column count)
    h = hotbar_rows     -- (`list` takes h as row count)
    local i = 0

    -- Hotbar Formspec
    local fs_hotbar =
        string.format('list[%s;%s;%.2f,%.2f;%d,%d;]',
            inventory_location, list_name, x, y, w, h)

    -- Remaining Inventory Formspec
    y = inv_remaining_y
    h = inv_remaining_rows
    i = inv_remaining_i
    local fs_remaining =
        string.format('list[%s;%s;%.2f,%.2f;%d,%d;%d]',
            inventory_location, list_name, x, y, w, h, i)

    return fs_upgrade_arrows .. fs_hotbar .. fs_remaining
end
