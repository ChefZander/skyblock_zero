return {
    { type = "text", title = "Questline: Chemistry", text = "Good luck." },

    {
        type = "quest",
        title = "Crusher",
        text = [[
You can put in pebbles to get metals, it will also crush stones into 2 gravel each, and gravel to 2 sand each.
]],
        requires = { "Concrete Plan", "Antimatter", "Charged Field" }
    },

    { type = "secret", title = "It's fake", text = "Digital gold? Where have I heard that before..." },

    { type = "quest", title = "Furnace", text = "Craft the high power electric furnace (H.P.E.F for short), it allows you to smelt any powder into an ingot, ingots are heavily used in crafting recipes.", requires = { "Crusher" } },


    { type = "quest", title = "Simple Alloy Furnace", text = "Smelts metals into alloys.\nTry out some combinations of metals to see which ones create alloys. Consumes 10 Power when running.", requires = { "Crusher", "Emittrium Circuits", "Antimatter", "Charged Field" } },

    { type = "quest", title = "Bronze Age", text = "Congratulations, Commander! You've just unlocked the Bronze Age—because nothing says 'cutting-edge space exploration' like struggling to make a metal our ancestors figured out 5,000 years ago. Sure, you've mastered faster-than-light travel, but apparently mixing [REDACTED] and [REDACTED] is still rocket science. Good luck, Space Caveman!", requires = { "Simple Alloy Furnace", "Crusher" } },
    {
        type = "quest",
        title = "Compressor",
        text = [[
Have you ever wanted to turn your metals into blocks? Now you can!
Craft this wonderful compressor, insert in 9 powder, or 9 ingots, and watch as it makes your blocks.
Blocks made from chemicals cannot be dug with matter annihilators, you must use the robotic arm or the drill instead.
        ]],
        requires = { "Crusher" }
    },
    {
        type = "quest",
        title = "Centrifuge",
        text = [[
In the centrifuge you can get gold, silicon and white sand from normal sand, silver from some sand shades, and rare metals (titanium, lithium and cobalt) from gravel.
        ]],
        requires = { "Crusher" }
    },
    {
        type = "quest",
        title = "Advanced Batteries",
        text = [[
A battery made with metals. Significantly better than the basic battery.
        ]],
        requires = { "Batteries", "Furnace", "Centrifuge" }
    },
    {
        type = "quest",
        title = "Very Advanced Batteries",
        text = [[
If you have lots of metals this is the battery for you!
        ]],
        requires = { "Batteries", "Furnace", "Advanced Batteries" }
    },
    {
        type = "quest",
        title = "Crystal Grower",
        text = [[
If you put in 9 warpshrooms, you will get some warp crystals, which you use for anything teleportation-related.
        ]],
        requires = { "Compressor", "Neutronium" }
    },

    {
        type = "quest",
        title = "Jetpack",
        text = [[
Have you wished to fly? Do i have the tool for you...

The controls:

Left clicking an un-activated jetpack (you can see with the red lighgt on the texture) will activate it.
Left clicking an activated jetpack (the light becomes green) will de-activate it

When a jetpack is activated:
If you press jump:
- jetpack applies upwards velocity to you
- jetpack wears down a bit
- you become 2x faster
If you press both jump and shift or aux1:
- jetpack applies half as much upwards velocity as when you jump
- jetpack wears down 2x less
- you still become 2x faster

The mode you are flying in can also be seen by how many particles are getting spawned.
The wear is setup such that it lasts you 3 minutes of constant flying

You can re-fuel your jetpack by clicking on a battery, full repair costs 1000 Cj

Jetpack gets de-activated when you move it in your inventory during flight, or when it runs out of charge.

The Jetpack originally used to get automatically de-activated when you stop having it in your hand, but that is no longer the case.
]],
        requires = { "Neutronium" }
    },
    { type = "quest", title = "Bear Arms", text = "Notice the small little pun there? .. it's obvious that it tells you to craft a Robotic Arm? Oh.", requires = { "Furnace" } },
    {
        type = "quest",
        title = "Electric Drill",
        text = [[
The elecric drill has 500 uses and is powered by electricity.
What does that mean?

If you "place" it on a battery (sneak+right click), it will take power from the battery and charge the drill! (Just like the jetpack)
It needs 1 power per 1 use.

It also digs 2x faster than the robotic arm.
]],
        requires = { "Bear Arms" }
    },
    {
        type = "quest",
        title = "Antimatter Generators",
        text =
        [[Craft the antimatter generator, it is best used with automation or a large array of batteries.
It needs 1 matter and 1 antimatter per second.
It's super resource hungy but gives you more power.
]],
        requires = { "Furnace" }
    },
    {
        type = "quest",
        title = "Phlogiston Fuser",
        text = [[
Chemistry is boring.... what about alchemy!
To make phlogiston, you'll need lots of power for a very long time, be aware of that.
You can also make some armor from phlogiston, once it is low on durability, you can charge that armor like you would charge your jetpack.
]],
        requires = { "Crystal Grower", "Very Advanced Batteries" }
    },
    {
        type = "quest",
        title = "Planet Teleporter",
        text =
        [[Right-click with a warp crystal to use. There are multiple types of planets, with some of them having rings.]],
        requires = { "Neutronium", "Phlogiston Fuser" }
    },
    {
        type = "text",
        title = "Inside of planets",
        text = [[
In the center of a planet, there is a core, around it is some molten metal.

Molten metal reacts with cold nodes (like water and ice), very slowly, to:
- if flowing molten metal collides with water, it gets tured into stone
- if a flowing metal source collides with water, it gets turned into the node that the flowing metal was. For example molten silicon => silicon block

There is currently no way to make molten metal.
        ]],
        info = true,
        requires = { "Planet Teleporter" }
    },
    {
        type = "quest",
        title = "Planet Ores",
        text = [[
At the center of planets, there is usually some core material.
In blue stone there is uranium ore, blue stone is only found in ice planets.
In red stone there is thorium ore, red stone is found in dead planets and colorium planets.
To get this achievement, you will need to put uranium or thorium powder in your inventory.
]],
        requires = { "Planet Teleporter" }
    },
    {
        type = "quest",
        title = "Pebble Enhancer",
        text = [[
You'll probably want to get thorium and uranium automatically now, no worries, it's possible.
Enhanced pebbles can also get you lithium, cobalt, titanium, silicon and silver.
Simply put a pebble into the pebble enhancer, it will become enhanced.
]],
        requires = { "Planet Ores" }
    },
    {
        type = "quest",
        title = "Decay Accelerator",
        text = [[
In later updates, this node will be able to transform regular materials.
Currently, it is used to obtain plutonium from uranium, simply insert uranium powder to it.
        ]],
        requires = { "Planet Ores" }
    },
    {
        type = "quest",
        title = "Radiation Shielding",
        text = [[Solid charged field shields against radiation.]],
        requires = { "Planet Ores" },
    },
    {
        type = "quest",
        title = "Nuclear Reactor",
        text = [[
If you need even more power, you might want to consider nuclear reactors.

Types of fuel rods:
- thorium: doesn't explode, lowest power,
- uranium: explodes, medium power
- plutonium: must have *non-radioactive* water ***sources*** (not flowing water) around the reactor, explodes, highest power
]],
        requires = { "Planet Ores", "Radiation Shielding" }
    },

}
