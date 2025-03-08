local S = metatool.S
local formspec_escape = minetest.formspec_escape

local function formspec_content(value, default)
	return formspec_escape(value or default or "")
end

local function fmt_rect(x, y, w, h)
	if w then
		return ("%0.3f,%0.3f;%0.3f,%0.3f"):format(x, y, w, h)
	end
	return ("%0.3f,%0.3f"):format(x, y)
end

local function generate_nonce()
	return ("%.32f"):format(math.random() + math.random() + math.random())
end

--
-- ATTENTION: metatool.form.Form is unstable and will probably evolve with breaking changes
-- NOTE: Formspec API is not included in stable features and breaking changes will not change major version.
--
local Form = {}
Form.__index = Form
setmetatable(Form, {
	__call = function(_, def)
		local obj = {
			width = def and def.width or 8,
			height = def and def.height or 8,
			xspacing = def and (def.xspacing or def.spacing) or 0.1,
			yspacing = def and (def.yspacing or def.spacing) or 0.1,
			elements = def and def.elements or {},
		}
		obj.formspec = ("formspec_version[3]size[%s;]"):format(fmt_rect(obj.width, obj.height))
		setmetatable(obj, Form)
		return obj
	end
})

function Form:get_rect(x, y, w, h, xcount, xindex, ycount, yindex, paddingtop)
	local sx = self.xspacing
	local sy = self.yspacing
	local cx = xcount or 1
	local ix = xindex or 1
	local cy = ycount or 1
	local iy = yindex or 1
	local pt = paddingtop or 0
	w = w or ((self.width - ((cx + 1) * sx)) / cx)
	h = h or ((self.height - ((cy + 1) * sy)) / cy)
	if cx > 1 then
		x = (x or 0) + (sx * ix) + (w * (ix - 1))
	end
	if cy > 1 then
		y = (y or 0) + (sy * iy) + (h * (iy - 1))
	end
	return x or sx, (y or sy) + pt, w, h - pt
end

function Form:raw(element)
	-- Add raw formspec element, `element` should be string with valid properly escaped formspec section
	table.insert(self.elements, element)
	return self
end

-- NOTE: Unstable function signature and `def` format. High probablility for breaking changes soon.
-- Formspec API is not included in stable features and breaking changes will not change major version.
-- def.columns and def.values required
-- everything else is optional
function Form:table(def)
	if not def.name or not def.columns or not def.values then
		return self
	end
	-- TODO: formspec_escape, columns as table with extended options
	local columns = {}
	local values = {}
	for i = 1, #def.columns do
		table.insert(columns, "text")
		table.insert(values, def.columns[i])
	end
	local ccount = #def.columns
	for _, v in ipairs(def.values) do
		for i = 1, ccount do
			table.insert(values, v[i] and formspec_escape(v[i]) or "")
		end
	end
	local pt = def.label and 0.4
	local background = def.background and (";background=%s"):format(def.background) or ""
	local highlight = def.highlight and (";highlight=%s"):format(def.highlight) or ""
	local color = def.color and (";color=%s"):format(def.color) or ""
	local x, y, w, h = self:get_rect(def.x, def.y, def.w, def.h, def.xcount, def.xidx, def.ycount, def.yidx, pt)
	table.insert(self.elements,
		(def.label and ("label[%s;%s]"):format(fmt_rect(x + 0.1, y - 0.2), def.label)) ..
		("tableoptions[border=false%s%s%s]"):format(background, highlight, color) ..
		("tablecolumns[%s]"):format(table.concat(columns, ";")) ..
		("table[%s;%s;%s]"):format(fmt_rect(x, y, w, h), def.name, table.concat(values, ","))
	)
	return self
end

-- NOTE: Unstable function signature and `def` format. High probablility for breaking changes soon.
-- Formspec API is not included in stable features and breaking changes will not change major version.
-- NOTE: Image button feature unstable, property names will most probably change
function Form:button(def)
	if not def.name then
		return self
	end
	local label = formspec_content(def.label, def.name)
	local x, y, w, h = self:get_rect(def.x, def.y, def.w, def.h, def.xcount, def.xidx, def.ycount, def.yidx)
	local properties
	if def.texture1 then
		local t1 = def.texture1 .. (def.modifier and formspec_escape(def.modifier) or "")
		local t2 = def.texture2 and def.texture2 .. (def.modifier and formspec_escape(def.modifier) or "")
		properties = ("%s;%s;%s;false;false;%s"):format(t1, def.name, label, t2)
	else
		properties = ("%s;%s"):format(def.name, label)
	end
	table.insert(self.elements,
		("button%s[%s;%s]"):format(def.exit and "_exit" or "", fmt_rect(x, y, w, h), properties)
	)
	return self
end

-- NOTE: Unstable function signature and `def` format. High probablility for breaking changes soon.
-- Formspec API is not included in stable features and breaking changes will not change major version.
function Form:field(def)
	if not def.name then
		return self
	end
	local label = formspec_content(def.label, def.name)
	local default = formspec_content(def.default)
	local x, y, w, h = self:get_rect(def.x, def.y, def.w, def.h, def.xcount, def.xidx, def.ycount, def.yidx)
	table.insert(self.elements,
		("field[%s;%s;%s;%s]"):format(fmt_rect(x, y, w, h), def.name, label, default)
	)
	return self
end

function Form:label(def)
	local label = formspec_content(def.label, def.name)
	local x, y = self:get_rect(def.x, def.y, def.w, def.h, def.xcount, def.xidx, def.ycount, def.yidx)
	table.insert(self.elements,
		("label[%s;%s]"):format(fmt_rect(x, y), label)
	)
	return self
end

function Form:render()
	-- Label is hack around formspecs not updating if nothing but field defaults changed
	return self.formspec .. table.concat(self.elements) .. "label[-9,-9;" .. os.clock() .. "]"
end

metatool.form = {
	Form = Form
}

-- container for form handler callback methods
metatool.form.handlers = {}

local function get_formname(name)
	if not name then
		return
	end
	local parts = name:gsub('\\s', ''):split(':')
	if #parts < 2 then
		return
	elseif parts[1] == "metatool" then
		if #parts < 3 then
			return
		end
		return name
	end
	return string.format("metatool:%s", name)
end

local function has_form(name)
	return name and (type(metatool.form.handlers[name]) == 'table')
end

-- Temporary storage for form data references
-- Links are created after(!) form is constructed
-- Links are destroyed after receiving fields and data is lost if not maintained by caller
local formdata = {}

local function destroy_formdata(player)
	local name = type(player) == "userdata" and player:get_player_name() or player
	if name then
		formdata[name] = nil
	end
end

local global_form_handler_registered
function metatool.form.register_global_handler()
	if not global_form_handler_registered then
		global_form_handler_registered = true
		print("metatool.form.register_global_handler Registering global formspec handler for Metatool")
		minetest.register_on_player_receive_fields(metatool.form.on_receive)
		minetest.register_on_leaveplayer(destroy_formdata)
	end
end

function metatool.form.on_receive(player, formname, fields)
	local matcher = formname:gmatch("([^~]+)")
	formname = matcher()
	if not has_form(formname) then
		-- form handler does not exist
		return
	end
	if fields and metatool.form.handlers[formname].on_receive then
		local playername = player:get_player_name()
		local data = formdata[playername]
		local name = data and data.name
		if name ~= formname then
			minetest.chat_send_player(playername, "Bug: Form name mismatch: " .. formname)
			return true
		end
		local secure = data and data.nonce == matcher()
		local result
		-- call actual form handler
		if secure then
			result = metatool.form.handlers[formname].on_receive(player, fields, data.data, secure)
		elseif not fields.quit then
			minetest.chat_send_player(playername, "Bug: Invalid security token for form " .. formname)
		end
		if result and not fields.quit then
			minetest.close_formspec(playername, formname)
		end
		if fields.quit and data then
			formdata[playername] = nil
		elseif result == false then
			-- Update formspec and send to player
			metatool.form.show(player, formname, data.data)
		elseif type(result) == "string" then
			-- Switch formspec and send to player
			metatool.form.show(player, result, data.data)
		end
	end
	-- this was our form, tell server to stop processing callbacks
	return true
end

function metatool.form.on_create(player, formname, data)
	if has_form(formname) and type(metatool.form.handlers[formname].on_create) == "function" then
		-- Use callback to get formspec definition
		return metatool.form.handlers[formname].on_create(player, data)
	end
end

-- on_create should be function that returns Form object.
-- on_receive is function that receives fields when form is submitted, can be nil.
function metatool.form.register_form(formname, formdef)
	local name = get_formname(formname)
	if not name then
		print(S("metatool.form.register_form Registration failed, invalid formname: %s", formname))
		return
	end
	if type(formdef) ~= "table" then
		print(S("metatool.form.register_form Registration failed, invalid formdef type: %s", type(formdef)))
		return
	end
	metatool.form.register_global_handler()
	print(S("metatool.form.register_form Registering form: %s", name))
	metatool.form.handlers[name] = {
		on_create = formdef.on_create,
		on_receive = formdef.on_receive,
	}
end

-- display formspec to player, if optional data variable is given then it will be
-- saved and forwarded to on_create and on_receive form handler callback functions.
function metatool.form.show(player, formname, data)
	local name = get_formname(formname)
	if has_form(name) then
		-- Construct form
		local nonce = generate_nonce()
		local form = metatool.form.on_create(player, name, data)
		local playername = player:get_player_name()
		if type(form) ~= "table" then
			minetest.chat_send_player(playername, "Bug: Attempt to open invalid form " .. formname)
			return
		end
		if metatool.form.handlers[name].on_receive then
			-- Store temporary data ref if form input is processed somehow
			formdata[playername] = {
				name = name,
				nonce = nonce,
				data = data,
			}
		end
		-- Show form to player
		minetest.show_formspec(playername, name .. "~" .. nonce, form:render())
	else
		minetest.chat_send_player(player:get_player_name(), "Bug: Metatool form does not exist " .. formname)
	end
end
