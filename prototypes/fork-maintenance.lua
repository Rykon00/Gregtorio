--------------------------------------------------------------------------------
--- FORK: MAINTENANCE SLOTS (issue #618; startup setting gregtorio-continued-maintenance, default off): the slot of
--- every crafting multiblock (FORK_MAINTENANCE.multiblocks below; generators have no module slots in Factorio), one
--- more module slot of the category `maintenance` that
--- scripts/fork-maintenance.lua takes the kits of prototypes/171-fork-maintenance.lua from.
--- Required from data-final-fixes.lua after every file that makes a machine. FORK_MAINTENANCE.machines is devcheck's
--- section MAINT; the mod data `fork-maintenance` names the machines and the kits for the script.
--------------------------------------------------------------------------------

if not FORK_MAINTENANCE.on then return end

data:extend({ { type = "module-category", name = "maintenance" } })

--- the slot of every crafting multiblock (a machine that took every module now takes the categories of the modules with an
--- effect by name, and maintenance: 150's molds and lenses, modules without an effect, stay in their machines)
local every, seen = { "maintenance" }, { maintenance = true }
for _, m in pairs(data.raw.module) do
	if m.category and not seen[m.category] and next(m.effect or {}) then
		seen[m.category] = true
		every[#every + 1] = m.category
	end
end
--- the crafting multiblocks: electric assembling machines and furnaces (GT's steam multiblocks have no maintenance hatch)
--- whose item is in a `*multiblocks` subgroup or whose item's recipe takes a controller, an energy hatch or another
--- multiblock (the blast furnaces' items are in the crafting menu's subgroups; a tier takes the tier below)
function FORK_MAINTENANCE.multiblocks()
	local function machine(item)
		local it = item and data.raw.item[item]
		if not (it and it.place_result) then return nil end
		for _, t in pairs({ "assembling-machine", "furnace" }) do
			local e = data.raw[t][it.place_result]
			if e and e.energy_source and e.energy_source.type == "electric" then return e end
		end
	end
	local multi = {}
	for name, it in pairs(data.raw.item) do
		if (it.subgroup or ""):match("multiblocks$") and machine(name) then multi[name] = true end
	end
	repeat
		local more = false
		for _, r in pairs(data.raw.recipe) do
			for _, res in pairs(r.results or {}) do
				if res.type == "item" and not multi[res.name] and machine(res.name) then
					for _, ing in pairs(r.ingredients or {}) do
						if multi[ing.name] or ing.name:match("%-controller$") or ing.name:match("energy%-hatch$") then
							multi[res.name], more = true, true
							break
						end
					end
				end
			end
		end
	until not more
	local out = {}
	for item in pairs(multi) do out[machine(item).name] = true end
	return out
end

local multiblocks = FORK_MAINTENANCE.multiblocks()
for _, t in pairs({ "assembling-machine", "furnace" }) do
	for name in pairs(multiblocks) do
		local e = data.raw[t][name]
		if e and not FORK_MAINTENANCE.machines[name] then
			local had = e.module_slots or 0
			e.module_slots = had + 1
			if had == 0 then
				e.allowed_module_categories = { "maintenance" }
				--- the engine rejects module slots without any allowed effect (as 150); kits have no effect, and
				--- beacons must not start boosting these machines
				if not e.allowed_effects or #e.allowed_effects == 0 then
					e.allowed_effects = { "consumption" }
					e.effect_receiver = e.effect_receiver or {}
					e.effect_receiver.uses_beacon_effects = false
				end
			elseif not e.allowed_module_categories then
				e.allowed_module_categories = table.deepcopy(every)
			else
				table.insert(e.allowed_module_categories, "maintenance")
			end
			FORK_MAINTENANCE.machines[name] = true
		end
	end
end
local names = {}
for n in pairs(FORK_MAINTENANCE.machines) do names[#names + 1] = n end
table.sort(names)
data:extend({ { type = "mod-data", name = "fork-maintenance", data = { machines = names, kits = FORK_MAINTENANCE.kits, kit_ticks = 2 * 60 * 60 * 60 } } })
