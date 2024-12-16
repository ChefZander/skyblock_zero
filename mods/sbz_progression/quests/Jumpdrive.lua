return {
    {
        type = "text",
        title = "Questline: Jumpdrive",
        text = [[
A modified version of the mt-mods/jumpdrive mod, lets you teleport yourself, and your buildings, anywhere*.
    ]]
    },
    {
        type = "quest",
        title = "Jumpdrive Backbone",
        text = [[
An ingredient in making the jumpdrive engine.
Also used in connecting jumpdrives to a fleet controller.
        ]],
        requires = { "Compressor", "Reactor Shells" }
    },
    {
        type = "quest",
        title = "Warp Device",
        text = [[
An ingredient in making the jumpdrive engine. May be required for other things in the future.
        ]],
        requires = { "Crystal Grower", "Antimatter Generator" },
    },
    {
        type = "quest",
        title = "The Jumpdrive (engine)",
        text = [[
Lets you teleport your buildings with you, to any* coordinate....

*Though in skyblock zero, this has been slightly modified: Without a jumpdrive station near the target, you can only travel 120 blocks away from your current position... But if you have a jumpdrive station, near (200~ish blocks away) your target position, you can teleport there.

The jumpdrive also acts as a battery, storing 200 kCj, this also means it can be discharged, be aware of that.

If you punch the jumpdrive with an empty hand, you will see an outline of what nodes it will teleport.

You can transport emitters with the jumpdrive.
Also, emitters stop spawning after y=1000, so you can transport stuff more easily there, since no emitters will intefere with you.
        ]],
        requires = { "Jumpdrive Backbone", "Warp Device", "Very Advanced Batteries" },
    },
    {
        type = "quest",
        title = "Jumpdrive Stations",
        text = [[
Soo i imagine you'd like to travel huge distances with the jumpdrive, well.... this will allow you to do that

Simply place one down in your target destination. Now you can teleport to it with the jumpdrive.
        ]],
        requires = { "The Jumpdrive (engine)" },
    },
    {
        type = "quest",
        title = "Jumpdrive Fleet Controller",
        text = [[
So... i imagine you want to move multiple jumpdrives at once... well you are lucky, this is the node for you!
Connect up all the jumpdrives with jumpdrive backbones, connect that to the fleet controller, and now you can use it!

Warning: Make sure to ALWAYS press "show" before jump... you don't want one of your jumpdrives stuck...
        ]],
        requires = { "Jumpdrive Backbone" }
    }
}
