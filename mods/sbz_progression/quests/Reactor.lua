return {
    {
        type = "text",
        title = "Questline: Emittrium Reactor",
        text = [[
Emittrium reactors are another way of generating energy. They are a 3x3x3 cube made of reactor shells (or reactor glass), with a reactor core in the center. The shells can be replaced with a reactor power port, a reactor coolant port, a reactor emittrium port and a reactor infoscreen. It consumes emittrium and water, and generates 800 power.
If it doesn't have enough coolant (water), it heats up, and bad things happen if it heats up too much.]]
    },
    {
        type = "quest",
        title = "Reactor Shells",
        text =
        "Reactor Shells are needed in crafting the emittrium reactor parts, and construction of the emittrium reactor.",
        requires = { "Obtain Emittrium" }
    },
    {
        type = "quest",
        title = "Reactor Glass",
        text =
        "Reactor Glass is needed in crafting recipes, and optionally can be used as a replacement for the reactor shell in the construction of the emittrium reactor.",
        requires = { "Emittrium Glass", "Reactor Shells" }
    },
    {
        type = "quest",
        title = "Reactor Infoscreens",
        text =
        "A Reactor Infoscreen is needed in the construction of the emittrium reactor, and are needed to turn on the reactor.",
        requires = { "Reactor Glass" }
    },
    {
        type = "quest",
        title = "Reactor Power Ports",
        text =
        "A Reactor Power Port is needed in the construction of the emittrium reactor. They deliver the energy generated by the reactor core.",
        requires = { "Reactor Shells" }
    },
    {
        type = "quest",
        title = "Reactor Coolant Ports",
        text =
        "A Reactor Coolant Port is needed in the construction of the emittrium reactor. They need 1 water bucket/s (delivered in pipes) to sustain reactor heat.",
        requires = { "Fluid Storage Tanks" }
    },
    {
        type = "quest",
        title = "Reactor Emittrium Input",
        text =
        "A Reactor Emittrium Input is needed in the construction of the emittrium reactor. They need 16 emittrium/minute to fuel the reactor.",
        requires = { "Reactor Shells", "Tubes" }
    },
    {
        type = "quest",
        title = "Reactor Core",
        text = "A Reactor Core is needed in the construction of the emittrium reactor. Needs to be in the center.",
        requires = { "Neutronium", "Reactor Shells" }
    },
    {
        type = "quest",
        title = "Building the emittrium reactor and turning it on",
        text =
        "Build a 3x3 cube of reactor shells or reactor glass, in the center, place the core, but in place of some of these shells, build the extra blocks mentioned earlier (Emittrium input, coolant port, power port, etc.)\n\nNow, to actually turn the reactor on, click the infoscreen, then turn it on in the UI. If you have something wrong in the reactor, it will tell you.\n\nIf you have multiple reactors, try pressing the re-link button if you think the infoscreen is displaying the wrong information",
        requires = { "Reactor Shells", "Reactor Infoscreens", "Reactor Power Ports", "Reactor Coolant Ports", "Reactor Emittrium Input", "Reactor Core" }
    },
}