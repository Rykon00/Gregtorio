--------------------------------------------------------------------------------
--- FORK: WIRELESS ENERGY (issue #622, the maintainer's decisions of 2026-10-27 and 2026-10-30)
--- GT New Horizons has a global energy account per team from UHV on (WirelessNetworkManager.java:29-55): a wireless
--- energy hatch takes its machine's power from the account, a wireless cover on a dynamo hatch puts a generator's power
--- into it, on any dimension. Here, per tier UHV to UXV, one of each at the tier's four amps (136's cap):
---   * the Wireless Dynamo Hatch (GT's wireless energy cover on the tier's dynamo hatch): an electric energy interface
---     that draws from its surface's network into its force's account;
---   * the Wireless Energy Hatch: an electric energy interface that gives its surface's network power from the account.
--- scripts/fork-wireless.lua moves the energy every 60 ticks (storage.fork_wireless.accounts, joules per force).
--- Recipes: GT's (the dump's fakeAssemblylineProcess and assembler recipes, UMV): the energy hatch from the tier's
--- energy hatch, the Ameliorated Superconducting Coil (GT's compact fusion coil, Gregtorio's compact-fusion-coil), a
--- superconducting coil block, an Active Transformer, 2 high power casings, 2 spacetime wires, a dense infinity plate,
--- 4 circuits of the tier above, an energised tesseract, 129.6 mutated living solder and 50 excited dimensionally
--- transcendent exotic catalyst; the dynamo hatch (GT's cover recipe) from 4 dense transcendent metal plates, an Active
--- Transformer, 2 infinity wires, the tier's wireless energy hatch and dynamo hatch, and 320 of the catalyst. Gregtorio
--- lacks GT's exotic catalyst: its resplendent catalyst (the one below) stands in. The Active Transformer (TecTech's)
--- is a named stand-in: GT's recipe (a LuV power transformer, a high energy flow circuit, 16 LuV superconductor wires,
--- 2 ultra high power ICs, 576 L tungstensteel) with a LuV machine hull for the transformer and a LuV circuit for the
--- high energy flow circuit, which Gregtorio lacks (no voltage tiers, #619).
--- Unlocks: the Active Transformer by 155's unlock_after; the hatches by the new technology Wireless Energy (12 packs),
--- after the first technology of each of their inputs, so at UMV as in GTNH.
--------------------------------------------------------------------------------

local OC = FORK_ORE_CHAIN
local ICON = "__gregtorio-continued__/graphics/icons/"
local TIERS = { "uhv", "uev", "uiv", "umv", "uxv" }
local ABOVE = { uhv = "uev", uev = "uiv", uiv = "umv", umv = "uxv", uxv = "max" }
--- four amps of the tier, as 136's dynamo cap
local CAP = { uhv = "655.36MW", uev = "1310.72MW", uiv = "2621.44MW", umv = "5242.88MW", uxv = "10485.76MW" }
local CATALYST = "excited-dimensionally-transcendent-resplendent-catalyst"

--- the technologies of every recipe that makes an item (as 170); nil: from the start
local function item_techs(name)
	local effects = {}
	for tn, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" then effects[e.recipe] = effects[e.recipe] or {}; table.insert(effects[e.recipe], tn) end
		end
	end
	local out = {}
	for rname, r in pairs(data.raw.recipe) do
		if not r.hidden and not rname:match("recycling") then
			for _, res in pairs(r.results or {}) do
				if res.name == name then
					if r.enabled ~= false then return nil end
					for _, tn in pairs(effects[rname] or {}) do out[#out + 1] = tn end
				end
			end
		end
	end
	return out
end
--- `tech`: the list of a technology of this file's (its recipes and its prerequisites), else 155's unlock_after
local function recipe(name, category, seconds, ingredients, tech)
	local ing = {}
	for _, i in pairs(ingredients) do
		ing[#ing + 1] = { type = data.raw.fluid[i[1]] and "fluid" or "item", name = i[1], amount = i[2] }
	end
	create_recipe{ recipe_name = name, category = category, energy_required = seconds, ingredients = ing,
		results = { { type = "item", name = name, amount = 1 } }, main_product = name }
	local groups = {}
	for _, i in pairs(ingredients) do groups[#groups + 1] = item_techs(i[1]) end
	if tech then
		tech.recipes[#tech.recipes + 1] = name
		for i, g in pairs(groups) do
			if not ingredients[i][1]:match("%-wireless%-") and g[1] then
				table.sort(g)
				tech.pre[g[1]] = true
			end
		end
	elseif not OC.unlock_after(name, groups) then
		log("FORK-WIRELESS: no technology for " .. name)
	end
end

--- the Active Transformer
create_item{ skip_recipe = true, name = "active-transformer", subgroup = data.raw.item["uhv-energy-hatch"].subgroup }
recipe("active-transformer", "luv-assembling-machine-recipes", 20 * LUV_SPEED, {
	{ "luv-machine-hull", 1 }, { "luv-circuit", 1 }, { "luv-superconductor-wire", 16 },
	{ "ultra-high-powered-integrated-circuit", 2 }, { "molten-tungstensteel", 57.6 } })

--- the hatches, as electric energy interfaces
local names = { energy = {}, dynamo = {} }
local tech = { recipes = {}, pre = {} }
for i, tier in pairs(TIERS) do
	for _, kind in pairs({ "energy", "dynamo" }) do
		local name = tier .. "-wireless-" .. kind .. "-hatch"
		data:extend({ {
			type = "electric-energy-interface", name = name, icon = ICON .. name .. ".png", icon_size = 32,
			flags = { "placeable-player", "player-creation" }, minable = { mining_time = 0.5, result = name },
			max_health = 200, collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } }, selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
			energy_source = kind == "energy"
				and { type = "electric", usage_priority = "tertiary", buffer_capacity = CAP[tier]:gsub("W$", "J"),
					output_flow_limit = CAP[tier], input_flow_limit = "0W" }
				or { type = "electric", usage_priority = "secondary-input", buffer_capacity = CAP[tier]:gsub("W$", "J"),
					input_flow_limit = CAP[tier], output_flow_limit = "0W" },
			energy_production = "0W", energy_usage = "0W", gui_mode = "none",
			picture = { filename = ICON .. name .. ".png", size = 32, scale = 1 },
			localised_description = { "entity-description.fork-wireless-" .. kind .. "-hatch", CAP[tier] },
		} })
		create_item{ skip_recipe = true, name = name, place_result = name, stack_size = 16,
			subgroup = data.raw.item[tier .. "-energy-hatch"].subgroup,
			order = (data.raw.item[tier .. "-energy-hatch"].order or "") .. "-wireless-" .. kind }
		names[kind][#names[kind] + 1] = name
	end
	--- (GT's assembly line recipe at UMV: Gregtorio's assembly lines end at ZPM)
	recipe(tier .. "-wireless-energy-hatch", "zpm-assembly-line-recipes", 20 * ZPM_SPEED, {
		{ tier .. "-energy-hatch", 1 }, { "compact-fusion-coil", 1 }, { "superconducting-coil-block", 1 },
		{ "active-transformer", 1 }, { "high-power-casing", 2 }, { "spacetime-wire", 2 }, { "dense-infinity-plate", 1 },
		{ ABOVE[tier] .. "-circuit", 4 }, { "energised-tesseract", 1 }, { "mutated-living-solder", 129.6 }, { CATALYST, 50 } },
		tech)
	recipe(tier .. "-wireless-dynamo-hatch", "umv-assembling-machine-recipes", 10 * UMV_SPEED, {
		{ "dense-transcendent-metal-plate", 4 }, { "active-transformer", 1 }, { "infinity-wire", 2 },
		{ tier .. "-wireless-energy-hatch", 1 }, { tier .. "-dynamo-hatch", 1 }, { CATALYST, 320 } }, tech)
end

--- the technology Wireless Energy: every hatch, after every input's first technology
local pre = {}
for t in pairs(tech.pre) do pre[#pre + 1] = t end
table.sort(pre)
FORK5B.tech{ name = "wireless-energy", packs = 12, count = 100, time = 60, recipes = tech.recipes, prerequisites = pre }

data:extend({ { type = "mod-data", name = "fork-wireless", data = { energy = names.energy, dynamo = names.dynamo,
	check_ticks = 60 } } })
