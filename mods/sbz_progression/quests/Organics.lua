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
Plants also need three things: water next to the node they're on, heat from nearby light sources, and as much sky access as possible, hence the walls and ceiling of the habitat should be made of glass. If they don't get these things, they'll start to wilt and die instead of growing. So take that into consideration when designing a habitat.

Also, you can use the airtight power cable to deliver power to the switching station. And also make sure to not put things like slabs or stairs in the walls.
]],
        requires = { "Switching Station", "Emittrium Glass", "Dirt", "Sprouting Plants" }
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
        type = "secret",
        title = "Not Chorus Fruit",
        text =
        "So apparently Warpshrooms make you teleport randomly when you eat them. Dunno if that makes up for how long they take to grow."
    },
    {
        type = "quest",
        title = "Colorium Trees",
        text = [[
Have you dreamed of like... coloring... nodes... or like... having some trees? Yea, you can do those now.
So, how do you grow them:
1) Obtain the sapling
2) Put a strong light source next to it
3) Wait or use fertilizer on it

Unlike plants, it does not need to be inside a habitat regulator.
Achievment will unlock when your tree grows.
And also, colorium trunks can be used in the burner.

Oh yeah also..... trees may mutate.... take 1 sapling from your tree, grow it, take that sapling, grow it, take that sapling.. and you get the idea.... if you do that, you will see the tree be different.
]],
        requires = { "Neutronium" },
    },

}
