local tex = modlib.tex

local paths = modlib.minetest.media.paths
local function read_png(fname)
	if fname == "blank.png" then return tex.new{w=1,h=1,0} end
	return tex.read_png(assert(paths[fname]))
end

local gt = {}

-- TODO colorizehsl, hsl, contrast
-- TODO (...) inventorycube; this is nontrivial.

function gt:file()
	return read_png(self.filename)
end

function gt:opacity()
	local t = self.base:gen_tex()
	t:opacity(self.ratio / 255)
	return t
end

function gt:invert()
	local t = self.base:gen_tex()
	t:invert(self.r, self.g, self.b, self.a)
	return t
end

function gt:brighten()
	local t = self.base:gen_tex()
	t:brighten()
	return t
end

function gt:noalpha()
	local t = self.base:gen_tex()
	t:noalpha()
	return t
end

function gt:makealpha()
	local t = self.base:gen_tex()
	t:makealpha(self.r, self.g, self.b)
	return t
end

function gt:multiply()
	local c = self.color
	local t = self.base:gen_tex()
	t:multiply_rgb(c.r, c.g, c.b)
	return t
end

function gt:screen()
	local c = self.color
	local t = self.base:gen_tex()
	t:screen_blend_rgb(c.r, c.g, c.b)
	return t
end

function gt:colorize()
	local c = self.color
	local t = self.base:gen_tex()
	t:colorize(c.r, c.g, c.b, self.ratio)
	return t
end

local function resized_to_larger(a, b)
	if a.w * a.h > b.w * b.h then
		b = b:resized(a.w, a.h)
	else
		a = a:resized(b.w, b.h)
	end
	return a, b
end

function gt:mask()
	local a, b = resized_to_larger(self.base:gen_tex(), self._mask:gen_tex())
	a:band(b)
	return a
end

function gt:lowpart()
	local t = self.base:gen_tex()
	local over = self.over:gen_tex()
	local lowpart_h = math.ceil(self.percent/100 * over.h) -- TODO (?) ceil or floor
	if lowpart_h > 0 then
		t, over = resized_to_larger(t, over)
		local y = over.h - lowpart_h + 1
		over:crop(1, y, over.w, over.h)
		t:blit(1, y, over)
	end
	return t
end

function gt:resize()
	return self.base:gen_tex():resized(self.w, self.h)
end

function gt:combine()
	local t = tex.filled(self.w, self.h, 0)
	for _, blt in ipairs(self.blits) do
		t:blit(blt.x + 1, blt.y + 1, blt.texture:gen_tex())
	end
	return t
end

function gt:fill()
	if self.base then
		return self.base:gen_tex():fill(self.w, self.h, self.x, self.y, self.color:to_number())
	end
	return tex.filled(self.w, self.h, self.color:to_number())
end

function gt:blit()
	local t, o = resized_to_larger(self.base:gen_tex(), self.over:gen_tex())
	t:blit(1, 1, o)
	return t
end

function gt:hardlight()
	local t, o = resized_to_larger(self.base:gen_tex(), self.over:gen_tex())
	t:hardlight_blend(o)
	return t
end

-- TODO (...?) optimize this
function gt:transform()
	local t = self.base:gen_tex()
	if self.flip_axis == "x" then
		t:flip_x()
	elseif self.flip_axis == "y" then
		t:flip_y()
	end
	-- TODO implement counterclockwise rotations to get rid of this hack
	for _ = 1, 360 - self.rotation_deg / 90 do
		t = t:rotated_90()
	end
	return t
end

local frame = function(t, frame, framecount)
	local fh = math.floor(t.h / framecount)
	t:crop(1, frame * fh + 1, t.w, (frame + 1) * fh)
end

local crack = function(self, o)
	local crack = read_png"crack_anylength.png"
	frame(crack, self.frame, math.floor(crack.h / crack.w))
	local t = self.base:gen_tex()
	local tile_w, tile_h = math.floor(t.w / self.tilecount), math.floor(t.h / self.framecount)
	crack = crack:resized(tile_w, tile_h)
	for ty = 1, t.h, tile_h do
		for tx = 1, t.w, tile_w do
			t[o and "blito" or "blit"](t, tx, ty, crack)
		end
	end
	return t
end

function gt:crack()
	return crack(self, false)
end

function gt:cracko()
	return crack(self, true)
end

function gt:verticalframe()
	local t = self.base:gen_tex()
	frame(t, self.frame, self.framecount)
	return t
end

function gt:sheet()
	local t = self.base:gen_tex()
	local tw, th = math.floor(t.w / self.w), math.floor(t.h / self.h)
	local x, y = self.x, self.y
	t:crop(x * tw + 1, y * th + 1, (x + 1) * tw, (y + 1) * th)
	return t
end

function gt:png()
	return tex.read_png_string(self.data)
end

return function(self)
	return assert(gt[self.type])(self)
end
