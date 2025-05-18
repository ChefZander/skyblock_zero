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
        title = "Small Protectors",
        text =
        [[
Small protectors protect a decently sized area.
Unwanted people won't be able to take items from machines or modify filter injectors or... like... do anything in your land... if the area is protected. Also this can't be placed anywhere near cores.

Special names ("owners") that you can add to protectors (no player can name themselvs these):
<b>.meteorite</b> - meteorites will now explode in your area
<b>.strange_blob_spread</b> - strange blobs will spread in your area
]],

        requires = { "Concrete Plan", "Furnace" }
    },
    {
        type = "quest",
        title = "Big Protectors",
        text = "Large protectors are like the small protectors but bigger.",
        requires = { "Small Protectors" }
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
        title = "Copy Tool",
        text = [[
(Copy Tool is a tool made with the metatool library - it also combines the luatool and tubetool from the metatool modpack).

The copy tool is used to copy settings between nodes.

aux1+left mouse button => Load the configuration of the node you are pointing at, into the tool
left mouse button => Paste the configuration from the tool into the node you are pointing at, the configuration stays in the tool
Putting into crafting grid => resets the configuration of the copy tool
aux1+sneak+left mouse button => Depending on the node you've pointed at, this may open a special menu, or do the same thing as if you weren't sneaking

Currently supported nodes:
- autocrafter
- filter injector
- item sorter
- luacontroller
- teleport tube - brings up a special menu
- luacontroller - copies editor code, main code, memory, formspec, and links, processes the links so that they are moved with the luacontroller

P.S. if you find anything that you'd like to be compatible with the copytool, don't be afraid to make a suggestion
        ]],
        requires = { "Tubes" }
    },
    {
        type = "quest",
        title = "Bulk Placer Tool",
        text = [[
The tool is from the "replacer" mod (specifically, SwissalpS's fork), originally called "Node replacement tool (technic)", but the name was changed in skyblock zero as that was a bit innacurate (there is no technic here, and it can place nodes too).

Sneak+right click => "Select" the node (this will be used later to decide what node to (re)place with)
Aux1+left click => Brings up a form where you can chose how the bulk placer tool will behave. Nodes that aren't rendered as a square, or are like/rendered like glass are treated as air.
Aux1+right click => Cycles through the modes without bringing up a form
Aux1+sneak+right click => Cycles between changing nodes, rotation or both
Right click => places the node, according to the mode
Left click => Replaces the node, according to the mode

It might behave weirdly with super powered lamps, be aware of that.
]]
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
    {
        type = "sercet",
        title = "AntiColorium Planets",
        text = [[
Nice green terrain and oceans of antiwater
        ]] -- is it really antiwater?
    }
}
