-- Spike #495: GT ore veins as noise autoplace. Throwaway, not part of Gregtorio.
local VEINS = require("veins")
local SET3 = {[3] = true, [4] = true, [11] = true} -- Coal, Magnetite, Copper
local ROLES = {primary = 1, secondary = 2, between = 3, sporadic = 4}

-- materials -> list of vein keys (8 * vein id + role)
local keys, order = {}, {}
for _, v in ipairs(VEINS) do
  for role, r in pairs(ROLES) do
    local m = v[role]
    if not keys[m] then keys[m] = {}; order[#order + 1] = m end
    table.insert(keys[m], 8 * v.id + r)
  end
end
table.sort(order)

local COLORS = {
  coal = {0.1, 0.1, 0.1}, lignite = {0.45, 0.3, 0.15}, magnetite = {0.35, 0.4, 0.55}, iron = {0.75, 0.8, 0.95},
  ["vanadium-magnetite"] = {0.6, 0.2, 0.8}, chalcopyrite = {0.9, 0.5, 0.1}, pyrite = {0.95, 0.9, 0.2},
  copper = {1, 0.25, 0.15},
}
local function hashcolor(s)
  local h = 0
  for i = 1, #s do h = (h * 31 + s:byte(i)) % 16777216 end
  return {(h % 256) / 255, (math.floor(h / 256) % 256) / 255, (math.floor(h / 65536) % 256) / 255}
end

local function sum(list, f)
  local parts = {}
  for _, v in ipairs(list) do
    local t = f(v)
    if t then parts[#parts + 1] = t end
  end
  return #parts > 0 and table.concat(parts, " + ") or "0"
end

-- per-cell uniform value in [0, 1], seeded by the map seed
local function cell_rand(seed)
  return "voronoi_cell_id{x = (gt_cell_x + 0.25) * gt_cell_size, y = (gt_cell_y + 0.25) * gt_cell_size, seed0 = map_seed, seed1 = "
    .. seed .. ", grid_size = gt_cell_size, distance_type = 'euclidean', jitter = 0}"
end

local function vein_pick(list, start)
  -- cumulative weights of the surface plus the empty weight
  local total = 0
  for _, v in ipairs(list) do total = total + v.weight end
  local expr, acc = "0", 0
  local parts = {}
  for _, v in ipairs(list) do
    acc = acc + v.weight
    parts[#parts + 1] = {acc, v.id}
  end
  for i = #parts, 1, -1 do
    expr = "if(gt_u_pick * (" .. total .. " + gt_empty_weight) < " .. parts[i][1] .. ", " .. parts[i][2] .. ", " .. expr .. ")"
  end
  -- start area: the four cells around the origin hold fixed veins
  return "if(gt_start_cell > 0, gt_start_cell - 1, " .. expr .. ")", total
end

local list3, listow = {}, {}
for _, v in ipairs(VEINS) do
  if v.ow then listow[#listow + 1] = v end
  if SET3[v.id] then list3[#list3 + 1] = v end
end
local pick3 = vein_pick(list3)
local pickow = vein_pick(listow)

local expressions = {
  gt_cell_size = "128",
  gt_empty_weight = "100",
  gt_fill = "1",
  gt_ore_amount = "1000",
  gt_cell_x = "floor(x / gt_cell_size)",
  gt_cell_y = "floor(y / gt_cell_size)",
  gt_u_pick = cell_rand(1),
  gt_u_radius = cell_rand(2),
  gt_u_ox = cell_rand(3),
  gt_u_oy = cell_rand(4),
  gt_u_angle = cell_rand(5),
  -- 1 + vein id for the four start cells (Magnetite NW, Copper NE, Coal SW, empty SE), else 0
  gt_start_cell = "(gt_cell_y == -1) * ((gt_cell_x == -1) * 5 + (gt_cell_x == 0) * 12) + (gt_cell_y == 0) * (gt_cell_x == -1) * 4",
  gt_vein_id = pickow,
  ["gt-vein-id-spike3"] = pick3,
  ["gt-vein-id-ow"] = pickow,
  gt_vein_size = sum(VEINS, function(v) return "(gt_vein_id == " .. v.id .. ") * " .. v.size end),
  gt_vein_density = sum(VEINS, function(v) return "(gt_vein_id == " .. v.id .. ") * " .. v.density end),
  gt_vein_r = "(16 + gt_u_radius * 2 * gt_vein_size) / 2",
  gt_vein_free = "max(0, gt_cell_size / 2 - gt_vein_r - 2)",
  gt_vein_cx = "(gt_cell_x + 0.5) * gt_cell_size + (gt_u_ox * 2 - 1) * gt_vein_free",
  gt_vein_cy = "(gt_cell_y + 0.5) * gt_cell_size + (gt_u_oy * 2 - 1) * gt_vein_free",
  gt_dx = "x - gt_vein_cx",
  gt_dy = "y - gt_vein_cy",
  gt_d = "pow(gt_dx * gt_dx + gt_dy * gt_dy, 0.5)",
  gt_t = "gt_dx * sin(gt_u_angle * pi + pi / 2) + gt_dy * sin(gt_u_angle * pi)",
  gt_band = "clamp(floor((gt_t + gt_vein_r) / (2 * gt_vein_r) * 9), 0, 8) + 1",
  -- GT: density falls off by chunks from the seed, chance = distance to the far edge / density
  gt_dens_local = "max(1, floor(gt_vein_density / floor(pow(2 + (gt_d / 16) * (gt_d / 16), 0.5))))",
  gt_px = "1 / max(1, floor((gt_vein_r + abs(gt_dx)) / gt_dens_local))",
  gt_py = "1 / max(1, floor((gt_vein_r + abs(gt_dy)) / gt_dens_local))",
  gt_p = "min(1, gt_fill * (1 - (1 - gt_px) * (1 - gt_py)))",
  gt_u_tile = "1 - random_penalty{x = x, y = y, seed = 7, source = 1, amplitude = 1}",
  -- deterministic per tile: a voronoi cell per tile
  gt_u_tile_vor = "voronoi_cell_id{x = x + 0.25, y = y + 0.25, seed0 = map_seed, seed1 = 7, grid_size = 1, distance_type = 'euclidean', jitter = 0}",
  -- bands 1-3 secondary, 4 between/secondary, 5 between, 6-7 primary/between, 8-9 primary
  gt_first = "if(gt_band <= 3, 2, if(gt_band <= 5, 3, 1))",
  gt_second = "if(gt_band == 4, 2, if(gt_band >= 6, if(gt_band <= 7, 3, 0), 0))",
  gt_role_raw = "if(gt_u_tile < gt_p, gt_first, if(gt_second > 0, \z
    if(gt_u_tile < gt_p + (1 - gt_p) * gt_p, gt_second, \z
      if(gt_u_tile < gt_p + (1 - gt_p) * gt_p + (1 - gt_p) * (1 - gt_p) * gt_p / 7, 4, 0)), \z
    if(gt_u_tile < gt_p + (1 - gt_p) * gt_p / 7, 4, 0)))",
  gt_role = "gt_role_raw * (gt_d < gt_vein_r) * (gt_vein_id > 0)",
  gt_vein_key = "gt_vein_id * 8 + gt_role",
}
for name, expr in pairs(expressions) do
  data:extend{{type = "noise-expression", name = name, expression = expr}}
end

local base = data.raw.resource["iron-ore"]
local resources = {}
for _, m in ipairs(order) do
  local r = table.deepcopy(base)
  r.name = "gt-spike-" .. m
  r.localised_name = m
  r.map_color = COLORS[m] or hashcolor(m)
  r.minable.result = "iron-ore"
  r.minable.results = nil
  local terms = {}
  for _, k in ipairs(keys[m]) do terms[#terms + 1] = "(gt_vein_key == " .. k .. ")" end
  r.autoplace = {
    probability_expression = table.concat(terms, " + "),
    richness_expression = "gt_ore_amount",
  }
  r.stages = base.stages
  data:extend{r}
  resources[m] = r.name
end

local nauvis = data.raw.planet.nauvis
local VANILLA_RES = {"iron-ore", "copper-ore", "stone", "coal", "uranium-ore", "crude-oil"}
local function planet(name, set, vein_expr, hidden, flat)
  local mgs = table.deepcopy(nauvis.map_gen_settings)
  if flat then
    mgs.autoplace_settings.tile.settings = {["grass-1"] = {}}
    mgs.autoplace_settings.decorative.settings = {}
    for n in pairs(mgs.autoplace_settings.entity.settings) do
      if not data.raw.resource[n] then mgs.autoplace_settings.entity.settings[n] = nil end
    end
    mgs.cliff_settings = {name = "cliff", cliff_elevation_0 = 1000, cliff_elevation_interval = 1000, richness = 0}
    mgs.autoplace_controls.trees = nil; mgs.autoplace_controls.rocks = nil; mgs.autoplace_controls.water = nil
  end
  mgs.autoplace_controls["enemy-base"] = nil
  mgs.autoplace_settings.entity.settings["enemy-base"] = nil
  for name2 in pairs(mgs.autoplace_settings.entity.settings) do
    if data.raw["unit-spawner"][name2] or data.raw.turret[name2] then mgs.autoplace_settings.entity.settings[name2] = nil end
  end
  if set ~= "vanilla" then
    for _, r in ipairs(VANILLA_RES) do
      mgs.autoplace_controls[r] = nil
      mgs.autoplace_settings.entity.settings[r] = nil
    end
  end
  if set then
    local mats = {}
    for _, v in ipairs(set == "vanilla" and {} or set) do
      for role in pairs(ROLES) do mats[v[role]] = true end
    end
    for m in pairs(mats) do mgs.autoplace_settings.entity.settings[resources[m]] = {} end
  end
  mgs.property_expression_names = mgs.property_expression_names or {}
  if vein_expr then mgs.property_expression_names.gt_vein_id = vein_expr end
  data:extend{{
    type = "planet", name = name, icon = nauvis.icon, icon_size = nauvis.icon_size, starmap_icon = nauvis.starmap_icon,
    starmap_icon_size = nauvis.starmap_icon_size, distance = 30, orientation = 0.5, hidden = hidden,
    map_gen_settings = mgs, surface_properties = table.deepcopy(nauvis.surface_properties),
  }}
end
planet("gt-spike3", list3, "gt-vein-id-spike3", true)
planet("gt-spike-ow", listow, "gt-vein-id-ow", false)
planet("gt-spike-none", nil, nil, false)
planet("gt-spike-vanilla", "vanilla", nil, false)
planet("gt-flat-ow", listow, "gt-vein-id-ow", false, true)
planet("gt-flat-none", nil, nil, false, true)
planet("gt-flat-vanilla", "vanilla", nil, false, true)

log("SPIKE materials " .. #order)
