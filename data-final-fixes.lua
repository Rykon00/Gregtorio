
table.insert(data.raw["character"]["character"].crafting_categories, "manual-only-recipes")
table.insert(data.raw["character"]["character"].crafting_categories, "crafting-table-recipes")
table.insert(data.raw["character"]["character"].crafting_categories, "crafting-or-assembling-recipes")

table.insert(data.raw.lab.lab.inputs, "umv-science-pack")
table.insert(data.raw.lab.lab.inputs, "uxv-science-pack")
table.insert(data.raw.lab.lab.inputs, "max-science-pack")

--------------------------
---VANILLA ITEM REMOVAL---
--------------------------

---BURNER MINING DRILL
data.raw["recipe"]["burner-mining-drill-recycling"] = nil
data.raw["mining-drill"]["burner-mining-drill"] = nil
data.raw["recipe"]["burner-mining-drill"] = nil
data.raw["item"]["burner-mining-drill"] = nil

---ELECTRIC FURNACE FURNACE
data.raw["recipe"]["electric-furnace-recycling"] = nil
data.raw["furnace"]["electric-furnace"] = nil
data.raw["recipe"]["electric-furnace"] = nil
data.raw["item"]["electric-furnace"] = nil




data.raw["map-gen-presets"].default["gregtorio"] = {
	order = "a",
	basic_settings = {
		peaceful_mode = true,
		autoplace_controls = {
			["iron-ore"] = { size = 0 },
			["copper-ore"] = { size = 0 },
			["coal"] = { size = 0 },
			["stone"] = { size = 0 },
			["crude-oil"] = { size = 0 },
			["uranium-ore"] = { size = 0 },
		}
	}
}


-- Disable spawners
for _, name in pairs({"biter-spawner", "spitter-spawner"}) do
  if data.raw["unit-spawner"][name] then
    data.raw["unit-spawner"][name].autoplace = nil
  end
end

-- Disable units
for _, unit in pairs(data.raw["unit"]) do
  unit.autoplace = nil
end

-- Disable worms
for _, name in pairs({"small-worm-turret", "medium-worm-turret", "big-worm-turret"}) do
  if data.raw["turret"][name] then
    data.raw["turret"][name].autoplace = nil
  end
end



---MAKING INSERTERS NOT REQUIRE POWER
--- Fork: the Manual Inserter runs on manual labor instead of for free (vanilla burner
--- inserter energy, about 10 swings per manual labor; no free initial fuel)
data.raw["inserter"]["burner-inserter"].energy_source = {
	type = "burner",
	fuel_categories = { "manual-labor" },
	burner_usage = data.raw["burner-usage"]["manual-labor"] and "manual-labor" or nil,
	effectivity = 1,
	fuel_inventory_size = 1,
	light_flicker = { color = { 0, 0, 0 } },
}
--data.raw["inserter"]["inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["long-handed-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["fast-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["bulk-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["stack-inserter"].energy_source = {type = "void"}
---MAKING YELLOW UNDERGROUND RUN 7 DISTANCE
data.raw["underground-belt"]["underground-belt"].max_distance = 7



---DISABLE TRIGGERED TECHS
--- Fork: don't disable Gregtorio's own techs that share a name with a vanilla tech (e.g. "tungsten-carbide")
local function is_gregtorio_tech(t)
  return t.icon and t.icon:sub(1, 24) == "__gregtorio-continued__/"
end
local function disable_trigger_tech(name)
  if data.raw.technology[name] and not is_gregtorio_tech(data.raw.technology[name]) then
    data.raw.technology[name].enabled = false
    data.raw.technology[name].hidden = true
	data.raw.technology[name].research_trigger = nil
	data.raw.technology[name].unit = {count = 10, ingredients = {{"automation-science-pack", 1}}, time = 10 }
  end
end
disable_trigger_tech("steam-power")
disable_trigger_tech("electronics")
disable_trigger_tech("cryogenic-plant")
disable_trigger_tech("yumako")
disable_trigger_tech("tungsten-steel")
disable_trigger_tech("tungsten-carbide")
disable_trigger_tech("recycling")
disable_trigger_tech("jellynut")
disable_trigger_tech("holmium-processing")
disable_trigger_tech("heating-tower")
disable_trigger_tech("foundry")
disable_trigger_tech("electromagnetic-plant")
disable_trigger_tech("calcite-processing")
disable_trigger_tech("bioflux")
disable_trigger_tech("bioflux-processing")
disable_trigger_tech("biochamber")
disable_trigger_tech("bacteria-cultivation")
disable_trigger_tech("artificial-soil")
disable_trigger_tech("agriculture")
disable_trigger_tech("space-platform")
disable_trigger_tech("biter-egg-handling")



---DISABLE TECHS
local function disable_tech(name)
  if data.raw.technology[name] and not is_gregtorio_tech(data.raw.technology[name]) then
    data.raw.technology[name].enabled = false
    data.raw.technology[name].hidden = true
    data.raw.technology[name].effects = {}
  end
end
disable_tech("automation-science-pack")
disable_tech("electric-mining-drill")
disable_tech("big-mining-drill")
disable_tech("heavy-armor")
disable_tech("advanced-material-processing")
disable_tech("advanced-material-processing-2")
disable_tech("low-density-structure")
disable_tech("engine")
disable_tech("sulfur-processing")
disable_tech("advanced-circuit")
disable_tech("plastics")
disable_tech("mining-productivity-1")
disable_tech("mining-productivity-2")
disable_tech("mining-productivity-3")
disable_tech("quality-module")
disable_tech("quality-module-2")
disable_tech("quality-module-3")
disable_tech("electric-engine")
disable_tech("lubricant")
disable_tech("advanced-oil-processing")
disable_tech("robotics")
disable_tech("laser")
disable_tech("uranium-mining")
disable_tech("processing-unit")
disable_tech("rocket-silo")
disable_tech("nuclear-fuel-reprocessing")
disable_tech("space-platform-thruster")
disable_tech("kovarex-enrichment-process")
disable_tech("asteroid-reprocessing")
disable_tech("coal-liquefaction")
disable_tech("epic-quality")
disable_tech("advanced-asteroid-processing")
disable_tech("overgrowth-soil")
disable_tech("biolab")
disable_tech("lightning-collector")
disable_tech("rail-support-foundations")
disable_tech("lithium-processing")
disable_tech("quantum-processor")
disable_tech("foundation")
disable_tech("legendary-quality")
disable_tech("captive-biter-spawner")
disable_tech("steel-plate-productivity")
disable_tech("low-density-structure-productivity")
disable_tech("plastic-bar-productivity")
disable_tech("rocket-fuel-productivity")
disable_tech("asteroid-productivity")
disable_tech("railgun-damage-1")
disable_tech("railgun-shooting-speed-1")
disable_tech("scrap-recycling-productivity")
disable_tech("processing-unit-productivity")
disable_tech("rocket-part-productivity")
disable_tech("railgun")
disable_tech("planet-discovery-fulgora")
disable_tech("planet-discovery-gleba")
disable_tech("planet-discovery-vulcanus")
disable_tech("planet-discovery-aquilo")
disable_tech("captivity")
disable_tech("fish-breeding")
disable_tech("carbon-fiber")
disable_tech("solar-energy")
disable_tech("toolbelt")
disable_tech("toolbelt-equipment")
disable_tech("modules")
disable_tech("speed-module")
disable_tech("speed-module-2")
disable_tech("speed-module-3")
disable_tech("productivity-module")
disable_tech("productivity-module-2")
disable_tech("productivity-module-3")
disable_tech("efficiency-module")
disable_tech("efficiency-module-2")
disable_tech("efficiency-module-3")
disable_tech("electric-energy-accumulators")
disable_tech("solar-panel-equipment")
disable_tech("effect-transmission")
disable_tech("automation-3")



---GUN TURRET
data.raw.technology["gun-turret"].prerequisites = { "military" }



---MILITARY
data.raw.technology["military"].prerequisites = { "craft-automation-science-packs" }



---STONE WALL
data.raw.technology["stone-wall"].prerequisites = { "military" }



---REPAIR PACK
data.raw.technology["repair-pack"].prerequisites = { "craft-automation-science-packs" }



---LANDFILL
data.raw.technology["landfill"].unit = {count = 80, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 20 }
data.raw.technology["landfill"].prerequisites = { "rock-crusher" }



---LAMP
data.raw.technology["lamp"].effects = { { type = "unlock-recipe", recipe = "torch" } }
data.raw.technology["lamp"].unit = {count = 5, ingredients = {{"automation-science-pack", SP01 }}, time = 5 }
data.raw.technology["lamp"].icon = "__gregtorio-continued__/graphics/technology/torches.png"
data.raw.technology["lamp"].prerequisites = { "craft-automation-science-packs" }



---RADAR
data.raw.technology["radar"].effects = {
      { type = "unlock-recipe", recipe = "lv-sensor" },
	  { type = "unlock-recipe", recipe = "radar" },
  }
data.raw.technology["radar"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }
data.raw.technology["radar"].prerequisites = { "automation-2" }



---FLUID HANDLING
data.raw.technology["fluid-handling"].effects = {
      { type = "unlock-recipe", recipe = "configurable-valve" },
	  { type = "unlock-recipe", recipe = "storage-tank" },
	  { type = "unlock-recipe", recipe = "pump" },
  }
data.raw.technology["fluid-handling"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }
data.raw.technology["fluid-handling"].prerequisites = { "automation-2" }



---CIRCUIT NETWORK
data.raw.technology["circuit-network"].prerequisites = { "circuit-assembler" }
data.raw.technology["circuit-network"].unit = {count = 160, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }



---FLUID WAGON
data.raw.technology["fluid-wagon"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 } }, time = 30 }



---AUTOMATED RAIL TRANSPORTATION
data.raw.technology["automated-rail-transportation"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 } }, time = 30 }



---LAB RESEARCH SPEED 1
data.raw.technology["research-speed-1"].prerequisites = { "logistic-science-pack" }
data.raw.technology["research-speed-1"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 20 }



---LAB RESEARCH SPEED 2
data.raw.technology["research-speed-2"].prerequisites = { "research-speed-1", "military-science-pack" }
data.raw.technology["research-speed-2"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 }}, time = 30 }



---LAB RESEARCH SPEED 3
data.raw.technology["research-speed-3"].prerequisites = { "research-speed-2", "chemical-science-pack" }
data.raw.technology["research-speed-3"].unit = {count = 400, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 }}, time = 30 }




---MILITARY 2
data.raw.technology["military-2"].prerequisites = { "military", "logistic-science-pack" }



---WEAPON SHOOTING SPEED 2
data.raw.technology["weapon-shooting-speed-2"].prerequisites = { "military-2", "weapon-shooting-speed-1" }



---PHYSICAL PROJECTILE DAMAGE 2
data.raw.technology["physical-projectile-damage-2"].prerequisites = { "military-2", "physical-projectile-damage-1" }



---DEFENDER
data.raw.technology["defender"].prerequisites = { "military-2" }


---STRONGER EXPLOSIVES 2
data.raw.technology["stronger-explosives-2"].prerequisites = { "stronger-explosives-1" }



---WEAPON SHOOTING SPEED 3
data.raw.technology["weapon-shooting-speed-3"].prerequisites = { "weapon-shooting-speed-2" }



---PHYSICAL PROJECTILE DAMAGE 3
data.raw.technology["physical-projectile-damage-3"].prerequisites = { "physical-projectile-damage-2" }



---AUTOMOBILISM
data.raw.technology["automobilism"].prerequisites = { "automation-2" }
data.raw.technology["automobilism"].unit = {count = 160, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }


---ADVANCED COMBINATORS
data.raw.technology["advanced-combinators"].unit = {count = 400, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 } }, time = 30 }


---CLIFF EXPLOSIVES
data.raw.technology["cliff-explosives"].prerequisites = { "implosion-compressor" }
data.raw.technology["cliff-explosives"].unit = {count = 540, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 } }, time = 30 }


---RESEARCH PRODUCTIVITY
data.raw.technology["research-productivity"].prerequisites = { "cryogenic-science-pack" }
data.raw.technology["research-productivity"].unit = {count_formula = "2000*2^(L-1)", ingredients = { {"automation-science-pack", SP11}, {"logistic-science-pack", SP10}, {"military-science-pack", SP09},
		{"chemical-science-pack", SP08}, {"production-science-pack", SP07}, {"utility-science-pack", SP06}, {"space-science-pack", SP05}, {"metallurgic-science-pack", SP04}, {"agricultural-science-pack", SP03},
		{"electromagnetic-science-pack", SP02}, {"cryogenic-science-pack", SP01} }, time = 720 }


------------------------------------------------
--- OPTIONAL DISABLING OF ALL MILITARY TECHS ---
------------------------------------------------
---[not actually optional for now]

disable_tech("gun-turret")
disable_tech("stone-wall")
disable_tech("gate")
disable_tech("military")
disable_tech("military-2")
disable_tech("military-3")
disable_tech("military-4")
disable_tech("defender")
disable_tech("physical-projectile-damage-1")
disable_tech("physical-projectile-damage-2")
disable_tech("physical-projectile-damage-3")
disable_tech("physical-projectile-damage-4")
disable_tech("physical-projectile-damage-5")
disable_tech("physical-projectile-damage-6")
disable_tech("physical-projectile-damage-7")
disable_tech("weapon-shooting-speed-1")
disable_tech("weapon-shooting-speed-2")
disable_tech("weapon-shooting-speed-3")
disable_tech("weapon-shooting-speed-4")
disable_tech("weapon-shooting-speed-5")
disable_tech("weapon-shooting-speed-6")
disable_tech("weapon-shooting-speed-7")
disable_tech("flammables")
disable_tech("flamethrower")
disable_tech("refined-flammables-1")
disable_tech("refined-flammables-2")
disable_tech("refined-flammables-3")
disable_tech("refined-flammables-4")
disable_tech("refined-flammables-5")
disable_tech("refined-flammables-6")
disable_tech("refined-flammables-7")
disable_tech("stronger-explosives-1")
disable_tech("stronger-explosives-2")
disable_tech("stronger-explosives-3")
disable_tech("stronger-explosives-4")
disable_tech("stronger-explosives-5")
disable_tech("stronger-explosives-6")
disable_tech("stronger-explosives-7")
disable_tech("rocketry")
disable_tech("rocket-turret")
disable_tech("atomic-bomb")
disable_tech("uranium-ammo")
disable_tech("health")
disable_tech("artillery")
disable_tech("artillery-shell-damage-1")
disable_tech("artillery-shell-range-1")
disable_tech("artillery-shell-speed-1")
disable_tech("distractor")
disable_tech("destroyer")
disable_tech("follower-robot-count-1")
disable_tech("follower-robot-count-2")
disable_tech("follower-robot-count-3")
disable_tech("follower-robot-count-4")
disable_tech("follower-robot-count-5")
disable_tech("electric-weapons-damage-1")
disable_tech("electric-weapons-damage-2")
disable_tech("electric-weapons-damage-3")
disable_tech("electric-weapons-damage-4")
disable_tech("land-mine")
disable_tech("laser-turret")
disable_tech("laser-shooting-speed-1")
disable_tech("laser-shooting-speed-2")
disable_tech("laser-shooting-speed-3")
disable_tech("laser-shooting-speed-4")
disable_tech("laser-shooting-speed-5")
disable_tech("laser-shooting-speed-6")
disable_tech("laser-shooting-speed-7")
disable_tech("laser-weapons-damage-1")
disable_tech("laser-weapons-damage-2")
disable_tech("laser-weapons-damage-3")
disable_tech("laser-weapons-damage-4")
disable_tech("laser-weapons-damage-5")
disable_tech("laser-weapons-damage-6")
disable_tech("laser-weapons-damage-7")
disable_tech("personal-laser-defense-equipment")
disable_tech("discharge-defense-equipment")
disable_tech("explosive-rocketry")
disable_tech("tank")
disable_tech("tesla-weapons")