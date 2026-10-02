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

put("basic", { "air", "nether-air", "ender-air", "distilled-water", "salt-water", "exhausted-water", "waste-liquid",
	"fluorine-rich-waste-liquid", "liquid-concrete" })
put("gases", { "hydrogen", "deuterium", "tritium", "helium", "helium-3", "nitrogen", "oxygen", "argon", "neon", "krypton",
	"xenon", "radon", "chlorine", "ozone", "carbon-dioxide", "carbon-monoxide", "nitrogen-dioxide",
	"dinitrogen-tetroxide", "sulfur-dioxide", "sulfur-trioxide", "hydrogen-sulfide", "hydrogen-cyanide" })
put("acids", { "aqua-regia", "nitration-mixture", "hydrogen-peroxide", "iron-iii-chloride", "antimony-pentachloride",
	"antimony-pentachloride-solution", "antimony-pentafluoride", "antimony-trichloride-solution", "titanium-tetrachloride",
	"silicon-tetrachloride", "sodium-tungstate", "polyaluminium-chloride" })
put("ore-solutions", { "bauxite-slurry", "heated-bauxite-slurry", "indium-concentrate", "lead-zinc-solution",
	"palladium-rich-ammonia", "platinum-palladium-leachate", "rhodium-sulfate-solution", "sulfuric-copper-solution",
	"sulfuric-iron-solution", "sulfuric-nickel-solution", "acidic-iridium-dioxide-solution", "acidic-osmium-solution",
	"sluice-juice", "ruby-juice" })
put("fuels", { "naphtha", "refinery-gas", "light-fuel", "heavy-fuel", "diesel", "cetane-boosted-diesel", "gasoline",
	"high-octane-gasoline", "rocket-fuel", "creosote", "wood-gas", "wood-tar", "wood-vinegar", "charcoal-byproducts",
	"methane", "ethane", "propane", "ethylene", "propene", "butene", "butadiene" })
put("organic", { "acetic-acid", "formic-acid", "phthalic-acid", "acetone", "benzene", "toluene", "dimethylbenzene", "phenol",
	"butyraldehyde", "chlorobenzene", "dichlorobenzene", "nitrochlorobenzene", "dichlorobenzidine", "diaminobenzidine",
	"chloroform", "chloroacetic-acid", "ethyl-cyanoacetate", "formaldehyde", "dimethylhydrazine", "diphenyl-isophthalate", "epichlorohydrin", "ethanol", "methanol", "ether",
	"methyl-acetate", "vinyl-acetate", "vinyl-chloride", "tetrafluoroethylene", "tetranitromethane", "sodium-formate",
	"p507", "biomass", "bacterial-sludge", "enriched-bacterial-sludge", "growth-medium", "mutagen" })
put("polymers", { "glue", "advanced-glue", "super-glue", "epoxy", "liquid-rubber", "silicone-rubber", "ptfe" })
put("coolants", { "cryogenic-helium", "lapis-coolant", "super-coolant", "sodium-potassium", "liquid-air",
	"liquid-nether-air", "liquid-ender-air" })
put("molten-elements", { "mercury", "molten-glass", "molten-borosilicate-glass", "molten-aluminium", "molten-americium",
	"molten-beryllium", "molten-chrome", "molten-cobalt", "molten-europium", "molten-flerovium", "molten-gallium",
	"molten-lithium", "molten-lutetium", "molten-magnesium", "molten-neodymium", "molten-silicon", "molten-silver",
	"molten-tantalum", "molten-tin", "molten-titanium", "molten-tungsten" })
put("molten-alloys", { "soldering-alloy" })
put("molten-superalloys", { "molten-hastelloy-c276", "molten-hastelloy-w", "molten-hastelloy-x", "molten-incoloy-020",
	"molten-incoloy-903", "molten-incoloy-ds", "molten-incoloy-ma956", "molten-inconel-625", "molten-inconel-690",
	"molten-inconel-792", "molten-maraging-steel-250", "molten-maraging-steel-300", "molten-stellite", "molten-talonite",
	"molten-ultimet", "molten-zeron-100", "molten-nitinol-60", "molten-tantalloy-60", "molten-staballoy",
	"molten-kanthal", "molten-nichrome" })
put("molten-exotic", { "molten-naquadah", "molten-naquadah-alloy", "molten-naquadria", "molten-trinium",
	"molten-tritanium", "molten-duranium", "molten-neutronium", "molten-cosmic-neutronium", "molten-draconium",
	"molten-infinity", "molten-transcendent-metal", "molten-spacetime", "molten-universium", "molten-magmatter",
	"molten-rhugnor", "molten-quantium", "molten-sunnarium", "molten-microversium", "molten-enderium",
	"molten-glowstone", "molten-vibrant-alloy", "molten-grisium", "molten-indovanadium", "molten-ruridit",
	"liquid-blaze" })
--- tiered: the plasma forge catalysts crude < resplendent < stellar, then the godforge fluids
FLUID_SUBGROUP["excited-dimensionally-transcendent-crude-catalyst"] = { "endgame", 1 }
FLUID_SUBGROUP["excited-dimensionally-transcendent-resplendent-catalyst"] = { "endgame", 2 }
FLUID_SUBGROUP["excited-dimensionally-transcendent-stellar-catalyst"] = { "endgame", 3 }
put("endgame", { "raw-star-matter", "spatially-enlarged-fluid", "tachyon-rich-temporal-fluid", "imaginary-time" })

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
