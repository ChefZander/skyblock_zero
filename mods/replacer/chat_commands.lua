
local rb = replacer.blabla

-- let's hope there isn't a yes that means no in another language :/
-- TODO: better option would be to simply toggle (see postool)
local lOn = { '1', 'on', 'yes', 'an', 'ja', 'si', 'sí', 'да', 'oui', 'joo', 'juu', 'kyllä', 'sim', 'em' }
local lOff = { '0', 'off', 'no', 'aus', 'nein', 'non', 'нет', 'ei', 'fora', 'não', 'desligado' }
local tOn, tOff = {}, {}
for _, s in ipairs(lOn) do tOn[s] = true end
for _, s in ipairs(lOff) do tOff[s] = true end

replacer.chatcommand_mute = {

	params = rb.ccm_params,--(chat|audio) (0|1)
	description = rb.ccm_description,
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		-- can happen if command was issued by e.g. command block
		-- while owner isn't online. Rather unlikely but possible.
		if not player then
			return false, rb.ccm_player_not_found
		end
		local meta = player:get_meta()
		-- TODO: low chance of this happening, above check would already fail.
		if not meta then
			return false, rb.ccm_player_meta_error
		end

		local lower = string.lower(param)
		local parts = lower:split(' ')
		local usage = rb.ccm_params .. '\n'
			.. rb.ccm_description
		if 2 > #parts then return false, usage end

		local command, value, key = parts[1], parts[2]
		if 'chat' == command then
			key = 'replacer_mute'
		elseif 'audio' == command then
			key = 'replacer_muteS'
		elseif 'version' == command then
			return true, tostring(replacer.version)
		else
			return false, usage
		end

		if tOff[value] then
			value = 1
		elseif tOn[value] then
			value = 0
		else
			return false, usage
		end

		meta:set_int(key, value)
		return true, ''
	end
}

minetest.register_chatcommand('replacer', replacer.chatcommand_mute)

