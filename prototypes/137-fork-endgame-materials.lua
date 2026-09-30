--------------------------------------------------------------------------------
--- FORK ENDGAME MATERIALS (issues #39 and #36)
--- The last draft recipes of the draft guard (FORK-DRAFT) and the endgame materials the GT
--- drafts expect. Triage and numbers: docs/ROADMAP.md, "Drafts and endgame materials".
---   1) drafts removed for good: magic (Thaumcraft) and cross-mod content, and what only
---      they used. Their recipes and items are deleted here, so the draft guard never sees them.
---   2) the circuit assembler recipe of the lapotronic energy orb cluster
---   3) GoodGenerator's high density plutonium for the plutonium based liquid fuel
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
