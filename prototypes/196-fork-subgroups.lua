--------------------------------------------------------------------------------
--- FORK SUBGROUPS: the Fluids tab
--- Factorio puts a fluid into the Fluids tab of the signal and fluid choosers (and of Factoriopedia) only when its
--- subgroup belongs to the item group "fluids"; a fluid without a subgroup lands in "Unsorted". The fluids of
--- upstream (06-fluids-module.lua) and of the fork files (fork_fluid / F.fluid) have none, and the vanilla fluids
--- that upstream redefines (crude oil, lubricant, sulfuric acid, ammonia, fluorine, lava) lost theirs.
---
--- Every subgroup is a row of the tab. The assignment of every Gregtorio fluid is here, in one place:
---   1. FLUID_SUBGROUP: explicit names (they win over the patterns), optionally with a rank for tiered lines
---   2. FLUID_PATTERNS: Lua patterns on the name, the first match wins
---   3. anything else: the fallback row "gregtorio-fluids-unsorted" (devcheck lists it as a warning)
--- Inside a row the fluids are ordered by name (equal order strings: Factorio sorts by name), or by rank where a
--- line has tiers.
--- A fluid is Gregtorio's when its icon is a Gregtorio file or it is named in FLUID_SUBGROUP; fluids of other
--- mods keep what their mod gave them. Loaded after every file that creates fluids.
--- Issue #119: the base game's and Space Age's fluids that Gregtorio uses get Gregtorio's icons (molten iron and copper
--- in the style of the other melts, steam), and the twelve that nothing of Gregtorio makes or uses are hidden.
--------------------------------------------------------------------------------

local P = "__gregtorio-continued__/"

--- rows of the Fluids tab after the vanilla row "fluid" (order "a"), top to bottom
local ROWS = {
	"basic",            -- water, air and waste
	"gases",            -- elemental and inorganic gases
	"acids",            -- acids and inorganic chemicals
	"ore-solutions",    -- ore processing solutions and slurries
	"fuels",            -- oil, fuels, refining and light hydrocarbons
	"organic",          -- organic chemistry and biology
	"polymers",         -- polymers, rubbers and glues
	"nuclear",          -- uranium and plutonium fuels, the naquadah line
	"coolants",         -- coolants and cryogenic fluids
	"purified-water",   -- water grades 1-8
	"plasmas",          -- *-plasma
	"particles",        -- the beamline's particles (issue #355)
	"molten-elements",  -- molten elements and glass, mercury
	"molten-alloys",    -- molten steels and conductor alloys (and any other molten-*)
	"molten-superalloys",
	"molten-exotic",    -- GregTech and endgame materials
	"endgame",          -- plasma forge catalysts, godforge fluids
	"unsorted",         -- fallback: fluids nothing below matches
}
local subgroups = {}
for i, row in pairs(ROWS) do
	subgroups[#subgroups + 1] = {
		type = "item-subgroup", name = "gregtorio-fluids-" .. row, group = "fluids", order = string.format("g[%02d]", i),
	}
end
data:extend(subgroups)

--- explicit table: name = row, or { row, rank } for a tiered line, or { "fluid", order } for a vanilla fluid that
--- upstream redefines (it goes back into the vanilla row with its vanilla order)
local FLUID_SUBGROUP = {}
local function put(row, names)
	for _, n in pairs(names) do FLUID_SUBGROUP[n] = row end
end

FLUID_SUBGROUP["crude-oil"] = { "fluid", "a[fluid]-b[oil]-a[crude-oil]" }
FLUID_SUBGROUP["lubricant"] = { "fluid", "a[fluid]-b[oil]-e[lubricant]" }
FLUID_SUBGROUP["sulfuric-acid"] = { "fluid", "a[fluid]-b[oil]-f[sulfuric-acid]" }
FLUID_SUBGROUP["lava"] = { "fluid", "b[new-fluid]-b[vulcanus]-a[lava]" }
FLUID_SUBGROUP["ammonia"] = { "fluid", "b[new-fluid]-e[aquilo]-b[ammonia]" }
FLUID_SUBGROUP["fluorine"] = { "fluid", "b[new-fluid]-e[aquilo]-c[fluorine]" }
--- issue #97: superheated steam (145-fork-power-multiblocks.lua) next to steam
FLUID_SUBGROUP["superheated-steam"] = { "fluid", "a[fluid]-a[water]-b[steam]-s[superheated]" }

put("basic", { "air", "nether-air", "ender-air", "distilled-water", "salt-water", "waste-liquid",
	"fluorine-rich-waste-liquid", "liquid-concrete" })
put("gases", { "hydrogen", "deuterium", "tritium", "helium", "helium-3", "nitrogen", "oxygen", "argon", "neon", "krypton",
	"xenon", "radon", "chlorine", "ozone", "carbon-dioxide", "carbon-monoxide", "nitrogen-dioxide",
	"dinitrogen-tetroxide", "sulfur-dioxide", "sulfur-trioxide", "hydrogen-sulfide", "hydrogen-cyanide" })
put("acids", { "aqua-regia", "nitration-mixture", "iron-iii-chloride", "antimony-pentachloride",
	"antimony-pentachloride-solution", "antimony-pentafluoride", "antimony-trichloride-solution", "titanium-tetrachloride",
	"silicon-tetrachloride", "sodium-tungstate", "polyaluminium-chloride" })
put("ore-solutions", { "bauxite-slurry", "heated-bauxite-slurry", "indium-concentrate", "lead-zinc-solution",
	"rhodium-sulfate-solution", "sulfuric-copper-solution",
	"sulfuric-iron-solution", "sulfuric-nickel-solution", "acidic-osmium-solution",
	"sluice-juice", "ruby-juice" })
put("fuels", { "naphtha", "refinery-gas", "light-fuel", "heavy-fuel", "diesel", "cetane-boosted-diesel", "gasoline",
	"high-octane-gasoline", "raw-gasoline", "rocket-fuel", "creosote", "wood-gas", "wood-tar", "wood-vinegar", "charcoal-byproducts",
	"methane", "ethane", "propane", "ethylene", "propene", "butene", "butadiene" })
put("organic", { "acetic-acid", "formic-acid", "phthalic-acid", "acetone", "benzene", "toluene", "dimethylbenzene", "phenol",
	"chlorobenzene", "dichlorobenzene", "nitrochlorobenzene", "dichlorobenzidine", "diaminobenzidine",
	"chloroform", "chloroacetic-acid", "ethyl-cyanoacetate", "formaldehyde", "dimethylhydrazine", "diphenyl-isophthalate", "epichlorohydrin", "ethanol", "methanol", "ether",
	"methyl-acetate", "vinyl-acetate", "vinyl-chloride", "tetrafluoroethylene", "tetranitromethane", "sodium-formate",
	"p507", "2-ethyl-1-hexanol", "biomass", "bacterial-sludge", "enriched-bacterial-sludge", "growth-medium", "mutagen" })
put("polymers", { "glue", "advanced-glue", "super-glue", "epoxy", "liquid-rubber", "silicone-rubber", "ptfe" })
put("coolants", { "cryogenic-helium", "lapis-coolant", "super-coolant", "sodium-potassium", "liquid-air",
	"liquid-nether-air", "liquid-ender-air", "coolant", "hot-coolant", "gelid-cryotheum" })
put("molten-elements", { "mercury", "molten-glass", "molten-borosilicate-glass", "molten-aluminium", "molten-americium",
	"molten-beryllium", "molten-chrome", "molten-cobalt", "molten-europium", "molten-flerovium", "molten-gallium",
	"molten-lithium", "molten-lutetium", "molten-magnesium", "molten-neodymium", "molten-silicon", "molten-silver",
	"molten-tantalum", "molten-tin", "molten-titanium", "molten-tungsten",
	-- issue #91: the melts of the elements that had none
	"molten-gold", "molten-lead", "molten-nickel", "molten-zinc", "molten-iridium", "molten-osmium", "molten-palladium",
	"molten-platinum", "molten-samarium" })
put("molten-alloys", { "soldering-alloy", "mutated-living-solder" })
--- issue #630: GT++'s milling and flotation (164 section 47)
put("organic", { "pine-oil", "carbon-disulfide", "urea", "liquid-resin" })
put("gases", { "coal-gas", "nefarious-gas" })
put("ore-solutions", { "red-mud", "nether-semi-fluid", "nefarious-oil", "poor-nether-waste", "netherrack-flotation-froth" })
for _, o in pairs(FORK_MILLING and FORK_MILLING.ores or {}) do put("ore-solutions", { o[1] .. "-flotation-froth" }) end
--- issue #617: the netherite chain (164 section 48)
put("ore-solutions", { "rich-nether-waste" })
put("molten-alloys", { "molten-thaumium", "molten-hellish-metal", "molten-manyullyn" })
put("molten-elements", { "molten-boron" })
   -- (issue #627: GT++'s UEV+ solder)
put("molten-superalloys", { "molten-hastelloy-c276", "molten-hastelloy-w", "molten-hastelloy-x", "molten-incoloy-020",
	"molten-incoloy-903", "molten-incoloy-ds", "molten-incoloy-ma956", "molten-inconel-625", "molten-inconel-690",
	"molten-inconel-792", "molten-maraging-steel-250", "molten-maraging-steel-300", "molten-stellite", "molten-talonite",
	"molten-ultimet", "molten-zeron-100", "molten-nitinol-60", "molten-tantalloy-60", "molten-staballoy",
	"molten-kanthal", "molten-nichrome" })
put("molten-exotic", { "molten-naquadah", "molten-naquadah-alloy", "molten-naquadria", "molten-trinium",
	"molten-tritanium", "molten-duranium", "molten-neutronium", "molten-cosmic-neutronium", "molten-draconium",
	"molten-infinity", "molten-transcendent-metal", "molten-spacetime", "molten-universium", "molten-magmatter",
	"molten-rhugnor", "molten-quantium", "molten-sunnarium", "molten-enderium",
	"molten-glowstone", "molten-vibrant-alloy", "molten-grisium", "molten-indovanadium", "molten-ruridit",
	"liquid-blaze", "fiery-blood",   -- (issue #355: GT's fiery blood, the fiery steel bath)
	-- issue #91: the new melts of the endgame materials and the superconductor bases
	"molten-bedrockium", "molten-eternity", "molten-enriched-naquadah", "molten-ledox",
	"molten-itbtc-alloy", "molten-palladium-naqindium", "molten-naquamiridium", "molten-triamerotronium",
	"molten-dracofinium", "molten-chromnorox", "molten-hypocosmium", "molten-yttrium-barium-cuprate" })
--- issue #98 (147-fork-gt-routes.lua): the high octane line, sodium persulfate, the black plutonium melt
put("fuels", { "hydrocracked-light-fuel", "octane", "anti-knock-agent" })
put("gases", { "nitrous-oxide" })
put("acids", { "sodium-persulfate" })
put("molten-exotic", { "molten-black-plutonium" })
--- issue #96 (146-fork-platinum-line.lua): the platinum line of GTNH
put("ore-solutions", { "platinum-concentrate", "palladium-enriched-ammonia" })
put("acids", { "ammonium-chloride" })
put("ore-solutions", { "rhodium-sulfate", "rhodium-salt-solution", "rhodium-filter-cake-solution",
	"ruthenium-tetroxide-solution", "ruthenium-tetroxide", "osmium-solution", "acidic-iridium-solution" })
put("molten-elements", { "molten-potassium" })
--- issue #262: the monazite rare earth line (159)
put("ore-solutions", { "muddy-monazite-rare-earth-solution", "diluted-monazite-rare-earth-mud", "diluted-monazite-sulfate",
	"nitrogenated-monazite-rare-earth-concentrate", "nitric-leached-monazite-mixture", "nitric-monazite-leached-concentrate" })
put("acids", { "ammonium-nitrate-solution" })
--- issue #269: the bastnasite and cerium lines (159)
put("ore-solutions", { "muddy-bastnasite-rare-earth-solution", "steam-cracked-bastnasite-mud",
	"conditioned-bastnasite-mud", "diluted-bastnasite-mud", "filtered-bastnasite-mud",
	"nitrogenated-bastnasite-rarer-earth-oxides", "bastnasite-rarer-earth-oxide-suspension" })
put("acids", { "hexafluorosilicic-acid", "sodium-fluorosilicate", "oxalic-acid" })
--- issue #272: section 6 of 159
put("ore-solutions", { "zirconium-tetrachloride-solution", "hydrated-ammonium-nitrate-slurry" })
put("acids", { "boric-acid" })
put("gases", { "phosgene", "boron-trichloride", "chloromethane" })
put("molten-elements", { "calcium-fluoride" })
--- issue #335: the Drilling Fluid of the Ore Drilling Plants (163), water with stone dust and lubricant
put("basic", { "drilling-fluid" })
--- issue #362: GT++'s rocket fuels and the chains behind them (164)
put("fuels", { "kerosene", "rp-1", "rp-1-rocket-fuel", "dense-hydrazine-fuel-mixture", "cn3h7o3-rocket-fuel", "coal-tar",
	"coal-tar-oil", "sulfuric-coal-tar-oil" })
put("organic", { "naphthalene", "ethylbenzene", "anthracene", "2-ethylanthraquinone", "2-ethylanthrahydroquinone", "hydrazine",
	"monomethylhydrazine" })
put("acids", { "hydrogen-peroxide", "prismarine-contaminated-hydrogen-peroxide" })   -- the second: #356
put("gases", { "prismatic-gas" })   -- #356
put("coolants", { "liquid-oxygen", "liquid-nitrogen" })   -- liquid nitrogen: #356
--- issue #360: the bio fuels (164)
put("fuels", { "seed-oil", "bio-diesel" })
put("organic", { "glycerol", "fermented-biomass" })
--- issue #358: the polymer ladder (164)
put("organic", { "cumene", "bisphenol-a", "styrene" })
put("polymers", { "polystyrene", "styrene-butadiene-rubber", "polycaprolactam" })
--- issue #361: the oil variety (164)
put("fuels", { "medium-oil", "natural-gas", "lpg" })
put("organic", { "mtbe-reaction-mixture" })
--- issue #366: trichlorosilane (164)
put("acids", { "trichlorosilane" })
--- issue #357: goodgenerator's fuels (164)
put("fuels", { "ethanol-gasoline", "cyclopentadiene", "jet-fuel-no-3", "jet-fuel-a", "combustion-promoter" })
put("organic", { "iron-ii-chloride", "diethylamine", "impure-ferrocene-mixture", "ferrocene-solution", "ferrocene-waste" })
put("nuclear", { "thorium-based-liquid-fuel", "excited-thorium-based-liquid-fuel", "depleted-thorium-based-liquid-fuel" })
--- issue #378: the Kevlar line (164)
put("organic", { "acetylene", "acetaldehyde", "ethylene-oxide", "ethylene-glycol", "methylamine", "nickel-tetracarbonyl",
	"nitrobenzene", "aniline" })
put("organic", { "1-4-dimethylbenzene", "naphthenic-acid", "terephthalic-acid", "dimethyl-terephthalate", "1-4-butanediol",
	"gamma-butyrolactone", "n-methyl-2-pyrrolidone", "acetic-anhydride", "4-nitroaniline", "diaminodiphenylmethane-mixture",
	"diphenylmethane-diisocyanate-mixture", "dimethyldichlorosilane", "silicon-oil", "propionic-acid", "trimethyl-borate",
	"butyraldehyde", "isobutyraldehyde", "butanol" })
put("acids", { "sulfur-dichloride", "thionyl-chloride", "phosphorus-trichloride" })
put("polymers", { "polyurethane-resin", "liquid-crystal-kevlar" })
put("fuels", { "xenoxene", "diluted-xenoxene", "raw-radox", "super-heavy-radox", "heavy-radox", "light-radox",
	"super-light-radox", "cracked-radox", "radox-gas" })
--- issue #386: the LFTR's fluorides and fuels (164 section 14)
put("acids", { "lithium-hydroxide", "beryllium-hydroxide", "ammonium-bifluoride", "ammonium-tetrafluoroberyllate",
	"thorium-nitrate" })
put("nuclear", { "lithium-fluoride", "beryllium-fluoride", "zirconium-tetrafluoride", "thorium-tetrafluoride",
	"uranium-tetrafluoride", "lftr-fuel-1", "lftr-fuel-2", "lftr-fuel-3" })
put("molten-elements", { "molten-uranium-235", "molten-plutonium-241", "molten-uranium-233", "molten-rhenium" })
put("molten-superalloys", { "molten-hastelloy-n", "molten-hs188-a" })
put("nuclear", { "lithium-tetrafluoroberyllate", "uranium-depleted-molten-salt", "thorium-depleted-molten-salt",
	"thorium-beryllium-depleted-molten-salt", "helium-sparged-u-salt", "fluorine-sparged-t-salt", "fluorine-sparged-tb-salt",
	"fluorinated-uranium-hexafluoride", "phosphorous-uranium-hexafluoride", "impure-molten-salt-base", "sodium-fluoride",
	"stable-molten-salt-base", "lftr-fuel-base" })
put("gases", { "neptunium-hexafluoride", "technetium-hexafluoride", "selenium-hexafluoride" })
--- issue #364: GTNH's sapphire and green sapphire juice (155)
put("ore-solutions", { "sapphire-juice", "green-sapphire-juice" })
--- issue #119: Space Age's melts, restyled below, are rows of the Fluids tab like the other melts
put("molten-elements", { "molten-iron", "molten-copper" })
put("molten-alloys", { "molten-potassium-disulfate" })
--- tiered: the plasma forge catalysts crude < prosaic < resplendent < stellar, then the godforge fluids
FLUID_SUBGROUP["excited-dimensionally-transcendent-crude-catalyst"] = { "endgame", 1 }
FLUID_SUBGROUP["excited-dimensionally-transcendent-prosaic-catalyst"] = { "endgame", 2 }   -- issue #355
FLUID_SUBGROUP["excited-dimensionally-transcendent-resplendent-catalyst"] = { "endgame", 3 }
FLUID_SUBGROUP["excited-dimensionally-transcendent-stellar-catalyst"] = { "endgame", 4 }
put("endgame", { "raw-star-matter", "spatially-enlarged-fluid", "tachyon-rich-temporal-fluid", "quark-gluon-plasma" })
--- issue #355: the plasma forge's residue and superfluid, grade 8 water's baryonic matter, oganesson
put("endgame", { "dimensionally-transcendent-residue", "stable-baryonic-matter", "dimensionally-shifted-superfluid" })
put("gases", { "oganesson" })
--- issue #355 step 4: the beamline's particles and UU matter
put("particles", { "electron", "proton", "tau", "omega", "upsilon", "graviton" })
put("endgame", { "uu-matter" })

--- patterns for whole lines (and for new fluids of a known kind); rank = a capture that orders the line by tier
local FLUID_PATTERNS = {
	{ "^grade%-(%d+)%-water$", "purified-water", rank = true },
	{ "%-plasma$", "plasmas" },
	{ "naquad", "nuclear" },
	{ "uranium", "nuclear" },
	{ "plutonium", "nuclear" },
	{ "^steam%-cracked%-", "fuels" },
	{ "^sulfuric%-.*fuel$", "fuels" },
	{ "^sulfuric%-naphtha$", "fuels" },
	{ "^sulfuric%-gas$", "fuels" },
	{ "^poly", "polymers" },
	{ "^liquid%-.*air$", "coolants" },
	{ "%-air$", "basic" },
	{ "%-acid$", "acids" },
	{ "^molten%-", "molten-alloys" },
	{ "%-solution$", "ore-solutions" },
}

local function is_gregtorios(f)
	local icon = f.icon or (f.icons and f.icons[1] and f.icons[1].icon)
	return FLUID_SUBGROUP[f.name] ~= nil or (type(icon) == "string" and icon:sub(1, #P) == P)
end

--- row and order of a Gregtorio fluid
local function place(name)
	local e = FLUID_SUBGROUP[name]
	if type(e) == "string" then return "gregtorio-fluids-" .. e, "m" end
	if e and e[1] == "fluid" then return "fluid", e[2] end
	if e then return "gregtorio-fluids-" .. e[1], string.format("a[%03d]-[%s]", e[2], name) end
	for _, p in pairs(FLUID_PATTERNS) do
		local m = name:match(p[1])
		if m then
			local order = p.rank and string.format("a[%03d]-[%s]", tonumber(m), name) or "m"
			return "gregtorio-fluids-" .. p[2], order
		end
	end
	return "gregtorio-fluids-unsorted", "m"
end

--- a vanilla fluid that only got a Gregtorio icon (water) keeps its vanilla row
local function in_fluids_tab(f)
	local sg = f.subgroup and data.raw["item-subgroup"][f.subgroup]
	return sg ~= nil and sg.group == "fluids"
end

--------------------------------------------------------------------------------
--- Issue #119: icons of the vanilla fluids Gregtorio uses, and the unused ones
--------------------------------------------------------------------------------

--- molten iron and copper are Space Age's fluids (saves and its recipes hold them): the same prototypes, with the
--- icon of the other melts (tools/gen_gt_icons.py --molten: GT's molten texture in GT's colour of the material, printed
--- by the tool: GT Iron 200 200 200, GT Copper 255 100 0) and the colour of the pipes to match
local VANILLA_MELTS = { iron = { 200, 200, 200 }, copper = { 255, 100, 0 } }
for mat, c in pairs(VANILLA_MELTS) do
	local f = data.raw.fluid["molten-" .. mat]
	if f then
		local col = { r = c[1] / 255, g = c[2] / 255, b = c[3] / 255 }
		f.icon, f.icons, f.icon_size = P .. "graphics/fluids/molten-" .. mat .. ".png", nil, 32
		f.base_color, f.flow_color = col, table.deepcopy(col)
	end
end
--- steam: GT's steam texture (tools/gen_gt_icons.py --fluid steam=fluid.steam); the prototype stays (boilers, steam
--- turbines, saves), the colours of the pipes too
if data.raw.fluid["steam"] then
	local f = data.raw.fluid["steam"]
	f.icon, f.icons, f.icon_size = P .. "graphics/fluids/steam.png", nil, 32
end

--- vanilla and Space Age fluids that no recipe a player can reach makes or uses but their void recipe: hidden
--- with it (hidden fluids are gone from the choosers and the Fluids tab). What still refers to them is Space Age
--- content nobody can obtain (fusion reactor and generator, thruster, the Aquilo and oil ocean tiles, the lithium brine
--- resource); a hidden fluid there is fine. FORK_FLUIDS_HIDDEN: the list, for devcheck. (Issue #318: heavy and light oil
--- are shown again: the Space Elevator's pump module makes them, 162 distils them.)
FORK_FLUIDS_HIDDEN = { "petroleum-gas", "ammoniacal-solution", "fluoroketone-cold",
	"fluoroketone-hot", "holmium-solution", "electrolyte", "lithium-brine", "thruster-fuel", "thruster-oxidizer",
	"fusion-plasma" }
for _, n in pairs(FORK_FLUIDS_HIDDEN) do
	if data.raw.fluid[n] then data.raw.fluid[n].hidden = true end
	if data.raw.recipe["void-" .. n] then data.raw.recipe["void-" .. n].hidden = true end
end

--- fluids that keep an icon of another mod on purpose (allow-list of devcheck's icon warning, with the reason)
local GT_OIL_BLACK = "GT's oil textures are plain black in every frame (fluid.liquid_heavy_oil, fluid.liquid_light_oil); "
	.. "the base game's icons tell the oils apart (issue #318)"
FORK_FLUID_ICONS_KEPT = {
	["heavy-oil"] = GT_OIL_BLACK,
	["light-oil"] = GT_OIL_BLACK,
}

for name, f in pairs(data.raw.fluid) do
	if is_gregtorios(f) and (FLUID_SUBGROUP[name] or not in_fluids_tab(f)) then
		f.subgroup, f.order = place(name)
		if f.subgroup == "gregtorio-fluids-unsorted" then log("FORK-FLUID-UNSORTED: " .. name) end
	end
end

--------------------------------------------------------------------------------
--- Items in "Unsorted" for the same reason: upstream redefines a vanilla item without a subgroup
--------------------------------------------------------------------------------

--- the iron gear (09-steam-age-item.lua) next to the other gears of create_item (mv extruder row)
local gear = data.raw.item["iron-gear-wheel"]
if gear and not gear.subgroup and data.raw["item-subgroup"]["subgroup-mv-extruder-recipes"] then
	gear.subgroup, gear.order = "subgroup-mv-extruder-recipes", "j[gear]-a[iron]"
end

--------------------------------------------------------------------------------
--- Issue #315: the production tab in tier order. Every tier has a row of machines (<tier>-age-production-machine) and a
--- row of multiblocks (subgroup-<tier>-age-multiblocks); LV to EV are ordered "c" to "i", the machine row of a tier and
--- then its multiblocks. The rows from IV up were "i-z-<tier>" (alphabetical: IV, LuV, MAX, UEV, UHV ...) and their
--- multiblock rows "j" to "q-max", after all of them. They get the order of their tier now, the multiblocks right after
--- the machines. Three EV items of upstream (18-ev-age-entity.lua) sat in the HV rows, and the recipes of the machines
--- made one tier up (fork_make_tier_machine, 101) kept the row of the machine they were copied from: a recipe in a tier
--- row goes into the row of its product.
--------------------------------------------------------------------------------
local TIER_ROWS = { "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
for i, t in ipairs(TIER_ROWS) do
	local key = string.format("i-z-%02d", i)
	local machines = data.raw["item-subgroup"][t .. "-age-production-machine"]
	if machines then machines.order = key .. "-a" end
	local multiblocks = data.raw["item-subgroup"]["subgroup-" .. t .. "-age-multiblocks"]
	if multiblocks then multiblocks.order = key .. "-b" end
end
for name, sg in pairs({ ["ev-autoclave"] = "ev-age-production-machine", ["ev-compressor"] = "ev-age-production-machine",
	["ev-tall-distillation-tower"] = "subgroup-ev-age-multiblocks" }) do
	local it = data.raw.item[name]
	if it and data.raw["item-subgroup"][sg] then it.subgroup = sg end
end
local function tier_row(sg)
	return sg and (sg:match("^[a-z]+%-age%-production%-machine$") or sg:match("^subgroup%-[a-z]+%-age%-multiblocks$"))
end
local function item_of(name)
	for t in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][name] then return data.raw[t][name] end
	end
end
local moved = 0
for _, r in pairs(data.raw.recipe) do
	if tier_row(r.subgroup) then
		local main = r.main_product
		if (not main or main == "") and r.results and #r.results == 1 then main = r.results[1].name end
		local it = main and main ~= "" and item_of(main)
		if it and tier_row(it.subgroup) and it.subgroup ~= r.subgroup then
			r.subgroup = it.subgroup
			moved = moved + 1
		end
	end
end
log("FORK-SUBGROUPS: " .. moved .. " machine recipes moved into the tier row of their product (issue #315)")
