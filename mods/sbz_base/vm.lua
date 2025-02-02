--[[
    The file below is licensed under the lgplv3 license, it was taken from mesecons
    License of mesecons: https://github.com/minetest-mods/mesecons
    Code was modified, was taken from https://github.com/minetest-mods/mesecons/blob/master/mesecons/util.lua#L342 (that line)

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
local function hash_blockpos(pos)
    return minetest.hash_node_position({
        x = math.floor(pos.x / BLOCKSIZE),
        y = math.floor(pos.y / BLOCKSIZE),
        z = math.floor(pos.z / BLOCKSIZE)
    })
end

-- Maps from a hashed mapblock position (as returned by hash_blockpos) to a
-- table.
--
-- Contents of the table are:
-- “vm” → the VoxelManipulator
-- “dirty” → true if data has been modified
--
-- Nil if no VM-based transaction is in progress.
local vm_cache = nil

-- Cache from node position hashes to nodes (represented as tables).
local vm_node_cache = nil

-- Whether the current transaction will need a light update afterward.
local vm_update_light = false

-- Starts a VoxelManipulator-based transaction.
--
-- During a VM transaction, calls to vm_get_node and vm_swap_node operate on a
-- cached copy of the world loaded via VoxelManipulators. That cache can later
-- be committed to the real map by means of vm_commit or discarded by means of
-- vm_abort.
function sbz_api.vm_begin()
    vm_cache = {}
    vm_node_cache = {}
    vm_update_light = false
end

-- Finishes a VoxelManipulator-based transaction, freeing the VMs and map data
-- and writing back any modified areas.
function sbz_api.vm_commit()
    for hash, tbl in pairs(vm_cache or {}) do
        if tbl.dirty then
            local vm = tbl.vm
            vm:write_to_map(vm_update_light)
            vm:update_map()
        end
    end
    vm_cache = nil
    vm_node_cache = nil
end

-- Finishes a VoxelManipulator-based transaction, freeing the VMs and throwing
-- away any modified areas.
function sbz_api.vm_abort()
    vm_cache = nil
    vm_node_cache = nil
end

-- Gets the cache entry covering a position, populating it if necessary.
local function vm_get_or_create_entry(pos)
    local hash = hash_blockpos(pos)
    local tbl = vm_cache[hash]
    if not tbl then
        tbl = { vm = minetest.get_voxel_manip(pos, pos), dirty = false }
        vm_cache[hash] = tbl
    end
    return tbl
end

-- Gets the node at a given position during a VoxelManipulator-based
-- transaction.
function sbz_api.vm_get_node(pos)
    local hash = minetest.hash_node_position(pos)
    local node = vm_node_cache[hash]
    if not node then
        node = vm_get_or_create_entry(pos).vm:get_node_at(pos)
        vm_node_cache[hash] = node
    end
    return node.name ~= "ignore" and { name = node.name, param1 = node.param1, param2 = node.param2 } or nil
end

-- Sets a node’s name during a VoxelManipulator-based transaction.
--
-- Existing param1, param2, and metadata are left alone.
--
-- The swap will necessitate a light update unless update_light equals false.
---@param pos table
---@param name string
---@param update_light boolean
function sbz_api.vm_swap_node(pos, name, update_light)
    -- If one node needs a light update, all VMs should use light updates to
    -- prevent newly calculated light from being overwritten by other VMs.
    vm_update_light = vm_update_light or update_light ~= false

    local tbl = vm_get_or_create_entry(pos)
    local hash = minetest.hash_node_position(pos)
    local node = vm_node_cache[hash]
    if not node then
        node = tbl.vm:get_node_at(pos)
        vm_node_cache[hash] = node
    end
    node.name = name
    tbl.vm:set_node_at(pos, node)
    tbl.dirty = true
end

-- Gets the node at a given position, regardless of whether it is loaded or
-- not, respecting a transaction if one is in progress.
--
-- Outside a VM transaction, if the mapblock is not loaded, it is pulled into
-- the server’s main map data cache and then accessed from there.
--
-- Inside a VM transaction, the transaction’s VM cache is used.
function sbz_api.get_node_force(pos)
    if vm_cache then
        return sbz_api.vm_get_node(pos)
    else
        local node = core.get_node_or_nil(pos)
        if node == nil then
            -- Node is not currently loaded; use a VoxelManipulator to prime
            -- the mapblock cache and try again.
            minetest.get_voxel_manip(pos, pos)
            node = minetest.get_node_or_nil(pos)
        end
        return node
    end
end

-- Swaps the node at a given position, regardless of whether it is loaded or
-- not, respecting a transaction if one is in progress.
--
-- Outside a VM transaction, if the mapblock is not loaded, it is pulled into
-- the server’s main map data cache and then accessed from there.
--
-- Inside a VM transaction, the transaction’s VM cache is used.
--
-- This function can only be used to change the node’s name, not its parameters
-- or metadata.
--
-- The swap will necessitate a light update unless update_light equals false.
function sbz_api.swap_node_force(pos, name, update_light)
    if vm_cache then
        return sbz_api.vm_swap_node(pos, name, update_light)
    else
        -- This serves to both ensure the mapblock is loaded and also hand us
        -- the old node table so we can preserve param2.
        local node = sbz_api.get_node_force(pos)
        node.name = name
        minetest.swap_node(pos, node)
    end
end
