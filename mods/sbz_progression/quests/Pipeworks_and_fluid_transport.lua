return {
    {
        type = "text",
        title = "Questline: Pipeworks",
        text =
        [[If you already know about regular pipeworks, skyblock_zero's pipeworks are a very modified version of that mod, but it will be similar though.]]
    },
    {
        type = "quest",
        title = "Tubes",
        text = [[
    Have you ever wanted to automatically move items around without input?

    Now you can!

    Tubes are, well, tubes that can transport items around! Currently, you can't interact with them: but just have some lying around, the next and future quests utilize them.

    TIP: Items in tubes will go into directions with higher priority.]],
        requires = { "Furnace" },
    },
    {
        type = "quest",
        title = "Automatic Filter-Injectors",
        text = [[
    Have you ever been tired of taking items out of nodes? Do you just want to interact with tubes as soon as possible?

    Now you can!

    The Automatic Filter-Injector takes stacks of items from nodes, and places them into tubes or other nodes.
        
        The Automatic Filter-Injector has two settings:
            The slot sequence allows you to change the order that items are taken out.
                Priority: Takes items out in first out order
                Randomly: Takes items out in a random order
                Rotation: Takes items out in a round-robin order
            The match mode sets the behavior when taking out items:
                Exact match - off: If an item matches the filter, it takes out the whole stack
                Exact match - on: If an item matches the filter and the stack are higher it takes out the filter count, for example the filter is set to 5 matter, and it is pulling from a stack of 60 matter it will pull out 5 matter until the stack is below 5 or empty
                Threshold: If an item matches the filter and the stack are higher it takes out items until the stack matches the filter, so I have a filter of 5 matter and a stack of 60 it will pull 55 matter out of the stack.
    ]],
        requires = { "Bear Arms", "Tubes" }
    },
    {
        type = "text",
        info = true,
        title = "Matter Factory",
        text = [[
Using advanced matter extractors, some automatic filter injectors, tubes, and a storinator, you can make a really good matter factory.
Advanced matter extractors are crazy fast for their cost, so with like 6 of them, you will get lots of matter in no time.

Here is an example of one:
<img name=questbook_image_matter_factory.png width=483 height=453>
        ]],
        requires = { "Automatic Filter-Injectors", "Tubes" }
    },
    {
        type = "quest",
        title = "Node Breakers",
        text =
        "Node Breakers try to break the node in front of them. The drops are thrown away into the back-side. They need 20 power for each node dug. To make \"caveman automation\" (non lua automation) more powerful, plants that haven't finished growing cannot be dug by the node breaker.",
        requires = { "Automatic Filter-Injectors" }
    },
    {
        type = "quest",
        title = "Deployers",
        text = "Deployers try to place a node into their front-side. That's about it.",
        requires = { "Automatic Filter-Injectors", "Bear Arms" }
    },
    {
        type = "text",
        info = true,
        title = "Organics Automation",
        text = [[
I think you want to automate that annoying harvesting of your pyrograss... feeding the burner every day... very boring right!
Well no worries, node breakers and deployers make plant automation easy.

<img name=questbook_image_organics_factory.png width=348>
Side note: deployers can place 2 nodes ahead, that's a "feature" not a bug.
]]
    },
    {
        type = "quest",
        title = "Punchers",
        text =
        "Punchers punch stuff, allowing you to automate resource generation even more. But you need to give them something to punch with.",
        requires = { "Automatic Filter-Injectors", "Bear Arms", "Emittrium Circuits" }
    },
    {
        type = "quest",
        title = "Autocrafters",
        text =
        "Autocrafters automatically craft. You can make them craft as fast as possible, but they consume more power depending on the current crafts/s.",
        requires = { "Bear Arms", "Neutronium", "Emittrium Circuits", "Automatic Filter-Injectors" }
    },
    {
        type = "quest",
        title = "Item Voids",
        text = "Item voids delete every item that goes in, and yes these are pipeworks trashcans.",
        requires = { "Tubes" }
    },
    {
        type = "quest",
        title = "Item Vacuums",
        text = "Item Vacuums vacuum up items in a 16 block radius, but they tend to cause lag.",
        requires = { "Neutronium", "Tubes" }
    },
    {
        type = "quest",
        title = "Teleport Tubes",
        text =
        [[So, i think you want to transmit items in long distances, well teleport tubes help in that! They pretty much explain themselvs, soo, good luck!

Oh wait, one thing to mention: The items will fall off the receiving tube if you don't use a high priority tube next to it.]],
        requires = { "Tubes", "Crystal Grower" }
    },
    {
        type = "quest",
        title = "Automatic Turrets",
        text =
        "Do you want to automatically shoot down meteorites, or even shoot down players? The automatic turret will help in that. It is similar to the node breaker, but does not dig nodes. Equip it with a laser to get started.",
        requires = { "Node Breakers", "Neutronium" }
    },
    -- ==================================================================================================

    { type = "text",  title = "Questline: Fluid Transport", text = "This questline is all about transporting fluids." },
    { type = "quest", title = "Fluid Pipes",                text = "A fluid pipe is like a tube, but with fluids. They move fluids around, just like how tubes move items around.",                requires = { "Tubes" } },
    { type = "quest", title = "Fluid Pumps",                text = "Fluid Pumps are automatic filter-injectors, but for pipes. They take fluids from fluid inventories.",                          requires = { "Automatic Filter-Injectors" } },
    { type = "quest", title = "Fluid Storage Tanks",        text = "Fluid Storage Tanks are storinators for fluids. They can store 100 nodes of fluid. That's a lot!",                             requires = { "Tubes", "Storinators" } },
    { type = "quest", title = "Fluid Capturers",            text = "Fluid Capturers capture liquid SOURCES from their top and store them. You can take out the captured fluid with a fluid pump.", requires = { "Fluid Storage Tanks" } },
    { type = "quest", title = "Fluid Cell Fillers",         text = "Fluid Cell Fillers fill empty fluid cells in their inventories.",                                                              requires = { "Fluid Storage Tanks" } },
}
