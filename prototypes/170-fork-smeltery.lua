--------------------------------------------------------------------------------
--- FORK SMELTERY (issue #613 part 3, the maintainer's decision of 2026-10-30): a Tinkers-like path before GT's mold
--- (glassmaking), as GT New Horizons' steam age has Tinkers' Construct's smeltery, casting table and tool station.
---   * Smeltery (burns coal or charcoal): melts the crushed ores and dusts of copper, tin, iron, gold and lead and bronze
---     dust into their melts, an ingot's worth each (14.4, GT's 144 L; no ore doubling), 5 s.
---   * Casting Table (no power): pours a melt into a single-use clay cast: ingots and plates (an ingot's worth) and, for
---     iron and bronze, GT's tool heads with GT's masses (OrePrefixes.java: hammer head 6 ingots, file head 2, saw blade
---     2, screwdriver tip 1, wrench head 4), 1 s per ingot's worth.
---   * Tool Station (no power): a tool head and a stick give #612's charges of that tool and material
---     (148: 100 x the material's tool durability / the damage of a crafting use), without the other tools #612's crafting
---     table recipe uses up. GT has no head of the knife and the wire cutter: those stay #612's recipes.
---   Clay casts: 4 clay balls each, by hand. The three machines are Gregtorio's (Tinkers' recipes are not in GT's dump):
---   the smeltery from 12 brick blocks, a stone furnace and 2 pipes; the casting table from 4 brick blocks; the tool
---   station from 5 logs and 2 iron plates. Sprites: tools/gen_sprites.py (smeltery).
---   Unlocks: 155's unlock_after (after the machine and every input).
--- Loaded after 158 and 164 (the parts) and before 157.
--------------------------------------------------------------------------------

local OC = FORK_ORE_CHAIN
local SPRITE = "__gregtorio-continued__/graphics/entity/"
local ICON = "__gregtorio-continued__/graphics/icons/"

local function item(name, amount) return { type = "item", name = name, amount = amount or 1 } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

--- a 3x3 steam age machine of category `category` with its sprite pair (graphics/entity/<name>/<name>-idle.png)
local function machine(name, category, energy_source, energy, ports)
	recipe_category_and_subgroup(category)
	make_steam_machine(name, name, category, "fr-" .. name, energy, 1, 0.5)
	local e = data.raw["assembling-machine"][name]
	e.crafting_speed = 1
	e.energy_source = energy_source
	e.fluid_boxes = ports
	e.fluid_boxes_off_when_no_fluid_recipe = ports ~= nil
	e.icon = ICON .. name .. ".png"
end

--- the technologies of every recipe that makes an item now (155's list misses recipes of later files, as this file's
--- melts and the stick's crafting table recipe); nil: from the start
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
local MACHINE = { ["smeltery-recipes"] = "smeltery", ["casting-table-recipes"] = "casting-table",
	["tool-station-recipes"] = "tool-station" }
--- unlocked after its machine and every input (155); `extra`: further items it waits for (a machine: its first recipe's)
local function unlock(name, category, extra)
	local r = data.raw.recipe[name]
	local groups = { category and item_techs(MACHINE[category]) or nil }
	for _, i in pairs(r.ingredients) do groups[#groups + 1] = item_techs(i.name) end
	for _, x in pairs(extra or {}) do groups[#groups + 1] = item_techs(x) end
	if not OC.unlock_after(name, groups) then log("FORK-SMELTERY: no technology for " .. name) end
end
local function recipe(list, name, category, seconds, ingredients, results)
	create_recipe{ recipe_name = name, category = category, energy_required = seconds, ingredients = ingredients,
		results = results, main_product = results[1].name, subgroup = "subgroup-" .. category }
	list[#list + 1] = name
end

--------------------------------------------------------------------------------
--- the machines, the casts and the heads
--------------------------------------------------------------------------------
machine("smeltery", "smeltery-recipes",
	{ type = "burner", fuel_categories = { "chemical" }, effectivity = 1, fuel_inventory_size = 1,
		emissions_per_minute = { pollution = 4 } }, "90kW",
	{ fluid_port(0, -1, "output", defines.direction.north) })
machine("casting-table", "casting-table-recipes", { type = "void" }, "1kW",
	{ fluid_port(0, -1, "input", defines.direction.north) })
machine("tool-station", "tool-station-recipes", { type = "void" }, "1kW", nil)
for name, ingredients in pairs({
	smeltery = { item("brick-block", 12), item("stone-furnace"), item("pipe", 2) },
	["casting-table"] = { item("brick-block", 4) },
	["tool-station"] = { item("wood", 5), item("iron-plate", 2) },
}) do
	create_item{ name = name, subgroup = "steam-age-production-machine", place_result = name, stack_size = 10,
		ingredients = ingredients }
end

local INGOT = 14.4
local METALS = { "copper", "tin", "iron", "gold", "lead", "bronze" }
local HEADS = {   -- GT's tool head, its ingots, #612's tool and the damage of a crafting use
	{ "hammer-head", 6, "hammer", 400 }, { "file-head", 2, "file", 400 }, { "saw-blade", 2, "saw", 200 },
	{ "screwdriver-tip", 1, "screwdriver", 400 }, { "wrench-head", 4, "wrench", 800 },
}
local DURABILITY = { iron = 256, bronze = 192 }
for _, shape in pairs({ "ingot", "plate", "hammer-head", "file-head", "saw-blade", "screwdriver-tip", "wrench-head" }) do
	local name = "clay-" .. shape .. "-cast"
	create_item{ name = name, subgroup = "steam-age-production-machine", ingredients = { item("clay-ball", 4) } }
	unlock(name)
end
for m in pairs(DURABILITY) do
	for _, h in pairs(HEADS) do create_item{ skip_recipe = true, name = m .. "-" .. h[1], subgroup = "subgroup-tool-recipes" } end
end

--------------------------------------------------------------------------------
--- each machine with its first recipe's inputs, its recipes after it (issue #556's rule)
--------------------------------------------------------------------------------
local MELT, CAST, TOOL = {}, {}, {}
for _, m in pairs(METALS) do
	for _, form in pairs({ "crushed-" .. m, m .. "-dust" }) do
		if data.raw.item[form] then
			recipe(MELT, "smeltery-" .. form, "smeltery-recipes", 5, { item(form) }, { fluid("molten-" .. m, INGOT) })
		end
	end
	for _, form in pairs({ "ingot", "plate" }) do
		recipe(CAST, "cast-" .. m .. "-" .. form, "casting-table-recipes", 1,
			{ fluid("molten-" .. m, INGOT), item("clay-" .. form .. "-cast") }, { item(m .. "-" .. form) })
	end
end
for m, durability in pairs(DURABILITY) do
	for _, h in pairs(HEADS) do
		local head = m .. "-" .. h[1]
		recipe(CAST, "cast-" .. head, "casting-table-recipes", h[2],
			{ fluid("molten-" .. m, INGOT * h[2]), item("clay-" .. h[1] .. "-cast") }, { item(head) })
		recipe(TOOL, "tool-station-" .. h[3] .. "-" .. m, "tool-station-recipes", 2, { item(head), item("stick") },
			{ item(h[3] .. "-usage", math.floor(100 * durability / h[4])) })
	end
end
unlock("smeltery", nil, { "crushed-copper" })
for _, r in pairs(MELT) do unlock(r, "smeltery-recipes") end
unlock("casting-table", nil, { "clay-ingot-cast", "molten-copper" })
for _, r in pairs(CAST) do unlock(r, "casting-table-recipes") end
unlock("tool-station", nil, { "iron-hammer-head", "stick" })
for _, r in pairs(TOOL) do unlock(r, "tool-station-recipes") end

--- the High Pressure Steam Water Pump (101 section 2m'): after the steel frames and the bronze pump's parts
unlock("hp-steam-water-pump")
