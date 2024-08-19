quests = {
    { type = "text", title = "Questline: Introduction", text = "The first questline, to introduce you to the Game. Your adventure will start here." },

    {
        type = "quest",
        title = "Introduction",
        text = "Welcome, player. This is the Quest Book, " ..
            "here you can check out what tasks you have to do and the materials you will need for each quest. " ..
            "You can also just ignore the Quest Book if you are an experienced player. " ..
            "Now, to get started look down at the core. Punching it will give you your first resources. " ..
            "These Quests are in no particular order, but you might need items from one Quest for another. " ..
            "\nTIP: If you lose your Quest Book, you can use /qb to get it back.",
        requires = {}
    },

    {
        type = "quest",
        title = "A bigger platform",
        text = "Isn't this one node a little too crammed? " ..
            "Let's do something about that. " ..
            "Punch the Core a little more. With nine 'Matter Dust', you can craft yourself a 'Matter Blob'. " ..
            "Check the Quest Book again when you've done that.",
        requires = { "Introduction" }
    },


    {
        type = "quest",
        title = "Antimatter",
        text = "Unfortunately, you dont seem to be strong enough to destroy that node once you place it. " ..
            "That kind of sucks, so let's craft something that can. " ..
            "Craft some 'Antimatter Dust', we'll need it for later. " ..
            "It's made by mixing 'Matter Dust' and 'Core Dust'. Let's see you figure this out, smart one.",
        requires = { "Introduction" }
    },

    {
        type = "quest",
        title = "Annihilator",
        text = "Does it feel weird to be holding antimatter? " ..
            "Now, to craft a 'Matter Annihilator' you'll need a couple things: " ..
            "One 'Antimatter Dust', one 'Charged Particle' and three 'Matter Blob'. " ..
            "Make sure the 'Charged Particle' is properly enclosed in matter, or it'll escape.",
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Charged Field",
        text = "Now, then. We have one more thing to do before we can start automating. Can you guess what it is? " ..
            "That's right! We need power generation. " ..
            "Using nine 'Charged Particle', you can craft yourself a 'Simple Charged Field' " ..
            "But listen up! Charged Fields decay over time. Since you are using a 'Simple Charged Field', it should last you a couple of minutes of power generation. " ..
            "Yeah, it uses energy even when there's nothing connected to it. Since resources are infinite here, time is your resource. " ..
            "Anyways, I talked a lot, didn't I? Maybe too much. Let's get automating.",
        requires = { "Introduction" }
    },

    {
        type = "quest",
        title = "Automation",
        text = "Finally! Automation! Let's get on that, shall we? " ..
            "Here's what you'll need for a 'Simple Matter Extractor'. " ..
            "One 'Matter Annihilator', four 'Matter Blob' and four 'Core Dust' " ..
            "\nTIP: Machines without power occasionally emit red particles.",
        requires = { "Annihilator" }
    },

    {
        type = "quest",
        title = "Advanced Extractors",
        text = "That's a shiny new machine you've got there! " ..
            "Do you also want to increase production? Sure you do. " ..
            "For Advanced Extractors you'll obviously need a Simple Matter Extractor, " ..
            "then four 'Matter Annihilator' and four 'Matter Blob'. That's a lot of resouces, " ..
            "but this Extractor will also occasionally generate 'Core Dust'!",
        requires = { "Automation", "Power Pipes" }
    },

    {
        type = "quest",
        title = "Circuitry",
        text = "Circuits are important crafting components for future recipes. " ..
            "You'll need them for lots of recipes, and many of them too. " ..
            "Green Circuits are the most simple to craft, but there are diffrent circuit types which are used in diffrent recipes. " ..
            "All diffrent Circuit types use Green Circuits as their base. " ..
            "To craft a Simple Circuit, you'll need one 'Core Dust' and one 'Matter Blob'. " ..
            "You'll get two Simple Circuits from that craft.",
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Generators",
        text = "Right now, you're probably using 'Simple Charged Field' nodes to generate your Global Power, " ..
            "but since they decay, they dont last forever, which is not convenient. " ..
            "They also leave behind indestructible residue which can be very annoying. " ..
            "To solve that, you can use a generator, it consumes 'Core Dust' as fuel over time " ..
            "and provides you with more power than 'Simple Charged Field' nodes do. " ..
            "However, Generators are very expensive. Here is the list of materials required: " ..
            "Four 'Simple Charged Field', one 'Antimatter Dust', three 'Matter Blob' and one 'Matter Annihilator'.",
        requires = { "Charged Field", "Power Pipes" }
    },

    {
        type = "quest",
        title = "Matter Plates",
        text = "Matter Plates are often used for machinery. They are simple to craft, yet important." ..
            "You can get four 'Matter Plate' by placing one 'Matter Blob' into the crafting grid.",
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Retaining Circuits",
        text =
            "Retaining Circuits are a type of Circuit often used in nodes which Store items, either permanently or temporarily. " ..
            "Circuits depend on other circuits which is why you will need a Simple Circuit to craft this Circuit. " ..
            "The list of materials is as follows: one 'Simple Circuit', one 'Charged Particle' and one 'Antimatter Dust'. " ..
            "Unlike Simple Circuits, this will only craft one Retaining Circuit.",
        requires = { "Circuitry" }
    },

    {
        type = "quest",
        title = "Storinators",
        text = "Storinators are the solution to clogged up inventories. " ..
            "They have 30 Slots of Inventory, and function like a chest. " ..
            "The more red/green dots the front of a storinator displays, the more full/empty it is. " ..
            "You will need one 'Simple Charged Field', one 'Simple Circuit', four 'Matter Plate' and three 'Retaining Circuit' " ..
            "to craft one Storinator.",
        requires = { "Retaining Circuits" }
    },

    {
        type = "quest",
        title = "Pretty Pebbles",
        text =
            "We're making the jump from generic matter to stone now! Here is where building a space station gets fun! " ..
            "First, before we can make Stone nodes we will need Pebbles. They are quite difficult to make, requiring three " ..
            "'Matter Blob' in a shapeless craft. Pebbles will unlock a lot of decorational nodes to spice up your island, " ..
            "and if you want you can even start building your own planet. It's all up to your imagination!",
        requires = { "A bigger platform" }
    },

    {
        type = "quest",
        title = "Concrete Plan",
        text =
            "Just regular old boring stone, nothing really to add here. Like, it's literally just stone. You know, the kind that would make even a rock collector yawn and say, I've seen gravel with more personality. It sits around all day, doing nothing—no metamorphosis, no glittering crystals—just living its best sedentary life. " ..
            "That said, it's made using 9 pebbles. ",
        requires = { "Pretty Pebbles" }
    },

    -- ======================================================================================
    { type = "text", title = "Questline: Emittrium",    text = "Emittrium is a very important material when working with Cosmic Joules. This Questline will teach you all about it." },

    {
        type = "quest",
        title = "Obtain Emittrium",
        text =
            "Do you see those blue stars in the distance? They're called Emitters. To obtain Emittrium from them, you will have to build a bridge over to one. " ..
            "I would recommend to choose the closest one to you, but any Emitter works. Next, you'll need a Matter Annihilator. You can't destory the Emitters, but you can " ..
            "chip away at them. Punch your Emitter of choice until it yields some 'Raw Emittrium'. We'll refine the Emittrium later, but for now we just need it in it's raw state.",
        requires = { "Annihilator" }
    },

    { type = "quest", title = "Power Pipes",          text = "To transfer power from generators to machines, you'll need Power Pipes. You can get a power pipe with a shapeless craft using one Raw Emittrium and one Matter Plate. The Pipes will connect up and supply your machines with power, looking at your machine will show 'Running' if the machine is running.", requires = { "Obtain Emittrium" } },

    { type = "quest", title = "Switching Station",          text = "To build an actual functioning network, you'll need a switching station connected to your network to manage the flow of power.\nIMPORTANT: If you connect more than one Switching Station to a network, they will explode until there is only one left!", requires = { "Power Pipes" } },

    { type = "quest", title = "Starlight Collectors",          text = "Starlight Collectors turn the light of stars into power for you to use. But the stars are very faint, so you'll need a lot of these if you want to power a whole factory!", requires = { "Obtain Emittrium" } },

    {type = "quest", title = "Emittrium Circuits", text = "For almost all recipes related to storing or transferring Cosmic Joules you'll need Emittrium Circuits. They're a shapeless craft using Raw Emittrium, a Charged Particle, a Retaining Circuit and a Matter Plate.", requires = {"Obtain Emittrium", "Retaining Circuits"}},
    
    {type = "quest", title = "Batteries", text = "Sometimes, you'll need to temporarily buffer some energy. That's what the Battery is for. It stores up to 300 Cosmic Joules of energy. You can craft it by surrounding a Emittrium Circuit with Matter Blobs.", requires = {"Emittrium Circuits"}},



    -- ======================================================================================
    { type = "text",  title = "Questline: Decorator", text = "An island with just machines will look very boring! Use the knowledge from the Decorator Questline to spice up your island! These quests are not required for progression, but playing can get boring on an empty, barren islend. So dont just ignore this Questline, okay? :P" },

    {
        type = "quest",
        title = "Reinforced Matter",
        text = "Normal matter isnt sturdy enough? Try this one. This one won't break, unless you break it, then it breaks. Wait a minute...",
        requires = { "A bigger platform", "Matter Plates" }
    },

    {
        type = "quest",
        title = "Emitter Immitators",
        text = "Emitter Immitators are decorational nodes providing light. " ..
            "You can get one, by surrounding a 'Matter Blob' with 'Antimatter Dust'. It doesn't glow as much as The Core though. " ..
            "\nTIP: Emitter Immitators spawn a lot of particles when punched, try it!",
        requires = { "Antimatter" }
    },

    {
        type = "quest",
        title = "Photon Lamps",
        text = "Are Emitter Immitators too dim for you? Introducing: Photon Lamps! " ..
            "With this revolutionary technology you can light up your world.. uhm... the same way.. as with Emitter Immitators.. just brighter! " ..
            "As for getting one, well, we dont sell them yet so you're just going to have to make your own! " ..
            "Here goes: A matter blob in the center, four matter plates in the corners and then just fill the rest of the spaces with regular " ..
            "Emitter Immitators. Boom! You're done! Now you've got yourself a Photon Lamp! No more sitting in darkness! Yay!",
        requires = { "Emitter Immitators", "Matter Plates" }
    },

    -- ======================================================================================
    { type = "text",   title = "Questline: Completionist", text = "This is the Completionist Questline. Only for hardcore gaming enjoyers, good luck completing it." },

    { type = "quest",  title = "Angel's Wing",             text = "The Angel's Wing can make you fly. Right-Click to use, it has 100 Uses. To craft, surround a Emittrium Circuit with Stone. This recipe is temporary.", requires = { "Emittrium Circuits", "Concrete Plan" } },

    { type = "secret", title = "Emptiness",                text = "Damn. You fell off." },
    { type = "secret", title = "Desolate",                 text = "You talked to yourself." },
    { type = "secret", title = "Fragile",                  text = "You broke an Angel's Wing." },
}

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
