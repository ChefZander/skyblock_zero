return {
    { type = "text", title = "Questline: Completionist", text = "This is the Completionist Questline. Only for hardcore gaming enjoyers, good luck completing it." },
    {
        type = "quest",
        title = "Antineutronium",
        text = [[
Sometimes, meteorites whizzing by will be made of antimatter instead of regular matter. These meteorites have Antineutronium in their core.
Antineutronium can be crafted into a Gravitational Repulsor, which repulses meteorites.

TIP: Build a shield out of compressed core dust to protect against antimatter meteorites.]],
        requires = { "Meteorites" }
    },
    {
        type = "quest",
        title = "Angel's Wing",
        text =
        "The Angel's Wing can make you fly. Right-Click to use, it has 100 uses. To craft, surround a Emittrium Circuit with Stone. This recipe is temporary.",
        requires = { "Emittrium Circuits", "Concrete Plan" }
    },
    {
        type = "quest",
        title = "Node Preserver",
        text = [[
The node preserver preserves any node, for example:
When you use it on a storinator, it will preserve all items in that storinator.
Or on a luacontroller, it will preserve everything it had.
Or, with a filter injector, it will preserve... again... everything it had.

The node preservers be used on any nodes which have metadata, or inventories.
They can only dig nodes that the robotic arm can.
]],
        requires = { "Phlogiston Fuser" }
    },
    {
        type = "quest",
        title = "Small Protectors",
        text =
        [[
Small protectors protect a decently sized area.
Unwanted people won't be able to take items from machines or modify filter injectors or... like... do anything in your land... if the area is protected. Also this can't be placed anywhere near cores.

Special names ("owners") that you can add to protectors (no player can name themselvs these):
<b>.meteorite</b> - meteorites will now explode in your area
]],

        requires = { "Concrete Plan", "Furnace" }
    },
    {
        type = "quest",
        title = "Big Protectors",
        text = "Large protectors are like the small protectors but bigger.",
        requires = { "Small Protectors" }
    },

    -- [[ SECRETS ]]
    {
        type = "secret",
        title = "Emptiness",
        text = "Damn. You fell off."
    },
    {
        type = "secret",
        title = "Desolate",
        text = "You talked to yourself."
    },
    {
        type = "secret",
        title = "Fragile",
        text = "You broke an Angel's Wing."
    },
}
