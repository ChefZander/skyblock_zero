-- License: LGPLv3 or later
-- from: https://github.com/mt-mods/digistuff/tree/master
local MAX_COMMANDS_AT_ONCE = 10
local t = type
minetest.register_node("sbz_logic_devices:noteblock", {
    description = "Note Block",
    info_extra = "Plays sounds, fully capable of blowing your ears off! :>",
    tiles = {
        "noteblock_top.png",
        "noteblock_top.png",
        "noteblock_front.png",
        "noteblock_side.png",
    },
    paramtype2 = "4dir",
    groups = { matter = 1, ui_logic = 1 },
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) == "string" then return minetest.sound_play(msg, { pos = pos }) end
        if type(msg) ~= "table" then return end
        if type(msg[1]) ~= "table" then msg[1] = msg end

        for i = 1, math.min(#msg, MAX_COMMANDS_AT_ONCE) do
            local cmd = msg[i]
            if type(cmd) == "string" then
                minetest.sound_play(cmd, { pos = pos })
            elseif type(cmd) == "table" then
                if t(cmd.sound) ~= "string" then break end

                for _, i in ipairs({ "pitch", "speed", "volume", "gain", }) do
                    if t(cmd[i]) == "string" then
                        cmd[i] = tonumber(cmd[i])
                    end
                end

                if not cmd.volume then cmd.volume = cmd.gain end
                local volume = 1
                if t(cmd.volume) == "number" then
                    volume = math.max(0, math.min(1, cmd.volume))
                end
                if not cmd.pitch then cmd.pitch = cmd.speed end
                local pitch = 1
                if t(cmd.pitch) == "number" then
                    pitch = math.max(0.05, math.min(10, cmd.pitch))
                end


                local sound_spec = { name = cmd.sound, gain = volume }
                local sound_param = { pos = pos, pitch = pitch, start_time = tonumber(cmd.start_time) }

                if t(cmd.cut) == "number" and cmd.cut >= 0 then
                    cmd.cut = math.min(cmd.cut, 10)
                    local handle = minetest.sound_play(sound_spec, sound_param, false)
                    minetest.after(cmd.cut, minetest.sound_stop, handle)
                elseif t(cmd.fadestep) == "number" and t(cmd.fadegain) == "number" and cmd.fadegain >= 0 and type(cmd.fadestart) == "number" and cmd.fadestart >= 0 then
                    local handle = minetest.sound_play(sound_spec, sound_param, false)
                    minetest.after(cmd.fadestart, minetest.sound_fade, handle, cmd.fadestep, cmd.fadegain)
                else
                    minetest.sound_play(sound_spec, sound_param, true)
                end
            end
        end
    end
})
