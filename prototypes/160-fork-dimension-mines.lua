--------------------------------------------------------------------------------
--- FORK DIMENSION MINES (issue #154's decision, part 1: issue #283): the materials of the microverse get a source of
--- their own, a mine per GT New Horizons dimension, gated by a technology that stands for reaching it at the voltage of
--- GTNH's rocket tier (gtneioreplugin DimensionHelper.java: the Nether and the End are T0). Issue #287 removed the
--- microverse. Veins from GT5-Unofficial af993ca6a9 OreMixes.java.
---
--- Overworld (MV, with Eyes of Ender, the first consumer): ender pearls are a mob drop of Endermen in GTNH; Gregtorio
---   has no mobs before the EV entity crusher, so a manual hunting recipe like the manual mines gives them, and the
---   crusher crushes Endermen like the other mobs (the maintainer's decision). Zombie heads (EnderIO's powered spawner,
---   soul binder and Z-logic controller, Ender IO) the same way (issue #287: the tier one microminer gave them; the
---   crusher's zombies come after the powered spawner they need).
--- The Nether (MV, technology Reach the Nether, before Eyes of Ender, which takes blaze rods):
---   * blaze rods: a mob drop (hunting, like the Endermen);
---   * the Molybdenum vein (Nether, End, Twilight Forest: wulfenite, molybdenite, molybdenum, powellite): molybdenite,
---     the one of them the mod has;
---   * soul sand (a Nether block): the dig site;
---   * nether air: GT++'s air intake hatch gives it in the Nether (MTEHatchAirIntake.java 41-53); here the HV compressor
---     (issue #314: not the LV one of the air collection), unlocked with the nether air distillation (End Steel).
--- The End (HV, technology Reach the End, after Eyes of Ender; before Radon, the first consumer of ender air):
---   * end stone (an End block) as compressed end stone;
---   * ender air in the HV compressor (issue #314: the EV one would lock the EV pack's radon); its liquefaction and
---     distillation move from EV Machines to Radon, so radon (the
---     quantum eye of the EV pack) comes from the End at HV (the maintainer's decision; GT's chemistry route, 8 plutonium
---     ingots, tiny uranium and air, is left out: the mod has neither plutonium ingots nor tiny uranium piles).
--- GTNH's End asteroids (naquadah, platinum, tungstate veins) come with the T3 dimensions (issue #285).
--- Issues #284 and #285 add the Moon and Mars, the asteroid belt, Jupiter's moons and Venus, issue #332 the Twilight
--- Forest's mines (with NAND Chips, no technology of their own) (sections below).
--- Loads before 142 (data.lua, issue #287): the unlock table of 142 and the ore chains of 155 (which unlock a chain step
--- after the technology of its raw ore) see the mines. The rules that move unlocks and add prerequisites for them are in
--- 161-fork-dimension-unlocks.lua, after 159.
--------------------------------------------------------------------------------

local F = FORK5B
local NETHER, END, TWILIGHT = "reach-the-nether", "reach-the-end", "reach-the-twilight-forest"

local function manual(name, category, ingredients, results)
	create_recipe{
		name = name,
		category = category,
		energy_required = 10,
		subgroup = "subgroup-mining",
		ingredients = ingredients,
		results = results,
		main_product = results[1].name,
	}
	return name
end
local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end
local PICKAXE, LABOR = item("iron-pickaxe-usage", 1), function(n) return item("manual-labor", n) end

--- the unlocks of an existing technology
local function unlock_in(tech, names)
	local t = data.raw.technology[tech]
	for _, n in pairs(names) do
		data.raw.recipe[n].enabled = false
		t.effects[#t.effects + 1] = { type = "unlock-recipe", recipe = n }
	end
end

--------------------------------------------------------------------------------
--- OVERWORLD: Endermen
--------------------------------------------------------------------------------

local enderman = manual("hunting-endermen", "manual-mine-recipes", { LABOR(24) }, { item("ender-pearl", 4) })
local zombie = manual("hunting-zombies", "manual-mine-recipes", { LABOR(24) }, { item("zombie-head", 1) })
create_recipe{
	name = "crushing-endermen",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 8,
	subgroup = "subgroup-ev-extreme-entity-crusher-recipes",
	ingredients = {},
	results = { item("ender-pearl", 1) },
	main_product = "ender-pearl",
}

--------------------------------------------------------------------------------
--- THE NETHER
--------------------------------------------------------------------------------

local nether = {
	manual("hunting-blazes", "manual-mine-recipes", { LABOR(24) }, { item("blaze-rod", 4) }),
	manual("digging-soul-sand", "manual-digsite-recipes", { item("iron-shovel-usage", 1), LABOR(2) },
		{ item("soul-sand", 64) }),
}
create_recipe{
	name = "nether-air-intake",
	category = "hv-compressor-recipes",   -- issue #314: an HV compressor (the maintainer's decision; EV would lock radon)
	energy_required = 10,
	subgroup = "subgroup-hv-compressor-recipes",
	ingredients = {},
	results = { fluid("nether-air", 1000) },
	main_product = "nether-air",
}

--- issue #501 (plan #494, V5): the Nether is a surface (165's planet gt-nether, surface property gt-dimension 2), reached
--- through a Nether Portal (scripts/fork-portals.lua): GTNH's obsidian frame lit with flint and steel, here one item
--- from 10 obsidian and the Flint and Steel (flint and an iron ingot, as Minecraft's). Obsidian in the steam age comes
--- from the Dig Site (the maintainer's choice: a stand-in for GTNH's lava pools); the LV fluid solidifier's stays.
--- Recipes of one dimension get surface_conditions: the nether air intake only in the Nether (the recipe abstraction
--- of #283 goes), the glowstone vein too (#494 decision 2: vanilla's Nether block), the water drilling rig not there
--- (the Nether has no water; its lava lakes give lava to an offshore pump, the lava boilers' fuel of #446).
local IN_NETHER = { { property = "gt-dimension", min = 2, max = 2 } }
data.raw.recipe["nether-air-intake"].surface_conditions = IN_NETHER
data.raw.recipe["mining-glowstone-vein"].surface_conditions = IN_NETHER
data.raw.recipe["water-drilling-rig"].surface_conditions = { { property = "gt-dimension", max = 1 } }
nether[#nether + 1] = manual("digging-obsidian", "manual-digsite-recipes", { PICKAXE, LABOR(8) }, { item("obsidian", 4) })
create_item{ name = "flint-and-steel", subgroup = "stone-age-production-machine", stack_size = 10,
	ingredients = { item("flint", 1), item("iron-ingot", 1) } }
create_item{ name = "nether-portal", subgroup = "stone-age-production-machine", place_result = "nether-portal",
	stack_size = 10, ingredients = { item("obsidian", 10), item("flint-and-steel", 1) } }
nether[#nether + 1] = "flint-and-steel"
nether[#nether + 1] = "nether-portal"
data:extend({ {
	type = "simple-entity-with-owner", name = "nether-portal",
	icon = "__gregtorio-continued__/graphics/icons/nether-portal.png", icon_size = 32,
	flags = { "placeable-player", "player-creation", "not-rotatable" },
	minable = { mining_time = 1, result = "nether-portal" }, max_health = 500,
	collision_box = { { -1.4, -1.4 }, { 1.4, 1.4 } }, selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
	collision_mask = { layers = {} },   -- walked onto: scripts/fork-portals.lua sends whoever steps in
	render_layer = "lower-object",
	picture = { filename = "__gregtorio-continued__/graphics/entity/fork/nether-portal.png", width = 192, height = 192,
		scale = 0.5 },
	localised_description = { "entity-description.nether-portal" },
} })

--------------------------------------------------------------------------------
--- THE TWILIGHT FOREST (issue #502, plan #494 V6): a surface (165's planet gt-twilight, surface property gt-dimension 3),
--- reached through a Twilight Portal (scripts/fork-portals.lua, 1:1). GTNH's portal is a 2x2 pool of water with 12
--- flowers around it, opened by tossing in a portal crystal (TwilightForest.cfg PortalCreationItem =
--- dreamcraft:TwilightCrystal, "a diamond is not enough"): here one 4x4 item from 4 buckets of water and the Twilight
--- Crystal (the mod has no flowers; the sprite draws them). The crystal is GTNH's assembler recipe (NewHorizonsCoreMod
--- AssemblerRecipes.java:926-930: a diamond and 4 LV circuits, 30 s at LV/2).
--------------------------------------------------------------------------------

local twilight = {}
create_item{ skip_recipe = true, name = "twilight-crystal", subgroup = "stone-age-production-machine", stack_size = 16 }
create_recipe{
	name = "twilight-crystal",
	category = "lv-assembling-machine-recipes",
	energy_required = 30 * LV_SPEED,
	subgroup = "stone-age-production-machine",
	ingredients = { item("diamond", 1), item("electronic-circuit", 4) },
	results = { item("twilight-crystal", 1) },
	main_product = "twilight-crystal",
}
create_item{ name = "twilight-portal", subgroup = "stone-age-production-machine", place_result = "twilight-portal",
	stack_size = 10, ingredients = { item("bucket-of-water", 4), item("twilight-crystal", 1) } }
twilight[#twilight + 1] = "twilight-crystal"
twilight[#twilight + 1] = "twilight-portal"
data:extend({ {
	type = "simple-entity-with-owner", name = "twilight-portal",
	icon = "__gregtorio-continued__/graphics/icons/twilight-portal.png", icon_size = 32,
	flags = { "placeable-player", "player-creation", "not-rotatable" },
	minable = { mining_time = 1, result = "twilight-portal" }, max_health = 500,
	collision_box = { { -1.9, -1.9 }, { 1.9, 1.9 } }, selection_box = { { -2, -2 }, { 2, 2 } },
	collision_mask = { layers = {} },   -- walked onto: scripts/fork-portals.lua sends whoever steps in
	render_layer = "lower-object",
	picture = { filename = "__gregtorio-continued__/graphics/entity/fork/twilight-portal.png", width = 256, height = 256,
		scale = 0.5 },
	localised_description = { "entity-description.twilight-portal" },
} })

--------------------------------------------------------------------------------
--- THE END
--------------------------------------------------------------------------------

local the_end = {
	manual("mining-end-stone", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("compressed-end-stone", 4) }),
}
create_recipe{
	name = "ender-air-intake",
	category = "hv-compressor-recipes",   -- issue #314: an HV compressor (the maintainer's decision; EV would lock radon)
	energy_required = 10,
	subgroup = "subgroup-hv-compressor-recipes",
	ingredients = {},
	results = { fluid("ender-air", 1000) },
	main_product = "ender-air",
}

--- issue #503 (plan #494, V7): The End is a surface (165's planet gt-end, surface property gt-dimension 4), reached through
--- an End Portal (scripts/fork-portals.lua): Minecraft's frame of 12 portal blocks, each with an Eye of Ender, here one
--- item from 12 Eyes of Ender. It leads to the main island (the exit portal at the origin) and back to the portal one
--- came through. The ender air intake and the end stone of the Dig Site work only in the End (#494 decision 2); the
--- radon route (161) stays at HV.
local IN_END = { { property = "gt-dimension", min = 4, max = 4 } }
data.raw.recipe["ender-air-intake"].surface_conditions = IN_END
data.raw.recipe["mining-end-stone"].surface_conditions = IN_END
create_item{ name = "end-portal", subgroup = "stone-age-production-machine", place_result = "end-portal",
	stack_size = 10, ingredients = { item("eye-of-ender", 12) } }
the_end[#the_end + 1] = "end-portal"
data:extend({ {
	type = "simple-entity-with-owner", name = "end-portal",
	icon = "__gregtorio-continued__/graphics/icons/end-portal.png", icon_size = 32,
	flags = { "placeable-player", "player-creation", "not-rotatable" },
	minable = { mining_time = 1, result = "end-portal" }, max_health = 500,
	collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } }, selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
	collision_mask = { layers = {} },   -- walked onto: scripts/fork-portals.lua sends whoever steps in
	render_layer = "lower-object",
	picture = { filename = "__gregtorio-continued__/graphics/entity/fork/end-portal.png", width = 320, height = 320,
		scale = 0.5 },
	localised_description = { "entity-description.end-portal" },
} })

--------------------------------------------------------------------------------
--- ENDER STORAGE (issue #504, plan #494 V8): EnderStorage's Ender Chest and Ender Tank, which GTNH uses to move items
--- and fluids between dimensions before AE2. Chests and tanks of the same three-colour code (16 wool colours each, left
--- to right) share their contents on every surface; scripts/fork-ender.lua sets the code in a panel beside the chest's
--- or tank's window. The Ender Chest is a linked-container (27 slots as EnderStorage's), the code its link_id; the
--- Ender Tank (1600, EnderStorage's 16 buckets in Gregtorio's tenth) is a storage tank whose group the script levels.
--- GTNH's recipes are IV arcane recipes (NewHorizonsCoreMod ScriptTCCoreMod.java, ENDERCHEST and ENDERTANK: nether star
--- plates or long blaze rods, dense enderium plates, the IV sensor and emitter, an obsidian chest or tank); the
--- maintainer's decision: the same shape at MV, an MV assembler recipe with the technology Ender Storage: ender eye
--- plates or blaze rods for the four corners, ender pearl plates for the dense enderium, the MV sensor and emitter, an
--- iron chest or a storage tank in the middle.
--------------------------------------------------------------------------------

do
	local function tint_layers(t, c)
		if type(t) ~= "table" then return end
		if t.filename or t.filenames then t.tint = c end
		for k, v in pairs(t) do if k ~= "tint" and type(v) == "table" then tint_layers(v, c) end end
	end
	local TINT = { 0.45, 0.75, 0.65 }
	local subgroup = data.raw.item["iron-chest"] and data.raw.item["iron-chest"].subgroup or "storage"
	local chest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
	chest.name = "ender-chest"
	chest.hidden = nil
	chest.icon, chest.icons, chest.icon_size = "__gregtorio-continued__/graphics/icons/ender-chest.png", nil, 32
	chest.inventory_size = 27
	chest.gui_mode = "none"   -- the code is set in scripts/fork-ender.lua's panel
	chest.minable = { mining_time = 0.5, result = "ender-chest" }
	chest.fast_replaceable_group = nil
	tint_layers(chest.picture, TINT)
	chest.localised_description = { "entity-description.ender-chest" }
	local tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
	tank.name = "ender-tank"
	tank.icon, tank.icons, tank.icon_size = "__gregtorio-continued__/graphics/icons/ender-tank.png", nil, 32
	tank.fluid_box.volume = 1600
	tank.minable = { mining_time = 0.5, result = "ender-tank" }
	tank.fast_replaceable_group = nil
	tank.next_upgrade = nil
	tint_layers(tank.pictures, TINT)
	tank.localised_description = { "entity-description.ender-tank" }
	data:extend({ chest, tank })
	for _, n in pairs({ "ender-chest", "ender-tank" }) do
		data:extend({ { type = "item", name = n, icon = "__gregtorio-continued__/graphics/icons/" .. n .. ".png",
			icon_size = 32, subgroup = subgroup, order = "z[ender]-" .. n, place_result = n, stack_size = 10 } })
	end
	local function recipe(name, corner, middle)
		create_recipe{
			name = name,
			category = "mv-assembling-machine-recipes",
			energy_required = 20 * MV_SPEED,
			subgroup = subgroup,
			ingredients = { item(corner, 4), item("ender-pearl-plate", 2), item("mv-sensor", 1), item("mv-emitter", 1),
				item(middle, 1) },
			results = { item(name, 1) },
			main_product = name,
		}
	end
	recipe("ender-chest", "ender-eye-plate", "iron-chest")
	recipe("ender-tank", "blaze-rod", "storage-tank")
end

--------------------------------------------------------------------------------
--- TECHNOLOGIES
--------------------------------------------------------------------------------

--- issue #501, the maintainer's decision: Reach the Nether in the steam age (after Iron Furnace, the first technology of
--- automation science; before: MV Machines and Extruder, three packs), before Rubber, which takes the Nether's sulfur
--- and sphalerite; every other first consumer of a Nether ore comes after Rubber; issue #573, the maintainer's choice: after
--- Steam Macerator too, so the steam macerator doubles the Nether's ores from Reach the Nether on (101's
--- fork_steam_ore_unlocks: the later of Steam Macerator and the ore's first technology)
F.tech{ name = NETHER, prerequisites = { "iron-furnace", "steam-macerator" }, packs = 1, count = 20, time = 30,
	recipes = nether }
table.insert(data.raw.technology["rubber"].prerequisites, NETHER)
--- issue #502: Reach the Twilight Forest in the LV age, after its crystal's LV assembler, LV circuits and diamond; before
--- Galena and Invar, whose galena, lead, silver and nickel veins are the Twilight Forest's now (GTNH's TFGalena is the
--- only T0 source of galena)
F.tech{ name = TWILIGHT, prerequisites = { "automation-2", "primitive-electronics", "steam-macerator" }, packs = 2,
	count = 30, time = 30, recipes = twilight }
for _, t in pairs({ "galena", "invar" }) do table.insert(data.raw.technology[t].prerequisites, TWILIGHT) end
F.tech{ name = END, prerequisites = { "eyes-of-ender", "hv-energy-hatches" }, packs = 4, count = 40, time = 30,
	recipes = the_end }
--- issue #504: Ender Storage at MV, after its eyes and pearls, the MV sensor, the MV emitter and the storage tank
F.tech{ name = "ender-storage", prerequisites = { "eyes-of-ender", "advanced-mv-machines", "laser-engraver",
	"fluid-handling" }, packs = 3, count = 40, time = 30, recipes = { "ender-chest", "ender-tank" } }
--- Endermen with the first use of their pearls; blaze rods come before it (161)
unlock_in("eyes-of-ender", { enderman })
unlock_in("extreme-entity-crushers", { "crushing-endermen" })
--- zombies with the first use of their heads (Ender IO's powered spawner)
unlock_in("ender-io", { zombie })
--- the nether air with its first consumer
unlock_in("end-steel", { "nether-air-intake" })



--------------------------------------------------------------------------------
--- GTNH'S OVERWORLD VEINS (issue #363, part 1): the veins of GT5-Unofficial 638b3f37ca OreMixes.java that are in the
--- Overworld and whose ores the mod lacked. The raw ores are GT's (create_ore, 07; GT's ore multiplier, cassiterite sand
--- 2); 155 gives them GTNH's chain, decomposition and smelting.
---   * a vein Gregtorio has under GT's name or with GT's main ores (upstream's veins: iron, magnetite, chalcopyrite = GT's
---     Copper, salt = GT's Salts, copper-tin = GT's CopperTin, basaltic mineral sands = GT's MineralSand) keeps what it
---     gives; GT's ores it lacked join it, 8 each (a sporadic ore's share), so no yield of the old vein changes;
---   * a vein without one is a new Manual Mine recipe with GT's ores at 32, 24, 16 and 8 (primary, secondary, in between,
---     sporadic; GT's LigniteCoal has lignite three times): LigniteCoal (with the Steam Forge Hammer, which turns raw
---     lignite into its gem, a fuel), Soapstone, GarnetTin, KaoliniteZeolite, Mica and Dolomite (with Ore Crushing, the
---     LV macerator of their crushed ores; the electrolyzer and centrifuge of their dusts come with or after it).
--- 163 gives every vein its Miner and Ore Drilling Plant twin.
--------------------------------------------------------------------------------

local VEIN_ORES_363 = {
	--  raw ore (GT material)          ore multiplier
	{ "lignite", 1 }, { "brown-limonite", 1 }, { "yellow-limonite", 1 }, { "banded-iron", 1 }, { "malachite", 1 },
	{ "magnetite", 1 }, { "chalcopyrite", 1 }, { "pyrite", 1 }, { "spodumene", 1 }, { "soapstone", 1 }, { "talc", 1 },
	{ "glauconite", 1 }, { "vermiculite", 1 }, { "alunite", 1 }, { "basaltic-mineral-sand", 1 },
	{ "granitic-mineral-sand", 1 }, { "cassiterite-sand", 2 }, { "garnet-sand", 1 }, { "asbestos", 1 }, { "diatomite", 1 },
	{ "kaolinite", 1 }, { "zeolite", 1 }, { "glauconite-sand", 1 }, { "kyanite", 1 }, { "mica", 1 }, { "pollucite", 1 },
	{ "dolomite", 1 }, { "wollastonite", 1 }, { "trona", 1 }, { "andradite", 1 },
}
--- the raw ores that only join a vein of a later technology are crushed from that technology on, like the vein's
--- other ores (crushed lepidolite with Hydrochloric Acid, crushed realgar with Primitive Electronic Circuit Assemblies)
local LATE_CRUSH_363 = { spodumene = "hydrochloric-acid", vermiculite = "primitive-electronic-circuit-assemblies",
	alunite = "primitive-electronic-circuit-assemblies" }
local crushed_363 = {}
for _, o in pairs(VEIN_ORES_363) do
	local x = o[1]
	create_ore("raw-" .. x, nil, "crushed-" .. x, x .. "-dust", nil, "crushed-" .. x, nil, nil, o[2], false, false)
	if LATE_CRUSH_363[x] then
		unlock_in(LATE_CRUSH_363[x], { "crushed-" .. x })
	else
		crushed_363[#crushed_363 + 1] = "crushed-" .. x
	end
end
--- GT's ores that join a vein Gregtorio has (8 each; issue #505: the copper-tin vein's is the one left, for its realgar)
local JOIN_363 = {
	["mining-copper-tin-vein"] = { "chalcopyrite", "vermiculite", "cassiterite", "alunite" },       -- GT CopperTin
}
for name, ores in pairs(JOIN_363) do
	local r = data.raw.recipe[name]
	--- (a recipe with several results needs an icon or a main product: the vein's first ore, as before)
	if not (r.icon or r.icons or r.main_product) then r.main_product = r.results[1].name end
	for _, x in pairs(ores) do r.results[#r.results + 1] = item("raw-" .. x, 8) end
end
--- (issue #505: the Lignite, Soapstone, Garnet Tin, Kaolinite Zeolite, Mica and Dolomite Vein recipes are gone, their
--- ores are Nauvis' map veins)
unlock_in("ore-crushing", crushed_363)



--------------------------------------------------------------------------------
--- GTNH'S TWILIGHT FOREST AND NETHER VEINS (issue #363, part 2), the same rules as part 1 above:
---   * the Twilight Forest's Olivine vein (bentonite, magnesite, olivine, glauconite) is a new Manual Mine recipe with NAND
---     Chips, as #332's Twilight Forest mines; its Nickel vein's garnierite joins upstream's nickel vein, the Molybdenum
---     vein's wulfenite and powellite the Nether's molybdenum vein (their crushed ores with the vein's other ores);
---   * the Nether's SaltPeterElectrotine vein (saltpeter, diatomite, alunite; electrotine, Project Red's, left out) is a
---     new Manual Mine recipe with Reach the Nether;
---   * the Twilight Forest's small ores the mod lacked (SmallOres.java: olivine, tanzanite, amethyst, opal, jasper, blue
---     topaz, spinel (GT's fools ruby), red and yellow garnet, jade, saltpeter) and its emerald and ruby join the small
---     ores' mine below, 8 of each.
--- The TF veins whose ores the mod mines elsewhere (coal, magnetite, gold, iron, salts, soapstone, apatite, lapis, galena)
--- get no second mine.
--------------------------------------------------------------------------------

local VEIN_ORES_363B = {
	--  raw ore, its dust (nil: <ore>-dust), GT's ore multiplier
	{ "olivine" }, { "bentonite" }, { "magnesite" }, { "garnierite" }, { "wulfenite" }, { "powellite" },
	{ "saltpeter", "saltpeter", 4 }, { "tanzanite" }, { "amethyst" }, { "opal" }, { "jasper" }, { "blue-topaz" },
	{ "spinel" }, { "jade" }, { "red-garnet" }, { "yellow-garnet" },
}
local CRUSH_363B = { garnierite = { "invar" }, wulfenite = { "tungstate-processing" }, powellite = { "tungstate-processing" },
	saltpeter = { "ore-crushing", "nand-chips" } }   -- issue #501: Ore Crushing, its LV macerator (Reach the Nether is a steam age technology)
for _, o in pairs(VEIN_ORES_363B) do
	local x = o[1]
	create_ore("raw-" .. x, nil, "crushed-" .. x, o[2] or (x .. "-dust"), nil, "crushed-" .. x, nil, nil, o[3] or 1, false,
		false)
	for _, t in pairs(CRUSH_363B[x] or { "nand-chips" }) do unlock_in(t, { "crushed-" .. x }) end
end
--- (issue #505: the Olivine and Saltpeter Electrotine Vein recipes are gone, their ores are the Twilight Forest's and the
--- Nether's map veins)
local TF_SMALL_363 = { "olivine", "tanzanite", "amethyst", "opal", "jasper", "blue-topaz", "spinel", "red-garnet",
	"yellow-garnet", "jade", "saltpeter", "emerald", "ruby" }



--------------------------------------------------------------------------------
--- ORE VEINS V1 (issue #496, plan #494): the raw ores of GTNH's T0 veins (prototypes/data/ore-mixes.lua) the mod
--- lacked, by #363's rules (a vein Gregtorio has gets GT's ores it lacked, 8 each; a vein without one is a new Manual
--- Mine recipe at GT's 32, 24, 16 and 8) until the map veins of #494 give them:
---   * quartzite (GT's NetherQuartz vein's sporadic ore, the Quartz vein's primary): a gem ore, its chain in 155; it joins
---     the nether quartz vein (circuit assembler);
---   * native molybdenum (the Molybdenum vein's in-between ore; GT's metal, no byproducts): it joins the Nether's
---     molybdenum vein, crushed with Tungstate Processing like the vein's other ores;
---   * oil sands (GT's OilSand vein, Overworld, its one ore four times): GT gives it no ore chain, the LV centrifuge turns
---     the ore into 2000 L heavy oil and sand at 40 % (ProcessingRawOre.java:48-56, 15 s); a new mine with that
---     centrifuge (Ore Washing).
--------------------------------------------------------------------------------

create_ore("raw-quartzite", nil, "crushed-quartzite", nil, nil, "crushed-quartzite", nil, nil, 1, false, false)
create_ore("raw-molybdenum", nil, "crushed-molybdenum", nil, nil, "crushed-molybdenum", nil, nil, 1, false, false)
create_item{ name = "raw-oilsands", subgroup = "subgroup-mining", skip_recipe = true }
create_recipe{
	name = "centrifuging-raw-oilsands",
	category = "lv-centrifuge-recipes",
	energy_required = 15,
	subgroup = "subgroup-lv-centrifuge-recipes",
	ingredients = { item("raw-oilsands", 1) },
	results = { fluid("heavy-oil", 200), { type = "item", name = "sand", amount = 1, independent_probability = 0.4 } },
	main_product = "heavy-oil",
}
unlock_in("circuit-assembler", { "crushed-quartzite" })
unlock_in("tungstate-processing", { "crushed-molybdenum" })
unlock_in("ore-washing", { "centrifuging-raw-oilsands" })   -- (issue #505: the Oil Sand Vein recipe is gone)



--------------------------------------------------------------------------------
--- THE TWILIGHT FOREST (issue #332, the maintainer's decision): GTNH's T0 dimension (DimensionHelper.java:99), two
--- recipes of the Manual Mine unlocked with NAND Chips, the first technology that needs them (the maintainer's choice: no
--- technology of their own). Its ores the mod lacked are topaz and amber, the two materials of GT's orange lens
--- (craftingLensOrange: the lens of every transparent dyeOrange material), which the simple SoC wafers need:
---   * the Aqua Ignis, Terra Aer and Perditio Ordo veins (OreMixes.java:534-570, Twilight Forest and Neper): Thaumcraft's
---     infused shards (primary, secondary; left out, the mod has no Thaumcraft), amber (in between), cinnabar
---     (sporadic); the three differ only by their shards: one mine, amber 32 as the first ore the mod has (as bornite
---     of Ross128), cinnabar 8;
---   * the small ores (SmallOres.java:214, 256, two of each per chunk): topaz (Twilight Forest and Horus) and amber,
---     8 of each, a quarter of a vein's first ore; the Twilight Forest's other small ores and veins hold ores the mod
---     mines elsewhere, so they get no mine (as #284/#285);
---   * issue #364: the Sapphire vein (OreMixes.java:375-386, Twilight Forest and Horus): almandine (primary), pyrope
---     (secondary), sapphire (in between) and green sapphire (sporadic), since issue #373 at GT's 32, 24, 16 and 8 (before,
---     without almandine and pyrope ores, sapphire 32); and the sapphire and green sapphire small ores (SmallOres.java,
---     Twilight Forest and Horus), 8 of each in the small ores' mine.
--- The raw ores are GT's (create_ore, 07): amber with GT's ore multiplier 2; create_ore makes no furnace recipe, 155
--- smelts them into their gem as GT does (issue #388);
--- 155 gives them GTNH's ore chain, gem grades and the amber lens (issue #364: sapphire and green sapphire their chain,
--- grades and juice; issue #370: their lenses, GTNH's blue and cyan lens).
--------------------------------------------------------------------------------

create_ore("raw-topaz", nil, "crushed-topaz", "topaz-dust", nil, "crushed-topaz", nil, nil, 1, false, false)
create_ore("raw-amber", nil, "crushed-amber", "amber-dust", nil, "crushed-amber", nil, nil, 2, false, false)
create_ore("raw-sapphire", nil, "crushed-sapphire", "sapphire-dust", nil, "crushed-sapphire", nil, nil, 1, false, false)
create_ore("raw-green-sapphire", nil, "crushed-green-sapphire", "green-sapphire-dust", nil, "crushed-green-sapphire", nil,
	nil, 1, false, false)
create_ore("raw-almandine", nil, "crushed-almandine", "almandine-dust", nil, "crushed-almandine", nil, nil, 1, false, false)
create_ore("raw-pyrope", nil, "crushed-pyrope", "pyrope-dust", nil, "crushed-pyrope", nil, nil, 1, false, false)
unlock_in("nand-chips", {
	manual("mining-amber-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-amber", 32), item("raw-cinnabar", 8) }),
	manual("mining-twilight-forest-small-ores", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-topaz", 8), item("raw-amber", 8), item("raw-sapphire", 8),
			item("raw-green-sapphire", 8) }),
	"crushed-topaz", "crushed-amber",
})
--- issue #370: the sapphire vein (issue #364) and the crushing of its ores come with the Laser Engraver, the first
--- consumer of the sapphire and green sapphire lens (the cyan and blue gem steps; the RAM wafer of Advanced Integrated
--- Circuits after it), no longer with NAND Chips (#252; #334 had put every Twilight Forest mine there)
unlock_in("laser-engraver", {   -- (issue #505: the Sapphire Vein recipe is gone, the Twilight Forest's map vein stays)
	"crushed-sapphire", "crushed-green-sapphire", "crushed-almandine", "crushed-pyrope",
})
--- issue #363: the Twilight Forest's other small ores (above), 8 of each
do
	local r = data.raw.recipe["mining-twilight-forest-small-ores"]
	if not (r.icon or r.icons or r.main_product) then r.main_product = r.results[1].name end
	for _, x in pairs(TF_SMALL_363) do r.results[#r.results + 1] = item("raw-" .. x, 8) end
end



--------------------------------------------------------------------------------
--- THE MOON AND MARS (issue #284): GTNH's T1 and T2 dimensions (rocket tiers of DimensionHelper.java), here HV and EV.
--- A mine per vein that holds a material the microverse gave, its GT ores in the mod's raw items (primary 32, the
--- others less, like the Overworld mines); GT's ores the mod lacks are left out:
---   Moon: TitaniumChrome (ilmenite, chromite; uvarovite, perlite left out), Bauxite (bauxite, ilmenite, aluminium),
---         Monazite (Moon, Deimos: bastnasite, monazite, neodymium)
---   Mars: Tungstate (Mars, Deimos: scheelite, tungstate; lithium left out), Pitchblende (Mars, Phobos: pitchblende,
---         uraninite), Uranium (Deimos, Phobos: uraninite)
--------------------------------------------------------------------------------

local MOON, MARS = "reach-the-moon", "reach-mars"
local moon = {
	manual("mining-titanium-chrome-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-ilmenite", 32), item("raw-chromite", 24) }),
	manual("mining-bauxite-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-bauxite", 32), item("raw-ilmenite", 16), item("raw-aluminium", 8) }),
	manual("mining-monazite-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-bastnasite", 32), item("raw-monazite", 16), item("raw-neodymium", 8) }),
}
--- issue #365: GTNH's Desh vein (OreMixes.java:707-717, Mars, Anubis, Miranda: desh twice, scheelite, tungstate), the
--- desh of the Digester's rotors (159); desh is GT's material (create_ore, 155's chain, its blast furnace)
create_ore("raw-desh", nil, "crushed-desh", "desh-dust", nil, "crushed-desh", nil, nil, 1, false, false)
local mars = {
	manual("mining-desh-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-desh", 56), item("raw-scheelite", 16), item("raw-tungstate", 8) }),
	"crushed-desh",
	manual("mining-tungstate-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-scheelite", 32), item("raw-tungstate", 16) }),
	manual("mining-pitchblende-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-pitchblende", 32), item("raw-uraninite", 16) }),
	manual("mining-uranium-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-uraninite", 32) }),
}
F.tech{ name = MOON, prerequisites = { END, "implosion-compressor" }, packs = 4, count = 40, time = 30, recipes = moon }
F.tech{ name = MARS, prerequisites = { MOON, "ev-components" }, packs = 5, count = 30, time = 45, recipes = mars }
--- moon turf (issue #287: it came from the tier four microminer mission): a dig site like the Nether's soul sand; the
--- macerator and centrifuge steps are upstream's (its 52-microverse-module.lua), the metal mixture's centrifuge takes
--- the mixture (upstream: moon dust, a slip)
create_item{ skip_recipe = true, name = "compressed-moon-turf", subgroup = "subgroup-mining" }
create_item{ skip_recipe = true, name = "extraterrestrial-metal-mixture", subgroup = "subgroup-hv-centrifuge-recipes" }
create_item{ skip_recipe = true, name = "mysterious-crystal-dust", subgroup = "subgroup-hv-centrifuge-recipes" }
create_item{
	name = "moon-dust",
	category = "hv-macerator-recipes",
	energy_required = HV_SPEED * 4,
	ingredients = { item("compressed-moon-turf", 1) },
	results = { item("moon-dust", 9) },
}
create_recipe{
	recipe_name = "moon-dust-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 5,
	ingredients = { item("moon-dust", 1) },
	results = {
		{ type = "item", name = "stone-dust", amount = 1, independent_probability = 0.25 },
		{ type = "item", name = "bauxite-dust", amount = 1, independent_probability = 0.23 },
		{ type = "item", name = "silicon-dioxide", amount = 1, independent_probability = 0.2 },
		{ type = "item", name = "quicklime", amount = 1, independent_probability = 0.14 },
		{ type = "item", name = "molybdenum-dust", amount = 1, independent_probability = 0.1 },
		{ type = "item", name = "extraterrestrial-metal-mixture", amount = 1, independent_probability = 0.08 },
		fluid("deuterium", 10),
	},
	main_product = "deuterium",
}
create_recipe{
	recipe_name = "extraterrestrial-metal-mixture-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 50,
	ingredients = { item("extraterrestrial-metal-mixture", 1) },
	results = {
		{ type = "item", name = "ilmenite-dust", amount = 1, independent_probability = 0.6 },
		{ type = "item", name = "chromium-dust", amount = 1, independent_probability = 0.4 },
		{ type = "item", name = "pyrolusite-dust", amount = 1, independent_probability = 0.35 },
		{ type = "item", name = "molybdenum-dust", amount = 1, independent_probability = 0.22 },
		{ type = "item", name = "tungstate-dust", amount = 1, independent_probability = 0.17 },
		{ type = "item", name = "mysterious-crystal-dust", amount = 1, independent_probability = 0.1 },
	},
	main_product = "mysterious-crystal-dust",
}
unlock_in(MOON, { manual("digging-moon-turf", "manual-digsite-recipes", { item("iron-shovel-usage", 1), LABOR(2) },
	{ item("compressed-moon-turf", 7) }), "moon-dust", "moon-dust-centrifuging", "extraterrestrial-metal-mixture-centrifuging" })



--------------------------------------------------------------------------------
--- T3 AND T4 (issue #285): the asteroid belt and Jupiter's moons (GTNH's T3, here IV) and Venus (T4, here LuV).
--- GTNH's End asteroids (T0 there) hold the same naquadah, platinum and tungstate veins; they come here with the
--- asteroids. T5 (Titan, Enceladus, Oberon, Miranda) holds nothing the mod still needs from the microverse.
---   Asteroids: Platinum (cooperite = sheldonite, palladium, platinum; iridium left out), Naquadah (naquadah; enriched
---              naquadah left out)
---   Callisto:  CallistoIce (callisto ice; topaz, blue topaz, alduorite left out)
---   Europa:    Ledox (ledox; opal, orichalcum, rubracium left out)
---   Venus:     Quantium (quantium; amethyst, rutile, ardite left out)
--- Callisto ice and quantium come as dust, as the microminer gave them.
--------------------------------------------------------------------------------

local ASTEROIDS, JOVIAN, VENUS = "reach-the-asteroid-belt", "reach-the-jovian-moons", "reach-venus"
local asteroids = {
	manual("mining-platinum-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-sheldonite", 32), item("raw-palladium", 24), item("raw-platinum", 16) }),
	manual("mining-naquadah-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-naquadah", 32) }),
}
local jovian = {
	manual("mining-callisto-ice-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("callisto-ice-dust", 32) }),
	manual("mining-ledox-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-ledox", 32) }),
}
local venus = {
	manual("mining-quantium-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("quantium-dust", 32) }),
}
F.tech{ name = ASTEROIDS, prerequisites = { MARS, "iv-machines" }, packs = 6, count = 50, time = 60, recipes = asteroids }
F.tech{ name = JOVIAN, prerequisites = { ASTEROIDS }, packs = 6, count = 50, time = 60, recipes = jovian }
F.tech{ name = VENUS, prerequisites = { JOVIAN, "luv-machines" }, packs = 7, count = 50, time = 60, recipes = venus }



--------------------------------------------------------------------------------
--- ROSS128 (issue #293): bartworks' Ross128b, GTNH's T3 (DimensionHelper.java:118), here IV like the asteroid belt.
--- Issue #373 (the maintainer's decision): every vein of Ross128b and of its moon Ross128ba (T5 at :130, here ZPM: Reach
--- Ross128ba) at GT's 32, 24, 16 and 8 (primary, secondary, in between, sporadic; an ore named twice adds up); the ores
--- the mod lacked are raw ores of create_ore, 155 gives them their chain (NEW_ORES: bartworks' byproducts, mass and
--- decomposition; the gem ores' grades). Ross128ba's Tungstate, TurmalinAlkali, CopperSulfits and RedZircon veins are
--- Ross128b's: one mine each, with Reach Ross128.
---   Ross128b (OreMixes.java:1351-1460): Thorianit (thorianite, uraninite, lepidolite, spodumene), Carbon (graphite,
---     diamond, coal, graphite), Bismuth (bismuthinite, stibnite, bismuth, bismutite), TurmalinAlkali (olenite,
---     fluor-buergerite, chromo-alumino-povondraite, vanadio-oxy-dravite), Roquesit (arsenopyrite, ferberite,
---     loellingite, roquesite), Tungstate (ferberite, huebnerite, loellingite, scheelite), CopperSulfits (djurleite,
---     bornite, wittichenite, tetrahedrite; issue #293 had bornite 32 and tetrahedrite 8, bornite's only source in
---     GTNH), Forsterit (forsterite, fayalite, orange and red descloizite), Hedenbergit (hedenbergite, fayalite, the
---     descloizites), RedZircon (fayalite, green fuchsite, red zircon, red fuchsite)
---   Ross128ba (:1461-1545): Tiberium (tiberium twice, enriched naquadah twice), Bart (BArTiMaEuSNeK four times),
---     Amethyst (amethyst, olivine, prasiolite, hedenbergite), Fluorspar (galena, sphalerite, fluorspar, barite)
--------------------------------------------------------------------------------

local ROSS, ROSS_BA = "reach-ross128", "reach-ross128ba"
for _, x in pairs({ "thorianite", "bismuthinite", "bismutite", "bismuth", "olenite", "fluor-buergerite", "chromo-alumino-povondraite", "vanadio-oxy-dravite", "arsenopyrite", "ferberite", "loellingite", "roquesite", "huebnerite", "djurleite", "wittichenite", "forsterite", "fayalite", "orange-descloizite", "red-descloizite", "hedenbergite", "green-fuchsite", "red-fuchsite", "red-zircon", "tiberium", "enriched-naquadah", "bartimaeusnek", "prasiolite", "fluorspar" }) do
	local dust = ({ ["thorianite"] = "thorianite", ["bismuth"] = "bismuth", ["enriched-naquadah"] = "enriched-naquadah-oxide-mixture", ["fluorspar"] = "fluorspar", ["red-zircon"] = "red-zircon-dust" })[x]
	--- (a dust the mod has already keeps its item: create_ore makes only the new ones; red zircon dust is 159's, which
	--- loads after 155, so it is made here, in 159's row)
	if x == "red-zircon" and not data.raw.item["red-zircon-dust"] then
		create_item{ skip_recipe = true, name = "red-zircon-dust", subgroup = "subgroup-digester-recipes" }
	end
	create_ore("raw-" .. x, nil, "crushed-" .. x, not dust and (x .. "-dust") or nil, nil, "crushed-" .. x, nil, nil, 1,
		false, false)
end
local function vein(name, ores)   -- GT's four ores at 32, 24, 16, 8; an ore named twice adds up
	local amounts, order = {}, {}
	for i, x in pairs(ores) do
		if not amounts[x] then order[#order + 1] = x end
		amounts[x] = (amounts[x] or 0) + ({ 32, 24, 16, 8 })[i]
	end
	local results = {}
	for _, x in pairs(order) do results[#results + 1] = item("raw-" .. x, amounts[x]) end
	return manual(name, "manual-mine-recipes", { PICKAXE, LABOR(24) }, results)
end
local ross_b = {
	vein("mining-thorianite-vein", { "thorianite", "uraninite", "lepidolite", "spodumene" }),
	vein("mining-carbon-vein", { "graphite", "diamond", "coal", "graphite" }),
	vein("mining-bismuth-vein", { "bismuthinite", "stibnite", "bismuth", "bismutite" }),
	vein("mining-alkali-tourmaline-vein", { "olenite", "fluor-buergerite", "chromo-alumino-povondraite", "vanadio-oxy-dravite" }),
	vein("mining-roquesite-vein", { "arsenopyrite", "ferberite", "loellingite", "roquesite" }),
	vein("mining-ross128-tungstate-vein", { "ferberite", "huebnerite", "loellingite", "scheelite" }),
	vein("mining-copper-sulfide-vein", { "djurleite", "bornite", "wittichenite", "tetrahedrite" }),
	vein("mining-forsterite-vein", { "forsterite", "fayalite", "orange-descloizite", "red-descloizite" }),
	vein("mining-hedenbergite-vein", { "hedenbergite", "fayalite", "orange-descloizite", "red-descloizite" }),
	vein("mining-red-zircon-vein", { "fayalite", "green-fuchsite", "red-zircon", "red-fuchsite" }),
}
for _, x in pairs({ "thorianite", "bismuthinite", "bismutite", "bismuth", "olenite", "fluor-buergerite", "chromo-alumino-povondraite", "vanadio-oxy-dravite", "arsenopyrite", "ferberite", "loellingite", "roquesite", "huebnerite", "djurleite", "wittichenite", "forsterite", "fayalite", "orange-descloizite", "red-descloizite", "hedenbergite", "green-fuchsite", "red-fuchsite", "red-zircon" }) do ross_b[#ross_b + 1] = "crushed-" .. x end
F.tech{ name = ROSS, prerequisites = { MARS, "iv-machines" }, packs = 6, count = 50, time = 60, recipes = ross_b }
local ross_ba = {
	vein("mining-tiberium-vein", { "tiberium", "tiberium", "enriched-naquadah", "enriched-naquadah" }),
	vein("mining-bartimaeusnek-vein", { "bartimaeusnek", "bartimaeusnek", "bartimaeusnek", "bartimaeusnek" }),
	vein("mining-ross128ba-amethyst-vein", { "amethyst", "olivine", "prasiolite", "hedenbergite" }),
	vein("mining-fluorspar-vein", { "galena", "sphalerite", "fluorspar", "barite" }),
}
for _, x in pairs({ "tiberium", "enriched-naquadah", "bartimaeusnek", "prasiolite", "fluorspar" }) do ross_ba[#ross_ba + 1] = "crushed-" .. x end
F.tech{ name = ROSS_BA, prerequisites = { ROSS, VENUS, "zpm-machines" }, packs = 8, count = 50, time = 60,
	recipes = ross_ba }



--------------------------------------------------------------------------------
--- THE TOXIC EVERGLADES (issue #373, group 3): GT++'s dimension (GTNH's T0 in DimensionHelper.java:102, reached by a
--- portal whose Containment Frame is a LuV assembler recipe, gtPlusPlus/core/recipe/RecipesMachines.java:164-178:
--- here LuV, Reach the Toxic Everglades). Its veins GTPP0 to GTPP19 (OreMixes.java:1131-1349) at GT's 32, 24, 16, 8,
--- GT++'s ores as raw ores of create_ore with 155's chain (NEW_ORES). GTPP0 is GT's iron four times.
--------------------------------------------------------------------------------

local EVERGLADES = "reach-the-everglades"
for _, x in pairs({ "agardite-cd", "agardite-la", "agardite-nd", "agardite-y", "alburnite", "barite-ra", "cerite", "crocoite", "cryolite-f", "demicheleite-br", "florencite", "fluorcaphite", "gadolinite-ce", "gadolinite-y", "geikielite", "hibonite", "honeaite", "irarsite", "kashinite", "lafossaite", "lanthanite-ce", "lanthanite-la", "lautarite", "lepersonnite", "miessiite", "nichromite", "perroudite", "polycrase", "samarskite-y", "samarskite-yb", "titanite", "xenotime", "yttrialite", "yttrocerite", "zimbabweite", "zircon", "zirconolite", "zirkelite", "fluorite-f", "runite" }) do
	local dust = ({ ["agardite-cd"] = true, yttrialite = true, ["lanthanite-ce"] = true })[x]
	create_ore("raw-" .. x, nil, "crushed-" .. x, not dust and (x .. "-dust") or nil, nil, "crushed-" .. x, nil, nil, 1,
		false, false)
end
local GTPP = {
	{ "iron", "iron", "iron", "iron" },
	{ "agardite-cd", "agardite-la", "demicheleite-br", "irarsite" },
	{ "agardite-nd", "agardite-y", "kashinite", "cerite" },
	{ "cerite", "nichromite", "xenotime", "hibonite" },
	{ "geikielite", "cryolite-f", "gadolinite-ce", "agardite-nd" },
	{ "hibonite", "yttrialite", "zirconolite", "cerite" },
	{ "xenotime", "zirkelite", "crocoite", "irarsite" },
	{ "honeaite", "miessiite", "samarskite-y", "samarskite-yb" },
	{ "titanite", "zimbabweite", "zircon", "florencite" },
	{ "lanthanite-ce", "fluorite-f", "lafossaite", "florencite" },
	{ "geikielite", "yttrocerite", "lanthanite-la", "barite-ra" },
	{ "fluorite-f", "kashinite", "zircon", "cryolite-f" },
	{ "cerite", "alburnite", "miessiite", "hibonite" },
	{ "cryolite-f", "barite-ra", "honeaite", "florencite" },
	{ "demicheleite-br", "perroudite", "irarsite", "barite-ra" },
	{ "fluorcaphite", "lafossaite", "gadolinite-ce", "gadolinite-y" },
	{ "yttrocerite", "lepersonnite", "lautarite", "fluorite-f" },
	{ "florencite", "lautarite", "samarskite-yb", "polycrase" },
	{ "gadolinite-ce", "gadolinite-y", "agardite-la", "agardite-cd" },
	{ "runite", "runite", "runite", "runite" },
}
local everglades = {}
for i, ores in ipairs(GTPP) do everglades[#everglades + 1] = vein("mining-everglades-gtpp" .. (i - 1) .. "-vein", ores) end
for _, x in pairs({ "agardite-cd", "agardite-la", "agardite-nd", "agardite-y", "alburnite", "barite-ra", "cerite", "crocoite", "cryolite-f", "demicheleite-br", "florencite", "fluorcaphite", "gadolinite-ce", "gadolinite-y", "geikielite", "hibonite", "honeaite", "irarsite", "kashinite", "lafossaite", "lanthanite-ce", "lanthanite-la", "lautarite", "lepersonnite", "miessiite", "nichromite", "perroudite", "polycrase", "samarskite-y", "samarskite-yb", "titanite", "xenotime", "yttrialite", "yttrocerite", "zimbabweite", "zircon", "zirconolite", "zirkelite", "fluorite-f", "runite" }) do everglades[#everglades + 1] = "crushed-" .. x end
--- (the MV and HV Dehydrators' technologies are prerequisites: GT++ decomposes the ores of 7 to 9 components and
--- fluorite (F) in the chemical dehydrator, #252)
F.tech{ name = EVERGLADES, prerequisites = { "luv-machines", "naquadah-processing", "hydrazine-rocket-fuels",
	"samaric-rare-earth-processing" }, packs = 7, count = 50, time = 60, recipes = everglades }



--------------------------------------------------------------------------------
--- THE VOID MINERS (issue #286, the decision of #154: the late ores come from GTNH's late ore machines; the
--- maintainer chose the Void Miner only, with its full ore pools). bartworks' Void Miner I, II and III
--- (bwcrossmod/galacticgreg/MTEVoidMinerBase.java, MTEVoidMiners.java, VoidMinerUtility.java):
---   * it mines the ore pool of the dimension it stands in: the GT veins of the dimension (primary and secondary at the
---     vein's weight, in-between and sporadic at an eighth) and its small ores (their amount), one ore per 10 ticks
---     times the tier (I 2, II 4, III 6 ores per second); a noble gas multiplies it (neon x4, krypton x8, xenon x16;
---     oganesson x64 is not in the mod), 2 L per second;
---   * Gregtorio has no dimensions, so a recipe per dimension stands for the dimension, and the tier decides which:
---     Void Miner I Pluto (GTNH's T7: black plutonium, neutronium, adamantium), II Barnard F (T8: bedrockium), III Horus
---     and Anubis (T9: cosmic neutronium, infinity catalyst); a higher tier also mines the lower dimensions, at its speed;
---   * a recipe is 10 s of mining (20 ores at tier I), the pool as outputs at GT's weights (expected amounts); ores the
---     mod lacks are left out, not replaced (VOID_POOLS, from GT5-Unofficial af993ca6a9 OreMixes.java and SmallOres.java).
--- The controllers are GT's assembly line recipes (bartworks AssemblyLine.java 27-44, TecTechResearchLoader.java 34-67)
--- with stand-ins for parts the mod lacks: the IV drilling rig for GT's Ore Drilling Plant IV, iridium frames for the
--- netherite frames, xenon for the oganesson of Void Miner III. 3x3 copies of the chemical reactor with a gas input, as
--- the other GT multiblocks of these files (159); sprites from GT's mining casings and the ore drill front.
--------------------------------------------------------------------------------

local VOID_POOLS = {
	["pluto"] = {
		{ "raw-ilmenite", 0.06721 }, { "raw-bauxite", 0.05072 }, { "raw-graphite", 0.05072 }, { "raw-naquadah", 0.04628 },
		{ "raw-thorium", 0.04042 }, { "raw-beryllium", 0.03804 }, { "raw-black-plutonium", 0.02916 },
		{ "raw-gold", 0.01775 }, { "raw-chromite", 0.01522 }, { "raw-vanadium-magnetite", 0.01268 },
		{ "raw-scheelite", 0.01268 }, { "raw-silver", 0.01268 }, { "raw-nickel", 0.0122 }, { "raw-neutronium", 0.01141 },
		{ "raw-silicon", 0.01014 }, { "raw-lead", 0.01014 }, { "raw-aluminium", 0.00634 }, { "raw-adamantium", 0.00634 },
		{ "raw-platinum", 0.00634 }, { "raw-tungstate", 0.00586 }, { "quantium-dust", 0.0038 },
		{ "raw-molybdenite", 0.00317 }, { "raw-diamond", 0.00317 }, { "raw-coal", 0.00317 }, { "raw-borax", 0.00317 },
		{ "raw-ledox", 0.00254 }, { "raw-emerald", 0.00238 }, { "raw-sheldonite", 0.00079 }, { "raw-palladium", 0.00079 },
	},
	["barnard-f"] = {
		{ "raw-redstone", 0.0641 }, { "raw-iron", 0.05128 }, { "raw-pitchblende", 0.04274 }, { "raw-graphite", 0.04274 },
		{ "raw-naquadah", 0.039 }, { "raw-thorium", 0.03405 }, { "raw-bastnasite", 0.03205 }, { "raw-beryllium", 0.03205 },
		{ "raw-realgar", 0.01976 }, { "raw-gold", 0.01896 }, { "raw-vanadium-magnetite", 0.01068 },
		{ "raw-grossular", 0.01068 }, { "raw-spessartine", 0.01068 }, { "raw-neutronium", 0.00962 },
		{ "raw-silicon", 0.00855 }, { "raw-copper", 0.00534 }, { "raw-uraninite", 0.00534 }, { "raw-adamantium", 0.00534 },
		{ "raw-nickel", 0.00427 }, { "raw-ruby", 0.00401 }, { "raw-cinnabar", 0.00401 },
		{ "raw-black-plutonium", 0.00321 }, { "raw-bedrockium", 0.00321 }, { "raw-diamond", 0.00267 },
		{ "raw-coal", 0.00267 }, { "raw-monazite", 0.002 }, { "raw-neodymium", 0.002 }, { "raw-emerald", 0.002 },
		{ "raw-pyrolusite", 0.00134 }, { "raw-tantalite", 0.00134 },
	},
	["horus"] = {
		{ "raw-certus-quartz", 0.10275 }, { "raw-black-plutonium", 0.03052 }, { "raw-oriharukon", 0.02915 },   -- (#355 step 5)
		{ "quantium-dust", 0.02186 },
		{ "raw-ledox", 0.02186 }, { "raw-barite", 0.01457 }, { "raw-neutronium", 0.01093 },
		{ "raw-cosmic-neutronium", 0.01093 }, { "raw-sulfur", 0.01002 }, { "raw-borax", 0.00364 },
		{ "raw-realgar", 0.00364 }, { "raw-emerald", 0.00146 }, { "raw-ruby", 0.00146 }, { "raw-bedrockium", 0.00137 },
	},
	--- issue #373: Neper (GTNH's T9, DimensionHelper.java:167), its veins (OreMixes.java: AquaIgnis, TerraAer, Mica,
	--- TungstenIrons, HeavyPentele, CertusQuartz, Dilithium) with the dilithium, mysterious crystal and vinteum the mod
	--- lacked before; Thaumcraft's shards, arsenic, tungsten, antimony, quartz sand, charged certus quartz, shadow and deep
	--- iron left out (no ore of them in the mod)
	["neper"] = {
		{ "raw-certus-quartz", 0.24465 }, { "raw-bismuth", 0.12232 }, { "raw-dilithium", 0.12232 }, { "raw-kyanite", 0.04077 },
		{ "raw-mica", 0.04077 }, { "raw-silicon", 0.03262 }, { "raw-cinnabar", 0.00815 }, { "raw-amber", 0.00815 },
		{ "raw-vinteum", 0.00765 }, { "raw-mysterious-crystal", 0.00765 }, { "raw-pollucite", 0.0051 },
		{ "raw-cassiterite", 0.0051 },
	},
	["anubis"] = {
		{ "raw-sulfur", 0.17238 }, { "callisto-ice-dust", 0.03448 }, { "raw-galena", 0.03448 }, { "raw-silver", 0.03448 },
		{ "raw-neutronium", 0.01293 }, { "raw-adamantium", 0.01293 }, { "raw-sphalerite", 0.01077 },
		{ "raw-fullers-earth", 0.00862 }, { "raw-gypsum", 0.00862 }, { "raw-infinity-catalyst", 0.00679 },
		{ "raw-pentlandite", 0.00431 }, { "raw-lead", 0.00431 }, { "raw-cryolite", 0.00431 }, { "raw-scheelite", 0.00323 },
		{ "raw-tungstate", 0.00323 }, { "raw-cassiterite", 0.00215 }, { "raw-bedrockium", 0.00162 },
		{ "raw-bauxite", 0.00086 },
	},
}

--- issue #356 (the maintainer's decision on #417): the Mehen Belt, AmunRa's asteroid belt (GTNH's T9; GT5-Unofficial
--- 638b3f37ca OreMixes.java and SmallOres.java, enableInDim MehenBelt: 12 veins, 7 small ores), for its awakened
--- draconium vein (draconium, draconium, awakened draconium, nether star); the draconium ores are new (155), titanium,
--- iridium, chrome, osmium, uranium, nether star, perlite, uvarovite and mithril ore are left out (no ore of them in the
--- mod)
VOID_POOLS["mehen-belt"] = {
	{ "raw-tin", 0.18464 }, { "raw-nickel", 0.09249 }, { "raw-bentonite", 0.08013 }, { "raw-magnesite", 0.08013 },
	{ "raw-garnierite", 0.05342 }, { "raw-lazurite", 0.05342 }, { "raw-sodalite", 0.05342 }, { "raw-uraninite", 0.05342 },
	{ "raw-draconium", 0.05342 }, { "raw-chromite", 0.03205 }, { "raw-neutronium", 0.02404 }, { "raw-ilmenite", 0.02137 },
	{ "raw-platinum", 0.01419 }, { "raw-adamantium", 0.01336 }, { "raw-olivine", 0.01269 }, { "raw-lapis", 0.01202 },
	{ "raw-palladium", 0.01002 }, { "raw-glauconite", 0.01002 }, { "raw-cassiterite", 0.00835 },
	{ "raw-sheldonite", 0.00835 }, { "raw-pentlandite", 0.00668 }, { "raw-cobaltite", 0.00668 },
	{ "raw-calcite", 0.00668 }, { "raw-awakened-draconium", 0.00334 }, { "raw-naquadah", 0.00167 },
}

local VM_PICKS = 20                -- ores per recipe at tier I (2 per second, 10 s)
local VM_GAS = { { nil, 1 }, { "neon", 4 }, { "krypton", 8 }, { "xenon", 16 } }
local VM_DIMS = { { "pluto", 1 }, { "barnard-f", 2 }, { "horus", 3 }, { "anubis", 3 }, { "neper", 3 },
	{ "mehen-belt", 3 } }   -- neper: #373, mehen-belt: #356
--- issue #373: Neper's ores the mod lacked (GT's dilithium, mysterious crystal and vinteum; the mysterious crystal dust is
--- the moon dust's above)
create_ore("raw-dilithium", nil, "crushed-dilithium", "dilithium-dust", nil, "crushed-dilithium", nil, nil, 1, false, false)
create_ore("raw-mysterious-crystal", nil, "crushed-mysterious-crystal", nil, nil, "crushed-mysterious-crystal", nil, nil, 1,
	false, false)
create_ore("raw-vinteum", nil, "crushed-vinteum", "vinteum-dust", nil, "crushed-vinteum", nil, nil, 1, false, false)
--- issue #355 step 5: Horus's oriharukon (GT's Oriharukon vein, OreMixes.java:773-782, Horus, Deimos and Phobos;
--- its tanzanite, vyroxeres and mirabilite left out as before) for GT New Horizons' Melodic Alloy (164 section 36)
create_ore("raw-oriharukon", nil, "crushed-oriharukon", "oriharukon-dust", nil, "crushed-oriharukon", nil, nil, 1, false,
	false)
--- issue #356: the Mehen Belt's draconium and awakened draconium (their metals in 164 section 22)
create_ore("raw-draconium", nil, "crushed-draconium", "draconium-dust", nil, "crushed-draconium", nil, nil, 1, false, false)
create_ore("raw-awakened-draconium", nil, "crushed-awakened-draconium", "awakened-draconium-dust", nil,
	"crushed-awakened-draconium", nil, nil, 1, false, false)
local VM_TECHS = { "void-miner-i", "void-miner-ii", "void-miner-iii" }

--- an output of the expected amount `e`
local function expected(name, e)
	if e < 1 then return { type = "item", name = name, amount = 1, independent_probability = e } end
	local n = math.floor(e)
	local r = { type = "item", name = name, amount = n }
	if e - n > 0.001 then r.extra_count_fraction = e - n end
	return r
end

local vm_recipes = { {}, {}, {} }
for tier = 1, 3 do F.category("void-miner-" .. tier .. "-recipes") end
for _, d in pairs(VM_DIMS) do
	for _, g in pairs(VM_GAS) do
		local name = "void-mining-" .. d[1] .. (g[1] and ("-" .. g[1]) or "")
		local results = {}
		for _, o in pairs(VOID_POOLS[d[1]]) do results[#results + 1] = expected(o[1], VM_PICKS * g[2] * o[2]) end
		create_recipe{
			name = name,
			category = "void-miner-" .. d[2] .. "-recipes",
			energy_required = 10,
			subgroup = "subgroup-void-miner-" .. d[2] .. "-recipes",
			ingredients = g[1] and { fluid(g[1], 2) } or {},
			results = results,
			main_product = results[1].name,
			icon = "__gregtorio-continued__/graphics/icons/fork/void-miner-" .. ({ "i", "ii", "iii" })[d[2]] .. ".png",
		}
		local list = vm_recipes[d[2]]
		list[#list + 1] = name
	end
end

--- the machines
local function void_miner(tier, energy, recipe)
	local name = "void-miner-" .. ({ "i", "ii", "iii" })[tier]
	local m = table.deepcopy(data.raw["assembling-machine"]["hv-chemical-reactor"])
	m.name = name
	m.icons = nil
	m.icon = "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = name }
	local cats = {}
	for t = 1, tier do cats[#cats + 1] = "void-miner-" .. t .. "-recipes" end
	m.crafting_categories = cats
	m.crafting_speed = tier
	m.energy_usage = energy
	m.fast_replaceable_group = "fr-void-miner"
	m.next_upgrade = nil
	m.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fluid_boxes = { {
		production_type = "input", volume = 1000, pipe_covers = pipecoverspictures(), pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
	} }
	m.fluid_boxes_off_when_no_fluid_recipe = true
	m.graphics_set = {
		idle_animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-idle.png",
			width = 96, height = 96, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-working.png",
			width = 96, height = 96, frame_count = 1, shift = { 0, 0 } } } },
	}
	m.localised_description = { "entity-description." .. name }
	data:extend({ m })
	create_item{
		name = name,
		icon = m.icon,
		place_result = name,
		subgroup = ({ "subgroup-luv-age-multiblocks", "subgroup-zpm-age-multiblocks", "subgroup-uv-age-multiblocks" })[tier],
		stack_size = 10,
		category = recipe[1],
		energy_required = recipe[2],
		ingredients = recipe[3],
	}
	return name
end
local function parts(list)
	local out = {}
	for i = 1, #list, 2 do
		local n = list[i]
		out[#out + 1] = { type = data.raw.fluid[n] and "fluid" or "item", name = n, amount = list[i + 1] }
	end
	return out
end
local vm1 = void_miner(1, EU16_LuV, { "luv-assembly-line-recipes", 120 * LUV_SPEED, parts{
	"iv-drilling-rig", 1, "iridium-frame", 4, "europium-plate", 3, "luv-motor", 9, "luv-sensor", 9,
	"luv-field-generator", 9, "europium-screw", 36, "molten-indalloy-140", 144, "neon", 2000 } })
local vm2 = void_miner(2, EU16_ZPM, { "zpm-assembly-line-recipes", 120 * ZPM_SPEED, parts{
	vm1, 1, "black-plutonium-frame", 9, "black-plutonium-plate", 3, "zpm-motor", 9, "zpm-sensor", 9,
	"zpm-field-generator", 9, "black-plutonium-screw", 36, "molten-indalloy-140", 144, "krypton", 2000 } })
--- (the UV recipes of the assembly line run in the ZPM one, 127: there is no UV assembly line; issue #287 found the
--- category without a machine once the microminer missions no longer gave the Void Miner III's ores)
local vm3 = void_miner(3, EU16_UV, { "zpm-assembly-line-recipes", 120 * UV_SPEED, parts{
	vm2, 1, "neutronium-frame", 9, "neutronium-plate", 3, "uv-motor", 9, "uv-sensor", 9,
	"uv-field-generator", 9, "neutronium-screw", 36, "molten-indalloy-140", 144, "xenon", 2000 } })

F.tech{ name = VM_TECHS[1], prerequisites = { VENUS, "assembly-line", "luv-components" }, packs = 7, count = 50,
	time = 60, recipes = F.join({ vm1 }, vm_recipes[1]) }
F.tech{ name = VM_TECHS[2], prerequisites = { VM_TECHS[1], "zpm-assembly-line", "zpm-components",
	"crystal-processor-mainframes" }, packs = 8, count = 50, time = 60, recipes = F.join({ vm2 }, vm_recipes[2]) }
F.tech{ name = VM_TECHS[3], prerequisites = { VM_TECHS[2], "uv-components" }, packs = 9, count = 50, time = 60,
	recipes = F.join({ vm3 }, vm_recipes[3]) }
unlock_in(VM_TECHS[3], { "crushed-dilithium", "crushed-mysterious-crystal", "crushed-vinteum" })   -- issue #373: Neper
unlock_in(VM_TECHS[3], { "crushed-draconium", "crushed-awakened-draconium" })   -- issue #356: the Mehen Belt
unlock_in(VM_TECHS[3], { "crushed-oriharukon" })   -- issue #355 step 5: Horus's oriharukon
