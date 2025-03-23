
local S = metatool.S

metatool.util = {}

--
-- Utility functions in metatool.util namespace
--

function metatool.util.pos_to_string(pos)
	if pos and pos.x and pos.y and pos.z then
		return ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
	end
	return "?,?,?"
end

function metatool.util.description(pos, node, meta)
	node = node or minetest.get_node(pos)
	meta = meta or minetest.get_meta(pos)
	local nicename = meta:get("infotext") or minetest.registered_nodes[node.name].description or node.name
	return ("%s at %s"):format(nicename, metatool.util.pos_to_string(pos))
end

function metatool.util.area_in_area(a, b)
	return a.pos1.x >= b.pos1.x and a.pos2.x <= b.pos2.x
		and a.pos1.y >= b.pos1.y and a.pos2.y <= b.pos2.y
		and a.pos1.z >= b.pos1.z and a.pos2.z <= b.pos2.z
end

--
-- Utility functions in metatool root namespace
--

function metatool.transform_tool_name(name, mtprefix)
	local parts = name:gsub('\\s',''):split(':')
	if #parts == 2 then
		return (mtprefix and ':' or '') .. parts[1] .. ':' .. parts[2]
	elseif #parts == 1 and parts[1] ~= 'metatool' then
		return (mtprefix and ':' or '') .. 'metatool:' .. parts[1]
	end
	-- print(S('Invalid metatool name %s', name))
end

function metatool.check_privs(player, privs)
	local success,_ = minetest.check_player_privs(player, privs)
	return success
end

function metatool.is_protected(pos, player, privs, no_violation_record)
	if privs and (metatool.check_privs(player, privs)) then
		-- player is allowed to bypass protection checks
		return false
	end
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		if not no_violation_record then
			-- node is protected record violation
			minetest.record_protection_violation(pos, name)
		end
		return true
	end
	return false
end

-- Save data for tool and update tool description
function metatool.write_data(itemstack, data, description, tool)
	if not itemstack then
		return
	end
	local meta = itemstack:get_meta()
	if data.data or data.group then
		local datastring = minetest.serialize(data)
		local storage_size = tool and tonumber(tool.settings.storage_size)
		if storage_size and #datastring > storage_size then
			return S('Cannot store %d bytes, max storage for %s is %d bytes',
				#datastring, tool.nice_name, tool.settings.storage_size)
		end
		meta:set_string('data', datastring)
	end
	if description then
		meta:set_string('description', description)
	end
end

-- Return data stored with tool
function metatool.read_data(itemstack)
	if not itemstack then
		return
	end
	local meta = itemstack:get_meta()
	local datastring = meta:get_string('data')
	return minetest.deserialize(datastring)
end
