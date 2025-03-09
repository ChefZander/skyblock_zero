Customization documentation for replacer minetest mod
=====================================================

- [Settings](#settings)
- [API Commands](#api-commands)
- [Overrides](#overrides)
- [Inspection Tool](#inspection-tool)

## Settings

_default values in parentheses ()_<br>
All the setting names correspond to equivalents in Lua namespace. Allowing them to be
changed "on the fly". The recipe related ones won't have any effect though.<br>
For history related settings, users will have to relog or have their history priv
revoked and granted again for the values to take effect correctly.

### replacer.max_nodes (3168)
Replace / place up to this many nodes when using modes other than single.<br>
Depending on server hardware and amount of users, this value needs adapting.
On singleplayer you can mostly use a higher value.

### replacer.max_time (1.0)
Some nodes take a long time to be placed. This value limits the time in seconds
in which the nodes are placed. This prevents more lag on an already lagging server
with a high replacer.max_nodes setting.<br>
This time does not include the time used to search for nodes, only the time used
to replace them is measured and limited by this value.

### replacer.radius_factor (0.4)
Radius limit factor when more possible positions are found than either max_nodes or charge
allow. Positions are traversed again and only those within radius * this factor are
passed back for replacement. Generates nice circles in field mode.<br>
Radius == floor(max_positions ^ radius_factor + .5) where max_positions is a min(max())
of available charge and max_nodes. Small changes to this value can have big effects.<br>
Set radius_factor to 0 or less for behaviour prior to version 3.3

### replacer.disable_minor_modes (bool)
If you don't want to use the minor modes at all, set to true. These are the modes where
only node or rotation is applied.

### replacer.history_priv (creative)
You can make history available to users with this priv. By default it is set to **creative**
as survival users can make several replacers. You can make this an achievement for busy players
to work towards, or set to **interact** to allow any player to use history of previously
used node settings.

### replacer.history_disable_persistency (false)
When set, does not save history over sessions. Reason might be old MT version.<br>
Currently history is stored in player's meta on logoff and at intervals.

### replacer.history_save_interval (7)
How frequently, in minutes, history is saved to player-meta.<br>
Only users with the priv are affected.

### replacer.history_include_mode (false)
When set, changes the replacer's major and minor modes when picking an item from history.<br>
The modes are stored either way.

### replacer.history_max (7)
Limits history length. Duplicates are removed so there isn't much need for long histories.

### replacer.hide_recipe_basic (false)
You may choose to hide basic recipe but then make sure to enable the technic direct one
or add your own registration. Reason might be that you want another recipe and don't
want to use an override.

### replacer.hide_recipe_technic_upgrade (false)
Hides the upgrade recipe.<br>
Only available if technic is installed.

### replacer.hide_recipe_technic_direct (true)
Hides the direct recipe of technic replacer that does not require a basic replacer as
ingredient.<br>
Only available if technic is installed.

### replacer.enable_recipe_technic_without_technic (false)
Enables a direct recipe of technic replacer without technic mod installed.<br>
The recipe is rather cheap and it is recommended to override it to play well with<br>
the type of server you are running.<br>
Only has effect if technic isn't installed.

### replacer.dev_mode (false)
Enable developer mode which gives users with **priv** priv to run **/place_all** chat command.<br>
This is not recommended on live servers as some nodes your mods provide may crash the server
when placed this way. [Read the comments in (test.lua)](test.lua)

## API commands

### Deny Groups
You can add groups that you don't want your users to be able to use replacer with.<br>
For example by default items from **group:seed** are forbidden.
```lua
replacer.deny_groups['seed'] = true
```

### Deny Nodes
A selection of nodes are added by default, such as tnt:* and protectors.<br>
You may want to deny the replacement **and** placement of certain nodes.
```lua
replacer.deny_list['tnt:boom'] = true
```

### Limit Node Count
This setting will be clamped to **replacer.max_nodes** if it exceeds it.<br>
If you pass 0, the node will be added to **deny_list**. Negative numbers are ignored.
```lua
replacer.register_limit('beacon:red', 5)
```
Above snippet limits technic replacer to only place maximum 5 red beacon boxes per usage.

### Max Technic Replacer Charge
Bellow example reduces the amount of charge a technic replacer can carry.
```lua
replacer.max_charge = 10000
```

### Charge per Node
Bellow example increases the amount of charge a technic replacer uses to place/replace a node.
```lua
replacer.charge_per_node = 30
```

### Replace Intervention
You can override ```replacer.permit_replace(pos, old_node_def, new_node_def, player_ref, player_name, player_inv, creative_or_give)```
function to implement server specific rules about where, when, who may place/replace what.<br>
E.g. check if player has sufficient funds or privs to be using replacer in a certain region.<br>
[Read more about this function in (replacer/constrain.lua)](replacer/constrain.lua)

### Enable Special Nodes
Register exceptions that don't rotate/colour using param1 and param2 by calling
```lua
replacer.register_exception(node_name, drop_name, callback)
```
* **node_name** is the name of the node user clicks on.
* **drop_name** is the name of the item to be taken from inventory.
* **callback** is an optional function that is called after **drop_name** has been placed.
This function can apply other changes or build structures around the placed node. Your
imagination is the limit. (Well computational resources too.)<br>
The callback signature is: ```f(pos, old_node_def, new_node_def, player_ref)```
[More details in (replacer/enable.lua)](replacer/enable.lua)

### Aliases
For players without **give** or **creative** priv, you can add aliases.
```lua
replacer.register_non_creative_alias('vines:jungle_middle', 'vines:jungle_end')
```
This allows users to click on "vines:jungle_middle" but set the replacer to "vines:jungle_end".
Many examples of these can be found in the "compat" directory.

### Enable Set Callbacks
Some nodes don't show up in crafting guide and the above methods don't suffice.<br>
To still enable these, you can register a callback function which is called
after several pre-checks have passed. The first callback to respond with something
other than **false** or **nil** allows the node to be used to set the replacer to.<br>
The callback signature is ```f(node, player_ref, pointed_thing)```
```lua
replacer.register_set_enabler(callback)
```
[More details in (replacer/enable.lua)](replacer/enable.lua)

## Overrides

Most functions are public and can be overridden.

### Creative priv check
Depending on game there may not be ```creative``` global and
its functions. Or you may want to give creative priv to some users
but only when they are using replacer. For this you can override
```replacer.has_creative(name)``` function returning a boolean value.
[Default located in (utils.lua)](utils.lua)

## Inspection Tool

### Adding craft methods
Some mods provide precesses that go beyond simple crafting, mixing or cooking. To provide
better support for those there is:
```lua
replacer.register_craft_method(uid, machine_itemstring, func_inspect, func_formspec)
```
* **uid** is a unique identifier for this method/mod. A good format is "mod_name:method_name".
* **machine_itemstring** is the node name that provides the service. It is used to lookup
the image displayed and the recipe of how to make the machine.
* **func_inspect** is a function that is called by the inspection tool when gathering
information for an item. It's signature is ```f(node_name, param2, recipes)``` and it
can manipulate **recipes** table adding more recipes.
* **func_formspec** is an optional function that is called when displaying the craft info.
The signature is ```f(recipe)``` where **recipe** is the recipe table **func_inspect** added.<br>
It returns a formspec string to be added to the main formspec.<br>
[It is defined in (inspect.lua)](inspect.lua)<br>
[Best examples of usage in (compat/technic.lua)](compat/technic.lua)

