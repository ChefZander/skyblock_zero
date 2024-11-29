return {
    { type = "text", title = "Questline: Chemistry", text = "Good luck." },

    { type = "quest", title = "Crusher", text = "This one's very simple :)\nIt's just pebbles in, metals out. Consumes 5 Power when running.", requires = { "Concrete Plan", "Antimatter", "Charged Field" } },

    { type = "secret", title = "It's fake", text = "Digital gold? Where have I heard that before..." },

    { type = "quest", title = "Furnace", text = "Craft the high power electric furnace (H.P.E.F for short), allows you to smelt any powder into an ingot, ingots are heavily used in crafting recipes.", requires = { "Crusher" } },


    { type = "quest", title = "Simple Alloy Furnace", text = "This one's less simple :)\nTry out some combinations of metals to see which ones create alloys. Consumes 10 Power when running.", requires = { "Crusher", "Emittrium Circuits", "Antimatter", "Charged Field" } },

    { type = "quest", title = "Bronze Age", text = "Congratulations, Commander! You've just unlocked the Bronze Age—because nothing says 'cutting-edge space exploration' like struggling to make a metal our ancestors figured out 5,000 years ago. Sure, you've mastered faster-than-light travel, but apparently mixing [REDACTED] and [REDACTED] is still rocket science. Good luck, Space Caveman!", requires = { "Simple Alloy Furnace", "Crusher" } },

    { type = "quest", title = "Meteorites", text = "By this point you've probably been here for at least an hour. You've almost certainly noticed the funny asteroids that whiz past your core occasionally. These are actually a source of metal as well, including some you can't get from crushing pebbles - if you can stop them, which is really hard when you don't know where they're going. But with the alloys you've got, you can craft Meteorite Radar, which shows you their trajectory and makes them much easier to catch. It'll probably still take a few tries though.", requires = { "Simple Alloy Furnace", "Emittrium Circuits" } },

    { type = "quest", title = "Neutronium", text = "In the core of a meteorite, you can find a single piece of very dense matter called Neutronium. It's so dense that you can craft it into a Gravitational Attractor, which attracts other passing meteorites and gets you even more metal, or a Gravitational Repulsor which drives them away.", requires = { "Meteorites" } },
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

Jetpack gets automatically de-activated when you stop having it in your hand or it runs out of wear
]],
        requires = { "Neutronium" }
    },
    { type = "quest", title = "Bear Arms",             text = "Notice the small little pun there? .. it's obvious that it tells you to craft a Robotic Arm? Oh.",                                                              requires = { "Furnace" } },
    {
        type = "quest",
        title = "Electric Drill",
        requires = { "Bear Arms" },
        text = [[
Do you think that the robotic arm is too fragile, or do you want to  dig and have your tool not break as easily?
Electric drill is the tool for you!!!

It has 500 uses and powered by electricity!
What does that mean?

If you "place" it on a battery (sneak+right click), it will take power from the battery and charge the drill! (Just like the jetpack)
It needs 1 power per 1 use.

It also digs 2x faster than the robotic arm.
]]
    },
    { type = "quest", title = "Antimatter Generators", text = "Craft the antimatter generator, it is best used with automation or a large array of batteries. It needs 1 matter and 1 antimatter per second for 120 power/s.", requires = { "Furnace" } },
    {
        type = "quest",
        title = "Meteorite Maker",
        text = [[
Makes... meteorites... (no way), also it needs some space on top of it.
But it cannot make strange matter meteorites.

Tip: By far, the fastest meteorite to mass produce is the emitter meteorite.
]],
        requires = { "Autocrafters", "Neutronium" }
    },
    {
        type = "quest",
        title = "It's strange...",
        text = [[
Be aware, strange matter can... spread... to both matter and antimatter...

Strange matter won't spread to "charged" nodes or machines, or protected areas.
So it's best to protect your area, even if you are in singleplayer, to defend against strange matter.

Strange matter meteorites spawn if you are 100 nodes away from the core.
]],
        requires = { "Neutronium" }
    },
    {
        type = "quest",
        requires = { "It's strange..." },
        title = "Strange Blob Cleaner",
        text = [[
Restores what was destroyed by strange blobs.
        ]],
    }
}
