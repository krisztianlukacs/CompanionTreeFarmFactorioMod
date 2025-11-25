data:extend({
  {
    type = "recipe",
    name = "tree-farm-companion",
    enabled = false,
    ingredients = {
      {type="item", name="steel-plate", amount=20},
      {type="item", name="electronic-circuit", amount=20},
      {type="item", name="iron-gear-wheel", amount=10}
    },
    results = {
      {type="item", name="tree-farm-companion", amount=1}
    }
  },
  {
    type = "recipe",
    name = "tree-seed",
    enabled = false,
    hidden = true,
    -- pl. 1 wood -> 2 seed
    ingredients = {
      {type="item", name="wood", amount=1}
    },
    results = {
      {type="item", name="tree-seed", amount=2}
    }
  }
})