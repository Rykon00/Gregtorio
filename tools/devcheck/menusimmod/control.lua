--- Runs one main menu simulation the way the main menu does: devcheck.py loads the simulation's save
--- with --benchmark for the simulation's length, this mod runs its init chunk once (first tick) and its
--- update chunk every tick. `game.simulation` (the menu camera) only exists in the menu; the chunks get a
--- stand-in for it. An error in a chunk or in a handler it registers stops the benchmark like it stops
--- the menu. Results are logged as DEVCHECK-MENUSIM lines: the force bonuses and the armor of every
--- character at the start, every second the characters (health, shields, equipment energy, enemies
--- around, damage taken by type and source) and every character death with its cause.
--- Issue #588, for Gregtorio's own scenes (config.expect, from tools/menusim/<name>.json): the entities of the save that
--- the load lost (FAIL), and every 30 ticks the machines in the camera's view (the init chunk sets the camera; the view
--- of 1920 x 1080 pixels): FAIL for a machine that runs out of fuel, water or steam or blocks on a full output, and for
--- a scene whose machines in view work less than half as much in its last 5 seconds as in its first. Issue #599: FAIL
--- when the save has a player (the menu draws its GUI over the scene) or a chunk in the view of a 3840 x 2160 screen is
--- not generated (the menu shows it black).
--- config.count_only: only log the counts by name of the player force's entities (DEVCHECK-MENUSIM COUNTS <json>), for
--- `devcheck.py menusim --rebuild` with the mod versions the save was made with.
local config = require("config")
local sim = prototypes.mod_data["zz-gregtorio-devcheck-menusim"].data[config.name]

local function out(s) log("DEVCHECK-MENUSIM " .. s) end

-- the camera the chunks set (this mod reads it here; the chunks read it through the stand-in, camera_stub)
local camera_values
-- LuaSimulation keys a chunk can write but not read (Factorio 2.1 API): a read stops the scene in the menu (issue #597)
local WRITE_ONLY = { camera_zoom = true, camera_alt_info = true, camera_player = true,
  camera_player_cursor_direction = true }

local function player_counts()
  local by = {}
  for _, surface in pairs(game.surfaces) do
    for _, e in pairs(surface.find_entities_filtered({ force = "player" })) do
      -- (not the characters: a player's character is on the map only while the player is connected)
      if e.type ~= "character" then by[e.name] = (by[e.name] or 0) + 1 end
    end
  end
  return by
end

local function check_entities()
  local have, lost, total = player_counts(), {}, 0
  for name, n in pairs(config.expect) do
    if (have[name] or 0) < n then lost[#lost + 1] = string.format("%s %d of %d", name, have[name] or 0, n) end
  end
  for _, n in pairs(have) do total = total + n end
  table.sort(lost)
  out(string.format("entities: %d of the player force, %d names expected, %d lost", total, table_size(config.expect), #lost))
  if #lost > 0 then out("FAIL entities lost in the load: " .. table.concat(lost, ", ")) end
end

local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end
-- statuses of a machine that stopped for want of fuel, water or steam or with a full output (an inserter only: no fuel)
local STOPPED = { no_fuel = true, no_input_fluid = true, low_input_fluid = true, full_output = true,
  full_burnt_result_output = true, waiting_for_space_in_destination = true, no_minable_resources = true }
local VIEW_TYPES = { "assembling-machine", "furnace", "boiler", "mining-drill", "lab", "inserter", "generator",
  "offshore-pump", "reactor", "burner-generator" }
local view

local function start_view(t0)
  local p, z = camera_values.camera_position, camera_values.camera_zoom
  local w, h = 30 / z, 16.875 / z
  view = { t0 = t0, area = { { p.x - w, p.y - h }, { p.x + w, p.y + h } }, centre = p, zoom = z,
    first = { 0, 0 }, last = { 0, 0 }, worked = {}, failed = {}, machines = 0, done = false }
  -- issue #599: the chunks a 3840 x 2160 screen shows must be in the save
  local surface, missing = game.surfaces[camera_values.camera_surface_index], {}
  for cx = math.floor((p.x - 2 * w) / 32), math.floor((p.x + 2 * w) / 32) do
    for cy = math.floor((p.y - 2 * h) / 32), math.floor((p.y + 2 * h) / 32) do
      if not surface.is_chunk_generated({ cx, cy }) then missing[#missing + 1] = cx .. "," .. cy end
    end
  end
  if #missing > 0 then
    out("FAIL chunks in the view of a 3840 x 2160 screen are not in the save (black in the menu): " .. table.concat(missing, " "))
  end
end

local function sample_view()
  local t = game.tick - view.t0
  local working, n, never = 0, 0, 0
  for _, e in pairs(game.surfaces[camera_values.camera_surface_index].find_entities_filtered({ area = view.area,
      force = "player", type = VIEW_TYPES })) do
    n = n + 1
    local st = STATUS[e.status] or tostring(e.status)
    if st == "working" then
      working = working + 1
      view.worked[e.unit_number] = true
    elseif (e.type == "inserter" and st == "no_fuel") or (e.type ~= "inserter" and STOPPED[st]) then
      if not view.failed[e.unit_number] then
        view.failed[e.unit_number] = true
        out(string.format("FAIL tick %d of the scene: %s at %.1f,%.1f in view: %s", t, e.name, e.position.x, e.position.y, st))
      end
    end
    if not view.worked[e.unit_number] then never = never + 1 end
  end
  view.machines = n
  if t <= 300 then view.first = { view.first[1] + working, view.first[2] + 1 } end
  if t >= config.ticks - 300 then view.last = { view.last[1] + working, view.last[2] + 1 } end
  if t + 30 >= config.ticks and not view.done then
    view.done = true
    local first, last = view.first[1] / math.max(view.first[2], 1), view.last[1] / math.max(view.last[2], 1)
    out(string.format("view at %.1f,%.1f zoom %.2f: %d machines, %.1f working in the first 5 s, %.1f in the last 5 s "
      .. "(average), %d never worked", view.centre.x, view.centre.y, view.zoom, n, first, last, never))
    if last < first / 2 then out("FAIL the machines in view work less than half as much at the end as at the start") end
  end
end

local function camera_stub()
  camera_values = { camera_position = { x = 0, y = 0 }, camera_zoom = 1, camera_surface_index = 1 }
  return setmetatable({}, {
    __index = function(_, k)
      if WRITE_ONLY[k] then error("LuaSimulation doesn't contain key " .. k .. ".", 2) end
      return camera_values[k]
    end,
    __newindex = function(_, k, v)
      if k == "camera_position" then v = { x = v.x or v[1], y = v.y or v[2] } end
      camera_values[k] = v
    end,
  })
end

local function compile(code, name)
  if not code or code == "" then return nil end
  local f, err = load(code:gsub("game%.simulation", "__menusim_camera"), "=" .. name)
  if not f then error(name .. " does not compile: " .. err) end
  return f
end

local function characters()
  local list = {}
  for _, surface in pairs(game.surfaces) do
    for _, c in pairs(surface.find_entities_filtered({ type = "character" })) do list[#list + 1] = c end
  end
  return list
end

local function grid_of(c)
  local inv = c.get_inventory(defines.inventory.character_armor)
  local stack = inv and inv[1]
  return stack and stack.valid_for_read and stack.grid or nil
end

local function describe_armor(c)
  local grid = grid_of(c)
  if not grid then return "no armor grid" end
  local counts, names = {}, {}
  for _, e in pairs(grid.equipment) do
    if not counts[e.name] then names[#names + 1] = e.name end
    counts[e.name] = (counts[e.name] or 0) + 1
  end
  table.sort(names)
  local parts = {}
  for _, n in ipairs(names) do parts[#parts + 1] = n .. "=" .. counts[n] end
  return string.format("grid %dx%d, %s; max shield %.0f, max energy %.0f kJ", grid.width, grid.height,
    table.concat(parts, " "), grid.max_shield, (grid.battery_capacity) / 1000)
end

local damage = {}   -- [unit_number] = { ["type/source"] = amount } since the last report

local function report_state()
  for _, c in pairs(characters()) do
    local grid = grid_of(c)
    local enemies = c.surface.count_entities_filtered({ position = c.position, radius = 20, force = "enemy", type = { "unit", "turret", "unit-spawner" } })
    local taken = {}
    for key, amount in pairs(damage[c.unit_number] or {}) do taken[#taken + 1] = string.format("%s %.0f", key, amount) end
    table.sort(taken)
    damage[c.unit_number] = nil
    out(string.format("tick=%d character=%d force=%s pos=%.1f,%.1f health=%.0f/%.0f shield=%.0f/%.0f energy=%.0f/%.0f kJ enemies(20)=%d damage=[%s]",
      game.tick, c.unit_number, c.force.name, c.position.x, c.position.y, c.health, c.max_health,
      grid and grid.shield or 0, grid and grid.max_shield or 0,
      grid and grid.available_in_batteries / 1000 or 0, grid and grid.battery_capacity / 1000 or 0,
      enemies, table.concat(taken, ", ")))
  end
end

local function report_start()
  local force = game.forces.player
  local researched = 0
  for _, t in pairs(force.technologies) do if t.researched then researched = researched + 1 end end
  local bonuses = {}
  for name in pairs(prototypes.ammo_category) do
    local d, s = force.get_ammo_damage_modifier(name), force.get_gun_speed_modifier(name)
    if d ~= 0 or s ~= 0 then bonuses[#bonuses + 1] = string.format("%s damage +%.0f%% speed +%.0f%%", name, d * 100, s * 100) end
  end
  table.sort(bonuses)
  out(string.format("start: %d of %d technologies researched, character health bonus %d, enemy evolution %.2f, peaceful %s",
    researched, #force.technologies, force.character_health_bonus, game.forces.enemy.get_evolution_factor(1),
    tostring(game.surfaces[1].peaceful_mode)))
  out("bonuses: " .. (#bonuses > 0 and table.concat(bonuses, "; ") or "none"))
  for _, c in pairs(characters()) do
    out(string.format("character=%d force=%s max health %.0f, %s", c.unit_number, c.force.name, c.max_health, describe_armor(c)))
  end
end

local update

local function register_logging()
  script.on_nth_tick(60, report_state)
  script.on_nth_tick(1, function()
    if update then update() end
    if view and (game.tick - view.t0) % 30 == 0 then sample_view() end
  end)
  local character = { { filter = "type", type = "character" } }
  if not script.get_event_handler(defines.events.on_entity_damaged) then
    script.on_event(defines.events.on_entity_damaged, function(e)
      local per = damage[e.entity.unit_number] or {}
      damage[e.entity.unit_number] = per
      local key = e.damage_type.name .. "/" .. (e.cause and e.cause.valid and e.cause.name or "?")
      per[key] = (per[key] or 0) + e.final_damage_amount
    end, character)
  end
  if not script.get_event_handler(defines.events.on_entity_died) then
    script.on_event(defines.events.on_entity_died, function(e)
      out(string.format("DIED tick=%d character=%d force=%s cause=%s damage=%s", game.tick, e.entity.unit_number,
        e.entity.force.name, e.cause and e.cause.valid and e.cause.name or "?", e.damage_type and e.damage_type.name or "?"))
    end, character)
  end
end

local function start()
  __menusim_camera = camera_stub()
  local init = compile(sim.init, "init")
  update = compile(sim.update, "update")
  if config.expect then
    check_entities()
    -- issue #599: the menu draws a player's GUI (quickbar, shortcut bar) over the scene
    if #game.players > 0 then out(string.format("FAIL the save has %d players: rebuild it (resave.lua removes them)", #game.players)) end
  end
  if init then init() end
  if config.expect then start_view(game.tick) end
  if game.finished or game.finished_but_continuing then
    -- the menu keeps running a simulation after a win (its scripts too), the benchmark does not
    out("game finished by the init chunk; state reset to running, as in the menu")
    game.set_game_state({ game_finished = false })
  end
  register_logging()
  report_start()
  out("init done")
end

script.on_init(function()
  if config.count_only then
    script.on_nth_tick(1, function()
      script.on_nth_tick(1, nil)
      out("COUNTS " .. helpers.table_to_json(player_counts()))
    end)
    return
  end
  if not sim then
    out("FAIL simulation " .. config.name .. " is not in main_menu_simulations")
    return
  end
  -- the menu runs the init chunk once the save is loaded, so after the mods' on_init and
  -- on_configuration_changed (Gregtorio's resets the technology effects there): on the first tick
  script.on_nth_tick(1, start)
end)
