### Metatool namespace keys for internal use, these should not be used directly

```
metatool.configuration_file
metatool.export_default_config
metatool.modpath
metatool.S
metatool.tools
metatool.privileged_tools
```

### Tool definition

`tool:on_read_node(player, pointed_thing, node, pos, nodedef)`
If defined this will be called instead of node definition `copy` method.
Return value should be `data, group, description`.

`tool:on_write_node(tooldata, group, player, pointed_thing, node, pos, nodedef)`
If defined this will be called instead of node definition `paste` method.
Return value is currently ignored.

`tool:on_read_info(player, pointed_thing, node, pos, nodedef, itemstack)`
If defined this will be called instead of node definition `info` method.
Return value is currently ignored.

### Node definition for tool

`definition:copy(node, pos, player)`
If defined then tool can read data when this node group is targeted.
This method should be used to read world state like check nodes,
read node metadata, display formspecs, etc. final actions.
Return value should contain data that will be stored to tool memory.

`definition:paste(node, pos, player, data)`
If defined then tool can apply data when this node group is targeted.
This method should be used to update world state like swap/set/remove
nodes, update node metadata, display formspecs, etc. final actions.
Return value is currently ignored.

`definition:info(node, pos, player, itemstack)`
If defined then tool can read extended info when this node group is targeted.
This method should be used to display extended information or handle special
actions like displaying more complex formspecs or possibly add additional
data into tool memory.
Return value is currently ignored.

`definition:before_read(pos, player)`
Optional. Overrides default protection checks if defined.
Called before `definition:copy`, should return:
* `true`: To continue processing and call `copy` method.
* `false`: To stop processing and not call `copy` method.

`definition:before_write(pos, player)`
Optional. Overrides default protection checks if defined.
Called before `definition:paste`, should return:
* `true`: To continue processing and call `paste` method.
* `false`: To stop processing and not call `paste` method.

`definition:before_info(pos, player)`
Optional. Overrides default protection checks if defined.
Called before `definition:info`, should return:
* `true`: To continue processing and call `info` method.
* `false`: To stop processing and not call `info` method.

### Metatool API methods

`metatool.settings(toolname[, key])`
Return settings for tool, either `nil`, `table` or value if key is given.
If optional key is given then return value of given key from tool configuration.

`metatool.merge_tool_settings(name, tooldef)`
Internal method to merge settings and push merged settings into tool definition.
Not meant to be used directly, will be called through `metatool:register_tool`.

`metatool.check_privs(player, privs)`
Check if player has privs, return boolean.

`metatool.is_protected(pos, player, privs, no_violation_record)`
Check if position is protected.

`metatool.before_read(nodedef, pos, player, no_violation_record)`
Default `before_read` method for registered nodes

`metatool.before_write(nodedef, pos, player, no_violation_record)`
Default `before_write` method for registered nodes.

`metatool.before_info(nodedef, pos, player, no_violation_record)`
Default `before_info` method for registered nodes

`metatool.write_data(itemstack, data, description)`
Write tool metadata.

`metatool.read_data(itemstack)`
Read and return tool metadata.

`metatool:on_use(toolname, itemstack, player, pointed_thing)`
Default `on_use` method for registered tools.

`metatool:register_tool(name, definition)`
Tool registration method, returns tool definition assembly.

`metatool:register_node(toolname, name, definition, override)`
Node registration method, this method will probably change or will be removed in future.
Do not use directly, instead use `tool:load_node_definition`.

`metatool.get_node(tool, player, pointed_thing)`
Get node from world, checks node compatibility and protections.
Returns either `nil` or indexed table containing node, pos, definition.

### Metatool API methods for registered tools

`tool:load_node_definition(def)`
Loads new node definition for registered tool.
