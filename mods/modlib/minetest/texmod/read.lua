local texmod = ...
local colorspec = modlib.minetest.colorspec

-- Generator readers

local gr = {}

function gr.png(r)
	r:expect":"
	local base64 = r:match_str"[a-zA-Z0-9+/=]"
	return assert(minetest.decode_base64(base64), "invalid base64")
end

function gr.inventorycube(r)
	local top = r:invcubeside()
	local left = r:invcubeside()
	local right = r:invcubeside()
	return top, left, right
end

function gr.combine(r)
	r:expect":"
	local w = r:int()
	r:expect"x"
	local h = r:int()
	local blits = {}
	while r:match":" do
		if r.eof then break end -- we can just end with `:`, right?
		local x = r:int()
		r:expect","
		local y = r:int()
		r:expect"="
		table.insert(blits, {x = x, y = y, texture = r:subtexp()})
	end
	return w, h, blits
end

function gr.fill(r)
	r:expect":"
	local w = r:int()
	r:expect"x"
	local h = r:int()
	r:expect":"
	-- Be strict(er than Minetest): Do not accept x, y for a base
	local color = r:colorspec()
	return w, h, color
end

-- Parameter readers

local pr = {}

function pr.fill(r)
	r:expect":"
	local w = r:int()
	r:expect"x"
	local h = r:int()
	r:expect":"
	if assert(r:peek(), "unexpected eof"):find"%d" then
		local x = r:int()
		r:expect","
		local y = r:int()
		r:expect":"
		local color = r:colorspec()
		return w, h, x, y, color
	end
	local color = r:colorspec()
	return w, h, color
end

function pr.brighten() end

function pr.noalpha() end

function pr.resize(r)
	r:expect":"
	local w = r:int()
	r:expect"x"
	local h = r:int()
	return w, h
end

function pr.makealpha(r)
	r:expect":"
	local red = r:int()
	r:expect","
	local green = r:int()
	r:expect","
	local blue = r:int()
	return red, green, blue
end

function pr.opacity(r)
	r:expect":"
	local ratio = r:int()
	return ratio
end

function pr.invert(r)
	r:expect":"
	local channels = {}
	while true do
		local c = r:match_charset"[rgba]"
		if not c then break end
		channels[c] = true
	end
	return channels
end

do
	function pr.transform(r)
		if r:match_charset"[iI]" then
			return pr.transform(r)
		end
		local idx = r:match_charset"[0-7]"
		if idx then
			return tonumber(idx), pr.transform(r)
		end
		if r:match_charset"[fF]" then
			local flip_axis = assert(r:match_charset"[xXyY]", "axis expected")
			return "f" .. flip_axis, pr.transform(r)
		end
		if r:match_charset"[rR]" then
			local deg = r:match_str"%d"
			-- Be strict here: Minetest won't recognize other ways to write these numbers (or other numbers)
			assert(deg == "90" or deg == "180" or deg == "270")
			return ("r%d"):format(deg), pr.transform(r)
		end
		-- return nothing, we're done
	end
end

function pr.verticalframe(r)
	r:expect":"
	local framecount = r:int()
	r:expect":"
	local frame = r:int()
	return framecount, frame
end

function pr.crack(r)
	r:expect":"
	local framecount = r:int()
	r:expect":"
	local frame = r:int()
	if r:match":" then
		return framecount, frame, r:int()
	end
	return framecount, frame
end
pr.cracko = pr.crack

function pr.sheet(r)
	r:expect":"
	local w = r:int()
	r:expect"x"
	local h = r:int()
	r:expect":"
	local x = r:int()
	r:expect","
	local y = r:int()
	return w, h, x, y
end

function pr.multiply(r)
	r:expect":"
	return r:colorspec()
end
pr.screen = pr.multiply

function pr.colorize(r)
	r:expect":"
	local color = r:colorspec()
	if not r:match":" then
		return color
	end
	if not r:match"a" then
		return color, r:int()
	end
	for c in ("lpha"):gmatch"." do
		r:expect(c)
	end
	return color, "alpha"
end

function pr.colorizehsl(r)
	r:expect":"
	local hue = r:int()
	if not r:match":" then
		return hue
	end
	local saturation = r:int()
	if not r:match":" then
		return hue, saturation
	end
	local lightness = r:int()
	return hue, saturation, lightness
end
pr.hsl = pr.colorizehsl

function pr.contrast(r)
	r:expect":"
	local contrast = r:int()
	if not r:match":" then
		return contrast
	end
	local brightness = r:int()
	return contrast, brightness
end

function pr.overlay(r)
	r:expect":"
	return r:subtexp()
end

function pr.hardlight(r)
	r:expect":"
	return r:subtexp()
end

function pr.mask(r)
	r:expect":"
	return r:subtexp()
end

function pr.lowpart(r)
	r:expect":"
	local percent = r:int()
	assert(percent)
	r:expect":"
	return percent, r:subtexp()
end

-- Build a prefix tree of parameter readers to greedily match the longest texture modifier prefix;
-- just matching `%a+` and looking it up in a table
-- doesn't work since `[transform` may be followed by a lowercase transform name
-- TODO (?...) consolidate with `modlib.trie`
local texmod_reader_trie = {}
for _, readers in pairs{pr, gr} do
	for type in pairs(readers) do
		local subtrie = texmod_reader_trie
		for char in type:gmatch"." do
			subtrie[char] = subtrie[char] or {}
			subtrie = subtrie[char]
		end
		subtrie.type = type
	end
end

-- Reader methods. We use `r` instead of the `self` "sugar" for consistency (and to save us some typing).
local rm = {}

function rm.peek(r, parenthesized)
	if r.eof then return end
	local expected_escapes = 0
	if r.level > 0 then
		-- Premature optimization my beloved (this is `2^(level-1)`)
		expected_escapes = math.ldexp(0.5, r.level)
	end
	if r.character:match"[&^:]" then -- "special" characters - these need to be escaped
		if r.escapes == expected_escapes then
			return r.character
		elseif parenthesized and r.character == "^" and r.escapes < expected_escapes then
			-- Special handling for `^` inside `(...)`: This is undocumented behavior but works in Minetest
			r.warn"parenthesized caret (`^`) with too few escapes"
			return r.character
		end
	elseif r.escapes <= expected_escapes then
		return r.character
	end if r.escapes >= 2*expected_escapes then
		return "\\"
	end
end
function rm.popchar(r)
	assert(not r.eof, "unexpected eof")
	r.escapes = 0
	while true do
		r.character = r:read_char()
		if r.character ~= "\\" then break end
		r.escapes = r.escapes + 1
	end
	if r.character == nil then
		assert(r.escapes == 0, "end of texmod expected")
		r.eof = true
	end
end
function rm.pop(r)
	local expected_escapes = 0
	if r.level > 0 then
		-- Premature optimization my beloved (this is `2^(level-1)`)
		expected_escapes = math.ldexp(0.5, r.level)
	end
	if r.escapes > 0 and r.escapes >= 2*expected_escapes then
		r.escapes = r.escapes - 2*expected_escapes
		return
	end
	return r:popchar()
end
function rm.match(r, char)
	if r:peek() == char then
		r:pop()
		return true
	end
end
function rm.expect(r, char)
	if not r:match(char) then
		error(("%q expected"):format(char))
	end
end
function rm.hat(r, parenthesized)
	if r:peek(parenthesized) == (r.invcube and "&" or "^") then
		r:pop()
		return true
	end
end
function rm.match_charset(r, set)
	local char = r:peek()
	if char and char:match(set) then
		r:pop()
		return char
	end
end
function rm.match_str(r, set)
	local c = r:match_charset(set)
	if not c then
		error(("character in %s expected"):format(set))
	end
	local t = {c}
	while true do
		c = r:match_charset(set)
		if not c then break end
		table.insert(t, c)
	end
	return table.concat(t)
end
function rm.int(r)
	local sign = 1
	if r:match"-" then sign = -1 end
	return sign * tonumber(r:match_str"%d")
end
function rm.fname(r)
	-- This is overly permissive, as is Minetest;
	-- we just allow arbitrary characters up until a character which may terminate the name.
	-- Inside an inventorycube, `&` also terminates names.
	-- Note that the constructor will however - unlike Minetest - perform validation.
	-- We could leverage the knowledge of the allowed charset here already,
	-- but that might lead to more confusing error messages.
	return r:match_str(r.invcube and "[^:^&){]" or "[^:^){]")
end
function rm.subtexp(r)
	r.level = r.level + 1
	local res = r:texp()
	r.level = r.level - 1
	return res
end
function rm.invcubeside(r)
	assert(not r.invcube, "can't nest inventorycube")
	r.invcube = true
	assert(r:match"{", "'{' expected")
	local res = r:texp()
	r.invcube = false
	return res
end
function rm.basexp(r)
	if r:match"(" then
		local res = r:texp(true)
		r:expect")"
		return res
	end
	if r:match"[" then
		local type = r:match_str"%a"
		local gen_reader = gr[type]
		if not gen_reader then
			error("invalid texture modifier: " .. type)
		end
		return texmod[type](gen_reader(r))
	end
	return texmod.file(r:fname())
end
function rm.colorspec(r)
	-- Leave exact validation up to colorspec, only do a rough greedy charset matching
	return assert(colorspec.from_string(r:match_str"[#%x%a]"))
end
function rm.texp(r, parenthesized)
	local base = r:basexp() -- TODO (?) make optional - warn about omitting the base
	while r:hat(parenthesized) do
		if r:match"[" then
			local reader_subtrie = texmod_reader_trie
			while true do
				local next_subtrie = reader_subtrie[r:peek()]
				if next_subtrie then
					reader_subtrie = next_subtrie
					r:pop()
				else
					break
				end
			end
			local type = assert(reader_subtrie.type, "invalid texture modifier")
			local param_reader, gen_reader = pr[type], gr[type]
			assert(param_reader or gen_reader)
			if param_reader then
				-- Note: It is important that this takes precedence to properly handle `[fill`
				base = base[type](base, param_reader(r))
			elseif gen_reader then
				base = base:blit(texmod[type](gen_reader(r)))
			end
			-- TODO (?...) we could consume leftover parameters here to be as lax as Minetest
		else
			base = base:blit(r:basexp())
		end
	end
	return base
end

local mt = {__index = rm}
return function(read_char, warn --[[function(str)]])
	local r = setmetatable({
		level = 0,
		invcube = false,
		parenthesized = false,
		eof = false,
		read_char = read_char,
		warn = warn or error,
	}, mt)
	r:popchar()
	local res = r:texp(false)
	assert(r.eof, "eof expected")
	return res
end
