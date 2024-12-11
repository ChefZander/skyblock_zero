return {
    {
        type = "text",
        title = "Questline: Storage",
        text = [[
So... i assume you need some sort of storage... to store items.... Well don't worry, Skyblock Zero provides multiple ways to do that.
        ]]
    },
    {
        type = "quest",
        title = "Storinators",
        text = [[
Storinators are the solution to clogged up inventories. They have 32 slots of inventory, and function like a chest.
The more red/green dots the front of a storinator displays, the more full/empty it is.
]],
        requires = { "Matter Plates", "Charged Field", "Retaining Circuits" }
    },

    {
        type = "quest",
        title = "Better Storinators",
        text = [[
Soo... i don't think the storinator's 32 slots is enough for you, is it?
Well don't worry.. you can craft more storinators.... OR you can upgrade them :>
Each upgrade adds 1 row and 1 collumn to the inventory space.

To complete this quest, you need to craft the bronze storinator.
        ]],
        requires = { "Storinators", "Bronze Age" }
    },
    {
        type = "quest",
        title = "Public Storinators",
        text =
        "Public storinators are like regular storinators but accessible to ANYONE, regardless of protections. You can craft them by just putting any type of storinator in your crafting guide.",
        requires = { "Storinators" }
    },
    {
        type = "quest",
        title = "Best Storinators",
        text = [[
Do you have chaos in your storinators, are you struggling to figure out which one is which.... Do you need labels, but signs get in the way?
Well, you can use neutronium storinators, they are a little expensive, requiring 4 neutronium, but if you can afford them, they are great for this.
]],
        requires = { "Better Storinators", "Neutronium" }
    },
    {
        type = "quest",
        title = "Drawers",
        text = [[
Do you have some some sort of automation set-up, that produces LARGE amounts of 1 type of item?
Or do you just have a large amount of some junk, but you don't want to throw it away for some reason?

Well... introducing DRAWERS, they are like storinators... but only store 1 type of item... and don't store tools...
But yeah they are really good at that...
They store 3200 of 1 type of item (without upgrades).

Drawers also come with 1x2 and 4x4 variants.
]],
        requires = { "Storinators" }
    },
    {
        type = "quest",
        title = "Drawer Upgrades",
        text = [[
Soo... i'm guessing that one drawer just won't meet all of your needs... well...
You can upgrade it! By clicking on the sides of the drawer, or the edges (if you are only facing the front fase) you can see an inventory, in which you put the upgrades...

The upgrades don't work as you expect them to, if you have 2 bronze upgrades, each bronze upgrade adds an extra 3200 items, it doesn't multiply 3200 by 4
        ]],
        requires = { "Drawers", "Bronze Age" }
    },
    {
        type = "quest",
        title = "Drawer Controller",
        text = [[
I think you have noticed that drawers still may not work so amazingly for automation, the drawer controller is here to solve that.
If you send it an item with a tube, or manually provide it an item, it will automatically put it in one of the drawers near it.

For taking out items, you can use a luacontroller, sending an itemstack (a string like "sbz_bio:dirt 100"), and it will try to give you that dirt by injecting it out of itself.
]],
        requires = { "Drawers" }
    }
}
