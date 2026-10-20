--------------------------------------------------------------------------------
--- FORK GODFORGE (roadmap phase 6b, issue #37)
--- GT's Forge of the Gods (TecTech MTEForgeOfGods and its modules) as one entity. Issue #355 (the maintainer's
--- decision): at GT New Horizons' place, between the UIV and UMV energy hatches (before: after the stargate):
---   * the godforge: a 13x13 UMV multiblock (two UIV energy hatches, one UMV amp) with GT's recipes of the stellar
---     energy siphon casing, the singularity reinforced stellar shielding casing, the remote graviton flow modulator
---     (it takes the quantum anomaly of 164 section 19) and the controller
---   * raw star matter (GT: condensed raw stellar plasma mixture), the forge's fuel: every godforge
---     recipe burns some, the way GT's star drains fuel while the modules run
---   * the plasma module: celestial tungsten plasma (GT's multi-step plasma) with the technology of GT's upgrades
---     that allow it; after the stargate, lead, thorium and naquadria plasma for the stellar catalyst
---   * after the stargate as before:
---   * the molten module: universium (GT makes it in the eye of harmony, see "6b hook" in 139)
---   * the exotic module: tachyon rich temporal and spatially enlarged fluid from spacetime, and magmatter,
---     the MAX metal (141-fork-max.lua)
---   * the stellar catalyst tier of the plasma forge (139-fork-endgame-multiblocks.lua: 6b hook)
---   * the infinite technology `godforge-upgrades` (GT's graviton shard upgrades): productivity for the
---     godforge's products, the long-term sink after `victory` together with the further victory levels
--- Simplified, on purpose (see "Phase 6b: MAX tier and godforge" in docs/ROADMAP.md):
---   * one entity runs every module's recipes; GT's modules, rings and 31 upgrades become technologies (the forge,
---     the plasma module, the molten module, the exotic module) and the infinite one
---   * no heat, fuel factor, milestones or graviton shards; no random exotic challenges: one magmatter
---     recipe per input metal (GT draws the metal at random), the plasma GT returns is the metal's melt
---   * no wireless EU: power through the energy hatches in the recipe, like the plasma forge
---   * no eye of harmony: its products (ore dusts per dimension, white and black dwarf matter for nanites)
---     have no consumer in the mod; raw star matter and universium come from the godforge instead
--------------------------------------------------------------------------------

local F = FORK5B

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

local GODFORGE = "godforge"
local GODFORGE_CAT = "godforge-recipes"
F.category(GODFORGE_CAT)
local function seconds(s) return s * UMV_SPEED end



--------------------------------------------------------------------------------
--- 1) PARTS AND THE GODFORGE
--- GT (tectech/loader/recipe/ResearchStationAssemblyLine.java, addGodforgeRecipes 2393-2544 and runLateRecipes
--- 2998-3029): research station assembly line recipes at UIV (the casings and the flow modulator) and UMV (the
--- controller), here in the assembly line with GT's seconds, fluids a tenth of GT's litres, plasmas GT's litres.
--- GT's wireGt08 and wireGt16 superconductors are 2 and 4 wires (as the plasma forge's controller in 139), GT++'s
--- Quantum is transcendent metal (as 133), the item of the godforge is the mod's (the controller with its casings,
--- hatches and hulls). Left out:
---   * creon, mellion and metastable oganesson (a named deviation, issue #355): GT New Horizons makes them from
---     celestial tungsten plasma, which the mod makes in the godforge's plasma module, so they would close a cycle;
---     the shielding casing's molten celestial tungsten for the same reason
---   * GT items the mod does not have: the eternal and combined singularities, the ZPM4 batteries, the Stable Boson
---     Containment Units, the UIV energy tunnel and energy distributor, the hypogen coils and plates (hypogen and
---     Six-Phased Copper themselves: 164 section 35, issue #436), the Boundless Gravitationally Severed Structure Casing (AmunRa) and the Magnetic Confinement Casing (creon,
---     hypogen, tengam), the Neutronium Heat Capacitors, the UV plasma generators, the Field Restriction Coil, the
---     Graviton Anomaly, the nanites, netherite, infinity catalyst, titansteel, proto-halkonite and abyssal, the
---     godforge glass (creon, mellion), and the excited exotic catalyst (GT's DTEC: the mod's plasma forge has the
---     crude and resplendent tiers)
--- GT's godforge draws wireless EU; here two UIV energy hatches (four UIV amps carry its one UMV amp, as the plasma
--- forge's UEV hatches carry its UIV amp).
--------------------------------------------------------------------------------

local SUBGROUP = "subgroup-umv-age-multiblocks"
--- GT++'s quantum anomaly (Laser_Lens_Special): its recipe is in 164 section 19 (it needs the Hi-Computation Station
--- Mk-V); 150 puts it in the laser engraver's lens slot like GT's lenses
create_item{ skip_recipe = true, name = "quantum-anomaly", subgroup = data.raw.item["gravi-star"].subgroup,
	stack_size = 64 }

create_item{
	name = "stellar-energy-siphon-casing",
	category = "zpm-assembly-line-recipes",
	energy_required = 10 * ZPM_SPEED,
	ingredients = {
		item("chromnorox-superconductive-wire", 64),
		item("1080k-super-coolant-cell", 2),
		fluid("molten-indalloy-140", 230.4),
		fluid("molten-chromnorox", 460.8),
	},
}
create_item{
	name = "singularity-reinforced-stellar-shielding-casing",
	category = "zpm-assembly-line-recipes",
	energy_required = 30 * ZPM_SPEED,
	results = { item("singularity-reinforced-stellar-shielding-casing", 4) },
	ingredients = {
		item("superdense-infinity-plate", 2),
		item("transcendent-metal-plate", 16),
		item("long-chromnorox-rod", 8),
		item("long-dracofinium-rod", 8),
		item("superdense-transcendent-metal-plate", 2),
		item("superdense-cosmic-neutronium-plate", 2),
		fluid("molten-indalloy-140", 1843.2),
		fluid("molten-bedrockium", 235929.6),
		fluid("molten-neutronium", 29491.2),
	},
}
create_item{
	name = "remote-graviton-flow-modulator",
	category = "zpm-assembly-line-recipes",
	energy_required = 10 * ZPM_SPEED,
	results = { item("remote-graviton-flow-modulator", 2) },
	ingredients = {
		item("quantum-anomaly", 4),
		item("uiv-emitter", 4),
		item("uev-circuit", 16),
		fluid("molten-indalloy-140", 460.8),
		fluid("molten-chromnorox", 460.8),
		fluid("molten-infinity", 460.8),
	},
}
create_item{
	name = GODFORGE .. "-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = 300 * ZPM_SPEED,
	ingredients = {
		item("stellar-energy-siphon-casing", 4),
		item("dimensional-bridge", 64),
		item("chromnorox-superconductive-wire", 64),
		item("uiv-sensor", 32),
		item("uiv-circuit", 64),
		fluid("molten-indalloy-140", 29491.2),
		fluid("thorium-plasma", 36864),
		fluid("molten-transcendent-metal", 29491.2),
	},
}
create_item{
	name = GODFORGE,
	category = "umv-assembling-machine-recipes",
	energy_required = 300 * UMV_SPEED,
	subgroup = SUBGROUP,
	stack_size = 10,
	place_result = GODFORGE,
	ingredients = {
		item(GODFORGE .. "-controller", 1),
		item("singularity-reinforced-stellar-shielding-casing", 64),
		item("stellar-energy-siphon-casing", 8),
		item("remote-graviton-flow-modulator", 4),
		item("uiv-energy-hatch", 2),
		item("uiv-machine-hull", 8),
	},
}

--- 13x13, one UMV amp (1310.72 MW, as each fusion reactor takes one amp of its tier), cloned from the MK5 like the
--- plasma forge: five fluid inputs north and one west, two outputs south
F.clone_multiblock{
	name = GODFORGE, source = "fusion-reactor-mk5", size = { 13, 13 }, categories = { GODFORGE_CAT },
	speed = UMV_SPEED, energy = "1310.72MW", icon = data.raw.item[GODFORGE].icon, subgroup = SUBGROUP,
}
do
	local m = data.raw["assembling-machine"][GODFORGE]
	m.fluid_boxes = {
		fluid_port(-4, -6, "input", defines.direction.north),
		fluid_port(-2, -6, "input", defines.direction.north),
		fluid_port( 0, -6, "input", defines.direction.north),
		fluid_port( 2, -6, "input", defines.direction.north),
		fluid_port( 4, -6, "input", defines.direction.north),
		fluid_port(-6,  0, "input", defines.direction.west),
		fluid_port(-2,  6, "output", defines.direction.south),
		fluid_port( 2,  6, "output", defines.direction.south),
	}
	for _, fb in pairs(m.fluid_boxes) do
		fb.pipe_covers = pipecoverspictures()
		fb.pipe_picture = assembler2pipepictures()
	end
	m.fluid_boxes_off_when_no_fluid_recipe = true
end



--------------------------------------------------------------------------------
--- 2) RAW STAR MATTER AND THE PLASMA MODULE
--- GT: the eye of harmony turns hydrogen and helium into raw star matter (1e9 litres each per 1e5), the
--- godforge burns it (or residue, or MHDCSM) as long as its modules run. Here the godforge makes it
--- itself from hydrogen and helium with crude catalyst to ignite the star, and every godforge recipe
--- burns STAR_FUEL per second of its time.
--- Plasma module (GT: tectech/loader/recipe/Godforge.java, 1 dust or 144 L of melt -> 144 L of plasma): celestial
--- tungsten (issue #355: GT's multi-step plasma of tier 0, 4 s at UXV, 184-225), which needs GT's module upgrades
--- GPCI (the module connects) and TPTP (multi-step plasmas; godforge/util/GodforgeMath.java:295, 302-322; 17
--- graviton shards on the cheapest path): the technology `godforge-plasma-module`. Its dust is GT++'s laser engraver
--- recipe (gtPlusPlus/core/recipe/RecipesGregTech.java:809-818): 6 tungsten dust with the quantum anomaly as the lens,
--- 3 min at UEV. After the stargate, the three plasmas of the stellar catalyst (GT's tier 1, which needs the SEDS
--- upgrade: 1 s, 10 s for naquadria). Thorium and lead plasma
--- have GT's fuel values (136, issues #375 and #397), naquadria plasma none.
--------------------------------------------------------------------------------

local STAR = "raw-star-matter"
local STAR_FUEL = 0.25 -- raw star matter per second of godforge time
F.fluid(STAR, "spackled-silvery-gold-fluid", { 0.95, 0.80, 0.45 })
F.fluid("lead-plasma", "medium-gray-fluid", { 0.55, 0.50, 0.65 })
F.fluid("thorium-plasma", "dark-gray-spackled-fluid", { 0.35, 0.30, 0.30 })
F.fluid("naquadria-plasma", "rich-green-fluid", { 0.30, 0.85, 0.40 })

local godforge_recipes = { plasma = {}, tier1 = {}, molten = {}, exotic = {} }
--- A godforge recipe: `time` seconds in the godforge, plus its star fuel
local function godforge_recipe(module, def)
	local ingredients = def.ingredients
	if def.fuel ~= false then ingredients[#ingredients + 1] = fluid(STAR, def.time * STAR_FUEL) end
	create_recipe{
		name = def.name,
		category = GODFORGE_CAT,
		energy_required = seconds(def.time),
		subgroup = "subgroup-" .. GODFORGE_CAT,
		ingredients = ingredients,
		results = def.results,
		main_product = def.main_product,
	}
	--- for the productivity of `godforge-upgrades` (the godforge has no module slots)
	data.raw.recipe[def.name].allow_productivity = true
	godforge_recipes[module][#godforge_recipes[module] + 1] = def.name
end

godforge_recipe("plasma", {
	name = STAR, time = 20, fuel = false,
	ingredients = { fluid("hydrogen", 1000), fluid("helium", 1000),
		fluid("excited-dimensionally-transcendent-crude-catalyst", 10) },
	results = { fluid(STAR, 100) },
})
godforge_recipe("tier1", {
	name = "lead-plasma", time = 1,
	ingredients = { item("lead-ingot", 1) },
	results = { fluid("lead-plasma", 144) },
})
godforge_recipe("tier1", {
	name = "thorium-plasma", time = 1,
	ingredients = { item("thorium-dust", 1) },
	results = { fluid("thorium-plasma", 144) },
})
godforge_recipe("tier1", {
	name = "naquadria-plasma", time = 10,
	ingredients = { fluid("molten-naquadria", 144) },
	results = { fluid("naquadria-plasma", 144) },
})
create_item{ skip_recipe = true, name = "celestial-tungsten-dust", subgroup = "subgroup-macerator-dust" }
F.fluid("celestial-tungsten-plasma", "celestial-tungsten-plasma", { 0.53, 0.55, 0.55 })   -- (GT++'s plasma texture, lifted)
create_recipe{
	name = "celestial-tungsten-dust",
	category = "uev-laser-engraver-recipes",
	energy_required = 180 * UEV_SPEED,
	ingredients = { item("tungsten-dust", 6), item("quantum-anomaly", 1) },
	results = { item("celestial-tungsten-dust", 1), item("quantum-anomaly", 1) },
	main_product = "celestial-tungsten-dust",
}
godforge_recipe("plasma", {
	name = "celestial-tungsten-plasma", time = 4 * UXV_SPEED / UMV_SPEED,
	ingredients = { item("celestial-tungsten-dust", 1) },
	results = { fluid("celestial-tungsten-plasma", 144) },
})



--------------------------------------------------------------------------------
--- 3) MOLTEN MODULE: UNIVERSIUM (6b hook of 139-fork-endgame-multiblocks.lua)
--- GT makes universium in the eye of harmony (rocket tiers 7 to 9), never in the plasma forge. Here the
--- godforge takes the inputs of the MK5 recipe (spacetime and flerovium) at half per ingot, in a sixth of
--- the reactor time (the plasma forge: two thirds, a third), 20 ingots per craft. The MK5 recipe stays the
--- entry route and the plasma forge recipes stay too (the stargate and the UXV tier come before the
--- godforge, and the plasma forge is their faster route).
--------------------------------------------------------------------------------

do
	local src = data.raw.recipe["molten-universium"]
	local out = src.results[1].amount
	local batch = 288
	local ingredients = {}
	for _, i in pairs(src.ingredients) do
		ingredients[#ingredients + 1] = fluid(i.name, i.amount * (batch / out) / 2)
	end
	local mk5_seconds = src.energy_required * (batch / out) / 1024
	godforge_recipe("molten", {
		name = "molten-universium-godforge", time = mk5_seconds / 6,
		ingredients = ingredients,
		results = { fluid("molten-universium", batch) },
		main_product = "molten-universium",
	})
end



--------------------------------------------------------------------------------
--- 4) EXOTIC MODULE: TIME, SPACE AND MAGMATTER
--- GT: tachyon rich temporal fluid and spatially enlarged fluid come from tesseracts in the centrifuge
--- (2880 L spacetime -> 1440 L of each); here the godforge splits molten spacetime. Magmatter: GT's
--- exoticizer asks for t L of temporal fluid, s L of spatial fluid (t < 50 < s) and 144 (s - t) L of the
--- plasma of a random metal and gives 576 L of magmatter (12.5 litres of plasma per litre). Here one
--- recipe per metal, with its melt instead of its plasma (the mod has no plasmas of these metals) at GT's
--- ratio, and equal parts of the two fluids, so the split above feeds it exactly. The metals are GT's list
--- as far as the mod has them; the player picks the one that is cheapest for them.
--------------------------------------------------------------------------------

F.fluid("tachyon-rich-temporal-fluid", "imaginary-time", { 0.95, 0.55, 0.85 })
F.fluid("spatially-enlarged-fluid", "spackled-medium-blue-fluid", { 0.35, 0.45, 0.95 })
F.fluid("molten-magmatter", "spackled-purple-fluid", { 0.60, 0.15, 0.55 })

godforge_recipe("exotic", {
	name = "spacetime-time-space-separation", time = 10,
	ingredients = { fluid("molten-spacetime", 288) },
	results = { fluid("tachyon-rich-temporal-fluid", 144), fluid("spatially-enlarged-fluid", 144) },
	main_product = "tachyon-rich-temporal-fluid",
})
local MAGMATTER_METALS = { "neutronium", "tritanium", "cosmic-neutronium", "draconium", "infinity", "rhugnor",
	"flerovium" }
local MAGMATTER_BATCH = 80          -- molten magmatter per craft
local MAGMATTER_RATIO = 12.5        -- GT: 144 (s - t) L of plasma per 576 L, s - t = 50 on average
local MAGMATTER_FLUIDS = 7          -- temporal and spatial fluid each per craft (GT: about 25 and 75 per 576)
for _, metal in pairs(MAGMATTER_METALS) do
	godforge_recipe("exotic", {
		name = "molten-magmatter-from-" .. metal, time = 20,
		ingredients = {
			fluid("molten-" .. metal, MAGMATTER_BATCH * MAGMATTER_RATIO),
			fluid("tachyon-rich-temporal-fluid", MAGMATTER_FLUIDS),
			fluid("spatially-enlarged-fluid", MAGMATTER_FLUIDS),
		},
		results = { fluid("molten-magmatter", MAGMATTER_BATCH) },
		main_product = "molten-magmatter",
	})
end
--- Quark gluon plasma (issue #249). GT's exoticizer in QGP mode takes 7 random plasmas (an item plasma 1 to 7 x 1296 L,
--- a gas plasma 1000 to 64 000 L; MTEExoticModule.java 204-237, Godforge.java 474-633) and gives 1000 L per parallel
--- in 10 s at MAX. Here one fixed recipe from plasmas of GT's list that the mod has, at GT's averages (an item
--- plasma 4 x 1296 L, the gas plasma 32 000 L, a tenth here): iron, calcium, niobium and titanium, helium. Its use is
--- GT's rhugnor MK5 recipe below.
F.fluid("quark-gluon-plasma", "quark-gluon-plasma", { 0.85, 0.40, 0.95 })
godforge_recipe("exotic", {
	name = "quark-gluon-plasma", time = 10,
	ingredients = { fluid("iron-plasma", 518.4), fluid("calcium-plasma", 518.4), fluid("niobium-plasma", 518.4),
		fluid("titanium-plasma", 518.4), fluid("helium-plasma", 3200) },
	results = { fluid("quark-gluon-plasma", 100) },
	main_product = "quark-gluon-plasma",
})
--- GT's rhugnor MK5 (gtPlusPlus/core/recipe/RecipesGregTech.java 323-331): 72 L QGP + 576 L quantum -> 576 L rhugnor in
--- 2.5 s (UEV). Quantum is molten transcendent metal here, as in the MK4 recipe (133-fork-umv.lua).
create_recipe{
	name = "molten-rhugnor-from-quark-gluon-plasma",
	category = "mk5-fusion-reactor-recipes",
	energy_required = 2.5 * UEV_SPEED,
	subgroup = "subgroup-mk5-fusion-reactor-recipes",
	ingredients = { fluid("quark-gluon-plasma", 7.2), fluid("molten-transcendent-metal", 57.6) },
	results = { fluid("molten-rhugnor", 57.6) },
	main_product = "molten-rhugnor",
}



--------------------------------------------------------------------------------
--- 5) STELLAR CATALYST OF THE PLASMA FORGE (6b hook of 139-fork-endgame-multiblocks.lua)
--- GT (MixerRecipes, DTPFRecipes): 1000 exotic catalyst, 1000 lead and thorium plasma, 100 naquadria plasma
--- and 25 raw star matter -> 1000 stellar catalyst, the eternal coil tier of the forge. The exotic tier is
--- not built here, so the resplendent catalyst goes in. The third recipe tier of the forge's metals makes
--- four times the crude batch in the same time, for half the resplendent catalyst per second of reactor
--- time (the same rule as in 139: CATALYST per second of a MK5).
--------------------------------------------------------------------------------

local DTPF_CAT = "dimensionally-transcendent-plasma-forge-recipes"
local STELLAR = "excited-dimensionally-transcendent-stellar-catalyst"
F.fluid(STELLAR, "spackled-yellow-fluid", { 0.98, 0.85, 0.35 })
create_recipe{
	name = STELLAR,
	category = DTPF_CAT,
	energy_required = 20 * UMV_SPEED,
	subgroup = "subgroup-" .. DTPF_CAT,
	ingredients = {
		fluid("excited-dimensionally-transcendent-resplendent-catalyst", 100),
		fluid("lead-plasma", 100),
		fluid("thorium-plasma", 100),
		fluid("naquadria-plasma", 10),
		fluid(STAR, 2.5),
	},
	results = { fluid(STELLAR, 100) },
}
local stellar_recipes = { STELLAR }
do
	local STELLAR_BATCH, STELLAR_PER_S = 576, 0.25
	for _, metal in pairs({ "molten-neutronium", "molten-cosmic-neutronium", "molten-infinity",
		"molten-transcendent-metal", "molten-spacetime", "molten-universium" }) do
		--- the crude recipe of 139 has the inputs per output and the time for 144
		local crude = data.raw.recipe[metal .. "-dtpf-crude"]
		local src = data.raw.recipe[metal]
		local out = src.results[1].amount
		local ingredients = {}
		for _, i in pairs(crude.ingredients) do
			if i.name ~= "excited-dimensionally-transcendent-crude-catalyst" then
				ingredients[#ingredients + 1] = { type = i.type, name = i.name, amount = i.amount * STELLAR_BATCH / 144 }
			end
		end
		local mk5_seconds = src.energy_required * (STELLAR_BATCH / out) / 1024
		ingredients[#ingredients + 1] = fluid(STELLAR, mk5_seconds * STELLAR_PER_S)
		local name = metal .. "-dtpf-stellar"
		create_recipe{
			name = name,
			category = DTPF_CAT,
			energy_required = crude.energy_required,
			subgroup = "subgroup-" .. DTPF_CAT,
			ingredients = ingredients,
			results = { fluid(metal, STELLAR_BATCH) },
			main_product = metal,
		}
		stellar_recipes[#stellar_recipes + 1] = name
	end
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES (the unit counts are set in 138-fork-research-balance.lua)
---   * the godforge and its plasma module: UMV science, between the UIV and UMV energy hatches (issue #355); the
---     godforge also unlocks the quantum anomaly, the chromatic lens and the resplendent catalyst (164 section 19),
---     their first consumer
---   * the molten and exotic modules, the stellar catalyst and the upgrades: MAX science, after the stargate
--- `victory` is no prerequisite: it is an infinite technology, and Factorio counts those as researched for
--- prerequisites only at their last level. The MAX packs come from the stargate, whose first 15 packs research
--- the first level of `victory`.
--------------------------------------------------------------------------------

F.tech{
	--- (the UMV machines come after the UIV energy hatch and the plasma forge; the Mk-III precise assembler makes
	--- the Hi-Computation Station Mk-V of the quantum anomaly)
	name = GODFORGE, prerequisites = { "precise-electronic-unit-mk3", "umv-machines" }, packs = 13, count = 1,
	recipes = { "stellar-energy-siphon-casing", "singularity-reinforced-stellar-shielding-casing",
		"remote-graviton-flow-modulator", GODFORGE .. "-controller", GODFORGE },
}
F.tech{
	name = "godforge-plasma-module", prerequisites = { GODFORGE }, packs = 13, count = 1,
	recipes = F.join({ "celestial-tungsten-dust" }, godforge_recipes.plasma),
}
--- the resplendent catalyst goes to the godforge (the quantum anomaly, 164); its tier of the forge's metals stays
--- after the UXV multiblocks
do
	local t = data.raw.technology["dtpf-resplendent-catalyst"]
	local keep = {}
	for _, e in pairs(t.effects) do
		if e.recipe ~= "excited-dimensionally-transcendent-resplendent-catalyst" then keep[#keep + 1] = e end
	end
	t.effects = keep
	t.prerequisites[#t.prerequisites + 1] = GODFORGE
	fork_add_unlock(GODFORGE, "excited-dimensionally-transcendent-resplendent-catalyst")
end
F.tech{
	name = "godforge-molten-module", prerequisites = { "godforge-plasma-module", "stargate" }, packs = 15, count = 1,
	recipes = godforge_recipes.molten,
}
F.tech{
	name = "godforge-exotic-module", prerequisites = { "godforge-molten-module" }, packs = 15, count = 1,
	recipes = F.join(F.join({}, godforge_recipes.exotic), { "molten-rhugnor-from-quark-gluon-plasma" }),
}
F.tech{
	name = "dtpf-stellar-catalyst", prerequisites = { "godforge-plasma-module", "stargate", "dtpf-resplendent-catalyst" },
	packs = 15, count = 1, recipes = F.join(F.join({}, stellar_recipes), godforge_recipes.tier1),
}

--- GT's graviton shard upgrades (31 of them, 112 shards) as one infinite technology: each level gives the
--- godforge's star matter, universium and magmatter recipes GODFORGE_UPGRADE more productivity (up to the
--- engine's +300 %). Its count doubles per level like `victory`'s (count formula in 138).
local GODFORGE_UPGRADE = 0.05
do
	local effects = {}
	for _, r in pairs(F.join(F.join({ STAR }, godforge_recipes.molten), godforge_recipes.exotic)) do
		if r ~= "spacetime-time-space-separation" then
			effects[#effects + 1] = { type = "change-recipe-productivity", recipe = r, change = GODFORGE_UPGRADE }
		end
	end
	data:extend({ {
		type = "technology",
		name = "godforge-upgrades",
		icon = "__gregtorio-continued__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = { "godforge-exotic-module" },
		unit = { count_formula = "1 * 2^(L-1)", ingredients = F.sci(15), time = 60 },
		max_level = "infinite",
		upgrade = true,
	} })
end
