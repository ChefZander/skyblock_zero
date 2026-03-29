
# Questline: Emittrium

Emittrium is a very important material when working with Cosmic Joules. This questline will teach you all about it.

## Obtain Emittrium
### ID: qid_obtain_emittrium

### Text

Do you see those blue nodes in the distance? They're called Emitters. To obtain Emittrium from them, you will have to build a bridge over to one.  
I would recommend to choose the closest one to you, but any Emitter works. Next, you'll need a Matter Annihilator. You can't destroy the Emitters, but you can chip away at them.  
  
Punch your Emitter of choice until it yields some 'Raw Emittrium'. We'll refine the Emittrium later, but for now we just need it in its raw state.  
  
Emitters have a 1/10 chance of producing Raw Emittrium, and a 9/10 chance of producing the same materials that the core does.  

### Meta

Requires: qid_annihilator

## Power Cables
### ID: qid_power_cables

### Text

To transfer power from generators to machines, you'll need Power Cables. You can get a power cable with a shapeless craft using one Raw Emittrium and one Matter Plate.  
The cables will connect up and supply your machines with power, looking at your machine will show 'Running' if the machine is running.  
Also, if you put a machine next to another machine, it will conduct power to that machine, so you only need power cables in some cases.  
For example, if you have one area for plants, one area for manufacturing, cables are the nicest option to bridge the areas.

### Meta

Requires: qid_matter_plates, Obtain Emittrium

## Starlight Collectors
### ID: qid_starlight_collectors

### Text

Starlight Collectors turn the light of stars into power for you to use. But the stars are very faint, so you'll need a lot of these if you want to power a whole factory!

### Meta

Requires: Obtain Emittrium

## Starlight Catchers
### ID: qid_starlight_catchers

### Text

Starlight Catchers are similar starlight collectors but more compact, generating 1 Cj/s.  
But unlike starlight collectors, they need **Photon-Energy converters**, to convert their energy into usable power.  
They won't do anything if you connect them directly to a Switching Station, as they provide power though the photon-energy converter.  

### Meta

Requires: qid_starlight_collectors

## Emittrium Circuits
### ID: qid_emittrium_circuits

### Text

For some recipes related to storing or transferring power, you'll need Emittrium Circuits. 

### Meta

Requires: qid_matter_plates, Obtain Emittrium, qid_retaining_circuits

## Batteries
### ID: qid_batteries

### Text

Sometimes, you'll need to temporarily buffer some energy. That's what the Battery is for. It stores up to 5 kCj of energy. You can craft it by surrounding a Emittrium Circuit with matter blobs.

TIP: Without batteries, all power that isn't being used for machines is wasted, with batteries you can store some of it.

### Meta

Requires: qid_emittrium_circuits

## Connectors
### ID: qid_connectors

### Text

If you want to turn machines on and off, you can use Connectors. They join two networks together, and you can click on them to turn them on and off.  
IMPORTANT: Make sure that only one of the two or more joined networks has a Switching Station, or they will blow up until reaching one.

### Meta

Requires: qid_emittrium_circuits, qid_reinforced_matter

## Angel's Wing
### ID: qid_angels_wing

### Text

The Angel's Wing can make you fly. Right-Click to use, it has 100 uses. To craft, surround an Emittrium Circuit with Stone. This recipe is temporary.

### Meta

Requires: qid_emittrium_circuits, qid_concrete_plan

## Ele Fabs
### ID: qid_ele_fabs

### Text

Used to manufacture various logic components.

### Meta

Requires: qid_antimatter, qid_emittrium_circuits

## Knowledge Stations
### ID: qid_knowledge_stations

### Text

Teaches you about logic, which is not documented in this questbook but instead in the knowledge station. Good luck.

### Meta

Requires: qid_concrete_plan, qid_ele_fabs

## Movable Emitters
### ID: qid_movable_emitters

### Text

If you are tired of not being able to have emitters wherever you want, get a Movable Emitter. Your factory could use another Emitter, no?  
In the core of the ice planets there is a solution but be aware, you must be strong.  
  
Movable emitters can be duplicated with 8 phlogiston.  

### Meta

Requires: qid_planet_teleporter
