return {
    { type = "text",  title = "Questline: Emittrium", text = "Emittrium is a very important material when working with Cosmic Joules. This questline will teach you all about it." },

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

    {
        type = "quest",
        title = "Power Cables",
        text = [[
To transfer power from generators to machines, you'll need Power Cables. You can get a power cable with a shapeless craft using one Raw Emittrium and one Matter Plate.
The cables will connect up and supply your machines with power, looking at your machine will show 'Running' if the machine is running.
Also, if you put a machine next to another machine, it will conduct power to that machine, so you only need power cables in very specific cases (like automation).]],
        requires = { "Matter Plates", "Obtain Emittrium" }
    },

    { type = "quest", title = "Starlight Collectors", text = "Starlight Collectors turn the light of stars into power for you to use. But the stars are very faint, so you'll need a lot of these if you want to power a whole factory!",                                                                                                                     requires = { "Obtain Emittrium" } },

    { type = "quest", title = "Emittrium Circuits",   text = "For almost all recipes related to storing or transferring Cosmic Joules (power), you'll need Emittrium Circuits. They're a shapeless craft using Raw Emittrium, a Charged Particle, a Retaining Circuit and a matter plate.",                                                                   requires = { "Matter Plates", "Obtain Emittrium", "Retaining Circuits" } },

    { type = "quest", title = "Batteries",            text = "Sometimes, you'll need to temporarily buffer some energy. That's what the Battery is for. It stores up to 1 CJh (Cosmic Joule Hour) of energy. You can craft it by surrounding a Emittrium Circuit with matter blobs.",                                                                         requires = { "Emittrium Circuits" } },

    { type = "quest", title = "Connectors",           text = "If you want to turn machines on and off, you can use Connectors. They join two networks together, and you can click on them to turn them on and off.\nIMPORTANT: Make sure that only one of the two or more joined networks has a switching station, or they will blow up until reaching one.", requires = { "Emittrium Circuits", "Reinforced Matter" } },

    --{ type = "quest", title = "Infinite Storinators", text = "Infinite Storinators are like normal Storinators, except you can store way more items in them. They have customizable storage size and consume 1 power per row of items. The limit of slots on an Infinite Storinator is 5000, that's 4970 more than a normal Storinator!", requires = { "Emittrium Circuits", "Storinators", "Meteorites" } },
    { type = "quest", title = "Ele Fabs",             text = "Used to manifacture various components, especially for logic.",                                                                                                                                                                                                                                 requires = { "Antimatter", "Emittrium Circuits" } },
    { type = "quest", title = "Knowledge Stations",   text = "Teaches you about logic, which is not documented in this questbook but instead in the knowledge station. Good luck.",                                                                                                                                                                           requires = { "Concrete Plan", "Ele Fabs" } },

}
