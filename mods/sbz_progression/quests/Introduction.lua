return {
    { type = "text", title = "Questline: Introduction", text = "The first questline, to introduce you to the game. Your adventure will start here." },
    {
        type = "text",
        title = "General Info",
        info = true,
        text = [[
By holding aux1 (usually "e"), you can sprint.

You have 20 health points, you re-gain them usually eating food.
If you die, your inventory stays with you, meaning there is no reason to worry about dying.

There are several in-game commands useful in survival:
- /bgm_volume <percentage> - sets the background music's volume
- commands of the areas mod - protecting using areas using /protect has been disabled, but you can still do other things
- /drawers_fix - if drawers appear broken just run that, command was taken from pandorabox_custom
- /afk - marks you as afk
- /core - teleports you to the core
- /playtime - shows your, or other player's playtime
- /qb - gives you the questbook if you don't have one
- /home - teleports you to home
- /sethome - sets your home
- /toggle_areas_hud - Toggles the areas hud, may be useful if you dont want to always see it.
- /theme_gui - opens the theming gui, here you can customize the theme

<b>Recomended for small screens</b>
in /theme_gui, you can disable "Force mono font", this will make the font less cool but it will make it smaller.
]]
    },
    {
        type = "quest",
        title = "Introduction",
        text =
        [[Welcome, player. This is the Quest Book. Here, you can check out what tasks you have to do, and the materials you will need for each quest.
		
You can also just ignore the Quest Book if you are an experienced player.
			
Now, to get started: look down at the core. Punching it will give you some of your first resources.
You can also just right-click the core, it will be easier on you.

These quests are in no particular order, but you might need items from one quest for another.
The Introduction questline is designed to get you started into a couple other questlines, so it is recommended you jump between questlines occasionally.

If you need to know a recipe, search the item in the inventory, and click on it, it will bring up what it can be used for or how it can be crafted.

TIP: If you lose your Quest Book, you can use /qb to get it back.]],
        requires = {}
    },

    {
        type = "quest",
        title = "A bigger platform",
        text = [[Isn't this one node a little too crammed? Let's do something about that.

Punch the Core a little more. With nine 'Matter Dust', you can craft yourself a 'Matter Blob'.
If you are unable to place a matter blob next to the core, try sneaking while placing it. On multiplayer servers the area around the core may be protected.
]],
        requires = { "Introduction" }
    },


    {
        type = "quest",
        title = "Antimatter",
        text =
        [[Unfortunately, you don't seem to be strong enough to destroy that node once you place it (Assuming you placed it already). That kind of sucks, so let's craft something that can. Craft some 'Antimatter Dust', we'll need it for later.\nDon't know how to craft it? The search bar in your inventory will help.]],
        requires = { "Introduction" }
    },

    {
        type = "quest",
        title = "Annihilator",
        text =
        [[Doesn't it feel weird to be holding antimatter? To break nodes you'll need a <b>Matter</b> Annihilator, you should craft it up now since it's used in some other crafts down the line.
        TIP: Half-broken Annihilators can also be used to craft with.
        Also, don't craft the <b>Anti</b>matter annihilator, you won't need it yet.]],
        requires = { "A bigger platform", "Antimatter" }
    },
    {
        type = "text",
        info = true,
        title = "Bridging out",
        text = [[
Emitters are these blue nodes scattered around the core, be careful not to confuse them with the very similar looking skybox.
You will need an annihilator to extract resources from them, they will behave exactly the same as a core, but they will sometimes give you emittrium.
You can craft matter platforms to have a cheaper way of bridging out.
]],
        requires = { "Annihilator" }
    },
    {
        type = "quest",
        title = "Charged Field",
        text =
        "Now, then. We have one more thing to do before we can start automating. Can you guess what it is? \nThat's right! We need power generation. \n\nTo get going, craft yourself a Simple Charged Field.\nBut listen up! Charged Fields decay over time, leaving indestructible residue (that decays in a relatively short time) behind. Since you are using a Simple Charged Field, you should expect to have energy for about 10 minutes. \nGenerators use energy even when there's nothing connected to them. Since resources are infinite here, time is your resource. Let's get automating.",
        requires = { "Introduction" }
    },

    {
        type = "quest",
        title = "Matter Plates",
        text = [[Matter Plates are often used for machinery. They are simple to craft, yet very important.

You can get four Matter Plates by placing one matter blob into the crafting grid.]],
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Switching Station",
        text =
        [[The Switching Station is an important node, because it is the heart of any Power Grid. You have to have exactly one per Power Grid, if you don't have one nothing will work, and if you have more than one, they will explode until there is only one in the power grid. The Switching Station also displays statistics about the Power Grid when hovered over in-world. When a machine says "no network found", it's not connected to the switching station and won't do anything.]],
        requires = { "Matter Plates" }
    },
    {
        type = "text",
        info = true,
        title = "What conducts power?",
        text = [[
Unlike most power systems, in Skyblock: Zero's power system, almost all machines conducts power to other machines.
Wires are useful when you have 2 far apart factories that you want to connect, for aesthetics, or for organization.
The power unit Cosmic Joules is abbreviated to Cj in most interfaces.
]]
    },

    {
        type = "quest",
        title = "Automation",
        text = [[Finally! Automation! Let's get on that, shall we? Here's what you'll need for a Simple Matter Extractor:

One Matter Annihilator, four matter blobs and four bits of core dust.
Also, you may need to click 2 times for the UI to show up.

TIP: Early game machines without power occasionally emit red particles.]],
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

To solve that, you can use a simple charge generator. It consumes core dust as fuel over time, and provides you with more power than simple charged fields do.

However, Generators are expensive. They require 4 simple charged fields, an antimatter dust, 3 matter blobs and 1 Matter Annihilator to craft.

]],
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
}
