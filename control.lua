local TICKS_PER_CYCLE = 60            -- 1 másodperc
local MAX_HARVEST_PER_CYCLE = 20     -- max ennyi fát vág ki egyszerre
local MAX_PLANT_PER_CYCLE = 20       -- max ennyi fát ültet egyszerre

local function get_farm_radius()
  return settings.global["companion_farm_radius"].value
end

local function is_harvesting_enabled()
  return settings.global["companion_farm_harvesting"].value
end

local function init_globals()
  storage.companions = storage.companions or {}
end

script.on_init(init_globals)
script.on_configuration_changed(init_globals)

-- Companion regisztrálása
local function register_companion(entity)
  if not (entity and entity.valid) then return end
  storage.companions = storage.companions or {}
  table.insert(storage.companions, { entity = entity })
end

local function unregister_companion(entity)
  if not (storage.companions and entity) then return end
  for i = #storage.companions, 1, -1 do
    local c = storage.companions[i]
    if not c.entity.valid or c.entity == entity then
      table.remove(storage.companions, i)
    end
  end
end

-- Építés eventek
local function on_built_entity(event)
  local ent = event.created_entity or event.entity
  if ent and ent.valid and ent.name == "tree-farm-companion" then
    register_companion(ent)
  end
end

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)
script.on_event(defines.events.script_raised_built, on_built_entity)

-- Eltávolítás eventek
local function on_entity_removed(event)
  local ent = event.entity
  if ent and ent.valid and ent.name == "tree-farm-companion" then
    unregister_companion(ent)
  end
end

script.on_event(defines.events.on_pre_player_mined_item, on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed)
script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

--------------------------------------------------
-- ARATÁS
--------------------------------------------------
local function harvest_trees(surface, pos, radius, companion)
  local inv = companion.get_inventory(defines.inventory.chest)
  if not inv then return end

  local area = {
    {pos.x - radius, pos.y - radius},
    {pos.x + radius, pos.y + radius}
  }

  local trees = surface.find_entities_filtered{
    area = area,
    type = {"tree"}
  }

  local harvested = 0

  for _, tree in ipairs(trees) do
    if not tree.to_be_deconstructed(tree.force) then
      local products = tree.prototype.mineable_properties.products
      
      if products then
        for _, p in pairs(products) do
          local amount = 0
          
          -- Handle probability
          if p.probability and math.random() > p.probability then
             goto continue
          end

          -- Handle amount min/max or fixed amount
          if p.amount_min and p.amount_max then
            amount = math.random(p.amount_min, p.amount_max)
          elseif p.amount then
            amount = p.amount
          else
            amount = 1 -- Fallback
          end

          if p.name and amount > 0 then
            inv.insert{
              name = p.name,
              count = amount
            }
          end
          
          ::continue::
        end
      end
      
      tree.destroy()

      harvested = harvested + 1
      if harvested >= MAX_HARVEST_PER_CYCLE then
        break
      end
    end
  end
end

--------------------------------------------------
-- ÜLTETÉS
--------------------------------------------------
-- Egyszerű, determinisztikus "rácsos" ültetés:
-- a companion körül 2 tile-es lépésközzel nézünk ültethető helyeket.

local function plant_trees(surface, pos, radius, companion)
  local inv = companion.get_inventory(defines.inventory.chest)
  if not inv then return end

  local seed_stack = inv.find_item_stack("tree-seed")
  if not seed_stack then return end

  local planted = 0

  local x_min = math.floor(pos.x - radius)
  local x_max = math.floor(pos.x + radius)
  local y_min = math.floor(pos.y - radius)
  local y_max = math.floor(pos.y + radius)

  -- lépésköz: 2 tile, hogy ne legyen túl sűrű
  local step = 2

  -- Random offset to avoid planting in the same order every time
  local offset_x = math.random(0, 1)
  local offset_y = math.random(0, 1)

  for y = y_min + offset_y, y_max, step do
    for x = x_min + offset_x, x_max, step do
      if seed_stack.count <= 0 then
        return
      end

      local dx = x + 0.5 - pos.x
      local dy = y + 0.5 - pos.y
      if (dx * dx + dy * dy) <= (radius * radius) then
        local p = {x + 0.5, y + 0.5}

        -- Check if we can place the entity and if there are no other trees too close
        if surface.can_place_entity{name = "tree-01", position = p} then
             -- Double check for existing trees in a small radius to prevent super dense clumping if grid aligns perfectly
             if surface.count_entities_filtered{position = p, radius = 0.8, type = "tree"} == 0 then
                  surface.create_entity{
                    name = "tree-01",    -- vanilla fa típus, később lecserélheted saját növényre
                    position = p,
                    force = companion.force
                  }

                  seed_stack.count = seed_stack.count - 1
                  planted = planted + 1

                  if planted >= MAX_PLANT_PER_CYCLE then
                    return
                  end
             end
        end
      end
    end
  end
end

--------------------------------------------------
-- FŐ CIKLUS
--------------------------------------------------
local function process_companion(companion_data, radius)
  local e = companion_data.entity
  if not (e and e.valid) then return end

  local surface = e.surface
  local pos = e.position

  if is_harvesting_enabled() then
    harvest_trees(surface, pos, radius, e)
  end
  plant_trees(surface, pos, radius, e)
end

script.on_nth_tick(TICKS_PER_CYCLE, function(event)
  if not storage.companions then return end
  local radius = get_farm_radius()

  for i = #storage.companions, 1, -1 do
    local c = storage.companions[i]
    if not (c.entity and c.entity.valid) then
      table.remove(storage.companions, i)
    else
      process_companion(c, radius)
    end
  end
end)