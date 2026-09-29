
--- Fork: ME terminal GUI and ME interface defaults (AE2, see prototypes/120-fork-ae2.lua)
local fork_me = require("scripts.fork-me-terminal")
--- Fork: AE2 autocrafting, pattern providers and crafting CPUs (see prototypes/121-fork-ae2-autocrafting.lua)
local fork_ae2 = require("scripts.fork-me-autocraft")
--- Fork: AE2 fluid storage, fluid drives and fluid interfaces (see prototypes/122-fork-ae2-fluids.lua)
local fork_fluids = require("scripts.fork-me-fluids")
--- Fork: molds stay in the machine's mold slot (see prototypes/150-fork-molds.lua)
local fork_molds = require("scripts.fork-molds")
--- Fork: researching the first level of `victory` wins the game (see prototypes/135-fork-endgame.lua)
local fork_victory = require("scripts.fork-victory")

script.on_event(defines.events.on_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
  fork_me.on_built(event.entity)
  fork_ae2.on_built(event.entity)
  fork_fluids.on_built(event.entity, fork_fluids.tags_from_event(event))
  fork_molds.on_built(event.entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
  fork_ae2.on_built(event.entity)
  fork_fluids.on_built(event.entity, fork_fluids.tags_from_event(event))
  fork_molds.on_built(event.entity)
end)

--- Fork: entities built by other scripts or on space platforms
script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive,
  defines.events.on_space_platform_built_entity }, function(event)
  fork_me.on_built(event.entity)
  fork_ae2.on_built(event.entity)
  fork_fluids.on_built(event.entity, fork_fluids.tags_from_event(event))
  fork_molds.on_built(event.entity)
end)

--- Fork: cloned entities (e.g. by other mods) need to be registered as well (a cloned fluid drive starts empty)
script.on_event(defines.events.on_entity_cloned, function(event)
  fork_ae2.on_built(event.destination)
  fork_fluids.on_built(event.destination)
end)

-- Raise a custom event when the cutscene ends
script.on_event(defines.events.on_cutscene_cancelled, function(event)
	local player = game.get_player(event.player_index)
	if player and player.character then
		player.print("It is strongly recommended that you set Manual Labor to autocraft up to a high number (1000+) for the early game and enable autocrafting.")
		player.print("You can safely disable all resource generation on Nauvis, its not used in this mod.")
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
	fork_me.on_configuration_changed()
	fork_fluids.on_configuration_changed()
	fork_ae2.on_configuration_changed()
	fork_molds.on_configuration_changed()
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
