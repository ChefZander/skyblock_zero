local max_count = 5
local show_duration = 10
local notifications = modlib.minetest.playerdata()

local function remove_last_notification(name)
	local notifs = notifications[name]
	minetest.get_player_by_name(name):hud_remove(notifs[#notifs].hud_id)
	notifs[#notifs] = nil
end

function epidermis.send_notification(player, message, color)
	local name = player:get_player_name()
	local notifs = notifications[name]
	if epidermis.colors[color] then
		color = epidermis.colors[color]:to_number_rgb()
	end
	if notifs[1] and notifs[1].message == message and notifs[1].color == color then
		notifs[1].job:cancel()
		notifs[1].job = modlib.minetest.after(show_duration, remove_last_notification, name)
		notifs[1].count = notifs[1].count + 1
		player:hud_change(notifs[1].hud_id, "text", ("(%d) %s"):format(notifs[1].count, message))
		return
	end
	if #notifs == max_count then
		notifs[#notifs].job:cancel()
		remove_last_notification(name)
	end
	for i, notification in ipairs(notifs) do
		player:hud_change(notification.hud_id, "offset", { x = 0, y = i * -20 })
	end
	table.insert(notifs, 1, {
		hud_id = player:hud_add({
			hud_elem_type = "text",
			position = { x = 0.6, y = 0.5 },
			text = message,
			number = color,
			direction = 0,
			alignment = { x = 1, y = 0 },
			offset = { x = 0, y = 0 },
			z_index = 0,
		}),
		color = color,
		message = message,
		count = 1,
		job = modlib.minetest.after(show_duration, remove_last_notification, name),
	})
end
