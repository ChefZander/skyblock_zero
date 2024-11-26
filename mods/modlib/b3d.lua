-- Localize globals
local assert, error, math, modlib, next, ipairs, pairs, setmetatable, string_char, table
	= assert, error, math, modlib, next, ipairs, pairs, setmetatable, string.char, table

local mat4 = modlib.matrix4

local read_int, read_single = modlib.binary.read_int, modlib.binary.read_single

local write_int, write_uint, write_single = modlib.binary.write_int, modlib.binary.write_uint, modlib.binary.write_single

local fround = modlib.math.fround

-- Set environment
local _ENV = {}
setfenv(1, _ENV)

local metatable = {__index = _ENV}

--+ Reads a single BB3D chunk from a stream
--+ Doing `assert(stream:read(1) == nil)` afterwards is recommended
--+ See `b3d_specification.txt` as well as https://github.com/blitz-research/blitz3d/blob/master/blitz3d/loader_b3d.cpp
--> B3D model
function read(stream)
	local left = 8

	local function byte()
		left = left - 1
		return assert(stream:read(1):byte())
	end

	local function int()
		return read_int(byte, 4)
	end

	local function id()
		return int() + 1
	end

	local function optional_id()
		local id = int()
		if id == -1 then
			return
		end
		return id + 1
	end

	local function string()
		local rope = {}
		while true do
			left = left - 1
			local char = assert(stream:read(1))
			if char == "\0" then
				return table.concat(rope)
			end
			table.insert(rope, char)
		end
	end

	local function float()
		return read_single(byte)
	end

	local function float_array(length)
		local list = {}
		for index = 1, length do
			list[index] = float()
		end
		return list
	end

	local function color()
		local ret = {}
		ret.r = float()
		ret.g = float()
		ret.b = float()
		ret.a = float()
		return ret
	end

	local function vector3()
		return float_array(3)
	end

	local function quaternion()
		local w = float()
		local x = float()
		local y = float()
		local z = float()
		return {x, y, z, w}
	end

	local function content()
		if left < 0 then
			error(("unexpected EOF at position %d"):format(stream:seek()))
		end
		return left ~= 0
	end

	local chunk
	local chunks = {
		TEXS = function()
			local textures = {}
			while content() do
				local tex = {}
				tex.file = string()
				tex.flags = int()
				tex.blend = int()
				tex.pos = float_array(2)
				tex.scale = float_array(2)
				tex.rotation = float()
				table.insert(textures, tex)
			end
			return textures
		end,
		BRUS = function()
			local brushes = {}
			local n_texs = int()
			assert(n_texs <= 8)
			while content() do
				local brush = {}
				brush.name = string()
				brush.color = color()
				brush.shininess = float()
				brush.blend = int()
				brush.fx = int()
				brush.texture_id = {}
				for index = 1, n_texs do
					brush.texture_id[index] = optional_id()
				end
				table.insert(brushes, brush)
			end
			return brushes
		end,
		VRTS = function()
			local vertices = {}
			vertices.flags = int()
			vertices.tex_coord_sets = int()
			vertices.tex_coord_set_size = int()
			assert(vertices.tex_coord_sets <= 8 and vertices.tex_coord_set_size <= 4)
			local has_normal = (vertices.flags % 2 == 1) or nil
			local has_color = (math.floor(vertices.flags / 2) % 2 == 1) or nil
			while content() do
				local vertex = {}
				vertex.pos = vector3()
				vertex.normal = has_normal and vector3()
				vertex.color = has_color and color()
				vertex.tex_coords = {}
				for tex_coord_set = 1, vertices.tex_coord_sets do
					local tex_coords = {}
					for tex_coord = 1, vertices.tex_coord_set_size do
						tex_coords[tex_coord] = float()
					end
					vertex.tex_coords[tex_coord_set] = tex_coords
				end
				table.insert(vertices, vertex)
			end
			return vertices
		end,
		TRIS = function()
			local tris = {}
			tris.brush_id = id()
			tris.vertex_ids = {}
			while content() do
				local i = id()
				local j = id()
				local k = id()
				table.insert(tris.vertex_ids, {i, j, k})
			end
			return tris
		end,
		MESH = function()
			local mesh = {}
			mesh.brush_id = optional_id()
			mesh.vertices = chunk{VRTS = true}
			mesh.triangle_sets = {}
			repeat
				local tris = chunk{TRIS = true}
				table.insert(mesh.triangle_sets, tris)
			until not content()
			return mesh
		end,
		BONE = function()
			local bone = {}
			while content() do
				local vertex_id = id()
				assert(not bone[vertex_id], "duplicate vertex weight")
				local weight = float()
				if weight > 0 then
					-- Many exporters include unneeded zero weights
					bone[vertex_id] = weight
				end
			end
			return bone
		end,
		KEYS = function()
			local flags = int()
			local _flags = flags % 8
			local rotation, scale, position
			if _flags >= 4 then
				rotation = true
				_flags = _flags - 4
			end
			if _flags >= 2 then
				scale = true
				_flags = _flags - 2
			end
			position = _flags >= 1
			local bone = {
				flags = flags
			}
			while content() do
				local frame = {}
				frame.frame = int()
				if position then
					frame.position = vector3()
				end
				if scale then
					frame.scale = vector3()
				end
				if rotation then
					frame.rotation = quaternion()
				end
				table.insert(bone, frame)
			end
			return bone
		end,
		ANIM = function()
			local ret = {}
			ret.flags = int() -- flags are unused
			ret.frames = int()
			ret.fps = float()
			return ret
		end,
		NODE = function()
			local node = {}
			node.name = string()
			node.position = vector3()
			node.scale = vector3()
			node.keys = {}
			node.rotation = quaternion()
			node.children = {}
			local node_type
			-- See https://github.com/blitz-research/blitz3d/blob/master/blitz3d/loader_b3d.cpp#L263
			-- Order is not validated; double occurrences of mutually exclusive node def are
			while content() do
				local elem, type = chunk()
				if type == "MESH" then
					assert(not node_type)
					node_type = "mesh"
					node.mesh = elem
				elseif type == "BONE" then
					assert(not node_type)
					node_type = "bone"
					node.bone = elem
				elseif type == "KEYS" then
					modlib.table.append(node.keys, elem)
				elseif type == "NODE" then
					table.insert(node.children, elem)
				elseif type == "ANIM" then
					node.animation = elem
				else
					assert(not node_type)
					node_type = "pivot"
				end
			end
			-- Ensure frames are sorted ascendingly
			table.sort(node.keys, function(a, b)
				assert(a.frame ~= b.frame, "duplicate frame")
				return a.frame < b.frame
			end)
			return node
		end,
		BB3D = function()
			local version = int()
			local self = {
				version = {
					major = math.floor(version / 100),
					minor = version % 100,
				},
				textures = {},
				brushes = {}
			}
			assert(self.version.major <= 2, "unsupported version: " .. self.version.major)
			while content() do
				local field, type = chunk{TEXS = true, BRUS = true, NODE = true}
				if type == "TEXS" then
					modlib.table.append(self.textures, field)
				elseif type == "BRUS" then
					modlib.table.append(self.brushes, field)
				else
					self.node = field
				end
			end
			return self
		end
	}

	local function chunk_header()
		left = left - 4
		return stream:read(4), int()
	end

	function chunk(possible_chunks)
		local type, new_left = chunk_header()
		local parent_left
		left, parent_left = new_left, left
		if possible_chunks and not possible_chunks[type] then
			error("expected one of " .. table.concat(modlib.table.keys(possible_chunks), ", ") .. ", found " .. type)
		end
		local res = assert(chunks[type])()
		assert(left == 0)
		left = parent_left - new_left
		return res, type
	end

	local self = chunk{BB3D = true}
	return setmetatable(self, metatable)
end

-- Writer

local function write_rope(self)
	local rope = {}

	local written_len = 0
	local function write(str)
		written_len = written_len + #str
		table.insert(rope, str)
	end

	local function byte(val)
		write(string_char(val))
	end

	local function int(val)
		write_int(byte, val, 4)
	end

	local function id(val)
		int(val - 1)
	end

	local function optional_id(val)
		int(val and (val - 1) or -1)
	end

	local function string(val)
		write(val)
		write"\0"
	end

	local function float(val)
		write_single(byte, fround(val))
	end

	local function float_array(arr, len)
		assert(#arr == len)
		for i = 1, len do
			float(arr[i])
		end
	end

	local function color(val)
		float(val.r)
		float(val.g)
		float(val.b)
		float(val.a)
	end

	local function vector3(val)
		float_array(val, 3)
	end

	local function quaternion(quat)
		float(quat[4])
		float(quat[1])
		float(quat[2])
		float(quat[3])
	end

	local function chunk(name, write_func)
		write(name)

		-- Insert placeholder for the 4-bit len
		table.insert(rope, false)
		written_len = written_len + 4
		local len_idx = #rope -- save index of placeholder

		local prev_written_len = written_len
		write_func()

		-- Write the length of this chunk
		local chunk_len = written_len - prev_written_len
		local len_binary = {}
		write_int(function(byte)
			table.insert(len_binary, string_char(byte))
		end, chunk_len, 4)
		rope[len_idx] = table.concat(len_binary)
	end

	local function NODE(node)
		chunk("NODE", function()
			string(node.name)
			vector3(node.position)
			vector3(node.scale)
			quaternion(node.rotation)
			local mesh = node.mesh
			if mesh then
				chunk("MESH", function()
					optional_id(mesh.brush_id)
					local vertices = mesh.vertices
					chunk("VRTS", function()
						int(vertices.flags)
						int(vertices.tex_coord_sets)
						int(vertices.tex_coord_set_size)
						for _, vertex in ipairs(vertices) do
							vector3(vertex.pos)
							if vertex.normal then vector3(vertex.normal) end
							if vertex.color then color(vertex.color) end
							for tex_coord_set = 1, vertices.tex_coord_sets do
								local tex_coords = vertex.tex_coords[tex_coord_set]
								for tex_coord = 1, vertices.tex_coord_set_size do
									float(tex_coords[tex_coord])
								end
							end
						end
					end)
					for _, triangle_set in ipairs(mesh.triangle_sets) do
						chunk("TRIS", function()
							id(triangle_set.brush_id)
							for _, tri in ipairs(triangle_set.vertex_ids) do
								id(tri[1])
								id(tri[2])
								id(tri[3])
							end
						end)
					end
				end)
			end
			if node.bone then
				chunk("BONE", function()
					for vertex_id, weight in pairs(node.bone) do
						id(vertex_id)
						float(weight)
					end
				end)
			end
			if node.keys then
				local keys_by_flags = {}
				for _, key in ipairs(node.keys) do
					local flags = 0
					flags = flags
						+ (key.position and 1 or 0)
						+ (key.scale and 2 or 0)
						+ (key.rotation and 4 or 0)
					keys_by_flags[flags] = keys_by_flags[flags] or {}
					table.insert(keys_by_flags[flags], key)
				end
				for flags, keys in pairs(keys_by_flags) do
					chunk("KEYS", function()
						int(flags)
						for _, frame in ipairs(keys) do
							int(frame.frame)
							if frame.position then vector3(frame.position) end
							if frame.scale then vector3(frame.scale) end
							if frame.rotation then quaternion(frame.rotation) end
						end
					end)
				end
			end
			local anim = node.animation
			if anim then
				chunk("ANIM", function()
					int(anim.flags)
					int(anim.frames)
					float(anim.fps)
				end)
			end
			for _, child in ipairs(node.children) do
				NODE(child)
			end
		end)
	end

	chunk("BB3D", function()
		int(self.version.major * 100 + self.version.minor)
		if self.textures[1] then
			chunk("TEXS", function()
				for _, tex in ipairs(self.textures) do
					string(tex.file)
					int(tex.flags)
					int(tex.blend)
					float_array(tex.pos, 2)
					float_array(tex.scale, 2)
					float(tex.rotation)
				end
			end)
		end
		if self.brushes[1] then
			local max_n_texs = 0
			for _, brush in ipairs(self.brushes) do
				for n in pairs(brush.texture_id) do
					if n > max_n_texs then
						max_n_texs = n
					end
				end
			end
			chunk("BRUS", function()
				int(max_n_texs)
				for _, brush in ipairs(self.brushes) do
					string(brush.name)
					color(brush.color)
					float(brush.shininess)
					int(brush.blend)
					int(brush.fx)
					for index = 1, max_n_texs do
						optional_id(brush.texture_id[index])
					end
				end
			end)
		end
		if self.node then
			NODE(self.node)
		end
	end)
	return rope
end

function write_string(self)
	return table.concat(write_rope(self))
end

function write(self, stream)
	for _, str in ipairs(write_rope(self)) do
		stream:write(str)
	end
end

-- B3D to glTF converter
-- See https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html
--! Highly experimental; expect bugs!
do
	-- glTF constants
	local array_buffer = 34962 -- "Buffer containing vertex attributes, such as vertices, texcoords or colors."
	local element_array_buffer = 34963 -- "Buffer used for element indices."
	local component_type = {
		signed_byte = 5120,
		unsigned_byte = 5121,
		signed_short = 5122,
		unsigned_short = 5123,
		unsigned_int = 5125,
		float = 5126,
	}

	-- Coordinate system conversions:
	-- "Blitz 3D uses a left-handed system: X+ is to the right. Y+ is up. Z+ is forward."
	-- "glTF uses a right-handed coordinate system. glTF defines +Y as up, +Z as forward, and -X as right;
	-- the front of a glTF asset faces +Z."

	local function translation_to_gltf(vec)
		return {-vec[1], vec[2], vec[3]} -- invert the X-axis
	end

	local function quaternion_to_gltf(quat)
		-- TODO (!) is this correct?
		return {-quat[1], quat[2], quat[3], quat[4]} -- invert the X-axis
	end

	-- Convert a color from table format to glTF RGBA list format
	local function color_to_gltf(col)
		return {col.r, col.g, col.b, col.a}
	end

	-- Basic helpers for writing to the buffer, all parameterized in terms of `write_byte`

	local function write_index(write_byte, index)
		write_uint(write_byte, index - 1 --[[1-based to 0-based]], 4)
	end

	local function write_float(write_byte, float)
		assert(-math.huge < float and float < math.huge)
		assert(-math.huge < fround(float) and fround(float) < math.huge, ("%.18g got %.18g"):format(float, fround(float)))
		write_single(write_byte, fround(float))
	end

	local function write_floats(write_byte, floats, expected_len)
		assert(#floats == expected_len)
		for i = 1, expected_len do
			write_float(write_byte, floats[i])
		end
	end

	local function write_vector(write_byte, vec)
		return write_floats(write_byte, vec, 3)
	end

	local function write_translation(write_byte, vec)
		return write_vector(write_byte, translation_to_gltf(vec))
	end

	local function write_quaternion(write_byte, quat)
		-- XYZW order is already correct, but we still need to convert left-handed to right-handed
		return write_floats(write_byte, quaternion_to_gltf(quat), 4)
	end

	function to_gltf(self)
		-- Accessor helper: Stores arrays of raw data in a buffer, produces views & accessors.
		-- Everything is dumped in the same large buffer.
		local buffer_rope = {} -- buffer content (table of strings)
		local buffer_views = {} -- glTF buffer views
		local accessors = {} -- glTF accessors
		local offset = 0 -- current byte offset
		local function add_accessor(
			type, -- name of the composite type (e.g. SCALAR, VEC3, VEC4, MAT4, ...)
			comp_type, -- name of the component type (e.g. float, unsigned_int, ...)
			index, -- true / false / nil: whether this is an index (true) or vertex data (false) or neither (nil)
			func -- `function(write_byte) ... return count, min, max end` to be called to write to the buffer view;
			     -- the count of elements written must be returned; min and max may be returned
		)
			-- Always add padding to obtain a multiple of 4
			-- TODO (?) don't add padding if it isn't required
			table.insert(buffer_rope, ("\0"):rep(offset % 4))
			offset = math.ceil(offset / 4) * 4
			local bytes_written = 0
			local count, min, max = func(function(byte)
				table.insert(buffer_rope, string_char(byte))
				bytes_written = bytes_written + 1
			end)
			assert(count)

			-- Add buffer view
			table.insert(buffer_views, {
				buffer = 0, -- 0-based - there only is one buffer
				byteOffset = offset,
				byteLength = bytes_written,
				target = ((index == true) and element_array_buffer) -- index data
					or ((index == false) and array_buffer) -- vertex data
					or nil, -- no target hint
			})
			table.insert(accessors, {
				bufferView = #buffer_views - 1, -- 0-based
				byteOffset = 0, -- view has correct offset
				componentType = assert(component_type[comp_type]),
				type = type,
				count = count,
				min = min,
				max = max,
			})

			offset = offset + bytes_written
			return #accessors - 1 -- 0-based index of the accessor
		end

		local textures = {} -- glTF textures
		local function add_texture(name)
			-- TODO (?) add an appropriate sampler
			table.insert(textures, {name = name})
			return #textures - 1 -- 0-based texture index
		end
		for _, tex in ipairs(self.textures) do
			-- Assert that all values we don't map properly yet are defaults
			-- TODO dig into Blitz3D sources to figure out the meaning of flags & blend
			-- TODO (...) deal with flag value of 65536:
			-- "The flags field value can conditional an additional flag value of '65536'.
			-- This is used to indicate that the texture uses secondary UV values, ala the TextureCoords command."
			assert(tex.flags == 1) -- TODO (?) see https://github.com/blitz-research/blitz3d/blob/master/gxruntime/gxcanvas.h#L59
			assert(tex.blend == 2)
			-- Assert that the texture isn't transformed
			assert(tex.rotation == 0)
			assert(tex.pos[1] == 0 and tex.pos[2] == 0)
			assert(tex.scale[1] == 1 and tex.scale[2] == 1)
			add_texture(tex.file)
		end

		-- Map brushes to materials (& textures)
		local materials = {}
		for i, brush in ipairs(self.brushes) do
			-- Assert defaults
			-- See https://github.com/blitz-research/blitz3d/blob/6beb288cb5962393684a59a4a44ac11524894939/blitz3d/brush.cpp#L164-L167:
			-- 0 = default/replace, 1 = alpha, 2 = multiply, 3 = add
			assert(brush.blend == 1) -- (alpha)
			-- TODO (...) figure out what these "effects" are and if/how to map them to glTF
			assert(brush.fx == 0)
			assert(#brush.texture_id <= 1) -- TODO (...) this supports only a single texture per brush for now
			local index
			if brush.texture_id[1] then
				index = brush.texture_id[1] -- 0-based
			else
				-- Implementations seem to implicitly assume textures for brushes
				index = add_texture(brush.name)
			end
			materials[i] = {
				name = brush.name,
				alphaMode = "BLEND",
				pbrMetallicRoughness = {
					baseColorFactor = color_to_gltf(brush.color),
					metallicFactor = brush.shininess, -- TODO (?) are these really equivalent?
					-- Add texture if there is none
					baseColorTexture = {
						index = index,
						-- `texCoord = 0` is the default already, no need to set it
					},
				},
			}
		end

		local meshes = {}
		local function add_mesh(mesh, weights, add_neutral_bone)
			local attributes = {}

			local vertices = mesh.vertices
			attributes.POSITION = add_accessor("VEC3", "float", false, function(write_byte)
				local inf = math.huge
				local min_pos, max_pos = {inf, inf, inf}, {-inf, -inf, -inf}
				for _, vertex in ipairs(mesh.vertices) do
					local pos = translation_to_gltf(vertex.pos)
					write_vector(write_byte, pos)
					min_pos = modlib.vector.combine(min_pos, pos, math.min)
					max_pos = modlib.vector.combine(max_pos, pos, math.max)
				end
				return #mesh.vertices, min_pos, max_pos -- vertex accessors MUST provide min & max
			end)

			local has_normals = vertices.flags % 2 == 1 -- lowest bit set?
			if has_normals then
				attributes.NORMAL = add_accessor("VEC3", "float", false, function(write_byte)
					for _, vertex in ipairs(mesh.vertices) do
						-- Some B3D models don't seem to have their normals normalized.
						-- TODO (?) raise a warning when handling this gracefully
						write_translation(write_byte, modlib.vector.normalize(vertex.normal))
					end
					return #mesh.vertices
				end)
			end

			local has_colors = vertices.flags % 4 >= 2 -- second lowest bit set?
			if has_colors then
				attributes.COLOR_0 = add_accessor("VEC4", "float", false, function(write_byte)
					for _, vertex in ipairs(mesh.vertices) do
						write_floats(write_byte, color_to_gltf(vertex.color), 4)
					end
					return #mesh.vertices
				end)
			end

			if vertices.tex_coord_sets >= 1 then
				assert(vertices.tex_coord_set_size == 2)
				for tex_coord_set = 1, vertices.tex_coord_sets do
					local tcs_id = tex_coord_set - 1 -- 0-based
					attributes[("TEXCOORD_%d"):format(tcs_id)] = add_accessor("VEC2", "float", false, function(write_byte)
						for _, vertex in ipairs(mesh.vertices) do
							write_floats(write_byte, vertex.tex_coords[tex_coord_set], 2)
						end
						return #mesh.vertices
					end)
				end
			end

			if next(weights) ~= nil then
				-- Count (& pack into list) joints influencing vertices, normalize weights
				local max_count = 0
				local joint_ids = {}
				local normalized_weights = {}
				-- Handle (supposedly) animated/dynamic vertices (can still be static by having zero weights)
				for vertex_id, joint_weights in pairs(weights) do
					local total_weight = 0
					local count = 0
					for _, weight in pairs(joint_weights) do
						total_weight = total_weight + weight
						count = count + 1
					end
					if total_weight > 0 then -- animated?
						joint_ids[vertex_id] = {}
						normalized_weights[vertex_id] = {}
						for joint, weight in pairs(joint_weights) do
							table.insert(joint_ids[vertex_id], joint)
							table.insert(normalized_weights[vertex_id], weight / total_weight)
						end
						max_count = math.max(max_count, count)
					end
				end
				-- Now search for static vertices
				for vertex_id in ipairs(mesh.vertices) do
					if not joint_ids[vertex_id] then
						-- Vertex isn't influenced by any bones => Add a dummy neutral bone to influence this vertex
						-- See https://github.com/KhronosGroup/glTF/issues/2269
						-- and https://github.com/KhronosGroup/glTF-Blender-IO/pull/1552/
						joint_ids[vertex_id] = {add_neutral_bone()}
						normalized_weights[vertex_id] = {1}
						max_count = math.max(max_count, 1) -- it is (theoretically) possible that all vertices are static
					end
				end
				assert(max_count > 0) -- TODO (?) warning for max_count > 4
				for set_start = 1, max_count, 4 do -- Iterate sets of 4 bones
					local set_id = math.floor(set_start / 4) -- 0-based => floor rather than ceil
					-- Write the joint IDs
					attributes[("JOINTS_%d"):format(set_id)] = add_accessor("VEC4", "unsigned_short", false, function(write_byte)
						for vertex_id in ipairs(mesh.vertices) do
							for i = set_start, set_start + 3 do
								local vrt_joint_ids, vrt_norm_weights = assert(joint_ids[vertex_id]), assert(normalized_weights[vertex_id])
								assert(#vrt_joint_ids == #vrt_norm_weights)
								local id = vrt_joint_ids[i] or 0
								local weight = vrt_norm_weights[i] or 0
								if weight == 0 then
									id = 0 -- required by the glTF spec
								end
								write_uint(write_byte, id, 2)
							end
						end
						return #mesh.vertices
					end)
					-- Write the corresponding weights
					attributes[("WEIGHTS_%d"):format(set_id)] = add_accessor("VEC4", "float", false, function(write_byte)
						for vertex_id in ipairs(mesh.vertices) do
							for i = set_start, set_start + 3 do
								local weight = (normalized_weights[vertex_id] or {})[i] or 0
								write_float(write_byte, weight)
							end
						end
						return #mesh.vertices
					end)
				end
			end

			-- Write the indices per triangle set
			local primitives = {}
			for i, triangle_set in ipairs(mesh.triangle_sets) do
				local index_accessor = add_accessor("SCALAR", "unsigned_int", true, function(write_byte)
					for _, tri in ipairs(triangle_set.vertex_ids) do
						-- Flip winding order due to the coordinate system transformation
						-- TODO (!) is this correct?
						for j = 3, 1, -1 do
							write_index(write_byte, tri[j])
						end
					end
					return 3 * #triangle_set.vertex_ids
				end)
				-- Each triangle set is equivalent to one glTF "primitive"
				local brush_id = triangle_set.brush_id or mesh.brush_id
				if brush_id == 0 then -- default brush
					brush_id = nil -- TODO (?) add default material if there are UVs
				else
					brush_id = brush_id - 1 -- 0-based
				end
				primitives[i] = {
					attributes = attributes,
					indices = index_accessor,
					material = brush_id,
					-- `mode = 4` (triangles) is the default already, no need to set it
				}
			end

			table.insert(meshes, {primitives = primitives})
			return #meshes - 1 -- 0-based
		end

		-- glTF lists
		local nodes = {}
		local skins = {}
		local samplers = {}
		local channels = {}
		local function add_node(
			node, -- b3d node to add
			bind_mat, -- bind matrix of the parent bone (may be `nil` if none)
			fps, -- fps of the parent bone (may be `nil` if none)
			anim -- shared animation of the parent mesh
		)
			table.insert(nodes, false) -- HACK first insert a placeholder to get a fixed ID
			local node_id = #nodes - 1 -- 0-indexed <=> before `table.insert`!

			-- Animation (speed)?
			fps = node.animation and node.animation.fps or fps

			-- Keyframes?
			if node.keys then
				-- Convert from a list of keyframes of three overrides to three lists of channels
				local targets = {
					translation = {output_type = "VEC3", b3d_field = "position", write_value = write_translation},
					scale = {output_type = "VEC3", b3d_field = "scale", write_value = write_vector},
					rotation = {output_type = "VEC4", b3d_field = "rotation", write_value = write_quaternion}
				}
				for _, keyframe in ipairs(node.keys) do
					local frame = keyframe.frame
					for _, target in pairs(targets) do
						local value = keyframe[target.b3d_field]
						if value then
							table.insert(target, {frame = frame, value = value})
						end
					end
				end
				for target, keyframes in pairs(targets) do
					if #keyframes > 0 then
						-- Write input (timestamps)
						local input = add_accessor("SCALAR", "float", nil, function(write_byte)
							local min, max = math.huge, -math.huge
							for _, keyframe in ipairs(keyframes) do
								local sec = keyframe.frame / (fps or 60) -- convert frames to seconds; default FPS is 60
								write_float(write_byte, sec)
								min, max = math.min(min, sec), math.max(max, sec)
							end
							return #keyframes, {min}, {max} -- min and max are mandatory
						end)

						-- Write output (overrides)
						local output = add_accessor(keyframes.output_type, "float", nil, function(write_byte)
							for _, keyframe in ipairs(keyframes) do
								keyframes.write_value(write_byte, keyframe.value)
							end
							return #keyframes
						end)

						table.insert(samplers, {
							input = input,
							output = output,
							-- interpolation default is already linear, matching b3d
						})

						table.insert(channels, {
							sampler = #samplers - 1, -- 0-based
							target = {
								node = node_id,
								path = target,
							}
						})
					end
				end
			end

			if node.mesh then
				-- Initialize skeletal animation
				assert(not anim)
				anim = {
					weights = {},
					joints = {},
					inv_bind_mats = {},
				}
			end

			if node.bone then
				local joint_id = #anim.joints
				table.insert(anim.joints, node_id)

				-- "To compose the local transformation matrix, TRS properties MUST be converted to matrices and postmultiplied in
				-- the T * R * S order; first the scale is applied to the vertices, then the rotation, and then the translation."
				local translation = translation_to_gltf(node.position)
				local rotation = modlib.quaternion.normalize(quaternion_to_gltf(node.rotation))
				local scale = node.scale
				local loc_trans_mat = mat4.scale(scale)
					:compose(mat4.rotation(rotation))
					:compose(mat4.translation(translation))

				-- Compute a proper inverse bind matrix as the inverse of the product of the transformation matrices
				-- along the path from the root (the mesh) to the current node (the bone).
				-- See e.g. https://stackoverflow.com/questions/17127994/opengl-bone-animation-why-do-i-need-inverse-of-bind-pose-when-working-with-gp
				-- https://computergraphics.stackexchange.com/questions/7603/confusion-about-how-inverse-bind-pose-is-actually-calculated-and-used
				bind_mat = bind_mat and bind_mat:multiply(loc_trans_mat) or loc_trans_mat
				table.insert(anim.inv_bind_mats, bind_mat:inverse())

				-- Insert into reverse lookup `anim.weights[vertex_id][joint_id] = weight`
				-- such that writing the mesh can then write the weights per vertex
				for vertex_id, weight in pairs(node.bone) do
					if weight > 0 then
						anim.weights[vertex_id] = anim.weights[vertex_id] or {}
						anim.weights[vertex_id][joint_id] = weight
					end
				end
			end

			local children = {}
			for _, child in ipairs(node.children) do
				table.insert(children, add_node(child, bind_mat, fps, anim))
			end
			local mesh, skin_id, neutral_node_id
			if node.mesh then
				local neutral_joint_id
				-- Lazily adds a placeholder for the neutral joint, returns joint ID
				local function add_neutral_joint()
					if neutral_joint_id then
						return neutral_joint_id
					end
					neutral_node_id = #nodes -- 0-based
					table.insert(nodes, {
						name = "neutral_bone",
						-- We need to flip the hierarchy: The neutral bone must be a parent of the mesh root;
						-- if it were a sibling, there would be no common skeleton root (accepted by Blender but not by glTF validator);
						-- if it were a child, transformations of the mesh root would affect it and it wouldn't be a neutral bone anymore.
						children = {node_id},
						-- translation, scale, rotation all default to identity
					})
					neutral_joint_id = #anim.joints -- 0-based
					table.insert(anim.joints, neutral_node_id)
					return neutral_joint_id -- 0-based
				end
				mesh = add_mesh(node.mesh, anim.weights, add_neutral_joint)
				if anim.joints and anim.joints[1] then
					if neutral_joint_id then
						-- Duplicate the inverse bind matrix of the parent (which the neutral bone will be a child of)
						table.insert(anim.inv_bind_mats, bind_mat or mat4.identity())
					end
					table.insert(skins, {
						inverseBindMatrices = add_accessor("MAT4", "float", nil, function(write_byte)
							for _, inv_bind_mat in ipairs(anim.inv_bind_mats) do
								assert(#inv_bind_mat == 4)
								-- glTF uses column-major order (we use row-major order)
								for i = 1, 4 do
									for j = 1, 4 do
										write_float(write_byte, inv_bind_mat[j][i])
									end
								end
							end
							return #anim.inv_bind_mats
						end),
						joints = anim.joints,
						skeleton = neutral_node_id, -- make the neutral bone the skeleton root
					})
					skin_id = #skins - 1 -- 0-based
				end
			end
			-- Now replace the placeholder
			nodes[node_id + 1 --[[0-based to 1-based]]] = {
				name = node.name,
				mesh = mesh,
				skin = skin_id,
				children = children[1] and children, -- glTF does not allow empty lists
				translation = translation_to_gltf(node.position),
				scale = node.scale,
				rotation = quaternion_to_gltf(node.rotation),
			}
			-- If a neutral bone exists, return the neutral bone (which has the node as a child) instead of the node
			return neutral_node_id or node_id -- 0-based
		end

		local scene, scenes
		if self.node then
			scene, scenes = 0, {{nodes = {add_node(self.node)}}}
		end

		local buffer_string = table.concat(buffer_rope)
		return {
			asset = {
				generator = "modlib b3d:to_gltf",
				version = "2.0"
			},
			-- Textures
			textures = textures[1] and textures, -- glTF does not allow empty lists
			materials = materials[1] and materials,
			-- Accessors, buffer views & buffers
			accessors = accessors,
			bufferViews = buffer_views,
			buffers = {
				{
					byteLength = #buffer_string,
					uri = "data:application/octet-stream;base64,"
						.. modlib.base64.encode(buffer_string) -- Note: Blender requires base64 padding
				},
			},
			-- Meshes & nodes
			meshes = meshes,
			nodes = nodes,
			-- A scene is not strictly needed but is useful for getting rid of validator warnings & having a proper root defined
			scene = scene,
			scenes = scenes,
			-- Animation
			skins = skins,
			-- B3D only contains (up to) a single animation
			animations = channels[1] and {
				{
					channels = channels,
					samplers = samplers,
				},
			},
		}
	end
end

function write_gltf(self, file)
	modlib.json:write_file(self:to_gltf(), file)
end

local binary_search_frame = modlib.table.binary_search_comparator(function(a, b)
	return modlib.table.default_comparator(a, b.frame)
end)

--> list of { bone_name = string, parent_bone_name = string, position = vector, rotation = quaternion, scale = vector }
function get_animated_bone_properties(self, keyframe, interpolate)
	local function get_frame_values(keys)
		local values = keys[keyframe]
		if values and values.frame == keyframe then
			return {
				position = values.position,
				rotation = values.rotation,
				scale = values.scale
			}
		end
		local index = binary_search_frame(keys, keyframe)
		if index > 0 then
			return keys[index]
		end
		index = -index
		assert(index > 1 and index <= #keys)
		local a, b = keys[index - 1], keys[index]
		if not interpolate then
			return a
		end
		local ratio = (keyframe - a.frame) / (b.frame - a.frame)
		return {
			position = (a.position and b.position and modlib.vector.interpolate(a.position, b.position, ratio)) or a.position or b.position,
			rotation = (a.rotation and b.rotation and modlib.quaternion.slerp(a.rotation, b.rotation, ratio)) or a.rotation or b.rotation,
			scale = (a.scale and b.scale and modlib.vector.interpolate(a.scale, b.scale, ratio)) or a.scale or b.scale,
		}
	end
	local bone_properties = {}
	local function get_props(node, parent_bone_name)
		local properties = {parent_bone_name = parent_bone_name}

		if keyframe > 0 and node.keys and next(node.keys) ~= nil then
			modlib.table.add_all(properties, get_frame_values(node.keys))
		end

		if not properties.position then -- animation not present, fall back to node position
			properties.position = modlib.table.copy(node.position)
		end

		if properties.rotation then -- animation is relative to node rotation
			properties.rotation = modlib.quaternion.compose(node.rotation, properties.rotation)
		else
			properties.rotation = modlib.table.copy(node.rotation)
		end

		if not properties.scale then -- animation not present, fall back to node scale
			properties.scale = modlib.table.copy(node.scale)
		end

		if node.bone then
			properties.bone_name = node.name
			table.insert(bone_properties, properties)
		end
		for _, child in pairs(node.children or {}) do
			get_props(child, properties.bone_name)
		end
	end
	get_props(self.node)
	return bone_properties
end

-- Export environment
return _ENV
