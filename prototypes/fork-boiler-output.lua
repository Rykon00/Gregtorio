--------------------------------------------------------------------------------
--- FORK BOILER OUTPUT (issue #593): the startup setting gregtorio-continued-boiler-output (default 1, GT New Horizons'
--- numbers) makes every steam boiler bigger, not more efficient: its steam per second and its fuel per second rise by the
--- same factor, steam per fuel stays GT New Horizons'. Required from data-final-fixes.lua after every file that makes or
--- changes a boiler and before prototypes/fork-steam-rates.lua, whose descriptions then show the multiplied steam.
---   * a `boiler` that makes steam or superheated steam from a burner or a burnt fluid (the Small and Large Coal Boiler,
---     the Large Bronze and Large Steel Boiler, the Large Titanium Boiler of 145, the base game's boiler):
---     energy_consumption times the factor; target temperature and effectivity stay, so the steam per joule does too;
---   * a machine with a fixed recipe that makes steam (101's lava and solar boilers): the recipe's steam and its fluid
---     ingredients (water, lava) times the factor, the time unchanged, set on the grid of 2^-24 with 197's rule (a factor
---     such as 1.5 can take an amount off it); the solar boilers' steam by day the same, they stop at night as before;
---   * left out: a `boiler` heated by another entity's heat (the base game's heat exchanger: its power comes from the
---     reactor) and a machine without a fixed recipe whose recipes all make steam (145's Large Heat Exchanger: hot coolant
---     from the Fluid Nuclear Reactor), since their steam is the reactor chain's.
--- FORK_BOILER_OUTPUT (factor, changed: entity -> kind, left_out: entity -> reason) is devcheck's section
--- BOILEROUTPUT.
--------------------------------------------------------------------------------

local STEAM = { steam = true, ["superheated-steam"] = true }
local FACTOR = settings.startup["gregtorio-continued-boiler-output"].value
FORK_BOILER_OUTPUT = { factor = FACTOR, changed = {}, left_out = {} }

local PREFIX = { [""] = 1, k = 1e3, K = 1e3, M = 1e6, G = 1e9, T = 1e12, P = 1e15, E = 1e18 }
--- "36kW" -> 36000
local function watts(s)
	if type(s) == "number" then return s end
	local n, p = tostring(s):match("^%s*([%d%.]+)%s*(%a?)W%s*$")
	return n and tonumber(n) * (PREFIX[p] or 1) or nil
end

--- 1. boilers
for name, b in pairs(data.raw.boiler or {}) do
	local out = b.output_fluid_box and b.output_fluid_box.filter
	local src = b.energy_source and b.energy_source.type
	local w = watts(b.energy_consumption)
	if out and STEAM[out] then
		if src == "burner" or src == "fluid" then
			if w then
				if FACTOR ~= 1 then b.energy_consumption = string.format("%.17gW", w * FACTOR) end
				FORK_BOILER_OUTPUT.changed[name] = "boiler"
			else
				FORK_BOILER_OUTPUT.left_out[name] = "energy_consumption " .. tostring(b.energy_consumption) .. " not read"
			end
		else
			FORK_BOILER_OUTPUT.left_out[name] = "heated by another entity (" .. tostring(src) .. "), the reactor chain's steam"
		end
	end
end

--- 2. machines with a fixed recipe that makes steam (the lava and solar boilers)
for name, m in pairs(data.raw["assembling-machine"] or {}) do
	local r = m.fixed_recipe and data.raw.recipe[m.fixed_recipe]
	local makes_steam = false
	for _, res in pairs(r and r.results or {}) do
		if res.type == "fluid" and STEAM[res.name] then makes_steam = true end
	end
	if makes_steam then
		if FACTOR ~= 1 then
			for _, i in pairs(r.ingredients or {}) do
				if i.type == "fluid" then
					i.amount = i.amount * FACTOR
					FORK_FLUID_STEPS.round_up(i, "amount", false)
				end
			end
			for _, res in pairs(r.results or {}) do
				if res.type == "fluid" then
					res.amount = res.amount * FACTOR
					FORK_FLUID_STEPS.round_up(res, "amount", true)
				end
			end
		end
		FORK_BOILER_OUTPUT.changed[name] = "fixed recipe " .. r.name
	end
end

--- 3. a machine whose recipes all make steam but that has no fixed recipe stays: the Large Heat Exchanger of 145 (one pass
--- over the recipes, then the machines of their categories; a machine with other recipes that give steam as one product
--- among others, a chemical reactor, is no boiler)
local steam_cats = {}   -- category -> a recipe that makes steam, or false when one of its recipes does not
for rname, r in pairs(data.raw.recipe) do
	local steam = false
	for _, res in pairs(r.results or {}) do
		if res.type == "fluid" and STEAM[res.name] then steam = true end
	end
	for _, cat in pairs(r.categories or { "crafting" }) do
		if not steam then steam_cats[cat] = false
		elseif steam_cats[cat] == nil then steam_cats[cat] = rname end
	end
end
for name, m in pairs(data.raw["assembling-machine"] or {}) do
	if not FORK_BOILER_OUTPUT.changed[name] then
		for _, cat in pairs(m.crafting_categories or {}) do
			if steam_cats[cat] then
				FORK_BOILER_OUTPUT.left_out[name] = "makes steam from a recipe of its choice (" .. steam_cats[cat] .. "), not a boiler"
			end
		end
	end
end

local function count(t) local n = 0 for _ in pairs(t) do n = n + 1 end return n end
log("FORK-BOILER-OUTPUT: factor " .. FACTOR .. ", " .. count(FORK_BOILER_OUTPUT.changed) .. " boilers changed, "
	.. count(FORK_BOILER_OUTPUT.left_out) .. " left out (issue #593)")
