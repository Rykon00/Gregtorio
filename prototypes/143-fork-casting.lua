--------------------------------------------------------------------------------
--- FORK CASTING (issue #91, part 2): fluid solidifier and fluid extractor
--- The solidifier cast parts for seven endgame metals only, and most melts could not be made from their ingot. As
--- GregTech does, every castable form of every material with a melt is cast here (with the one generic mold of
--- 150-fork-molds.lua, which every recipe of the solidifiers needs), every ingot with a melt can be melted in the
--- fluid extractor, and the materials with an ingot but no melt get one.
---
--- GT's casts (ProcessingShaping.java, ProcessingIngot/Plate/Block/Gear/Nugget/Rotor.java, bartworks'
--- MoltenCellLoader.java): melt per part in GT litres (144 per ingot) and seconds, at Gregtorio's scale (14.4 per
--- ingot, a tenth) and in the time GT takes at the material's voltage:
---   ingot 144 1.6 s, plate 144 1.6 s, block 1296 (GT: mass x 9 ticks; here 9 ingots of 1.6 s), nugget 16 0.8 s,
---   gear (GT's small gear) 144 0.8 s, large gear (GT's gear) 576 6.4 s, rotor 612 (GT: mass ticks; here the 4.9 s
---   of the upstream endgame casts), rod 72 7.5 s, long rod 144 15 s, bolt 18 2.5 s, ring 36 5 s, screw 18 2.5 s,
---   round 16 2.5 s
--- GT's fluid extractor melts an ingot into 144 in 24 ticks (GTRecipeRegistrator.registerReverseFluidSmelting).
---
--- MATERIALS: per material the solidifier tier and the technology. The tier is the one of the material's ingot cast
--- where one exists, else the higher of the machine tier of its ingot recipe and the tier of the technology that
--- unlocks it (GT: the material's voltage). The technology is the later of that technology and the one of the
--- tier's fluid solidifier and extractor. `color`: a material that had no melt gets one, molten-<material>, its
--- icon is GT's molten fluid texture in GT's material colour (tools/gen_gt_icons.py --molten, which prints the
--- colours: GT's molten colour where GT sets one, the GT++ alloys' colour, materials GT does not have take the colour
--- of their ingot icon; issue #99: dark colours are lifted, a melt glows). Forms: every form above that exists as an item and is not cast from
--- the melt yet; the melt recipe: every ingot whose melt has no extractor recipe yet, or (melt = true) only one
--- whose technology comes tiers later (the melts of the fusion inputs, made in the IV extractor from LuV/ZPM on). Upstream casts stay as they
--- are (some use other amounts: the endgame large gears 576.2, the rounds and bolts 1.8).
--- Not materials (no melt): the mixed metal ingot, the wrapped plutonium ingot and the iridium alloy ingot (items).
--- Chromium's melt is the upstream molten chrome.
--- Loaded after 142 (the technologies) and before 150 (the molds), 196 (the Fluids tab), 198 and 199.
--------------------------------------------------------------------------------

local F = FORK5B
local SPEED = { lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED, iv = IV_SPEED, luv = LUV_SPEED,
	zpm = ZPM_SPEED, uv = UV_SPEED, uhv = UHV_SPEED, uev = UEV_SPEED, uiv = UIV_SPEED, umv = UMV_SPEED,
	uxv = UXV_SPEED, max = MAX_SPEED }
local ALIAS = { ["chromium"] = "chrome" }

--- form, item name pattern, melt per part, seconds
local FORMS = {
	{ "ingot", "%s-ingot", 14.4, 1.6 },
	{ "plate", "%s-plate", 14.4, 1.6 },
	{ "block", "block-of-%s", 129.6, 14.4 },
	{ "nugget", "%s-nugget", 1.6, 0.8 },
	{ "gear", "%s-gear", 14.4, 0.8 },
	{ "large-gear", "large-%s-gear", 57.6, 6.4 },
	{ "rotor", "%s-rotor", 61.2, 4.9 },
	{ "rod", "%s-rod", 7.2, 7.5 },
	{ "long-rod", "long-%s-rod", 14.4, 15 },
	{ "bolt", "%s-bolt", 1.8, 2.5 },
	{ "ring", "%s-ring", 3.6, 5 },
	{ "screw", "%s-screw", 1.8, 2.5 },
	{ "round", "%s-round", 1.6, 2.5 },
}

local MATERIALS = {
	["brass"] = { "lv", "circuit-assembler", color = { 255, 180, 0 } },
	["bronze"] = { "lv", "concrete", color = { 255, 128, 0 } },
	["cobalt-brass"] = { "lv", "cobalt-brass", color = { 180, 180, 160 } },
	["copper"] = { "lv", "concrete", melt = true },
	["cupronickel"] = { "lv", "electric-blast-furnace", melt = true },
	["europium"] = { "lv", "fusion-plasmas-mk1" },
	["gold"] = { "lv", "concrete", color = { 255, 255, 30 } },
	["incoloy-903"] = { "lv", "large-electric-compressor" },
	["invar"] = { "lv", "invar", color = { 180, 180, 120 } },
	["iron"] = { "lv", "concrete" },
	["kanthal"] = { "lv", "kanthal", melt = true },
	["lead"] = { "lv", "galena", color = { 192, 137, 192 } },
	["nickel"] = { "lv", "invar", color = { 200, 200, 250 } },
	["nickel-zinc-ferrite"] = { "lv", "smd-components" },
	["red-alloy"] = { "lv", "concrete" },
	["silver"] = { "lv", "galena", melt = true },
	["stainless-steel"] = { "lv", "stainless-steel" },
	["steel"] = { "lv", "concrete", color = { 185, 185, 185 } },
	["tin"] = { "lv", "concrete" },
	["zinc"] = { "lv", "concrete", color = { 250, 240, 240 } },
	["aluminium"] = { "mv", "mv-machines", melt = true },
	["annealed-copper"] = { "mv", "integrated-circuits", color = { 255, 120, 20 } },
	["battery-alloy"] = { "mv", "battery", color = { 156, 124, 160 } },
	["beryllium"] = { "mv", "advanced-mv-machines", melt = true },
	["black-steel"] = { "mv", "mv-machines" },
	["conductive-iron"] = { "mv", "mv-machines", color = { 255, 191, 195 } },
	["eglin-steel"] = { "mv", "mv-machines", color = { 191, 95, 26 } },
	["electrum"] = { "mv", "advanced-integrated-circuits", color = { 255, 255, 100 } },
	["energetic-alloy"] = { "mv", "energetic-alloy", color = { 255, 140, 25 } },
	["grisium"] = { "mv", "chemical-bath-plant" },
	["hsse"] = { "mv", "hsse" },
	["hssg"] = { "mv", "hssg" },
	["hsss"] = { "mv", "hsss" },
	["inconel-625"] = { "mv", "fluid-shaper" },
	["maraging-steel-250"] = { "mv", "industrial-centrifuge" },
	["maraging-steel-300"] = { "mv", "industrial-cutting-factory" },
	["microversium"] = { "mv", "mv-machines" },
	["niobium-titanium"] = { "mv", "niobium-titanium" },
	["pulsating-iron"] = { "mv", "eyes-of-ender", color = { 128, 246, 155 } },
	["ruridit"] = { "mv", "ruridit" },
	["silicon"] = { "mv", "advanced-integrated-circuits", melt = true },
	["tungsten-carbide"] = { "mv", "tungsten-carbide" },
	["ultimet"] = { "mv", "alloy-blast-smelter" },
	["vanadium-gallium"] = { "mv", "vanadium-gallium" },
	["vanadium-steel"] = { "mv", "oil-gathering" },
	["watertight-steel"] = { "mv", "fluid-shaper" },
	["zeron-100"] = { "mv", "alloy-blast-smelter" },
	["blue-steel"] = { "hv", "hv-energy-hatches" },
	["chromium"] = { "hv", "advanced-hv-machines", melt = true },
	["gallium"] = { "hv", "smd-components" },
	["hastelloy-w"] = { "hv", "alloy-blast-smelter" },
	["hastelloy-x"] = { "hv", "hyper-intensity-laser-engraver" },
	["incoloy-020"] = { "hv", "alloy-blast-smelter" },
	["incoloy-ds"] = { "hv", "zyngen" },
	["inconel-690"] = { "hv", "industrial-extrusion-machine" },
	["inconel-792"] = { "hv", "industrial-centrifuge" },
	["indovanadium"] = { "hv", "space-science-pack" },
	["neodymium"] = { "hv", "hv-machines", melt = true },
	["nichrome"] = { "hv", "nichrome-coils" },
	["platinum"] = { "hv", "smd-components", color = { 255, 255, 200 } },
	["rtm-alloy"] = { "hv", "alloy-blast-smelting-older-materials" },
	["staballoy"] = { "hv", "staballoy" },
	["talonite"] = { "hv", "industrial-cutting-factory" },
	["tantalloy-60"] = { "hv", "industrial-wire-factory" },
	["tantalum"] = { "hv", "niobium-and-tantalum-extraction" },
	["tantalum-carbide"] = { "hv", "zyngen" },
	["tumbaga"] = { "hv", "large-sifter", color = { 255, 178, 15 } },
	["tungstensteel"] = { "hv", "tungstensteel" },
	["vibrant-alloy"] = { "hv", "tier-three-microminers" },
	["dark-steel"] = { "ev", "ev-machines", color = { 159, 139, 159 } },
	["electrical-steel"] = { "ev", "ev-machines", color = { 216, 216, 216 } },
	["end-steel"] = { "ev", "ev-machines", color = { 219, 206, 125 } },
	["enderium"] = { "ev", "zpm-materials" },
	["hastelloy-c276"] = { "ev", "ev-machines" },
	["incoloy-ma956"] = { "ev", "ev-machines" },
	["soularium"] = { "ev", "ender-io", color = { 194, 146, 83 } },
	["stellite"] = { "ev", "industrial-electrolyzer" },
	["titanium"] = { "ev", "ev-machines", melt = true },
	["tungsten"] = { "ev", "ev-machines" },
	["zirconium-carbide"] = { "ev", "ev-machines", color = { 222, 202, 180 } },
	["crystaltine"] = { "iv", "tier-four-microminers", color = { 115, 188, 218 } },
	["iridium"] = { "iv", "iv-machines", color = { 240, 240, 245 } },
	["magnalium"] = { "iv", "industrial-mixer", color = { 200, 190, 255 } },
	["naquadah-alloy"] = { "iv", "naquadah-alloy" },
	["nitinol-60"] = { "iv", "hyper-intensity-laser-engraver" },
	["potin"] = { "iv", "industrial-electrolyzer", color = { 201, 151, 129 } },
	["rhodium-plated-palladium"] = { "iv", "rhodium-plated-palladium", color = { 220, 220, 240 } },
	["samarium"] = { "iv", "luv-components", color = { 255, 255, 204 } },
	["signalum"] = { "iv", "tier-four-microminers", color = { 174, 72, 14 } },
	["yttrium-barium-cuprate"] = { "iv", "yttrium-barium-cuprate", color = { 159, 127, 139 } },
	["enriched-naquadah"] = { "luv", "enriched-naquadah", color = { 64, 255, 64 } },
	["ledox"] = { "luv", "super-coolant", color = { 0, 116, 255 } },
	["lithium"] = { "luv", "fusion-plasmas-mk1" },
	["naquadah"] = { "luv", "naquadah-processing" },
	["osmiridium"] = { "luv", "naquadah-alloy", color = { 100, 100, 255 } },
	["palladium-naqindium"] = { "luv", "zpm-superconductors", color = { 120, 120, 120 } },
	["trinium"] = { "luv", "enriched-naquadah" },
	["americium"] = { "zpm", "uv-materials" },
	["fluxed-electrum"] = { "zpm", "fluxed-electrum" },
	["itbtc-alloy"] = { "zpm", "crystal-processor-mainframes", color = { 153, 76, 0 } },
	["naquadria"] = { "zpm", "uv-materials" },
	["neutronium"] = { "zpm", "uv-materials" },
	["osmium"] = { "zpm", "zpm-energy-hatches", color = { 50, 50, 255 } },
	["palladium"] = { "zpm", "zpm-assembly-line", color = { 177, 177, 177 } },
	["bedrockium"] = { "uv", "bedrockium", color = { 138, 138, 138 } },
	["naquamiridium"] = { "uv", "uv-energy-hatches", color = { 224, 210, 7 } },
	["tritanium"] = { "uv", "uhv-materials" },
	["cosmic-neutronium"] = { "uhv", "uev-materials" },
	["draconium"] = { "uhv", "uev-materials" },
	["infinity"] = { "uhv", "uev-materials" },
	["quantium"] = { "uhv", "quantium" },
	["triamerotronium"] = { "uhv", "uhv-energy-hatches", color = { 38, 129, 189 } },
	["dracofinium"] = { "uev", "uev-energy-hatches", color = { 174, 8, 8 } },
	["rhugnor"] = { "uev", "fusion-coil-ii" },
	["transcendent-metal"] = { "uev", "uiv-materials" },
	["chromnorox"] = { "uiv", "uiv-energy-hatches", color = { 229, 88, 177 } },
	["spacetime"] = { "uiv", "umv-materials" },
	["hypocosmium"] = { "umv", "umv-energy-hatches", color = { 181, 38, 205 } },
	["universium"] = { "umv", "uxv-materials" },
	["eternity"] = { "uxv", "uxv-energy-hatches", color = { 153, 136, 172 } },
	["magmatter"] = { "uxv", "max-materials" },
}

local function item_exists(n)
	for t, _ in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][n] then return true end
	end
	return false
end
--- what is cast from a melt and which melts can be made from an ingot already
local cast, melted = {}, {}
for _, r in pairs(data.raw.recipe) do
	local c = r.category or "crafting"
	local melt
	for _, i in pairs(r.ingredients or {}) do
		if i.type == "fluid" and i.name:sub(1, 7) == "molten-" then melt = i.name end
	end
	if melt and (c:find("fluid%-solidifier") or c:find("vacuum%-freezer")) then
		for _, res in pairs(r.results or {}) do cast[melt .. "|" .. res.name] = true end
	end
	if c:find("extractor") then
		for _, res in pairs(r.results or {}) do
			for _, i in pairs(r.ingredients or {}) do
				if res.type == "fluid" and i.name:sub(-6) == "-ingot" then melted[res.name .. "|" .. i.name] = true end
			end
		end
	end
end

--- (recipes: the casts and melts made here; 199's auto-unlock does not count them as producers, see there)
FORK_CASTING = { casts = 0, melts = 0, fluids = 0, recipes = {} }
for mat, def in pairs(MATERIALS) do
	local tier, tech = def[1], def[2]
	local melt = "molten-" .. (ALIAS[mat] or mat)
	if def.color then
		F.fluid(melt, "molten-" .. mat, { def.color[1] / 255, def.color[2] / 255, def.color[3] / 255 })
		FORK_CASTING.fluids = FORK_CASTING.fluids + 1
	end
	for _, f in pairs(FORMS) do
		local item = string.format(f[2], mat)
		if item_exists(item) and not cast[melt .. "|" .. item] then
			local name = "solidify-" .. item
			if data.raw.recipe[name] then name = "solidify-" .. item .. "-from-melt" end
			create_recipe{
				name = name,
				category = tier .. "-fluid-solidifier-recipes",
				energy_required = f[4] * SPEED[tier],
				ingredients = { { type = "fluid", name = melt, amount = f[3] } },
				results = { { type = "item", name = item, amount = 1 } },
				main_product = item,
			}
			fork_add_unlock(tech, name)
			FORK_CASTING.recipes[name] = true
			FORK_CASTING.casts = FORK_CASTING.casts + 1
		end
	end
	local ingot = mat .. "-ingot"
	if item_exists(ingot) and (def.melt or not melted[melt .. "|" .. ingot]) then
		local name = "melt-" .. ingot
		create_recipe{
			name = name,
			category = tier .. "-extractor-recipes",
			energy_required = 1.2 * SPEED[tier],
			ingredients = { { type = "item", name = ingot, amount = 1 } },
			results = { { type = "fluid", name = melt, amount = 14.4 } },
			main_product = melt,
		}
		fork_add_unlock(tech, name)
		FORK_CASTING.recipes[name] = true
		FORK_CASTING.melts = FORK_CASTING.melts + 1
	end
end
log("FORK-CASTING: " .. FORK_CASTING.casts .. " casts, " .. FORK_CASTING.melts .. " melt recipes, "
	.. FORK_CASTING.fluids .. " new melts")
