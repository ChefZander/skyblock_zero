
# Questline: Pipeworks

If you already know about regular pipeworks, skyblock_zero's pipeworks are a very modified version of that mod, but it will be similar though.

## Tubes

### Text

Have you ever wanted to automatically move items around without input?  
  
Now you can!  
  
Tubes are, well, tubes that can transport items around! Currently, you can't interact with them, but just have some lying around—the next and future quests use them.  
  
TIP: Items in tubes will go into directions with higher tube priority. The default tube priority is 100.

### Meta

Requires: Furnace

## Automatic Filter-Injectors

### Text

Have you ever been tired of taking items out of nodes? Do you just want to interact with tubes as soon as possible?  
Now you can!  
The Automatic Filter-Injector takes stacks of items from nodes and places them into tubes or other nodes.  
  
\<big\>The Automatic Filter-Injector has two settings:\</big\>  
**The slot sequence (allows you to change the order that items are taken out):**  
Priority: Takes items out in first-out order  
Randomly: Takes items out in a random order  
Rotation: Takes items out in a cyclic order  
**The match mode (sets the behavior when taking out items):**  
Exact match - off: If an item matches the filter, it takes out the whole stack  
Exact match - on: If an item matches the filter and the stack is higher, it takes out the filter count. For example, if the filter is set to 5 matter and it is pulling from a stack of 60 matter, it will pull out 5 matter until the stack is below 5 or empty.  
Threshold: If an item matches the filter and the stack is higher, it takes out items until the stack matches the filter. For example, if you have a filter of 5 matter and a stack of 60, it will pull 55 matter out of the stack.  

### Meta

Requires: Bear Arms, Tubes

## Info: Matter Factory

### Text

Using advanced matter extractors, some automatic filter injectors, tubes, and a Storinator, you can make a really good matter factory.  
Advanced matter extractors are crazy fast for their cost, so with around 5 of them, you will get lots of matter in no time.  
  
Here is an example of one:  
\<img name=questbook_image_matter_factory.png width=483 height=453\>  

### Meta

Requires: Automatic Filter-Injectors, Tubes

## Node Breakers

### Text

Node Breakers try to break the node in front of them. The drops are ejected out the back-side. They need 20 power for each node dug. To make "caveman automation" (non-Lua automation) more powerful, plants that haven't finished growing cannot be dug by the Node Breaker. If you insert a tool that requires power (for example, a laser), the node breaker will try to charge it, consuming more power.

### Meta

Requires: Automatic Filter-Injectors

## Deployers

### Text

Deployers try to place a node into their front-side. That's about it.

### Meta

Requires: Automatic Filter-Injectors, Bear Arms

## Punchers

### Text

Punchers punch stuff, allowing you to automate resource generation even more. But you need to give them something to punch with.

### Meta

Requires: Automatic Filter-Injectors, Bear Arms, Emittrium Circuits

## Autocrafters

### Text

Autocrafters automatically craft. They require a crafting processor item to run, which you can upgrade as you progress through the game, to increase crafting speed.

### Meta

Requires: Bear Arms, Neutronium, Emittrium Circuits, Automatic Filter-Injectors

## Simple Crafting Processors

### Text

The first tier of Crafting Processors. This one crafts at a speed of one item per second, for 10 power. The higher tiers of crafting processors will not have quests associated with them, so here are their stats:

Simple Crafting Processor: 1 item/s & 10 power
Quick Crafting Processor: 2 items/s & 25 power
Fast Crafting Processor: 4 items/s & 50 power
Accelerated Silicon Crafting Processor: 8 items/s & 100 power
Nuclear Crafting Processor: 16 items/s & 175 power

### Meta

Requires: Autocrafters

## Item Voids

### Text

Item Voids delete every item that goes in, and yes, these are Pipeworks trash cans. But unlike pipeworks trash cans, they show the amount of items they've destroyed.  

### Meta

Requires: Tubes

## Info: Overflow Handling

### Text

Tubes break when they have too many stacks in them. This may not appear as a problem at first, but when you think about it, it can be a huge issue.  
**If we have this setup:**  
\<img name=questbook_image_basic_setup.png\>  
Then there might be an issue if the Storinator that we are putting items into is completely filled.  
In cases where there is only one tube, the item will simply drop, but when there are at least two tubes, the items will wander around until eventually there are too many of them. In that case, the tubes will break.  
How do we prevent our tubes from breaking or items from dropping?  
Well, a simple answer would be to have more storinators :D..... but that's not practical.
  
**Instead, consider using item voids like this:**  
<img name=questbook_image_overflow_handling.png>

Item voids have the lowest priority, so items really don't want to go there.
Storinators have a higher priority than Item Voids, so if the Storinator isn't full, items will want to go there.  
Item Voids have a lower priority, so if the item can't go to the Storinator, it will go into the Item Void.  
  
The default priority of nodes is 100.

### Meta

Requires: Item Voids

## Item Vacuums

### Text

Item Vacuums vacuum up items in a 16-block radius, but they tend to cause lag.

### Meta

Requires: Neutronium, Tubes

## Teleport Tubes

### Text

So, I think you want to transmit items over long distances. Well, teleport tubes help with that! They pretty much explain themselves, so good luck!
  
Oh wait, one thing to mention: items will fall off the receiving tube if you don't use a high-priority tube next to it.

### Meta

Requires: Tubes, Crystal Grower

## One Direction Tubes

### Text

This is a tube that accepts items from all directions but only allows them to go in one direction.  
If you hover over it, it will spawn a white particle. The direction of the white particle is the direction that the items will go in.  
  
To change that direction, sneak and punch it on the side that you want the items to go in.  

### Meta

Requires: Tubes

## Automatic Turrets

### Text

Do you want to automatically shoot down meteorites or even shoot down players? The automatic turret will help with that. It is similar to the node breaker but does not dig nodes. Equip it with a laser to get started. But be warned: near spawn, the turret's range gets decreased by 80%. If you insert a tool that requires power, for example lasers, it will try to charge the laser, resulting in more power usage.

### Meta

Requires: Node Breakers, Neutronium

## Instatubes

### Text

Instatubes are tubes that are instant. They are generally less laggy than their regular pipeworks tube counterparts WHEN USED CORRECTLY. They can be a lot more laggy if you use them incorrectly.  
  
Instatubes work differently than regular tubes.  
They internally create a list of all the receivers, then sort the receivers based on priority. The receivers with the highest priority will be given the items first. If they are full, it will move on to the receiver with lower priority.  
This is different from regular pipeworks tubes, in a way that's hard to explain, so a visual example is best:  
\<img name=questbook_image_instatubes_vs_pipeworks_tubes.png\>  
Suppose that the green storinators have a priority of 99 (they don't, but it will make explaining this easier). That is higher than regular pipeworks tubes but lower than regular storinators.  
In that case, with default pipeworks tubes, items will flow first to the green Storinator, then once it's full, they will flow to the regular Storinator.  
Instatubes work differently: they will choose the Storinator with the highest priority first, then the lowest. So items would flow first into the regular Storinator, and once that's full, they will flow to the green Storinator.  
  
Overflow handling: simply put an item void connected to the instatubes (you might need to connect it to a few low-priority tubes if you use those anywhere, as it has a priority of only one, and you can go below that).  
  
Now, some things are just impossible with the basic instatube, so there are more types of instatubes :D. This will cover all them.
  
\<big\>Priority Instatubes\</big\>  
(Low priority instatubes, high priority instatubes)  
  
They change the priority of all the machines on their "branch". To explain this better, here it is visually:  
\<img name=questbook_image_instatube_priority.png width=450\>  
  
\<big\>Teleport Instatube\</big\>  
It teleports items... But isn't quite the same as using the pipeworks instatube, because teleport instatubes will check all teleport instatubes and give the item to the highest-priority receiver instead of just sending items to one randomly.  
\<big\>Cycling Input Instatube\</big\>  
This instatube is only useful when placed next to something that outputs items (for example, Filter Injectors and Blast Furnace Output Ports).
It completely ignores the priority of receivers and instead cycles between them.
  
\<big\>Randomized Input Instatube\</big\>  
Like the cycling input instatube, but it gives the item to a random receiver.
  
\<big>Instatube Item Filter\</big\>  
Similar to the item sorter, but it only governs what can pass through that tube. (The advantage of using it over item sorters is that it will respect priority, and no short-lived entities will be created.)  
  
\<big\>One-Way Instatubes\</big\>  
Instatubes that only allow items to flow in one direction, useful when having multiple filter injectors.

\<bigger\>Performance\</bigger\>
With big speed comes big responsiblity.

The lag from instatubes may show up in your switching station as lag from the thing that is inserting to them. (For example Automatic Filter-Injectors or punchers). The lag from pipeworks tubes does not show up in there.

1st tip: Don't make all of your base a single large instatube network. (unless you know what you are doing, and know the flaws of instatubes)  
2nd tip: Don't transport MANY small item stacks in a large instatube network, <b>have one or the other</b>. Always prefer larger item stacks. (Instead of sending 100 matter blobs in seperate stacks to a large network, just send one stack of matter blobs)
3rd tip: Only debug performance when it matters. (for example: you notice unusually high lag from filter injectors, or from your 500 puncher setup)

Practical example: Say you want to wire up 50 punchers to your base for processing, how should you go about doing this?  
Well, you will be transporting 50 item stacks per second, depending on the network size, that is a lot!

What you SHOULDN'T do:
(In these images, storinators may be in any place, and they don't have to be storinators, they can be machines or even other punchers, they just have to be connected to the punchers in some way, and the punchers can be anything that produces large amounts of very tiny item stacks)
\<img name=questbook_image_instatube_performance_wrong.png width=400\>  
In this image, for each item the punchers send out, it needs to iterate over everything in the network (so storinators, punchers) to find something that isn't full, this isn't ideal for performance if you are getting 100 item stacks per second.

What you SHOULD do instead:
\<img name=questbook_image_instatube_performance_correct.png width=400\>  
(Don't forget to actually power those filter injectors)

In this case, the many little item stacks that get sent to that storinator, or if that storinator got filled, to the item void.
So in the worst case, an item only needs to iterate through 2 things (the collection storinator and the item void) to determine where to go.
There aren't as many item stacks that get sent to the larger network, because those item stacks will contain more items. (Instead of sending 200 "sbz_resources:matter_dust 1", it will just send 1 "sbz_resources:matter_dust 200" if that makes sense, and that's faster)
The high priority instatube here is redundant but useful if you aren't working with punchers.
  
**To complete this quest, craft an instatube.**  

### Meta

Requires: Blast Furnace

## Pattern Storinator

### Text

It is a Storinator with 16 slots of storage and 16 slots for the pattern.  
The pattern slots govern how the storage slots can be filled. If a pattern has 43 Matter Dust in the first slot, then there can be only up to 43 Matter Dust in that slot, similar to how the Autocrafter does it.  
  
By default, the Filter Injector does nothing to the Pattern Storinator.  
When the Pattern Storinator is full (storage matches the pattern), it will allow using Filter Injectors but disallow inputting items into the Pattern Storinator.  
Once it's empty, you will be able to insert into it again, and filter injectors will stop working on it.
  
The Pattern Storinator can be used in machines like the Meteorite Maker, where your flow rate of emittrium and matter blobs might otherwise cause clogging.

### Meta

Requires: Automatic Filter-Injectors

# Questline: Fluid Transport

This questline is about transporting fluids.

## Fluid Pipes

### Text

A fluid pipe is like an (Insta)tube, but with fluids. They move fluids around just like how tubes move items around.

### Meta

Requires: Tubes

## Fluid Pumps

### Text

Fluid Pumps are automatic filter-injectors, but for pipes. They take fluids from fluid inventories.

### Meta

Requires: Automatic Filter-Injectors

## Fluid Storage Tanks

### Text

Fluid Storage Tanks are storinators for fluids. They can store 100 nodes of fluid. That's a lot! (But not really if you compare it to the amount of nodes that a basic Storinator can store.)

Tip: Once any fluid storage has received one type of liquid, it will always continue to receive that type of liquid.  
This means that if you have a fluid storage that was previously filled with liquid aluminium, but now you want to fill it with water, you will need to replace that fluid storage block.  
This applies to pretty much all of fluid transport.  

### Meta

Requires: Tubes, Storinators

## Fluid Capturers

### Text

Fluid Capturers capture liquid **sources** from their top and store them. You can take out the captured fluid with a fluid pump.

### Meta

Requires: Fluid Storage Tanks

## Fluid Cell Fillers

### Text

Fluid Cell Fillers fill empty fluid cells in their inventories.

### Meta

Requires: Fluid Storage Tanks
