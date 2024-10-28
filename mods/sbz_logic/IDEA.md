# Ok, this is me, frog, before you read this document
This was written a long time ago
You can see my ideas in here, some did not make it

# This is me (frog) writing down ideas for the logic


Let's split this into 2 parts...

1) Lua (and the editor)
2) Machine logic (and the ability to interract with the world, for that lua part...)

Keep in mind that almost all code i show is meant to be run in the *sandbox*, not mod code

# Definitions

lua sandbox = something that executes lua code from the user, with limits as to what it can access (easily done with `setfenv` - 100% secure), and limits on execution time (debug hooks with time limits work well enough, they arent ideal though, but i dont know any single way to overwhelm them)

"normal" sandbox/non yieldable sandbox/ anything but the coroutine sandbox = sandbox that just executes the code once, not allowing it to pause

coroutine/yieldable sandbox = sandbox that allows the user's code to *pause*, or to *wait for* an event, or to *wait a certain amount of seconds*, basically offers `coroutine.yield()`

# The Lua!!! part

Soo uh it would be a coroutine sandbox with libox, that's for certain

I'm thinking a good idea would be to add files and libraries, libraries of course as items... idk.... magnetic disks?

The editor should be customizable... as in... a custom formspec

There should be a magnetic disk with like the "default" editor

3 types of disks:

1) data disk - `return { ["x"] = "whatever" }`
2) (user) code disk - `print("LUA!!!")` (executes immiadedly upon insertion)
3) system code disks (sysdisks) - privledged code, immutable, craftable, basically code that comes from this mod, and is not written by the user

now about the editor... mmm

so do i just... ok i let the player set the formspec and `on_receive_fields` of the editor

then i just add a basic editor user disk, that just does that, immiadedly, and i let players create their own more advanced editors (with like files n stuff)

so at first, the lua thing will have a formspec telling you to insert a basic editor disk

now... how should it work... like more specifically

ok so, yeah, a coroutine sandbox...

should it be able to do async jobs? YES... though the environment of the async job would be limited and you can only pass basic types thru, also only have like... idk... x of them at once?... also obviously async jobs wouldn't be able to yield or anything like that

Now... what if it wants to align itself with a tick or a subtick?

well...

```lua
-- well.. it could be like this...
function on_subtick(supply, demand)
    -- gets called as _G.on_subtick(supply, demand) 
    -- as a non-yieldable sandbox
end

function on_tick(supply, demand)
    -- same here... called as _G.on_tick(supply, demand)
    -- as a seperate non yieldable sandbox
end
-- they will share the same environment and everything, just not be able to `yield`
```

same could be with....

```lua
    function on_receive_fields(fields, sender)
        -- blabla
        -- nonyieldable sandbox you get it
    end
```

the non-yieldable/non-coroutine sandbox is there because its like really simple....

there is ANOTHER WAY TO DO THIS though...

```lua
    while true do
        local event = coroutine.yield()
        if event.type == "tick" then
            -- blabla
        end
    end
```

and yknow... i think its better? idk honestly
i mean one could just as easily do...

```lua

    local function on_receive_fields(fields, sender)
        -- blabla
    end
    repeat
        local event = coroutine.yield()
        if event.type=="gui" then
            on_receive_fields(fields, sender)
        end
    until the_end_of_time

```
and it would be BETTER, because one can yield in that
so yeah....

but how will async jobs be handled? well uhh here we will have to....

```lua
    some_constant_located_in_global_environment_for_no_reason = 3.1416
    for i=1,10 do
        local JOB_ID = i
        do_async(JOB_ID, function(job_id, env)
            return job_id + math.random() - env.some_constant_located_in_global_environment_for_no_reason
        end, JOB_ID, _G) -- you can just pass in _G lol
    end

    while true do
        local event = coroutine.yield()
        if event.type == "async" then
            print("JOB ID: "..event.job_id)
            if event.error then
                print("ERROR: "..event.error)
            else
                print("RESULT: "..event.result) -- obviously stripped of all functions and everything
            end
        end
    end
```

What if there are more async jobs than the limit we just proposed earlier?

Uhhh.... idk... we put em in a queue, if the queue is too large we throw up and end the sandbox

ok i think that works well.... mmm... what about the editor configuring in the sandbox

ok... this makes me think i will actually need a `on_receive_fields` function that is independant from the coroutine sandbox

because say the code just errored... you need some way of like... yknow... displaying that it just errored? and to like keep working regardless of how badly the coroutine sandbox screws up

but the coroutine sandbox could still access like whats going on in the fields and like yeah modify the formspec (like with a `gui` event)

so think of it like this

X - dead
Y - revived 
T - tick
F - received fields/user does something in gui, results in a tick for both

coroutine sandbox          ----T---------F---F->X   Y---------T--->
on_receive_fields function --------------F---F------F--------------

that revival wouldn't have been possible if the fields handling *depended* on the coroutine sandbox to work... ok is this too confusing lol


now is that it....

yeah? i mean... what else?

OHH HYEAH THE *LIMITING*

<details>
    <summary>open if you dont know what debug hooks are</summary>
    ok so, debug hooks basically uhh... let me just show you

    ```lua
    debug.sethook(function()
        debug.sethook() -- clear the hook
        error("Too many events")
    end, "", 20) -- every 20 instructions, consistant
    for i=1,5 do
        print("HI: "..i )
    end

    --> HI: 1
    --> HI: 2
    --> error: Too many events
    ```
    the above is a really really simplified example of how mesecons luacontrollers limit your code, it is always consistant and you can *kinda* know where and when your code will fail

    but this is problematic because some instructions and C functions take different amounts of time...

    string concatinating 2 gigantic strings will take *possibly seconds*, yet debug hooks count them as like what... 4 instructions?, something really long

    so instead this mod will limit based off of time, it's not consistant but  way better than having a 4 year old public issue about it... *cough* mesecons *cough*

    
</details>

so... what if, we had like a 5ms limit per event (2ms for on_receive_fields, so that it doesn't go all at once)... but also a 100ms/second limit, and the closer you get to that 100ms/s limit, the more you will have to pay in power consumbtion, if you don't provide it with enough power, or 100ms/s limit is reached, luac will deactivate, idk if the power consumbtion should be exponential or linear

i think thats fair, as for async jobs... idk?

3 threads running at once, 50 jobs queued, 120ms/s (keep in mind async, if you run some 8 core machine, thats basically nothing contributing to the main lag) and 80% lower bill?


# The world interfacing part
honestly this should be made later after i make the lua part but heres a generic idea of what i want

- NOT wires
- NOT techpack's ultra hard to remember and iterate over numbers
- a unified system... like... yeah.... ***not*** like techpack (whatever the hell it has...)

something like mindustry's logic processors being able to link to machines

ok so... what if there was like a linking tool, which could like link machines or just... positions... to a lua thing (i still haven't given it a name i think), and you *unlike mindustry* can choose the name of those links

and you could also just manually use relative positions to control blocks

and also maybe like groups under the same name? 

```lua
local relative_position = get_link("infinite_storinator")
local inf_storinator = relative_position
local list_of_relative_positions = get_link("furnaces")
local furnaces = list_of_relative_positions

send_to(inf_storinator, 30) -- have 30 slots

local items = pull_from(furnaces, "src") -- ill explain later
```

yeah like that

### Pipeworks

ok so.. i saw https://www.curseforge.com/minecraft/mc-mods/super-factory-manager and this is like really cool (i dont care much about having the inventory cables though)

so yeah what if you could just... 

`location_ref = {x=,y=,z=} OR { [1]={x=,y=,z=}, [2]={x=,y=,z=} [3] = ... whatever you know the pattern }`

`items = pull_from(location_ref, inventory_list_name... or direction... idk which is better, filter)` - `items` - immutable for the sandbox, this is the representation of the items and where they came from, doesn't actually *pull* the items, but opens them up for access, if that makes sense

`put_to(location_ref, inventory_list_name_or_direction_idk_man_i_need_to_decide, items)`


And yeah thats all im going to come up with for the world interfacing part, its a good idea to make the lua part first...

and also yeah i think its a good idea to bill `pull_from` and `put_to`



# Lua part (again)
ok so, another disk, an editor code disk, would be needed (that would just punch the editor code directly)