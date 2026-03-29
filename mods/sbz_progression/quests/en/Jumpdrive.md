
# Questline: Jumpdrive

A modified version of the mt-mods/jumpdrive mod, lets you teleport yourself, and your buildings, anywhere*.
    

## Jumpdrive Backbone
### ID: qid_jumpdrive_backbone

### Text

An ingredient in making the jumpdrive engine.  
Also used in connecting jumpdrives to a fleet controller.  

### Meta

Requires: qid_compressor, qid_reactor_shells

## Warp Device
### ID: qid_warp_device

### Text

An ingredient in making the jumpdrive engine. May be required for other things in the future.  

### Meta

Requires: qid_crystal_grower, qid_antimatter_generators

## The Jumpdrive (engine)
### ID: qid_the_jumpdrive_engine

### Text

Lets you teleport your buildings with you, to any* coordinate....  
  
*Though in skyblock zero, this has been slightly modified: Without a jumpdrive station near the target, you can only travel 500 blocks away from your current position... But if you have a jumpdrive station, near (50 blocks away) your target position, you can teleport there.  
  
The jumpdrive also acts as a battery, storing 200 kCj, this also means it can be discharged, be aware of that.  
  
If you punch the jumpdrive with an empty hand, you will see an outline of what nodes it will teleport.  
  
You can transport emitters with the jumpdrive.  
Also, emitters stop spawning after y=1000, so you can transport stuff more easily there, since no emitters will interfere with you.  
  
If your jumpdrive flight takes too much energy, the jumpdrive can also take away power from other batteries, it will do this automatically, but its 4 times less efficient compared to using regular jumpdrive's power.  
It is good practice to use the "show" button before using the "jump" button, to see how much power your flight will consume,  
The jumpdrive can only take away power from batteries that are in the jumpdrive range.  
  
With protections: Jumpdrive leaves protections behind if it collides with another protected area that's not yours.  

### Meta

Requires: qid_jumpdrive_backbone, qid_warp_device, qid_very_advanced_batteries

## Jumpdrive Stations
### ID: qid_jumpdrive_stations

### Text

So, I imagine you'd like to travel huge distances with the jumpdrive, well.... this will allow you to do that  
  
Simply place one down in your target destination. Now you can teleport near it with the jumpdrive.  

### Meta

Requires: qid_the_jumpdrive_engine

## Jumpdrive Fleet Controller
### ID: qid_jumpdrive_fleet_controller

### Text

So... I imagine you want to move multiple jumpdrives at once... well you are lucky, this is the node for you!  
Connect up all the jumpdrives with jumpdrive backbones, connect that to the fleet controller, and now you can use it!  
  
Warning: Make sure to ALWAYS press "show" before jump... you don't want one of your jumpdrives to be in the wrong place...  

### Meta

Requires: qid_jumpdrive_backbone
