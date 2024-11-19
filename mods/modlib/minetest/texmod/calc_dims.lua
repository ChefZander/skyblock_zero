local cd = {}

local function calc_dims(self, get_file_dims)
	return assert(cd[self.type])(self, get_file_dims)
end

function cd:file(d)
	return d(self.filename)
end

do
	local function base_dim(self, get_dims) return calc_dims(self.base, get_dims) end
	cd.opacity = base_dim
	cd.invert = base_dim
	cd.brighten = base_dim
	cd.noalpha = base_dim
	cd.makealpha = base_dim
	cd.lowpart = base_dim
	cd.mask = base_dim
	cd.multiply = base_dim
	cd.colorize = base_dim
	cd.colorizehsl = base_dim
	cd.hsl = base_dim
	cd.screen = base_dim
	cd.contrast = base_dim
end

do
	local function wh(self) return self.w, self.h end
	cd.resize = wh
	cd.combine = wh
end

function cd:fill(get_dims)
	if self.base then return calc_dims(self.base, get_dims) end
	return self.w, self.h
end

do
	local function upscale_to_higher_res(self, get_dims)
		local base_w, base_h = calc_dims(self.base, get_dims)
		local over_w, over_h = calc_dims(self.over, get_dims)
		if base_w * base_h > over_w * over_h then
			return base_w, base_h
		end
		return over_w, over_h
	end
	cd.blit = upscale_to_higher_res
	cd.hardlight = upscale_to_higher_res
end

function cd:transform(get_dims)
	if self.rotation_deg % 180 ~= 0 then
		local base_w, base_h = calc_dims(self.base, get_dims)
		return base_h, base_w
	end
	return calc_dims(self.base, get_dims)
end

do
	local math_clamp = modlib.math.clamp
	local function next_pow_of_2(x)
		-- I don't want to use a naive 2^ceil(log(x)/log(2)) due to possible float precision issues.
		local m, e = math.frexp(x) -- x = _*2^e, _ in [0.5, 1)
		if m == 0.5 then e = e - 1 end -- x = 2^(e-1)
		return math.ldexp(1, e) -- 2^e, premature optimization here we go
	end
	function cd:inventorycube(get_dims)
		local top_w, top_h = calc_dims(self.top, get_dims)
		local left_w, left_h = calc_dims(self.left, get_dims)
		local right_w, right_h = calc_dims(self.right, get_dims)
		local d = math_clamp(next_pow_of_2(math.max(top_w, top_h, left_w, left_h, right_w, right_h)), 2, 64)
		return d, d
	end
end

do
	local function frame_dims(self, get_dims)
		local base_w, base_h = calc_dims(self.base, get_dims)
		return base_w, math.floor(base_h / self.framecount)
	end
	cd.verticalframe = frame_dims
	cd.crack = frame_dims
	cd.cracko = frame_dims
end

function cd:sheet(get_dims)
	local base_w, base_h = calc_dims(self.base, get_dims)
	return math.floor(base_w / self.w), math.floor(base_h / self.h)
end

function cd:png()
	local png = modlib.minetest.decode_png(modlib.text.inputstream(self.data))
	return png.width, png.height
end

return calc_dims
