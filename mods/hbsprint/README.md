# Skyblock: Zero Forked Mod

Currently synchronized with commit 92a1e0cddb0f4f3278e629402cbfc0efe6bceecf from upstream: <https://github.com/minetest-mods/hbsprint>.

See `COPYRIGHT.md` for up-to-date copyright information. README contents below is preserved from the original mod.

# hbSprint

## Description
A flexible sprint mod supporting stamina, hunger and coexistance with other physics altering mods.

## Licensing
- LGPLv2.1/CC BY-SA 3.0. Particle code: copyright (c) 2017 Elijah Duffy.
- sprint_stamina_\*icon textures:
  - CC0
  - Created by Jordan Irwin (AntumDeluge)
  - Based on [Running man icon by manio1](https://openclipart.org/detail/254287)

## Notes
hbSprint can be played with Minetest 0.4.16 or above.
It has no dependencies, but supports [hudbars](https://repo.or.cz/minetest_hudbars.git) and [player_monoids](https://github.com/minetest-mods/player_monoids).

Compatible hunger mods: [hbhunger](https://repo.or.cz/minetest_hbhunger.git) or [hunger_ng](https://gitlab.com/4w/hunger_ng).

## List of features

- Displays and drains stamina (by default, if hudbars is present). Hides stamina bar if full.
- Displays and drains satiation (by default, if compatible hunger mod found)
- Drains air faster while sprinting on walkable ground but in water (by default)
- Requires only forward key to be pressed, not left and right (by default)
- Requires walkable ground (no water surface sprinting)
- Particle spawning based on ground type (Thanks to [octacian](https://github.com/octacian/sprint/))
- All variables customizable in Advanced settings or directly in minetest.conf


## Known issues
- Forward double tap support not implemented

## Bug reports and suggestions
You can report bugs or suggest ideas by [filing an issue](http://github.com/tacotexmex/hbsprint/issues/new).

## Links
* [Download ZIP](https://github.com/minetest-mods/hbsprint/archive/master.zip)
* [Source](https://github.com/minetest-mods/hbsprint)
* [Forum thread](https://forum.minetest.net/viewtopic.php?f=9&t=18069&p=282981)
