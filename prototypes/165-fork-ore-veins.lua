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
}
--- the Thaumcraft veins of the Twilight Forest (163's FORK_ORE_VEINS.dropped)
for name in pairs(FORK_ORE_VEINS.dropped) do
	FORK_ORE_MIX_SKIPPED["mix:" .. name] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)"
end
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
---   * issue #529: one autoplace control per vein (below) and the grid control gt-ore-veins: its frequency shrinks the
---     cells (128 / sqrt(frequency)), its size sets the share of cells with a vein, its richness the ore per tile of
---     every vein; gt_empty_share, gt_fill and gt_ore_amount are named constants a map's property_expression_names can
---     override;
---   * gt_vein_id is each planet's own expression (property_expression_names, gt-vein-id-<DimNames>); on Nauvis the four
---     cells around the origin hold the Coal, Iron, Copper and Cassiterite veins (their order by the map seed, at least
---     half GT's size);
---   * scripts/fork-ore-veins.lua tags a vein on the map with GT's name when the chunk of its centre is charted (mod data
---     fork-ore-veins).
--- 102 keeps the vanilla resources off; the vein recipes stay until V9 (#505).
--------------------------------------------------------------------------------

--- the planets with map veins (DimNames -> planet, 163's FORK_ORE_VEINS.planets: Nauvis, the Nether since V5, the
--- Twilight Forest since V6, The End since V7)
FORK_ORE_VEINS.start = { "Coal", "Iron", "Copper", "Cassiterite" }
FORK_ORE_VEINS.resources = {}

--------------------------------------------------------------------------------
--- Phase V5 (issue #501): the Nether as a surface. The surface property gt-dimension (#494: 1 Overworld, 2 Nether, 3
--- Twilight Forest, 4 End) gates recipes and buildings with surface_conditions. The planet gt-nether is a Space Age
--- planet for its map generation and surface properties only (hidden, no space connection); scripts/fork-portals.lua
--- makes its surface at the first portal. Its terrain is Vulcanus' without Vulcanus' resources, rocks, demolishers and
--- chimneys: its volcanic rock stands for netherrack, its lava lakes give lava to an offshore pump (the lava boilers of
--- #446), and it has no water (the water drilling rig gets surface_conditions in 160). No sun: solar power 0.
--------------------------------------------------------------------------------

data:extend({ { type = "surface-property", name = "gt-dimension", default_value = 1, order = "z-gt" } })
data.raw.planet.nauvis.surface_properties["gt-dimension"] = 1
do
	local vulcanus = data.raw.planet.vulcanus
	local mgs = table.deepcopy(vulcanus.map_gen_settings)
	mgs.territory_settings = nil
	mgs.autoplace_controls = { ["vulcanus_volcanism"] = mgs.autoplace_controls["vulcanus_volcanism"] or {} }
	mgs.autoplace_settings.entity = { settings = {} }
	for k in pairs(mgs.property_expression_names or {}) do
		if k:match("^entity:") then mgs.property_expression_names[k] = nil end
	end
	data:extend({ {
		type = "planet", name = "gt-nether", hidden = true,
		icon = vulcanus.icon, icon_size = vulcanus.icon_size, starmap_icon = vulcanus.starmap_icon,
		starmap_icon_size = vulcanus.starmap_icon_size, distance = 1, orientation = 0.99,
		map_gen_settings = mgs,
		surface_properties = { ["gt-dimension"] = 2, ["day-night-cycle"] = 5 * 60 * 60, ["magnetic-field"] = 90,
			["solar-power"] = 0, pressure = 1000, gravity = 10 },
		surface_render_parameters = vulcanus.surface_render_parameters,
		persistent_ambient_sounds = vulcanus.persistent_ambient_sounds,
	} })
end

--------------------------------------------------------------------------------
--- Phase V6 (issue #502): the Twilight Forest as a surface, the planet gt-twilight (gt-dimension 3, hidden, no space
--- connection; scripts/fork-portals.lua makes its surface at the first Twilight Portal). Its terrain is Nauvis' as a
--- dense forest (the trees at the sliders' top, a wet climate for the green grass), without biters and vanilla
--- resources; GTNH's 15 Twilight Forest veins (the three Thaumcraft veins left out). Permanent dusk: the script freezes
--- the daytime at dusk, and the sun gives half of Nauvis' light.
--------------------------------------------------------------------------------

do
	local nauvis = data.raw.planet.nauvis
	local mgs = table.deepcopy(nauvis.map_gen_settings)
	mgs.territory_settings = nil
	mgs.autoplace_controls = { trees = { frequency = 6, size = 6, richness = 2 }, water = {}, nauvis_cliff = {},
		starting_area_moisture = {} }
	for name in pairs(mgs.autoplace_settings.entity.settings) do
		if data.raw.resource[name] then mgs.autoplace_settings.entity.settings[name] = nil end
	end
	data:extend({
		{ type = "noise-expression", name = "gt-twilight-moisture", expression = "0.7 + 0.3 * moisture_nauvis" },
		{ type = "noise-expression", name = "gt-twilight-aux", expression = "0.25 + 0.5 * aux_nauvis" },
	})
	mgs.property_expression_names = { moisture = "gt-twilight-moisture", aux = "gt-twilight-aux" }
	data:extend({ {
		type = "planet", name = "gt-twilight", hidden = true,
		icon = nauvis.icon, icon_size = nauvis.icon_size, starmap_icon = nauvis.starmap_icon,
		starmap_icon_size = nauvis.starmap_icon_size, distance = 1, orientation = 0.98,
		map_gen_settings = mgs,
		surface_properties = { ["gt-dimension"] = 3, ["day-night-cycle"] = 5 * 60 * 60, ["magnetic-field"] = 90,
			["solar-power"] = 50, pressure = 1000, gravity = 10 },
		surface_render_parameters = nauvis.surface_render_parameters,
		persistent_ambient_sounds = nauvis.persistent_ambient_sounds,
	} })
end

--------------------------------------------------------------------------------
--- Phase V7 (issue #503): The End as a surface, the planet gt-end (gt-dimension 4, hidden, no space connection;
--- scripts/fork-portals.lua makes its surface at the first End Portal). Minecraft's End: a main island of end stone
--- around the origin (a radius of about 400 tiles), outer islands from about 800 tiles on, the void around them (a copy
--- of out-of-map: nothing is built or walked there); no water, no trees, no cliffs; GTNH's 7 End veins on the land
--- only (gt_end_land cuts gt_vein_id below). No sun: the script freezes the daytime at night, solar power 0.
--------------------------------------------------------------------------------

do
	local function noise(seed, scale)
		return "basis_noise{x = x, y = y, seed0 = map_seed, seed1 = " .. seed .. ", input_scale = " .. scale
			.. ", output_scale = 1}"
	end
	data:extend({ { type = "noise-expression", name = "gt_end_land",
		expression = "max(distance < 400 + 60 * " .. noise(41, "1 / 90") .. ", "
			.. noise(42, "1 / 350") .. " + 0.4 * " .. noise(43, "1 / 90") .. " > 0.35 + clamp((900 - distance) / 100, 0, 10))" } })
	local stone = table.deepcopy(data.raw.tile["sand-1"])
	stone.name = "gt-end-stone"
	stone.localised_name = { "tile-name.gt-end-stone" }
	stone.order = "z[gt]-a[end-stone]"
	stone.tint = { 0.95, 0.95, 0.7 }
	stone.map_color = { 219, 222, 158 }
	stone.autoplace = { probability_expression = "gt_end_land" }
	local void = table.deepcopy(data.raw.tile["out-of-map"])
	void.name = "gt-end-void"
	void.localised_name = { "tile-name.gt-end-void" }
	void.order = "z[gt]-b[end-void]"
	void.autoplace = { probability_expression = "1 - gt_end_land" }
	data:extend({ stone, void })
	local nauvis = data.raw.planet.nauvis
	data:extend({ {
		type = "planet", name = "gt-end", hidden = true,
		icon = nauvis.icon, icon_size = nauvis.icon_size, starmap_icon = nauvis.starmap_icon,
		starmap_icon_size = nauvis.starmap_icon_size, distance = 1, orientation = 0.97,
		map_gen_settings = {
			autoplace_controls = {},
			autoplace_settings = { tile = { settings = { ["gt-end-stone"] = {}, ["gt-end-void"] = {} } },
				decorative = { settings = {} }, entity = { settings = {} } },
			property_expression_names = { cliffiness = "0" },
		},
		surface_properties = { ["gt-dimension"] = 4, ["day-night-cycle"] = 5 * 60 * 60, ["magnetic-field"] = 90,
			["solar-power"] = 0, pressure = 1000, gravity = 10 },
		surface_render_parameters = nauvis.surface_render_parameters,
		persistent_ambient_sounds = nauvis.persistent_ambient_sounds,
	} })
end

local ROLES = { "primary", "secondary", "between", "sporadic" }
local NEIGHBOUR = { primary = "between", secondary = "between", between = "secondary" }
--------------------------------------------------------------------------------
--- Issue #529 (the maintainer's request and decisions of 2026-10-23): one autoplace control per vein a planet places,
--- gt-vein-<GT's mix name>, named as its chart tag with the primary ore's icon ([autoplace-control-names]), listed on the
--- planets that place the vein, ordered by surface and then by GT's weight. Per vein:
---   * frequency multiplies its weight in its planet's pick; with its checkbox off (frequency or size 0) its weight is 0
---     and the other veins fill its cells, as GTNH leaves a disabled vein out of its weighted list;
---   * size magnifies it (its radius, the fall of its density and GT's chance of a tile); the cells keep room for the
---     largest vein (88 tiles x the largest size), so a vein above size 1.45 makes every cell of its planet larger;
---   * richness scales its ore per tile, on top of the grid control's richness.
--- The four start veins of Nauvis ignore their frequency and take size and richness; a start vein that is off leaves its
--- cell to the normal pick. The grid control keeps the name gt-ore-veins, so old saves keep their cells (a save whose
--- old size slider is not 1 gets it on every vein: migrations/2026-10-23-issue-529-vein-controls.lua).
--------------------------------------------------------------------------------
local GRID = "gt-ore-veins"
local function slider(control, name) return "var('control:" .. control .. ":" .. name .. "')" end
local FREQ, SIZE, RICH = slider(GRID, "frequency"), slider(GRID, "size"), slider(GRID, "richness")
local function vein_control(m) return "gt-vein-" .. m.name end

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
	--- a vein is 8 + 0..32 tiles in radius at size 1: the cell keeps room for the largest one (issue #529: of the largest
	--- size slider of the planet's veins, gt_size_max, which each planet sets)
	gt_size_max = "1",
	gt_cell_size = "max(gt_cell_base / pow(" .. FREQ .. ", 0.5), 88 * gt_size_max)",
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
	--- issue #529: the vein's own size and richness sliders
	gt_vein_scale = sum(used_ids, function(id) return "(gt_vein_id == " .. id .. ") * " .. slider(vein_control(used[id]), "size") end),
	gt_vein_rich = sum(used_ids, function(id) return "(gt_vein_id == " .. id .. ") * " .. slider(vein_control(used[id]), "richness") end),
	--- the share of the cells that hold a vein: the grid control's size (1: three in four)
	gt_fill_share = "clamp((1 - gt_empty_share) * " .. SIZE .. ", 0, 1)",
	gt_vein_r = "(8 + if(gt_vein_start > 0, 0.5 + 0.5 * gt_u_radius, gt_u_radius) * gt_vein_size) * gt_vein_scale",
	gt_vein_free = "max(0, gt_cell_size / 2 - gt_vein_r - 2)",
	gt_vein_cx = "(gt_cell_x + 0.5) * gt_cell_size + (gt_u_ox * 2 - 1) * gt_vein_free",
	gt_vein_cy = "(gt_cell_y + 0.5) * gt_cell_size + (gt_u_oy * 2 - 1) * gt_vein_free",
	gt_dx = "x - gt_vein_cx",
	gt_dy = "y - gt_vein_cy",
	gt_d = "pow(gt_dx * gt_dx + gt_dy * gt_dy, 0.5)",
	gt_t = "gt_dx * sin(gt_u_angle * pi + pi / 2) + gt_dy * sin(gt_u_angle * pi)",
	gt_band = "clamp(floor((gt_t + gt_vein_r) / (2 * gt_vein_r) * 9), 0, 8) + 1",
	--- GT: localDensity = density / floor(sqrt(2 + chunks from the seed ^ 2)), chance = max(1, far-edge distance /
	--- localDensity) per axis, a tile takes the layer's ore at 1 / chance of either axis; issue #529: a vein's size slider
	--- magnifies it as a whole (the distances divided by gt_vein_scale), so a vein at size 2 has four times the ore tiles
	gt_dens_local = "max(1, floor(gt_vein_density / floor(pow(2 + pow(gt_d / (16 * max(gt_vein_scale, 0.01)), 2), 0.5))))",
	gt_px = "1 / max(1, floor((gt_vein_r + abs(gt_dx)) / (gt_dens_local * max(gt_vein_scale, 0.01))))",
	gt_py = "1 / max(1, floor((gt_vein_r + abs(gt_dy)) / (gt_dens_local * max(gt_vein_scale, 0.01))))",
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
	gt_ore_richness = "gt_ore_amount * " .. RICH .. " * gt_vein_rich",
}
--- issue #529: a vein's weight in the pick (GT's weight x its frequency, 0 with its checkbox off) and whether it is on
for _, id in ipairs(used_ids) do
	local c = vein_control(used[id])
	E["gt_vein_weight_" .. id] = used[id].weight .. " * " .. slider(c, "frequency") .. " * (" .. slider(c, "size") .. " > 0)"
	E["gt_vein_on_" .. id] = "(" .. slider(c, "frequency") .. " > 0) * (" .. slider(c, "size") .. " > 0)"
end

--- each planet's vein: the start cells (Nauvis), else the pick by the veins' weights (issue #529: x their frequency) and
--- the share of cells with a vein; the largest size slider of its veins (gt-size-max-<DimNames>)
for dim, list in pairs(planet_veins) do
	local weights, parts, sizes = {}, {}, {}
	for _, m in ipairs(list) do
		weights[#weights + 1] = "gt_vein_weight_" .. m.id
		parts[#parts + 1] = { table.concat(weights, " + "), m.id }
		sizes[#sizes + 1] = slider(vein_control(m), "size")
	end
	local pick = "0"
	for i = #parts, 1, -1 do
		pick = "if(gt_u_pick * gt_vein_total_" .. dim .. " / gt_fill_share < " .. parts[i][1] .. ", " .. parts[i][2] .. ", "
			.. pick .. ")"
	end
	E["gt_vein_total_" .. dim] = table.concat(weights, " + ")
	E["gt_vein_pick_" .. dim] = pick
	local size_max = sizes[1]
	for i = 2, #sizes do size_max = "max(" .. size_max .. ", " .. sizes[i] .. ")" end
	E["gt-size-max-" .. dim] = size_max
	if dim == "OW" then
		--- the start vein of a start cell, and whether it is on
		local start, on = {}, {}
		for j, n in ipairs(FORK_ORE_VEINS.start) do
			local here = "((gt_start_index + gt_start_turn - 1) % 4 == " .. (j - 1) .. ")"
			start[#start + 1] = here .. " * " .. by_name[n].id
			on[#on + 1] = here .. " * gt_vein_on_" .. by_name[n].id
		end
		E.gt_start_on = "(gt_start_index > 0) * (" .. table.concat(on, " + ") .. ")"
		E["gt-vein-id-" .. dim] = "if(gt_start_on > 0, " .. table.concat(start, " + ") .. ", gt_vein_pick_" .. dim .. ")"
		E["gt-vein-start-" .. dim] = "gt_start_index * gt_start_on"
	elseif dim == "THE_END" then
		E["gt-vein-id-" .. dim] = "gt_vein_pick_" .. dim .. " * gt_end_land"   -- the veins on the islands only
	else
		E["gt-vein-id-" .. dim] = "gt_vein_pick_" .. dim
	end
end
for name, expr in pairs(E) do data:extend({ { type = "noise-expression", name = name, expression = expr } }) end

data:extend({
	{ type = "resource-category", name = "gt-ore" },
	{ type = "autoplace-control", name = GRID, category = "resource", richness = true, order = "a-a" },
})
--- issue #529: the veins' controls, by surface and then by GT's weight (the first surface of a vein on several)
for _, id in ipairs(used_ids) do
	local m, first = used[id], 9
	for dim, planet in pairs(FORK_ORE_VEINS.planets) do
		for _, v in ipairs(planet_veins[dim]) do
			if v.id == id then first = math.min(first, FORK_ORE_MIX_SURFACES[dim] or 9) end
		end
	end
	data:extend({ { type = "autoplace-control", name = vein_control(m), category = "resource", richness = true,
		order = string.format("b-%d-%04d-%s", first, 9999 - m.weight, m.name) } })
end
--- every ore can be mined by hand (#494 decision 8)
for _, c in pairs(data.raw.character) do
	c.mining_categories = c.mining_categories or { "basic-solid" }
	table.insert(c.mining_categories, "gt-ore")
end

local STONE = data.raw.resource["stone"]
--- issue #654: GT's ore texture of the material's icon set in its colour (tools/gen_vein_ore_sheets.py) over the base
--- game's stone lumps in GT's stone grey
local ORE_SETS = require("prototypes.data.vein-ore-sets")
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
	r.autoplace = { control = GRID, order = "g-" .. x, probability_expression = table.concat(terms, " + "),
		richness_expression = "gt_ore_richness" }
	r.stage_counts = { 1000, 750, 500, 300, 150, 75, 30, 1 }
	r.stages.sheet.tint = { 0.72, 0.72, 0.74 }
	r.stages_effect = { sheet = { filename = "__gregtorio-continued__/graphics/entity/fork/gt-ore-" .. (ORE_SETS[x] or "dull") .. ".png",
		priority = "extra-high", size = 64, frame_count = 8, variation_count = 8, scale = 1, tint = color, blend_mode = "normal" } }
	r.effect_animation_period, r.min_effect_alpha, r.max_effect_alpha, r.effect_darkness_multiplier = 1, 1, 1, 0
	r.map_color = color
	r.mining_visualisation_tint = color
	r.factoriopedia_simulation = nil
	data:extend({ r })
	FORK_ORE_VEINS.resources[x] = r.name
end

--- the planets: the controls (the grid's and their veins'), their resources and their vein expressions (issue #563: not in
--- classic mode, whose vein recipes come from 166; the resources, expressions and controls stay for the saves that switch,
--- and data-final-fixes.lua hides the controls no planet lists)
for dim, planet in pairs(FORK_CLASSIC_ORES and {} or FORK_ORE_VEINS.planets) do
	local mgs = data.raw.planet[planet].map_gen_settings
	mgs.autoplace_controls[GRID] = {}
	mgs.property_expression_names = mgs.property_expression_names or {}
	mgs.property_expression_names.gt_vein_id = "gt-vein-id-" .. dim
	mgs.property_expression_names.gt_size_max = "gt-size-max-" .. dim
	if E["gt-vein-start-" .. dim] then mgs.property_expression_names.gt_vein_start = "gt-vein-start-" .. dim end
	for _, m in ipairs(planet_veins[dim]) do
		mgs.autoplace_controls[vein_control(m)] = {}
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
		resources = res, control = vein_control(used[id]) }
end
local planets = {}
for dim, planet in pairs(FORK_ORE_VEINS.planets) do
	local ids = {}
	for _, m in ipairs(planet_veins[dim]) do ids[#ids + 1] = m.id end
	local start = {}
	if dim == "OW" then for _, n in ipairs(FORK_ORE_VEINS.start) do start[#start + 1] = by_name[n].id end end
	planets[planet] = { dimension = dim, veins = ids, start = start }
end
data:extend({ { type = "mod-data", name = "fork-ore-veins", data = { veins = labels, planets = planets,
	mode = FORK_ORE_MODE } } })

--- issue #563: for 166's classic vein recipes, the veins the map places (each once, in GT's order) with the planets that
--- place them, and the ore of a layer
FORK_ORE_VEINS.placed = {}
for _, id in ipairs(used_ids) do
	local m, on = used[id], {}
	for dim in pairs(FORK_ORE_VEINS.planets) do
		for _, v in ipairs(planet_veins[dim]) do if v.id == id then on[#on + 1] = dim end end
	end
	table.sort(on, function(a, b) return FORK_ORE_MIX_SURFACES[a] < FORK_ORE_MIX_SURFACES[b] end)
	FORK_ORE_VEINS.placed[#FORK_ORE_VEINS.placed + 1] = { mix = m, dimensions = on }
end
FORK_ORE_VEINS.ore_of = ore_of
FORK_ORE_VEINS.fill = tonumber(E.gt_fill)   -- GT's chance of a tile x this (the maintainer's 3, #495)


--------------------------------------------------------------------------------
--- Issue #574: a player looking for an ore found no slider for it (diamond is the in-between layer of the "Graphite &
--- Diamond Vein"), and the planets' icons in the map generator were Nauvis' and Vulcanus'. Generated from the data above,
--- no list by hand:
---   * every vein control gets a description: one line per ore with its icon and the layers it holds (primary,
---     secondary, in between, sporadic; an ore of two layers once), GT's weight, density and size, and per surface its
---     share of the cells with a vein (`[fork-vein]` locale keys, the numbers as parameters);
---   * in map-vein mode a raw ore of a vein says in its description which veins hold it and in which layers;
---   * gt-nether, gt-twilight and gt-end have icons of their own (graphics/icons/<planet>.png, drawn by
---     tools/gen_icons.py --drawn).
--- FORK_ORE_VEINS.table (one row per placed vein) is devcheck's section VEINTABLE for the vein table of
--- docs/ORE-VEINS.md; devcheck's names check fails for a vein control without its description.
--------------------------------------------------------------------------------

local ROLE_KEYS = { primary = "primary", secondary = "secondary", between = "between", sporadic = "sporadic" }
--- a list as one localised string of nested concatenations (a localised string takes 20 parameters at most)
local function join(list, sep)
	if #list == 0 then return "" end
	if #list <= 9 then
		local out = { "" }
		for i, x in ipairs(list) do
			if i > 1 then out[#out + 1] = sep end
			out[#out + 1] = x
		end
		return out
	end
	local half = math.floor(#list / 2)
	local a, b = {}, {}
	for i, x in ipairs(list) do if i <= half then a[#a + 1] = x else b[#b + 1] = x end end
	return { "", join(a, sep), sep, join(b, sep) }
end
local function item_name(name)
	local it = data.raw.item[name]
	return it and it.localised_name or { "item-name." .. name }
end
--- the ores of a vein in GT's order, each with its layers: { { ore = x, roles = { "primary", ... } }, ... }
local function vein_ores(m)
	local out, at = {}, {}
	for _, role in ipairs(ROLES) do
		local x = ore_of(m, role)
		if x then
			if not at[x] then
				at[x] = { ore = x, roles = {} }
				out[#out + 1] = at[x]
			end
			table.insert(at[x].roles, role)
		end
	end
	return out
end
local function roles_text(roles)
	local parts = {}
	for _, r in ipairs(roles) do parts[#parts + 1] = { "fork-vein.role-" .. ROLE_KEYS[r] } end
	local out = { "fork-vein.roles-" .. #parts }
	for _, p in ipairs(parts) do out[#out + 1] = p end
	return out
end
local totals = {}
for dim, list in pairs(planet_veins) do
	local w = 0
	for _, m in ipairs(list) do w = w + m.weight end
	totals[dim] = w
end

FORK_ORE_VEINS.table = {}
local found = {}   -- raw ore -> { localised vein lines }
for _, v in ipairs(FORK_ORE_VEINS.placed) do
	local m = v.mix
	local ores, lines = vein_ores(m), {}
	for _, o in ipairs(ores) do
		local raw = "raw-" .. o.ore
		lines[#lines + 1] = { "fork-vein.ore", raw, item_name(raw), roles_text(o.roles) }
		found[raw] = found[raw] or {}
		table.insert(found[raw], { "fork-vein.found-in-vein", m.label, roles_text(o.roles) })
	end
	local surfaces, planets = {}, {}
	for _, dim in ipairs(v.dimensions) do
		local planet = FORK_ORE_VEINS.planets[dim]
		planets[#planets + 1] = planet
		local share = totals[dim] > 0 and m.weight / totals[dim] * (1 - tonumber(E.gt_empty_share)) * 100 or 0
		surfaces[#surfaces + 1] = { "fork-vein.surface", { "space-location-name." .. planet }, string.format("%.1f", share) }
	end
	local control = data.raw["autoplace-control"][vein_control(m)]
	control.localised_description = { "", join(lines, "\n"), "\n",
		{ "fork-vein.stats", tostring(m.weight), tostring(m.density), tostring(m.size) }, "\n", join(surfaces, "\n") }
	local row = { mix = m.name, label = m.label, planets = planets, weight = m.weight, density = m.density, size = m.size }
	for _, role in ipairs(ROLES) do row[role] = ore_of(m, role) or "" end
	FORK_ORE_VEINS.table[#FORK_ORE_VEINS.table + 1] = row
end
--- (classic mode has no veins on the map: the raw ores say nothing there)
if not FORK_CLASSIC_ORES then
	for raw, list in pairs(found) do
		local it = data.raw.item[raw]
		if it then
			local line = { "fork-vein.found-in", join(list, ", ") }
			local desc = it.localised_description or { "item-description." .. raw }
			it.localised_description = { "?", { "", desc, "\n", line }, line }
		end
	end
end

--- the planets' own icons
for _, planet in pairs({ "gt-nether", "gt-twilight", "gt-end" }) do
	local p = data.raw.planet[planet]
	p.icon, p.icon_size = "__gregtorio-continued__/graphics/icons/" .. planet .. ".png", 64
	p.starmap_icon, p.starmap_icon_size = p.icon, 64
end
