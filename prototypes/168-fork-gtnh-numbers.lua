--------------------------------------------------------------------------------
--- FORK GTNH NUMBERS (issue #689)
--- Gregtorio's recipes are written per issue from GT's source and by generators (143's casts, 155's ore chain, 158's
--- parts) that follow GT's formulas only roughly, so 3,307 of the 10,016 recipes that have a GT New Horizons recipe with
--- the same items in and out had other numbers (`devcheck.py gtnh-diff`, #679). prototypes/data/gtnh-numbers.lua holds
--- GT's numbers of those recipes, written by `devcheck.py check --gtnh-numbers` from the recipe dump of tools/gtnh_dump/
--- through tools/gtnh_map.py; this file sets them, in Gregtorio's units:
---   t   the tier from GT's EU/t (ULV counts as LV): the recipe moves into the category of that tier of its machine,
---       where a machine runs it (every higher machine of the kind runs it as well); issue #724, the maintainer's
---       decision: also upward, at GT's tier's speed, and the recipe's unlock moves behind the first technology after
---       that tier's machine (`unlock_behind_machine` below); the blast furnace's tier is its coil heat (#620)
---   e   energy_required: GT's seconds x the speed of the tier (Gregtorio's rule, so a machine of the recipe's tier takes
---       GT's time), x the batch when the recipe is several GT recipes at once (16 rods -> 64 bolts)
---   i   the item ingredients, o the item results per chance (GT gives an item once sure and once by chance as two
---       results)
---   fi, fo  the fluid ingredients and results, a tenth of GT's litres (issue #671; also where a map of Gregtorio's
---       used GT's litres, the naquadah cracking and its distillation, or a gas variant of 144 its own amount)
--- Left out (tools/gtnh_map.py, NUMBERS_SKIP_MAPS): the crafting table's recipes (GT's tools merge recipes with and
--- without a tool, #688), 157's recycling (GT's formulas on Gregtorio's own recipes, the decision on #190) and the
--- fusion reactor (#32's plasma balance). devcheck's `check` fails for a recipe with a GT recipe whose numbers in this scope differ from
--- GT's and that neither the table nor FORK_GTNH_NUMBERS_KEPT names, and for a table that is not what `--gtnh-numbers`
--- writes. Loads after every file that makes recipes (after 157) and before 150, 196, 197, 198 and 199.
--------------------------------------------------------------------------------

local DATA = require("prototypes.data.gtnh-numbers")
local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }

--- recipes that keep their own numbers, with the reason (devcheck fails for an entry without one or for a recipe without
--- a GT recipe of other numbers; `--gtnh-numbers` leaves them out of the table)
FORK_GTNH_NUMBERS_KEPT = FORK_GTNH_NUMBERS_KEPT or {}
for _, cable in pairs({ "niobium-titanium", "vanadium-gallium", "naquadah", "naquadah-alloy", "bedrockium", "draconium",
	"fluxed-electrum", "lumiium", "nether-star", "quantium" }) do
	FORK_GTNH_NUMBERS_KEPT[cable .. "-cable"] = "issue #690: GT insulates one wire in the assembler's cable map with rubber "
		.. "or a pulp; Gregtorio's cable recipe takes 4 wires and its foils, the cable map is #690's"
end

--- issue #724: recipes that keep their tier below GT's (all their other numbers are GT's), with the reason: Gregtorio
--- needs their product before the machine of GT's tier (devcheck fails for an entry without a reason or that GT does not
--- run in a higher tier; `--gtnh-numbers` writes no tier for them)
FORK_GTNH_TIER_KEPT = FORK_GTNH_TIER_KEPT or {}
--- (generated from the unlock check of #724: a recipe whose product a recipe needs at that technology, before GT's tier's
--- machine, with no other maker there; the universium parts make the UXV components the UXV machines need)
for name, why in pairs({
	["vibrant-crystal"] = "issues #724/#714: the merged NEI dump gives GT's IV tier, but ender-crystal and the EV Extreme Entity Crusher take it with production science, before the IV machines",
	["dracofinium-ingot"] = "issue #724: GT runs it at UEV, but UEV Energy Hatches takes it and the UEV vacuum freezer needs that hatch",
	["chromnorox-ingot"] = "issue #724: GT runs it at UIV, but UIV Energy Hatches takes it and the UIV vacuum freezer needs that hatch",
	["hypocosmium-ingot"] = "issue #724: GT runs it at UMV, but UMV Energy Hatches takes it and the UMV vacuum freezer needs that hatch",
	["triamerotronium-ingot"] = "issue #724: GT runs it at UHV, but UHV Multiblocks takes it before the UHV vacuum freezer",
	["palladium-naqindium-dust"] = "issue #724: GT runs it at ZPM, but ZPM Superconductors takes it before the ZPM mixer",
	["naquamiridium-ingot"] = "issue #724: GT runs it at UV, but UV Multiblocks takes it before the UV vacuum freezer",
	["palladium-naqindium-ingot"] = "issue #724: GT runs it at ZPM, but ZPM Superconductors takes it before the ZPM vacuum freezer",
	["adamantium-alloy-nugget-maceration"] = "issue #724: GT runs it at ZPM, but Precise Electronic Unit Mk2 takes its tiny piles before the ZPM macerator",
	["benzene-from-wood-tar"] = "issue #724: GT runs it at MV, but benzene-cell takes its benzene with gas-turbine, before the MV machine",
	["ethanol-to-ethylene"] = "issue #724: GT runs it at MV, but sulfuric-acid-concentration takes its diluted-sulfuric-acid with sulfuric-acid, before the MV machine",
	["fine-universium-wire"] = "issue #724: GT runs it at UXV, but temporal-processing-unit takes its fine-universium-wire with temporal-processors, before the UXV machine",
	["large-universium-gear"] = "issue #724: GT runs it at UXV, but uxv-piston takes its large-universium-gear with uxv-components, before the UXV machine",
	["long-universium-rod"] = "issue #724: GT runs it at UXV, but uxv-motor takes its long-universium-rod with uxv-components, before the UXV machine",
	["melt-antimony-ingot"] = "issue #724: GT runs it at MV, but solidify-antimony-ingot takes its molten-antimony with soldering-alloy, before the MV machine",
	["melt-brass-ingot"] = "issue #724: GT runs it at MV, but solidify-brass-ingot takes its molten-brass with circuit-assembler, before the MV machine",
	["melt-cobalt-brass-ingot"] = "issue #724: GT runs it at MV, but solidify-cobalt-brass-ingot takes its molten-cobalt-brass with cobalt-brass, before the MV machine",
	["melt-cupronickel-ingot"] = "issue #724: GT runs it at MV, but solidify-cupronickel-ingot takes its molten-cupronickel with electric-blast-furnace, before the MV machine",
	["melt-invar-ingot"] = "issue #724: GT runs it at MV, but solidify-invar-ingot takes its molten-invar with invar, before the MV machine",
	["melt-nickel-ingot"] = "issue #724: GT runs it at MV, but solidify-nickel-ingot takes its molten-nickel with invar, before the MV machine",
	["melt-realgar-ingot"] = "issue #724: GT runs it at MV, but solidify-realgar-ingot takes its molten-realgar with primitive-electronic-circuit-assemblies, before the MV machine",
	["melt-silver-ingot"] = "issue #724: GT runs it at MV, but solidify-silver-ingot takes its molten-silver with galena, before the MV machine",
	["melt-steel-ingot"] = "issue #724: GT runs it at MV, but solidify-steel-ingot takes its molten-steel with concrete, before the MV machine",
	["melt-thorium-ingot"] = "issue #724: GT runs it at MV, but solidify-thorium-ingot takes its molten-thorium with ore-centrifuging, before the MV machine",
	["melt-zinc-ingot"] = "issue #724: GT runs it at MV, but solidify-zinc-ingot takes its molten-zinc with concrete, before the MV machine",
	["molten-glass"] = "issue #724: GT runs it at MV, but glass-fluid-solidifier takes its molten-glass with concrete, before the MV machine",
	["ruby-juice"] = "issue #724: GT runs it at HV, but ruby-juice-centrifuging takes its ruby-juice with ruby-juice, before the HV machine",
	["solidify-universium-ring"] = "issue #724: GT runs it at UXV, but uxv-motor takes its universium-ring with uxv-components, before the UXV machine",
	["universium-foil"] = "issue #724: GT runs it at UXV, but temporal-printed-circuit-board takes its universium-foil with temporal-processors, before the UXV machine",
	["universium-frame"] = "issue #724: GT runs it at UXV, but temporal-processor-mainframe takes its universium-frame with temporal-processor-mainframes, before the UXV machine",
	["universium-gear"] = "issue #724: GT runs it at UXV, but uxv-piston takes its universium-gear with uxv-components, before the UXV machine",
	["universium-ingot"] = "issue #724: GT runs it at UXV, but universium-wire takes its universium-ingot with uxv-materials, before the UXV machine",
	["universium-plate"] = "issue #724: GT runs it at UXV, but temporal-processor-supercomputer takes its universium-plate with temporal-processors, before the UXV machine",
	["universium-rod"] = "issue #724: GT runs it at UXV, but uxv-piston takes its universium-rod with uxv-components, before the UXV machine",
	["universium-rotor"] = "issue #724: GT runs it at UXV, but uxv-pump takes its universium-rotor with uxv-components, before the UXV machine",
	["universium-screw"] = "issue #724: GT runs it at UXV, but uxv-pump takes its universium-screw with uxv-components, before the UXV machine",
}) do FORK_GTNH_TIER_KEPT[name] = why end

--- (issue #759: own_time, the energy_required a recipe had before this file set the table's, for devcheck's
--- `--gtnh-numbers`: a recipe of a higher GT tier written for that tier keeps GT's tier's speed)
FORK_GTNH_NUMBERS = { recipes = 0, tiers = 0, times = 0, amounts = 0, missing = {}, own_time = {}, raised = {},
	raised_from = {}, moved_unlocks = 0 }

local function tier_of(category)
	for _, t in pairs(TIERS) do
		if category:sub(1, #t + 1) == t .. "-" then return t end
	end
	return nil
end

local function is_item(x)
	return (x.type or "item") == "item"
end

for name, n in pairs(DATA) do
	local r = data.raw.recipe[name]
	if not r then
		FORK_GTNH_NUMBERS.missing[#FORK_GTNH_NUMBERS.missing + 1] = name
	elseif not FORK_GTNH_NUMBERS_KEPT[name] then
		FORK_GTNH_NUMBERS.recipes = FORK_GTNH_NUMBERS.recipes + 1
		if n.t then
			local cat = fork_category(r)
			local cur = tier_of(cat)
			local new = cur and (n.t .. cat:sub(#cur + 1))
			local up = 0
			for i, t in ipairs(TIERS) do
				if t == cur then up = up - i elseif t == n.t then up = up + i end
			end
			if new and new ~= cat and data.raw["recipe-category"][new] and not (up > 0 and FORK_GTNH_TIER_KEPT[name]) then
				fork_set_category(r, new)
				FORK_GTNH_NUMBERS.tiers = FORK_GTNH_NUMBERS.tiers + 1
				if up > 0 then FORK_GTNH_NUMBERS.raised[name], FORK_GTNH_NUMBERS.raised_from[name] = new, cat end
			end
		end
		if n.e and r.energy_required ~= n.e then
			FORK_GTNH_NUMBERS.own_time[name] = r.energy_required or 0.5
			r.energy_required = n.e
			FORK_GTNH_NUMBERS.times = FORK_GTNH_NUMBERS.times + 1
		end
		if n.i then
			for _, x in pairs(r.ingredients or {}) do
				if is_item(x) and n.i[x.name] then x.amount = n.i[x.name] end
			end
		end
		--- (issue #671: the fluids, a tenth of GT's litres)
		for _, x in pairs(n.fi and r.ingredients or {}) do
			if x.type == "fluid" and n.fi[x.name] then x.amount = n.fi[x.name] end
		end
		for _, x in pairs(n.fo and r.results or {}) do
			if x.type == "fluid" and n.fo[x.name] then x.amount, x.amount_min, x.amount_max = n.fo[x.name], nil, nil end
		end
		if n.o then
			-- (an item's results are GT's stacks in its place: a sure one and one per chance)
			local stacks = {}
			for _, s in pairs(n.o) do
				stacks[s[1]] = stacks[s[1]] or {}
				table.insert(stacks[s[1]], s)
			end
			local results, done = {}, {}
			for _, x in pairs(r.results or {}) do
				if is_item(x) and stacks[x.name] then
					if not done[x.name] then
						done[x.name] = true
						for _, s in pairs(stacks[x.name]) do
							local res = table.deepcopy(x)
							res.amount, res.amount_min, res.amount_max = s[2], nil, nil
							res.probability, res.independent_probability = nil, s[3]
							results[#results + 1] = res
						end
					end
				else
					results[#results + 1] = x
				end
			end
			-- (a recipe of one result that now has two needs a main product or an icon)
			if #results > 1 and #(r.results or {}) == 1 and not (r.main_product or r.icon or r.icons) then
				r.main_product = r.results[1].name
			end
			r.results = results
			FORK_GTNH_NUMBERS.amounts = FORK_GTNH_NUMBERS.amounts + 1
		end
	end
end
--- issue #724: a recipe moved to a higher tier comes with the first technology after a machine of its new category
--- and after its old technologies (a recipe there from the start: with that machine); the unlock tree check (#252)
--- says what that pushes later
local techs_of, ancestors_of, machine_techs_of = {}, {}, {}
for tname, t in pairs(data.raw.technology) do
	for _, e in pairs(t.effects or {}) do
		if e.type == "unlock-recipe" then
			techs_of[e.recipe] = techs_of[e.recipe] or {}
			table.insert(techs_of[e.recipe], tname)
		end
	end
end
local function ancestors(tname)
	if ancestors_of[tname] then return ancestors_of[tname] end
	local out, todo = {}, { tname }
	while #todo > 0 do
		local t = data.raw.technology[table.remove(todo)]
		for _, p in pairs(t and t.prerequisites or {}) do
			if not out[p] then out[p] = true todo[#todo + 1] = p end
		end
	end
	ancestors_of[tname] = out
	return out
end
--- the technologies of the recipes that make a machine of the category (an empty list with `free`: one is there from the
--- start)
local makers_of = {}
for rname, r in pairs(data.raw.recipe) do
	for _, x in pairs(r.results or {}) do
		if (x.type or "item") == "item" then
			makers_of[x.name] = makers_of[x.name] or {}
			table.insert(makers_of[x.name], rname)
		end
	end
end
local function machine_techs(category)
	if machine_techs_of[category] then return machine_techs_of[category].list, machine_techs_of[category].free end
	local out, free = {}, false
	for _, kind in pairs({ "assembling-machine", "furnace" }) do
		for ename, e in pairs(data.raw[kind] or {}) do
			local runs = false
			for _, c in pairs((FORK_MACHINES_NOT_FIRST or {})[ename] and {} or e.crafting_categories or {}) do
				if c == category then runs = true end
			end
			for iname, it in pairs(runs and data.raw.item or {}) do
				if it.place_result == ename then
					for _, rname in pairs(makers_of[iname] or {}) do
						local mr = data.raw.recipe[rname]
						if not mr.hidden and not rname:find("^recycling%-") then
							if mr.enabled ~= false then free = true end
							for _, t in pairs(techs_of[rname] or {}) do out[#out + 1] = t end
						end
					end
				end
			end
		end
	end
	machine_techs_of[category] = { list = out, free = free }
	return out, free
end
local function after_all(groups)
	local best, best_n
	for tname, t in pairs(data.raw.technology) do
		if not t.hidden and t.enabled ~= false then
			local a, ok = ancestors(tname), true
			for _, g in pairs(groups) do
				local hit = false
				for _, x in pairs(g) do
					if x == tname or a[x] then hit = true break end
				end
				if not hit then ok = false break end
			end
			if ok then
				local n = 0
				for _ in pairs(a) do n = n + 1 end
				if not best or n < best_n or (n == best_n and tname < best) then best, best_n = tname, n end
			end
		end
	end
	return best
end
local function remove_unlock(tname, recipe)
	local t, keep = data.raw.technology[tname], {}
	for _, e in pairs(t.effects or {}) do
		if not (e.type == "unlock-recipe" and e.recipe == recipe) then keep[#keep + 1] = e end
	end
	t.effects = keep
end
local raised = {}
for name in pairs(FORK_GTNH_NUMBERS.raised) do raised[#raised + 1] = name end
table.sort(raised)
for _, name in pairs(raised) do
	local r, cat = data.raw.recipe[name], FORK_GTNH_NUMBERS.raised[name]
	local list, free = machine_techs(cat)
	local machine = {}
	for _, t in pairs(list) do machine[t] = true end
	local own = techs_of[name] or {}
	--- (a recipe no technology unlocks yet gets its technology later, from 199's auto-unlock or 158's routes, after its
	--- inputs: left alone)
	local fine = free or #own > 0 or r.enabled == false
	for _, t in pairs(free and {} or own) do
		if not machine[t] then
			local hit = false
			for m in pairs(machine) do if ancestors(t)[m] then hit = true break end end
			if not hit then fine = false end
		end
	end
	if not fine and next(machine) then
		local groups = { list }
		if #own > 0 then groups[2] = own end
		local tech = after_all(groups)
		if tech then
			for _, t in pairs(own) do remove_unlock(t, name) end
			r.enabled = false
			fork_add_unlock(tech, name)
			techs_of[name] = { tech }
			FORK_GTNH_NUMBERS.moved_unlocks = FORK_GTNH_NUMBERS.moved_unlocks + 1
		else
			log("FORK-GTNH-NUMBERS: no technology after the machine of " .. cat .. " for " .. name)
		end
	end
end
table.sort(FORK_GTNH_NUMBERS.missing)
local n_raised = #raised
--- (issue #724: for the migration of old saves, migrations/2026-11-01-issue-724-tier-raises.lua: a machine of the old
--- category loses such a recipe when the map loads)
local moved = {}
for _, name in pairs(raised) do
	moved[name] = { from = FORK_GTNH_NUMBERS.raised_from[name], to = FORK_GTNH_NUMBERS.raised[name] }
end
data:extend({ { type = "mod-data", name = "fork-gtnh-raised", data = { recipes = moved } } })
log("FORK-GTNH-NUMBERS-RAISED: " .. table.concat(raised, ","))
log("FORK-GTNH-NUMBERS: " .. FORK_GTNH_NUMBERS.recipes .. " recipes with GT's numbers (" .. FORK_GTNH_NUMBERS.tiers
	.. " tiers, " .. n_raised .. " of them up with " .. FORK_GTNH_NUMBERS.moved_unlocks .. " unlocks moved, " .. FORK_GTNH_NUMBERS.times .. " times), " .. #FORK_GTNH_NUMBERS.missing .. " of the table missing: "
	.. table.concat(FORK_GTNH_NUMBERS.missing, ", "))
