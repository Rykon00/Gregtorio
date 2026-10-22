-- Spike #495: timing, one ore per tile, vein ids read back at the cell centres.
local VEINS = require("veins")
local ROLES = {primary = 1, secondary = 2, between = 3, sporadic = 4}
local KEY_MAT = {}
for _, v in ipairs(VEINS) do
  for role, r in pairs(ROLES) do KEY_MAT[8 * v.id + r] = v[role] end
end
local VEIN_NAME = {}
for _, v in ipairs(VEINS) do VEIN_NAME[v.id] = v.name end

local RADIUS = 8
local OFFSET = 0 -- chunks around the origin: (2R)^2 chunks
local out = {}
local function say(s) out[#out + 1] = s; log({"", "SPIKE ", s}) end

local function mgs_of(planet, overrides)
  local mgs = prototypes.space_location[planet].map_gen_settings
  -- the prototype returns a fresh table
  mgs.seed = 12345
  mgs.property_expression_names = mgs.property_expression_names or {}
  for k, v in pairs(overrides or {}) do mgs.property_expression_names[k] = v end
  return mgs
end

local function generate(name, planet, overrides)
  local s = game.create_surface(name, mgs_of(planet, overrides))
  local p = helpers.create_profiler()
  s.request_to_generate_chunks({0, 0}, RADIUS)
  s.force_generate_chunk_requests()
  p.stop()
  local n = 0
  for _ in s.get_chunks() do n = n + 1 end
  return s, p, n
end

local function check(s)
  local ents = s.find_entities_filtered{type = "resource"}
  local seen, dup, positions = {}, 0, {}
  for _, e in ipairs(ents) do
    local k = e.position.x .. "," .. e.position.y
    if seen[k] then dup = dup + 1 end
    seen[k] = true
    positions[#positions + 1] = {x = e.position.x + OFFSET, y = e.position.y + OFFSET}
  end
  local props = s.calculate_tile_properties({"gt_vein_key", "gt_band", "gt_vein_id"}, positions)
  local wrong, roles, mats = 0, {0, 0, 0, 0}, {}
  for i, e in ipairs(ents) do
    local id = props.gt_vein_id[i]
    local ok = false
    for r = 1, 4 do if "gt-spike-" .. tostring(KEY_MAT[8 * id + r]) == e.name then ok = true end end
    if not ok then wrong = wrong + 1 end
    local band = props.gt_band[i]
    local allowed = band <= 3 and {2, 4} or band == 4 and {3, 2, 4} or band == 5 and {3, 4} or band <= 7 and {1, 3, 4} or {1, 4}
    for _, r in ipairs(allowed) do
      if "gt-spike-" .. tostring(KEY_MAT[8 * id + r]) == e.name then roles[r] = roles[r] + 1; break end
    end
    mats[e.name] = (mats[e.name] or 0) + 1
  end
  local total = #ents
  say(string.format("%s: %d ore tiles, %d tiles with a second ore, %d with a material that is not in the vein of its cell",
    s.name, total, dup, wrong))
  say(string.format("%s: roles primary %.1f%% secondary %.1f%% between %.1f%% sporadic %.1f%%", s.name,
    100 * roles[1] / total, 100 * roles[2] / total, 100 * roles[3] / total, 100 * roles[4] / total))
  local list = {}
  for m, c in pairs(mats) do list[#list + 1] = m .. "=" .. c end
  table.sort(list)
  say(s.name .. ": " .. table.concat(list, " "))
end

local veins_out = {}
local function cells(s, size)
  -- cell centres in the generated area
  local positions = {}
  local lim = RADIUS * 32
  for cy = math.floor(-lim / size), math.floor((lim - 1) / size) do
    for cx = math.floor(-lim / size), math.floor((lim - 1) / size) do
      positions[#positions + 1] = {x = (cx + 0.5) * size, y = (cy + 0.5) * size}
    end
  end
  local props = s.calculate_tile_properties({"gt_vein_id", "gt_vein_cx", "gt_vein_cy", "gt_vein_r"}, positions)
  local counts, labels = {}, {}
  for i, pos in ipairs(positions) do
    local id = props.gt_vein_id[i]
    local name = VEIN_NAME[id] or "empty"
    counts[name] = (counts[name] or 0) + 1
    if id > 0 then
      local n = s.count_entities_filtered{type = "resource", position = {props.gt_vein_cx[i], props.gt_vein_cy[i]},
        radius = props.gt_vein_r[i]}
      veins_out[#veins_out + 1] = string.format("%s %s %.1f %d", s.name, name, props.gt_vein_r[i], n)
      labels[#labels + 1] = string.format("%s Vein at %.0f,%.0f r=%.1f", name, props.gt_vein_cx[i], props.gt_vein_cy[i],
        props.gt_vein_r[i])
      -- tile count of this vein (for the richness)
    end
  end
  local list = {}
  for m, c in pairs(counts) do list[#list + 1] = m .. "=" .. c end
  table.sort(list)
  say(string.format("%s: %d cells: %s", s.name, #positions, table.concat(list, " ")))
  for i = 1, math.min(6, #labels) do say(s.name .. ": label " .. labels[i]) end
end

local function tile_dump(s, half, file)
  -- one line per resource: x y material (for the pictures)
  local lines = {}
  for _, e in ipairs(s.find_entities_filtered{type = "resource", area = {{-half, -half}, {half, half}}}) do
    lines[#lines + 1] = string.format("%d %d %s", math.floor(e.position.x), math.floor(e.position.y), e.name)
  end
  helpers.write_file(file, table.concat(lines, "\n") .. "\n")
end

local function determinism(s, prop)
  prop = prop or "gt_u_tile"
  local pos = {}
  for i = 1, 200 do pos[i] = {x = i * 3 + 0.5, y = 7.5} end
  local a = s.calculate_tile_properties({prop, "gt_u_pick"}, pos)
  local diff, diffc = 0, 0
  for i = 1, 200 do
    local b = s.calculate_tile_properties({prop, "gt_u_pick"}, {pos[i]})
    if b[prop][1] ~= a[prop][i] then diff = diff + 1 end
    if b.gt_u_pick[1] ~= a.gt_u_pick[i] then diffc = diffc + 1 end
  end
  say(string.format(prop .. ": per tile random differs for %d of 200 positions between a batch and single queries, cell random for %d", diff, diffc))
end

script.on_init(function()
  -- the hidden planet makes its surface through LuaPlanet.create_surface (V5's way)
  local ok, err = pcall(function() return game.planets["gt-spike3"].create_surface() end)
  say("hidden planet create_surface: " .. tostring(ok) .. " " .. tostring(ok and err.name or err))

  local runs = {
    {"none", "gt-spike-none"}, {"vanilla", "gt-spike-vanilla"}, {"spike3", "gt-spike3"}, {"ow", "gt-spike-ow"},
    {"ow-det", "gt-spike-ow", {gt_u_tile = "gt_u_tile_vor"}},
    {"flat-none", "gt-flat-none"}, {"flat-vanilla", "gt-flat-vanilla"}, {"flat-ow", "gt-flat-ow"},
    {"flat-ow-det", "gt-flat-ow", {gt_u_tile = "gt_u_tile_vor"}},
  }
  local surfaces, times = {}, {}
  for rep = 1, 3 do
    for j = 1, #runs do
      local run = runs[(j + rep - 2) % #runs + 1]
      local s, p, n = generate("t" .. rep .. "-" .. run[1], run[2], run[3])
      times[run[1]] = times[run[1]] or {}
      table.insert(times[run[1]], p)
      surfaces[run[1]] = surfaces[run[1]] or s
      say({"", "time ", run[1], " ", n, " chunks: ", p})
    end
  end
  determinism(surfaces.spike3)
  check(surfaces.spike3)
  check(surfaces.ow)
  check(surfaces["ow-det"])
  determinism(surfaces["ow-det"], "gt_u_tile_vor")
  cells(surfaces.spike3, 128)
  cells(surfaces.ow, 128)

  -- pictures: cell sizes and empty weights on the three-vein planet
  for _, size in ipairs{96, 128, 160} do
    for _, empty in ipairs{"107", "320"} do
      local name = "pic-" .. size .. "-" .. empty
      local s = generate(name, "gt-spike3", {gt_cell_size = tostring(size), gt_empty_weight = empty})
      tile_dump(s, RADIUS * 32, "spike/" .. name .. ".txt")
      cells(s, size)
    end
  end
  local s = generate("pic-128-107-fill3", "gt-spike3", {gt_fill = "3", gt_empty_weight = "107"})
  tile_dump(s, RADIUS * 32, "spike/pic-128-107-fill3.txt")
  cells(s, 128)
  local s3 = generate("big-ow-fill1", "gt-flat-ow", {gt_u_tile = "gt_u_tile_vor"})
  cells(s3, 128)
  local s4 = generate("big-ow-fill3", "gt-flat-ow", {gt_u_tile = "gt_u_tile_vor", gt_fill = "3"})
  cells(s4, 128)
  check(s)
  local s2 = generate("pic-ow", "gt-spike-ow", {})
  tile_dump(s2, RADIUS * 32, "spike/pic-ow.txt")
  helpers.write_file("spike/veins.txt", table.concat(veins_out, "\n") .. "\n")
  helpers.write_file("spike/result.txt", "")
  for _, line in ipairs(out) do helpers.write_file("spike/result.txt", {"", line, "\n"}, true) end
end)
