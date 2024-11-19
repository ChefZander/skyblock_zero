--[[
	This file does not follow the usual conventions;
	it duplicates some code for performance reasons.

	In particular, use of `modlib.minetest.colorspec` is avoided.

	Most methods operate *in-place* (imperative method names)
	rather than returning a modified copy (past participle method names).

	Outside-facing methods consistently use 1-based indexing; indices are inclusive.
]]

local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local function round(x) return floor(x + 0.5) end
local function clamp(x, mn, mx) return max(min(x, mx), mn) end

-- ARGB handling utilities

local function unpack_argb(argb)
	return floor(argb / 0x1000000),
			floor(argb / 0x10000) % 0x100,
			floor(argb / 0x100) % 0x100,
			argb % 0x100
end

local function pack_argb(a, r, g, b)
	local argb = (((a * 0x100 + r) * 0x100) + g) * 0x100 + b
	return argb
end

local function round_argb(a, r, g, b)
	return round(a), round(r), round(g), round(b)
end

local function scale_0_1_argb(a, r, g, b)
	return a / 255, r / 255, g / 255, b / 255
end

local function scale_0_255_argb(a, r, g, b)
	return a * 255, r * 255, g * 255, b * 255
end

local tex = {}
local metatable = {__index = tex}

function metatable:__eq(other)
	if self.w ~= other.w or self.h ~= other.h then return false end
	for i = 1, #self do	if self[i] ~= other[i] then return false end end
	return true
end

function tex:new()
	return setmetatable(self, metatable)
end

function tex.filled(w, h, argb)
	local self = {w = w, h = h}
	for i = 1, w*h do
		self[i] = argb
	end
	return tex.new(self)
end

function tex:copy()
	local copy = {w = self.w, h = self.h}
	for i = 1, #self do
		copy[i] = self[i]
	end
	return tex.new(copy)
end

-- Reading & writing

function tex.read_png_string(str)
	local stream = modlib.text.inputstream(str)
	local png = modlib.minetest.decode_png(stream)
	assert(stream:read(1) == nil, "eof expected")
	modlib.minetest.convert_png_to_argb8(png)
	png.data.w, png.data.h = png.width, png.height
	return tex.new(png.data)
end

function tex.read_png(path)
	local png
	modlib.file.with_open(path, "rb", function(f)
		png = modlib.minetest.decode_png(f)
		assert(f:read(1) == nil, "eof expected")
	end)
	modlib.minetest.convert_png_to_argb8(png)
	png.data.w, png.data.h = png.width, png.height
	return tex.new(png.data)
end

function tex:write_png_string()
	return modlib.minetest.encode_png(self.w, self.h, self)
end

function tex:write_png(path)
	modlib.file.write_binary(path, self:write_png_string())
end

function tex:fill(sx, sy, argb)
	local w, h = self.w, self.h
	for y = sy, h do
		local i = (y - 1) * w + sx
		for _ = sx, w do
			self[i] = argb
			i = i + 1
		end
	end
end

function tex:in_bounds(x, y)
	return x >= 1 and y >= 1 and x <= self.w and y <= self.h
end

function tex:get_argb_packed(x, y)
	return self[(y - 1) * self.w + x]
end

function tex:get_argb(x, y)
	return unpack_argb(self[(y - 1) * self.w + x])
end

function tex:set_argb_packed(x, y, argb)
	self[(y - 1) * self.w + x] = argb
end

function tex:set_argb(x, y, a, r, g, b)
	self[(y - 1) * self.w + x] = pack_argb(a, r, g, b)
end

function tex:map_argb(func)
	for i = 1, #self do
		self[i] = pack_argb(func(unpack_argb(self[i])))
	end
end

local function blit(s, x, y, t, o)
	local sw, sh = s.w, s.h
	local tw, th = t.w, t.h
	-- Restrict to overlapping region
	x, y = clamp(x, 1, sw), clamp(y, 1, sh)
	local min_tx, min_ty = max(1, 2 - x), max(1, 2 - y)
	local max_tx, max_ty = min(tw, sw - x + 1), min(th, sh - y + 1)
	for ty = min_ty, max_ty do
		local ti, si = (ty - 1) * tw, (y + ty - 2) * sw + x - 1
		for _ = min_tx, max_tx do
			ti, si = ti + 1, si + 1
			local sa, sr, sg, sb = scale_0_1_argb(unpack_argb(s[si]))
			if sa == 1 or not o then -- HACK because of dirty `[cracko`
				local ta, tr, tg, tb = scale_0_1_argb(unpack_argb(t[ti]))
				-- "`t` over `s`" (Porter-Duff-Algorithm)
				local sata = sa * (1 - ta)
				local ra = ta + sata
				assert(ra > 0 or (sa == 0 and ta == 0))
				if ra > 0 then
					s[si] = pack_argb(round_argb(scale_0_255_argb(
						ra,
						(ta * tr + sata * sr) / ra,
						(ta * tg + sata * sg) / ra,
						(ta * tb + sata * sb) / ra
					)))
				end
			end
		end
	end
end

-- Blitting with proper alpha blending.
function tex.blit(s, x, y, t)
	return blit(s, x, y, t, false)
end

-- Blit, but only on fully opaque base pixels. Only `[cracko` uses this.
function tex.blito(s, x, y, t)
	return blit(s, x, y, t, true)
end

function tex.combine_argb(s, t, cf)
	assert(#s == #t)
	for i = 1, #s do
		s[i] = cf(s[i], t[i])
	end
end

-- See https://github.com/TheAlgorithms/Lua/blob/162c4c59f5514c6115e0add8a2b4d56afd6d3204/src/bit/uint53/and.lua
-- TODO (?) optimize fallback band using caching, move somewhere else
local band = bit and bit.band or function(n, m)
	local res = 0
	local bit = 1
	while n * m ~= 0 do -- while both are nonzero
		local n_bit, m_bit = n % 2, m % 2 -- extract LSB
		res = res + (n_bit * m_bit) * bit -- add AND of LSBs
		n, m = (n - n_bit) / 2, (m - m_bit) / 2 -- remove LSB from n & m
		bit = bit * 2 -- next bit
	end
	return res
end

function tex.band(s, t)
	return s:combine_argb(t, band)
end

function tex.hardlight_blend(s, t)
	return s:combine_argb(t, function(sargb, targb)
		local sa, sr, sg, sb = scale_0_1_argb(unpack_argb(sargb))
		local _, tr, tg, tb = scale_0_1_argb(unpack_argb(targb))
		return pack_argb(round_argb(scale_0_255_argb(
			sa,
			sr < 0.5 and 2*sr*tr or 1 - 2*(1-sr)*(1-tr),
			sr < 0.5 and 2*sg*tg or 1 - 2*(1-sg)*(1-tg),
			sr < 0.5 and 2*sb*tb or 1 - 2*(1-sb)*(1-tb)
		)))
	end)
end

function tex:brighten()
	return self:map_argb(function(a, r, g, b)
		return round_argb((255 + a) / 2, (255 + r) / 2, (255 + g) / 2, (255 + b) / 2)
	end)
end

function tex:noalpha()
	for i = 1, #self do
		self[i] = 0xFF000000 + self[i] % 0x1000000
	end
end

function tex:makealpha(r, g, b)
	local mrgb = r * 0x10000 + g * 0x100 + b
	for i = 1, #self do
		local rgb = self[i] % 0x1000000
		if rgb == mrgb then
			self[i] = rgb
		end
	end
end

function tex:opacity(factor)
	for i = 1, #self do
		self[i] = round(floor(self[i] / 0x1000000) * factor) * 0x1000000 + self[i] % 0x1000000
	end
end

function tex:invert(ir, ig, ib, ia)
	return self:map_argb(function(a, r, g, b)
		if ia then a = 255 - a end
		if ir then r = 255 - r end
		if ig then g = 255 - g end
		if ib then b = 255 - b end
		return a, r, g, b
	end)
end

function tex:multiply_rgb(r, g, b)
	return self:map_argb(function(sa, sr, sg, sb)
		return round_argb(sa, r * sr, g * sg, b * sb)
	end)
end

function tex:screen_blend_rgb(r, g, b)
	return self:map_argb(function(sa, sr, sg, sb)
		return round_argb(sa,
			255 - ((255 - sr) * (255 - r)) / 255,
			255 - ((255 - sg) * (255 - g)) / 255,
			255 - ((255 - sb) * (255 - b)) / 255)
	end)
end

function tex:colorize(cr, cg, cb, ratio)
	return self:map_argb(function(a, r, g, b)
		local rat = ratio == "alpha" and a or ratio
		return round_argb(
			a,
			rat * r + (1 - rat) * cr,
			rat * g + (1 - rat) * cg,
			rat * b + (1 - rat) * cb
		)
	end)
end

function tex:crop(from_x, from_y, to_x, to_y)
	local w = self.w
	local i = 1
	for y = from_y, to_y do
		local j = (y - 1) * w + from_x
		for _ = from_x, to_x do
			self[i] = self[j]
			i, j = i + 1, j + 1
		end
	end
	-- Remove remaining pixels
	for j = i, #self do self[j] = nil end
	self.w, self.h = to_x - from_x + 1, to_y - from_y + 1
end

function tex:flip_x()
	for y = 1, self.h do
		local i = (y - 1) * self.w
		local j = i + self.w + 1
		while i < j do
			i, j = i + 1, j - 1
			self[i], self[j] = self[j], self[i]
		end
	end
end

function tex:flip_y()
	for x = 1, self.w do
		local i, j = x, (self.h - 1) * self.w + x
		while i < j do
			i, j = i + self.w, j - self.w
			self[i], self[j] = self[j], self[i]
		end
	end
end

--> copy of the texture, rotated 90 degrees clockwise
function tex:rotated_90()
	local w, h = self.w, self.h
	local t = {w = h, h = w}
	local i = 0
	for y = 1, w do
		for x = 1, h do
			i = i + 1
			t[i] = self[(h-x)*w + y]
		end
	end
	t = tex.new(t)
	return t
end

-- Uses box sampling. Hard to optimize.
-- TODO (...) interpolate box samples; match what Minetest does
--> copy of `self` resized to `w` x `h`
function tex:resized(w, h)
	--! This function works with 0-based indices.
	local sw, sh = self.w, self.h
	local fx, fy = sw / w, sh / h
	local t = {w = w, h = h}
	local i = 0
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			-- Sample the area
			local vy_from = y * fy
			local vy_to = vy_from + fy
			local vx_from = x * fx
			local vx_to = vx_from + fx

			local a, r, g, b = 0, 0, 0, 0
			local pf_sum = 0

			local function blend(sx, sy, pf)
				if pf <= 0 then return end
				local sa, sr, sg, sb = unpack_argb(self[sy * sw + sx + 1])
				pf_sum = pf_sum + pf -- TODO (?) eliminate `pf_sum`
				sa = sa * pf
				a = a + sa
				r, g, b = r + sa * sr, g + sa * sg, b + sa * sb
			end

			local function srow(sy, pf)
				if pf <= 0 then return end
				local sx_from, sx_to = ceil(vx_from), floor(vx_to)
				for sx = sx_from, sx_to - 1 do blend(sx, sy, pf) end -- whole pixels
				-- Pixels at edges
				blend(floor(vx_from), sy, pf * (sx_from - vx_from))
				blend(floor(vx_to), sy, pf * (vx_to - sx_to))
			end

			local sy_from, sy_to = ceil(vy_from), floor(vy_to)
			for sy = sy_from, sy_to - 1 do srow(sy, 1) end -- whole pixels
			-- Pixels at edges
			srow(floor(vy_from), sy_from - vy_from)
			srow(floor(vy_to), vy_to - sy_to)
			if a > 0 then r, g, b = r / a, g / a, b / a end
			assert(pf_sum > 0)
			i = i + 1
			t[i] = pack_argb(round_argb(a / pf_sum, r, g, b))
		end
	end
	return tex.new(t)
end

return tex
