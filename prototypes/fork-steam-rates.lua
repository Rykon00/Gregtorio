--------------------------------------------------------------------------------
--- FORK STEAM RATES (issue #564): the game shows a boiler's and a steam machine's power in kW only, so a boiler's 1.2 steam
--- per second looked like a bug next to a steam machine that needs 3.2. Required from data-final-fixes.lua after every
--- file that makes or changes these machines; every number is computed from the prototypes:
---   * a `boiler` that makes steam or superheated steam: energy_consumption / (the output fluid's heat_capacity x (its
---     target_temperature - the input fluid's default_temperature)), also in output-to-separate-pipe mode;
---   * a machine with a fixed recipe that makes steam (101's lava and solar boilers): the recipe's steam / (its time /
---     the crafting speed); the solar boilers (mod data fork-solar-boilers) by day;
---   * a machine whose fluid energy source burns steam or superheated steam: energy_usage / (the fluid's fuel_value x the
---     source's effectivity) while it works; one of the steam age (its item comes with a technology of red science only,
---     or from the start) also says how many Small Coal Boilers that is.
--- The line goes after the entity's description ("?" keeps the description when it has none). FORK_STEAM_RATES (entity
--- -> { kind, type, fluid, rate, boilers }) is devcheck's section STEAMRATES (with whether the entity's description has the line); devcheck checks the Small Coal Boiler (1.2), the
--- Large Bronze Boiler (160) and the Steam Alloy Smelter (3.2).
--------------------------------------------------------------------------------

local STEAM = { steam = true, ["superheated-steam"] = true }
local SMALL_BOILER = "small-coal-boiler"
FORK_STEAM_RATES = {}

local PREFIX = { [""] = 1, k = 1e3, K = 1e3, M = 1e6, G = 1e9, T = 1e12, P = 1e15, E = 1e18 }
--- "36kW" -> 36000, "100kJ" -> 100000 (watts or joules)
local function amount(s)
	if type(s) == "number" then return s end
	local n, p = tostring(s):match("^%s*([%d%.]+)%s*(%a?)[WJ]%s*$")
	return n and tonumber(n) * (PREFIX[p] or 1) or nil
end

--- a rate for the text: three significant digits, no trailing zeros
local function fmt(x)
	local s = x >= 100 and string.format("%.0f", x) or string.format("%.3g", x)
	return s
end

local function fluid_of(box)
	return box and box.filter and data.raw.fluid[box.filter]
end

--- the items that place an entity, and whether one of them comes in the steam age
local placers = {}
for _, kind in pairs({ "item", "item-with-entity-data" }) do
	for name, it in pairs(data.raw[kind] or {}) do
		if it.place_result then
			placers[it.place_result] = placers[it.place_result] or {}
			table.insert(placers[it.place_result], name)
		end
	end
end
local recipe_techs = {}
for tname, t in pairs(data.raw.technology) do
	if t.enabled ~= false and not t.hidden then
		for _, e in pairs(t.effects or {}) do
			if e.type == "unlock-recipe" then
				recipe_techs[e.recipe] = recipe_techs[e.recipe] or {}
				table.insert(recipe_techs[e.recipe], t)
			end
		end
	end
end
local function red_only(t)
	for _, i in pairs(t.unit and t.unit.ingredients or {}) do
		if (i[1] or i.name) ~= "automation-science-pack" then return false end
	end
	return true
end
local function steam_age(entity)
	for _, item in pairs(placers[entity] or {}) do
		for name, r in pairs(data.raw.recipe) do
			if not r.hidden then
				for _, res in pairs(r.results or {}) do
					if res.name == item then
						if r.enabled ~= false and not recipe_techs[name] then return true end
						for _, t in pairs(recipe_techs[name] or {}) do if red_only(t) then return true end end
					end
				end
			end
		end
	end
	return false
end

--- 1. boilers
for name, b in pairs(data.raw.boiler or {}) do
	local out, input = fluid_of(b.output_fluid_box), fluid_of(b.fluid_box)
	local watts = amount(b.energy_consumption)
	if out and STEAM[out.name] and watts and b.target_temperature then
		local heat = amount(out.heat_capacity or "1kJ")
		local from = input and input.default_temperature or 15
		local rate = watts / (heat * (b.target_temperature - from))
		FORK_STEAM_RATES[name] = { kind = "boiler", type = "boiler", fluid = out.name, rate = rate }
	end
end

--- 2. machines with a fixed recipe that makes steam (the lava and solar boilers)
local solar = {}
local md = data.raw["mod-data"] and data.raw["mod-data"]["fork-solar-boilers"]
for _, n in pairs(md and md.data.names or {}) do solar[n] = true end
for name, m in pairs(data.raw["assembling-machine"] or {}) do
	local r = m.fixed_recipe and data.raw.recipe[m.fixed_recipe]
	if r then
		for _, res in pairs(r.results or {}) do
			if res.type == "fluid" and STEAM[res.name] and res.amount then
				local rate = res.amount / ((r.energy_required or 0.5) / (m.crafting_speed or 1))
				FORK_STEAM_RATES[name] = { kind = solar[name] and "solar" or "boiler", type = "assembling-machine", fluid = res.name,
					rate = rate }
			end
		end
	end
end

--- 3. machines that burn steam
local small = FORK_STEAM_RATES[SMALL_BOILER]
for kind, list in pairs(data.raw) do
	for name, e in pairs(list) do
		local src = type(e) == "table" and e.energy_source
		if type(src) == "table" and e.type == kind and src.type == "fluid" and src.burns_fluid and not FORK_STEAM_RATES[name] then
			local f = fluid_of(src.fluid_box)
			local watts, fuel = amount(e.energy_usage), f and amount(f.fuel_value)
			if f and STEAM[f.name] and watts and fuel and fuel > 0 then
				local rate = watts / (fuel * (src.effectivity or 1))
				local entry = { kind = "uses", type = kind, fluid = f.name, rate = rate }
				if f.name == "steam" and small and steam_age(name) then entry.boilers = rate / small.rate end
				FORK_STEAM_RATES[name] = entry
			end
		end
	end
end

--- the descriptions: the entity's and those of the items that place it (issue #564's first version reached the item
--- of the same name only, which a placed machine's tooltip does not show). An item without a description of its own
--- keeps showing the entity's.
for name, s in pairs(FORK_STEAM_RATES) do
	local fluid = { "fluid-name." .. s.fluid }
	local line
	if s.kind == "uses" and s.boilers then
		line = { "fork-steam.uses-boilers", fmt(s.rate), fluid, fmt(s.boilers) }
	elseif s.kind == "uses" then
		line = { "fork-steam.uses", fmt(s.rate), fluid }
	elseif s.kind == "solar" then
		line = { "fork-steam.produces-by-day", fmt(s.rate), fluid }
	else
		line = { "fork-steam.produces", fmt(s.rate), fluid }
	end
	local e = data.raw[s.type][name]
	local entity_desc = e.localised_description or { "entity-description." .. name }
	e.localised_description = { "?", { "", entity_desc, "\n", line }, line }
	for _, item in pairs(placers[name] or {}) do
		local it = data.raw.item[item] or data.raw["item-with-entity-data"][item]
		local item_desc = it.localised_description or { "item-description." .. item }
		it.localised_description = { "?", { "", item_desc, "\n", line }, { "", entity_desc, "\n", line }, line }
	end
end
