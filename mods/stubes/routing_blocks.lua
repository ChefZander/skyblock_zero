-- Group: `stube_routing_node`=1
-- Transport is handled in stube_transport.lua

---@class stube.RoutingState: table
---@field items { [any]: stube.TubedItem } Routing nodes can organize items hovewer they like
---@field updated_at number
---@field to_remove? boolean

---@class stube.RoutingNodeDef
---@field update fun(state:stube.RoutingState, hpos: number):nil
---@field accept fun(state:stube.RoutingState, tubed_item:stube.TubedItem, dir: table):boolean
---@field speed number Delay between updates, but routing nodes always update after tubes

---@type { [string]: stube.RoutingNodeDef }
stube.registered_routing_node = {}

function stube.register_routing_node(name, def, routing_def)
    stube.registered_routing_node[name] = routing_def
    core.register_node(name, def)
end
