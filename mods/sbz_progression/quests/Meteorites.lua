return {
    {
        type = "text",
        title = "Questline: Meteorites",
        text = "",
    },
    {
        type = "quest",
        title = "Meteorites",
        text =
        "By this point you've probably been here for at least an hour. You've almost certainly noticed the funny asteroids that whiz past your core occasionally. These are actually a source of metal as well. If you can stop them, which is really hard when you don't know where they're going. But with the alloys you've got, you can craft Meteorite Radar, which shows you their trajectory and makes them much easier to catch. It'll probably still take a few tries though.",
        requires = { "Simple Alloy Furnace", "Emittrium Circuits" }
    },

    {
        type = "quest",
        title = "Laser",
        text = [[
Soo... i'm guessing you would have a lot of trouble getting to the meteorites by bridging...
Well don't fear, there is the laser now...

To charge the laser, "place it" into a battery. (shift+place to battery)
]],
        requires = { "Simple Alloy Furnace", "Emittrium Circuits" },
    },
    {
        type = "quest",
        title = "Neutronium",
        text =
        "In the core of a meteorite, you can find a single piece of very dense matter called Neutronium. It's so dense that you can craft it into a Gravitational Attractor, which attracts other passing meteorites and gets you even more metal, or a Gravitational Repulsor which drives them away.",
        requires = { "Meteorites" }
    },
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
        title = "Strange Blob Cleaner",
        requires = { "It's strange..." },
        text = [[
Restores what was destroyed by strange blobs.
        ]],
    }
}
