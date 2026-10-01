--------------------------------------------------------------------------------
--- FORK ENDGAME MULTIBLOCKS (roadmap phase 6a, issue #37)
--- Two GT endgame multiblocks on top of the UMV tier (133-fork-umv.lua):
---   * the dimensionally transcendent plasma forge (DTPF): GT's MTEPlasmaForge. Here a UMV multiblock
---     with its own recipe category that makes the endgame metals more efficiently than the fusion
---     reactors (the MK3 to MK5 recipes stay as the entry route), and the catalysts it burns
---   * the quantum force transformer (QFT): GT++'s MTEQuantumForceTransformer. A UMV multiblock that
---     runs GT's QFT recipes whose materials exist in the mod: the platinum line and the naquadah line
--- The drafts are in 29-uev-age-item.lua and 31-uiv-age-item.lua (not loaded, not valid Lua); the
--- numbers follow GT5-Unofficial (PlasmaForgeRecipes, DTPFRecipes of the core mod, RecipeLoaderChemicalSkips,
--- NaquadahRecipeLoader), see "Phase 6a: QFT and DTPF" in docs/ROADMAP.md.
---
--- Simplified, on purpose:
---   * DTPF: no coil heat, no runtime discount and no convergence. GT's five catalysts (made from up to
---     20 plasmas in the transcendent plasma mixer) are two fluids made in the forge itself: crude (GT's
---     four plasmas) and resplendent (crude + boron, sulfur, nitrogen, zinc and titanium plasma; GT's
---     radon, nickel and silver plasma do not exist here). No residue.
---   * DTPF metals: GT makes them from carrier melts (copper -> cosmic neutronium) and tesseracts, which
---     would skip the whole fusion chain. Here each DTPF recipe is the fusion recipe of the metal with
---     two thirds of the inputs per output and in a third of the reactor time (see DTPF_INPUT and
---     DTPF_TIME), plus catalyst; the resplendent tier makes twice the batch in the same time for less
---     catalyst per ingot. tools/balance_model.py compares the two routes.
---   * QFT: no catalyst items, no tiered casings and no focus plasmas to choose: one recipe per main
---     output (GT's neptunium focus: the focused output at (N+1)/2N, the others at 1/2N), nitrogen plasma
---     as the focus plasma (GT: neptunium plasma, from radon and nitrogen plasma).
--- Phase 6b (MAX tier, godforge) hooks are marked "6b hook" and listed in the roadmap.
--------------------------------------------------------------------------------

local F = FORK5B

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

--- Multiblock with its own size and fluid ports, cloned from the fusion reactor MK5 (electric, one
--- crafting speed per tier like the reactors); sprites from tools/gen_sprites.py (MULTIBLOCKS)
local function multiblock(def)
	F.clone_multiblock{
		name = def.name, source = "fusion-reactor-mk5", size = def.size, categories = def.categories,
		speed = def.speed, energy = def.energy, icon = data.raw.item[def.name].icon,
		subgroup = "subgroup-umv-age-multiblocks",
	}
	local m = data.raw["assembling-machine"][def.name]
	m.fluid_boxes = def.ports
	for _, fb in pairs(m.fluid_boxes) do
		fb.pipe_covers = pipecoverspictures()
		fb.pipe_picture = assembler2pipepictures()
	end
	m.fluid_boxes_off_when_no_fluid_recipe = true
end



--------------------------------------------------------------------------------
--- 1) DIMENSIONALLY TRANSCENDENT PLASMA FORGE
--- GT: 33x24x33, 2121 dimensionally transcendent casings, 2112 coils, 120 dimensional bridges, one or
--- two energy hatches; the controller from the research station assembly line (UIV) with UEV parts.
--- Here 11x11, one UMV amp (1310.72 MW, like each fusion reactor takes one amp of its tier), the parts
--- one tier up (UIV), the UMV coil, two UMV energy hatches (GT: up to two).
--- Part recipes as in GT where the mod has the part: the microwave energy transmitter is a UV emitter,
--- laurenium screws are spacetime screws, mutated living solder is indalloy 140, enriched naquadah is
--- naquadah, oganesson and californium are left out; the controller takes no eternal singularity,
--- quantum anomaly, ZPM battery and teleporter (GT items the mod does not have).
--------------------------------------------------------------------------------

local DTPF = "dimensionally-transcendent-plasma-forge"
local DTPF_CAT = "dimensionally-transcendent-plasma-forge-recipes"
F.category(DTPF_CAT)

create_item{
	name = "dimensionally-transcendent-casing",
	category = "umv-assembling-machine-recipes",
	energy_required = 20 * UMV_SPEED,
	ingredients = {
		item("osmiridium-plate", 6),
		item("spacetime-screw", 12),
		item("1080k-super-coolant-cell", 1),
		item("uv-emitter", 1),
		item("triamerotronium-superconductive-wire", 1),
		fluid("molten-indalloy-140", 28.8),
		fluid("molten-naquadah", 14.4),
	},
}
create_item{
	name = "dimensional-bridge",
	category = "zpm-assembly-line-recipes",
	energy_required = 4 * 30 * ZPM_SPEED,
	ingredients = {
		item("dimensionally-transcendent-casing", 1),
		item("uv-emitter", 1),
		item("uv-circuit", 2),
		item("ppic-wafer", 2),
		item("triamerotronium-superconductive-wire", 6),
		item("uhv-field-generator", 1),
		fluid("molten-indalloy-140", 576),
		fluid("molten-naquadah", 129.6),
	},
}
create_item{
	name = DTPF .. "-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = 5 * 30 * ZPM_SPEED,
	ingredients = {
		item("dimensional-bridge", 4),
		item("uiv-energy-hatch", 4),
		item("chromnorox-superconductive-wire", 24),
		item("1080k-super-coolant-cell", 4),
		item("umv-circuit", 20),
		item("uiv-field-generator", 4),
		item("superdense-neutronium-plate", 4),
		item("uiv-pump", 4),
		fluid("molten-indalloy-140", 576),
		fluid("molten-naquadah", 576),
	},
}
create_item{
	name = DTPF,
	category = "umv-assembling-machine-recipes",
	energy_required = 300 * UMV_SPEED,
	subgroup = "subgroup-umv-age-multiblocks",
	stack_size = 10,
	place_result = DTPF,
	ingredients = {
		item(DTPF .. "-controller", 1),
		item("dimensionally-transcendent-casing", 48),
		item("dimensional-bridge", 16),
		item("spacetime-coil-block", 32),
		item("umv-energy-hatch", 2),
		item("umv-machine-hull", 8),
	},
}

--- 11x11: five fluid inputs north and one west (the resplendent catalyst takes six fluids), two
--- outputs south
multiblock{
	name = DTPF, size = { 11, 11 }, categories = { DTPF_CAT }, speed = UMV_SPEED, energy = "1310.72MW",
	ports = {
		fluid_port(-4, -5, "input", defines.direction.north),
		fluid_port(-2, -5, "input", defines.direction.north),
		fluid_port( 0, -5, "input", defines.direction.north),
		fluid_port( 2, -5, "input", defines.direction.north),
		fluid_port( 4, -5, "input", defines.direction.north),
		fluid_port(-5,  0, "input", defines.direction.west),
		fluid_port(-2,  5, "output", defines.direction.south),
		fluid_port( 2,  5, "output", defines.direction.south),
	},
}

--- Catalysts (GT: transcendent plasma mixer, 1000 of each plasma -> 1000 catalyst in 5 s). Crude is GT's
--- recipe; resplendent is GT's without radon, nickel and silver plasma. Made in the forge itself.
F.fluid("excited-dimensionally-transcendent-crude-catalyst", "spackled-orange-fluid", { 0.85, 0.45, 0.20 })
F.fluid("excited-dimensionally-transcendent-resplendent-catalyst", "spackled-light-blue-fluid", { 0.45, 0.80, 0.95 })

local CRUDE = "excited-dimensionally-transcendent-crude-catalyst"
local RESPLENDENT = "excited-dimensionally-transcendent-resplendent-catalyst"
create_recipe{
	name = CRUDE,
	category = DTPF_CAT,
	energy_required = 5 * UMV_SPEED,
	ingredients = {
		fluid("helium-plasma", 100),
		fluid("iron-plasma", 100),
		fluid("calcium-plasma", 100),
		fluid("niobium-plasma", 100),
	},
	results = { fluid(CRUDE, 100) },
}
create_recipe{
	name = RESPLENDENT,
	category = DTPF_CAT,
	energy_required = 10 * UMV_SPEED,
	ingredients = {
		fluid(CRUDE, 100),
		fluid("boron-plasma", 100),
		fluid("sulfur-plasma", 100),
		fluid("nitrogen-plasma", 100),
		fluid("zinc-plasma", 100),
		fluid("titanium-plasma", 100),
	},
	results = { fluid(RESPLENDENT, 100) },
}

--- The metals. Each recipe is the fusion recipe of the metal (molten-X: two melts or plasmas of 14.4 ->
--- 14.4 in a fusion reactor), with DTPF_INPUT of its inputs per output and DTPF_TIME of its reactor time
--- (the DTPF and the reactors draw the same power per crafting speed: 0.64 MW). Crude: 144 per craft;
--- resplendent: 288 per craft in the same time. The catalyst per craft follows the reactor time of the
--- metal (GT: the catalyst stands for the energy of the normal route): CRUDE_PER_S crude catalyst per
--- second of a MK5 (speed 1024) that the fusion recipe would take for the batch, RESPLENDENT_PER_S of the
--- resplendent one (per the doubled batch).
local DTPF_INPUT = 2 / 3
local DTPF_TIME = 1 / 3
local CRUDE_PER_S = 1.5
local RESPLENDENT_PER_S = 0.5
local DTPF_METALS = {
	"molten-neutronium", "molten-cosmic-neutronium", "molten-infinity", "molten-transcendent-metal",
	"molten-spacetime",
	"molten-universium", -- 6b hook: GT makes universium in the godforge / eye of harmony, not in the DTPF
}
local dtpf_recipes = { crude = {}, resplendent = {} }
for _, metal in pairs(DTPF_METALS) do
	local src = data.raw.recipe[metal]
	local out = 0
	for _, r in pairs(src.results) do if r.name == metal then out = r.amount end end
	for tier, def in pairs({ crude = { 144, CRUDE, CRUDE_PER_S }, resplendent = { 288, RESPLENDENT, RESPLENDENT_PER_S } }) do
		local batch, catalyst, per_s = def[1], def[2], def[3]
		local mk5_seconds = src.energy_required * (batch / out) / 1024
		local ingredients = {}
		for _, i in pairs(src.ingredients) do
			ingredients[#ingredients + 1] = { type = i.type, name = i.name, amount = i.amount * (batch / out) * DTPF_INPUT }
		end
		ingredients[#ingredients + 1] = fluid(catalyst, mk5_seconds * per_s)
		local name = metal .. "-dtpf-" .. tier
		create_recipe{
			name = name,
			category = DTPF_CAT,
			energy_required = src.energy_required * (144 / out) * DTPF_TIME,
			subgroup = "subgroup-" .. DTPF_CAT,
			ingredients = ingredients,
			results = { fluid(metal, batch) },
			main_product = metal,
		}
		dtpf_recipes[tier][#dtpf_recipes[tier] + 1] = name
	end
end



--------------------------------------------------------------------------------
--- 2) QUANTUM FORCE TRANSFORMER
--- GT: 15x21x15, a UIV controller (research station assembly line, UEV parts), 177 quantum force
--- conductors, force field glass, tiered pulse manipulators and shielding cores (they set the recipe and
--- focus tier), a bulk catalyst housing (the catalyst count sets the parallels). Here 9x9 at UMV (one UMV
--- amp), with UIV parts like the DTPF: controller, QFT coil casings (GT's infinity coil, super coolant
--- cells, an electromagnetic coil and quantum: a superconducting coil block and transcendent metal here),
--- two UMV energy hatches. No tiered casings and no catalyst housing: every recipe has its focus built in.
--------------------------------------------------------------------------------

local QFT = "quantum-force-transformer"
local QFT_CAT = "quantum-force-transformer-recipes"
F.category(QFT_CAT)

create_item{
	name = QFT .. "-coil-casing",
	category = "umv-assembling-machine-recipes",
	energy_required = 90 * UMV_SPEED,
	ingredients = {
		item("infinity-coil-block", 1),
		item("1080k-super-coolant-cell", 4),
		item("transcendent-metal-plate", 2),
		item("superconducting-coil-block", 1),
		fluid("molten-transcendent-metal", 144),
	},
}
create_item{
	name = QFT .. "-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = 3 * 30 * ZPM_SPEED,
	ingredients = {
		item("uiv-circuit", 8),
		item("uiv-pump", 4),
		item("uiv-field-generator", 4),
		item("uiv-robot-arm", 2),
		fluid("molten-indalloy-140", 576),
		fluid("molten-transcendent-metal", 576),
	},
}
create_item{
	name = QFT,
	category = "umv-assembling-machine-recipes",
	energy_required = 300 * UMV_SPEED,
	subgroup = "subgroup-umv-age-multiblocks",
	stack_size = 10,
	place_result = QFT,
	ingredients = {
		item(QFT .. "-controller", 1),
		item(QFT .. "-coil-casing", 16),
		item("titanium-reinforced-borosilicate-glass-block", 32),
		item("umv-energy-hatch", 2),
		item("umv-machine-hull", 8),
	},
}

--- 9x9: four fluid inputs north, two outputs south
multiblock{
	name = QFT, size = { 9, 9 }, categories = { QFT_CAT }, speed = UMV_SPEED, energy = "1310.72MW",
	ports = {
		fluid_port(-3, -4, "input", defines.direction.north),
		fluid_port(-1, -4, "input", defines.direction.north),
		fluid_port( 1, -4, "input", defines.direction.north),
		fluid_port( 3, -4, "input", defines.direction.north),
		fluid_port(-1,  4, "output", defines.direction.south),
		fluid_port( 1,  4, "output", defines.direction.south),
	},
}

--- GT's recipes (RecipeLoaderChemicalSkips, NaquadahRecipeLoader), only those whose inputs and outputs the
--- mod has. GT's names: platinum, palladium metallic powder, iridium leach residue (= iridium metal
--- residue), iridium-osmium leach residue (= rarest metal residue), crude rhodium metal (= crude rhodium
--- residue), leach residue (= iridium group sludge); naquadah earth (= naquadah oxide mixture) and
--- enriched naquadah earth. GT's inert naquadah dusts (activated to melt in GT's neutron activator) are
--- the mod's step before the metal: naquadahine dust and enriched naquadah sulphate.
--- Each output has `amount` at 100 %; a recipe per main output gives it (N+1)/2N and the others 1/2N.
local FOCUS_PLASMA = "nitrogen-plasma"
local QFT_RECIPES = {
	{ input = { item("metallic-platinum-powder", 32) }, time = 20,
		outputs = { { "platinum-dust", 64 }, { "palladium-dust", 64 }, { "iridium-dust", 64 }, { "osmium-dust", 64 },
			{ "rhodium-dust", 64 }, { "ruthenium-dust", 64 } } },
	{ input = { item("metallic-palladium-powder", 32) }, time = 20,
		outputs = { { "palladium-dust", 64 }, { "platinum-dust", 64 }, { "rhodium-plated-palladium-dust", 64 } } },
	{ input = { item("iridium-metal-residue", 32) }, time = 20,
		outputs = { { "iridium-dust", 64 }, { "platinum-dust", 64 }, { "osmiridium-dust", 64 } } },
	{ input = { item("rarest-metal-mixture", 32) }, time = 20,
		outputs = { { "osmium-dust", 64 }, { "iridium-dust", 64 }, { "osmiridium-dust", 64 } } },
	{ input = { item("crude-rhodium-residue", 32) }, time = 20,
		outputs = { { "rhodium-dust", 64 }, { "palladium-dust", 64 }, { "platinum-dust", 64 },
			{ "rhodium-plated-palladium-dust", 64 } } },
	{ input = { item("iridium-group-sludge", 32) }, time = 20,
		outputs = { { "iridium-dust", 64 }, { "osmium-dust", 64 }, { "rhodium-dust", 64 }, { "ruthenium-dust", 64 } } },
	--- GT: 64 000 hydrogen and fluorine (scaled to the 1000 of a fluid port); 1 inert naquadah, here 16
	--- naquadahine dust so the QFT is not worse than the mod's naquadah line (see the roadmap)
	{ input = { item("naquadah-oxide-mixture", 32), item("sodium", 64), item("carbon", 1),
			fluid("hydrogen", 1000), fluid("fluorine", 1000), fluid("oxygen", 100) }, time = 10,
		outputs = { { "naquadahine-dust", 16 }, { "titanium-dust", 64 }, { "adamantium-dust", 64 }, { "gallium", 64 } } },
	--- GT: 16 000 sulfuric acid, 32 000 waste liquid (scaled); the waste liquid is no focus choice
	{ input = { item("enriched-naquadah-oxide-mixture", 32), item("zinc-dust", 64), item("carbon", 1),
			fluid("sulfuric-acid", 1000), fluid("oxygen", 100) }, time = 10,
		outputs = { { "enriched-naquadah-sulphate", 16 }, { "trinium-dust", 64 } },
		extra = { fluid("waste-liquid", 1000) } },
}
local qft_recipes = {}
for _, def in pairs(QFT_RECIPES) do
	local n = #def.outputs + (def.extra and #def.extra or 0)
	for _, focus in pairs(def.outputs) do
		local results = {}
		for _, o in pairs(def.outputs) do
			local p = o[1] == focus[1] and (n + 1) / (2 * n) or 1 / (2 * n)
			results[#results + 1] = { type = "item", name = o[1], amount = o[2], probability = p }
		end
		for _, e in pairs(def.extra or {}) do
			results[#results + 1] = { type = "fluid", name = e.name, amount = e.amount, probability = 1 / (2 * n) }
		end
		local ingredients = table.deepcopy(def.input)
		ingredients[#ingredients + 1] = fluid(FOCUS_PLASMA, 100)
		local name = def.input[1].name .. "-qft-" .. focus[1]
		create_recipe{
			name = name,
			category = QFT_CAT,
			energy_required = def.time * UMV_SPEED,
			subgroup = "subgroup-" .. QFT_CAT,
			ingredients = ingredients,
			results = results,
			main_product = focus[1],
		}
		qft_recipes[#qft_recipes + 1] = name
	end
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES (the unit counts are set in 138-fork-research-balance.lua, which loads after this file:
--- about 8 hours of pack production in the reference factory of the tier, like the other UMV and UXV techs)
---   * the DTPF and the crude tier: UMV science, after the UMV multiblocks (the UMV energy hatch) and
---     the MK5 plasmas
---   * the resplendent tier: UXV science, after the UXV multiblocks
---   * the QFT: UMV science, after the UMV multiblocks
--------------------------------------------------------------------------------

F.tech{
	name = DTPF, prerequisites = { "umv-multiblocks", "fusion-plasmas-mk5" }, packs = 13, count = 1,
	recipes = F.join({ "dimensionally-transcendent-casing", "dimensional-bridge", DTPF .. "-controller", DTPF, CRUDE },
		dtpf_recipes.crude),
}
F.tech{
	name = "dtpf-resplendent-catalyst", prerequisites = { DTPF, "uxv-multiblocks" }, packs = 14, count = 1,
	recipes = F.join({ RESPLENDENT }, dtpf_recipes.resplendent),
}
F.tech{
	name = QFT, prerequisites = { "umv-multiblocks" }, packs = 13, count = 1,
	recipes = F.join({ QFT .. "-coil-casing", QFT .. "-controller", QFT }, qft_recipes),
}
