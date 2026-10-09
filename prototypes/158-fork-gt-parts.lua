--------------------------------------------------------------------------------
--- FORK GT PARTS (issues #222 and #223, B5)
--- Issue #222: GT New Horizons' parts of the four ingots of issue #205 (realgar, thorium, antimony, molybdenum), every
--- item GT generates for them (MaterialsInit.java: addMetalItems, realgar also addGearItems; MetaGeneratedItem01/02/03,
--- OrePrefixes.java conditions; the frame box of LoaderMetaPipeEntities.java, the storage blocks of
--- LoaderGTBlockFluid.java), each with GT's main machine recipe (OP/Processing*.java, GTRecipeRegistrator.java) in
--- Gregtorio's units (time = GT seconds x the tier's speed; a tenth of GT's litres):
---   plate         bender, 1 ingot, mass ticks (LV)          double plate  bender, 2 ingots, 2 x mass (MV)
---   dense plate   bender, 9 ingots, 9 x mass (MV)           superdense    compressor, 64 plates, 32 x mass (MV)
---   foil          bender, 1 ingot -> 4, 2 x mass (LV)       rod           lathe, 1 ingot -> rod + 2 small piles, 5 x mass
---   long rod      forge hammer, 2 rods, mass                bolt          cutter, rod + water -> 4, 4 x mass
---   screw         lathe, bolt, mass / 8                     round         lathe, nugget, mass / 4
---   ring          extruder, 1 ingot -> 4, 2 x mass (MV)     fine wire     wiremill, 1 ingot -> 4, 5 s
---   small spring  bender, rod -> 2, 5 s                     spring        bender, long rod, 10 s
---   item casing   alloy smelter, 2 ingots + mold -> 3, 6.4 s  frame       assembler, 4 rods, 3.2 s
---   block         compressor, 9 ingots, 15 s (antimony, thorium and molybdenum have one in GT, realgar not)
---   realgar: gear (GT's small gear) extruder 1 ingot, mass (MV); large gear (GT's gear) extruder 4 ingots, 5 x mass
---   (MV); rotor assembler 4 plates + ring + 1.6 soldering alloy, mass (LV)
--- Not made: GT's tool heads and turbine blades (the TOOL bit of realgar, thorium and molybdenum: GT's tools and turbine
--- rotors, which Gregtorio does not have per material) and GT's cells. The casts come from 143 (FORK_CASTING.run at the
--- end of this file), the icons from tools/gen_gt_icons.py.
--- Issue #223, B5: GT's nugget recipes (ProcessingNugget.java) for the nuggets of the ore chain (#187, #205), the new
--- ones and naquadah's: ingot -> 9 nuggets in the alloy smelter with the mold (5 s), nugget -> a tiny pile of the dust in
--- the macerator (GTRecipeRegistrator.registerReverseMacerating: mass / 9 ticks, at least 16); 9 tiny piles make the dust
--- at the crafting table (GT's packager is not in Gregtorio, as for dark ash). GT's crafting recipe with the saw is not
--- made (Gregtorio has no GT tools).
--- Unlocks: unlock_after of 155 (the first technology after the machine and the inputs). Loads after 155 and before
--- 150, 196, 197, 198, 199 and 200.
--------------------------------------------------------------------------------

local OC = FORK_ORE_CHAIN
local P = "__gregtorio-continued__/graphics/icons/"

local function item(name, amount, probability)
	return { type = "item", name = name, amount = amount or 1, probability = probability }
end
local function fluid(name, amount)
	return { type = "fluid", name = name, amount = amount }
end
local function add_item(name, sub, order)
	if data.raw.item[name] then return end
	data:extend({ { type = "item", name = name, icon = P .. name .. ".png", icon_size = 32, subgroup = sub, order = order,
		stack_size = 64 } })
end
local made = 0
--- a recipe, unlocked after its machine and every item it takes (the mold aside)
local function recipe(def)
	if data.raw.recipe[def.name] then error("158-fork-gt-parts: recipe " .. def.name .. " exists already") end
	data:extend({ {
		type = "recipe", name = def.name, category = def.category, enabled = false, energy_required = def.time,
		ingredients = def.ingredients, results = def.results, main_product = def.results[1].name,
		--- the machine's row, as create_recipe (a recipe without one would follow its item into the Material parts tab)
		subgroup = def.subgroup or (def.category ~= "crafting" and ("subgroup-" .. def.category) or nil),
	} })
	OC.made(def.name)
	local groups = { def.category ~= "crafting" and OC.machine_techs(def.category) or nil }
	for _, i in pairs(def.ingredients) do
		if i.type == "item" and i.name ~= "mold" then groups[#groups + 1] = OC.item_techs(i.name) end
	end
	OC.unlock_after(def.name, groups)
	made = made + 1
end
local function sub_of(name, default)
	local it = data.raw.item[name]
	return it and it.subgroup or default
end

--------------------------------------------------------------------------------
--- 1) ISSUE #223, B5: GT'S NUGGET RECIPES
--------------------------------------------------------------------------------
--- metal: GT mass, its dust (nil: <metal>-dust)
local NUGGETS = {
	iron = { 56 }, gold = { 196 }, copper = { 63 }, tin = { 118 }, lead = { 207 }, silver = { 107 }, nickel = { 58 },
	beryllium = { 9 }, thorium = { 230 }, ledox = { 98 }, realgar = { 53 }, neodymium = { 144 }, naquadah = { 330 },
	antimony = { 121, "antimony" }, molybdenum = { 95 },
}
local nuggets = 0
for m, d in pairs(NUGGETS) do
	local nugget, ingot, dust = m .. "-nugget", m .. "-ingot", d[2] or (m .. "-dust")
	if data.raw.item[nugget] and data.raw.item[ingot] and data.raw.item[dust] then
		local tiny = "tiny-pile-of-" .. m .. "-dust"
		add_item(tiny, sub_of(dust, "subgroup-macerator-dust"), "z-" .. tiny)
		recipe{ name = m .. "-nugget-from-ingot", category = "lv-alloy-smelter-recipes", time = 5,
			subgroup = "subgroup-lv-alloy-smelter-recipes",
			ingredients = { item(ingot), item("mold") }, results = { item(nugget, 9), item("mold") } }
		if not data.raw.recipe[m .. "-ingot-from-nuggets"] then
			--- in the alloy smelter's row (the ingot's row is in the Material parts tab, which has items only)
			recipe{ name = m .. "-ingot-from-nuggets", category = "lv-alloy-smelter-recipes", time = 10,
				subgroup = "subgroup-lv-alloy-smelter-recipes",
				ingredients = { item(nugget, 9), item("mold") }, results = { item(ingot), item("mold") } }
		end
		recipe{ name = m .. "-nugget-maceration", category = "lv-macerator-recipes", time = math.max(16, math.floor(d[1] / 9)) / 20,
			ingredients = { item(nugget) }, results = { item(tiny) } }
		recipe{ name = dust .. "-from-tiny-piles", category = "crafting", time = 0.5,
			ingredients = { item(tiny, 9) }, results = { item(dust) } }
		nuggets = nuggets + 1
	else
		log("FORK-GT-PARTS: no nugget, ingot or dust of " .. m)
	end
end

--------------------------------------------------------------------------------
--- 2) ISSUE #222: THE PARTS (after the nugget recipes: the round takes a nugget)
--------------------------------------------------------------------------------
--- material: GT mass (Materials.getMass), its dust, whether GT has a storage block and GT's gears
local METALS = {
	realgar = { mass = 53, dust = "realgar-dust", gears = true },
	thorium = { mass = 230, dust = "thorium-dust", block = true },
	antimony = { mass = 121, dust = "antimony", block = true },
	molybdenum = { mass = 95, dust = "molybdenum-dust", block = true },
}
local parts = 0
for m, d in pairs(METALS) do
	local s = d.mass / 20   -- GT's mass ticks in seconds
	local ingot = m .. "-ingot"
	local sub = sub_of(ingot, "subgroup-smelting")
	local function part(name, order)
		if not data.raw.item[name] then
			add_item(name, sub, "z-" .. m .. "-" .. order)
			parts = parts + 1
		end
	end
	local small = "small-pile-of-" .. (d.dust == m and (m .. "-dust") or d.dust)
	add_item(small, sub_of(d.dust, "subgroup-macerator-dust"), "z-" .. small)

	part(m .. "-plate", "c")
	recipe{ name = m .. "-plate", category = "lv-bending-machine-recipes", time = s,
		ingredients = { item(ingot) }, results = { item(m .. "-plate") } }
	part("double-" .. m .. "-plate", "d")
	recipe{ name = "double-" .. m .. "-plate", category = "mv-bending-machine-recipes", time = 2 * s * MV_SPEED,
		ingredients = { item(ingot, 2) }, results = { item("double-" .. m .. "-plate") } }
	part("dense-" .. m .. "-plate", "e")
	recipe{ name = "dense-" .. m .. "-plate", category = "mv-bending-machine-recipes", time = 9 * s * MV_SPEED,
		ingredients = { item(ingot, 9) }, results = { item("dense-" .. m .. "-plate") } }
	part("superdense-" .. m .. "-plate", "f")
	recipe{ name = "superdense-" .. m .. "-plate", category = "mv-compressor-recipes", time = 32 * s * MV_SPEED,
		ingredients = { item(m .. "-plate", 64) }, results = { item("superdense-" .. m .. "-plate") } }
	part(m .. "-foil", "g")
	recipe{ name = m .. "-foil", category = "lv-bending-machine-recipes", time = 2 * s,
		ingredients = { item(ingot) }, results = { item(m .. "-foil", 4) } }
	part(m .. "-rod", "h")
	recipe{ name = m .. "-rod", category = "lv-lathe-recipes", time = 5 * s,
		ingredients = { item(ingot) }, results = { item(m .. "-rod"), item(small, 2) } }
	recipe{ name = (d.dust == m and (m .. "-dust") or d.dust) .. "-from-small-piles", category = "crafting", time = 0.5,
		ingredients = { item(small, 4) }, results = { item(d.dust) } }
	part("long-" .. m .. "-rod", "i")
	recipe{ name = "long-" .. m .. "-rod", category = "lv-forge-hammer-recipes", time = s,
		ingredients = { item(m .. "-rod", 2) }, results = { item("long-" .. m .. "-rod") } }
	part(m .. "-bolt", "k")
	recipe{ name = m .. "-bolt", category = "lv-cutting-machine-recipes", time = 4 * s,
		ingredients = { item(m .. "-rod"), fluid("water", 0.4) }, results = { item(m .. "-bolt", 4) } }
	part(m .. "-screw", "l")
	recipe{ name = m .. "-screw", category = "lv-lathe-recipes", time = math.max(1, math.floor(d.mass / 8)) / 20,
		ingredients = { item(m .. "-bolt") }, results = { item(m .. "-screw") } }
	part(m .. "-round", "j")
	recipe{ name = m .. "-round", category = "lv-lathe-recipes", time = math.max(1, math.floor(d.mass / 4)) / 20,
		ingredients = { item(m .. "-nugget") }, results = { item(m .. "-round") } }
	part(m .. "-ring", "m")
	recipe{ name = m .. "-ring", category = "mv-extruder-recipes", time = 2 * s * MV_SPEED,
		ingredients = { item(ingot) }, results = { item(m .. "-ring", 4) } }
	part("fine-" .. m .. "-wire", "s")
	recipe{ name = "fine-" .. m .. "-wire", category = "lv-wiremill-recipes", time = 5,
		ingredients = { item(ingot) }, results = { item("fine-" .. m .. "-wire", 4) } }
	part("small-" .. m .. "-spring", "q")
	recipe{ name = "small-" .. m .. "-spring", category = "lv-bending-machine-recipes", time = 5,
		ingredients = { item(m .. "-rod") }, results = { item("small-" .. m .. "-spring", 2) } }
	part(m .. "-spring", "r")
	recipe{ name = m .. "-spring", category = "lv-bending-machine-recipes", time = 10,
		ingredients = { item("long-" .. m .. "-rod") }, results = { item(m .. "-spring") } }
	part(m .. "-item-casing", "p")
	recipe{ name = m .. "-item-casing", category = "lv-alloy-smelter-recipes", time = 6.4,
		subgroup = "subgroup-lv-alloy-smelter-recipes",
		ingredients = { item(ingot, 2), item("mold") }, results = { item(m .. "-item-casing", 3), item("mold") } }
	part(m .. "-frame", "t")
	recipe{ name = m .. "-frame", category = "lv-assembling-machine-recipes", time = 3.2,
		ingredients = { item(m .. "-rod", 4) }, results = { item(m .. "-frame") } }
	if d.block then
		part("block-of-" .. m, "u")
		recipe{ name = "block-of-" .. m, category = "lv-compressor-recipes", time = 15,
			ingredients = { item(ingot, 9) }, results = { item("block-of-" .. m) } }
	end
	if d.gears then
		part(m .. "-gear", "n")
		recipe{ name = m .. "-gear", category = "mv-extruder-recipes", time = s * MV_SPEED,
			ingredients = { item(ingot) }, results = { item(m .. "-gear") } }
		part("large-" .. m .. "-gear", "o")
		recipe{ name = "large-" .. m .. "-gear", category = "mv-extruder-recipes", time = 5 * s * MV_SPEED,
			ingredients = { item(ingot, 4) }, results = { item("large-" .. m .. "-gear") } }
		part(m .. "-rotor", "v")
		recipe{ name = m .. "-rotor", category = "lv-assembling-machine-recipes", time = s,
			ingredients = { item(m .. "-plate", 4), item(m .. "-ring"), fluid("soldering-alloy", 1.6) },
			results = { item(m .. "-rotor") } }
	end
end

FORK_CASTING.run()
log("FORK-GT-PARTS: " .. parts .. " new parts of realgar, thorium, antimony and molybdenum (issue #222), GT's nugget recipes "
	.. "of " .. nuggets .. " metals (issue #223), " .. made .. " recipes; casting: " .. FORK_CASTING.casts .. " casts")
