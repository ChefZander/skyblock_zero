-- https://github.com/minetest/minetest_docs/blob/413b559f1a49e59c2649eea2835fc7620d407dca/doc/formspecs.adoc#versions
-- https://rubenwardy.com/minetest_modding_book/en/players/formspecs.html

local r = replacer
local rb = replacer.blabla
local get_player_information = minetest.get_player_information
local mfe = minetest.formspec_escape
local check_player_privs = minetest.check_player_privs
local show_formspec = minetest.show_formspec

replacer.form_name_modes = 'replacer_replacer_mode_change'

function replacer.get_form_modes_4(player, mode)
	local major, minor = mode.major, mode.minor
	local name = player:get_player_name()
	local has_history_priv = check_player_privs(name, r.history_priv)
	local form_dimensions = r.disable_minor_modes and '5.375,3.5' or '5.375,4.25'
	local button_height = '1'
	local button_single_dimensions = '.33,.77;2,'
	local button_field_dimensions = '2.9,.77;2,'
	local button_crust_dimensions = '1.44,2.1;2,'
	local minor_dimensions = '.38,3.42;4.5,.55'
	local history_label_position, history_dropdown_position
	if has_history_priv then
		button_single_dimensions = '0.33,0.77;2.3,'
		button_field_dimensions = '3.04,0.77;2.3,'
		button_crust_dimensions = '5.75,0.77;2.3,'
		if r.disable_minor_modes then
			form_dimensions = '8.375,3.39'
			history_label_position = '0.33,2.22;'
			history_dropdown_position = '0.38,2.55'
		else
			form_dimensions = '8.375,4.39'
			button_single_dimensions = '0.33,0.77;2.3,'
			button_field_dimensions = '3.04,0.77;2.3,'
			button_crust_dimensions = '5.75,0.77;2.3,'
			minor_dimensions = '1.88,2.12;4.5,0.60'
			history_label_position = '0.33,3.22;'
			history_dropdown_position = '0.38,3.55'
		end
	end
	local tmp_name = '_'
	local formspec = 'formspec_version[4]'
		.. 'size[' .. form_dimensions .. ']'
		.. 'label[0.33,0.44;' .. mfe(rb.choose_mode)
		.. ']button_exit[' .. button_single_dimensions .. button_height .. ';'
	if 1 == major then
		formspec = formspec .. '_;< ' .. mfe(rb.mode_single) .. ' >'
	else
		tmp_name = 'mode1'
		formspec = formspec .. 'mode1;' .. mfe(rb.mode_single)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_single_tooltip) .. ']button_exit['
		.. button_field_dimensions .. button_height .. ';'
	if 2 == major then
		tmp_name = '_'
		formspec = formspec .. '_;< ' .. mfe(rb.mode_field) .. ' >'
	else
		tmp_name = 'mode2'
		formspec = formspec .. 'mode2;' .. mfe(rb.mode_field)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_field_tooltip) .. ']button_exit['
		.. button_crust_dimensions .. button_height .. ';'
	if 3 == major then
		tmp_name = '_'
		formspec = formspec .. '_;< ' .. mfe(rb.mode_crust) .. ' >'
	else
		tmp_name = 'mode3'
		formspec = formspec .. 'mode3;' .. mfe(rb.mode_crust)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_crust_tooltip) .. ']'
	if not r.disable_minor_modes then
		formspec = formspec .. 'dropdown[' .. minor_dimensions .. ';minor;'
		.. mfe(rb.mode_minor1) .. ',' .. mfe(rb.mode_minor2) .. ',' .. mfe(rb.mode_minor3)
		.. ';' .. tostring(minor) .. ';true]tooltip[' .. minor_dimensions .. ';'
		.. mfe(rb.mode_minor1 .. ': ' .. rb.mode_minor1_info .. '\n'
			.. rb.mode_minor2 .. ': ' .. rb.mode_minor2_info .. '\n'
			.. rb.mode_minor3 .. ': ' .. rb.mode_minor3_info) .. ']'
	end

	if not has_history_priv then return formspec end

	formspec = formspec .. 'label[' .. history_label_position .. mfe(rb.choose_history)
		.. ']dropdown[' .. history_dropdown_position .. ';7.5,0.6;history;'
	local db = r.history.get_player_table(player)
	for _, data in ipairs(db) do
		if r.history_include_mode then
			formspec = formspec .. data.mode.major .. '.' .. data.mode.minor .. ' '
		end
		formspec = formspec .. mfe(data.human_string) .. ','
	end
	formspec = formspec .. '~~~~~~~~~~~~~~;1;true]'
	return formspec
end -- get_form_modes_4


function replacer.get_form_modes_default(mode)
	local major = mode.major
	local tmp_name = '_'
	local formspec = 'size[3.9,2]'
		.. 'label[0,0;' .. mfe(rb.choose_mode)
		.. ']button_exit[0.0,0.6;2,0.5;'
	if 1 == major then
		formspec = formspec .. '_;< ' .. mfe(rb.mode_single) .. ' >'
	else
		tmp_name = 'mode1'
		formspec = formspec .. 'mode1;' .. mfe(rb.mode_single)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_single_tooltip) .. ']button_exit[1.9,0.6;2,0.5;'
	if 2 == major then
		formspec = formspec .. '_;< ' .. mfe(rb.mode_field) .. ' >'
	else
		tmp_name = 'mode2'
		formspec = formspec .. 'mode2;' .. mfe(rb.mode_field)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_field_tooltip) .. ']button_exit[0.0,1.4;2,0.5;'
	if 3 == major then
		formspec = formspec .. '_;< ' .. mfe(rb.mode_crust) .. ' >'
	else
		tmp_name = 'mode3'
		formspec = formspec .. 'mode3;' .. mfe(rb.mode_crust)
	end
	formspec = formspec .. ']tooltip[' .. tmp_name .. ';'
		.. mfe(rb.mode_crust_tooltip) .. ']'
	return formspec
end -- get_form_modes_default

function replacer.on_player_receive_fields(player, form_name, fields)
	-- no need to process if it's not expected formspec that triggered call
	if form_name ~= r.form_name_modes then return end
	-- collect some information
	local name = player:get_player_name()
	local wielded = player:get_wielded_item()
	local node, mode = r.get_data(wielded)
	-- user clicked on currently active mode
	if fields._ then return end
	if fields.mode1 or fields.mode2 or fields.mode3 then
		-- user clicked on one of the major modes
		mode.major = (fields.mode1 and 1) or (fields.mode2 and 2) or (fields.mode3 and 3)
	elseif fields.minor then
		-- clamp to { 1, 2, 3 }
		mode.minor = math.min(3, math.max(1, tonumber(fields.minor) or 1))
		if r.disable_minor_modes then mode.minor = 1 end
	elseif fields.history then
		-- ignore if user doesn't have privs
		if not check_player_privs(name, r.history_priv) then
			r.log('info', rb.formspec_error:format(name, dump(fields)))
			return
		end
		local entry = r.history.get_by_index(player, tonumber(fields.history) or 1)
		if not entry then return end

		node = entry.node
		mode = r.history_include_mode and entry.mode or nil
	elseif fields.quit then
		-- user closed formspec with escape or other clicking manouver
		return
	else
		-- some hacked client forging formspec?
		r.log('info', rb.formspec_hacker:format(name, dump(fields)))
		return
	end

	-- set metadata and itemstring
	r.set_data(wielded, node, mode)
	-- update wielded item
	player:set_wielded_item(wielded)
end -- on_player_receive_fields
-- listen to submitted fields
minetest.register_on_player_receive_fields(r.on_player_receive_fields)

function replacer.show_mode_formspec(player, mode)
	if not player then return end

	local name = player:get_player_name()
	local version = get_player_information(name).formspec_version
	local formspec
	if 4 > version then
		formspec = r.get_form_modes_default(mode)
	else
		-- version 4 allows us to use proper dropdowns and other gimmics
		formspec = r.get_form_modes_4(player, mode)
	end
	-- show the formspec to player
	show_formspec(name, r.form_name_modes, formspec)
end -- show_mode_formspec

