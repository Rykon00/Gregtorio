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
--- issue #617 (the maintainer's decision of 2026-10-28): ancient debris, the start of GT's netherite chain
--- (gregtech/loaders/postload/chains/NetheriteRecipes.java:313-321), lies in GTNH's Nether scattered like small ores
--- (Et Futurum Requiem's world gen, GT-New-Horizons-Modpack config/etfuturum/world.cfg:110-111, 182-183: veins of 2 or 3);
--- a Manual Mine recipe in the Nether like the glowstone vein, with 163's electric twins; unlocked by 164 section 48
create_item{ name = "ancient-debris", subgroup = "subgroup-mining", skip_recipe = true }
manual("mining-ancient-debris", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("ancient-debris", 2) })
data.raw.recipe["mining-ancient-debris"].surface_conditions = IN_NETHER
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
	local subgroup = data.raw.item["iron-chest"] and data.raw.item["iron-chest"].subgroup or "storage"
	local chest = table.deepcopy(data.raw["linked-container"]["linked-chest"])
	chest.name = "ender-chest"
	chest.hidden = nil
	chest.icon, chest.icons, chest.icon_size = "__gregtorio-continued__/graphics/icons/ender-chest.png", nil, 32
	chest.inventory_size = 27
	chest.gui_mode = "none"   -- the code is set in scripts/fork-ender.lua's panel
	chest.minable = { mining_time = 0.5, result = "ender-chest" }
	chest.fast_replaceable_group = nil
	--- issue #654: drawn sprites (tools/gen_icons.py --drawn) instead of the tinted vanilla chest and tank
	chest.picture = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/ender-chest.png", size = 64, scale = 0.5 } } }
	chest.localised_description = { "entity-description.ender-chest" }
	local tank = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
	tank.name = "ender-tank"
	tank.icon, tank.icons, tank.icon_size = "__gregtorio-continued__/graphics/icons/ender-tank.png", nil, 32
	tank.fluid_box.volume = 1600
	tank.minable = { mining_time = 0.5, result = "ender-tank" }
	tank.fast_replaceable_group = nil
	tank.next_upgrade = nil
	local tank_sprite = { filename = "__gregtorio-continued__/graphics/entity/fork/ender-tank.png", size = 192, scale = 0.5 }
	tank.pictures.picture = { north = tank_sprite, east = tank_sprite, south = tank_sprite, west = tank_sprite }
	tank.window_bounding_box = { { -0.35, -0.22 }, { 0.35, 0.5 } }   -- (the window the sprite draws)
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
--- PHOBOS, DEIMOS AND THE MOON (issue #636, the maintainer's decision of 2026-10-28): every GTNH vein of the Moon (T1,
--- here HV) and of Mars's moons Phobos and Deimos (T2, here EV with Reach Mars) is mined, as a mine at GT's 32, 24, 16
--- and 8 as Ross128's (the vein() above). The veins that had none (GT5-Unofficial f2814df OreMixes.java,
--- prototypes/data/ore-mixes.lua):
---   Draconium (Deimos, Phobos: draconium, electrotine, jade, vinteum; electrotine left out, no material in the mod)
---   Oriharukon (Deimos, Phobos: oriharukon, tanzanite, vyroxeres, mirabilite; the last two left out, as before)
---   HeavyPentele (Mars, Phobos: arsenic, bismuth, antimony twice)
--- QuartzSpace (Moon, Mars, Phobos: quartzite, barite, certus quartz) gets none: its ores are the map veins' (163 hides
--- such a mine). The other veins had their mine (the Moon's and Mars's above, the Overworld's, the Nether's, the End's).
--- Draconium, oriharukon and vinteum came from the Void Miner III (UV) only; GTNH has them at T2. Arsenic and antimony
--- are new raw ores (create_ore; their dusts are the mod's; 155 gives them GT's chain).
--------------------------------------------------------------------------------

create_ore("raw-arsenic", nil, "crushed-arsenic", nil, nil, "crushed-arsenic", nil, nil, 1, false, false)
create_ore("raw-antimony", nil, "crushed-antimony", nil, nil, "crushed-antimony", nil, nil, 1, false, false)
unlock_in(MARS, {
	vein("mining-draconium-vein", { "draconium", nil, "jade", "vinteum" }),
	vein("mining-oriharukon-vein", { "oriharukon", "tanzanite" }),
	vein("mining-heavy-pentele-vein", { "arsenic", "bismuth", "antimony", "antimony" }),
	"crushed-arsenic", "crushed-antimony",
})



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
--- issue #632: GT's radium, barite (Ra)'s byproduct and electrolysis product (155)
create_item{ skip_recipe = true, name = "radium-dust", subgroup = "subgroup-macerator-dust" }
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
--- issue #636 (the maintainer's decision of 2026-10-28): every other dimension of GTNH's T3 to T9 that the Void Miner
--- may mine (bwcrossmod/galacticgreg/VoidMinerUtility.java:221-266 generateDropMaps: the veins' primary and secondary
--- ore at the vein's weight, in-between and sporadic at an eighth, the small ores at their amount; GTNH's asteroid belts,
--- the Asteroids, the Kuiper Belt and the Mehen Belt, cannot be void mined, galacticgreg/api/enums/DimensionDef.java:64,
--- 175, 201), from GT5-Unofficial f2814df (OreMixes.java, SmallOres.java; the commit of prototypes/data/ore-mixes.lua).
--- T3 to T7 with the Void Miner I, T8 with the II, Seth and Maahes (T9) with the III. Seth brings the raw tengam and the
--- tartarite of #629 and Maahes the naquadria vein's naquadria, new raw ores here; the other ores the mod lacks are left
--- out, as above.
for name, pool in pairs({
	--- Ceres (T3): left out Chrome, Electrotine, Plutonium, Titanium
	["ceres"] = {
		{ "raw-magnetite", 0.21455 }, { "raw-brown-limonite", 0.08046 }, { "raw-yellow-limonite", 0.08046 },
		{ "raw-iron", 0.06705 }, { "raw-chalcopyrite", 0.05364 }, { "raw-bentonite", 0.04023 },
		{ "raw-beryllium", 0.04023 }, { "raw-magnesite", 0.04023 }, { "raw-uraninite", 0.03352 },
		{ "raw-diatomite", 0.02682 }, { "raw-lazurite", 0.02682 }, { "raw-saltpeter", 0.02682 },
		{ "raw-soapstone", 0.02682 }, { "raw-sodalite", 0.02682 }, { "raw-talc", 0.02682 }, { "raw-grossular", 0.01341 },
		{ "raw-spessartine", 0.01341 }, { "raw-vanadium-magnetite", 0.01341 }, { "raw-lead", 0.01073 },
		{ "raw-banded-iron", 0.01006 }, { "raw-malachite", 0.01006 }, { "raw-glauconite", 0.00838 },
		{ "raw-copper", 0.0067 }, { "raw-platinum", 0.0067 }, { "raw-pyrite", 0.0067 }, { "raw-bismuth", 0.00536 },
		{ "raw-gold", 0.00536 }, { "raw-nickel", 0.00536 }, { "raw-olivine", 0.00503 }, { "raw-alunite", 0.00335 },
		{ "raw-calcite", 0.00335 }, { "raw-lapis", 0.00335 }, { "raw-molybdenite", 0.00335 },
		{ "raw-pentlandite", 0.00335 }, { "raw-thorium", 0.00335 }, { "raw-wulfenite", 0.00335 },
		{ "raw-emerald", 0.00251 }, { "raw-pyrolusite", 0.00168 }, { "raw-tantalite", 0.00168 },
		{ "raw-diamond", 0.00134 }, { "raw-palladium", 0.00084 }, { "raw-sheldonite", 0.00084 },
		{ "raw-molybdenum", 0.00042 }, { "raw-powellite", 0.00042 },
	},
	--- Ganymede (T3): left out Chrome, Lithium, Perlite, Plutonium, Titanium, Uvarovite, Zinc
	["ganymede"] = {
		{ "raw-tetrahedrite", 0.11669 }, { "raw-redstone", 0.10669 }, { "raw-brown-limonite", 0.10002 },
		{ "raw-yellow-limonite", 0.10002 }, { "raw-ilmenite", 0.08835 }, { "raw-bauxite", 0.06668 },
		{ "raw-galena", 0.06668 }, { "raw-graphite", 0.06668 }, { "raw-uraninite", 0.04168 }, { "raw-tin", 0.02667 },
		{ "raw-lead", 0.0175 }, { "raw-scheelite", 0.01667 }, { "raw-chromite", 0.01334 }, { "raw-iron", 0.01334 },
		{ "raw-banded-iron", 0.0125 }, { "raw-malachite", 0.0125 }, { "raw-aluminium", 0.00834 },
		{ "raw-platinum", 0.00834 }, { "raw-copper", 0.00729 }, { "raw-stibnite", 0.00729 }, { "raw-saltpeter", 0.00667 },
		{ "raw-cinnabar", 0.00625 }, { "raw-ruby", 0.00625 }, { "raw-coal", 0.00417 }, { "raw-diamond", 0.00417 },
		{ "raw-silver", 0.00417 }, { "raw-lapis", 0.00333 }, { "raw-palladium", 0.00104 }, { "raw-sheldonite", 0.00104 },
		{ "raw-thorium", 0.00104 }, { "raw-tungstate", 0.00104 },
	},
	--- Io (T4): left out Ceruclase, Chrome, Infused Gold, Iridium, Mithril, Mytryl, Plutonium, Titanium, Vulcanite, Zinc
	["io"] = {
		{ "raw-magnetite", 0.24592 }, { "raw-sulfur", 0.1537 }, { "raw-tin", 0.08165 }, { "raw-pitchblende", 0.06148 },
		{ "raw-bastnasite", 0.04611 }, { "raw-gold", 0.04611 }, { "raw-jasper", 0.03074 }, { "raw-iron", 0.02767 },
		{ "raw-barite", 0.01537 }, { "raw-grossular", 0.01537 }, { "raw-quartzite", 0.01537 }, { "raw-silver", 0.01537 },
		{ "raw-spessartine", 0.01537 }, { "raw-vanadium-magnetite", 0.01537 }, { "raw-uraninite", 0.01153 },
		{ "raw-platinum", 0.01057 }, { "raw-pyrite", 0.00961 }, { "raw-pyrolusite", 0.00961 },
		{ "raw-sphalerite", 0.00961 }, { "raw-apatite", 0.00768 }, { "raw-nickel", 0.00768 }, { "raw-bismuth", 0.00615 },
		{ "raw-redstone", 0.00615 }, { "raw-saltpeter", 0.00615 }, { "raw-cassiterite", 0.0048 },
		{ "raw-certus-quartz", 0.00384 }, { "raw-lapis", 0.00307 }, { "raw-monazite", 0.00288 },
		{ "raw-neodymium", 0.00288 }, { "raw-tantalite", 0.00288 }, { "raw-palladium", 0.00192 },
		{ "raw-pyrochlore", 0.00096 }, { "raw-sheldonite", 0.00096 }, { "raw-thorium", 0.00096 },
	},
	--- Mercury (T4): left out Chrome, Electrotine, Iridium, Mithril, Perlite, Titanium, Uvarovite, Zinc
	["mercury"] = {
		{ "raw-redstone", 0.11075 }, { "raw-brown-limonite", 0.10383 }, { "raw-yellow-limonite", 0.10383 },
		{ "raw-ilmenite", 0.09172 }, { "raw-bauxite", 0.06922 }, { "raw-graphite", 0.06922 }, { "raw-bismuth", 0.05884 },
		{ "raw-naquadah", 0.05516 }, { "raw-arsenic", 0.05191 }, { "raw-draconium", 0.03461 }, { "raw-nickel", 0.01557 },
		{ "raw-chromite", 0.01384 }, { "raw-lead", 0.01384 }, { "raw-antimony", 0.01298 }, { "raw-banded-iron", 0.01298 },
		{ "raw-malachite", 0.01298 }, { "raw-aluminium", 0.00865 }, { "raw-platinum", 0.00865 },
		{ "raw-cinnabar", 0.00649 }, { "raw-ruby", 0.00649 }, { "raw-coal", 0.00433 }, { "raw-diamond", 0.00433 },
		{ "raw-jade", 0.00433 }, { "raw-molybdenite", 0.00433 }, { "raw-vinteum", 0.00433 }, { "raw-wulfenite", 0.00433 },
		{ "raw-enriched-naquadah", 0.00324 }, { "raw-palladium", 0.00216 }, { "raw-sheldonite", 0.00108 },
		{ "raw-molybdenum", 0.00054 }, { "raw-powellite", 0.00054 },
	},
	--- Enceladus (T5): left out Chrome, Iridium, Lithium, Mithril, Orichalcum, Osmium, Rubracium, Titanium, Vanadium, Zinc
	["enceladus"] = {
		{ "raw-iron", 0.1269 }, { "raw-chalcopyrite", 0.10575 }, { "raw-bastnasite", 0.07931 },
		{ "raw-magnetite", 0.07931 }, { "raw-uraninite", 0.05948 }, { "raw-lazurite", 0.05288 },
		{ "raw-sodalite", 0.05288 }, { "raw-ledox", 0.03966 }, { "raw-opal", 0.03966 }, { "raw-nickel", 0.02809 },
		{ "raw-scheelite", 0.02644 }, { "raw-silver", 0.02644 }, { "raw-copper", 0.01322 }, { "raw-pyrite", 0.01322 },
		{ "raw-lapis", 0.0119 }, { "raw-saltpeter", 0.01058 }, { "raw-gold", 0.00991 }, { "raw-calcite", 0.00661 },
		{ "raw-monazite", 0.00496 }, { "raw-neodymium", 0.00496 }, { "raw-palladium", 0.00165 },
		{ "raw-tungstate", 0.00165 },
	},
	--- Miranda (T5): left out Electrotine, Iridium, Mithril, Osmium, Perlite, Titanium, Uvarovite
	["miranda"] = {
		{ "raw-tetrahedrite", 0.17241 }, { "raw-redstone", 0.14778 }, { "raw-tin", 0.13085 }, { "raw-graphite", 0.09852 },
		{ "raw-desh", 0.07389 }, { "raw-draconium", 0.04926 }, { "raw-nickel", 0.02617 }, { "raw-chromite", 0.0197 },
		{ "raw-ilmenite", 0.0197 }, { "raw-iron", 0.0197 }, { "raw-apatite", 0.01232 }, { "raw-pyrolusite", 0.01232 },
		{ "raw-copper", 0.01078 }, { "raw-stibnite", 0.01078 }, { "raw-gold", 0.00985 }, { "raw-cinnabar", 0.00924 },
		{ "raw-ruby", 0.00924 }, { "raw-cassiterite", 0.0077 }, { "raw-coal", 0.00616 }, { "raw-diamond", 0.00616 },
		{ "raw-jade", 0.00616 }, { "raw-vinteum", 0.00616 }, { "raw-scheelite", 0.00462 }, { "raw-tungstate", 0.00462 },
		{ "raw-palladium", 0.00154 }, { "raw-pyrochlore", 0.00154 }, { "raw-tantalite", 0.00154 },
	},
	--- Oberon (T5): left out Chrome, Deep Iron, Iridium, Lithium, Osmium, Shadow Iron, Titanium, Tungsten
	["oberon"] = {
		{ "raw-brown-limonite", 0.16216 }, { "raw-yellow-limonite", 0.16216 }, { "raw-galena", 0.10811 },
		{ "raw-pitchblende", 0.10811 }, { "raw-naquadah", 0.08615 }, { "raw-silver", 0.03378 }, { "raw-lead", 0.02838 },
		{ "raw-grossular", 0.02703 }, { "raw-scheelite", 0.02703 }, { "raw-spessartine", 0.02703 },
		{ "raw-silicon", 0.02162 }, { "raw-banded-iron", 0.02027 }, { "raw-malachite", 0.02027 }, { "raw-nickel", 0.0152 },
		{ "raw-platinum", 0.01351 }, { "raw-uraninite", 0.01351 }, { "raw-lapis", 0.00541 },
		{ "raw-enriched-naquadah", 0.00507 }, { "raw-pyrolusite", 0.00338 }, { "raw-tantalite", 0.00338 },
		{ "raw-diamond", 0.0027 }, { "raw-palladium", 0.00169 }, { "raw-sheldonite", 0.00169 },
		{ "raw-tungstate", 0.00169 },
	},
	--- Titan (T5): left out Infused Gold, Iridium, Meteoric Iron, Mithril, Osmium, Perlite, Rutile, Titanium, Uvarovite, Zinc
	["titan"] = {
		{ "raw-ilmenite", 0.10055 }, { "raw-bauxite", 0.07683 }, { "raw-graphite", 0.07588 }, { "raw-naquadah", 0.06047 },
		{ "raw-nickel", 0.0581 }, { "raw-arsenic", 0.05691 }, { "raw-bastnasite", 0.05691 }, { "raw-beryllium", 0.05691 },
		{ "raw-bismuth", 0.05691 }, { "raw-gold", 0.05691 }, { "raw-garnierite", 0.03794 }, { "raw-tin", 0.03035 },
		{ "raw-grossular", 0.01897 }, { "raw-silver", 0.01897 }, { "raw-spessartine", 0.01897 },
		{ "raw-chromite", 0.01518 }, { "raw-iron", 0.01518 }, { "raw-antimony", 0.01423 }, { "raw-aluminium", 0.00949 },
		{ "raw-redstone", 0.00759 }, { "raw-diamond", 0.00664 }, { "raw-coal", 0.00474 }, { "raw-cobaltite", 0.00474 },
		{ "raw-molybdenite", 0.00474 }, { "raw-pentlandite", 0.00474 }, { "raw-wulfenite", 0.00474 },
		{ "raw-emerald", 0.00356 }, { "raw-enriched-naquadah", 0.00356 }, { "raw-monazite", 0.00356 },
		{ "raw-neodymium", 0.00356 }, { "raw-platinum", 0.00356 }, { "raw-thorium", 0.00356 },
		{ "raw-pyrolusite", 0.00237 }, { "raw-tantalite", 0.00237 }, { "raw-palladium", 0.00119 },
		{ "raw-molybdenum", 0.00059 }, { "raw-powellite", 0.00059 },
	},
	--- Proteus (T6): left out Chrome, Deep Iron, Infused Gold, Iridium, Osmium, Perlite, Shadow Iron, Titanium, Tungsten, Uvarovite, Vanadium, Zinc
	["proteus"] = {
		{ "raw-ilmenite", 0.10244 }, { "raw-bauxite", 0.07731 }, { "raw-chalcopyrite", 0.07731 },
		{ "raw-graphite", 0.07731 }, { "raw-iron", 0.07731 }, { "raw-gold", 0.06523 }, { "raw-magnetite", 0.05799 },
		{ "raw-uraninite", 0.04349 }, { "raw-copper", 0.04059 }, { "raw-tin", 0.03093 }, { "raw-barite", 0.01933 },
		{ "raw-quartzite", 0.01933 }, { "raw-silver", 0.01933 }, { "raw-chromite", 0.01546 }, { "raw-silicon", 0.01546 },
		{ "raw-nickel", 0.01087 }, { "raw-adamantium", 0.00966 }, { "raw-aluminium", 0.00966 },
		{ "raw-neutronium", 0.00966 }, { "raw-pyrite", 0.00966 }, { "raw-bismuth", 0.00773 }, { "raw-redstone", 0.00773 },
		{ "raw-saltpeter", 0.00773 }, { "raw-certus-quartz", 0.00483 }, { "raw-coal", 0.00483 },
		{ "raw-diamond", 0.00483 }, { "raw-molybdenite", 0.00483 }, { "raw-wulfenite", 0.00483 },
		{ "raw-platinum", 0.00362 }, { "raw-naquadah", 0.00121 }, { "raw-molybdenum", 0.0006 },
		{ "raw-powellite", 0.0006 },
	},
	--- Triton (T6): left out Deep Iron, Gallium, Iridium, Lithium, Mithril, Niobium, Plutonium241, Shadow Iron, Titanium, Tungsten, Uranium235, Yttrium
	["triton"] = {
		{ "raw-magnetite", 0.27972 }, { "raw-galena", 0.06993 }, { "raw-bastnasite", 0.05245 }, { "raw-thorium", 0.05245 },
		{ "raw-uraninite", 0.05245 }, { "raw-nickel", 0.04371 }, { "raw-garnierite", 0.03497 }, { "raw-copper", 0.02797 },
		{ "raw-silver", 0.02185 }, { "raw-lead", 0.01836 }, { "raw-gold", 0.01748 }, { "raw-grossular", 0.01748 },
		{ "raw-scheelite", 0.01748 }, { "raw-spessartine", 0.01748 }, { "raw-vanadium-magnetite", 0.01748 },
		{ "raw-iron", 0.01399 }, { "raw-silicon", 0.01399 }, { "raw-adamantium", 0.00874 }, { "raw-neutronium", 0.00874 },
		{ "raw-cobaltite", 0.00437 }, { "raw-pentlandite", 0.00437 }, { "raw-monazite", 0.00328 },
		{ "raw-neodymium", 0.00328 }, { "raw-pyrolusite", 0.00219 }, { "raw-tantalite", 0.00219 },
		{ "raw-diamond", 0.00175 }, { "raw-naquadah", 0.00109 }, { "raw-palladium", 0.00109 },
		{ "raw-tungstate", 0.00109 },
	},
	--- Haumea (T7): left out Infused Gold, Lithium, Nether Star, Plutonium241, Titanium, Uranium235, Zinc
	["haumea"] = {
		{ "raw-uraninite", 0.10388 }, { "raw-ilmenite", 0.0813 }, { "raw-bauxite", 0.07227 },
		{ "raw-pitchblende", 0.07227 }, { "raw-naquadah", 0.05872 }, { "raw-thorium", 0.05759 },
		{ "raw-bastnasite", 0.0542 }, { "raw-bentonite", 0.0542 }, { "raw-beryllium", 0.0542 },
		{ "raw-garnet-sand", 0.0542 }, { "raw-gold", 0.0542 }, { "raw-magnesite", 0.0542 }, { "raw-scheelite", 0.01807 },
		{ "raw-iron", 0.01445 }, { "raw-adamantium", 0.00903 }, { "raw-aluminium", 0.00903 },
		{ "raw-neutronium", 0.00903 }, { "raw-glauconite", 0.00678 }, { "raw-olivine", 0.00678 },
		{ "raw-red-garnet", 0.00678 }, { "raw-yellow-garnet", 0.00678 }, { "raw-emerald", 0.00339 },
		{ "raw-enriched-naquadah", 0.00339 }, { "raw-monazite", 0.00339 }, { "raw-neodymium", 0.00339 },
		{ "raw-platinum", 0.00339 }, { "raw-tungstate", 0.00113 },
	},
	--- MakeMake (T7): left out Chrome, Chrysotile, Gallium, Lithium, Niobium, Titanium, Vanadium, Yttrium
	["makemake"] = {
		{ "raw-magnetite", 0.25266 }, { "raw-ilmenite", 0.05984 }, { "raw-bauxite", 0.05319 },
		{ "raw-pitchblende", 0.05319 }, { "raw-red-garnet", 0.05319 }, { "raw-bastnasite", 0.03989 },
		{ "raw-bentonite", 0.03989 }, { "raw-beryllium", 0.03989 }, { "raw-magnesite", 0.03989 },
		{ "raw-uraninite", 0.03657 }, { "raw-yellow-garnet", 0.02992 }, { "raw-black-plutonium", 0.0266 },
		{ "raw-iron", 0.0133 }, { "raw-scheelite", 0.0133 }, { "raw-vanadium-magnetite", 0.0133 }, { "raw-lead", 0.01064 },
		{ "raw-adamantium", 0.00665 }, { "raw-aluminium", 0.00665 }, { "raw-neutronium", 0.00665 },
		{ "raw-bismuth", 0.00532 }, { "raw-nickel", 0.00532 }, { "raw-glauconite", 0.00499 }, { "raw-gold", 0.00499 },
		{ "raw-olivine", 0.00499 }, { "raw-borax", 0.00332 }, { "raw-realgar", 0.00332 }, { "raw-emerald", 0.00249 },
		{ "raw-monazite", 0.00249 }, { "raw-neodymium", 0.00249 }, { "raw-thorium", 0.00249 }, { "raw-naquadah", 0.00083 },
		{ "raw-tungstate", 0.00083 },
	},
	--- BarnardC (T8): left out Deep Iron, Iridium, Osmium, Shadow Iron, Tungsten
	["barnard-c"] = {
		{ "raw-lignite", 0.31093 }, { "raw-oilsands", 0.0823 }, { "raw-basaltic-mineral-sand", 0.07316 },
		{ "raw-granitic-mineral-sand", 0.07316 }, { "raw-arsenic", 0.05487 }, { "raw-bismuth", 0.05487 },
		{ "raw-rock-salt", 0.04572 }, { "raw-salt", 0.04572 }, { "raw-black-plutonium", 0.03658 },
		{ "raw-red-garnet", 0.03658 }, { "raw-coal", 0.01829 }, { "raw-kyanite", 0.01829 }, { "raw-mica", 0.01829 },
		{ "raw-silicon", 0.01463 }, { "raw-antimony", 0.01372 }, { "raw-nickel", 0.01029 },
		{ "raw-fullers-earth", 0.00914 }, { "raw-gypsum", 0.00914 }, { "raw-neodymium", 0.00914 },
		{ "raw-samarium", 0.00914 }, { "raw-lepidolite", 0.00572 }, { "raw-spodumene", 0.00572 }, { "raw-borax", 0.00457 },
		{ "raw-yellow-garnet", 0.00457 }, { "raw-cassiterite", 0.00229 }, { "raw-pollucite", 0.00229 },
		{ "raw-tartarite", 0.00229 },
	},
	--- BarnardE (T8): left out Cadmium, Caesium, Deep Iron, Infused Gold, Nether Star, Plutonium241, Shadow Iron, Titanium, Tungsten, Uranium235, Zinc
	["barnard-e"] = {
		{ "raw-magnetite", 0.22699 }, { "raw-iron", 0.08228 }, { "raw-uraninite", 0.07448 },
		{ "raw-chalcopyrite", 0.05675 }, { "raw-naquadah", 0.04611 }, { "raw-bentonite", 0.04256 },
		{ "raw-garnet-sand", 0.04256 }, { "raw-gold", 0.04256 }, { "raw-magnesite", 0.04256 }, { "raw-thorium", 0.04256 },
		{ "raw-grossular", 0.01419 }, { "raw-spessartine", 0.01419 }, { "raw-vanadium-magnetite", 0.01419 },
		{ "raw-silicon", 0.01135 }, { "raw-adamantium", 0.00709 }, { "raw-copper", 0.00709 },
		{ "raw-neutronium", 0.00709 }, { "raw-pyrite", 0.00709 }, { "raw-nickel", 0.00567 }, { "raw-glauconite", 0.00532 },
		{ "raw-olivine", 0.00532 }, { "raw-red-garnet", 0.00532 }, { "raw-yellow-garnet", 0.00532 },
		{ "raw-cerium", 0.00355 }, { "raw-lanthanum", 0.00355 }, { "raw-molybdenite", 0.00355 },
		{ "raw-wulfenite", 0.00355 }, { "raw-enriched-naquadah", 0.00266 }, { "raw-platinum", 0.00266 },
		{ "raw-pyrolusite", 0.00177 }, { "raw-tantalite", 0.00177 }, { "raw-molybdenum", 0.00044 },
		{ "raw-powellite", 0.00044 },
	},
	--- CentauriA (T8): left out Cadmium, Caesium, Electrotine
	["centauri-bb"] = {
		{ "raw-sulfur", 0.14109 }, { "raw-nether-quartz", 0.11993 }, { "raw-tetrahedrite", 0.09877 },
		{ "raw-redstone", 0.08466 }, { "raw-cassiterite-sand", 0.05644 }, { "raw-garnet-sand", 0.05644 },
		{ "raw-pitchblende", 0.05644 }, { "raw-beryllium", 0.04233 }, { "raw-diatomite", 0.03527 },
		{ "raw-black-plutonium", 0.02822 }, { "raw-red-garnet", 0.02822 }, { "raw-saltpeter", 0.02822 },
		{ "raw-quartzite", 0.02116 }, { "raw-barite", 0.01411 }, { "raw-grossular", 0.01411 },
		{ "raw-spessartine", 0.01411 }, { "raw-pyrite", 0.00882 }, { "raw-sphalerite", 0.00882 },
		{ "raw-asbestos", 0.00705 }, { "raw-neodymium", 0.00705 }, { "raw-samarium", 0.00705 },
		{ "raw-uraninite", 0.00705 }, { "raw-copper", 0.00617 }, { "raw-stibnite", 0.00617 }, { "raw-cinnabar", 0.00529 },
		{ "raw-ruby", 0.00529 }, { "raw-alunite", 0.00353 }, { "raw-borax", 0.00353 }, { "raw-cerium", 0.00353 },
		{ "raw-certus-quartz", 0.00353 }, { "raw-lanthanum", 0.00353 }, { "raw-yellow-garnet", 0.00353 },
		{ "raw-emerald", 0.00265 }, { "raw-thorium", 0.00265 }, { "raw-pyrolusite", 0.00176 },
		{ "raw-tantalite", 0.00176 }, { "raw-tartarite", 0.00176 },
	},
	--- TcetiE (T8): left out Chrome, Manganese, Nether Star, Perlite, Uvarovite
	["tau-ceti-e"] = {
		{ "raw-magnetite", 0.31163 }, { "raw-apatite", 0.05843 }, { "raw-banded-iron", 0.05356 },
		{ "raw-magnesite", 0.05356 }, { "raw-tin", 0.05173 }, { "raw-ilmenite", 0.05161 }, { "raw-oilsands", 0.04382 },
		{ "raw-bauxite", 0.03895 }, { "raw-garnet-sand", 0.02921 }, { "raw-kaolinite", 0.02921 },
		{ "raw-zeolite", 0.02921 }, { "raw-rock-salt", 0.02435 }, { "raw-salt", 0.02435 }, { "raw-red-garnet", 0.02313 },
		{ "raw-black-plutonium", 0.01948 }, { "raw-vanadium-magnetite", 0.01948 }, { "raw-barite", 0.00974 },
		{ "raw-gold", 0.00974 }, { "raw-iron", 0.00974 }, { "raw-quartzite", 0.00974 }, { "raw-chromite", 0.00779 },
		{ "raw-opal", 0.0067 }, { "raw-sulfur", 0.0067 }, { "raw-yellow-garnet", 0.00609 }, { "raw-aluminium", 0.00487 },
		{ "raw-fullers-earth", 0.00365 }, { "raw-glauconite-sand", 0.00365 }, { "raw-pyrochlore", 0.00365 },
		{ "raw-tricalcium-phosphate", 0.00365 }, { "raw-cassiterite", 0.00304 }, { "raw-lepidolite", 0.00304 },
		{ "raw-spodumene", 0.00304 }, { "raw-borax", 0.00243 }, { "raw-certus-quartz", 0.00243 },
		{ "raw-tungstate", 0.00243 }, { "raw-lapis", 0.00195 }, { "raw-molybdenum", 0.0003 },
	},
	--- VegaB (T8): left out Cadmium, Caesium, Chrome, Chrysotile, Gallium, Infused Gold, Lithium, Nether Star, Niobium, Plutonium241, Titanium, Uranium235, Vanadium, Yttrium
	["vega-b"] = {
		{ "raw-magnetite", 0.18967 }, { "raw-tetrahedrite", 0.06988 }, { "raw-redstone", 0.0599 }, { "raw-gold", 0.04367 },
		{ "raw-galena", 0.03993 }, { "raw-pitchblende", 0.03993 }, { "raw-uraninite", 0.03494 },
		{ "raw-bismuth", 0.03394 }, { "raw-naquadah", 0.03244 }, { "raw-arsenic", 0.02995 },
		{ "raw-garnet-sand", 0.02995 }, { "raw-thorium", 0.02995 }, { "raw-red-garnet", 0.02371 },
		{ "raw-yellow-garnet", 0.02371 }, { "raw-lazurite", 0.01997 }, { "raw-sodalite", 0.01997 },
		{ "raw-silver", 0.01248 }, { "raw-lead", 0.01048 }, { "raw-scheelite", 0.00998 },
		{ "raw-vanadium-magnetite", 0.00998 }, { "raw-antimony", 0.00749 }, { "raw-adamantium", 0.00499 },
		{ "raw-neutronium", 0.00499 }, { "raw-copper", 0.00437 }, { "raw-stibnite", 0.00437 }, { "raw-cinnabar", 0.00374 },
		{ "raw-ruby", 0.00374 }, { "raw-calcite", 0.0025 }, { "raw-cerium", 0.0025 }, { "raw-lanthanum", 0.0025 },
		{ "raw-lapis", 0.0025 }, { "raw-realgar", 0.0025 }, { "raw-enriched-naquadah", 0.00187 },
		{ "raw-platinum", 0.00187 }, { "raw-diamond", 0.001 }, { "raw-tungstate", 0.00062 },
	},
	--- Seth (T9): left out Chrome, Electrotine, Iridium, Mithril, Osmium
	["seth"] = {
		{ "raw-magnetite", 0.44444 }, { "raw-tengam", 0.11111 }, { "raw-tin", 0.07378 }, { "raw-ilmenite", 0.0625 },
		{ "raw-bauxite", 0.05556 }, { "raw-bastnasite", 0.04167 }, { "raw-draconium", 0.02778 },
		{ "raw-vanadium-magnetite", 0.02778 }, { "raw-nickel", 0.01476 }, { "raw-gold", 0.01389 }, { "raw-iron", 0.01389 },
		{ "raw-samarium", 0.01389 }, { "raw-neodymium", 0.00955 }, { "raw-aluminium", 0.00694 },
		{ "raw-platinum", 0.00694 }, { "raw-cassiterite", 0.00434 }, { "raw-jade", 0.00347 }, { "raw-vinteum", 0.00347 },
		{ "raw-monazite", 0.0026 }, { "raw-palladium", 0.00174 }, { "raw-tartarite", 0.00174 },
		{ "raw-sheldonite", 0.00087 },
	},
	--- Maahes (T9): left out Alduorite, Ardite, Chrome, Iridium, Manganese, Rutile, Titanium, Trinium, Vanadium
	["maahes"] = {
		{ "raw-naquadah", 0.12281 }, { "raw-basaltic-mineral-sand", 0.09357 }, { "raw-granitic-mineral-sand", 0.09357 },
		{ "raw-magnetite", 0.07018 }, { "raw-enriched-naquadah", 0.05117 }, { "callisto-ice-dust", 0.04678 },
		{ "raw-galena", 0.04678 }, { "raw-silver", 0.04678 }, { "raw-soapstone", 0.04678 }, { "raw-talc", 0.04678 },
		{ "raw-topaz", 0.04678 }, { "quantium-dust", 0.03509 }, { "raw-amethyst", 0.03509 }, { "raw-adamantium", 0.0117 },
		{ "raw-fullers-earth", 0.0117 }, { "raw-gypsum", 0.0117 }, { "raw-neutronium", 0.0117 }, { "raw-gold", 0.00877 },
		{ "raw-blue-topaz", 0.00585 }, { "raw-cryolite", 0.00585 }, { "raw-glauconite", 0.00585 }, { "raw-lead", 0.00585 },
		{ "raw-naquadria", 0.00585 }, { "raw-palladium", 0.00585 }, { "raw-pentlandite", 0.00585 },
		{ "raw-sheldonite", 0.00585 }, { "raw-tungstate", 0.00585 }, { "raw-molybdenum", 0.00073 },
		{ "raw-platinum", 0.00073 },
	},
}) do VOID_POOLS[name] = pool end

local VM_PICKS = 20                -- ores per recipe at tier I (2 per second, 10 s)
local VM_GAS = { { nil, 1 }, { "neon", 4 }, { "krypton", 8 }, { "xenon", 16 } }
local VM_DIMS = { { "pluto", 1 }, { "barnard-f", 2 }, { "horus", 3 }, { "anubis", 3 }, { "neper", 3 },
	{ "mehen-belt", 3 } }   -- neper: #373, mehen-belt: #356
for _, d in pairs({ { "ceres", 1 }, { "ganymede", 1 }, { "io", 1 }, { "mercury", 1 }, { "enceladus", 1 }, { "miranda", 1 },
	{ "oberon", 1 }, { "titan", 1 }, { "proteus", 1 }, { "triton", 1 }, { "haumea", 1 }, { "makemake", 1 },
	{ "barnard-c", 2 }, { "barnard-e", 2 }, { "centauri-bb", 2 }, { "tau-ceti-e", 2 }, { "vega-b", 2 }, { "seth", 3 },
	{ "maahes", 3 } }) do
	VM_DIMS[#VM_DIMS + 1] = d   -- issue #636
end
--- issue #636: Seth's raw tengam and tartarite (GT's TengamRaw and Tartarite, the dusts new) and Maahes's naquadria
create_ore("raw-tengam", nil, "crushed-tengam", "raw-tengam-dust", nil, "crushed-tengam", nil, nil, 1, false, false)
create_ore("raw-tartarite", nil, "crushed-tartarite", "tartarite-dust", nil, "crushed-tartarite", nil, nil, 1, false, false)
create_ore("raw-naquadria", nil, "crushed-naquadria", nil, nil, "crushed-naquadria", nil, nil, 1, false, false)
--- issue #631: GT's samarium ore (Seth's, Barnard C's and Centauri Bb's SecondLanthanid vein), whose dust in GTNH is
--- gtnhlanth's samarium ore concentrate (164 section 55)
create_ore("raw-samarium", nil, "crushed-samarium", "samarium-ore-concentrate", nil, "crushed-samarium", nil, nil, 1, false,
	false)
--- issue #631 part 3: GT's ores of the other lanthanides with an ion extraction resin (164 section 56): lanthanum and
--- cerium in the RareEarth vein (Barnard E and F, Centauri Bb, Vega B), every one in the Deep Dark (161); their dusts are
--- the mod's
for _, x in pairs({ "lanthanum", "praseodymium", "cerium", "europium", "gadolinium", "terbium", "dysprosium", "holmium",
	"erbium", "ytterbium", "lutetium" }) do
	create_ore("raw-" .. x, nil, "crushed-" .. x, nil, nil, "crushed-" .. x, nil, nil, 1, false, false)
end
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
unlock_in(VM_TECHS[3], { "crushed-dilithium", "crushed-mysterious-crystal" })   -- issue #373: Neper
unlock_in(VM_TECHS[3], { "crushed-awakened-draconium" })   -- issue #356: the Mehen Belt
--- (issue #636: draconium, oriharukon and vinteum come from Phobos and Deimos's mines with Reach Mars now)
unlock_in(MARS, { "crushed-draconium", "crushed-oriharukon", "crushed-vinteum" })
unlock_in(VM_TECHS[3], { "crushed-tengam", "crushed-tartarite", "crushed-naquadria" })   -- issue #636: Seth, Maahes
unlock_in(VM_TECHS[2], { "crushed-samarium", "crushed-lanthanum", "crushed-cerium" })   -- issue #631: Barnard C and E, Centauri Bb, Vega B
