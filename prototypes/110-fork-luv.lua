--------------------------------------------------------------------------------
--- FORK LuV
--- Macht die LuV-Stufe spielbar. Grundlage sind die Entwürfe in 21-luv-age-item.lua
--- (LuV-Bauteile, Assembly Line). Ergänzt wird, was dort fehlte:
---   * fehlende Materialteile (HSS-S, Samarium, Ruridit, Rhodium-Plated Palladium, V-Ga-Kabel)
---   * Tippfehler/Platzhalter in den Entwurfsrezepten
---   * Assembly Line als Gebäude
---   * LuV-Grundmaschinen und -Multiblock-Upgrades (Kopie der IV-Versionen, eine Stufe höher)
---   * LuV-Science-Pack-Rezept und die LuV-Technologien
--- Was darüber hinausgeht (Fusion, Crystal-Prozessoren, Bacterial Vat, Wasserlinie) bleibt
--- Entwurf und wird vom Draft-Guard in 199-fork-finalize.lua ausgeblendet.
--------------------------------------------------------------------------------

local function set_ingredient(recipe_name, from, to)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-LUV: Rezept fehlt: " .. recipe_name) return end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.name == from then i.name = to end
		end
	end
end



--------------------------------------------------------------------------------
--- MATERIALTEILE
--------------------------------------------------------------------------------

--- HSS-S: LuV-Hauptmaterial (Motor, Kolben, Pumpe, Roboterarm ...). Upstream hatte nur Folie.
create_metal_parts{
	material = "hsss",
	speed = HSSS_SPEED,
	make_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_large_gear = true,
	make_round = true,
	make_nugget = true,
	make_ring = true,
	make_bolt = true,
	make_screw = true,
	make_rotor = true,
	make_frame = true,
}

--- Samarium-Stab (für den magnetischen Samarium-Stab im LuV-Motor)
create_metal_parts{ material = "samarium", speed = SAMARIUM_SPEED, make_rod = true }

--- Ruridit-Platte
create_metal_parts{ material = "ruridit", speed = RURIDIT_SPEED, make_plate = true }

--- Rhodium-Plated Palladium: Gehäuse-Material für LuV (Casing, Hull)
create_item{
	name = "rhodium-plated-palladium-dust",
	category = "iv-mixer-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "palladium-dust", amount = 3 },
		{ type = "item", name = "rhodium-dust", amount = 1 },
	},
	results = { { type = "item", name = "rhodium-plated-palladium-dust", amount = 4 } },
}
create_item{
	name = "rhodium-plated-palladium-ingot",
	category = "iv-electric-blast-furnace-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "rhodium-plated-palladium-dust", amount = 1 },
		{ type = "fluid", name = "argon", amount = 50 },
	},
	results = { { type = "item", name = "rhodium-plated-palladium-ingot", amount = 1 } },
}
create_metal_parts{ material = "rhodium-plated-palladium", speed = RHODIUM_PLATED_PALLADIUM_SPEED or 20, make_plate = true }

--- Vanadium-Gallium-Kabel (für den LuV Machine Hull), wie die anderen Superleiter-Kabel
create_item{
	name = "vanadium-gallium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "vanadium-gallium-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
	results = { { type = "item", name = "vanadium-gallium-cable", amount = 1 } },
}



--------------------------------------------------------------------------------
--- KORREKTUREN IN DEN ENTWÜRFEN
--------------------------------------------------------------------------------

--- Tippfehler: Indium Gallium Phosphate -> Phosphide (das Item existiert so)
set_ingredient("uhpic-wafer", "indium-gallium-phosphate", "indium-gallium-phosphide")
--- Naquadah gibt es erst mit Fusion (ZPM). Für den UHPIC-Wafer auf LuV: Europium-dotierter Weg -> Tungstensteel
set_ingredient("uhpic-wafer", "molten-naquadah", "molten-tungstensteel")

--- LuV-Superleiter: der geplante Barium-Titanat-Draht existiert nicht; LuV-Superleiter in GT ist YBCO
set_ingredient("luv-energy-hatch", "barium-titanate-cuproxide-superconductive-wire", "yttrium-barium-cuprate-cable")
set_ingredient("superconducting-coil-block", "barium-titanate-cuproxide-superconductive-wire", "yttrium-barium-cuprate-cable")
--- Super-Coolant-Zellen gibt es noch nicht -> IV-Superleiter-Kühlung über kryogenes Helium
do
	local r = data.raw.recipe["luv-energy-hatch"]
	if r then
		local keep = {}
		for _, i in pairs(r.ingredients) do
			if i.name ~= "180k-super-coolant-cell" and i.name ~= "super-coolant" then keep[#keep + 1] = i end
		end
		table.insert(keep, { type = "fluid", name = "cryogenic-helium", amount = 200 })
		r.ingredients = keep
	end
end

--- Assembler Machine Casing brauchte ZPM-Schaltkreise für eine LuV-Maschine -> IV-Schaltkreise
set_ingredient("assembler-machine-casing", "zpm-circuit", "iv-circuit")

--- Naquadah Coil Block ist ZPM-Material, das auf LuV nicht herstellbar ist -> bleibt Entwurf
if data.raw.recipe["naquadah-coil-block"] then data.raw.recipe["naquadah-coil-block"] = nil end

--- Circuit Assembly Line: nur für Crystal-Prozessoren (Mutagen/Bacterial Vat fehlen) -> bleibt Entwurf
for _, n in pairs({ "circuit-assembly-line-controller", "luv-circuit-assembly-line" }) do
	if data.raw.recipe[n] then data.raw.recipe[n] = nil end
end



--------------------------------------------------------------------------------
--- ASSEMBLY LINE (baut die LuV-Bauteile)
--------------------------------------------------------------------------------

do
	local m = table.deepcopy(data.raw["assembling-machine"]["iv-assembling-machine"])
	m.name = "luv-assembly-line"
	m.icon = ICON_PATH .. "luv-assembly-line.png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = "luv-assembly-line" }
	m.crafting_categories = { "iv-assembly-line-recipes", "luv-assembly-line-recipes" }
	m.crafting_speed = 1
	m.energy_usage = EU16_IV
	m.fast_replaceable_group = "fr-assembly-line"
	local w, h = 9, 3
	m.collision_box = { { -w / 2 + 0.2, -h / 2 + 0.2 }, { w / 2 - 0.2, h / 2 - 0.2 } }
	m.selection_box = { { -w / 2, -h / 2 }, { w / 2, h / 2 } }
	m.fluid_boxes = {
		fluid_port(-3, -1, "input", defines.direction.north),
		fluid_port(-1, -1, "input", defines.direction.north),
		fluid_port( 1, -1, "input", defines.direction.north),
		fluid_port( 3, -1, "input", defines.direction.north),
	}
	for _, fb in pairs(m.fluid_boxes) do
		fb.pipe_covers = pipecoverspictures()
		fb.pipe_picture = assembler2pipepictures()
	end
	m.fluid_boxes_off_when_no_fluid_recipe = true
	m.graphics_set = {
		idle_animation = { layers = { { filename = "__Gregtorio__/graphics/entity/fork/luv-assembly-line-idle.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__Gregtorio__/graphics/entity/fork/luv-assembly-line-working.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ m })
	local item = data.raw.item["luv-assembly-line"]
	if item then
		item.place_result = "luv-assembly-line"
		item.subgroup = "subgroup-luv-age-multiblocks"
		item.stack_size = 10
	end
end



--------------------------------------------------------------------------------
--- LuV-MASCHINEN (Kopien der IV-Maschinen, Rezept eine Stufe höher)
--------------------------------------------------------------------------------

LUV_BASIC_MACHINES = IV_BASIC_MACHINES
LUV_UPGRADE_MACHINES = IV_UPGRADE_MACHINES



--------------------------------------------------------------------------------
--- LuV SCIENCE PACK
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "luv-science-pack",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 60,
	order = "g",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "rtm-alloy-coil-block", amount = 4 },
		{ type = "item", name = "robust-tungstensteel-machine-casing", amount = 4 },
		{ type = "item", name = "iv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 144 },
	},
	results = {
		{ type = "item", name = "space-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- TECHNOLOGIEN
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack" }
	local amounts = { SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
	local out = {}
	for i = 1, n do
		out[#out + 1] = { packs[i], amounts[#amounts - n + i] }
	end
	return out
end

local function tech(def)
	local effects = {}
	for _, r in pairs(def.recipes) do
		if data.raw.recipe[r] then
			effects[#effects + 1] = { type = "unlock-recipe", recipe = r }
			data.raw.recipe[r].enabled = false
		else
			log("FORK-LUV: Tech " .. def.name .. ": Rezept fehlt " .. r)
		end
	end
	data:extend({ {
		type = "technology",
		name = def.name,
		icon = "__Gregtorio__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = def.prerequisites,
		unit = { count = def.count, ingredients = sci(def.packs), time = def.time or 60 },
	} })
end

local hsss_parts = {}
for _, p in pairs({ "hsss-nugget", "hsss-plate", "hsss-rod", "long-hsss-rod", "hsss-gear", "large-hsss-gear", "hsss-round",
	"hsss-ring", "hsss-bolt", "hsss-screw", "hsss-rotor", "hsss-frame" }) do
	hsss_parts[#hsss_parts + 1] = p
end

--- IV-Science: Materialien und Assembly Line
tech{
	name = "hsss-parts", prerequisites = { "hsss", "utility-science-pack" }, packs = 6, count = 600,
	recipes = hsss_parts,
}
tech{
	name = "yttrium-barium-cuprate", prerequisites = { "indium", "utility-science-pack" }, packs = 6, count = 600,
	recipes = { "yttrium-barium-cuprate-dust", "hot-yttrium-barium-cuprate-ingot", "yttrium-barium-cuprate-ingot",
		"yttrium-barium-cuprate-wire", "yttrium-barium-cuprate-cable" },
}
tech{
	name = "vanadium-gallium", prerequisites = { "alloy-blast-smelter", "utility-science-pack" }, packs = 6, count = 600,
	recipes = { "molten-vanadium-gallium", "solidify-vanadium-gallium-ingot", "vanadium-gallium-wire",
		"vanadium-gallium-cable", "vanadium-gallium-foil" },
}
tech{
	name = "rhodium-plated-palladium", prerequisites = { "rhodium", "utility-science-pack" }, packs = 6, count = 600,
	recipes = { "rhodium-plated-palladium-dust", "rhodium-plated-palladium-ingot", "rhodium-plated-palladium-plate" },
}
tech{
	name = "assembly-line", prerequisites = { "iv-machines", "iv-energy-hatches" }, packs = 6, count = 800,
	recipes = { "data-stick", "data-access-hatch", "assembly-line-casing", "assembler-machine-casing",
		"assembly-line-controller", "luv-assembly-line" },
}
tech{
	name = "luv-components",
	prerequisites = { "hsss-parts", "yttrium-barium-cuprate", "vanadium-gallium", "rhodium-plated-palladium",
		"ruridit", "assembly-line" },
	packs = 6, count = 1000,
	recipes = { "samarium-rod", "magnetic-samarium-rod", "long-magnetic-samarium-rod", "ruridit-plate",
		"molten-indalloy-140", "niobium-titanium-cable",
		"luv-motor", "luv-piston", "luv-pump", "luv-conveyor-module", "luv-robot-arm", "luv-sensor", "luv-emitter",
		"luv-field-generator", "luv-machine-casing", "luv-machine-hull" },
}
fork_add_unlock("space-science-pack", "luv-science-pack")
table.insert(data.raw.technology["space-science-pack"].prerequisites, "luv-components")

--- LuV-Science: Maschinen und Energie
local luv_machine_recipes = {}
for _, base in pairs(LUV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "iv", "luv", 6, nil)
	luv_machine_recipes[#luv_machine_recipes + 1] = "luv-" .. base
end
for _, base in pairs(LUV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "iv", "luv", nil, nil)
	luv_machine_recipes[#luv_machine_recipes + 1] = "luv-" .. base
end
--- Maschinen zuerst: UHPIC und Ludicrous Voltage Coil brauchen den LuV Assembler
tech{
	name = "luv-machines", prerequisites = { "space-science-pack" }, packs = 7, count = 1000,
	recipes = luv_machine_recipes,
}
tech{
	name = "luv-energy-hatches", prerequisites = { "luv-machines" }, packs = 7, count = 1500,
	recipes = { "uhpic-wafer", "ultra-high-powered-integrated-circuit", "ludicrous-voltage-coil",
		"luv-energy-hatch", "superconducting-coil-block" },
}
