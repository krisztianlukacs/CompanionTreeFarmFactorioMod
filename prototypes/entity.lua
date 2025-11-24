data:extend({
  {
    type = "container",
    name = "tree-farm-companion",
    icon = "__base__/graphics/icons/roboport.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "tree-farm-companion"},
    max_health = 300,
    corpse = "small-remnants",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
    inventory_size = 64,
    picture = {
      filename = "__base__/graphics/entity/roboport/roboport-base.png",
      width = 143,
      height = 135,
      shift = {0.5, 0.1},
      scale = 0.7
    },
    circuit_wire_connection_point = nil,
    circuit_connector_sprites = nil,
    circuit_wire_max_distance = 0
  }
})