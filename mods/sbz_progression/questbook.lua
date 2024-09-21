quests = {
    { type = "text",  title = "Questline: Introduction", text = "The first questline, to introduce you to the game. Your adventure will start here." },

    {
        type = "quest",
        title = "Introduction",
        text =
        [[Welcome, player. This is the Quest Book. Here, you can check out what tasks you have to do, and the materials you will need for each quest.
		
You can also just ignore the Quest Book if you are an experienced player.
			
Now, to get started: look down at the core. Punching it will give you some of your first resources.

These quests are in no particular order, but you might need items from one quest for another.

TIP: If you lose your Quest Book, you can use /qb to get it back.]],
        requires = {}
    },

    {
        type = "quest",
        title = "A bigger platform",
        text = [[Isn't this one node a little too crammed? Let's do something about that.

Punch the Core a little more. With nine 'Matter Dust', you can craft yourself a 'Matter Blob'. Place it down, and then check the Quest Book again when you've done that.]],
        requires = { "Introduction" }
    },


    {
        type = "quest",
        title = "Antimatter",
        text =
        [[Unfortunately, you don't seem to be strong enough to destroy that node once you place it. That kind of sucks, so let's craft something that can.

Craft some 'Antimatter Dust', we'll need it for later. It's made by mixing 'Matter Dust' and 'Core Dust'. Let's see you figure this out, smart one.]],
        requires = { "Introduction" }
    },
	
    {
        type = "quest",
        title = "Annihilator",
        text = [[Doesn't it feel weird to be holding antimatter?

Now, to craft a Matter Annihilator you'll need a couple things:

* one Antimatter Dust
* one Charged Particle
* three Matter Blobs.

Make sure the Charged Particle is properly encased in matter, or it'll escape.]],
        requires = { "A bigger platform", "Antimatter" }
    },

    {
        type = "quest",
        title = "Charged Field",
        text = [[Now, then. We have one more thing to do before we can start automating. Can you guess what it is?

That's right! We need power generation.

Using nine Charged Particles, you can craft yourself a Simple Charged Field.
But listen up! Charged Fields decay over time, leaving indestructible residue (that decays in a relatively short time) behind. Since you are using a Simple Charged Field, you should expect to have energy for about 10 minutes.

Yeah, it uses energy even when there's nothing connected to it. Since resources are infinite here, time is your resource.
Anyways, I talked a lot, didn't I? Maybe too much. Let's get automating.]],
        requires = { "Introduction" }
    },

    {
        type = "quest",
        title = "Matter Plates",
        text = [[Matter Plates are often used for machinery. They are simple to craft, yet very important.

You can get four Matter Plates by placing one matter blob into the crafting grid.]],
        requires = { "A bigger platform" }
    },

    { type = "quest", title = "Switching Station",       text = "The Switching Station is an important node, because it is the heart of any Power Grid. You have to have exactly one per Power Grid, if you dont have one nothing will work, and if you have more than one, they will explode until there is only one in the power grid. The Switching Station also displays statistics about the Power Grid when hovered over in-world.", requires = { "Matter Plates" } },

    {
        type = "quest",
        title = "Automation",
        text = [[Finally! Automation! Let's get on that, shall we? Here's what you'll need for a Simple Matter Extractor:

One Matter Annihilator, four matter blobs and four bits of core dust.

TIP: Machines without power occasionally emit red particles.]],
        requires = { "Annihilator", "Charged Field" }
    },

    {
        type = "quest",
        title = "Advanced Extractors",
        text =
        [[That's a shiny new machine you've got there! Do you also want to triple your production? Only for DOUBLE THE POWER? Sure you do.

For Advanced Extractors you'll obviously need a Simple Matter Extractor, then four Matter Annihilators and four matter Blobs. That's a lot of resources, but this Extractor will also occasionally generate Core Dust!

For the curious, an Advanced Extractor has a 4% chance of extracting core dust. This means a core dust will be extracted every 40 seconds (on average).]],
        requires = { "Automation" }
    },

    {
        type = "quest",
        title = "Circuitry",
        text =
        [[Circuits are important crafting components for future recipes. You'll need them for lots of recipes, and many of them too.

Simple Circuits are currently your only available Circuit type, but there are different circuit types which will be used in the future. Also, all different Circuit types use Simple Circuits as their base.

To craft a Simple Circuit, you'll need one core dust and one matter blob. You'll get two Simple Circuits from that craft.]],
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Generators",
        text =
        [[Right now, you're probably using simple charged fields to generate your power, but since they decay, they don't last forever, which is not convenient.

To solve that, you can use a generator; it consumes core dust as fuel over time, and provides you with more power than simple charged fields do.

However, Generators are expensive. They require 4 simple charged fields, an antimatter dust, 3 matter blobs and 1 Matter Annihilator to craft.]],
        requires = { "Charged Field", "Antimatter" }
    },

    {
        type = "quest",
        title = "Retaining Circuits",
        text =
        [[Retaining Circuits are a type of Circuit often used in nodes which store items, either permanently or temporarily. Circuits depend on other circuits which is why you will need a Simple Circuit to craft this Circuit.

The list of materials is as follows: one Simple Circuit, one charged particle and one antimatter dust.

Unlike Simple Circuits, this will only craft one Retaining Circuit.]],
        requires = { "Antimatter", "Circuitry" }
    },

    {
        type = "quest",
        title = "Storinators",
        text =
        [[Storinators are the solution to clogged up inventories. They have 30 slots of inventory, and function like a chest.

The more red/green dots the front of a storinator displays, the more full/empty it is.

You will need one simple charged field, one Simple Circuit, four matter plates and three Retaining Circuits to craft one Storinator.]],
        requires = { "Matter Plates", "Charged Field", "Retaining Circuits" }
    },

    {
        type = "quest",
        title = "Pretty Pebbles",
        text =
        [[We're making the jump from generic matter to stone now! Here is where building a space station gets fun!

First, before we can make Stone nodes we will need Pebbles. They are quite difficult to make, requiring three matter blobs in a shapeless craft.
Pebbles will unlock a lot of decorational nodes to spice up your island, as well as plenty of tech, and if you want you can even start building your own planet. It's all up to your imagination!]],
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Concrete Plan",
        text =
        [[Just regular old boring stone, nothing really to add here. Like, it's literally just stone. You know, the kind that would make even a rock collector yawn and say, "I've seen gravel with more personality". It sits around all day, doing nothing—no metamorphosis, no glittering crystals—just living its best sedentary life.

That said, it's made using 9 pebbles.]],
        requires = { "Pretty Pebbles" }
    },

    -- ======================================================================================
    { type = "text", title = "Questline: Emittrium", text = "Emittrium is a very important material when working with Cosmic Joules. This questline will teach you all about it." },

    {
        type = "quest",
        title = "Obtain Emittrium",
        text =
        [[Do you see those blue stars in the distance? They're called Emitters. To obtain Emittrium from them, you will have to build a bridge over to one.
I would recommend to choose the closest one to you, but any Emitter works. Next, you'll need a Matter Annihilator. You can't destroy the Emitters, but you can chip away at them.

Punch your Emitter of choice until it yields some 'Raw Emittrium'. We'll refine the Emittrium later, but for now we just need it in its raw state.

Emitters have a 1/10 chance of producing Raw Emittrium, and a 9/10 chance of just producing the same materials that core does.
]],
        requires = { "Annihilator" }
    },

    { type = "quest", title = "Power Cables", text = [[
To transfer power from generators to machines, you'll need Power Cables. You can get a power cable with a shapeless craft using one Raw Emittrium and one Matter Plate.
The cables will connect up and supply your machines with power, looking at your machine will show 'Running' if the machine is running.
Also, if you put a machine next to another machine, it will conduct power to that machine, so you only need power cables in very specific cases (like automation).]], requires = { "Matter Plates", "Obtain Emittrium" } },

    { type = "quest", title = "Starlight Collectors", text = "Starlight Collectors turn the light of stars into power for you to use. But the stars are very faint, so you'll need a lot of these if you want to power a whole factory!", requires = { "Obtain Emittrium" } },

    { type = "quest", title = "Emittrium Circuits", text = "For almost all recipes related to storing or transferring Cosmic Joules (power), you'll need Emittrium Circuits. They're a shapeless craft using Raw Emittrium, a Charged Particle, a Retaining Circuit and a matter plate.", requires = { "Matter Plates", "Obtain Emittrium", "Retaining Circuits" } },

    { type = "quest", title = "Batteries", text = "Sometimes, you'll need to temporarily buffer some energy. That's what the Battery is for. It stores up to 300 Cosmic Joules of energy. You can craft it by surrounding a Emittrium Circuit with matter blobs.", requires = { "Emittrium Circuits" } },

    { type = "quest", title = "Advanced Batteries", text = "Sometimes, you'll need to temporarily buffer lots of energy. Ah, you know what this is for. It stores 900 Cosmic Joules, it's for when your factory needs to be compact. Yadda yadda.", requires = { "Batteries", "Furnace" } },

    { type = "quest", title = "Connectors", text = "If for some reason you want to turn machines off and on, you can use these things called Connectors. They join two networks together, and you can click on them to turn them on and off. Yeah, that's about it.", requires = { "Emittrium Circuits", "Reinforced Matter" } },

    { type = "quest", title = "Infinite Storinators", text = "Infinite Storinators are like normal Storinators, except you can store way more items in them. They have customizable storage size and consume 1 power per row of items. The limit of slots on an Infinite Storinator is 5000, that's 4970 more than a normal Storinator!", requires = { "Emittrium Circuits", "Storinators", "Meteorites" } },
    -- ======================================================================================
    { type = "text", title = "Questline: Chemistry", text = "Good luck." },

    { type = "quest", title = "Crusher", text = "This one's very simple :)\nIt's just pebbles in, metals out. Consumes 5 Power when running.", requires = { "Concrete Plan", "Antimatter", "Charged Field" } },
    
    { type = "secret", title = "It's fake", text = "Digital gold? Where have I heard that before..." },

    { type = "quest", title = "Furnace", text = "Craft the high power electric furnace (H.P.E.F for short), allows you to smelt any powder into an ingot, ingots are heavily used in crafting recipes.", requires = { "Crusher" } },


    { type = "quest", title = "Simple Alloy Furnace", text = "This one's less simple :)\nTry out some combinations of metals to see which ones create alloys. Consumes 10 Power when running.", requires = { "Crusher", "Emittrium Circuits", "Antimatter", "Charged Field" } },

    { type = "quest", title = "Bronze Age", text = "Congratulations, Commander! You've just unlocked the Bronze Age—because nothing says 'cutting-edge space exploration' like struggling to make a metal our ancestors figured out 5,000 years ago. Sure, you've mastered faster-than-light travel, but apparently mixing [REDACTED] and [REDACTED] is still rocket science. Good luck, Space Caveman!", requires = { "Simple Alloy Furnace", "Crusher" } },

    { type = "quest", title = "Meteorites", text = "By this point you've probably been here for at least an hour. You've almost certainly noticed the funny asteroids that whiz past your core occasionally. These are actually a source of metal as well, including some you can't get from crushing pebbles - if you can stop them, which is really hard when you don't know where they're going. But with the alloys you've got, you can craft Meteorite Radar, which shows you their trajectory and makes them much easier to catch. It'll probably still take a few tries though.", requires = { "Simple Alloy Furnace", "Emittrium Circuits" } },

    { type = "quest", title = "Neutronium", text = "In the core of a meteorite, you can find a single piece of very dense matter called Neutronium. It's so dense that you can craft it into a Gravitational Attractor, which attracts other passing meteorites and gets you even more metal, or a Gravitational Repulsor which drives them away.", requires = { "Meteorites" } },

    { type = "quest", title = "Bear Arms", text = "Craft the robotic arm.", requires = { "Furnace" } },
    { type = "quest", title = "Antimatter Generators", text = "Craft the antimatter generator, it is best used with automation or a LARGE ammount of batteries. It needs 1 matter and 1 antimatter per second for 120 power/s.", requires = { "Furnace" } },

    -- ======================================================================================
    { type = "text", title = "Questline: Organics", text = "Grow plants and fungi to craft more things and also make your base look really cool." },
    { type = "quest", title = "Liquid Water", text = "So it turns out that crushing pebbles actually squeezes out a bit of water. You can take advantage of this by crafting some fluid cells and putting them in the crusher output to collect it. Once you've done that, go build a little pool or something, I dunno.", requires = { "Crusher" } },
    { type = "quest", title = "Emittrium Glass", text = "The other preliminary we need before growing stuff is glass. Thankfully it's really easy to craft, it only needs emittrium and antimatter and crafts a lot of glass.", requires = { "Antimatter", "Obtain Emittrium" } },
    { type = "quest", title = "Dirt", text = "If you've followed my instructions and built a pool, you should notice moss beginning to grow around it, and algae on top of it, if there's enough light. Take some of that moss and craft it into dirt.", requires = { "Liquid Water" } },
    { type = "quest", title = "Sprouting Plants", text = "You'll also need to craft the algae on your pool into fertilizer. This is useful for speeding up plant growth, or for forcing dormant seeds in the dirt to germinate.", requires = { "Liquid Water" } },
    { type = "quest", title = "Growing Plants", text = [[
Alright, this is where it gets complicated, so read carefully.

All plants except moss and algae need to be placed in a habitat in order to grow properly. This means a fully enclosed room with a powered Habitat Regulator placed inside it.
Plants also need three things: water next to the node they're on, heat from nearby light sources, and as much sky access as possible, hence the walls and ceiling of the habitat should be made of glass. If they don't get these things, they'll start to wilt and die instead of growing. So take that into consideration when designing a habitat.]], requires = { "Switching Station", "Emittrium Glass", "Dirt", "Sprouting Plants" } },
    { type = "quest", title = "Carbon Dioxide", text = [[
So now that you have a habitat, all you've got to do is use some fertilizer on some dirt inside it. Keep trying until you get a sort of purple grass - this is Pyrograss, a hardy yet very flammable monocotyledon. Wait for it to grow to full height and then harvest it.
	
There is one more thing which almost all plants except Pyrograss need: CO2, which they use to photosynthesize. To produce some, simply craft a Burner from Pyrograss and some other stuff. If placed in a habitat this will burn organic items placed inside it to release CO2 into the habitat's atmosphere - no power necessary. Some items are better than others, try out a few and see what works best!]], requires = { "Growing Plants", "Annihilator" } },
    { type = "quest", title = "Stemfruit", text = "The only other plant you can get from fertilizing dirt is Stemfruit; you won't need to grow much of these, but due to their unusual genetic instability you can craft them with stuff to make new types of plant. Try out some combinations and see what you get!", requires = { "Carbon Dioxide" } },
    { type = "quest", title = "Fiberweed", text = "Unlike the other plants we've met so far, this one lives in the water, and can only be planted on dirt. It'll keep growing higher and higher until it reaches the surface of the water. Its sturdiness and fibrousness allow it to be crafted into Rope, which may be placed hanging from things to climb down them.", requires = { "Stemfruit" } },
    { type = "quest", title = "Airlocks", text = "Tired of breaking a hole in the wall whenever you want to enter a habitat? Introducing the Airlock: a node which holds in the atmosphere while letting you effortlessly walk through.", requires = { "Growing Plants", "Emittrium Glass", "Neutronium" } },
    { type = "secret", title = "Not Chorus Fruit", text = "So apparently Warpshrooms make you teleport randomly when you eat them. Dunno if that makes up for how long they take to grow." },


    -- ======================================================================================
    { type = "text", title = "Questline: Decorator", text = "An island with just machines will look very boring! Use the knowledge from the Decorator Questline to spice up your island! These quests are not required for progression, but playing can get boring on an empty, barren, dark island. So don't just ignore this questline, okay? :P" },
	{
        type = "quest",
        title = "More Antimatter",
        text =
        [[Did you know that you can also craft Antimatter Blobs? They give off extremely faint light and unlock some lighting nodes to light up your island.
You can even make antimatter versions of some decorational blocks! Just be careful when placing them; if antimatter and matter come in contact then they will annihilate and create a violent explosion.

TIP: You can use simple charged fields as scaffolding when dealing with antimatter.]],
        requires = { "Antimatter" }
    },
    {
        type = "quest",
        title = "Anti-Annihilator",
        text = [[Unfortunately, you don't seem to be strong enough to destroy that node once you place it. That kind of sucks, so let's craft something that can.

Craft some 'Antimatter Annihilator', we'll need it for later. It's made by mixing 'Antimatter Blob', 'Charged Particle' and 'Matter Dust'. Let's see you figure this out, smart one.]],
        requires = { "More Antimatter" }
    },
	{
        type = "quest",
        title = "Screwdriver",
        text = "Screwdriver rotates blocks when you click on one with it.",
        requires = { "Antimatter", "Introduction" }
    },
    {
        type = "quest",
        title = "Matter Stairs",
        text = [[Stairs in a space game, huh?

Let me tell you, they’re the universe’s ultimate prank. You’d think in the vast expanse of space, we’d figure out a way to do away with stairs. But no!
Instead, we have these absurd vertical obstacles that defy both gravity and logic. Picture this: you’re navigating a sleek, futuristic spaceship, zooming through hyperspace, and suddenly—bam!—you’re face-to-face with a stairway.
Not just any stairway, but one that seems to stretch endlessly between levels of the ship. You’re floating in zero-g, and your only choice is to awkwardly flail your way up or down, hoping you don’t collide with the bulkheads.
And what’s with the handrails? They’re always placed at just the wrong height, making it feel like they’re mocking you as you drift by. Oh, you wanted support? Too bad, space cadet!
I swear, every time I encounter these space stairs, I wonder if the game developers just had a sadistic streak. Let’s see how they handle these! We’ve mastered faster-than-light travel, but let’s make sure their biggest challenge is a staircase that defies the laws of physics!
Next time you’re floating through the cosmos and stumble upon these absurd contraptions, just remember: they’re not there to help you—they’re there to remind you that even in the boundless universe, the real challenge is mastering the art of interstellar stair-climbing.]],
        requires = { "A bigger platform" }
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

    { type = "quest", title = "Phosphor", text = "On the other hand, you can craft an Emittrium Circuit with an Emitter Imitator to make Phosphor, a very weak light source which however is turned on and off using power. This may be useful as an indicator of whether machines are working... or for discos.",                                                                                                                                                                                                                                                  requires = { "Emitter Immitators", "Emittrium Circuits" } },
    -- ======================================================================================
    {
        type = "text",
        title = "Questline: Pipeworks",
        text =
        [[If you already know about regular pipeworks, skyblock_zero's pipeworks are a very modified version of that mod, but it will be similar though.]]
    }, {
    type = "quest",
    title = "Tubes",
    text = [[
Have you ever wanted to automatically move items around without input?

Now you can!

Tubes are, well, tubes that can transport items around! Currently, you can't interact with them: but just have some lying around, the next and future quests utilize them.

TIP: Items in tubes will go into directions with higher priority.]],
    requires = { "Furnace" },
}, {
    type = "quest",
    title = "Automatic Filter-Injectors",
    text = [[
Have you ever been tired of taking items out of nodes? Do you just want to interact with tubes as soon as possible?

Now you can!

The Automatic Filter-Injector takes stacks of items from nodes, and places them into tubes or other nodes. 

]],
    requires = { "Bear Arms", "Tubes" }
}, {
    type = "quest",
    title = "Node Breakers",
    text = "Node Breakers try to break the node in front of them. The drops are thrown away into the back-side. They need 1 power and run every second.",
    requires = { "Automatic Filter-Injectors" }
}, {
    type = "quest",
    title = "Deployers",
    text = "Deployers try to place a node into their front-side. That's about it.",
    requires = { "Automatic Filter-Injectors", "Bear Arms" }
}, {
    type = "quest",
    title = "Punchers",
    text = "Punchers punch stuff, allowing you to automate resource generation even more.",
    requires = { "Automatic Filter-Injectors", "Bear Arms", "Emittrium Circuits" }
}, {
    type = "quest",
    title = "Autocrafters",
    text = "Autocrafters automatically craft. You can make them craft as fast as possible, but they consume more power depending on the current crafts/s.",
    requires = { "Bear Arms", "Neutronium", "Emittrium Circuits", "Automatic Filter-Injectors" }
}, {
    type = "quest",
    title = "Item Voids",
    text = "Item voids delete every item that goes in, and yes these are pipeworks trashcans.",
    requires = { "Tubes" }
}, {
    type = "quest",
    title = "Item Vacuums",
    text = "Item Vacuums vacuum up items in a 16 block radius, but they tend to cause lag.",
    requires = { "Neutronium", "Tubes" }
},
    -- ==================================================================================================

    { type = "text",  title = "Questline: Fluid Transport",                       text = "This questline is all about transporting fluids." },
    { type = "quest", title = "Fluid Pipes",                                      text = "A fluid pipe is like a tube, but with fluids. They move fluids around, just like how tubes move items around.",                                                                                                                                                                                                                                                                                                                                                                                 requires = { "Tubes" } },
    { type = "quest", title = "Fluid Pumps",                                      text = "Fluid Pumps are automatic filter-injectors, but for pipes. They take fluids from fluid inventories.",                                                                                                                                                                                                                                                                                                                                                                                                                                                     requires = { "Automatic Filter-Injectors" } },
    { type = "quest", title = "Fluid Storage Tanks",                              text = "Fluid Storage Tanks are storinators for fluids. They can store 100 nodes of fluid. That's a lot!",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            requires = { "Tubes", "Storinators" } },
    { type = "quest", title = "Fluid Capturers",                                  text = "Fluid Capturers capture liquid SOURCES from their top and store them. You can take out the captured fluid with a fluid pump.",                                                                                                                                                                                                                                                                                                                                                                                     requires = { "Fluid Storage Tanks" } },
    { type = "quest", title = "Fluid Cell Fillers",                               text = "Fluid Cell Fillers fill empty fluid cells in their inventories.",                                                                                                                                                                                                                                                                                                                                                                                                                                                            requires = { "Fluid Storage Tanks" } },
    -- ==================================================================================================
    { type = "text",  title = "Questline: Emittrium Reactor",                     text = [[
Emittrium reactors are another way of generating energy. They are a 3x3x3 cube made of reactor shells (or reactor glass), with a reactor core in the center. The shells can be replaced with a reactor power port, a reactor coolant port, a reactor emittrium port and a reactor infoscreen. It consumes emittrium and water, and generates 800 power.
If it doesn't have enough coolant (water), it heats up, and bad things happen if it heats up too much.]] },
    { type = "quest", title = "Reactor Shells",                                   text = "Reactor Shells are needed in crafting the emittrium reactor parts, and construction of the emittrium reactor.",                                                                                                                                                                                                                                                                                                                                                                                                   requires = { "Obtain Emittrium" } },
    { type = "quest", title = "Reactor Glass",                                    text = "Reactor Glass is needed in crafting recipes, and optionally can be used as a replacement for the reactor shell in the construction of the emittrium reactor.",                                                                                                                                                                                                                                                                                                                                                    requires = { "Emittrium Glass", "Reactor Shells" } },
    { type = "quest", title = "Reactor Infoscreens",                              text = "A Reactor Infoscreen is needed in the construction of the emittrium reactor, and are needed to turn on the reactor.",                                                                                                                                                                                                                                                                                                                                                                                                            requires = { "Reactor Glass" } },
    { type = "quest", title = "Reactor Power Ports",                              text = "A Reactor Power Port is needed in the construction of the emittrium reactor. They deliver the energy generated by the reactor core.",                                                                                                                                                                                                                                                                                                                                                                                                            requires = { "Reactor Shells" } },
    { type = "quest", title = "Reactor Coolant Ports",                            text = "A Reactor Coolant Port is needed in the construction of the emittrium reactor. They need 1 water bucket/s (delivered in pipes) to sustain reactor heat.",                                                                                                                                                                                                                                                                                                                                                                                                           requires = { "Fluid Storage Tanks" } },
    { type = "quest", title = "Reactor Emittrium Input",                          text = "A Reactor Emittrium Input is needed in the construction of the emittrium reactor. They need 16 emittrium/minute to fuel the reactor.",                                                                                                                                                                                                                                                                                                                                                                                                                             requires = { "Reactor Shells", "Tubes" } },
    { type = "quest", title = "Reactor Core",                                     text = "A Reactor Core is needed in the construction of the emittrium reactor. Needs to be in the center.",                                                                                                                                                                                                                                                                                                                                                                                                                                 requires = { "Neutronium", "Reactor Shells" } },
    { type = "quest", title = "Building the emittrium reactor and turning it on", text = "Build a 3x3 cube of reactor shells or reactor glass, in the center, place the core, but in place of some of these shells, build the extra blocks mentioned earlier (Emittrium input, coolant port, power port, etc.)\n\nNow, to actually turn the reactor on, click the infoscreen, then turn it on in the UI. If you have something wrong in the reactor, it will tell you.\n\nIf you have multiple reactors, try pressing the re-link button if you think the infoscreen is displaying the wrong information", requires = { "Reactor Shells", "Reactor Infoscreens", "Reactor Power Ports", "Reactor Coolant Ports", "Reactor Emittrium Input", "Reactor Core" } },
    -- ======================================================================================
    { type = "text",  title = "Questline: Completionist",                         text = "This is the Completionist Questline. Only for hardcore gaming enjoyers, good luck completing it." },

    { type = "quest", title = "Antineutronium", text = [[
Sometimes, meteorites whizzing by will be made of antimatter instead of regular matter. These meteorites have Antineutronium in their core.
Antineutronium can be crafted into a Gravitational Repulsor, which repulses meteorites.

TIP: Build a shield out of simple charged fields to protect against antimatter meteorites.]], requires = { "Meteorites" } },
    {
        type = "quest",
        title = "Angel's Wing",
        text =
        "The Angel's Wing can make you fly. Right-Click to use, it has 100 uses. To craft, surround a Emittrium Circuit with Stone. This recipe is temporary.",
        requires = { "Emittrium Circuits", "Concrete Plan" }
    },
    {
        type = "quest",
        title = "Small Protectors",
        text =
        [[
Small protectors protect a decently sized area.
Unwanted people won't be able to take items from machines or modify filter injectors or... like... do anything in your land... if the area is protected. Also this can't be placed anywhere near cores.]],
        requires = { "Concrete Plan", "Furnace" }
    }, {
    type = "quest",
    title = "Big Protectors",
    text = "Large protectors are like the small protectors but bigger.",
    requires = { "Small Protectors" }
}, {
    type = "quest",
    title = "Public Storinators",
    text =
    "Public storinators are like regular storinators but accessible to ANYONE, regardless of protections.",
    requires = { "Storinators" }
},
{ type = "secret", title = "Emptiness", text = "Damn. You fell off." },
{ type = "secret", title = "Desolate",  text = "You talked to yourself." },
{ type = "secret", title = "Fragile",   text = "You broke an Angel's Wing." },}
local function getquestbyname(questname)
    for i, quest in ipairs(quests) do
        if quest.title == questname then
            return quest
        end
    end
end

local function combineWithAnd(list)
    local listLength = #list

    if listLength == 0 then
        return ""
    elseif listLength == 1 then
        return list[1]
    elseif listLength == 2 then
        return list[1] .. " and " .. list[2]
    else
        local combinedString = table.concat(list, ", ", 1, listLength - 1)
        combinedString = combinedString .. ", and " .. list[listLength]
        return combinedString
    end
end

function unlock_achievement(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return
    end

    local meta = player:get_meta()
    if not is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, "true")
        minetest.chat_send_player(player_name, "Quest Completed: " .. achievement_id .. "!")

        local pos = player:get_pos()
        minetest.add_particlespawner({
            amount = 50,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 15,
            maxexptime = 25,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "organic_particle.png",
            glow = 10
        })
    end
end

function revoke_achievement(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return
    end

    local meta = player:get_meta()
    if is_achievement_unlocked(player_name, achievement_id) then
        meta:set_string(achievement_id, "")
        minetest.chat_send_player(player_name, "Quest revoked: " .. achievement_id)
    end
end

function is_achievement_unlocked(player_name, achievement_id)
    local player = minetest.get_player_by_name(player_name)
    if not player then
        return false
    end

    local meta = player:get_meta()
    if meta then
        return meta:get_string(achievement_id) == "true"
    else
        return false
    end
end

function is_quest_available(player_name, quest_id)
    local quest = getquestbyname(quest_id)
    if quest.requires == nil then return true end

    for i, questname in ipairs(quest.requires) do
        if is_achievement_unlocked(player_name, questname) == false then
            return false
        end
    end
    return true
end

-- Function to create the formspec
local function get_questbook_formspec(selected_quest_index, player_name)
    local selected_quest = quests[selected_quest_index]
    local quest_list = ""

    for i, quest in ipairs(quests) do
        if quest.type == "quest" then
            if is_achievement_unlocked(player_name, quest.title) then
                quest_list = quest_list .. "✓ " .. quest.title .. ","
            elseif is_quest_available(player_name, quest.title) then
                quest_list = quest_list .. "► " .. quest.title .. ","
            else
                quest_list = quest_list .. " ✕ " .. quest.title .. ","
            end
        elseif quest.type == "text" then
            quest_list = quest_list .. "≡ " .. quest.title .. ","
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) then
            quest_list = quest_list .. "✪ " .. quest.title .. ","
        elseif quest.type == "secret" and is_achievement_unlocked(player_name, quest.title) == false then
            quest_list = quest_list .. "✪ ???,"
        end
    end
    quest_list = quest_list:sub(1, -2)

    local formspec = "formspec_version[7]" ..
        "size[12,8]" ..
        "label[0.1,0.3;Quest List]" ..
        "textlist[0,0.7;5.8,7;quest_list;" .. quest_list .. ";" .. selected_quest_index .. "]"

    if selected_quest.type == "quest" or (selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title)) then
        formspec = formspec ..
            "hypertext[6,0.3;100,100;;\\<big\\>" .. minetest.formspec_escape(selected_quest.title) .. "]" ..
            "textarea[6,1.3;5.8,5;;;" ..
            (is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock.") ..
            "]" .. -- minetest.formspec_escape(selected_quest.text)
            "label[6,7.2;" ..
            (is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest.") ..
            "]"
    elseif selected_quest.type == "secret" and is_achievement_unlocked(player_name, selected_quest.title) == false then
        formspec = formspec ..
            "label[6,0.3;Secret Quest]" ..
            "label[6,0.7;Title: ???]" ..
            "textarea[6,1.2;5.8,5;;;" .. "???" .. "]" .. -- minetest.formspec_escape(selected_quest.text)
            "label[6,7.2;" ..
            (is_achievement_unlocked(player_name, selected_quest.title) and "✔️ You have completed this Quest." or "You have not completed this Quest.") ..
            "]"
    elseif selected_quest.type == "text" then
        formspec = formspec ..
            "textarea[6,0.3;5.8,5;;;" ..
            (is_quest_available(player_name, selected_quest.title) and minetest.formspec_escape(selected_quest.text) or "Complete " .. combineWithAnd(selected_quest.requires) .. " to unlock.") ..
            "]"
    end

    -- play page sound lol

    minetest.sound_play("questbook", {
        to_player = player_name,
        gain = 1.0,
    })

    return formspec
end

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "questbook:main" then
        if fields.quest_list then
            local event = minetest.explode_textlist_event(fields.quest_list)
            if event.type == "CHG" then
                local selected_quest_index = event.index
                local name = player:get_player_name()

                -- set selected quest index
                local meta = player:get_meta()
                if meta then
                    meta:set_int("selected_quest_index", selected_quest_index)
                end

                minetest.show_formspec(name, "questbook:main",
                    get_questbook_formspec(selected_quest_index, player:get_player_name()))
            end
        end
    end
end)


minetest.register_craftitem("sbz_progression:questbook", {
    description = "Quest Book",
    inventory_image = "questbook.png",
    stack_max = 1,
    on_use = function(itemstack, player, pointed_thing)
        local selected_quest_index = 1
        local meta = player:get_meta()
        if meta then
            selected_quest_index = meta:get_int("selected_quest_index")
        end
        if selected_quest_index == 0 then selected_quest_index = 1 end

        minetest.show_formspec(player:get_player_name(), "questbook:main",
            get_questbook_formspec(selected_quest_index, player:get_player_name()))
    end
})
