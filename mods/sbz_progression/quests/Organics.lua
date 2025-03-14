return {
    {
        type = "text",
        title = "Questline: Organics",
        text =
        "Grow plants and fungi to craft more things and also make your base look really cool."
    },
    {
        type = "quest",
        title = "Liquid Water",
        text =
        "Crushing pebbles squeezes out a bit of water. You can take advantage of this by crafting some fluid cells and putting them in the crusher output to collect it. Once you've done that, go build a little pool or something. :)",
        requires = { "Crusher" }
    },
    {
        type = "quest",
        title = "Emittrium Glass",
        text =
        "The other preliminary we need before we can start growing plants is glass. Thankfully it's really easy to craft, it only needs emittrium and antimatter and crafts a lot of glass.",
        requires = { "Antimatter", "Obtain Emittrium" }
    },
    {
        type = "quest",
        title = "Dirt",
        text =
        "If you've followed my instructions and built a pool, you should notice moss beginning to grow around it, and algae on top of it, if there's enough light. Take some of that moss and craft it into dirt.",
        requires = { "Liquid Water" }
    },
    {
        type = "quest",
        title = "Sprouting Plants",
        text =
        "You'll also need to craft the algae on your pool into fertilizer. This is useful for forcing dormant seeds in the non-fertilized dirt to germinate.",
        requires = { "Liquid Water" }
    },
    {
        type = "quest",
        title = "Growing Plants",
        text = [[
Alright, this is where it gets complicated, so read carefully.

All plants except moss and algae need to be placed in a habitat in order to grow properly. This means a fully enclosed room with a powered Habitat Regulator placed inside it.
Plants also need three things: water next to the node they're on, heat from nearby light sources. If they don't get these things, they'll start to wilt and die instead of growing. So take that into consideration when designing a habitat.

Also, you can use the airtight power cable to deliver power to the switching station. And also make sure to not put things like slabs or stairs in the walls.

<b>Tip: make the habitat walls out of solid nodes (emittrium glass is one of the cheapest), and airlocks, do not use things like stairs, or meteorite radars in the construction of your habitat. At most, use things that look like solid-full cubes. Also make sure that the habitat regulator isn't inside the wall, but inside the room you built.</b>
]],
        requires = { "Switching Station", "Emittrium Glass", "Dirt", "Sprouting Plants" }
    },
    {
        type = "quest",
        title = "TNT",
        requires = { "Growing Plants" },
        text = [[
There are TNT sticks, they are made by compressing 9 pyrograss. These TNT sticks can be thrown and they can be used in combat.

Normal TNT (compressed 9 tnt sticks, 81 pyrograss) can be lit by right clicking it. TNT knocks back entites (regardless of if there is line of sight) and damages entities only if there is line of sight.

To complete this quest, craft a full TNT block.

Also, TNT explosions are delayed if the server is laggy, meaning you can set up 100 000 TNT and it wouldn't be much of an issue. (frog tried this)
        ]],
    },
    {
        type = "quest",
        title = "Fertilized Dirt",
        text = [[
I'm guessing you want to grow plants faster now, don't worry, there is a solution!

You can craft fertilized dirt with 4 algae and 1 dirt, and boom, you have 3x faster dirt.
But there is a catch, the growth will be 3x faster, but so will the co2 consumbtion.
And you also can't fertilize the dirt, to germinate the dormant seeds, you have to manually place your plant.
]],
        requires = { "Growing Plants" }
    },
    {
        type = "quest",
        title = "Carbon Dioxide",
        text = [[
So now that you have a habitat, all you've got to do is use some fertilizer on some dirt inside it. Keep trying until you get a sort of purple grass - this is Pyrograss, a hardy yet very flammable monocotyledon. Wait for it to grow to full height and then harvest it.
	
There is one more thing which almost all plants except Pyrograss need: CO2, which they use to photosynthesize. To produce some, simply craft a Burner from Pyrograss and some other stuff. If placed in a habitat this will burn organic items placed inside it to release CO2 into the habitat's atmosphere - no power necessary. Some items are better than others, try out a few and see what works best!
Keep in mind, the excess co2 produced by the burner will stay in the habitat, so this means you can have a burner running, and it would build up co2 in the habitat.

The size of the habitat determines how much co2 it can hold.
]],
        requires = { "Growing Plants", "Annihilator" }
    },
    {
        type = "quest",
        title = "Stemfruit",
        text =
        "The only other plant you can get from fertilizing dirt is Stemfruit; you won't need to grow much of these, but due to their unusual genetic instability you can craft them with stuff to make new types of plant. Try out some combinations and see what you get!",
        requires = { "Carbon Dioxide" }
    },
    {
        type = "quest",
        title = "Fiberweed",
        text =
        "Unlike the other plants we've met so far, this one lives in the water, and can only be planted on dirt. It'll keep growing higher and higher until it reaches the surface of the water. Its sturdiness and fibrousness allow it to be crafted into Rope, which may be placed hanging from things to climb down them.",
        requires = { "Stemfruit" }
    },
    {
        type = "quest",
        title = "Airlocks",
        text =
        "Tired of breaking a hole in the wall whenever you want to enter a habitat? Introducing the Airlock: a node which holds in the atmosphere while letting you effortlessly walk through.",
        requires = { "Growing Plants", "Emittrium Glass" }
    },
    {
        type = "quest",
        title = "Co2 Compactors",
        text =
        "I'll assume you want to store a little more carbon dioxide in your habitat, well co2 compactors are excellent for that, they store 30 carbon dioxide in one node, so would be equivilent to 30 air nodes.",
        requires = { "Stemfruit", "Airlocks" }
    },
    {
        type = "quest",
        title = "Warpshrooms",
        text = [[
Applying a mystery, very dense block, to your stemfruit, gets you... a mushroom?  Well... there wasn't mush-room for realism haha!

Jokes aside, it grows like stemfruit, just a bit slower.
        ]],
        requires = { "Stemfruit", "Neutronium" }
    },
    {
        type = "secret",
        title = "Not Chorus Fruit",
        text =
        "So apparently Warpshrooms make you teleport randomly when you eat them. Dunno if that makes up for how long they take to grow."
    },
    {
        type = "quest",
        title = "Colorium Trees",
        text = [[
Have you dreamed of like... coloring... nodes... or like... having some trees? You can do/have that now.
So, how do you grow them:
1) Obtain the sapling
2) Put a strong light source next to it
3) Wait or use fertilizer on it

Unlike plants, it does not need to be inside a habitat regulator.
Achievment will unlock when your tree grows.
And also, colorium trunks can be used in the burner.

Also, you may see there is a tree core where the sapling used to be, that tree core contains the tree's DNA.
]],
        requires = { "Neutronium" },
    },
    {
        type = "quest",
        title = "Dna Extractor",
        text = [[
So, do you want a different tree?
1) Put your tree core in the dna extractor
2) Put your saplings (doesn't matter if they are the default saplings, or already have some dna on them)
3) Get your new sapling :D

That new sapling, when it grows, it will mutate slightly, so will the tree core.
You can put that new mutated tree core into the dna extractor, and repeat. After you do this enough times, you will get a tree completely different from the one you started with, you can go sell some tree cores to people too if you got a nice tree (assuming multiplayer) :D
    ]],
        requires = { "Colorium Trees" },
    },
    {
        type = "quest",
        title = "Colorium Emitters",
        text = [[
Tree farms are difficult, and sometimes needlessly laggy, so colorium emitters were made as a solution.
When you place them, don't worry, they can be dug.
They can also be colored, darker colors look weird, you should try them.
They can drop a sapling, a tree trunk or a leaf.

So... how do you get them....
They are in the cores of "Colorium Planets", those are the planets with trees and pyrograss.
Colorium emitters are surrounded by molten metal, so you will need some strong armor (neutronium armor works, may be overkill).
You will get this quest when you obtain one (possibly will need to move it around in the inventory).

You can duplicate colorium emitters with 8 phlogiston.
]],
        requires = { "Colorium Trees", "Phlogiston" },
    }

}
