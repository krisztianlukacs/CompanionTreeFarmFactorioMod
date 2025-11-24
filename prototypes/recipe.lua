data:extend({
  {
    type = "recipe",
    name = "tree-farm-companion",
    enabled = true,
    ingredients = {
      {"steel-plate", 10},
      {"electronic-circuit", 10},
      {"iron-gear-wheel", 5}
    },
    result = "tree-farm-companion"
  },
  {
    type = "recipe",
    name = "tree-seed",
    enabled = true,
    -- pl. 1 wood -> 2 seed
    ingredients = {
      {"wood", 1}
    },
    result = "tree-seed",
    result_count = 2
  }
})