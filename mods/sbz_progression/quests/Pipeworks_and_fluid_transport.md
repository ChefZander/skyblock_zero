
# Questline: Pipeworks

If you already know about regular pipeworks, skyblock_zero's pipeworks are a very modified version of that mod, but it will be similar though.

## Tubes

### Text

Have you ever wanted to automatically move items around without input?  
  
Now you can!  
  
Tubes are, well, tubes that can transport items around! Currently, you can't interact with them: but just have some lying around, the next and future quests use them.  
  
TIP: Items in tubes will go into directions with higher tube priority. The default tube priority is 100.

### Meta

Requires: Furnace

## Automatic Filter-Injectors

### Text

Have you ever been tired of taking items out of nodes? Do you just want to interact with tubes as soon as possible?  
Now you can!  
The Automatic Filter-Injector takes stacks of items from nodes, and places them into tubes or other nodes.  
  
\<big\>The Automatic Filter-Injector has two settings:\</big\>  
**The slot sequence (allows you to change the order that items are taken out):**  
Priority: Takes items out in first out order  
Randomly: Takes items out in a random order  
Rotation: Takes items out in a cyclic order  
**The match mode (sets the behavior when taking out items):**  
Exact match - off: If an item matches the filter, it takes out the whole stack  
Exact match - on: If an item matches the filter and the stack are higher it takes out the filter count, for example the filter is set to 5 matter, and it is pulling from a stack of 60 matter it will pull out 5 matter until the stack is below 5 or empty  
Threshold: If an item matches the filter and the stack are higher it takes out items until the stack matches the filter, so I have a filter of 5 matter and a stack of 60 it will pull 55 matter out of the stack.  

### Meta

Requires: Bear Arms, Tubes

## Info: Matter Factory

### Text

Using advanced matter extractors, some automatic filter injectors, tubes, and a storinator, you can make a really good matter factory.  
Advanced matter extractors are crazy fast for their cost, so with like 5 of them, you will get lots of matter in no time.  
  
Here is an example of one:  
\<img name=questbook_image_matter_factory.png width=483 height=453\>  

### Meta

Requires: Automatic Filter-Injectors, Tubes

## Node Breakers

### Text

Node Breakers try to break the node in front of them. The drops are thrown away into the back-side. They need 20 power for each node dug. To make "caveman automation" (non lua automation) more powerful, plants that haven't finished growing cannot be dug by the node breaker. If you insert in a tool that requires power (for example laser), the node breaker will try to charge it, consuming more power.

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

Autocrafters automatically craft. You can make them craft as fast as possible, but they consume more power depending on the current crafts.

### Meta

Requires: Bear Arms, Neutronium, Emittrium Circuits, Automatic Filter-Injectors

## Item Voids

### Text

Item voids delete every item that goes in, and yes these are pipeworks trash cans. But unlike pipeworks trash cans, they show the amount of items they've destroyed.  
That number can "overflow" into the negatives, if you actually manage to do this, don't consider it a bug, but consider it an achievement :)

### Meta

Requires: Tubes

## Info: Overflow Handling

### Text

Tubes break when they have too many stacks in them. This may not appear as a problem at first, but when you think about it - it can be a huge issue.  
**If we have this setup:**  
\<img name=questbook_image_basic_setup.png\>  
Then, there might be an issue with it if the storinator that we are putting items to is completely filled.  
In cases where there is only one tube, the item will simply drop, but when there are at least 2 tubes, the items will wonder around, until eventually there will be too many of them. In that case, the tubes will break.  
  
How do we prevent our tubes breaking, or items dropping?  
Well... a simple answer would be to have more storinators :D... but that's not practical  
  
**Instead, consider using item voids like this:**  
\<img name=questbook_image_overflow_handling.png\>  
Item voids have the lowest priority, so items really don't want to go there.  
Storinator, has a higher priority than the item void, so if the storinator isn't full, items will go there.  
Item voids, have a lower priority, so if the item can't go to the storinator, it will go into the item void.  
  
The default priority is 100.  

### Meta

Requires: Item Voids

## Item Vacuums

### Text

Item Vacuums vacuum up items in a 16 block radius, but they tend to cause lag.

### Meta

Requires: Neutronium, Tubes

## Teleport Tubes

### Text

So, i think you want to transmit items in long distances, well teleport tubes help in that! They pretty much explain themselvs, soo, good luck!  
  
Oh wait, one thing to mention: The items will fall off the receiving tube if you don't use a high priority tube next to it.

### Meta

Requires: Tubes, Crystal Grower

## One Direction Tubes

### Text

This is a tube that accepts items from all directions, but allows them to only go in one direction.  
If you hover over it, it will spawn a white particle, the direction of the white particle, is the direction that the items will go in.  
  
To change that direction, sneak and punch it on the side that you want the items to go in.  

### Meta

Requires: Tubes

## Automatic Turrets

### Text

Do you want to automatically shoot down meteorites, or even shoot down players? The automatic turret will help in that. It is similar to the node breaker, but does not dig nodes. Equip it with a laser to get started. But be warned, near spawn, the turret's range gets decreased by 80%. If you insert in a tool that requires power, for example lasers, it will try to charge the laser, resulting in more power use.

### Meta

Requires: Node Breakers, Neutronium

## Instatubes

### Text

Instatubes are tubes that are instant. They are generally less laggy than their regular pipeworks tube counterparts.  
  
Instatubes work a bit differently than regular tubes.  
They internally create a list of all the receivers, then they will sort the receivers based on priority, and the receivers with largest priority will be given the items first, if they are full, it will move on with the receiver with lower priority.  
This is different to regular pipeworks tubes... in a way... that's hard to explain, so a visual example would be best:  
\<img name=questbook_image_instatubes_vs_pipeworks_tubes.png\>  
Suppose that the green storinators had a priority of 99. (they don't, but it will make explaining this easier) That is higher than regular pipeworks tubes, but lower than regular storinators.  
In that case, with the default pipeworks tubes, the items will flow first to the green storinator, then once it's full, it will flow to the regular storinator.  
Instatubes work a bit differently, they will choose the storinator with the highest priority, then to the lowest. So items would flow first into the regular storinator, once that's full, it will flow to the green storinator.  
  
Overflow handling: simply put up an item void connected to the instatubes (might need to connect it to a few low priority tubes if you use those anywhere, as it has only a priority of one, and you can go below that)  
  
Now... some things are just impossible with the basic instatube, so there are more types of instatubes :D, this will cover them  
  
\<big\>Priority Instatubes\</big\>  
(Low priority instatubes, high priority instatubes)  
  
They change the priority of all the machines on their "branch", to explain this better, here it is visually:  
\<img name=questbook_image_instatube_priority.png width=450\>  
  
\<big\>Teleport Instatube\</big\>  
It teleports items... But isn't quite the same as using the pipeworks instatube, because teleport instatubes will check out all teleport instatubes, and give the item to the highest priority receiver, instead of just sending items to one randomly.  
  
\<big\>Cycling Input Instatube\</big\>  
This instatube is only useful when placed to something that outputs items (example: filter injectors and blast furnace output ports).  
It will completely ignore the priority of the receivers, instead just cycling between them.  
  
\<big\>Randomized Input Instatube\</big\>  
Like the cycling input instatube but it just gives one random receiver the item  
  
\<big\>Instatube Item Filter\</big\>  
Similar to the item sorter, but it only governs what can pass through that tube. (The advantage of using it over item sorters is that it will respect priority, and also no short lived entities will get created)  
  
\<big\>One way instatubes\</big\>  
Instatubes that only allow items flowing from one direction, useful when having multiple filter injectors.  
  
  
**To complete this quest, craft an instatube**  

### Meta

Requires: Blast Furnace

## Pattern Storinator

### Text

It is a storinator with 16 slots of storage, and 16 slots for the pattern.  
The pattern slots govern how the storage slots can be filled. If a pattern has in the first slot 43 matter dust, then there can be only up to 43 matter dust in that slot. Similar to how the autocrafter does it.  
  
By default, filter injector does nothing to the pattern storinator.  
When the pattern storinator is full (storage matches the pattern), it will allow using filter injectors, but will disallow inputting items into the pattern storinator.  
Once its empty, you will be able to insert to it again, and filter injectors will stop working on it.  
  
The pattern storinator can be used in machines like the meteorite maker, where your flow rate of emittrium and matter blobs might make the meteorite maker clog.  

### Meta

Requires: Automatic Filter-Injectors

# Questline: Fluid Transport

This questline about transporting fluids.

## Fluid Pipes

### Text

A fluid pipe is like a (insta)tube, but with fluids. They move fluids around, just like how tubes move items around.

### Meta

Requires: Tubes

## Fluid Pumps

### Text

Fluid Pumps are automatic filter-injectors, but for pipes. They take fluids from fluid inventories.

### Meta

Requires: Automatic Filter-Injectors

## Fluid Storage Tanks

### Text

Fluid Storage Tanks are storinators for fluids. They can store 100 nodes of fluid. That's a lot! (But not really if you compare the amount of nodes that the basic storinator can store)

Tip: Once any fluid storage has received one type of liquid, they will always continue to receive that type of liquid  
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
