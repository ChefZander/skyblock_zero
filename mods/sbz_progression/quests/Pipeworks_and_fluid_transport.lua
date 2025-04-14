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

    TIP: Items in tubes will go into directions with higher tube priority. The default tube priority is 100.]],
        requires = { "Furnace" },
    },
    {
        type = "quest",
        title = "Automatic Filter-Injectors",
        text = [[
Have you ever been tired of taking items out of nodes? Do you just want to interact with tubes as soon as possible?
Now you can!
The Automatic Filter-Injector takes stacks of items from nodes, and places them into tubes or other nodes.

<big>The Automatic Filter-Injector has two settings:</big>
<b>The slot sequence (allows you to change the order that items are taken out):</b>
Priority: Takes items out in first out order
Randomly: Takes items out in a random order
Rotation: Takes items out in a round-robin order
<b>The match mode (sets the behavior when taking out items):</b>
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
Advanced matter extractors are crazy fast for their cost, so with like 5 of them, you will get lots of matter in no time.

Here is an example of one:
<img name=questbook_image_matter_factory.png width=483 height=453>
        ]],
        requires = { "Automatic Filter-Injectors", "Tubes" }
    },
    {
        type = "quest",
        title = "Node Breakers",
        text =
        "Node Breakers try to break the node in front of them. The drops are thrown away into the back-side. They need 20 power for each node dug. To make \"caveman automation\" (non lua automation) more powerful, plants that haven't finished growing cannot be dug by the node breaker. If you insert in a tool that requires power (for example laser), the node breaker will try to charge it, consuming more power.",
        requires = { "Automatic Filter-Injectors" }
    },
    {
        type = "quest",
        title = "Deployers",
        text = "Deployers try to place a node into their front-side. That's about it.",
        requires = { "Automatic Filter-Injectors", "Bear Arms" }
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
        text =
        "Item voids delete every item that goes in, and yes these are pipeworks trash cans. But unlike pipeworks trash cans, they show the amount of items they've destroyed.\nThat number can \"overflow\" into the negatives, if you actually manage to do this, don't consider it a bug, but consider it an achievement :)",
        requires = { "Tubes" }
    },
    {
        type = "text",
        info = true,
        title = "Overflow Handling",
        requires = { "Item Voids" },
        text = [[
Tubes break when they have too many stacks in them. This may not appear as a problem at first, but when you think about it - it can be a huge issue.
<b>If we have this setup:</b>
<img name=questbook_image_basic_setup.png>
Then, there might be an issue with it if the storinator that we are putting items to is completely filled.
In cases where there is only one tube, the item will simply drop, but when there are at least 2 tubes, the items will wonder around, until eventually there will be too many of them. In that case, the tubes will break.

How do we prevent our tubes breaking, or items dropping?
Well... a simple answer would be to have more storinators :D... but that's not practical

<b>Instead, consider using item voids like this:</b>
<img name=questbook_image_overflow_handling.png>
Item voids have the lowest priority, so items really don't want to go there.
Storinator, has a higher priority than the item void, so if the storinator isn't full, items will go there.
Item voids, have a lower priority, so if the item can't go to the storinator, it will go into the item void.

The default priority is 100.
]]
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
        title = "One Direction Tubes",
        text = [[
This is a tube that accepts items from all directions, but allows them to only go in one direction.
If you hover over it, it will spawn a white particle, the direction of the white particle, is the direction that the items will go in.

To change that direction, sneak and punch it on the side that you want the items to go in.
]],
        requires = { "Tubes" }
    },
    {
        type = "quest",
        title = "Automatic Turrets",
        text =
        "Do you want to automatically shoot down meteorites, or even shoot down players? The automatic turret will help in that. It is similar to the node breaker, but does not dig nodes. Equip it with a laser to get started. But be warned, near spawn, the turret's range gets decreased by 80%. If you insert in a tool that requires power, for example lasers, it will try to charge the laser, resulting in more power use.",
        requires = { "Node Breakers", "Neutronium" }
    },
    {
        type = "quest",
        title = "Instatubes",
        text = [[
Instatubes are tubes that are instant. They are generally less laggy than their regular pipeworks tube counterparts.

Instatubes work a bit differently than regular tubes.
They internally create a list of all the receivers, then they will sort the receivers based on priority, and the receivers with largest priority will be given the items first, if they are full, it will move on with the receiver with lower priority.
This is different to regular pipeworks tubes... in a way... that's hard to explain, so a visual example would be best:
<img name=questbook_image_instatubes_vs_pipeworks_tubes.png>
Suppose that the green storinators had a priority of 99. (they don't, but it will make explaining this easier) That is higher than regular pipeworks tubes, but lower than regular storinators.
In that case, with the default pipeworks tubes, the items will flow first to the green storinator, then once it's full, it will flow to the regular storinator.
Instatubes work a bit differently, they will choose the storinator with the highest priority, then to the lowest. So items would flow first into the regular storinator, once that's full, it will flow to the green storinator.

Overflow handling: simply put up an item void connected to the instatubes (might need to connect it to a few low priority tubes if you use those anywhere, as it has only a priority of one, and you can go below that)

Now... some things are just impossible with the basic instatube, so there are more types of instatubes :D, this will cover them

<big>Priority Instatubes</big>
(Low priority instatubes, high priority instatubes)

They change the priority of all the
        ]],
    },
    -- ==================================================================================================

    { type = "text",  title = "Questline: Fluid Transport", text = "This questline is all about transporting fluids." },
    { type = "quest", title = "Fluid Pipes",                text = "A fluid pipe is like a tube, but with fluids. They move fluids around, just like how tubes move items around.",                requires = { "Tubes" } },
    { type = "quest", title = "Fluid Pumps",                text = "Fluid Pumps are automatic filter-injectors, but for pipes. They take fluids from fluid inventories.",                          requires = { "Automatic Filter-Injectors" } },
    { type = "quest", title = "Fluid Storage Tanks",        text = "Fluid Storage Tanks are storinators for fluids. They can store 100 nodes of fluid. That's a lot!",                             requires = { "Tubes", "Storinators" } },
    { type = "quest", title = "Fluid Capturers",            text = "Fluid Capturers capture liquid SOURCES from their top and store them. You can take out the captured fluid with a fluid pump.", requires = { "Fluid Storage Tanks" } },
    { type = "quest", title = "Fluid Cell Fillers",         text = "Fluid Cell Fillers fill empty fluid cells in their inventories.",                                                              requires = { "Fluid Storage Tanks" } },
}
