core.register_craftitem("sbz_bio:paper", {
    description = "Paper",
    inventory_image = "paper.png"
})

local fsdata = {}
local show_formspec = function(user)
    local wield_index = fsdata[user:get_player_name()]
    if not wield_index then return end
    local inv = user:get_inventory()
    local book_item = inv:get_stack(user:get_wield_list(), wield_index)
    if book_item:get_name() ~= "sbz_bio:book" then return end

    local book_item_meta = book_item:get_meta()
    local esc = core.formspec_escape
    core.show_formspec(user:get_player_name(), "sbz_bio:book_formspec", string.format([[
formspec_version[7]
size[10,12.2]

field[0.2,0.6;9.6,0.8;title;Title\:;%s]
textarea[0.2,1.8;9.6,9.4;text;Text\:;%s]
button[0.2,11.2;9.6,0.9;save;Save]
]], esc(book_item_meta:get_string("title")), esc(book_item_meta:get_string("text"))))
end

local max_title_size = 200
local max_text_size = 80000
core.register_on_player_receive_fields(function(user, formname, fields)
    if formname == "sbz_bio:book_formspec" then
        -- save
        local wield_index = fsdata[user:get_player_name()]
        if not wield_index then return end
        local inv = user:get_inventory()
        local book_item = inv:get_stack(user:get_wield_list(), wield_index)
        if book_item:get_name() ~= "sbz_bio:book" then return end
        local book_item_meta = book_item:get_meta()
        if #(fields.title or "") > max_title_size then return end
        if #(fields.text or "") > max_text_size then return end

        if fields.title then
            book_item_meta:set_string("title", fields.title)
        end
        if fields.text then
            book_item_meta:set_string("text", fields.text)

            if #(fields.text or "") > 1000 then
                unlock_achievement(user:get_player_name(), 'Alive Poets Society')
            end
        end
        if fields.title then
            book_item_meta:set_string("description", "Book: " .. fields.title)
        end
        inv:set_stack(user:get_wield_list(), wield_index, book_item)
    end
end)

core.register_craftitem("sbz_bio:book", {
    description = "Book",
    inventory_image = "book.png",
    info_extra = "You can write stuff in this!",
    on_use = function(stack, user, pointed)
        if user.is_fake_player then return end
        local wield_index = user:get_wield_index()
        fsdata[user:get_player_name()] = wield_index
        show_formspec(user)
        return stack
    end
})


core.register_craft {
    output = "sbz_bio:paper 12",
    recipe = {
        { "sbz_bio:fiberweed", "sbz_bio:cleargrass", "sbz_bio:fiberweed", }
    }
}
core.register_craft {
    output = "sbz_bio:book",
    recipe = {
        { "sbz_resources:matter_plate", "sbz_resources:matter_plate", "sbz_resources:matter_plate", },
        { "sbz_bio:paper",              "sbz_bio:paper",              "sbz_bio:paper", },
        { "sbz_resources:matter_plate", "sbz_resources:matter_plate", "sbz_resources:matter_plate", }
    }
}
