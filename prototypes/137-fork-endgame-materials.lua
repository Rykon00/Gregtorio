--------------------------------------------------------------------------------
--- FORK ENDGAME MATERIALS (issues #39 and #36)
--- The last draft recipes of the draft guard (FORK-DRAFT) and the endgame materials the GT
--- drafts expect. Triage and numbers: docs/ROADMAP.md, "Drafts and endgame materials".
---   1) drafts removed for good: magic (Thaumcraft) and cross-mod content, and what only
---      they used. Their recipes and items are deleted here, so the draft guard never sees them.
---   2) the circuit assembler recipe of the lapotronic energy orb cluster
---   3) GoodGenerator's high density plutonium for the plutonium based liquid fuel
---   4) the materials of issue #36: super coolant (ledox, callisto ice), the 1080k super coolant
---      cell, fluxed electrum, bedrockium, quantium; UU matter is not built (see the ROADMAP)
---   5) the stand-ins they replace, where that moves nothing in front of its tier
--- Loaded after 136-fork-power.lua (the plutonium fuel and the dynamo hatches are defined there)
--- and before 150-fork-molds.lua.
--------------------------------------------------------------------------------

local F = FORK5B

local function log_removed(kind, name)
	log("FORK-REMOVED: " .. kind .. " " .. name)
end



--------------------------------------------------------------------------------
--- 1) DRAFTS REMOVED FOR GOOD
--- Nothing in the fork needs them, and their parts belong to mods or systems the fork does not
--- have. Every recipe that makes or uses one of these items is deleted with it, then every
--- technology effect that pointed at a deleted recipe.
---   * Thaumcraft: the tier five microminer (infused gold), infused gold ore, salis mundis,
---     thaumium, magic essence, void metal, shadow metal, ichorium (their UU matter as well)
---   * GT++ RuneScape materials: force plasma (arcanite), astral titanium and runite plasma
---     (titansteel); the three plasmas were only ingredients of each other
---   * GoodGenerator's atomic separation catalyst (blaze powder, manyullyn, orundum from
---     tiberium) and the naquadah fuel cracking it drives (naquadah asphalt, cracked heavy fuel,
---     thulium and thorium melt); the fuel line of 136-fork-power.lua works without them
---   * the electric implosion compressor recipe of high density plutonium (GT's EIC is not
---     built; the implosion compressors have no fluid input for its neutronium, and the nugget
---     route below makes the same item)
--------------------------------------------------------------------------------

local REMOVED_ITEMS = {
	"raw-infused-gold", "crushed-infused-gold", "infused-gold-dust", "salis-mundis", "thaumium-dust",
	"magic-essence", "void-metal-dust", "shadow-metal-dust", "ichorium-dust",
	"raw-atomic-separation-catalyst", "orundum-plate", "hot-atomic-separation-catalyst-ingot",
	"atomic-separation-catalyst-ingot",
	"high-density-plutonium-eic",
}
--- Drafts whose missing parts are fluids or items that never existed (nothing to delete but them)
local REMOVED_RECIPES = {
	"microminer-infused-gold", "force-plasma", "astral-titanium-plasma", "runite-plasma",
	"naquadah-solution-cracking", "naquadah-heavy-fuel-cracking", "naquadah-asphalt-cracking",
	"high-density-plutonium-eic",
}

do
	local gone_item, gone_recipe = {}, {}
	for _, n in pairs(REMOVED_ITEMS) do gone_item[n] = true end
	for _, n in pairs(REMOVED_RECIPES) do gone_recipe[n] = true end
	for name, r in pairs(data.raw.recipe) do
		for _, key in pairs({ "ingredients", "results" }) do
			for _, i in pairs(r[key] or {}) do
				if gone_item[i.name] then gone_recipe[name] = true end
			end
		end
	end
	for name, _ in pairs(gone_recipe) do
		if data.raw.recipe[name] then
			data.raw.recipe[name] = nil
			log_removed("recipe", name)
		end
	end
	for name, _ in pairs(gone_item) do
		for t, _ in pairs(defines.prototypes.item) do
			if data.raw[t] and data.raw[t][name] then
				data.raw[t][name] = nil
				log_removed("item", name)
			end
		end
	end
	for _, tech in pairs(data.raw.technology) do
		if tech.effects then
			local keep = {}
			for _, e in pairs(tech.effects) do
				if not (e.type == "unlock-recipe" and gone_recipe[e.recipe]) then keep[#keep + 1] = e end
			end
			tech.effects = keep
		end
	end
end



--------------------------------------------------------------------------------
--- 2) LAPOTRONIC ENERGY ORB CLUSTER, CIRCUIT ASSEMBLER RECIPE
--- The draft's "qubit processing unit" is GT's QBit processing unit (Circuit_Chip_QuantumCPU),
--- which is the qubit CPU chip here. The recipe is a second way to the cluster next to the
--- ZPM assembly line one; the lapotronic energy orb it takes (IV) was never unlocked and comes
--- with it (tech lapotronic-energy-orbs, below).
--------------------------------------------------------------------------------

F.replace_ingredient("lapotronic-energy-orb-cluster", "qubit-processing-unit", "qubit-cpu-chip", 4)



--------------------------------------------------------------------------------
--- 3) HIGH DENSITY PLUTONIUM (GoodGenerator)
--- GT: 8 plutonium oxide-uranium mixture dusts (Pu 10, O 12, U 2, C 8) + 4 HSS-S foils -> wrapped
--- plutonium ingot (EV assembler, 90 s); 2 wrapped -> 1 nugget + 8 tiny HSS-S dusts (implosion
--- compressor); 9 nuggets -> high density plutonium (compressor, 60 s); 1 high density plutonium,
--- 8 neutronium, 16 caesium and 2 naquadah dust -> 1000 plutonium based liquid fuel (LuV mixer).
--- Here the mixture is its metal content: 8 mixture dusts hold 2.5 plutonium and 0.5 uranium, so a
--- wrap takes 3 plutonium 239 and 1 uranium 238 dust (oxygen and carbon left out; no mixture item).
--- The tiny HSS-S dust byproduct is left out (no HSS-S dust here). One high density plutonium is
--- 54 plutonium dust, about the 64 dust the fuel took as a stand-in before. The fuel keeps
--- neutronium ingots for GT's neutronium dust (no dust here).
--------------------------------------------------------------------------------

F.redo("wrapped-plutonium-ingot", {
	ingredients = {
		{ type = "item", name = "plutonium-239-dust", amount = 3 },
		{ type = "item", name = "uranium-238-dust", amount = 1 },
		{ type = "item", name = "hsss-foil", amount = 4 },
	},
})
F.redo("high-density-plutonium-nugget", {
	energy_required = 1,
	results = { { type = "item", name = "high-density-plutonium-nugget", amount = 1 } },
})
F.redo("plutonium-based-liquid-fuel", {
	ingredients = {
		{ type = "item", name = "high-density-plutonium", amount = 1 },
		{ type = "item", name = "neutronium-ingot", amount = 2 },
		{ type = "item", name = "caesium-dust", amount = 16 },
		{ type = "item", name = "naquadah-dust", amount = 2 },
	},
})



--------------------------------------------------------------------------------
--- 4) ENDGAME MATERIALS (issue #36)
--- The end (tier three microminer) gets three more veins, like the naquadah one of phase 1: GT
--- mines ledox, callisto ice, bedrockium and quantium on moons, planets and asteroids of
--- GalaxySpace, which the microverse projector stands in for.
--------------------------------------------------------------------------------

local function microminer(name, count, results, main)
	create_recipe{
		name = name,
		category = "lv-assembling-machine-recipes",
		energy_required = 8,
		subgroup = "subgroup-microminer-t3",
		ingredients = { { type = "item", name = "tier-three-microminer-output", amount = count } },
		results = results,
		main_product = main,
	}
end

--- 4a) SUPER COOLANT (LuV). The draft: ledox dust, callisto ice dust and lapis coolant in the HV
--- mixer (GT5-Unofficial has no recipe of its own; GT uses it from grade 5 water on). Ledox has
--- its ore line already (07-ore-processing-module.lua); callisto ice comes out as dust.
create_item{ skip_recipe = true, name = "callisto-ice-dust", subgroup = "subgroup-microminer-t3" }
microminer("microminer-ledox", 1, {
	{ type = "item", name = "raw-ledox", amount = 24 },
	{ type = "item", name = "callisto-ice-dust", amount = 16 },
}, "raw-ledox")
F.fluid("super-coolant", "spackled-light-blue-fluid", { 0.45, 0.80, 1.00 })

--- 4b) 1080K SUPER COOLANT CELL (UHV). The drafts: 3 x 180k -> 540k, 2 x 540k + a dense fluxed
--- electrum plate -> 1080k space cell, canned with 600 super coolant. GT: Reactor_Coolant_Sp_6,
--- 2 / 4 / 6 / 8 in the UEV / UIV / UMV / UXV energy and dynamo hatches (section 5).

--- 4c) FLUXED ELECTRUM (ZPM). GT: 9000 K, the dust recipe is not in GT5-Unofficial (Redstone
--- Arsenal: electrum + redstone). Here electrum and redstone with naquadah, which puts it at ZPM:
--- dust from the ZPM mixer, ingot from the ZPM blast furnace and vacuum freezer, melt from the
--- ZPM alloy blast smelter. Parts: plate, dense plate (space cell), foil, wire and fine wire.
create_ingot("fluxed-electrum", "zpm", 10 * ZPM_SPEED, {
		{ type = "item", name = "electrum-dust", amount = 4 },
		{ type = "item", name = "redstone-dust", amount = 2 },
		{ type = "item", name = "naquadah-dust", amount = 1 },
	},
	7, "zpm", ZPM_SPEED * 90, F.argon(),
	"zpm", ZPM_SPEED * 24, false, true, true, nil, true, false)
create_metal_parts{ material = "fluxed-electrum", speed = 10, make_plate = true, make_dense_plate = true,
	make_foil = true, make_wire = true, make_fine_wire = true }
F.fluid("molten-fluxed-electrum", "spackled-silvery-gold-fluid", { 0.95, 0.85, 0.40 })

--- 4d) BEDROCKIUM (UV). GT: 9900 K, the UHV cable. The upstream draft microminer-bedrockium
--- (23-zpm-age-item.lua, tier seven) on the end; the ore line exists; ingot from the UV blast
--- furnace and vacuum freezer; plate, wire and cable (like the other endgame cables).
microminer("microminer-bedrockium", 2, {
	{ type = "item", name = "raw-bedrockium", amount = 32 },
	{ type = "item", name = "compressed-end-stone", amount = 8 },
}, "raw-bedrockium")
create_ingot("bedrockium", nil, nil, nil, 1, "uv", UV_SPEED * 99, F.argon(),
	"uv", UV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "bedrockium", speed = 10, make_plate = true, make_wire = true }
F.cable("bedrockium")

--- 4e) QUANTIUM (UHV). GT: 9900 K ore (Venus, Horus; niobium asteroids), the UEV component melt
--- and the UMV cable. Dust from the end, ingot from the UHV blast furnace and vacuum freezer, melt
--- from the extractor, wire and cable.
create_item{ skip_recipe = true, name = "quantium-dust", subgroup = "subgroup-microminer-t3" }
microminer("microminer-quantium", 2, {
	{ type = "item", name = "quantium-dust", amount = 24 },
	{ type = "item", name = "compressed-end-stone", amount = 8 },
}, "quantium-dust")
create_ingot("quantium", nil, nil, nil, 1, "uhv", UHV_SPEED * 99, F.argon(),
	"uhv", UHV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "quantium", speed = 10, make_wire = true }
F.cable("quantium")
F.fluid("molten-quantium", "spackled-purple-fluid", { 0.55, 0.35, 0.80 })
create_recipe{
	name = "molten-quantium",
	category = "iv-extractor-recipes",
	energy_required = 1.2 * IV_SPEED,
	ingredients = { { type = "item", name = "quantium-ingot", amount = 1 } },
	results = { { type = "fluid", name = "molten-quantium", amount = 14.4 } },
}



--------------------------------------------------------------------------------
--- 5) STAND-INS REPLACED (GT's material where the phases had to use another one)
--- Not switched, on purpose: the UHV parts stay tritanium (phase 5a; only their cable changes),
--- the uranium based liquid fuel keeps naquadah dust for quantium (ZPM fuel, UHV material), the
--- UHV and UEV hatches keep cryogenic helium (GT: IC2 coolant), the tritanium coil stays the UHV
--- blast furnace coil (GT's fluxed electrum coil is the level above).
--------------------------------------------------------------------------------

local function swap(recipes, from, to, amount)
	for _, r in pairs(recipes) do
		local rec = data.raw.recipe[r]
		if not rec then log("FORK-ENDGAME: missing recipe: " .. r) else
			local found = false
			for _, i in pairs(rec.ingredients or {}) do
				if i.name == from then i.name = to; i.amount = amount or i.amount; found = true end
			end
			if not found then log("FORK-ENDGAME: " .. r .. " has no " .. from) end
		end
	end
end
local function hatches(tiers)
	local out = {}
	for _, t in pairs(tiers) do
		out[#out + 1] = t .. "-energy-hatch"
		out[#out + 1] = t .. "-dynamo-hatch"
	end
	return out
end
local COMPONENTS = { "motor", "pump", "conveyor-module", "piston", "robot-arm", "emitter", "sensor", "field-generator" }
local function components(tier)
	local out = {}
	for _, c in pairs(COMPONENTS) do out[#out + 1] = tier .. "-" .. c end
	return out
end

--- Super coolant: grade 5 water (GT: 100 per craft, left out before), grade 7 water and the UIV to
--- UXV hatches (cryogenic helium; GT uses super coolant from UIV up)
do
	local r = data.raw.recipe["grade-5-water"]
	if r then table.insert(r.ingredients, { type = "fluid", name = "super-coolant", amount = 100 }) end
end
swap({ "grade-7-water" }, "cryogenic-helium", "super-coolant")
swap(hatches({ "uiv", "umv", "uxv" }), "cryogenic-helium", "super-coolant")
--- 1080k super coolant cells in the UEV to UXV hatches (GT: 2 / 4 / 6 / 8 space coolant cells)
for i, t in pairs({ "uev", "uiv", "umv", "uxv" }) do
	for _, r in pairs(hatches({ t })) do
		local rec = data.raw.recipe[r]
		if rec then
			table.insert(rec.ingredients, { type = "item", name = "1080k-super-coolant-cell", amount = 2 * i })
		end
	end
end

--- Fluxed electrum: UV voltage coil (fine americium wire), UHV emitter and sensor (tritanium foil),
--- fusion MK3 controller (tritanium melt), naquadah based fuel MK2 (naquadria dust; GT: 32)
swap({ "ultimate-voltage-coil" }, "fine-americium-wire", "fine-fluxed-electrum-wire")
swap({ "uhv-emitter", "uhv-sensor" }, "tritanium-foil", "fluxed-electrum-foil")
swap({ "fusion-reactor-mk3-controller" }, "molten-tritanium", "molten-fluxed-electrum")
swap({ "naquadah-based-fuel-mk2" }, "naquadria-dust", "fluxed-electrum-dust", 32)

--- Bedrockium: the UHV cable of the UHV components (tritanium cable), the UEV casing (draft)
swap(components("uhv"), "tritanium-cable", "bedrockium-cable")
swap({ "uev-machine-casing" }, "cosmic-neutronium-plate", "bedrockium-plate")

--- Quantium: the melt of the UEV components (cosmic neutronium melt), the UMV cable of the UMV
--- components (spacetime cable)
swap(components("uev"), "molten-cosmic-neutronium", "molten-quantium")
swap(components("umv"), "spacetime-cable", "quantium-cable")



--------------------------------------------------------------------------------
--- UNLOCKS
--------------------------------------------------------------------------------

--- The circuit assembler cluster and the orb it takes: a tech of their own after the ZPM assembly
--- line (the cluster tech of phase 3, ZPM science) and the techs of their chips and board. Its fine
--- niobium-titanium wire would make the auto-unlock visit the new tech before advanced-smds and
--- move the wire there, so it is bound to advanced-smds (where the auto-unlock put it so far).
fork_add_unlock("advanced-smds", "fine-niobium-titanium-wire")
F.tech{
	name = "lapotronic-energy-orbs",
	prerequisites = { "zpm-assembly-line", "qubit-cpus", "nanoprocessors", "ev-energy-hatches",
		"industrial-precision-lathe", "me-storage-256k" },
	packs = 8, count = 2000,
	recipes = { "lapotronic-energy-orb", "lapotronic-energy-orb-cluster" },
}
--- With the fuel that needs it (ZPM science)
for _, r in pairs({ "wrapped-plutonium-ingot", "high-density-plutonium-nugget", "high-density-plutonium" }) do
	fork_add_unlock("naquadah-fuels", r)
end

--- Issue #36: one technology per material, at the tier that needs it first
F.tech{
	name = "super-coolant", prerequisites = { "tier-three-microminers", "luv-machines" }, packs = 7, count = 2000,
	recipes = { "microminer-ledox", "crushed-ledox", "ledox-dust", "centrifuging-crushed-ledox", "super-coolant" },
}
F.tech{
	name = "fluxed-electrum", prerequisites = { "zpm-multiblocks", "naquadah-processing" }, packs = 8, count = 3000,
	recipes = { "fluxed-electrum-dust", "hot-fluxed-electrum-ingot", "fluxed-electrum-ingot", "molten-fluxed-electrum",
		"solidify-fluxed-electrum-ingot", "fluxed-electrum-plate", "dense-fluxed-electrum-plate", "fluxed-electrum-foil",
		"fluxed-electrum-wire", "fine-fluxed-electrum-wire" },
}
F.tech{
	name = "bedrockium", prerequisites = { "uv-multiblocks", "tier-three-microminers" }, packs = 9, count = 4000,
	recipes = { "microminer-bedrockium", "crushed-bedrockium", "bedrockium-dust", "centrifuging-crushed-bedrockium",
		"hot-bedrockium-ingot", "bedrockium-ingot", "bedrockium-plate", "bedrockium-wire", "bedrockium-cable" },
}
F.tech{
	name = "space-coolant-cells", prerequisites = { "uhv-machines", "super-coolant", "fluxed-electrum" }, packs = 10,
	count = 2500,
	recipes = { "180k-space-cell", "540k-space-cell", "1080k-space-cell", "1080k-super-coolant-cell" },
}
F.tech{
	name = "quantium", prerequisites = { "uhv-multiblocks", "tier-three-microminers" }, packs = 10, count = 3000,
	recipes = { "microminer-quantium", "hot-quantium-ingot", "quantium-ingot", "molten-quantium", "quantium-wire",
		"quantium-cable" },
}
--- The first users of each material need it
for tech, pre in pairs({
	["water-purification"] = "super-coolant",
	["uv-energy-hatches"] = "fluxed-electrum",
	["uhv-components"] = "bedrockium",
	["uev-energy-hatches"] = "space-coolant-cells",
	["uev-components"] = "quantium",
}) do
	table.insert(data.raw.technology[tech].prerequisites, pre)
end
