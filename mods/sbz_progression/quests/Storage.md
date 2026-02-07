# Questline: Storage

Mainly about drawers and Storinators.

## Storinators

### Text

Storinators are the solution to clogged up inventories. They have 32 slots of inventory, and function like a chest.  
The more red/green dots the front of a Storinator displays, the more full/empty it is.  

### Meta

Requires: Matter Plates, Charged Field, Retaining Circuits

## Better Storinators

### Text

At some point, only having 32 slots of storage is not enough.  
You can make more Storinators, or you can make an upgraded one.  
Each upgrade adds 1 row and 1 column to the inventory space.  
  
To complete this quest, you need to craft the bronze Storinator.  

### Meta

Requires: Storinators, Bronze Age

## Public Storinators

### Text

Public Storinators are like regular Storinators but are accessible to **anyone**, regardless of protections. You can craft them by simply putting any type of Storinator in your crafting guide.

### Meta

Requires: Storinators

## Best Storinators

### Text

Do you have chaos in your Storinators? Are you struggling to figure out which one is which? Do you need labels, but signs get in the way?  
You can use Neutronium Storinators. They are a little expensive, requiring 4 Neutronium, but if you can afford them, they are great for this.  

### Meta

Requires: Better Storinators, Neutronium

## Drawers

### Text

Do you have some automation that produces large amounts of one type of item?  
Or do you just have large amounts of a single item type?  

Drawers will help here. They are like Storinators, but they can only store a few item types.
They store 3200 items (without upgrades). With upgrades, they can store a lot more.  

Drawers also come with 1x2 and 4x4 variants.  

### Meta

Requires: Storinators

## Drawer Upgrades

### Text

Drawers by default store the same amount of items as a Storinator; that's a bit boring. What if you could store more?

TIP: The upgrades don't work as you might expect. If you have two bronze upgrades, each bronze upgrade adds an extra 3200 items; it doesn't multiply 3200 by 4 or anything like that.  
TIP: To insert an upgrade into a drawer, you need to right-click the edge of it or right-click a side that doesn't have the item display.

### Meta

Requires: Drawers, Bronze Age

## Drawer Controller

### Text

You may have noticed that drawers still might not work amazingly for automation; the drawer controller is here to solve that.  
If you send it an item with a tube or manually provide it an item, it will automatically put it into an adjacent drawer (or a drawer adjacent to the others).  

For taking out items, you can use a Luacontroller, sending an itemstack (a string like `"sbz_bio:dirt 100"`), and it will try to give you that dirt by injecting it out of itself.  

### Meta

Requires: Drawers

## Room Containers
### Text

Do you want to just put things in a room? This node was made for that.

Room containers contain 16x16x16 rooms (if you count the walls) that is inside one mapblock. A player can only have 100 rooms at most.

If you break a room container, don't worry, the next room container you place will point to that same room.

Room containers can also accept power and teleport it to a room.

Right-click a room to teleport to it, and right-click the room exit (a special block inside the wall) to exit the room.

Warning: To save the positions of rooms, room containers use an experimental luanti function (that has been experimental and mostly unchanged since 2016), this might not be that big of a concern but <b>you shouldn't put your entire storage system in a room container</b> because of that. It is unclear how reliable the saving/loading of room containers is.
Server owners should ideally have backups.

Warning: The power input functionality may not work correctly on servers (by default), or on Skyblock Zero configurations that have the "sbz_switching_station_unload" setting active, it may be unusable, sorry.




### Meta

Requires: Warpshrooms
