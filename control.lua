
--- Fork: the ME network is the mod me-network (issue #83); this hands the ME state of older saves over to it once
local fork_handover = require("scripts.fork-me-handover")
--- Fork: molds stay in the machine's mold slot (see prototypes/150-fork-molds.lua)
local fork_molds = require("scripts.fork-molds")
--- Fork: researching the first level of `victory` wins the game (see prototypes/135-fork-endgame.lua)
local fork_victory = require("scripts.fork-victory")
--- Fork: fuel check of the endgame generators, cooled fluid of the plasma turbines (see prototypes/136-fork-power.lua)
local fork_power = require("scripts.fork-power")
--- Fork: Space Elevator modules run only next to a Space Elevator with free slots (see prototypes/162-fork-space-elevator.lua)
local fork_space_elevator = require("scripts.fork-space-elevator")
--- Fork: a Miner or Ore Drilling Plant that replaces a mine keeps its vein (issue #342, see prototypes/163-fork-electric-mine.lua)
local fork_electric_mine = require("scripts.fork-electric-mine")
--- Fork: the solar boilers make steam by day only (issue #446, see prototypes/101-fork-machines.lua)
local fork_steam_boilers = require("scripts.fork-steam-boilers")
--- Fork: the map veins get a chart tag with their name (issue #497, see prototypes/165-fork-ore-veins.lua)
local fork_ore_veins = require("scripts.fork-ore-veins")
--- Fork: the Ore Drilling Plants drink Drilling Fluid per ore mined (issue #499, see prototypes/163-fork-electric-mine.lua)
local fork_ore_drills = require("scripts.fork-ore-drills")
--- Fork: the Nether Portal sends whoever steps onto it to the Nether and back (issue #501, see prototypes/160-fork-dimension-mines.lua)
local fork_portals = require("scripts.fork-portals")
--- Fork: Ender Chests and Ender Tanks of one colour code share their contents on every surface (issue #504, see prototypes/160-fork-dimension-mines.lua)
local fork_ender = require("scripts.fork-ender")

local function on_built(event)
  local entity = event.entity
  if entity.name == "trash-can" then
    entity.remove_unfiltered_items = true
  end
  fork_electric_mine.on_built(entity)
  fork_molds.on_built(entity)
  fork_power.on_built(entity)
  fork_space_elevator.on_built(entity)
  fork_steam_boilers.on_built(entity)
  fork_ore_drills.on_built(entity)
  fork_ender.on_built(entity, event.tags)   -- issue #546: the code of a blueprint
end
script.on_event({ defines.events.on_built_entity, defines.events.on_robot_built_entity }, on_built)
--- Fork: the vein of a mine about to be replaced (issue #342)
script.on_event(defines.events.on_pre_build, fork_electric_mine.on_pre_build)
--- Fork: the name of a map vein when the chunk of its centre is charted (issue #497)
script.on_event(defines.events.on_chunk_charted, fork_ore_veins.on_chunk_charted)
--- Fork: a player who steps onto a Nether Portal (issue #501)
script.on_event(defines.events.on_player_changed_position, fork_portals.on_player_changed_position)
script.on_event(defines.events.on_marked_for_upgrade, fork_electric_mine.on_marked_for_upgrade)
script.on_event(defines.events.on_cancelled_upgrade, fork_electric_mine.on_cancelled_upgrade)
script.on_event({ defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined }, fork_electric_mine.on_pre_mined)

--- Fork: entities built by other scripts or on space platforms, and cloned ones
script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive,
  defines.events.on_space_platform_built_entity }, function(event)
  fork_electric_mine.on_built(event.entity)
  fork_molds.on_built(event.entity)
  fork_power.on_built(event.entity)
  fork_space_elevator.on_built(event.entity)
  fork_steam_boilers.on_built(event.entity)
  fork_ore_drills.on_built(event.entity)
  fork_ender.on_built(event.entity, event.tags)
end)
script.on_event(defines.events.on_entity_cloned, function(event)
  fork_power.on_built(event.destination)
  fork_space_elevator.on_built(event.destination)
  fork_steam_boilers.on_built(event.destination)
  fork_ore_drills.on_built(event.destination)
  fork_ender.on_built(event.destination)
end)
--- Fork: a Space Elevator or a module removed (any way): its surface is assigned again
script.on_event(defines.events.on_object_destroyed, function(event)
  fork_space_elevator.on_object_destroyed(event)
  fork_ore_drills.on_object_destroyed(event)   -- issue #499: an Ore Drilling Plant's hidden tank goes with it
  fork_ender.on_object_destroyed(event)   -- issue #504: an Ender Tank leaves its group
end)
--- Fork: the colour code panel of the Ender Chest and Ender Tank (issue #504)
script.on_event(defines.events.on_gui_opened, fork_ender.on_gui_opened)
script.on_event(defines.events.on_gui_closed, fork_ender.on_gui_closed)
script.on_event(defines.events.on_gui_selection_state_changed, fork_ender.on_gui_selection_state_changed)
script.on_event(defines.events.on_entity_settings_pasted, fork_ender.on_entity_settings_pasted)
--- Fork: blueprints keep the colour code of the Ender Chest and Ender Tank (issue #546)
script.on_event(defines.events.on_player_setup_blueprint, fork_ender.on_player_setup_blueprint)
script.on_event(defines.events.on_blueprint_settings_pasted, fork_ender.on_blueprint_settings_pasted)

-- Raise a custom event when the cutscene ends
script.on_event(defines.events.on_cutscene_cancelled, function(event)
	local player = game.get_player(event.player_index)
	if player and player.character then
		player.print("It is strongly recommended that you set Manual Labor to autocraft up to a high number (1000+) for the early game and enable autocrafting.")
		player.print("You can safely disable all resource generation on Nauvis, its not used in this mod.")
		--- Fork: where to find machine recipes (issue #49, prototypes/198-fork-crafting-menu.lua)
		if settings.startup["gregtorio-continued-show-machine-recipes"].value then
			player.print({ "fork-hint.machine-recipes" })
		end
		player.print({ "fork-hint.factoriopedia" })
		player.character_crafting_speed_modifier = 1.0
	end
end)




local tech_name = {
  ["weapon-shooting-speed-1"] = "Weapon Shooting Speed One",
  ["physical-projectile-damage-1"] = "Physical Projectile Damage One",
  ["logistic-science-pack"] = "LV Science Pack",
  ["steel-backpack"] = "Steel Backpack",
  ["repair-pack"] = "Repair Pack",
  ["stone-wall"] = "Stone Wall",
  ["military"] = "Military",
  ["iron-furnace"] = "Iron Furnace",
  ["gun-turret"] = "Gun Turret",
  ["lamp"] = "Torches",
  ["logistics"] = "Logistics",
  ["basic-backpack"] = "Basic Backpack",
  ["small-coal-boiler"] = "Small Coal Boiler",
  ["steam-alloy-smelter"] = "Steam Alloy Smelter",
  ["steam-compressor"] = "Steam Compressor",
  ["steam-forge-hammer"] = "Steam Forge Hammer",
  ["coke-oven"] = "Coke Oven",
  ["steel-processing"] = "Steel Processing",
  ["glassmaking"] = "Glassmaking",
  ["steam-macerator"] = "Steam Macerator",
  ["steam-extractor"] = "Steam Extractor",
  ["rubber"] = "Rubber",
  ["primitive-electronics"] = "Primitive Electronics",
  ["steam-turbine"] = "Steam Turbine",
  ["wiremill"] = "Wiremill",
  ["bending-machine"] = "Bending Machine",
}

script.on_event(defines.events.on_research_finished, function(event)
  fork_victory.on_research_finished(event)
  local name = tech_name[event.research.name]
  if not name then return end

  for _, player in pairs(event.research.force.players) do
    if player and player.valid and player.character then
      player.insert({name = "manual-labor", count = 1000})
      player.print("[color=orange]You feel a burst of motivation after having researched " .. name .. "![/color]")
      player.print("[color=orange]You have gained an additional 1000 Manual Labor, and will continue to gain this for each red pack only tech researched.[/color]")
    end
  end
end)


--- Fork: re-apply tech effects after a mod update so recipes newly added to already
--- researched techs also get unlocked in existing saves.
script.on_configuration_changed(function(data)
	local changes = data.mod_changes and data.mod_changes[script.mod_name]
	if changes or data.mod_startup_settings_changed then
		for _, force in pairs(game.forces) do
			force.reset_technology_effects()
		end
	end
	--- the ME network (its graph rebuild and the migrations of old ME networks) is me-network's since issue #83
	fork_handover.on_configuration_changed()
	fork_molds.on_configuration_changed()
	fork_power.on_configuration_changed()
	fork_space_elevator.on_configuration_changed()
	fork_steam_boilers.on_configuration_changed()
	fork_ore_drills.on_configuration_changed()
end)



--- Fork: /gregtorio-remove-vanilla-ores removes the vanilla resource patches, which
--- Gregtorio does not use and which cannot be mined anymore (see 102-fork-resources.lua).
local VANILLA_RESOURCES = {
	"iron-ore", "copper-ore", "stone", "coal", "uranium-ore", "crude-oil",
	"tungsten-ore", "calcite", "scrap", "sulfuric-acid-geyser", "lithium-brine", "fluorine-vent",
}
commands.add_command("gregtorio-remove-vanilla-ores",
	"Removes all vanilla resource patches (iron, copper, stone, coal, uranium, oil ...) on every surface. Gregtorio does not use them.",
	function(cmd)
		local player = cmd.player_index and game.get_player(cmd.player_index)
		if player and not player.admin then
			player.print("Only admins can use this command.")
			return
		end
		local names = {}
		for _, n in pairs(VANILLA_RESOURCES) do
			if prototypes.entity[n] then names[#names + 1] = n end
		end
		local removed = 0
		for _, surface in pairs(game.surfaces) do
			for _, e in pairs(surface.find_entities_filtered{ type = "resource", name = names }) do
				e.destroy()
				removed = removed + 1
			end
		end
		game.print("Gregtorio: removed " .. removed .. " vanilla resource tiles.")
	end)
