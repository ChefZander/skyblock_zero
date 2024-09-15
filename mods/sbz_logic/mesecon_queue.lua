--[[
    Hey! this is code directly taken from mesecons - https://github.com/minetest-mods/mesecons/blob/master/mesecons/actionqueue.lua
    It was modified to fit in to skyblock_zero


Copyright (C) 2011-2016 Mesecons Mod Developer Team and contributors

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

--[[
Mesecons uses something it calls an ActionQueue.

The ActionQueue holds functions and actions.
Functions are added on load time with a specified name.
Actions are preserved over server restarts.

Each action consists of a position, the name of an added function to be called,
the params that should be used in this function call (additionally to the pos),
the time after which it should be executed, an optional overwritecheck and a
priority.

If time = 0, the action will be executed in the next globalstep, otherwise the
earliest globalstep when it will be executed is the after next globalstep.

It is guaranteed, that for two actions ac1, ac2 where ac1 ~= ac2,
ac1.time == ac2.time, ac1.priority == ac2.priority and ac1 was added earlier
than ac2, ac1 will be executed before ac2 (but in the same globalstep).

Note: Do not pass references in params, as they can not be preserved.

Also note: Some of the guarantees here might be dropped at some time.
]]

-- this function below is from https://github.com/minetest-mods/mesecons/blob/ff87cf3162750d50b74ae04b2298b896dad165e0/mesecons/util.lua#L240 - same license basically

-- Returns whether two values are equal.
-- In tables, keys are compared for identity but values are compared recursively.
-- There is no protection from infinite recursion.

local function cmpAny(t1, t2)
    if type(t1) ~= type(t2) then return false end
    if type(t1) ~= "table" then return t1 == t2 end

    -- Check that for each key of `t1` both tables have the same value
    for i, e in pairs(t1) do
        if not cmpAny(e, t2[i]) then return false end
    end

    -- Check that all keys of `t2` are also keys of `t1` so were checked in the previous loop
    for i, _ in pairs(t2) do
        if t1[i] == nil then return false end
    end

    return true
end

sbz_api.queue = {
    funcs = {}
}

-- localize for speed
local queue = sbz_api.queue

queue.actions = {} -- contains all ActionQueue actions

function queue:add_function(name, func)
    self.funcs[name] = func
end

-- If add_action with twice the same overwritecheck and same position are called, the first one is overwritten
-- use overwritecheck nil to never overwrite, but just add the event to the queue
-- priority specifies the order actions are executed within one globalstep, highest first
-- should be between 0 and 1
function queue:add_action(pos, func, params, time, overwritecheck, priority)
    -- Create Action Table:
    time = time or 0 -- time <= 0 --> execute, time > 0 --> wait time until execution
    priority = priority or 1
    local action = {
        pos = table.copy(pos),
        func = func,
        params = table.copy(params or {}),
        time = time,
        owcheck = (overwritecheck and table.copy(overwritecheck)) or nil,
        priority = priority
    }

    -- check if old action has to be overwritten / removed:
    if overwritecheck then
        for i, ac in ipairs(self.actions) do
            if vector.equals(pos, ac.pos)
                and cmpAny(overwritecheck, ac.owcheck) then
                -- remove the old action
                table.remove(self.actions, i)
                break
            end
        end
    end

    table.insert(self.actions, action)
end

-- execute the stored functions on a globalstep
-- if however, the pos of a function is not loaded (get_node_or_nil == nil), do NOT execute the function
-- this makes sure that resuming mesecons circuits when restarting minetest works fine (hm, where do we do this?)
-- However, even that does not work in some cases, that's why we delay the time the globalsteps
-- start to be execute by 4 seconds

local m_time = 0
local resumetime = 4

local function globalstep_func(dtime)
    -- don't even try if server has not been running for XY seconds; resumetime = time to wait
    -- after starting the server before processing the ActionQueue, don't set this too low
    if m_time < resumetime then
        m_time = m_time + dtime
        return
    end

    local actions = queue.actions
    -- split into two categories:
    -- actions_now: actions to execute now
    -- queue.actions: actions to execute later
    local actions_now = {}
    queue.actions = {}

    for _, ac in ipairs(actions) do
        if ac.time > 0 then
            -- action ac is to be executed later
            -- ~> insert into queue.actions
            ac.time = ac.time - dtime
            table.insert(queue.actions, ac)
        else
            -- action ac is to be executed now
            -- ~> insert into actions_now
            table.insert(actions_now, ac)
        end
    end

    -- stable-sort the executed actions after their priority
    -- some constructions might depend on the execution order, hence we first
    -- execute the actions that had a lower index in actions_now
    local old_action_order = {}
    for i, ac in ipairs(actions_now) do
        old_action_order[ac] = i
    end
    table.sort(actions_now, function(ac1, ac2)
        if ac1.priority ~= ac2.priority then
            return ac1.priority > ac2.priority
        else
            return old_action_order[ac1] < old_action_order[ac2]
        end
    end)

    -- execute highest priorities first, until all are executed
    for _, ac in ipairs(actions_now) do
        queue:execute(ac)
    end
end

minetest.register_globalstep(globalstep_func)

function queue:execute(action)
    -- ignore if action queue function name doesn't exist,
    -- (e.g. in case the action queue savegame was written by an old mesecons version)
    if self.funcs[action.func] then
        self.funcs[action.func](action.pos, unpack(action.params))
    end
end

-- Store and read the ActionQueue to / from a file
-- so that upcoming actions are remembered when the game
-- is restarted

-- edit: no im not doing that lol
