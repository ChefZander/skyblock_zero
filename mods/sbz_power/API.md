# The api got too complex to not be documented

### `sbz_api.register_machine(name, def)`
- registers a... machine
- you can choose if it conducts power by setting the pipe_conducts group to 0
- `def.disallow_pipeworks` - so if you dont want itemtransport (DONT DO THIS INTENTIONALLY to make your machine more "balanced", PLEASE) you just set this to true, also this automatically happens when you dont have a output_inv, but you still get `pipeworks.after_place` and `pipeworks.after_dig`, also if you have your own after_place_node or after_dig_node you need to manually add in pipeworks.after_dig(blabla) and yeah you get it
- `def.input_inv` `def.output_inv` - theese are the input/output inventory lists, `def.input_inv` is optional for pipeworks
- `power_consumed = def.action(pos, node, meta, supply, demand)`
 - node: its the node name... not really useful
 - supply: the... supply... of the network
 - demand: the... demand...... of the network
 - returns a number, it must be a number or you will get a cryptic error, that number is the amount that the power is consumed
 - runs once per second*
- `def.power_needed` - so if your machine is something like the extractor where theres not much going on, you can just set this value to 5, it will modify your action to only execute when it has that amount of power
  - `def.idle_consume` - requires `def.power_needed` - the idle consumbtion of the thing... when it like doesnt have enough power thats what yeah.... defaults to `def.power_needed`, keep it nil if you didnt get my amazing explanation  
  - `def.action_interval` - requires `def.power_needed` - the delay between your actions, yeah im sorry that it requires power_needed but whatever i was too lazy while writing the api ok


### `sbz_api.register_generator(name, def)`
- `def.power_generated` so if your generator is a literal constant solar panel, you might want to set this to like 3 and it will just generate that amount of power... no `def.action` required
- `def.action` same as machines
- `def.output_inv` `dev.input_inv` `def.disallow_pipeworks` same as machines
- `def.action_interval` - blabla you know

### STATEFUL MACHINES
ok so there are theese 2 functions (very very similar) - `sbz_api.register_stateful_machine` and `sbz_api.register_stateful_generator`

they register 2 machines, one with an _off and one with an _on

The type obtainable to the player (in the inventory and crafts) is _off

they also register an alias so that `x_machine_off` = `x_machine`

and they also make sure that the drops are correct and that the _on is not in creative inventory

now..

`sbz_api.register_stateful_machine(name, def, on_def, off_def)`
- on_def: the definition that gets applied only in the _on node
- off_def (optional): the definition that gets applied only in the _off node.. kinda useless but for the sake of completeness

oh yeah also

`def.stateful` - this gets automatically set to true, for internal pourpourses

`def.autostate` - if you set it to true, state will (most likely) be automatically managed for you, so that when you require 0 power, its off, when you require more than 0 power... its on

and `sbz_api.register_stateful_generator` is literally the same thing but for generators

## Now the... fun stuff

`sbz_api.turn_off(pos)` - turns off a stateful node in that pos

`sbz_api.turn_on(pos)` - yeah opposite of turn_off

`sbz_api.is_on(pos)` - tells you if its on or not, works only for stateful nodes

all of theese work only on stateful nodes actually


