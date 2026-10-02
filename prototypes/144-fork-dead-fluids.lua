--------------------------------------------------------------------------------
--- FORK DEAD FLUIDS (issue #91, part 3): GregTech's producers and uses of fluids that nothing made or used
--- After parts 1 and 2 (the nether and ender air, charcoal byproducts, super glue, the melts and casts) these were
--- left; each gets what GregTech has for it. Fluids at Gregtorio's scale (a tenth of GT's), times as in GT.
---   * neon, krypton, xenon (from the nether and ender air): GT's blast furnace gases (BlastFurnaceGasStat.java).
---     GT makes every blast furnace recipe with a gas for every gas, from the nitrogen recipe: argon takes 0.8 of its
---     time and 0.85 of its gas, neon 0.6 and 0.55, krypton 0.5 and 0.4, xenon 0.4 and 0.25 (helium 0.9 and 1, radon
---     0.7 and 0.7). Every blast furnace recipe here with argon, helium or radon (GT's inert gases; nitrogen is a
---     reactant in some of Gregtorio's recipes) gets a neon, a krypton and a xenon variant, scaled from its gas:
---     EBF_GASES, unlocked with the base recipe, at the earliest with end-steel (where the gases come from)
---   * nitrogen dioxide (ender air distillation, potassium dichromate): GT's nitric acid, 2 NO2 + O + H2O -> 2 HNO3
---     (ChemicalRecipes.java, LV, 12 s)
---   * gasoline: GT's raw gasoline (naphtha, refinery gas, methanol, acetone; HV large chemical reactor, 5 s) and
---     gasoline (raw gasoline and toluene, 0.5 s), burnt like diesel: a gasoline cell for the combustion generator.
---     GT: 576 EU per litre, diesel 480 (Gregtorio's diesel cell: 800 for 192 MJ, so 500 J per GT EU) -> 230.4 MJ
--- Loaded after 143 and before 150 and 196.
--------------------------------------------------------------------------------

local F = FORK5B

--------------------------------------------------------------------------------
--- 1) NEON, KRYPTON, XENON: BLAST FURNACE GASES
--------------------------------------------------------------------------------

local GAS_STAT = { helium = { 0.9, 1.0 }, argon = { 0.8, 0.85 }, radon = { 0.7, 0.7 } }
local NOBLE = { { "neon", 0.6, 0.55 }, { "krypton", 0.5, 0.4 }, { "xenon", 0.4, 0.25 } }
--- base recipe -> technology of its variants
--- (FORK_GAS_VARIANTS: the variants made here; like the casts of 143 199's auto-unlock does not count them as
--- producers, else a variant would stand in for its base recipe, which the auto-unlock pulls in)
FORK_GAS_VARIANTS = {}
local EBF_GASES = {
	["neodymium-ingot"] = "end-steel",
	["hot-titanium-ingot"] = "end-steel",
	["hot-staballoy-ingot"] = "staballoy",
	["hot-tungsten-ingot"] = "tungsten",
	["hot-tungstensteel-ingot"] = "tungstensteel",
	["hot-iridium-ingot"] = "iv-components",
	["hot-yttrium-barium-cuprate-ingot"] = "yttrium-barium-cuprate",
	["rhodium-plated-palladium-ingot"] = "rhodium-plated-palladium",
	["hot-trinium-ingot"] = "enriched-naquadah",
	["hot-osmiridium-ingot"] = "naquadah-alloy",
	["engraved-crystal-chip"] = "crystal-processors",
	["hot-palladium-naqindium-ingot"] = "zpm-superconductors",
	["hot-itbtc-alloy-ingot"] = "crystal-processor-mainframes",
	["hot-osmium-ingot"] = "zpm-energy-hatches",
	["hot-fluxed-electrum-ingot"] = "fluxed-electrum",
	["hot-naquamiridium-ingot"] = "uv-energy-hatches",
	["hot-bedrockium-ingot"] = "bedrockium",
	["hot-triamerotronium-ingot"] = "uhv-energy-hatches",
	["hot-quantium-ingot"] = "quantium",
	["hot-dracofinium-ingot"] = "uev-energy-hatches",
	["hot-chromnorox-ingot"] = "uiv-energy-hatches",
	["hot-hypocosmium-ingot"] = "umv-energy-hatches",
	["hot-eternity-ingot"] = "uxv-energy-hatches",
}
for base, tech in pairs(EBF_GASES) do
	local r = data.raw.recipe[base]
	local gas
	for _, i in pairs(r and r.ingredients or {}) do
		if i.type == "fluid" and GAS_STAT[i.name] then gas = i end
	end
	if gas then
		local stat = GAS_STAT[gas.name]
		for _, n in pairs(NOBLE) do
			local v = table.deepcopy(r)
			v.name = base .. "-" .. n[1]
			v.energy_required = (r.energy_required or 0.5) * n[2] / stat[1]
			for _, i in pairs(v.ingredients) do
				if i.type == "fluid" and i.name == gas.name then
					i.name = n[1]
					i.amount = gas.amount * n[3] / stat[2]
				end
			end
			v.main_product = v.main_product or (r.results and r.results[1] and r.results[1].name)
			v.localised_name = { "recipe-name.fork-with-gas", { "item-name." .. v.main_product }, { "fluid-name." .. n[1] } }
			data:extend({ v })
			FORK_GAS_VARIANTS[v.name] = true
			fork_add_unlock(tech, v.name)
		end
	else
		log("FORK-DEAD-FLUIDS: no inert gas in " .. base)
	end
end



--------------------------------------------------------------------------------
--- 2) NITROGEN DIOXIDE: NITRIC ACID
--------------------------------------------------------------------------------

create_recipe{
	name = "nitric-acid-from-nitrogen-dioxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "nitrogen-dioxide", amount = 200 },
		{ type = "fluid", name = "oxygen", amount = 100 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = { { type = "fluid", name = "nitric-acid", amount = 200 } },
	main_product = "nitric-acid",
}
fork_add_unlock("end-steel", "nitric-acid-from-nitrogen-dioxide")



--------------------------------------------------------------------------------
--- 3) GASOLINE
--------------------------------------------------------------------------------

F.fluid("raw-gasoline", "light-fuel", { 0.75, 0.70, 0.25 })
create_recipe{
	name = "raw-gasoline",
	category = "hv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "naphtha", amount = 1600 },
		{ type = "fluid", name = "refinery-gas", amount = 200 },
		{ type = "fluid", name = "methanol", amount = 100 },
		{ type = "fluid", name = "acetone", amount = 100 },
	},
	results = { { type = "fluid", name = "raw-gasoline", amount = 2000 } },
}
create_recipe{
	name = "gasoline",
	category = "hv-chemical-reactor-recipes",
	energy_required = 0.5,
	ingredients = {
		{ type = "fluid", name = "raw-gasoline", amount = 1000 },
		{ type = "fluid", name = "toluene", amount = 100 },
	},
	results = { { type = "fluid", name = "gasoline", amount = 1100 } },
}
create_item{
	name = "gasoline-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "230.4MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	subgroup = data.raw.item["diesel-cell"] and data.raw.item["diesel-cell"].subgroup or nil,
	ingredients = {
		{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
		{ type = "fluid", name = "gasoline", amount = 800 },
	},
}
for _, r in pairs({ "raw-gasoline", "gasoline", "gasoline-cell" }) do fork_add_unlock("cetane-boosted-diesel", r) end
