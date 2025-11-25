data:extend({
  {
    type = "technology",
    name = "companion-tree-farming",
    icon = "__base__/graphics/technology/robotics.png",
    icon_size = 256,
    icon_mipmaps = 4,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "tree-farm-companion"
      }
    },
    prerequisites = {"electronics", "steel-processing"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 30
    },
    order = "c-a"
  }
})
