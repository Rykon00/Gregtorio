--------------------------------------------------------------------------------
--- FORK ORE VEINS (plan #494, the maintainer's decision of 2026-10-22): GTNH's ore veins as mixed ore patches on the
--- map and the T0 dimensions as surfaces. Phase V1 (issue #496): the data of GT's ore mixes,
--- prototypes/data/ore-mixes.lua (tools/gen_ore_mixes.py from GT5-Unofficial's OreMixes.java), and the rule that
--- every ore of a vein on one of Gregtorio's surfaces has a raw ore with GTNH's chain. Phase V2 (issue #497): the
--- Overworld's veins on Nauvis (below).
---
--- FORK_ORE_MIX_SURFACES: GT's dimensions (DimNames) that are, or become, surfaces of Gregtorio, with their surface
--- property gt-dimension (#494: 1 Overworld, 2 Nether, 3 Twilight Forest, 4 End).
--- FORK_ORE_MIX_SKIPPED: what is left out on purpose, with the reason; keys are a material, "mix:<GT name>" (the vein
--- is dropped) or "dimension:<DimNames>" (a dimension of GT's veins that is not a surface).
--- FORK_ORE_MIX_NO_CHAIN: materials whose ore GT processes without the ore chain, with the reason.
--- devcheck fails for an ore of a vein on a surface without a raw ore and its chain (the ore washer's purified-<ore>)
--- that is in neither list, for a dimension of GT's veins that is neither a surface nor skipped, and for a stale entry.
--- Loads after 161 (every raw ore exists, 155 has made the chains).
--------------------------------------------------------------------------------

FORK_ORE_MIXES = require("prototypes.data.ore-mixes")

FORK_ORE_MIX_SURFACES = {
	OW = 1, NETHER = 2, TWILIGHT_FOREST = 3, THE_END = 4,
}

local THAUMCRAFT = "Thaumcraft's infused shard; the mod has no Thaumcraft (#494 decision 4)"
FORK_ORE_MIX_SKIPPED = {
	["electrotine"] = "Project Red's ore, left out as in #363; its tiles fall to the neighbouring layer (#494 decision 4)",
	["infused-air"] = THAUMCRAFT, ["infused-earth"] = THAUMCRAFT, ["infused-entropy"] = THAUMCRAFT,
	["infused-fire"] = THAUMCRAFT, ["infused-order"] = THAUMCRAFT, ["infused-water"] = THAUMCRAFT,
	["mix:AquaIgnis"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
	["mix:TerraAer"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
	["mix:PerditioOrdo"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
}
--- the dimensions that keep their mines and the Void Miner pools for now (#494: not in this plan)
for _, d in pairs({ "ENDASTEROID", "EVERGLADES", "MOON", "DEIMOS", "MARS", "PHOBOS", "ASTEROIDS", "CALLISTO", "CERES",
	"EUROPA", "GANYMEDE", "ROSS128B", "IO", "MERCURY", "VENUS", "ENCELADUS", "MIRANDA", "OBERON", "TITAN", "ROSS128BA",
	"PROTEUS", "TRITON", "HAUMEA", "KUIPERBELT", "MAKEMAKE", "PLUTO", "BARNARDC", "BARNARDE", "BARNARDF", "CENTAURIBB",
	"TCETIE", "VEGAB", "ANUBIS", "HORUS", "MAAHES", "MEHENBELT", "NEPER", "SETH" }) do
	FORK_ORE_MIX_SKIPPED["dimension:" .. d] = "stays a mine or Void Miner pool for now (#494: not in this plan)"
end

FORK_ORE_MIX_NO_CHAIN = {
	["oilsands"] = "GT has no ore chain for it: the LV centrifuge turns the raw ore into heavy oil and sand "
		.. "(ProcessingRawOre.java:48, 160's centrifuging-raw-oilsands)",
}



--------------------------------------------------------------------------------
--- Phase V2 (issue #497): GTNH's Overworld veins as mixed ore patches on Nauvis, by noise autoplace (the spike of #495;
--- the maintainer's defaults: GT's chance x 3, cells of 128 tiles, a quarter of them empty, 1000 ore per tile).
---   * one resource gt-ore-<material> per ore of a vein on a planet with map veins (category gt-ore, mined by hand into
---     raw-<material>), GT's colour as its map colour and as the tint of the vanilla stone sprites;
---   * the map is a grid of cells (gt_cell_size); voronoi_cell_id at the cell (jitter 0, seeded by the map) gives each
---     cell its values: the vein (gt_vein_id, by the cumulative GTNH weights of the planet's veins and the empty share),
---     the radius (8 + 0..1 x GT's size: GT's 16 + 0..2 x size across), the centre and the axis of the bands;
---   * GT's nine layers (WorldgenGTOreLayer.java) lie flat as bands across the vein: 1-3 secondary, 4 between (else
---     secondary), 5 between, 6-7 primary (else between), 8-9 primary, sporadic in 1/7 of the tiles left; a tile's chance
---     is GT's (1 / (distance to the far edge / density), the density falling by chunks from the centre) x gt_fill; the
---     roll is a voronoi cell per tile (random_penalty depends on the batch it is evaluated in, #495 finding 1);
---   * gt_vein_key = 8 x vein id + layer (1 primary, 2 secondary, 3 between, 4 sporadic); a resource's probability is the
---     sum of (gt_vein_key == k) over its keys, so a tile holds one ore at most; an ore left out (FORK_ORE_MIX_SKIPPED)
---     gives its layer to the neighbouring layer's ore (#494 decision 4);
---   * the sliders of the autoplace control gt-ore-veins: frequency shrinks the cells (128 / sqrt(frequency)), size
---     scales the veins (the cells grow with them), richness the ore per tile; gt_empty_share, gt_fill and gt_ore_amount
---     are named constants a map's property_expression_names can override;
---   * gt_vein_id is each planet's own expression (property_expression_names, gt-vein-id-<DimNames>); on Nauvis the four
---     cells around the origin hold the Coal, Iron, Copper and Cassiterite veins (their order by the map seed, at least
---     half GT's size);
---   * scripts/fork-ore-veins.lua tags a vein on the map with GT's name when the chunk of its centre is charted (mod data
---     fork-ore-veins).
--- 102 keeps the vanilla resources off; the vein recipes stay until V9 (#505).
--------------------------------------------------------------------------------

--- the planets with map veins (DimNames -> planet); V5 to V7 add the Nether, the Twilight Forest and The End
FORK_ORE_VEINS = { planets = { OW = "nauvis" }, start = { "Coal", "Iron", "Copper", "Cassiterite" }, resources = {} }

local ROLES = { "primary", "secondary", "between", "sporadic" }
local NEIGHBOUR = { primary = "between", secondary = "between", between = "secondary" }
local CONTROL = "gt-ore-veins"
local FREQ, SIZE, RICH = "var('control:" .. CONTROL .. ":frequency')", "var('control:" .. CONTROL .. ":size')",
	"var('control:" .. CONTROL .. ":richness')"

local by_name, planet_veins, used = {}, {}, {}
for _, m in ipairs(FORK_ORE_MIXES.mixes) do by_name[m.name] = m end
for dim in pairs(FORK_ORE_VEINS.planets) do
	planet_veins[dim] = {}
	for _, m in ipairs(FORK_ORE_MIXES.mixes) do
		local here = false
		for _, d in pairs(m.dimensions) do if d == dim then here = true end end
		if here and not FORK_ORE_MIX_SKIPPED["mix:" .. m.name] then
			table.insert(planet_veins[dim], m)
			used[m.id] = m
		end
	end
end
local used_ids = {}
for id in pairs(used) do used_ids[#used_ids + 1] = id end
table.sort(used_ids)

--- the ore of a layer: the mix's, or the neighbouring layer's where the mix's is left out
local function ore_of(mix, role)
	local x = mix[role]
	if FORK_ORE_MIX_SKIPPED[x] then x = NEIGHBOUR[role] and mix[NEIGHBOUR[role]] end
	if x and FORK_ORE_MIX_SKIPPED[x] then x = nil end
	return x
end
local keys, ores = {}, {}
for _, id in ipairs(used_ids) do
	for r, role in ipairs(ROLES) do
		local x = ore_of(used[id], role)
		if x then
			if not keys[x] then keys[x] = {}; ores[#ores + 1] = x end
			table.insert(keys[x], 8 * id + r)
		end
	end
end
table.sort(ores)

local function sum(list, f)
	local parts = {}
	for _, v in ipairs(list) do parts[#parts + 1] = f(v) end
	return #parts > 0 and table.concat(parts, " + ") or "0"
end
--- a value in [0, 1] per cell, seeded by the map
local function cell_value(seed)
	return "voronoi_cell_id{x = (gt_cell_x + 0.25) * gt_cell_size, y = (gt_cell_y + 0.25) * gt_cell_size, seed0 = map_seed, "
		.. "seed1 = " .. seed .. ", grid_size = gt_cell_size, distance_type = 'euclidean', jitter = 0}"
end

local E = {
	--- the maintainer's defaults (#495), overridable per map
	gt_cell_base = "128",
	gt_empty_share = "0.25",
	gt_fill = "3",
	gt_ore_amount = "1000",
	--- a vein is 8 + 0..32 tiles in radius at size 1: the cell keeps room for the largest one
	gt_cell_size = "max(gt_cell_base / pow(" .. FREQ .. ", 0.5), 88 * " .. SIZE .. ")",
	gt_cell_x = "floor(x / gt_cell_size)",
	gt_cell_y = "floor(y / gt_cell_size)",
	gt_u_pick = cell_value(1),
	gt_u_radius = cell_value(2),
	gt_u_ox = cell_value(3),
	gt_u_oy = cell_value(4),
	gt_u_angle = cell_value(5),
	--- the planets override both (none: no veins)
	gt_vein_id = "0",
	gt_vein_start = "0",
	--- the four cells around the origin: 1 north-west, 2 north-east, 3 south-west, 4 south-east, else 0
	gt_start_index = "(gt_cell_y == -1) * ((gt_cell_x == -1) + (gt_cell_x == 0) * 2) + (gt_cell_y == 0) * ((gt_cell_x == -1) * 3 + (gt_cell_x == 0) * 4)",
	--- a turn of the start veins, the same in every cell of a map
	gt_start_turn = "floor(voronoi_cell_id{x = 0.5, y = 0.5, seed0 = map_seed, seed1 = 6, grid_size = 64, "
		.. "distance_type = 'euclidean', jitter = 0} * 3.999)",
	gt_vein_size = sum(used_ids, function(id) return "(gt_vein_id == " .. id .. ") * " .. used[id].size end),
	gt_vein_density = sum(used_ids, function(id) return "(gt_vein_id == " .. id .. ") * " .. used[id].density end),
	gt_vein_r = "(8 + if(gt_vein_start > 0, 0.5 + 0.5 * gt_u_radius, gt_u_radius) * gt_vein_size) * " .. SIZE,
	gt_vein_free = "max(0, gt_cell_size / 2 - gt_vein_r - 2)",
	gt_vein_cx = "(gt_cell_x + 0.5) * gt_cell_size + (gt_u_ox * 2 - 1) * gt_vein_free",
	gt_vein_cy = "(gt_cell_y + 0.5) * gt_cell_size + (gt_u_oy * 2 - 1) * gt_vein_free",
	gt_dx = "x - gt_vein_cx",
	gt_dy = "y - gt_vein_cy",
	gt_d = "pow(gt_dx * gt_dx + gt_dy * gt_dy, 0.5)",
	gt_t = "gt_dx * sin(gt_u_angle * pi + pi / 2) + gt_dy * sin(gt_u_angle * pi)",
	gt_band = "clamp(floor((gt_t + gt_vein_r) / (2 * gt_vein_r) * 9), 0, 8) + 1",
	--- GT: localDensity = density / floor(sqrt(2 + chunks from the seed ^ 2)), chance = max(1, far-edge distance /
	--- localDensity) per axis, a tile takes the layer's ore at 1 / chance of either axis
	gt_dens_local = "max(1, floor(gt_vein_density / floor(pow(2 + pow(gt_d / (16 * " .. SIZE .. "), 2), 0.5))))",
	gt_px = "1 / max(1, floor((gt_vein_r + abs(gt_dx)) / gt_dens_local))",
	gt_py = "1 / max(1, floor((gt_vein_r + abs(gt_dy)) / gt_dens_local))",
	gt_p = "min(1, gt_fill * (1 - (1 - gt_px) * (1 - gt_py)))",
	gt_u_tile = "voronoi_cell_id{x = x + 0.25, y = y + 0.25, seed0 = map_seed, seed1 = 7, grid_size = 1, "
		.. "distance_type = 'euclidean', jitter = 0}",
	gt_first = "if(gt_band <= 3, 2, if(gt_band <= 5, 3, 1))",
	gt_second = "if(gt_band == 4, 2, if(gt_band >= 6, if(gt_band <= 7, 3, 0), 0))",
	gt_role_raw = "if(gt_u_tile < gt_p, gt_first, if(gt_second > 0, "
		.. "if(gt_u_tile < gt_p + (1 - gt_p) * gt_p, gt_second, "
		.. "if(gt_u_tile < gt_p + (1 - gt_p) * gt_p + (1 - gt_p) * (1 - gt_p) * gt_p / 7, 4, 0)), "
		.. "if(gt_u_tile < gt_p + (1 - gt_p) * gt_p / 7, 4, 0)))",
	gt_role = "gt_role_raw * (gt_d < gt_vein_r) * (gt_vein_id > 0)",
	gt_vein_key = "gt_vein_id * 8 + gt_role",
	gt_ore_richness = "gt_ore_amount * " .. RICH,
}

--- each planet's vein: the start cells (Nauvis), else the pick by GT's weights and the empty share
for dim, list in pairs(planet_veins) do
	local total, acc, parts = 0, 0, {}
	for _, m in ipairs(list) do total = total + m.weight end
	for _, m in ipairs(list) do
		acc = acc + m.weight
		parts[#parts + 1] = { acc, m.id }
	end
	local pick = "0"
	for i = #parts, 1, -1 do
		pick = "if(gt_u_pick * " .. total .. " / (1 - gt_empty_share) < " .. parts[i][1] .. ", " .. parts[i][2] .. ", " .. pick .. ")"
	end
	if dim == "OW" then
		local start = {}
		for j, n in ipairs(FORK_ORE_VEINS.start) do
			start[#start + 1] = "((gt_start_index + gt_start_turn - 1) % 4 == " .. (j - 1) .. ") * " .. by_name[n].id
		end
		E["gt-vein-id-" .. dim] = "if(gt_start_index > 0, " .. table.concat(start, " + ") .. ", " .. pick .. ")"
		E["gt-vein-start-" .. dim] = "gt_start_index"
	else
		E["gt-vein-id-" .. dim] = pick
	end
end
for name, expr in pairs(E) do data:extend({ { type = "noise-expression", name = name, expression = expr } }) end

data:extend({
	{ type = "resource-category", name = "gt-ore" },
	{ type = "autoplace-control", name = CONTROL, category = "resource", richness = true, order = "a-a" },
})
--- every ore can be mined by hand (#494 decision 8)
for _, c in pairs(data.raw.character) do
	c.mining_categories = c.mining_categories or { "basic-solid" }
	table.insert(c.mining_categories, "gt-ore")
end

local STONE = data.raw.resource["stone"]
for _, x in ipairs(ores) do
	local info = FORK_ORE_MIXES.materials[x]
	local c = info and info.color or { 128, 128, 128 }
	local color = { c[1] / 255, c[2] / 255, c[3] / 255 }
	local raw = data.raw.item["raw-" .. x]
	local terms = {}
	for _, k in ipairs(keys[x]) do terms[#terms + 1] = "(gt_vein_key == " .. k .. ")" end
	local r = table.deepcopy(STONE)
	r.name = "gt-ore-" .. x
	r.localised_name = { "entity-name.gt-ore", info and info.name or x }
	r.icon, r.icons, r.icon_size = raw.icon, raw.icons, raw.icon_size
	r.category = "gt-ore"
	r.order = "g-" .. x
	r.minable = { mining_time = 2, result = "raw-" .. x }   -- slower than vanilla ore by hand (1)
	r.autoplace = { control = CONTROL, order = "g-" .. x, probability_expression = table.concat(terms, " + "),
		richness_expression = "gt_ore_richness" }
	r.stage_counts = { 1000, 750, 500, 300, 150, 75, 30, 1 }
	r.stages.sheet.tint = color
	r.map_color = color
	r.mining_visualisation_tint = color
	r.factoriopedia_simulation = nil
	data:extend({ r })
	FORK_ORE_VEINS.resources[x] = r.name
end

--- the planets: the control, their resources and their vein expressions
for dim, planet in pairs(FORK_ORE_VEINS.planets) do
	local mgs = data.raw.planet[planet].map_gen_settings
	mgs.autoplace_controls[CONTROL] = {}
	mgs.property_expression_names = mgs.property_expression_names or {}
	mgs.property_expression_names.gt_vein_id = "gt-vein-id-" .. dim
	if E["gt-vein-start-" .. dim] then mgs.property_expression_names.gt_vein_start = "gt-vein-start-" .. dim end
	for _, m in ipairs(planet_veins[dim]) do
		for _, role in ipairs(ROLES) do
			local x = ore_of(m, role)
			if x then mgs.autoplace_settings.entity.settings["gt-ore-" .. x] = {} end
		end
	end
end

--- for scripts/fork-ore-veins.lua and devcheck's runtime test: vein id -> GT's name, the primary's raw ore and the
--- resources of its layers; planet -> DimNames, its vein ids and the start veins
local labels = {}
for _, id in ipairs(used_ids) do
	local res, seen = {}, {}
	for _, role in ipairs(ROLES) do
		local x = ore_of(used[id], role)
		if x and not seen[x] then seen[x] = true; res[#res + 1] = "gt-ore-" .. x end
	end
	labels[tostring(id)] = { text = used[id].label .. " Vein", icon = "raw-" .. (ore_of(used[id], "primary") or used[id].primary),
		resources = res }
end
local planets = {}
for dim, planet in pairs(FORK_ORE_VEINS.planets) do
	local ids = {}
	for _, m in ipairs(planet_veins[dim]) do ids[#ids + 1] = m.id end
	local start = {}
	if dim == "OW" then for _, n in ipairs(FORK_ORE_VEINS.start) do start[#start + 1] = by_name[n].id end end
	planets[planet] = { dimension = dim, veins = ids, start = start }
end
data:extend({ { type = "mod-data", name = "fork-ore-veins", data = { veins = labels, planets = planets } } })
