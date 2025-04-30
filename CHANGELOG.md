Release 37
- Fixed instatubes sometimes not working
- Added bricks and wooden planks
- Fixed one pixel of pebble being transparent (Yes, you weren't crazy!)
- Fixed a lot of bugs with instatubes and specifically instatube teleport tubes
- Added starlight catchers
- Optimized habitat regulators
- Fixed cycling instatubes not behaving correctly
- Added an instatube debug tool
- Fixed a bug where luacontroller linkers weren't respecting protections (yikes)
- Optimized drawer controllers
- Fixed node preservers not preserving the contents of "wielders" (punchers, node breakers, deployers)
- Fixed instatubes not playing nice with item sorters


Release 36 - "Oh no... there is stuff to fix actually, oops" Update
- Fixed a bug with instatubes that made them behave really strangely, when a server restarted
- Added the height limit for emitters back
- Added a command that removes all pipeworks tube entities
- Fixed bugs about meteorite spawning (they could previously only spawn near spawn)
- Buffed the spawn rate on multiplayer (For each person, a meteorite will spawn)
- Fixed instatubes not "internally connecting" when machines are placed near them
- Fixed wielders (punchers/node breakers/deployers) making a big amount of entities in certain situations
- Fixed instatube quest being always visible 
- Made luacontroller "ram" limit to be 400kb (from 1mb)
- Re-wrote the "Introduction" luacontroller help page
- Fixed blast furnace not breaking properly when digging a blast furnace controller
- Made instatubes colorable and fixed a bug where instatubes that were dug weren't stackable with freshly crafted ones
- Made antimatter platforms explody
- Fixed one way instatube textures being in the wrong direction

Release 35 - "Optimization update"
- made pipes and tubes smaller (1/4th of a node => 3/16th of a node)
- fixed some bugs
- made fluid pipe look better
- added instatubes
- Added blast furnace
- Made switching station lag not show fractions of miliseconds
- Optimized switching stations
- Optimized super powered lamps
- Optimized reactors
- Optimized fluid transport
- Added teleport batteries (thanks to lnee)
- Made drawers support filter injectors
- Made drawers color-able
- Made copytool copy filter injector "exact match mode"


Release 34
- Added a recipe to memory controller
- Added an info page "Overflow Handling"
- Added an "Items destroyed: " infotext to item voids
- Improved some quests by adding images
- Made burners store co2
- Fixed rare bugs with filter injectors

Release 33
- Fixed a bug where filter injectors didn't work with one way tubes
- Added one direction tube
  - A tube that accepts items from all directions, but sends them to only one direction
- Fixed meteorite sounds being heard by everyone
- ***BREAKING*** (for multiplayer, for logic nerds): made formspec screens "public"
  - If you have a formspec screen that you don't want the public accessing, please check the `clicker` field
- Fixed logic components not sending info to luacontroller after jump
- Fixed bug where filter injector sometimes sent too many items, causing them to sometimes be thrown out
- Made robotic arms be able to repair broken tubes
- Made creative batteries and generators diggable
- Added things to small protector's documentation
- Fix simple alloy furnace sounds being heard by everyone, regardless of their distance to the audio source
- Made jumpdrive only be able to get power from batteries that are in its range.
- Fixed reactors only saying that their fuel rods are used 0%
- Added node preserver
- Removed the teleport request mod, **servers will have to add it back**
- Fix strange blob crashing the server, when consuming a node with inventory
- Fixed partially/completely full storinators's drops 
- Added bulk replacer tool
- Increased the range of planet light control
- Added copytool
- Improved autocrafter UI a little bit
- Fixed jumpdrive travelnet compatibility
- Fixed compatibility with nodes that used on_movenode (so including travelnet)
- Make Meteoric matter decay
- Make tree mutations way more potent (lowered to 10 mutations, but without the "60% chance of preventing a mutation" check, and made mutations much more likely)
- Added pitch variations to some sound effects
- Made luacontroller's `pos` global change in the main environment if the luacontroller has been jumped
- After an "sbz moment", it was decided that strange blobs should be able to explode
- Changed planet mapgen a bit, made bluestone/redstone more common
- Changed how trees get generated, decreased the maximum tree size
- Changed the linker tool so the waypoints have a maximum view range of 100
- Fixed a lot of lighting bugs when the smooth lighting setting is disabled
- **Re-worked organics a bit**
- Added /playtime and /afk
- Added colorium glass
- Nerfed how much co2 colorium tree trunks and colorium tree leaves make when burning
- Made node breakers, deployers, punchers, turrets give power to items that require it
- Fixed pat.* library
- Fixed bug with meteorite sounds being able to be heard by anyone
- Corrected Antimatter Blob quest's misinformation
- Added memory controller
- Made hologram projectors be able to animate models
- Fixed the default editor's disk menu  being weird sometimes


Release 32
- Fix the bug with filter injectors crashing the game when directly outputting to accelerator tubes
- Fix background music being at 0% volume by default

Release 31
- Make the data disk description more accurate - they can only hold 20 kilobytes, not 1 megabyte
- Re-worked how meteorite attractors/repulsors attract players when holding neutronium - You now no longer can move yourself, and experience zero gravity
  - This allows for making orbits if you are skilled
- Added the turret
- For luacontrollers (_G refers to the global environment)
  - Added _G.chat_debug(msg) to both environments, check your nearest knowledge station
  - Removed _G.origin from the main environment
  - Added _G.pos to editor environment
  - Added _G.full_traceback to the editor environment
  - Fixed matrix screens being wildly inaccurate
  - Added some examples to the knowledge station
- Cleared up "Growing Plants" quest
- Fixed some nodes being considered as solid to the habitat
- Breaking: enabled cyclic mode for pipeworks
  - Items will now no longer prefer to go one direction if you have something like a tube with branches, or an item sorter, instead they will cycle thru all the directions, make sure you check your factories
- Enabled backface culling by default on the tubes, tubes will now look much cleaner at the cost of some visual bugs
  - Added a setting to toggle tube backface culling
- Storinators can now be colored with the coloring tool
- Neutronium storinators can now sort by name (if they are placed after the update, existing neutronium storinators will not have this capability)
- Added co2 compactor (stores co2 like a "co2 battery" would)
- Fixed autocrafter behavior with pipeworks (now overflow handling with item voids is made easy)
- Made item sorter and item void textures better
- Added "Organics Automation" page to questbook
- Fixed ladders for the 2nd time - now they are only vertical
- Added warpshrooms quest
- Better documented the reactor quest
- Re-worked how jumpdrives interact with protections
- Changed the behavior of filter injectors so that they don't try to push stuff out when the inventory they are trying to push stuff to is clearly full
- Re-worked and fixed bugs with logic item transport

Release 30
- Fixed crash bugs with jumpdrive and moving nodes with luacontrollers
- Added lead shielding

Release 29
- Notice: Releases may be really small like this one, or HUGE like release 28
- Started doing changelogs again
- Added more "info sections" to the questbook, told people that you can hold right click to the core in the questbook
- Fixed a bug where colorium storinators needed stemfruit... instead of colorium xD
- Made bronze slightly darker 
- Added Teleport Tube, and the proper quests for it
- Changed some stuff about how jumpdrive moves nodes that need special compatibility
  - If this creates any bugs, please report them!
- Fix bug with the "Radiation shielding" text
- Fireworks have been improved
- Client lag with molten liquids should be reduced
- Fixed a bug with ladders, where they refused to go in certain directions
- Compressed images, lossy compressed the background to 200kb

Release 10
- Completely recode energy system to use "Cosmic Joules" instead of "Global Power"
- Pipe-based energy system
- Removed quest "Global Power"
- Added questline "Emittrium"
- New quests: "Obtain Emittrium", "Emittrium Circuits", "Power Pipes", "Batteries", "Reinforced Matter" and "Angel's Wing"
- new secret quests
- several ui fixes and a craft guide system
- added Starlight Collectors
- Stopped doing changelogs

Release 9
- New questline "Decorator"
- Moved "Emitter Immitators" to the Decorator questline
- New quest: "Photon Lamps" in Decorator Questline
- Added Photon Lamps
- Fixed a bug reported by @theidealist (ty)
- Secret quests now show up in the questbook as ???

Release 8
- Questbook now has questlines
- Primitive Questbook API documentation added (see docs folder)
- Questbook has new types of quests
- Quests may now require other quests to be completed to be viewable
- Added secret quest "Emptiness"
- Improved indicators on quests

Release 7
- fix the questbook reminders
- player is now invisible, replaced by a white particle trail
- removed players hand
- Add 3 new quests "Global Power", "Pretty Pebbles" and "Concrete Plan"
- Rightclicking the core will now also give materials
- Bumped 'Advanced Extractor' chance to extract 'Core Dust' from 1/50 to 1/25
- Add Dirt, Soil and Stone Nodes
- Add 'Raw Emittrium' and 'Pebble' Items

Release 6
- 'Emitter Immitator' now gives off twice as much light
- Introduced the Quest Book instead of the Guide (which has been removed)
- Ported 7 Quests over from the old quest system
- Added 6 new quests covering most of the current gameplay
- Particles when completing a quest
- use /qb to get the questbook on old worlds
- Custom hotbar textures

Release 5
- Fixed an issue with infinite negative energy reported by @fgaz

Release 4
- Fixed sneaking being insanely fast for no reason
- Fixed bugs with Generator where it would give infinite energy / take infinite energy
- Added conversion chamber craftitem
- Added Organic Converter (not usable so far)

Release 3
- Fixed power not getting removed when removing a running generator
- Added space-like physics
- Added a sound when placing a machine
- Added a sound when opening a machine's formspec
- Added a sound when Simple Charged Field or Charged Field Residue decays
- Added Storinators
- Added Simple Circuit and Retaining Circuit
- Added Matter Plate

Release 2
- Added Advanced Matter Extractor
- Made Emitters display a message when clicked
- Added "Advanced Extractors" Optional Quest / Achievement
- Fixed Infite Energy, see: https://content.minetest.net/threads/8584/
- Added Simple Charge Generator
- Added Emitter Immitator

Release 1
- First release
