
script.on_event(defines.events.on_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  if event.entity.name == "trash-can" then
    event.entity.remove_unfiltered_items = true
  end
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