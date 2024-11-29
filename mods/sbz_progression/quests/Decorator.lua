return {
    { type = "text", title = "Questline: Decorator", text = "An island with just machines will look very boring! Use the knowledge from the Decorator Questline to spice up your island! These quests are not required for progression, but playing can get boring on an empty, barren, dark island. So don't just ignore this questline, okay? :P" },
    {
        type = "quest",
        title = "Compressed Core Dust",
        text =
        [[As you keep expanding your space station, you might wonder: "What am I going to do with all this Core Dust?". The answer to that question is to...

Compress it! Compressed Core Dust can be used as a building material.]],
        requires = { "A bigger platform" }
    },
    {
        type = "quest",
        title = "More Antimatter",
        text =
        [[Did you know that you can also craft Antimatter Blobs? They give off extremely faint light and unlock some lighting nodes to light up your island.
You can even make antimatter versions of some decorational blocks! Just be careful when placing them; if antimatter and matter come in contact then they will annihilate and create a violent explosion.

TIP: You can use compressed core dust as a buffer when dealing with antimatter.]],
        requires = { "Antimatter" }
    },
    {
        type = "quest",
        title = "Anti-Annihilator",
        text =
        [[Unfortunately, you don't seem to be strong enough to destroy that node once you place it. That kind of sucks, so let's craft something that can.

Now, to craft an Antimatter Annihilator you'll need a couple things:

* one Matter Dust
* one Charged Particle
* three Antimatter Blobs.

Make sure the Charged Particle is properly encased in antimatter, or it'll escape.]],
        requires = { "More Antimatter" }
    },
    {
        type = "quest",
        title = "Screwdriver",
        text = "Screwdriver rotates blocks when you click on one with it. Same as mtg screwdriver.",
        requires = { "Antimatter", "Introduction" }
    },
    --[[
    {
        type = "quest",
        title = "Matter Stairs",
        text = [[Stairs in a space game, huh?

Let me tell you, they’re the universe’s ultimate prank. You’d think in the vast expanse of space, we’d figure out a way to do away with stairs. But no!
Instead, we have these absurd vertical obstacles that defy both gravity and logic. Picture this: you’re navigating a sleek, futuristic spaceship, zooming through hyperspace, and suddenly—bam!—you’re face-to-face with a stairway.
Not just any stairway, but one that seems to stretch endlessly between levels of the ship. You’re floating in zero-g, and your only choice is to awkwardly flail your way up or down, hoping you don’t collide with the bulkheads.
And what’s with the handrails? They’re always placed at just the wrong height, making it feel like they’re mocking you as you drift by. Oh, you wanted support? Too bad, space cadet!
I swear, every time I encounter these space stairs, I wonder if the game developers just had a sadistic streak. Let’s see how they handle these! We’ve mastered faster-than-light travel, but let’s make sure their biggest challenge is a staircase that defies the laws of physics!
Next time you’re floating through the cosmos and stumble upon these absurd contraptions, just remember: they’re not there to help you—they’re there to remind you that even in the boundless universe, the real challenge is mastering the art of interstellar stair-climbing.]] --[[,
        requires = { "A bigger platform" }
    },
    --]]
    {
        type = "quest",
        title = "CNC Machines",
        text = [[
Do you want shapes that aren't... blocks? Like... stairs?
Oh do i have the machine for you!

With a CNC machine you can make all sorts of stairs and slabs....
Craft one, put in the block of your choosing*, and boom!

*The block needs to be compatible with the CNC machine, it usually will have a grey "You can make stairs with it!" text.
]],
        requires = { "Emittrium Circuits" }
    },
    {
        type = "quest",
        title = "Factory Flooring",
        text = "This is a node to use as floor for your factory, to give it those classic vibes.",
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Tiled Factory Flooring",
        text = "A variation of Factory Flooring which add even more tiling!",
        requires = { "A bigger platform", "Factory Flooring" }
    },

    {
        type = "quest",
        title = "Factory Ventilator",
        text = "You might want a Ventilation system inside a factory, just saying.",
        requires = { "Factory Flooring", "Crusher" }
    },

    {
        type = "quest",
        title = "Reinforced Matter",
        text =
        "Normal matter isn't sturdy enough? Try this one. This one won't break, unless you break it, then it breaks. Wait a minute...",
        requires = { "A bigger platform", "Matter Plates" }
    },

    {
        type = "quest",
        title = "Emitter Immitators",
        text = [[Emitter Immitators are decorational nodes providing light.

You can get one, by surrounding a 'Matter Blob' with 'Antimatter Dust'. They don't glow as much as The Core though.

TIP: Emitter Immitators spawn a lot of particles when punched, try it!]],
        requires = { "A bigger platform", "More Antimatter" }
    },

    {
        type = "quest",
        title = "Photon Lamps",
        text = [[Are Emitter Immitators too dim for you? Introducing: Photon Lamps!

With this revolutionary technology you can light up your world... uhm... the same way... as with Emitter Immitators... just brighter!
As for getting one, well, we don't sell them yet so you're just going to have to make your own!

Here goes: A matter blob in the center, four matter plates in the corners and then just fill the rest of the spaces with regular Emitter Immitators.
Boom! You're done! Now you've got yourself a Photon Lamp! No more sitting in darkness! Yay!]],
        requires = { "Emitter Immitators", "Matter Plates" }
    },

    {
        type = "quest",
        title = "Phosphor",
        text =
        "On the other hand, you can craft an Emittrium Circuit with an Emitter Imitator to make Phosphor, a very weak light source which however is turned on and off using power. This may be useful as an indicator of whether machines are working... or for discos.",
        requires = { "Emitter Immitators", "Emittrium Circuits" }
    },
    {
        type = "quest",
        title = "Signs",
        text =
        "Do you want to write something.... that's like... visible in the world? You should consider crafting a sign.",
        requires = { "Antimatter" }
    },
    {
        type = "quest",
        title = "Powered Lights",
        text =
        "Do you want to light up an area, cheaply? Powered lamps are the way to do it.... if you find something cheaper its a bug.\nOr do you want to light up a huge area, the Super powered lamp is for you, it fills up a 12x12x12 cube with invisible lights for somewhat low power consumbtion!",
        requires = { "Switching Station", "More Antimatter", "Emittrium Glass" }
    },
    {
        type = "quest",
        title = "Coloring Tool",
        text = [[
Yeah, if you actually want to color nodes, use that.
It requires 1 colorium per each node you are coloring.

You extract colorium dust from colorium leaves, then you put it in the furnace.
With that colorium, you make your tool.
        ]],
        requires = { "Colorium Trees" }
    }
}
