--- Fork: main menu simulations (PR #65), loaded from data-final-fixes.lua after the vanilla techs are disabled.
--- Issue #588 adds Gregtorio's own scenes (first section). Several vanilla menu simulations call
--- research_all_technologies() and rely on the bonuses it gives:
--- "nauvis_biter_base_laser_defense" walks a character in power armor through a biter base and survives
--- on the laser damage (+300 %), laser shooting speed (+220 %) and health (+50) bonuses. Gregtorio disables
--- those vanilla techs (disable_tech in data-final-fixes.lua: hidden, no effects) and
--- research_all_technologies() skips disabled techs, so the character got no bonus, died, and the
--- simulation's on_tick script, which reads character.position without a validity check, stopped the
--- main menu with "LuaEntity was invalid". Every simulation that calls research_all_technologies() now
--- gets the bonuses of the disabled techs right after that call, so it runs as in vanilla.
--- Check: `python tools/devcheck/devcheck.py menusim --sim all --compare`.

local simulations = data.raw["utility-constants"]["default"].main_menu_simulations
if not simulations then return end

-- GREGTORIO'S OWN SCENES (issue #588). A scene's save is a map of this mod, saved again by
-- `devcheck.py menusim --sim <name> --rebuild` with today's mods (tools/menusim/: its chunks cut to the factory, the
-- builder's blueprint library and the replay removed). The menu loads the save with the mods as they are, runs `init`
-- once and `update` every tick, and loads the save again after `length` ticks. Vanilla's Nauvis scenes stay in the
-- rotation next to these (the maintainer's choice in #588); Gregtorio's are registered more than once (end of this
-- section, issue #591).

-- The steam age, built in the map editor by achilles155: coal boilers, steam macerators, forge hammers, alloy smelters,
-- furnaces and crafting tables on one bus. The camera looks at the bus junction east of the forge hammers (the save's
-- player-built entities span -91,-78 to 126,68; zoom 1 shows 60 x 34 tiles at 1920 x 1080). `update` keeps the
-- machines near the camera busy: once a second it tops up the fuel of a burner that burnt its last item, empties a
-- crafting machine whose output is full and gives a crafting machine short of its ingredients one craft's worth (the
-- factory has more forge hammers than its macerators feed).
simulations.gregtorio_steam_age = {
	checkboard = false,
	save = "__gregtorio-continued__/menu-simulations/gregtech-steam-age.zip",
	length = 60 * 20,
	init = [[
    game.simulation.camera_position = {58, -3}
    game.simulation.camera_zoom = 1
    game.tick_paused = false
    game.surfaces.nauvis.daytime = 0
  ]],
	update = [[
    if game.tick % 60 ~= 0 then return end
    local p, z = game.simulation.camera_position, game.simulation.camera_zoom
    local w, h = 48 / z, 27 / z
    local crafter = { ["assembling-machine"] = true, furnace = true }
    for _, e in pairs(game.surfaces.nauvis.find_entities_filtered({ force = "player",
      area = { { p.x - w, p.y - h }, { p.x + w, p.y + h } },
      type = { "assembling-machine", "furnace", "inserter", "lab", "boiler", "mining-drill" } })) do
      local burner = e.burner
      if burner and burner.currently_burning and burner.inventory.is_empty() then
        burner.inventory.insert({ name = burner.currently_burning.name.name, count = 5 })
      end
      if crafter[e.type] then
        local status = e.status
        if status == defines.entity_status.full_output then
          e.get_output_inventory().clear()
        elseif status == defines.entity_status.item_ingredient_shortage or status == defines.entity_status.no_ingredients then
          local recipe = e.get_recipe()
          if not recipe and e.type == "furnace" and e.previous_recipe then recipe = e.previous_recipe.name end
          if recipe then
            local input = e.get_inventory(defines.inventory.crafter_input)
            for _, i in pairs(recipe.ingredients) do
              local missing = i.type == "item" and i.amount - input.get_item_count(i.name) or 0
              if missing > 0 then input.insert({ name = i.name, count = missing }) end
            end
          end
        end
      end
    end
  ]],
}

-- Issue #591: the menu picks its next scene at random (main_menu_simulations has no order or priority), so the
-- maintainer's wish "Gregtorio's scenes first" cannot be set; instead every scene of this mod is in the list
-- SCENE_WEIGHT times, as `<name>_copy2` and so on (the steam age: 5 of 39 entries, about every eighth scene).
-- devcheck.py menusim runs a scene once and checks that its copies are the same.
local SCENE_WEIGHT = 5
local own = {}
for name, sim in pairs(simulations) do
	if type(sim.save) == "string" and sim.save:find("^__gregtorio%-continued__/") then own[name] = sim end
end
for name, sim in pairs(own) do
	for n = 2, SCENE_WEIGHT do simulations[name .. "_copy" .. n] = table.deepcopy(sim) end
end

-- VANILLA SCENES: the bonuses of the disabled techs (PR #65)

-- effect type -> LuaForce field for the plain modifiers
local FORCE_FIELDS = {
	["character-health-bonus"] = "character_health_bonus",
	["maximum-following-robots-count"] = "maximum_following_robot_count",
	["mining-drill-productivity-bonus"] = "mining_drill_productivity_bonus",
	["character-inventory-slots-bonus"] = "character_inventory_slots_bonus",
	["artillery-range"] = "artillery_range_modifier",
	["laboratory-speed"] = "laboratory_speed_modifier",
}

local bonuses = {}
for _, effect in ipairs(FORK_DISABLED_TECH_EFFECTS or {}) do
	local t = effect.type
	if t == "ammo-damage" or t == "gun-speed" then
		bonuses[#bonuses + 1] = { t, effect.ammo_category, effect.modifier }
	elseif t == "turret-attack" then
		bonuses[#bonuses + 1] = { t, effect.turret_id, effect.modifier }
	elseif t == "change-recipe-productivity" then
		bonuses[#bonuses + 1] = { t, effect.recipe, effect.change }
	elseif FORCE_FIELDS[t] then
		bonuses[#bonuses + 1] = { FORCE_FIELDS[t], false, effect.modifier }
	end
end
if #bonuses == 0 then return end

local apply = [[
local function fork_disabled_tech_bonuses(force)
  for _, b in pairs(]] .. serpent.line(bonuses, { comment = false }) .. [[) do
    local t, name, m = b[1], b[2], b[3]
    if t == "ammo-damage" then force.set_ammo_damage_modifier(name, force.get_ammo_damage_modifier(name) + m)
    elseif t == "gun-speed" then force.set_gun_speed_modifier(name, force.get_gun_speed_modifier(name) + m)
    elseif t == "turret-attack" then force.set_turret_attack_modifier(name, force.get_turret_attack_modifier(name) + m)
    elseif t == "change-recipe-productivity" then
      local recipe = force.recipes[name]
      if recipe then recipe.productivity_bonus = recipe.productivity_bonus + m end
    else force[t] = force[t] + m end
  end
end
]]

for _, sim in pairs(simulations) do
	if type(sim.init) == "string" and sim.init:find("research_all_technologies", 1, true) then
		sim.init = apply .. sim.init:gsub("([%w_%.%[%]\"']+)%.research_all_technologies%(%)",
			"%1.research_all_technologies() fork_disabled_tech_bonuses(%1)")
	end
end
