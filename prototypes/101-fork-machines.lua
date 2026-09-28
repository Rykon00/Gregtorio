--------------------------------------------------------------------------------
--- FORK MACHINES
--- Fehlende Gebäude für EV und IV:
---   * Tier-Kategorien auffüllen (z. B. EV Fluid Solidifier kann auch MV/HV/EV-Rezepte)
---   * EV-Multiblocks, deren Item existierte, aber nicht platzierbar war
---   * IV-Grundmaschinen (Kopien der EV-Maschinen, Tier hochgeschoben)
---   * IV-Multiblocks (GT++-"Industrial"-Maschinen) aus 20-iv-age-entity.lua
--- Sprites unter graphics/entity/fork/ werden von tools/gen_sprites.py erzeugt.
--------------------------------------------------------------------------------

local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv" }
local TIER_INDEX = {}
for i, t in ipairs(TIERS) do TIER_INDEX[t] = i end

local SPRITE_PATH = "__Gregtorio__/graphics/entity/fork/"

local function tier_of(name)
	local t = name:match("^(%a+)%-")
	return t and TIER_INDEX[t] and t or nil
end

local function category_exists(c)
	return data.raw["recipe-category"][c] ~= nil
end

--- Energiewerte wie "1.28MW" skalieren
local function scale_energy(s, factor)
	local num, unit = s:match("^([%d%.]+)(%a+)$")
	local mult = { W = 1, kW = 1e3, MW = 1e6, GW = 1e9 }
	local watts = tonumber(num) * mult[unit] * factor
	if watts >= 1e9 then return string.format("%.4gGW", watts / 1e9) end
	if watts >= 1e6 then return string.format("%.4gMW", watts / 1e6) end
	return string.format("%.4gkW", watts / 1e3)
end

--- Alle vorhandenen Kategorien "<tier>-<rest>" bis einschließlich max_tier
local function tier_categories(rest, max_tier)
	local out = {}
	for i = 1, TIER_INDEX[max_tier] do
		local c = TIERS[i] .. "-" .. rest
		if category_exists(c) then table.insert(out, c) end
	end
	return out
end

local function add_unique(list, items)
	local seen = {}
	for _, v in pairs(list) do seen[v] = true end
	for _, v in pairs(items) do
		if not seen[v] then table.insert(list, v); seen[v] = true end
	end
	return list
end

--- Kategorien einer Maschine auf alle niedrigeren (und eigenen) Tiers auffüllen
local function tier_fill(categories, machine_tier)
	local result = {}
	for _, c in pairs(categories) do
		table.insert(result, c)
		local ct, rest = c:match("^(%a+)%-(.+)$")
		if ct and TIER_INDEX[ct] and TIER_INDEX[ct] <= TIER_INDEX[machine_tier] then
			add_unique(result, tier_categories(rest, machine_tier))
		end
	end
	return add_unique({}, result)
end

--- Grafik-Set aus erzeugten Sprites (idle: 1 Frame, working: vertikaler Streifen)
local function fork_graphics(sprite_name, width_px, height_px, frames)
	return {
		idle_animation = { layers = { {
			filename = SPRITE_PATH .. sprite_name .. "-idle.png",
			width = width_px, height = height_px,
			frame_count = 1, repeat_count = frames, shift = { 0, 0 },
		} } },
		animation = { layers = { {
			filename = SPRITE_PATH .. sprite_name .. "-working.png",
			width = width_px, height = height_px,
			frame_count = frames, line_length = 1, animation_speed = 0.3, shift = { 0, 0 },
		} } },
	}
end

--- Neue Maschine als Kopie einer bestehenden
---   def = { name, source, categories, crafting_speed, energy_usage, sprite = {name, frames} | nil,
---           size = {w, h} (nur ohne Fluidboxen), keep_fluids = true|false, icon }
local function clone_machine(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-MACHINE: Quelle fehlt: " .. def.source) return nil end
	local m = table.deepcopy(src)
	m.name = def.name
	m.minable = { mining_time = 0.5, result = def.name }
	m.crafting_categories = def.categories
	m.crafting_speed = def.crafting_speed or m.crafting_speed
	m.energy_usage = def.energy_usage or m.energy_usage
	m.fast_replaceable_group = def.fast_replaceable_group or m.fast_replaceable_group
	if def.icon then m.icon = def.icon; m.icon_size = 32 end
	if def.keep_fluids == false then
		m.fluid_boxes = nil
		m.fluid_boxes_off_when_no_fluid_recipe = nil
	end
	local w, h
	if def.size then
		w, h = def.size[1], def.size[2]
		m.collision_box = { { -w / 2 + 0.2, -h / 2 + 0.2 }, { w / 2 - 0.2, h / 2 - 0.2 } }
		m.selection_box = { { -w / 2, -h / 2 }, { w / 2, h / 2 } }
	else
		w = src.selection_box[2][1] - src.selection_box[1][1]
		h = src.selection_box[2][2] - src.selection_box[1][2]
	end
	if def.sprite then
		m.graphics_set = fork_graphics(def.sprite[1], w * 32, h * 32, def.sprite[2] or 1)
	end
	data:extend({ m })
	return m
end

--- Item auf eine Entity zeigen lassen (für Items mit auskommentiertem place_result)
local function set_place_result(item_name, entity_name)
	local item = data.raw.item[item_name]
	if not item then log("FORK-MACHINE: Item fehlt: " .. item_name) return end
	item.place_result = entity_name
end



--------------------------------------------------------------------------------
--- 1) TIER-KATEGORIEN AUFFÜLLEN (bestehende LV–EV-Maschinen)
---    z. B. EV Fluid Solidifier hatte nur LV-Rezepte, EV Macerator kein HV/EV
--------------------------------------------------------------------------------

for name, m in pairs(data.raw["assembling-machine"]) do
	local t = tier_of(name)
	if t and m.crafting_categories and TIER_INDEX[t] <= TIER_INDEX["ev"] then
		m.crafting_categories = tier_fill(m.crafting_categories, t)
	end
end



--- Chemical Baths hatten zwei Fluid-EINGÄNGE, aber keinen Ausgang. Alle Bath-Rezepte
--- brauchen höchstens 1 Fluid rein + 1 Fluid raus (u. a. Platin-Linie) -> zweiter Port wird Ausgang (Süden).
for name, m in pairs(data.raw["assembling-machine"]) do
	local is_bath = false
	for _, c in pairs(m.crafting_categories or {}) do
		if c:match("%-chemical%-bath%-recipes$") then is_bath = true end
	end
	if is_bath and m.fluid_boxes and #m.fluid_boxes == 2 then
		local out = m.fluid_boxes[2]
		out.production_type = "output"
		local h = m.selection_box[2][2]
		for _, pc in pairs(out.pipe_connections) do
			pc.flow_direction = "output"
			pc.direction = defines.direction.south
			pc.position = { pc.position[1], h - 0.5 }
		end
	end
end



--------------------------------------------------------------------------------
--- 2) EV-MULTIBLOCKS UND ENDER-IO-MASCHINEN (Items existierten, waren nicht platzierbar)
--------------------------------------------------------------------------------

--- ALLOY BLAST SMELTER (3x4 wie der EBF, gleiche Fluid-Ports)
clone_machine{
	name = "ev-alloy-blast-smelter", source = "ev-electric-blast-furnace",
	categories = tier_categories("alloy-blast-smelter-recipes", "ev"),
	crafting_speed = 8, energy_usage = EU16_EV,
	fast_replaceable_group = "fr-alloy-blast-smelter",
	icon = ICON_PATH .. "alloy-blast-smelter.png",
	sprite = { "ev-alloy-blast-smelter", 1 },
}
set_place_result("ev-alloy-blast-smelter", "ev-alloy-blast-smelter")

--- EXTREME ENTITY CRUSHER
clone_machine{
	name = "ev-extreme-entity-crusher", source = "ev-macerator", keep_fluids = false,
	categories = { "ev-extreme-entity-crusher-recipes" },
	crafting_speed = 1, energy_usage = EU8_EV,
	fast_replaceable_group = "fr-extreme-entity-crusher",
	icon = ICON_PATH .. "extreme-entity-crusher.png",
	sprite = { "ev-extreme-entity-crusher", 1 },
}
set_place_result("ev-extreme-entity-crusher", "ev-extreme-entity-crusher")

--- ENDER IO: Slice'n'Splice, Soul Binder, Powered Spawner
for _, n in pairs({ "slice-n-splice", "soul-binder", "powered-spawner" }) do
	clone_machine{
		name = n, source = "ev-macerator", keep_fluids = false,
		categories = { n .. "-recipes" },
		crafting_speed = 1, energy_usage = EU2_HV,
		fast_replaceable_group = "fr-" .. n,
		icon = ICON_PATH .. n .. ".png",
		sprite = { n, 1 },
	}
	set_place_result(n, n)
end

--- LARGE SIFTER (HV-Multiblock, 5x3, Grafik existiert bereits)
do
	local m = clone_machine{
		name = "hv-large-sifter", source = "ev-macerator", keep_fluids = false, size = { 5, 3 },
		categories = tier_categories("sifter-recipes", "iv"),
		crafting_speed = 4, energy_usage = EU16_HV,
		fast_replaceable_group = "fr-large-sifter",
		icon = ICON_PATH .. "large-sifter.png",
	}
	if m then
		m.graphics_set = {
			idle_animation = { layers = { { filename = "__Gregtorio__/graphics/entity/large-sifter/large-sifter-idle.png",
				width = 160, height = 96, frame_count = 1, shift = { 0, 0 } } } },
			animation = { layers = { { filename = "__Gregtorio__/graphics/entity/large-sifter/large-sifter-working.png",
				width = 160, height = 96, frame_count = 1, shift = { 0, 0 } } } },
		}
	end
	set_place_result("hv-large-sifter", "hv-large-sifter")
end



--------------------------------------------------------------------------------
--- 3) IV-GRUNDMASCHINEN
---    Kopie der EV-Maschine: doppelte Geschwindigkeit, doppelter Verbrauch,
---    IV-Kategorien dazu, Rezept = EV-Rezept mit allen Tier-Bauteilen eine Stufe höher.
--------------------------------------------------------------------------------

--- Zutat eine Tier-Stufe hochschieben (ev-motor -> iv-motor, hv-energy-hatch -> ev-energy-hatch, ...)
local SPECIAL_SHIFT = {
	["aluminium-cable"]     = "tungsten-cable",
	["platinum-cable"]      = "tungsten-cable",
	["cupronickel-coil-block"] = "kanthal-coil-block",
	["kanthal-coil-block"]  = "nichrome-coil-block",
	["nichrome-coil-block"] = "rtm-alloy-coil-block",
}
local function item_exists(n)
	for t, _ in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][n] then return true end
	end
	return false
end
local function shift_name(n)
	if SPECIAL_SHIFT[n] and item_exists(SPECIAL_SHIFT[n]) then return SPECIAL_SHIFT[n] end
	local t, rest = n:match("^(%a+)%-(.+)$")
	if t and TIER_INDEX[t] and TIERS[TIER_INDEX[t] + 1] then
		local shifted = TIERS[TIER_INDEX[t] + 1] .. "-" .. rest
		if item_exists(shifted) then return shifted end
	end
	return n
end
local function shift_list(list)
	local out = {}
	for _, i in pairs(list or {}) do
		local c = table.deepcopy(i)
		if c.type ~= "fluid" then c.name = shift_name(c.name) end
		table.insert(out, c)
	end
	return out
end

--- Maschine -> Sprite (erzeugt aus GT-Texturen) und Frames
IV_BASIC_MACHINES = {
	"wiremill", "bending-machine", "extruder", "rock-crusher", "lathe", "macerator", "centrifuge",
	"air-collector", "extractor", "electrolyzer", "assembling-machine", "cutting-machine",
	"canning-machine", "mixer", "ore-washer", "laser-engraver", "fluid-solidifier", "chemical-bath",
	"polarizer", "circuit-assembler", "autoclave", "alloy-smelter", "compressor",
}
--- Multiblocks, die als Upgrade der EV-Version kommen (gleiche Grafik wie EV)
IV_UPGRADE_MACHINES = {
	"electric-blast-furnace", "vacuum-freezer", "large-chemical-reactor", "microverse-projector",
	"tall-distillation-tower", "short-distillation-tower", "implosion-compressor", "cracker",
	"multismelter", "pyrolyse-oven", "greenhouse", "drilling-rig", "alloy-blast-smelter",
}

local iv_machine_recipes = {}

local function make_iv_machine(base, sprite)
	local ev_name, iv_name = "ev-" .. base, "iv-" .. base
	local ev = data.raw["assembling-machine"][ev_name]
	if not ev then log("FORK-MACHINE: keine EV-Maschine " .. ev_name) return end
	local categories = table.deepcopy(ev.crafting_categories)
	local extra = {}
	for _, c in pairs(categories) do
		local ct, rest = c:match("^(%a+)%-(.+)$")
		if ct and TIER_INDEX[ct] then add_unique(extra, tier_categories(rest, "iv")) end
	end
	categories = add_unique(categories, extra)

	clone_machine{
		name = iv_name, source = ev_name, categories = categories,
		crafting_speed = ev.crafting_speed * 2,
		energy_usage = scale_energy(ev.energy_usage, 2),
		sprite = sprite and { iv_name, sprite } or nil,
		icon = sprite and ("__Gregtorio__/graphics/icons/fork/" .. iv_name .. ".png") or nil,
	}

	--- Item
	local ev_item = data.raw.item[ev_name]
	local item = table.deepcopy(ev_item)
	item.name = iv_name
	item.place_result = iv_name
	item.order = (ev_item.order or "") .. "-iv"
	if item.subgroup == "ev-age-production-machine" then item.subgroup = "iv-age-production-machine" end
	if item.subgroup == "subgroup-ev-age-multiblocks" then item.subgroup = "subgroup-iv-age-multiblocks" end
	if sprite then item.icon = "__Gregtorio__/graphics/icons/fork/" .. iv_name .. ".png"; item.icon_size = 32 end
	data:extend({ item })

	--- Rezept
	local ev_recipe = data.raw.recipe[ev_name]
	local r = table.deepcopy(ev_recipe)
	r.name = iv_name
	r.enabled = false
	r.ingredients = shift_list(ev_recipe.ingredients)
	r.results = shift_list(ev_recipe.results)
	for _, res in pairs(r.results) do if res.name == ev_name then res.name = iv_name end end
	if r.main_product then r.main_product = iv_name end
	--- Upgrade-Multiblocks: die EV-Version geht rein, nicht eine IV-Version von sich selbst
	for _, ing in pairs(r.ingredients) do if ing.name == iv_name then ing.name = ev_name end end
	data:extend({ r })
	table.insert(iv_machine_recipes, iv_name)
end

data:extend({
	{ type = "item-subgroup", name = "iv-age-production-machine", group = "production", order = "i-z" },
})

for _, base in pairs(IV_BASIC_MACHINES) do make_iv_machine(base, 6) end
for _, base in pairs(IV_UPGRADE_MACHINES) do make_iv_machine(base, nil) end

for _, r in pairs(iv_machine_recipes) do fork_add_unlock("iv-machines", r) end



--------------------------------------------------------------------------------
--- 4) IV-MULTIBLOCKS (GT++ Industrial-Maschinen), Items aus 20-iv-age-entity.lua
---    Machen alle Rezepte ihrer Maschinenfamilie bis IV, doppelt so schnell wie IV.
--------------------------------------------------------------------------------

local IV_MULTIBLOCKS = {
	-- Item/Entity                          Quelle (Fluid-Ports)   Kategorien-Familie(n)
	{ "iv-industrial-maceration-stack",     "ev-macerator",        { "macerator-recipes" } },
	{ "iv-industrial-wire-factory",         "ev-wiremill",         { "wiremill-recipes" } },
	{ "iv-industrial-material-press",       "ev-bending-machine",  { "bending-machine-recipes" } },
	{ "iv-large-electric-compressor",       "ev-compressor",       { "compressor-recipes" } },
	{ "iv-magnetic-flux-exhibiter",         "ev-polarizer",        { "polarizer-recipes" } },
	{ "iv-fluid-shaper",                    "ev-fluid-solidifier", { "fluid-solidifier-recipes" } },
	{ "iv-industrial-cutting-factory",      "ev-cutting-machine",  { "cutting-machine-recipes" } },
	{ "iv-chemical-bath-plant",             "ev-chemical-bath",    { "chemical-bath-recipes" } },
	{ "iv-industrial-electrolyzer",         "ev-electrolyzer",     { "electrolyzer-recipes" } },
	{ "iv-industrial-precision-lathe",      "ev-lathe",            { "lathe-recipes" } },
	{ "iv-large-extractor",                 "ev-extractor",        { "extractor-recipes" } },
	{ "iv-hyper-intensity-laser-engraver",  "ev-laser-engraver",   { "laser-engraver-recipes" } },
	{ "iv-industrial-extrusion-machine",    "ev-extruder",         { "extruder-recipes" } },
	{ "iv-industrial-centrifuge",           "ev-centrifuge",       { "centrifuge-recipes" } },
	{ "iv-industrial-mixer",                "ev-mixer",            { "mixer-recipes" } },
	{ "iv-turbocan-pro",                    "ev-canning-machine",  { "canning-machine-recipes" } },
	{ "iv-zyngen",                          "ev-alloy-smelter",    { "alloy-smelter-recipes" } },
}

for _, mb in pairs(IV_MULTIBLOCKS) do
	local name, source, families = mb[1], mb[2], mb[3]
	if data.raw.item[name] then
		local categories = {}
		for _, fam in pairs(families) do add_unique(categories, tier_categories(fam, "iv")) end
		local src = data.raw["assembling-machine"][source]
		clone_machine{
			name = name, source = source, categories = categories,
			crafting_speed = 32,
			energy_usage = src and scale_energy(src.energy_usage, 4) or EU16_IV,
			fast_replaceable_group = "fr-" .. name,
			icon = data.raw.item[name].icon,
			sprite = { name, 1 },
		}
		set_place_result(name, name)
	else
		log("FORK-MACHINE: IV-Multiblock-Item fehlt: " .. name)
	end
end

--- Upstream-Fehler in den IV-Multiblock-Rezepten
do
	--- Wire Factory brauchte sich selbst statt ihres Controllers
	local r = data.raw.recipe["iv-industrial-wire-factory"]
	if r then
		for _, ing in pairs(r.ingredients) do
			if ing.name == "iv-industrial-wire-factory" then ing.name = "industrial-wire-factory-controller" end
		end
	end
	--- Precision Lathe hatte das Icon des Electrolyzers
	local it = data.raw.item["iv-industrial-precision-lathe"]
	if it then it.icon = ICON_PATH .. "industrial-precision-lathe.png" end
	--- Zyngen hatte das Icon des Industrial Mixers
	local zy = data.raw.item["iv-zyngen"]
	if zy then zy.icon = ICON_PATH .. "zyngen.png" end
end
