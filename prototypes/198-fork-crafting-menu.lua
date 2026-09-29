--------------------------------------------------------------------------------
--- FORK CRAFTING MENU (issue #49)
---
--- Upstream `create_recipe` (03-helper-functions-module.lua) sets `hide_from_player_crafting`
--- on every recipe of a machine category, so the crafting menu only lists hand recipes and
--- machine-only recipes (zinc, "4x Resistor", ...) look like they do not exist. Vanilla lists
--- them too, with the red "cannot be crafted by hand" background.
---
--- This pass shows every recipe whose category has a machine again, except the recipes in
--- FORK_CRAFTING_MENU_HIDDEN below. `hidden` recipes (recycling, parameters, ...) are not
--- touched. tools/devcheck checks that nothing else stays hidden, so a new hidden recipe
--- needs an entry here.
---
--- Startup setting `gregtorio-continued-show-machine-recipes` (default on) turns it off.
--------------------------------------------------------------------------------

--- Global so tools/devcheck can dump it. Every entry: key -> reason.
FORK_CRAFTING_MENU_HIDDEN = {
	categories = {
		["fluid-voiding-recipes"] = "void-<fluid>: one trash recipe per fluid (data.lua), also hidden in Factoriopedia",
	},
	subgroups = {
		["fill-barrel"] = "vanilla barrel filling recipes, hidden in vanilla",
		["empty-barrel"] = "vanilla barrel emptying recipes, hidden in vanilla",
	},
	recipes = {
		["burner-inserter"] = "replaced vanilla recipe (09-steam-age-item.lua); the menu shows the crafting table recipe",
		["iron-chest"] = "replaced vanilla recipe (09-steam-age-item.lua); the menu shows the crafting table recipe",
		["iron-stick"] = "replaced vanilla recipe (09-steam-age-item.lua); the menu shows the crafting table recipe",
		["pipe"] = "replaced vanilla recipe (09-steam-age-item.lua); the menu shows the crafting table recipe",
		["chest"] = "replaced vanilla wooden chest recipe (09-steam-age-item.lua); the menu shows the crafting table recipe",
		["rocket-part"] = "vanilla rocket silo recipe, hidden in vanilla",
		["biter-egg"] = "vanilla captive biter spawner recipe, hidden in vanilla",
	},
}

local setting = settings.startup["gregtorio-continued-show-machine-recipes"]
if setting and not setting.value then
	log("FORK-CRAFTING-MENU: machine recipes stay hidden (startup setting off)")
	return
end

local keep = FORK_CRAFTING_MENU_HIDDEN

--- Categories that have at least one machine (the character is not a machine)
local machine_category = {}
for _, t in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
	for _, e in pairs(data.raw[t] or {}) do
		for _, c in pairs(e.crafting_categories or {}) do machine_category[c] = true end
	end
end

local function only_fluids(r)
	for _, res in pairs(r.results or {}) do
		local f = res.type == "fluid" and data.raw.fluid[res.name]
		if not f or f.subgroup then return false end
	end
	return r.results ~= nil and #r.results > 0
end

local shown, kept = 0, 0
for name, r in pairs(data.raw.recipe) do
	local category = r.category or "crafting"
	if r.hide_from_player_crafting and not r.hidden and machine_category[category] then
		if keep.categories[category] or keep.subgroups[r.subgroup or ""] or keep.recipes[name] then
			kept = kept + 1
		else
			r.hide_from_player_crafting = false
			--- recipes of a fluid without a subgroup (the ABS molten metals) would land in the
			--- default fluid subgroup; put them next to the other recipes of their machine
			if not r.subgroup and only_fluids(r) and data.raw["item-subgroup"]["subgroup-" .. category] then
				r.subgroup = "subgroup-" .. category
			end
			shown = shown + 1
		end
	end
end
log("FORK-CRAFTING-MENU: " .. shown .. " machine recipes shown in the crafting menu, " .. kept .. " kept hidden")
