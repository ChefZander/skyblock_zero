local function get_gradient_texture(component, color)
	local old_value = color[component]
	color[component] = 255
	local texture = ("epxw.png^[multiply:%s^[resize:256x1^[mask:epidermis_gradient_%s.png")
		:format(color:to_string(), component)
	color[component] = old_value
	return texture
end

local dice_texture = epidermis.textures.dice
function epidermis.show_colorpicker_formspec(player, color, callback)
	local function show_colorpicker_formspec()
		local fs = {
			{"size", {8.5, 5.25}; false},
			{"real_coordinates", true},
			{"scrollbaroptions", min = 0; max = 255; smallstep = 1; largestep = 25; thumbsize = 1; arrows = "show"},
			{"label", {0.25, 0.25}; "Pick a color:"},
			{"image", {3, 0.25}; {0.5,0.5}; "epxw.png^[multiply:" .. color:to_string()},
			{"field", {3.5, 0.25}; {2, 0.5}; "color"; ""; color:to_string()},
			{"field_close_on_enter", "color"; false},
			{"image_button", {5, 0.25}; {0.5, 0.5}; dice_texture; "random"; ""},
			{"tooltip", "random"; "Random color"},
			{"image_button_exit", {7.25, 0.25}; {0.5, 0.5}; "epidermis_check.png"; "set"; ""},
			{"tooltip", "set"; "Set color"},
			{"image_button_exit", {7.75,0.25}; {0.5,0.5}; "epidermis_cross.png"; "cancel"; ""},
			{"tooltip", "cancel"; "Cancel"},
		}
		for index, component in ipairs{"Red", "Green", "Blue"} do
			local first_letter = component:sub(1, 1)
			local component_short = first_letter:lower()
			local y = 0.25 + index * 1.25
			table.insert(fs, {"scrollbar", {0.25, y}; {8, 0.5}; "horizontal", component_short, color[component_short]})
			table.insert(fs, {
				"label",
				{0.25, y + 0.75};
				minetest.colorize(("#%06X"):format(0xFF * 0x100 ^ (3 - index)), first_letter)
			})
			table.insert(fs, {"image", {0.75, y + 0.5}; {6.5, 0.5}; get_gradient_texture(component_short, color)})
			table.insert(fs, {"field", {7.25, y + 0.5}; {1, 0.5}; "field_" .. component_short; ""; color[component_short]})
			table.insert(fs, {"field_close_on_enter", "field_" .. component_short; true})
		end
		fslib.show_formspec(player, fs, function(fields)
			if fields.random then
				color = modlib.minetest.colorspec.new{
					r = math.random(0, 255),
					g = math.random(0, 255),
					b = math.random(0, 255)
				}
				show_colorpicker_formspec()
				return
			end
			if fields.quit then
				if fields.set or fields.key_enter then
					callback(color)
					return
				end
				callback()
				return
			end
			local key_enter_field = fields.key_enter_field
			local value = fields[key_enter_field]
			if key_enter_field and value then
				if key_enter_field == "color" then
					local new_color = modlib.minetest.colorspec.from_string(value)
					if not new_color then return end -- invalid colorstring
					new_color = new_color or color
					new_color.a = 255 -- HACK the colorpicker doesn't support alpha
					color = new_color
					show_colorpicker_formspec()
					return
				end
				local short_component = ({field_r = "r", field_g = "g", field_b = "b"})[key_enter_field]
				if not short_component then return end
				if not value:match"^%d+$" then return end
				color[short_component] = math.min(tonumber(value), 255)
				show_colorpicker_formspec()
				return
			end
			for _, short_component in pairs{"r", "g", "b"} do
				if fields[short_component] then
					local field = minetest.explode_scrollbar_event(fields[short_component])
					if field.type == "CHG" then
						color[short_component] = math.max(0, math.min(field.value, 255))
						show_colorpicker_formspec()
						return
					end
				end
			end
		end)
	end
	show_colorpicker_formspec()
end