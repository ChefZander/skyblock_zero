--[[
    The section below is licensed under the lgplv3 license, it was taken from mesecons
    This license text only applies to the section below, a comment will be placed indicating when that section ends

    License of mesecons: https://github.com/minetest-mods/mesecons

This program is free software; you can redistribute the Mesecons Mod and/or
modify it under the terms of the GNU Lesser General Public License version 3
published by the Free Software Foundation.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
Boston, MA  02110-1301, USA.

]]


-- Block position "hashing" (convert to integer) functions for voxelmanip cache
local BLOCKSIZE = 16

-- convert node position --> block hash

---@param pos vector
---@return integer
local function hash_blockpos(pos)
    return minetest.hash_node_position({
        x = math.floor(pos.x / BLOCKSIZE),
        y = math.floor(pos.y / BLOCKSIZE),
        z = math.floor(pos.z / BLOCKSIZE)
    })
end

local vm_cache = {}
local vm_node_cache = {}

--- Resets the vm cache, does the same thing as vm_abort actually
function sbz_api.vm_begin()
    vm_cache = {}
    vm_node_cache = {}
end

---@deprecated
function sbz_api.vm_abort()
    vm_cache = nil
    vm_node_cache = nil
end

local function vm_get_or_create_entry(pos)
    local hash = hash_blockpos(pos)
    local tbl = vm_cache[hash]
    if not tbl then
        tbl = minetest.get_voxel_manip(pos, pos)
        vm_cache[hash] = tbl
    end
    return tbl
end

--- Gets node from the vm_cache or creates an entry
--- May not be up to date!
--- @param pos vector
--- @return node|nil
function sbz_api.vm_get_node(pos)
    local hash = minetest.hash_node_position(pos)
    local node = vm_node_cache[hash]
    if not node then
        node = vm_get_or_create_entry(pos):get_node_at(pos)
        vm_node_cache[hash] = node
    end
    return node.name ~= "ignore" and { name = node.name, param1 = node.param1, param2 = node.param2 } or nil
end

-- Gets the node at a given position, regardless of whether it is loaded or
-- not, respecting a transaction if one is in progress.
--
-- Outside a VM transaction, if the mapblock is not loaded, it is pulled into
-- the server’s main map data cache and then accessed from there.
--
-- Inside a VM transaction, the transaction’s VM cache is used.
--- @param pos vector
--- @return node | nil
function sbz_api.get_node_force(pos)
    if vm_cache then
        return sbz_api.vm_get_node(pos)
    else
        local node = minetest.get_node_or_nil(pos)
        if node == nil then
            -- Node is not currently loaded; use a VoxelManipulator to prime
            -- the mapblock cache and try again.
            minetest.get_voxel_manip(pos, pos)
            node = minetest.get_node_or_nil(pos)
        end
        return node
    end
end
