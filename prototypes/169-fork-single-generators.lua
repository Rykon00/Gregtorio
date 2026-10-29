--------------------------------------------------------------------------------
--- FORK SINGLE-BLOCK GENERATORS (issue #644, the decision on #638: as in GT New Horizons)
--- GT's single-block naquadah reactors Mark I to V and plasma generators Mark I to IV and the Ultimate Pocket Sun
--- (gregtech/loaders/preload/LoaderMetaTileEntities.java:9135-9171 and 9221-9254), on GT's tiers EV to UV, one amp
--- of the tier (EU32) like 145's EV and IV gas turbines, 3x3 (sprites: tools/gen_sprites.py single_generators).
---   * Naquadah reactors (MTENaquadahReactor): burner generators; each tier burns its one GT fuel (the dump's
---     gt.recipe.*naquadahreactor maps, 1 EU = 1 kJ) and gives the depleted part back:
---       Mk I   EV   enriched naquadah bolt         50 000 EU -> naquadah bolt        efficiency  80 %
---       Mk II  IV   enriched naquadah rod         250 000 EU -> naquadah rod                   100 %
---       Mk III LuV  naquadria bolt                250 000 EU -> naquadah bolt                  150 %
---       Mk IV  ZPM  naquadria rod               1 000 000 EU -> naquadah rod                   200 %
---       Mk V   UV   long enriched naquadah rod    500 000 EU -> long naquadah rod              250 %
---     (getEfficiency: 80 % at EV, then 100 + 50 per tier.) bartworks' tiberium fuels are left out: no tiberium here.
---   * Plasma generators (MTEPlasmaGenerator): 136's fluid generators on the plasmas 136 gives a fuel value (accepted
---     fuels in the mod data "fork-power", as for the large plasma turbines), efficiency 10 + 10 x tier %: 50 % at EV to
---     90 % at UV. Unlike the large plasma turbine, GT's single block gives no cooled fluid back.
---   * Recipes: GT's crafting table recipes (two rods, two circuits, two field generators, the hull, two cables or
---     wires). GT's 4x, 8x and 12x cables and wires are 4, 8 and 12 single ones here (the cable sizes are #729's).
---     Stand-ins: uranium 235 for GT's two uranium 235 rods (one ingot's worth; Gregtorio has no uranium 235 rod),
---     plutonium 239 dust for two plutonium 241 rods (Gregtorio's plutonium 241 comes only with Fusion Plasmas MK3, its
---     plutonium 239 with the LFTR, LuV), the vanadium-gallium cable (the LuV hull's) for GT's HSS-G cable (Gregtorio has
---     no HSS-G cable).
---   * Unlocks: after every input and the machine's fuel (155's unlock_after), so no generator comes before its fuel.
--- Loaded after 158 and 164 (the parts, the plasmas) and before 157, which recycles the machines.
--------------------------------------------------------------------------------

local OC = FORK_ORE_CHAIN
local ICON = "__gregtorio-continued__/graphics/icons/fork/"
local SPRITE = "__gregtorio-continued__/graphics/entity/fork/"
local POWER = { ev = EU32_EV, iv = EU32_IV, luv = EU32_LuV, zpm = EU32_ZPM, uv = EU32_UV }
local SUBGROUP = data.raw.item["iv-gas-turbine"].subgroup

local function stack(name, amount) return { type = "item", name = name, amount = amount } end
--- 50000 EU -> "50MJ"
local function eu(value)
	if value >= 1e6 then return string.format("%.5gGJ", value / 1e6) end
	return string.format("%.5gMJ", value / 1e3)
end
--- "81.92MJ" -> 81.92e6
local function joules(value)
	return tonumber(value:match("^[%d.]+")) * ({ kJ = 1e3, MJ = 1e6, GJ = 1e9 })[value:match("%a+$")]
end
--- the technologies that give an item or fluid: 155's, else those of every recipe that makes it now (an item 155 does
--- not know, as 164's; like 158's item_techs); nil: there from the start
local tech_effects
local function item_techs(name)
	local t = OC.item_techs(name)
	if t == nil or #t > 0 then return t end
	if not tech_effects then
		tech_effects = {}
		for tn, tech in pairs(data.raw.technology) do
			for _, e in pairs(tech.effects or {}) do
				if e.type == "unlock-recipe" then
					tech_effects[e.recipe] = tech_effects[e.recipe] or {}
					table.insert(tech_effects[e.recipe], tn)
				end
			end
		end
	end
	local out = {}
	for rname, r in pairs(data.raw.recipe) do
		if not r.hidden and not rname:match("recycling") then
			for _, res in pairs(r.results or {}) do
				if res.name == name then
					if r.enabled ~= false then return nil end
					for _, tn in pairs(tech_effects[rname] or {}) do out[#out + 1] = tn end
				end
			end
		end
	end
	return out
end
--- the recipe of a generator: unlocked after its inputs and its fuel
local function machine(name, ingredients, fuel)
	create_item{ name = name, icon = ICON .. name .. ".png", subgroup = SUBGROUP, ingredients = ingredients,
		place_result = name, stack_size = 10 }
	local groups = { item_techs(fuel) }
	for _, i in pairs(ingredients) do groups[#groups + 1] = item_techs(i.name) end
	if OC.unlock_after(name, groups) then return end
	--- the inputs on branches without a common later technology: of each input its earliest technology (fewest
	--- ancestors), of those the latest (the tree check reports what its prerequisites miss)
	local function ancestors(tn)
		local n, seen = 0, {}
		local function walk(t)
			for _, pre in pairs(data.raw.technology[t] and data.raw.technology[t].prerequisites or {}) do
				if not seen[pre] then seen[pre] = true; n = n + 1; walk(pre) end
			end
		end
		walk(tn)
		return n
	end
	local best, best_n
	for _, g in pairs(groups) do
		local first, first_n
		for _, tn in pairs(g or {}) do
			local n = ancestors(tn)
			if not first or n < first_n then first, first_n = tn, n end
		end
		if first and (not best or first_n > best_n) then best, best_n = first, first_n end
	end
	if best then fork_add_unlock(best, name) else log("FORK-SINGLE-GENERATORS: no technology for " .. name) end
end

--------------------------------------------------------------------------------
--- 1) NAQUADAH REACTORS MARK I TO V
--------------------------------------------------------------------------------
local REACTORS = {
	--  tier   fuel                          EU         depleted              eff.  rods (x2)                       circuits (x2)  cable
	{ "ev",  "enriched-naquadah-bolt",        50000,   "naquadah-bolt",      0.8, { "uranium-235", 1 },          "iv-circuit",  "aluminium-cable" },
	{ "iv",  "enriched-naquadah-rod",         250000,  "naquadah-rod",       1.0, { "plutonium-239-dust", 1 },   "luv-circuit", "tungsten-cable" },
	{ "luv", "naquadria-bolt",                250000,  "naquadah-bolt",      1.5, { "europium-rod", 2 },         "zpm-circuit", "vanadium-gallium-cable" },
	{ "zpm", "naquadria-rod",                 1000000, "naquadah-rod",       2.0, { "americium-rod", 2 },        "uv-circuit",  "naquadah-cable" },
	{ "uv",  "long-enriched-naquadah-rod",    500000,  "long-naquadah-rod",  2.5, { "naquadah-alloy-rod", 2 },   "uhv-circuit", "fluxed-electrum-cable" },
}
for i, r in ipairs(REACTORS) do
	local tier, name = r[1], r[1] .. "-naquadah-reactor"
	local category = "naquadah-reactor-mk" .. i
	data:extend({ { type = "fuel-category", name = category } })
	local fuel = data.raw.item[r[2]]
	if fuel.fuel_value then error("169-fork-single-generators: " .. r[2] .. " has a fuel value already") end
	fuel.fuel_categories, fuel.fuel_value, fuel.burnt_result = { category }, eu(r[3]), r[4]
	create_burner_generator{
		name = name, icon = ICON .. name .. ".png", efficiency = r[5], fuel_categories = { category },
		max_power = POWER[tier], frame_count = 1,
		idle_animation = SPRITE .. name .. "-idle.png", working_animation = SPRITE .. name .. "-working.png",
	}
	machine(name, { stack(r[6][1], r[6][2]), stack(r[7], 2), stack(tier .. "-field-generator", 2),
		stack(tier .. "-machine-hull", 1), stack(r[8], 8) }, r[2])
end

--------------------------------------------------------------------------------
--- 2) PLASMA GENERATORS MARK I TO IV AND THE ULTIMATE POCKET SUN
--------------------------------------------------------------------------------
local power_data = data.raw["mod-data"]["fork-power"].data
local plasmas = power_data.fuels["luv-large-plasma-turbine"]
local min_plasma = math.huge
for _, p in pairs(plasmas) do min_plasma = math.min(min_plasma, joules(data.raw.fluid[p].fuel_value)) end
local PLASMA_GENERATORS = {
	--  tier   eff.  rods (x2)                       circuits (x2)  field generators (x2)  hull                 wire or cable
	{ "ev",  0.5, { "plutonium-239-dust", 1 },   "iv-circuit",  "hv-field-generator",  "luv-machine-hull", { "tungsten-cable", 8 } },
	{ "iv",  0.6, { "europium-rod", 2 },         "luv-circuit", "ev-field-generator",  "zpm-machine-hull", { "vanadium-gallium-wire", 8 } },
	{ "luv", 0.7, { "americium-rod", 2 },        "zpm-circuit", "iv-field-generator",  "uv-machine-hull",  { "naquadah-wire", 8 } },
	{ "zpm", 0.8, { "americium-rod", 2 },        "zpm-circuit", "zpm-field-generator", "uv-machine-hull",  { "triamerotronium-superconductive-wire", 16 } },
	{ "uv",  0.9, { "americium-rod", 2 },        "uv-circuit",  "uv-field-generator",  "uv-machine-hull",  { "triamerotronium-superconductive-wire", 24 } },
}
for _, g in ipairs(PLASMA_GENERATORS) do
	local name = g[1] .. "-plasma-generator"
	FORK_POWER.make_generator{ name = name, size = 3, power = POWER[g[1]], volume = 100, min_fuel = min_plasma,
		effectivity = g[2], icon = ICON .. name .. ".png" }
	power_data.fuels[name] = plasmas
	machine(name, { stack(g[3][1], g[3][2]), stack(g[4], 2), stack(g[5], 2), stack(g[6], 1), stack(g[7][1], g[7][2]) },
		"helium-plasma")
end
