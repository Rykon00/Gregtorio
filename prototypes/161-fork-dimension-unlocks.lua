--------------------------------------------------------------------------------
--- FORK DIMENSION UNLOCKS (issue #287): the unlock rules of the dimension mines of 160-fork-dimension-mines.lua
--- (issues #283 to #286). 160 loads before 142, so that the unlock table of 142 and the ore chains of 155 see the mines;
--- these rules need what 142 to 159 unlock (the ore chains, the parts of 158, the lanthanide lines of 159) and load
--- after 159 (data.lua).
--------------------------------------------------------------------------------

local NETHER, END = "reach-the-nether", "reach-the-end"
local MOON, MARS = "reach-the-moon", "reach-mars"
local ASTEROIDS, JOVIAN, VENUS = "reach-the-asteroid-belt", "reach-the-jovian-moons", "reach-venus"
local VM_TECHS = { "void-miner-i", "void-miner-ii", "void-miner-iii" }
local ROSS = "reach-ross128"

local function packs(tech) return #(data.raw.technology[tech].unit.ingredients or {}) end
local function ancestors(tech, seen)
	seen = seen or {}
	for _, p in pairs(data.raw.technology[tech].prerequisites or {}) do
		if not seen[p] then seen[p] = true; ancestors(p, seen) end
	end
	return seen
end
--- a prerequisite (none when the technology has it already, directly or further back)
local function require_tech(tech, prerequisite)
	local t = data.raw.technology[tech]
	if ancestors(tech)[prerequisite] then return end
	t.prerequisites = t.prerequisites or {}
	t.prerequisites[#t.prerequisites + 1] = prerequisite
end
--- move recipes from whatever technology unlocks them to `tech`
local function move_unlocks(names, tech)
	local set = {}
	for _, n in pairs(names) do set[n] = true end
	for _, t in pairs(data.raw.technology) do
		if t.effects then
			local keep = {}
			for _, e in pairs(t.effects) do
				if not (e.type == "unlock-recipe" and set[e.recipe]) then keep[#keep + 1] = e end
			end
			t.effects = keep
		end
	end
	local t = data.raw.technology[tech]
	for _, n in pairs(names) do
		data.raw.recipe[n].enabled = false
		t.effects[#t.effects + 1] = { type = "unlock-recipe", recipe = n }
	end
end

--- The ore chains of the dimensions' ores (155: crushed, purified, centrifuged, impure and pure dust, their hammer,
--- sifter and separator steps; the lines that take them): 155 unlocks a step after the technology of its raw ore, so most
--- come after the dimension. A step unlocked at a lower science tier than the dimension (by an unlock table that put it
--- with an older source of the ore), or by one of the dimension's prerequisites (a prerequisite there would close a
--- loop), moves to it; any other technology that takes the ore gets the dimension as a prerequisite (#252's tree rule).
--- The gem grades of monazite (155) count as its forms.
local function ore_dimension(reach, ores, items)
	local forms = {}
	for _, i in pairs(items or {}) do forms[i] = true end   -- (items the mine gives directly, without an ore chain)
	for _, x in pairs(ores) do
		for _, f in pairs({ "raw-%s", "crushed-%s", "purified-%s", "centrifuged-%s", "impure-%s-dust", "pure-%s-dust",
			"chipped-%s", "flawed-%s", "%s-gem", "flawless-%s", "exquisite-%s" }) do
			forms[f:format(x)] = true
		end
	end
	local takes = {}
	for name, r in pairs(data.raw.recipe) do
		if not name:find("recycling", 1, true) then
			for _, i in pairs(r.ingredients or {}) do
				if forms[i.name] then takes[name] = true end
			end
		end
	end
	local move, needs = {}, {}
	local before = ancestors(reach)
	for tname, t in pairs(data.raw.technology) do
		if tname ~= reach then
			for _, e in pairs(t.effects or {}) do
				if e.type == "unlock-recipe" and takes[e.recipe] then
					if packs(tname) < packs(reach) or before[tname] then move[#move + 1] = e.recipe else needs[tname] = true end
				end
			end
		end
	end
	move_unlocks(move, reach)
	for tname in pairs(needs) do require_tech(tname, reach) end
end



--------------------------------------------------------------------------------
--- THE NETHER AND THE END (issue #283)
--------------------------------------------------------------------------------

--- blaze rods (the Nether) before Eyes of Ender, which takes them
require_tech("eyes-of-ender", NETHER)
--- the airs with their first consumers
require_tech("end-steel", NETHER)
require_tech("end-steel", END)
move_unlocks({ "ender-air-intake", "liquid-ender-air", "ender-air-distillation" }, "radon")
require_tech("radon", END)
require_tech("radon", "oil-processing")   -- the tall distillation tower of the ender air
--- the other first consumers of the Nether's materials
require_tech("ender-io", NETHER)
require_tech("tungstate-processing", NETHER)
ore_dimension(NETHER, { "molybdenite" })



--------------------------------------------------------------------------------
--- THE MOON AND MARS (issue #284)
--------------------------------------------------------------------------------

--- 155 places a step after the technologies of its inputs before these rules add the dimensions to the older
--- technologies; the EV engraving of flawless monazite stays with the EV laser engraver (Advanced EV Machines), as
--- before issue #287
move_unlocks({ "engraving-flawless-monazite-to-exquisite" }, "advanced-ev-machines")
ore_dimension(MOON, { "ilmenite", "chromite", "bauxite", "aluminium", "bastnasite", "monazite", "neodymium" })
ore_dimension(MARS, { "scheelite", "tungstate", "pitchblende", "uraninite", "desh" }, { "desh-dust" })   -- issue #365: desh
--- bauxite dust's electrolysis was aluminium's MV route; aluminium has its others (fuller's earth, lazurite, cryolite)
move_unlocks({ "bauxite-dust-electrolysis" }, MOON)
--- the implosion of monazite dust into gems belongs to the gem grades of the monazite from the Moon
move_unlocks({ "implosion-monazite-dust-to-gem" }, MOON)
--- the Bayer steps of bauxite slurry (Bauxite Slurry Process, an HV technology that Reach the End needs); the process's
--- lazurite and sodalite route stays there
move_unlocks({ "heated-bauxite-slurry", "heated-bauxite-slurry-reaction", "centrifuge-bauxite-slag" }, MOON)
--- the moon dust's centrifuge gives molybdenum dust at HV, which brings the molybdenum ingot and its casts to the Moon
--- (158, 143); its melt needs the EV fluid extractor and stays with the molybdenite line
move_unlocks({ "melt-molybdenum-ingot" }, "tungstate-processing")
--- End Steel melts neodymium ingots (in a blast furnace with neon, krypton, xenon): the dust comes from the Moon's ore
require_tech("end-steel", "neodymium")



--------------------------------------------------------------------------------
--- T3 AND T4 (issue #285)
--------------------------------------------------------------------------------

--- (sheldonite dust and the tiny piles of metallic platinum powder that crushed platinum smelts into come only from
--- these ores)
ore_dimension(ASTEROIDS, { "sheldonite", "palladium", "platinum", "naquadah" },
	{ "sheldonite-dust", "tiny-pile-of-metallic-platinum-powder" })
--- (the ledox rotor of 158 with its plate, at Super Coolant, as before issue #287)
move_unlocks({ "ledox-rotor" }, "super-coolant")
ore_dimension(JOVIAN, { "ledox" }, { "callisto-ice-dust" })
ore_dimension(VENUS, {}, { "quantium-dust" })



--------------------------------------------------------------------------------
--- THE VOID MINERS (issue #286): the late ores' chains (155) and their first consumers (Bedrockium at UV, Quantium at
--- UEV)
--------------------------------------------------------------------------------

--- black plutonium (the blast furnace and vacuum freezer of 147 at ZPM, the parts of 158) came with Bedrockium (UV),
--- where the microminer missions gave the ore; its first consumer is the Void Miner II (ZPM, frames, plates, screws)
do
	local moved = {}
	for _, e in pairs(data.raw.technology["bedrockium"].effects or {}) do
		if e.type == "unlock-recipe" and e.recipe:find("black-plutonium", 1, true) and not e.recipe:find("^melt%-") then
			moved[#moved + 1] = e.recipe   -- (the melt needs the UV fluid extractor)
		end
	end
	move_unlocks(moved, VM_TECHS[2])
end
--- 155 puts the forge hammer steps of the raw and crushed ores with their source, the Void Miners; they stay with the rest
--- of their chain (#286: Bedrockium and Quantium; black plutonium's with the Void Miner II, above)
for ore, tech in pairs({ ["black-plutonium"] = VM_TECHS[2], neutronium = "bedrockium", adamantium = "bedrockium",
	borax = "bedrockium", bedrockium = "bedrockium", ["cosmic-neutronium"] = "cosmic-neutronium", ["infinity-catalyst"] = "quantium" }) do
	move_unlocks({ "hammering-raw-" .. ore, "hammering-crushed-" .. ore }, tech)
end
ore_dimension(VM_TECHS[1], { "black-plutonium", "neutronium", "adamantium" })
ore_dimension(VM_TECHS[2], { "bedrockium" })
ore_dimension(VM_TECHS[3], { "cosmic-neutronium", "infinity-catalyst" })



--------------------------------------------------------------------------------
--- ROSS128 (issue #293): bornite's ore chain and the platinum line's steps from it (the sludge of Platinum Ore
--- Processing, the concentrate of Platinum Line Initialization) come with the mine or need it; tetrahedrite has its
--- Overworld mine
--------------------------------------------------------------------------------

ore_dimension(ROSS, { "bornite" })

--- issue #373: 155's recipes of the chemical dehydrators, which 159 makes (the Everglades ores' decompositions)
FORK_ORE_CHAIN.unlock_after_159()



--------------------------------------------------------------------------------
--- THE DEEP DARK (issue #636, the maintainer's decision of 2026-10-28): GTNH's T10 dimension (gtneioreplugin/util/
--- DimensionHelper.java:177, "Underdark"), where the Void Miner mines every ore of GT, bartworks and GT++ at weight 1
--- unless configured (bwcrossmod/galacticgreg/VoidMinerLoader.java:29-90). Here a Void Miner III recipe with every raw
--- ore of the mod (a raw-<ore> with its crushed-<ore>) in equal shares, at the Void Miners' rate (160: 20 ores per 10 s
--- at tier I, neon, krypton and xenon x4, x8, x16), with a technology of its own at UHV. Built here, after every file
--- that makes raw ores (160, 162).
--------------------------------------------------------------------------------

do
	local ores = {}
	for name in pairs(data.raw.item) do
		local x = name:match("^raw%-(.+)$")
		if x and data.raw.item["crushed-" .. x] then ores[#ores + 1] = name end
	end
	table.sort(ores)
	local function expected(name, e)   -- (as 160's)
		if e < 1 then return { type = "item", name = name, amount = 1, independent_probability = e } end
		local n = math.floor(e)
		local r = { type = "item", name = name, amount = n }
		if e - n > 0.001 then r.extra_count_fraction = e - n end
		return r
	end
	local recipes = {}
	for _, g in pairs({ { nil, 1 }, { "neon", 4 }, { "krypton", 8 }, { "xenon", 16 } }) do
		local name = "void-mining-deep-dark" .. (g[1] and ("-" .. g[1]) or "")
		local results = {}
		for _, o in pairs(ores) do results[#results + 1] = expected(o, 20 * g[2] / #ores) end
		create_recipe{
			name = name,
			category = "void-miner-3-recipes",
			energy_required = 10,
			subgroup = "subgroup-void-miner-3-recipes",
			ingredients = g[1] and { { type = "fluid", name = g[1], amount = 2 } } or {},
			results = results,
			main_product = results[1].name,
			icon = "__gregtorio-continued__/graphics/icons/fork/void-miner-iii.png",
		}
		recipes[#recipes + 1] = name
	end
	FORK5B.tech{ name = "the-deep-dark", prerequisites = { VM_TECHS[3], "uhv-machines" }, packs = 10, count = 50, time = 60,
		recipes = recipes }
	--- issue #631 part 3: the lanthanides only the Deep Dark mines (no GTNH vein holds them): their ore chains (155, which
	--- found no source for them) come with it; Rare Earth Ion Extraction (164 section 56) comes after it
	local unlocked = {}
	for _, t in pairs(data.raw.technology) do
		for _, e in pairs(t.effects or {}) do if e.type == "unlock-recipe" then unlocked[e.recipe] = true end end
	end
	local chain = {}
	for _, x in pairs({ "praseodymium", "europium", "gadolinium", "terbium", "dysprosium", "holmium", "erbium", "ytterbium",
		"lutetium" }) do
		local forms = {}
		for _, f in pairs({ "raw-%s", "crushed-%s", "purified-%s", "centrifuged-%s", "impure-%s-dust", "pure-%s-dust" }) do
			forms[f:format(x)] = true
		end
		for name, r in pairs(data.raw.recipe) do
			if not unlocked[name] and r.enabled == false and not name:find("recycling", 1, true) then
				for _, i in pairs(r.ingredients or {}) do
					if forms[i.name] then chain[#chain + 1] = name; break end
				end
			end
		end
	end
	for _, n in pairs(chain) do fork_add_unlock("the-deep-dark", n) end
	table.insert(data.raw.technology["rare-earth-ion-extraction"].prerequisites, "the-deep-dark")
end
