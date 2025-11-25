data:extend({
  {
    type = "int-setting",
    name = "companion_farm_radius",
    setting_type = "runtime-global",
    default_value = 50,
    minimum_value = 5,
    maximum_value = 128,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "companion_farm_harvesting",
    setting_type = "runtime-global",
    default_value = false,
    order = "b"
  }
})