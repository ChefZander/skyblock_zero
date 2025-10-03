---@meta _
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: 'core' namespace reference > Sounds

--[[
WIPDOC
]]
---@class core.SoundID : integer

--[[
Unofficial note: i made ephemeral NOT be optional because it's a good idea to explicitly set it (most of the time you don't use that, so set it to true)
* `core.sound_play(spec, parameters, [ephemeral])`: returns a handle
    * `spec` is a `SimpleSoundSpec`
    * `parameters` is a sound parameter table
    * `ephemeral` is a boolean (default: false)
      Ephemeral sounds will not return a handle and can't be stopped or faded.
      It is recommend to use this for short sounds that happen in response to
      player actions (e.g. door closing).
]]
---@nodiscard
---@param spec core.SimpleSoundSpec
---@param parameters core.SoundParamter
---@param ephemeral boolean?
---@return core.SoundID?
function core.sound_play(spec, parameters, ephemeral) end

--[[
* `core.sound_stop(handle)`
    * `handle` is a handle returned by `core.sound_play`
]]
---@param handle core.SoundID
function core.sound_stop(handle) end

--[[
* `core.sound_fade(handle, step, gain)`
    * `handle` is a handle returned by `core.sound_play`
    * `step` determines how fast a sound will fade.
      The gain will change by this much per second,
      until it reaches the target gain.
      Note: Older versions used a signed step. This is deprecated, but old
      code will still work. (the client uses abs(step) to correct it)
    * `gain` the target gain for the fade.
      Fading to zero will delete the sound.
]]
---@param handle core.SoundID
---@param step number
---@param gain number
function core.sound_fade(handle, step, gain) end