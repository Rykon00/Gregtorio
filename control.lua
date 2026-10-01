
--- Fork: ME network core: cable graph, controller, drives and cells, storage API (AE2, issue #68, see prototypes/120-fork-ae2.lua)
local fork_net = require("scripts.fork-me-network")
--- Fork: ME Interface and import/export buses, the I/O step (also runs the fluid step)
local fork_io = require("scripts.fork-me-io")
--- Fork: migration of ME networks from before issue #68 (logistic network based)
local fork_migrate = require("scripts.fork-me-migrate")
--- Fork: ME terminal (the hub window), routes the GUI events of every ME window (scripts/fork-me-gui.lua)
local fork_me = require("scripts.fork-me-terminal")
--- Fork: AE2 autocrafting, pattern providers and crafting CPUs (see prototypes/121-fork-ae2-autocrafting.lua)
local fork_ae2 = require("scripts.fork-me-autocraft")
--- Fork: AE2 fluid storage, fluid drives and fluid interfaces (see prototypes/122-fork-ae2-fluids.lua)
local fork_fluids = require("scripts.fork-me-fluids")
--- Fork: AE2 level maintainer and circuit interface (issue #38, see prototypes/121-fork-ae2-autocrafting.lua)
local fork_circuit = require("scripts.fork-me-circuit")
--- Fork: the windows of the ME blocks (issue #68 step R3; after the modules whose functions they call)
require("scripts.fork-me-windows")
--- Fork: molds stay in the machine's mold slot (see prototypes/150-fork-molds.lua)
local fork_molds = require("scripts.fork-molds")
--- Fork: researching the first level of `victory` wins the game (see prototypes/135-fork-endgame.lua)
local fork_victory = require("scripts.fork-victory")
--- Fork: fuel check of the endgame generators, cooled fluid of the plasma turbines (see prototypes/136-fork-power.lua)
local fork_power = require("scripts.fork-power")

--- the blueprint handler of the autocrafting module also tags ME Interfaces, buses and drives
fork_ae2.blueprint_hooks[#fork_ae2.blueprint_hooks + 1] = fork_io.tag_blueprint
fork_ae2.blueprint_hooks[#fork_ae2.blueprint_hooks + 1] = fork_net.tag_blueprint

script.on_event(defines.events.on_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
  fork_net.on_built(event.entity, event)
  fork_io.on_built(event.entity, event.tags)
  fork_ae2.on_built(event.entity, event.tags)
  fork_fluids.on_built(event.entity, event.tags)
  fork_circuit.on_built(event.entity, event.tags)
  fork_molds.on_built(event.entity)
  fork_power.on_built(event.entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
  fork_net.on_built(event.entity, event)
  fork_io.on_built(event.entity, event.tags)
  fork_ae2.on_built(event.entity, event.tags)
  fork_fluids.on_built(event.entity, event.tags)
  fork_circuit.on_built(event.entity, event.tags)
  fork_molds.on_built(event.entity)
  fork_power.on_built(event.entity)
end)

--- Fork: entities built by other scripts or on space platforms
script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive,
  defines.events.on_space_platform_built_entity }, function(event)
  fork_net.on_built(event.entity, event)
  fork_io.on_built(event.entity, event.tags)
  fork_ae2.on_built(event.entity, event.tags)
  fork_fluids.on_built(event.entity, event.tags)
  fork_circuit.on_built(event.entity, event.tags)
  fork_molds.on_built(event.entity)
  fork_power.on_built(event.entity)
end)

--- Fork: cloned entities (e.g. by other mods) need to be registered as well (a cloned fluid drive starts empty,
--- the settings of providers, fluid interfaces, level maintainers and circuit interfaces are copied)
script.on_event(defines.events.on_entity_cloned, function(event)
  fork_net.on_built(event.destination)
  fork_net.on_cloned(event.source, event.destination)
  fork_io.on_built(event.destination, nil, event.source)
  fork_ae2.on_built(event.destination, nil, event.source)
  fork_fluids.on_built(event.destination, nil, event.source)
  fork_circuit.on_built(event.destination, nil, event.source)
  fork_power.on_built(event.destination)
end)

--- Fork: the recipe choice of an ME Pattern Provider (for the furnaces next to it) and the settings of ME Drives,
--- ME Interfaces, buses, ME Fluid Interfaces, Level Maintainers and Circuit Interfaces are copied by settings
--- paste and stored in blueprints (the blueprint handler of fork-me-autocraft.lua tags all of them)
script.on_event(defines.events.on_entity_settings_pasted, function(event)
  fork_net.on_entity_settings_pasted(event)
  fork_io.on_entity_settings_pasted(event)
  fork_ae2.on_entity_settings_pasted(event)
  fork_fluids.on_entity_settings_pasted(event)
  fork_circuit.on_entity_settings_pasted(event)
end)

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  fork_ae2.on_player_setup_blueprint(event)
end)

--- Fork: removed ME members. Mined: an ME Drive's cells (with their items and fluids) go into the mined buffer,
--- a fluid interface's content back into the network; destroyed or removed by a script: the cells are spilled.
--- The fluid module runs first (it looks at the network the entity still belongs to), then the graph is updated.
local REMOVED_FILTER = {}
for _, t in pairs({ "simple-entity-with-force", "storage-tank", "lamp", "electric-energy-interface", "container",
  "constant-combinator", "assembling-machine", "furnace" }) do
  REMOVED_FILTER[#REMOVED_FILTER + 1] = { filter = "type", type = t }
end
local function on_mined(event)
  fork_fluids.on_mined_event(event)
  fork_io.on_removed(event.entity)
  fork_net.on_removed(event.entity, event.buffer)
end
for _, name in pairs({ "on_player_mined_entity", "on_robot_mined_entity", "on_space_platform_mined_entity" }) do
  script.on_event(defines.events[name], on_mined, REMOVED_FILTER)
end
script.on_event(defines.events.on_entity_died, function(event)
  fork_fluids.on_removed(event.entity)
  fork_io.on_removed(event.entity)
  fork_net.on_removed(event.entity, nil)
end, REMOVED_FILTER)
script.on_event(defines.events.script_raised_destroy, function(event)
  fork_fluids.on_removed(event.entity)
  fork_io.on_removed(event.entity)
  fork_net.on_removed(event.entity, nil)
end, REMOVED_FILTER)

--- Fork: a rotated import or export bus faces another entity
script.on_event(defines.events.on_player_rotated_entity, function(event)
  fork_io.on_rotated(event.entity)
  fork_net.on_rotated(event.entity)
end)

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
	--- the ME graph first (the only map scan), then the migration of old ME networks (issue #68), then the
	--- modules that read the graph
	fork_net.rebuild()
	fork_migrate.run_fluids()
	fork_migrate.run()
	fork_me.on_configuration_changed()
	fork_fluids.on_configuration_changed()
	fork_ae2.on_configuration_changed()
	fork_circuit.on_configuration_changed()
	fork_io.on_configuration_changed()
	fork_molds.on_configuration_changed()
	fork_power.on_configuration_changed()
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
