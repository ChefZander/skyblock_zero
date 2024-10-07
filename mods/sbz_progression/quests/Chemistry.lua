return {
    { type = "text", title = "Questline: Chemistry", text = "Good luck." },

    { type = "quest", title = "Crusher", text = "This one's very simple :)\nIt's just pebbles in, metals out. Consumes 5 Power when running.", requires = { "Concrete Plan", "Antimatter", "Charged Field" } },

    { type = "secret", title = "It's fake", text = "Digital gold? Where have I heard that before..." },

    { type = "quest", title = "Furnace", text = "Craft the high power electric furnace (H.P.E.F for short), allows you to smelt any powder into an ingot, ingots are heavily used in crafting recipes.", requires = { "Crusher" } },


    { type = "quest", title = "Simple Alloy Furnace", text = "This one's less simple :)\nTry out some combinations of metals to see which ones create alloys. Consumes 10 Power when running.", requires = { "Crusher", "Emittrium Circuits", "Antimatter", "Charged Field" } },

    { type = "quest", title = "Bronze Age", text = "Congratulations, Commander! You've just unlocked the Bronze Age—because nothing says 'cutting-edge space exploration' like struggling to make a metal our ancestors figured out 5,000 years ago. Sure, you've mastered faster-than-light travel, but apparently mixing [REDACTED] and [REDACTED] is still rocket science. Good luck, Space Caveman!", requires = { "Simple Alloy Furnace", "Crusher" } },

    { type = "quest", title = "Meteorites", text = "By this point you've probably been here for at least an hour. You've almost certainly noticed the funny asteroids that whiz past your core occasionally. These are actually a source of metal as well, including some you can't get from crushing pebbles - if you can stop them, which is really hard when you don't know where they're going. But with the alloys you've got, you can craft Meteorite Radar, which shows you their trajectory and makes them much easier to catch. It'll probably still take a few tries though.", requires = { "Simple Alloy Furnace", "Emittrium Circuits" } },

    { type = "quest", title = "Neutronium", text = "In the core of a meteorite, you can find a single piece of very dense matter called Neutronium. It's so dense that you can craft it into a Gravitational Attractor, which attracts other passing meteorites and gets you even more metal, or a Gravitational Repulsor which drives them away.", requires = { "Meteorites" } },

    { type = "quest", title = "Bear Arms", text = "Craft the robotic arm.", requires = { "Furnace" } },
    { type = "quest", title = "Antimatter Generators", text = "Craft the antimatter generator, it is best used with automation or a large array of batteries. It needs 1 matter and 1 antimatter per second for 120 power/s.", requires = { "Furnace" } },
}
