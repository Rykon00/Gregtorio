--- Fork: main menu simulations (PR #65), loaded from data-final-fixes.lua after the vanilla techs are disabled.
--- Several vanilla menu simulations call research_all_technologies() and rely on the bonuses it gives:
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
