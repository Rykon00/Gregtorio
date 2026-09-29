--------------------------------------------------------------------------------
--- MANUAL LABOR BURNER USAGE
--- Buildings powered by "manual labor" (Crafting Table, ...) used the vanilla fuel
--- burner usage: the empty slot showed the gas pump and the status said "No fuel".
--- This burner usage shows the fist instead (icons from tools/gen_ui_icons.py).
--------------------------------------------------------------------------------

data:extend({
	{
		type = "burner-usage",
		name = "manual-labor",
		empty_slot_sprite = {
			filename = "__gregtorio-continued__/graphics/icons/fork/empty-manual-labor-slot.png",
			priority = "extra-high-no-scale",
			size = 64,
			flags = { "gui-icon" },
		},
		empty_slot_caption = { "gui.fork-manual-labor" },
		empty_slot_description = { "gui.fork-manual-labor-description" },
		icon = {
			filename = "__gregtorio-continued__/graphics/icons/fork/manual-labor-icon-red.png",
			priority = "extra-high-no-scale",
			width = 64,
			height = 64,
			flags = { "icon" },
		},
		no_fuel_status = { "entity-status.fork-no-manual-labor" },
		accepted_fuel_key = "description.accepted-fuel",
		burned_in_key = "burned-in",
	},
})

local function uses_manual_labor(es)
	if not (es and es.type == "burner") then return false end
	if es.fuel_category == "manual-labor" then return true end
	for _, c in pairs(es.fuel_categories or {}) do
		if c == "manual-labor" then return true end
	end
	return false
end

for t, _ in pairs(defines.prototypes.entity) do
	for _, e in pairs(data.raw[t] or {}) do
		for _, key in pairs({ "energy_source", "burner" }) do
			if uses_manual_labor(e[key]) and not e[key].burner_usage then
				e[key].burner_usage = "manual-labor"
				log("FORK-MANUAL-LABOR: " .. e.name)
			end
		end
	end
end
