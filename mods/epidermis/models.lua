local mlvec = modlib.vector

local media_paths = epidermis.media_paths

local bad_character_b3d_path = modlib.mod.get_resource "character_without_normals.b3d"
local bad_character_b3d_hash = minetest.sha1(modlib.file.read(bad_character_b3d_path))
local fixed_character_b3d_path = modlib.mod.get_resource "character_with_normals.b3d"

return setmetatable({}, {
	__index = function(self, filename)
		local _, ext = modlib.file.get_extension(filename)
		if not ext or ext:lower() ~= "b3d" then
			-- Only B3D support currently
			return
		end
		if not media_paths[filename] then
			filename = "character.b3d"
		end
		local path = assert(media_paths[filename], filename)
		-- HACK replace a "bad" character.b3d with a fixed version that includes normals
		-- Susceptible to SHA1 collisions, but so is MT's media loading process
		-- See https://github.com/minetest/minetest_game/pull/2902
		if filename == "character.b3d" and minetest.sha1(modlib.file.read(path)) == bad_character_b3d_hash then
			path = fixed_character_b3d_path
		end
		local model = io.open(path, "rb")
		local character = assert(modlib.b3d.read(model))
		assert(not model:read(1))
		model:close()
		local mesh = assert(character.node.mesh)
		local vertices = assert(mesh.vertices)
		for _, vertex in ipairs(vertices) do
			-- Minetest hardcodes a blocksize of 10 model units
			vertex.pos = mlvec.divide_scalar(vertex.pos, 10)
		end
		-- Triangle sets by texture index
		local tris_by_tex = {}
		local func = modlib.func
		for _, set in pairs(assert(mesh.triangle_sets)) do
			local tris = set.vertex_ids
			for _, tri in pairs(tris) do
				modlib.table.map(tri, func.curry(func.index, vertices))
				tri.poses = { tri[1].pos, tri[2].pos, tri[3].pos }
			end
			local brush_id = tris.brush_id or mesh.brush_id
			local tex_id
			if brush_id then
				tex_id = assert(character.brushes[brush_id].texture_id[1])
			else
				-- No brush, default to first texture
				tex_id = 1
			end
			tris_by_tex[tex_id] = tris_by_tex[tex_id] and modlib.table.append(tris_by_tex[tex_id], tris) or tris
		end
		self[filename] = {
			vertices = vertices,
			triangle_sets = tris_by_tex,
			frames = (character.node.animation or {}).frames or 1
		}
		return self[filename]
	end
})
