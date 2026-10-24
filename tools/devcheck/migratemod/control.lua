--- Test helper for `devcheck.py migrate`. On the new map made with the older version (on_init) it builds a
--- small ME network with two loaded 1k fluid drives, a loaded drive outside any network, recovered fluid with no
--- network at its place and a chest with two loaded fluid drive items. Issue #68 step R2 turns all of them into
--- fluid cells: after the update the old drives must be ME Drives with four 1k fluid cells holding their fluid,
--- the recovered chlorine must be in the nearest drive with room, the items' water in fluid cells next to the
--- (untagged) items, the network must hold the drives' fluid, and the migration report must count the same units
--- before and after (DEVCHECK-MIGRATE-FLUIDS). Old saves with the cable network of R1 (`--from-ref` a commit
--- with R1) get the same, on a controller connected by cables. Versions without fluid drives are skipped.
--- It also builds a large naquadah reactor full of steam under load, which must be stopped after the
--- update (DEVCHECK-MIGRATE-POWER, issue #25), and a LuV plasma turbine on helium plasma under full load
--- with a turbine output hatch, which must run after the update and return one helium per plasma
--- (DEVCHECK-MIGRATE-TURBINE, issue #28).
--- Pattern providers (issue #27, issue #80): in the same network a Molecular Assembler and a fresh iron furnace
--- with providers; the furnace's provider has a recipe chosen (versions with the furnace choice). After the update
--- (issue #80: encoded patterns) the assembler's provider must hold a crafting pattern of the assembler's recipe and
--- the furnace's provider a processing pattern of the chosen recipe, both usable, and both items must be craftable
--- (DEVCHECK-MIGRATE-PATTERNS; FORK-ME-MIGRATE lines). Versions without pattern providers are skipped.
--- Crafting CPU (issue #38 changed its record to several job slots): the old save also has a powered CPU, a
--- drive with plates and sticks, and a gear job started with the old version on the assembler above. After
--- the update the job must finish with the gears in storage and the CPU must count as one job slot
--- (DEVCHECK-MIGRATE-JOB). A level maintainer of the old save (versions with it) keeps a few more gears: after
--- the job it must start a job of its own on the migrated pattern and reach its amount. Issue #206: me-network 0.5.1
--- removes the legacy CPU on load and queues its job; on the first tick a 2x2 multiblock CPU is built where it stood,
--- the job must be queued right after the load and then go on there. Issue #220: a save of me-network 0.5.1 or later
--- (no legacy blocks) gets the network of today's blocks, its job on a multiblock CPU built in the old save.
--- Issue #68 (the ME rework): the old save's ME network is a logistic network. It gets an old 1k drive with
--- items (also of another quality and a blueprint, which the new network cannot store), an old requester
--- interface with items in its inventory and its trash, an old terminal, a second old controller in the same
--- logistic network, a chest with 16 storage cells on one stack (cells become items with tags and stack size
--- 1), an old drive item in a chest and the ghost of an old drive. After the update every old entity must be
--- replaced, the network connected by cables (fluid drives, CPU, provider and terminal included), the item
--- totals of the old chests must be in the new network (job items aside, they move), the blueprint in an
--- overflow chest, the migration report without a difference, the cells and the old item kept
--- (DEVCHECK-MIGRATE-ITEMS).
local F = "gregtorio-me-fluids"
local NET = "gregtorio-me-network"
--- issue #552: the migration files of the old save's version (devcheck writes them into old-version.lua): Factorio runs a
--- migration once per save and marks every one of a new map's version as done, so a check of a migration the old version
--- has already is skipped
local ok_old, OLD = pcall(require, "old-version")
local OLD_MIGRATIONS = ok_old and OLD.migrations or {}
--- issue #563: the ore mode of the load (the startup setting of the new version; an old version has none: map veins or,
--- before 0.5.6, the vein recipes it had); a check of the update reads it, its set-up of the old save does not
local function classic_mode()
	local ok, s = pcall(function() return settings.startup["gregtorio-continued-ore-mode"] end)
	return ok and s ~= nil and s.value == "vein-recipes"
end
local DRIVE = "me-fluid-drive-1k"
local Y = 40
local TOTAL = { water = 40000, chlorine = 10000 }      -- drive 1: 32000 water, drive 2: 8000 water + 10000 chlorine
local LONE = { water = 500 }
local FL_D1, FL_D2, FL_LONE = { 8.5, Y + 3.5 }, { 10.5, Y + 3.5 }, { 120.5, Y + 0.5 }   -- the old fluid drives
local FL_ITEMS, FL_ITEM_WATER = { 30.5, Y + 25.5 }, 777       -- a chest with two loaded fluid drive items (issue #68, R2)
local OLD_POOL, OLD_POOL_AT = { chlorine = 700 }, { 60.5, Y + 0.5 }   -- recovered fluid of the old save, no network there

local function near(a, b) return math.abs((a or 0) - (b or 0)) <= 1e-3 end
local function same(a, b)
	for k, v in pairs(a) do if not near(v, b[k]) then return false end end
	for k, v in pairs(b) do if not near(v, a[k]) then return false end end
	return true
end

--- Endgame generators (issue #25): the old save has a UV large naquadah reactor full of steam under
--- full load (before the fuel check it burns steam). After the update it must be stopped with the
--- "Wrong fuel" status and keep its steam. Versions without the reactor are skipped.
local PW_REACTOR = "uv-large-naquadah-reactor"
local PW_POS = { 40.5, Y + 2.5 }
local PW_STEAM = 500

--- Issue #535: the old save is made in the Factorio of its version (2.0: LuaFluidBox) and loaded in 2.1 (the fluid methods
--- of LuaEntity); this helper runs in both. What `e` and the pipeline segment of its first box hold of `fluid`: 2.0's
--- get_fluid_count gave the entity's part and the segment contents the rest, 2.1's segment fluid is the whole segment
local major, minor = (script.active_mods.base or "2.0"):match("^(%d+)%.(%d+)")
local V21 = tonumber(major) > 2 or tonumber(minor) >= 1
local function fluid_total(e, fluid)
	if not V21 then
		local seg = e.fluidbox.get_fluid_segment_contents(1)
		return e.get_fluid_count(fluid) + ((seg and seg[fluid]) or 0)
	end
	if e.has_fluid_segment(1) then
		local f = e.get_fluid_segment_fluid(1)
		return f and f.name == fluid and f.amount or 0
	end
	return e.get_fluid_count(fluid)
end

local function steam_in(e)
	return fluid_total(e, "steam")
end

local function setup_power()
	if not prototypes.entity[PW_REACTOR] then
		storage.power = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-POWER skipped (no large naquadah reactor in this version)")
		return
	end
	local s = game.surfaces[1]
	local r = s.create_entity{ name = PW_REACTOR, position = PW_POS, force = "player", raise_built = true }
	local got = r.insert_fluid{ name = "steam", amount = PW_STEAM }
	local eei = s.create_entity{ name = "electric-energy-interface", position = { PW_POS[1], PW_POS[2] + 6 }, force = "player" }
	eei.power_production = 0
	eei.power_usage = 327.68e6 / 60
	eei.electric_buffer_size = 1e8
	s.create_entity{ name = "substation", position = { PW_POS[1] + 4, PW_POS[2] + 6 }, force = "player" }
	storage.power = { reactor = r, steam = got, stopped_before = r.disabled_by_script }
	log("DEVCHECK-MIGRATE-SETUP-POWER " .. (got == PW_STEAM and "ok" or "failed") .. " (reactor with " .. got .. " steam)")
end

local function check_power()
	local p = storage.power
	if p == nil or p == "skipped" then
		log("DEVCHECK-MIGRATE-POWER skipped")
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local r = p.reactor
	expect(r.valid, "the reactor is gone")
	local left = 0
	if r.valid then
		left = steam_in(r)
		local cs = r.custom_status
		expect(r.disabled_by_script, "the reactor on steam is not stopped")
		expect(cs and type(cs.label) == "table" and cs.label[1] == "entity-status.fork-wrong-fuel",
			"reactor status " .. serpent.line(cs))
		expect(math.abs(left - p.steam) < 1e-6, "the reactor holds " .. left .. " steam of " .. p.steam)
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL power: " .. m) end
	log("DEVCHECK-MIGRATE-POWER " .. (#problems == 0 and "ok" or "failed") .. string.format(" (steam %.1f of %.1f)", left, p.steam))
end

--- Plasma turbine (issue #28): placed with the old version (its old state), it must burn plasma after
--- the update and the hatch must get the cooled helium for it (hatch + owed + the energy of the current
--- step / fuel value, within 0.1 %), checked at tick 120. Versions without the turbine are skipped.
local TB = "luv-large-plasma-turbine"
local TB_POS = { 75.5, Y + 1.5 }
local TB_PLASMA, TB_POWER = 100, 81.92e6

local function setup_turbine()
	if not (prototypes.entity[TB] and prototypes.entity["turbine-output-hatch"]) then
		storage.turbine = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-TURBINE skipped (no plasma turbine in this version)")
		return
	end
	local s = game.surfaces[1]
	local t = s.create_entity{ name = TB, position = TB_POS, force = "player", raise_built = true }
	local got = t.insert_fluid{ name = "helium-plasma", amount = TB_PLASMA }
	local h = s.create_entity{ name = "turbine-output-hatch", position = { TB_POS[1] + 2, TB_POS[2] }, force = "player", raise_built = true }
	local eei = s.create_entity{ name = "electric-energy-interface", position = { TB_POS[1], TB_POS[2] + 6 }, force = "player" }
	eei.power_production = 0
	eei.power_usage = TB_POWER / 60
	eei.electric_buffer_size = TB_POWER / 60
	s.create_entity{ name = "substation", position = { TB_POS[1] + 4, TB_POS[2] + 6 }, force = "player" }
	storage.turbine = { turbine = t, hatch = h, plasma = got }
	log("DEVCHECK-MIGRATE-SETUP-TURBINE " .. (got == TB_PLASMA and "ok" or "failed") .. " (turbine with " .. got .. " helium plasma)")
end

local function check_turbine()
	local p = storage.turbine
	if p == nil or p == "skipped" then
		log("DEVCHECK-MIGRATE-TURBINE skipped")
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local t, h = p.turbine, p.hatch
	expect(t.valid and h.valid, "the turbine or its hatch is gone")
	local burnt, back = 0, 0
	if t.valid and h.valid then
		burnt = p.plasma - fluid_total(t, "helium-plasma")
		local P = "gregtorio-power"
		back = h.get_fluid_count("helium") + remote.call(P, "debt", t, "helium")
			+ remote.call(P, "energy", t) / prototypes.fluid["helium-plasma"].fuel_value
		expect(burnt > 0.2, "the turbine burnt only " .. burnt .. " plasma")
		expect(math.abs(back - burnt) <= 1e-3 + 1e-3 * burnt, "the turbine burnt " .. burnt .. " plasma and returned " .. back .. " helium")
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL turbine: " .. m) end
	log("DEVCHECK-MIGRATE-TURBINE " .. (#problems == 0 and "ok" or "failed") .. string.format(" (%.4f plasma -> %.4f helium)", burnt, back))
end

--- Issue #91: an update that adds recipes to technologies (or moves them) reaches existing saves through the
--- technology effect reset of Gregtorio's on_configuration_changed. The old save researches these technologies (and
--- their prerequisites); after the update every recipe that a researched technology unlocks must be enabled.
--- (issue #569: galena, invar and rubber need a reach technology since 0.5.6, which a save of 0.5.5 lacks)
local TT_TECHS = { "steam-compressor", "extruder", "end-steel", "alloy-blast-smelter", "industrial-mixer",
	"tier-three-microminers", "naquadah-processing", "uv-multiblocks", "osmium", "galena", "invar", "rubber" }
local TT_REACH = { ["reach-the-nether"] = true, ["reach-the-twilight-forest"] = true, ["reach-the-end"] = true }
local TT_CHECK_TICK = 60
--- issue #571: a second force of the steam age, which researched Steam Macerator (and its prerequisites of the old
--- version) but not Ore Crushing: after the update it keeps every recipe it had (the player's force has Ore Crushing)
local TT_STEAM_FORCE, TT_STEAM_TECHS = "devcheck-steam-age", { "steam-macerator" }
--- recipes that 0.5.9 moved to a later technology on purpose (in the changelog), so the steam age force loses them
local TT_STEAM_MOVED = {
	["dimension-mine"] = true,   -- issue #556: with Primitive Electronic Circuit Assemblies (before: Craft Wooden Tools)
	["gravel"] = true,           -- issue #560: the forge hammer's, with Steam Forge Hammer (before: Steam Macerator)
}

local function setup_techs()
	local n = 0
	local function research(force, name)
		local t = force.technologies[name]
		if not t or t.researched then return end
		for p, _ in pairs(t.prerequisites) do research(force, p) end
		t.researched = true
		n = n + 1
	end
	local force = game.forces.player
	for _, name in pairs(TT_TECHS) do research(force, name) end
	storage.tt_enabled = {}
	for name, r in pairs(force.recipes) do if r.enabled then storage.tt_enabled[name] = true end end
	local steam = game.forces[TT_STEAM_FORCE] or game.create_force(TT_STEAM_FORCE)
	for _, name in pairs(TT_STEAM_TECHS) do research(steam, name) end
	storage.tt_steam_enabled = {}
	for name, r in pairs(steam.recipes) do if r.enabled then storage.tt_steam_enabled[name] = true end end
	log("DEVCHECK-MIGRATE-SETUP-TECHS ok (" .. n .. " technologies researched)")
end

local function check_techs()
	if not storage.tt_enabled then
		log("DEVCHECK-MIGRATE-TECHS skipped")
		return
	end
	local problems, recipes, techs, new = {}, 0, 0, 0
	local function check(force, enabled, who)
		for name, t in pairs(force.technologies) do
			if t.researched then
				techs = techs + 1
				--- issue #569: a researched technology has its reach technologies researched
				for p in pairs(t.prerequisites) do
					if TT_REACH[p] and not force.technologies[p].researched then
						problems[#problems + 1] = who .. "the researched technology " .. name .. " needs " .. p .. ", which is not researched"
					end
				end
				for _, e in pairs(t.prototype.effects) do
					if e.type == "unlock-recipe" then
						local r = force.recipes[e.recipe]
						recipes = recipes + 1
						if not r.enabled then
							problems[#problems + 1] = who .. e.recipe .. " of the researched technology " .. name .. " is not enabled"
						elseif not enabled[e.recipe] then
							new = new + 1
						end
					end
				end
			end
		end
	end
	check(game.forces.player, storage.tt_enabled, "")
	--- issue #571: the steam age force keeps every recipe it had and gets the steam macerator's ore recipes
	local steam = storage.tt_steam_enabled and game.forces[TT_STEAM_FORCE]
	if steam then
		check(steam, storage.tt_steam_enabled, TT_STEAM_FORCE .. ": ")
		for name in pairs(storage.tt_steam_enabled) do
			if steam.recipes[name] and not steam.recipes[name].enabled and not TT_STEAM_MOVED[name] then
				problems[#problems + 1] = TT_STEAM_FORCE .. ": " .. name .. " was enabled before the update and is not now"
			end
		end
		for _, name in pairs({ "steam-crushed-copper", "steam-impure-copper-dust", "impure-copper-dust-smelter" }) do
			if steam.recipes[name] and not steam.recipes[name].enabled then
				problems[#problems + 1] = TT_STEAM_FORCE .. ": " .. name .. " is not enabled with Steam Macerator"
			end
		end
	end
	for i, m in pairs(problems) do
		if i > 20 then break end
		log("DEVCHECK-MIGRATE-FAIL techs: " .. m)
	end
	log("DEVCHECK-MIGRATE-TECHS " .. (#problems == 0 and "ok" or "failed") .. " (" .. recipes .. " recipes of " .. techs
		.. " researched technologies enabled, " .. new .. " of them new; " .. #problems .. " not enabled)")
end

--- Issues #98 and #96: fluids and items that an update removes are mapped to their nearest counterpart by the
--- JSON migrations of migrations/. The old save holds them in storage tanks and a chest; after the update the tanks
--- must hold the counterpart (the same amount) and the chest the counterpart items. Versions without them: skipped.
--- Issue #96: the old save also runs the GTCEu platinum line: machines with its recipes and their item inputs; after
--- the update a machine whose recipe is gone has none (`nil`), the others keep theirs (renamed: the new name).
--- A 5th field names an entity the change brought: an old version that has it already is past the change (row skipped).
local RM_FLUIDS = { ["exhausted-water"] = "water",
	["platinum-palladium-leachate"] = "platinum-concentrate", ["chloroplatinic-acid"] = "platinum-concentrate",
	["palladium-rich-ammonia"] = "palladium-enriched-ammonia",
	["acidic-iridium-dioxide-solution"] = "acidic-iridium-solution" }
local RM_ITEMS = { ["ammonia-hexachloroplatinate"] = "platinum-salt", ["crude-platinum-residue"] = "metallic-platinum-powder",
	["raw-platinum-powder"] = "reprecipitated-platinum", ["crude-palladium-residue"] = "palladium-salt",
	["raw-palladium-powder"] = "reprecipitated-palladium", ["platinum-group-residue"] = "platinum-residue",
	["potassium-pyrosulfate"] = "potassium-disulfate", ["iridium-dioxide-residue"] = "iridium-dioxide",
	["ammonia-hexachloroiridiate"] = "iridium-chloride",
	["advanced-card"] = "me-advanced-card",           -- issue #121
	["acceleration-card"] = "me-acceleration-card",   -- issue #195 (an item becomes me-network's module)
	["apatite-lens"] = "green-sapphire-lens", ["lapis-lens"] = "sapphire-lens",   -- issue #370
	["lv-air-collector"] = "lv-compressor", ["ev-air-collector"] = "ev-compressor",   -- issue #153
	["ev-greenhouse"] = "lv-greenhouse",   -- issue #165
	["small-lamp"] = "gt-torch" }   -- issue #555 (the item stays: mapped by its migration, RM_MIGRATION)
--- an item that stays in the game and is mapped only by its JSON migration: skipped when the old version has it (a save of
--- that version ran it); issue #555 also places a lamp, which must be a torch after the update
local RM_MIGRATION = { ["small-lamp"] = "2026-10-24-issue-555-torch.json" }
local RM_MACHINES = {
	{ "lv-chemical-reactor", "platinum-palladium-leachate-processing", nil },
	{ "lv-electrolyzer", "chloroplatinic-acid", nil },
	{ "lv-ore-washer", "palladium-dust", "crushed-palladium-washing" },
	{ "lv-mixer", "aqua-regia", "aqua-regia" },
	{ "mv-electric-blast-furnace", "platinum-group-residue-processing", "platinum-group-residue-processing" },
	{ "lv-chemical-reactor", "ammonia-hexachloroiridiate", nil },
	{ "lv-chemical-bath", "rhodium-sulfate-processing", nil },    -- the recipe stays, in the chemical reactor
	-- issue #152: every Extractor of an old save becomes the Fluid Extractor of its tier (the maintainer's choice): a melt
	-- keeps running, sticky resin is gone (an item recipe of the Extractor); a save made after the split keeps its Extractors
	{ "lv-extractor", "melt-iron-ingot", "melt-iron-ingot", "lv-fluid-extractor", "lv-fluid-extractor" },
	{ "lv-extractor", "sticky-resin", nil, "lv-fluid-extractor", "lv-fluid-extractor" },
	{ "ev-extractor", "melt-titanium-ingot", "melt-titanium-ingot", "ev-fluid-extractor", "lv-fluid-extractor" },
	-- issue #165: every greenhouse becomes the Extreme Industrial Greenhouse (lv-greenhouse), its recipe kept
	{ "hv-greenhouse", "growing-trees", "growing-trees", "lv-greenhouse" },
	-- issue #171: annealed copper moved to the Arc Furnace, the old electric blast furnace loads without it
	{ "mv-electric-blast-furnace", "annealed-copper-ingot", nil },
	-- issue #173: the printed circuits moved to the Forming Press, the old circuit assembler loads without them
	{ "lv-circuit-assembler", "printed-silicon", nil },
	-- issue #185: the ore washer and centrifuge shortcuts are mapped onto the ore chain's recipes
	{ "lv-ore-washer", "iron-dust", "purified-iron" },
	{ "lv-centrifuge", "centrifuging-crushed-iron", "centrifuging-impure-iron-dust" },
	-- issue #153: an Air Collector becomes the compressor of its tier and keeps making air (checked by the entity's
	-- name below)
	{ "lv-air-collector", "air-collection", "air-collection", "lv-compressor" },
	{ "hv-air-collector", "air-collection", "air-collection", "hv-compressor" },
	-- issue #202: the macerator recipe of Raw Cassiterite (crushed-tin) is crushed-cassiterite since it has its own crushed ore
	{ "lv-macerator", "crushed-tin", "crushed-cassiterite" },
	-- issue #203: the macerator recipes of Raw Gypsum, Sulfur and Calcite keep their names and make the crushed ore
	{ "lv-macerator", "gypsum", "gypsum" },
	{ "lv-macerator", "sulfur", "sulfur" },
	{ "lv-macerator", "calcite", "calcite" },
	-- issue #317: vanilla recipes deleted for good (no technology unlocked them, the old save enables them by script); a
	-- machine of an old save loads without its recipe
	{ "chemical-plant", "battery", nil },
	{ "foundry", "casting-iron", nil },
	-- issue #316: a laser engraver's gem step keeps its recipe; the lens it took as an ingredient goes into its lens slot
	{ "ev-laser-engraver", "engraving-chipped-ruby-to-flawed", "engraving-chipped-ruby-to-flawed" },
	-- issue #325: a wafer engraving recipe that took no lens before gets its lens (the ruby lens) in the lens slot
	{ "mv-laser-engraver", "ilc-wafer-sw", "ilc-wafer-sw" },
	-- issue #332: the simple SoC wafer took no lens before (also after #325); it gets the amber lens in the slot, or, in a
	-- save that had the slot already, stops with "Missing lens"
	{ "mv-laser-engraver", "simple-soc-wafer-sw", "simple-soc-wafer-sw" },
	-- issue #335: the Manual Mine got a fast replace group and the Ore Drilling Plant as its next upgrade; issue #499: the
	-- name went to the mining drill, a Manual Mine of an old save is a Dimension Mine (JSON migration); issue #500: one on
	-- an Overworld vein (hidden since #499) is replaced by the Manual Mine drill at its place, with its manual labor as fuel
	-- (issue #563: in classic mode the Dimension Mine keeps the recipe, the 7th field)
	{ "manual-mine", "mining-iron-vein", nil, "manual-mine", nil, true, { "mining-iron-vein", "dimension-mine" } },
	-- issue #505: the vein recipes of Nauvis, the Nether and the Twilight Forest left map-vein mode; a mine on Nauvis on a
	-- Nether vein stays a Dimension Mine without a recipe (issue #563: classic mode keeps the recipe)
	{ "manual-mine", "mining-tetrahedrite-vein", nil, "dimension-mine", nil, nil, { "mining-tetrahedrite-vein", "dimension-mine" } },
	-- issue #563: 0.5.5's chalcopyrite vein is GT's Copper: the drill in map-vein mode, mining-copper-vein in classic mode
	{ "manual-mine", "mining-chalcopyrite-vein", nil, "manual-mine", nil, true, { "mining-copper-vein", "dimension-mine" } },
	-- issue #569: 0.5.5's galena vein (Galena) is the Twilight Forest's: in map-vein mode its mine loses the recipe, in
	-- classic mode it runs GT's TFGalena vein, unlocked by Reach the Twilight Forest, which the update researches
	{ "manual-mine", "mining-galena-vein", nil, "dimension-mine", nil, nil, { "mining-tf-galena-vein", "dimension-mine", true } },
	-- issue #527: a Manual Mine's recipe that moved to the Dig Site (#499) or needs the Nether (#501) is a placeholder on
	-- load (JSON), which the migration clears with a message
	{ "manual-mine", "hunting-blazes", nil, "dimension-mine" },
	{ "manual-mine", "cobblestone-manual-mine", nil, "dimension-mine" },
	{ "manual-mine", "mining-glowstone-vein", nil, "dimension-mine" },
	-- issue #348: upstream's Ruby Lens from a plain ruby is deleted; a lathe of an old save loads without the recipe
	{ "lv-lathe", "ruby-lens", nil },
	-- issue #370: GTNH's green sapphire and sapphire lens replace the apatite and lapis lens; an engraver of an old save
	-- has the new lens in its slot (JSON migration), a lathe loads without the old lens recipe
	{ "mv-laser-engraver", "ram-wafer-sw", "ram-wafer-sw" },
	{ "mv-laser-engraver", "engraving-chipped-lapis-to-flawed", "engraving-chipped-lapis-to-flawed" },
	{ "lv-lathe", "apatite-lens-from-exquisite", nil },
}
--- Issue #317: a character of the old save has a hand craft of a deleted vanilla recipe in its queue; after the update the
--- save loads, the character is there and its queue is empty. The game drops the craft with its ingredients (they are
--- neither in the inventory nor on the ground), which only a script could cause: no technology ever unlocked the recipe.
local RM_QUEUED = { recipe = "small-lamp", count = 3 }
local RM_AT = { -30.5, Y + 30.5 }

local function setup_removed()
	local s, list = game.surfaces[1], {}
	s.request_to_generate_chunks(RM_AT, 2)
	s.force_generate_chunk_requests()
	local x = RM_AT[1]
	for old, new in pairs(RM_FLUIDS) do
		if prototypes.fluid[old] then
			local t = s.create_entity{ name = "storage-tank", position = { x, RM_AT[2] }, force = "player" }
			list[#list + 1] = { tank = t, old = old, new = new, amount = t.insert_fluid{ name = old, amount = 1000 } }
			x = x + 4
		end
	end
	local chest = s.create_entity{ name = "iron-chest", position = { RM_AT[1], RM_AT[2] + 4 }, force = "player" }
	local items = {}
	for old, new in pairs(RM_ITEMS) do
		if prototypes.item[old] and not OLD_MIGRATIONS[RM_MIGRATION[old] or ""] then
			items[#items + 1] = { old = old, new = new, count = chest.insert{ name = old, count = 5 } }
		end
	end
	local lamp
	if prototypes.entity["small-lamp"] and not OLD_MIGRATIONS[RM_MIGRATION["small-lamp"]] then
		lamp = { 2 + RM_AT[1], RM_AT[2] + 4 }
		s.create_entity{ name = "small-lamp", position = lamp, force = "player" }
	end
	local machines = {}
	for i, m in pairs(RM_MACHINES) do
		local r = prototypes.recipe[m[2]]
		--- (a version after #499, whose mines are mining drills, skips the rows of the old recipe machines)
		if prototypes.entity[m[1]] and prototypes.entity[m[1]].type == "assembling-machine" and r
			and not (m[5] and prototypes.entity[m[5]]) then
			local e = s.create_entity{ name = m[1], position = { RM_AT[1] + 8 * (i - 1), RM_AT[2] + 12 }, force = "player",
				raise_built = true }
			game.forces.player.recipes[m[2]].enabled = true
			e.set_recipe(m[2])
			local items = {}
			for _, ing in pairs(r.ingredients) do
				if ing.type == "item" then
					e.insert{ name = ing.name, count = ing.amount * 2 }
					items[ing.name] = true
				end
			end
			--- a version with the slot: the recipe's mold or lens goes into it, as a player's would
			local md = prototypes.mod_data["fork-mold-recipes"]
			local tool = md and md.data[m[2]]
			local inv = e.get_module_inventory()
			if tool and inv then inv.insert{ name = tool } end
			--- issue #332: a slot that this version leaves empty (its recipe needs no tool here)
			local empty_slot = md ~= nil and tool == nil and inv ~= nil and #inv > 0
			machines[#machines + 1] = { entity = e, old = m[2], new = m[3], name = m[4], items = items,
				empty_slot = empty_slot, pos = e.position, drill = m[6], machine = m[1], classic = m[7] }
		end
	end
	local queue
	local qr = prototypes.recipe[RM_QUEUED.recipe]
	if qr then
		local c = s.create_entity{ name = "character", position = { RM_AT[1], RM_AT[2] + 20 }, force = "player" }
		game.forces.player.recipes[RM_QUEUED.recipe].enabled = true
		for _, ing in pairs(qr.ingredients) do c.insert{ name = ing.name, count = ing.amount * RM_QUEUED.count } end
		queue = { character = c, queued = c.begin_crafting{ recipe = RM_QUEUED.recipe, count = RM_QUEUED.count } }
	end
	if #list == 0 and #items == 0 and #machines == 0 and not queue and not lamp then
		storage.removed = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-REMOVED skipped (none of the removed fluids or items in this version)")
		return
	end
	storage.removed = { tanks = list, chest = chest, items = items, machines = machines, queue = queue, lamp = lamp,
		had_veins = (s.map_gen_settings.property_expression_names or {}).gt_vein_id ~= nil }
	log("DEVCHECK-MIGRATE-SETUP-REMOVED ok (" .. #list .. " fluids in tanks, " .. #items .. " items in a chest, "
		.. #machines .. " machines with recipes of the old line"
		.. (queue and (", " .. queue.queued .. " hand crafts of " .. RM_QUEUED.recipe .. " queued") or "") .. ")")
end

local function check_removed()
	local p = storage.removed
	if p == nil or p == "skipped" then
		log("DEVCHECK-MIGRATE-REMOVED skipped")
		return
	end
	local problems = {}
	for _, e in pairs(p.tanks) do
		local got = e.tank.valid and e.tank.get_fluid_count(e.new) or 0
		if math.abs(got - e.amount) > 1e-3 then
			problems[#problems + 1] = e.old .. ": the tank holds " .. got .. " " .. e.new .. " of " .. e.amount
		end
	end
	local want = {}
	for _, e in pairs(p.items) do want[e.new] = (want[e.new] or 0) + e.count end
	for name, count in pairs(want) do
		local got = p.chest.valid and p.chest.get_item_count(name) or 0
		if got ~= count then problems[#problems + 1] = "the chest holds " .. got .. " " .. name .. " of " .. count end
	end
	for _, m in pairs(p.machines or {}) do
		if classic_mode() and m.classic then
			m = { entity = m.entity, old = m.old, new = m.classic[1], name = m.classic[2], items = m.items, pos = m.pos,
				researched = m.classic[3] }
			--- issue #569: the mine runs, its recipe is unlocked for the force
			if m.researched and not game.forces.player.recipes[m.new].enabled then
				problems[#problems + 1] = "the machine with " .. m.old .. " has " .. m.new .. ", which is not researched"
			end
		end
		--- issue #500: a mine on an Overworld vein became a mining drill at its place
		local drill = m.drill and m.pos and game.surfaces[1].find_entity(m.name, m.pos)
		if m.drill and not (drill and drill.type == "mining-drill") then
			problems[#problems + 1] = "the machine with " .. m.old .. " is no " .. m.name .. " drill at its place"
		elseif drill and m.items["manual-labor"] and drill.get_fuel_inventory().get_item_count("manual-labor") == 0 then
			problems[#problems + 1] = "the " .. m.name .. " drill got no manual labor of the old mine as fuel"
		end
		--- issue #560: an ore machine of an old save is a furnace now, built in its place (scripts/fork-ore-furnaces.lua); it
		--- has no recipe set but picks the new recipe from the old one's ingredients it holds
		local furnace = not m.drill and not m.entity.valid and m.pos and game.surfaces[1].find_entity(m.name or m.machine, m.pos)
		if furnace and furnace.type == "furnace" then m.entity = furnace else furnace = nil end
		local r = not m.drill and m.entity.valid and m.entity.get_recipe()
		local got = r and r.name or nil
		if furnace and not got and m.new then
			for _, ing in pairs(prototypes.recipe[m.new].ingredients) do
				if ing.type == "item" and m.items[ing.name] and furnace.get_item_count(ing.name) > 0 then got = m.new end
			end
		end
		if m.drill then
			-- (checked above)
		elseif not m.entity.valid then
			problems[#problems + 1] = "the machine with " .. m.old .. " is gone"
		elseif got ~= m.new then
			problems[#problems + 1] = "the machine with " .. m.old .. " has " .. tostring(got) .. ", not " .. tostring(m.new)
		elseif m.name and m.entity.name ~= m.name then
			problems[#problems + 1] = "the machine with " .. m.old .. " is a " .. m.entity.name .. ", not a " .. m.name
		end
	end
	--- issue #500: the old save's generated chunks have the map veins' ores (regenerate_entity)
	local gt = {}
	for name, r in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "resource" } }) do
		if r.resource_category == "gt-ore" then gt[#gt + 1] = name end
	end
	local vein_tiles = #gt > 0 and game.surfaces[1].count_entities_filtered{ type = "resource", name = gt, limit = 1 } or 0
	if classic_mode() and not p.had_veins then
		--- issue #563: a save without the veins gets none in classic mode
		if vein_tiles > 0 then problems[#problems + 1] = "the old save's chunks got ore of the map veins in classic mode" end
	elseif #gt > 0 and vein_tiles == 0 then
		problems[#problems + 1] = "the old save's chunks have no ore of the map veins"
	end
	--- issues #316 and #325: a machine whose recipe needs a mold or lens in its slot has it there after the update and
	--- runs (the old recipe took it as an ingredient, or none; fork-molds gives a machine new to the slot its tool once);
	--- issue #332: a machine that had the slot already, empty for its recipe, stops instead until a player puts the tool in
	local md = prototypes.mod_data["fork-mold-recipes"]
	local tools = md and md.data or {}
	local stopped = 0
	for _, m in pairs(p.machines or {}) do
		local tool = m.new and tools[m.new]
		if tool and m.entity.valid and m.empty_slot then
			local inv = m.entity.get_module_inventory()
			if inv and inv.get_item_count(tool) > 0 then
				problems[#problems + 1] = "the machine with " .. m.new .. " got a " .. tool .. " although it had the slot"
			elseif not m.entity.disabled_by_script then
				problems[#problems + 1] = "the machine with " .. m.new .. " runs without its " .. tool
			else
				stopped = stopped + 1
				log("DEVCHECK-MIGRATE removed: the machine with " .. m.new .. " stops: "
					.. serpent.line(m.entity.custom_status and m.entity.custom_status.label))
			end
		elseif tool and m.entity.valid then
			local inv = m.entity.get_module_inventory()
			if not (inv and inv.get_item_count(tool) == 1) then
				problems[#problems + 1] = "the machine with " .. m.new .. " has no " .. tool .. " in its slot"
			elseif m.entity.disabled_by_script then
				problems[#problems + 1] = "the machine with " .. m.new .. " is stopped with its " .. tool .. " in the slot"
			end
		end
	end
	--- issue #555: the placed small lamp is a torch at its place
	if p.lamp then
		local s = game.surfaces[1]
		if not s.find_entity("gt-torch", p.lamp) or s.find_entity("small-lamp", p.lamp) then
			problems[#problems + 1] = "the old save's small lamp is no torch at its place"
		end
	end
	local q = p.queue
	if q then
		local c = q.character
		if not c.valid then
			problems[#problems + 1] = "the character with the queued " .. RM_QUEUED.recipe .. " is gone"
		elseif c.crafting_queue_size ~= 0 then
			problems[#problems + 1] = "the crafting queue still holds " .. c.crafting_queue_size .. " entries"
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL removed: " .. m) end
	log("DEVCHECK-MIGRATE-REMOVED " .. (#problems == 0 and "ok" or "failed") .. " (" .. #p.tanks .. " fluids, "
		.. #p.items .. " items mapped, " .. #(p.machines or {}) .. " machines checked, " .. stopped .. " stopped for their tool"
		.. (p.lamp and ", the small lamp a torch" or "")
		.. (q and (", queued " .. RM_QUEUED.recipe .. " dropped") or "") .. ")")
end

local A = "gregtorio-me-autocraft"
local PT_ASSEMBLER, PT_FURNACE = { 14.5, Y + 8.5 }, { 19, Y + 13 }
local PT_PROVIDER_A, PT_PROVIDER_F = { 16.5, Y + 8.5 }, { 17.5, Y + 12.5 }
--- issue #157 (me-network #131, 0.5.0): the assembler is one tile; it stands next to its provider, where the 3x3 one of
--- older versions had its edge (its centre two tiles away)
local PT_ASSEMBLER_1 = { 15.5, Y + 8.5 }
local function one_tile_assembler() return prototypes.entity["me-molecular-assembler"].tile_width == 1 end
local PT_RECIPE, PT_FURNACE_RECIPE = "iron-gear-crafting-table", "iron-dust-smelter"
--- me-network 0.5.0 moved the encoding of a pattern given as data to the ME Pattern Terminal
local PATTERN_TERMINAL = "gregtorio-me-pattern-terminal"
local JOB_GEARS = 5
local MAINT_POS, MAINT_KEEP = { 5.5, Y + 16.5 }, JOB_GEARS + 3        -- a level maintainer of the old save (issue #38)
local CHECK_TICK = 570                                                  -- the job and the maintainer are checked here
--- issue #206 (me-network #145): me-network 0.5.1 has no legacy Crafting CPU; the 2x2 multiblock CPU built where it stood
local CPU_BLOCKS = { { "me-1k-crafting-storage", 8.5, Y + 8.5 }, { "me-crafting-unit", 9.5, Y + 8.5 },
	{ "me-crafting-unit", 8.5, Y + 9.5 }, { "me-crafting-unit", 9.5, Y + 9.5 } }

--- the version of the old save has the cable network of issue #68 step R1 (and still the old fluid drives)
function R1() return prototypes.entity["me-network-controller"] ~= nil end
--- the version of the old save stores fluids in fluid cells already (issue #68 step R2, 0.4.0 and later: the fluid
--- module has no `unpack_drive` any more): there are no fluid drives to convert, the network of the pattern, job and
--- maintainer checks is built without them
function R2() return remote.interfaces[F] ~= nil and not remote.interfaces[F].unpack_drive end
--- issue #220: me-network 0.5.1 and later (me-network #146) have no legacy blocks (no ME fluid drives, no old controller,
--- no legacy Crafting CPU): the network of the pattern, job and maintainer checks is built of today's blocks, the job of the
--- old save runs on a multiblock CPU (a 1k crafting storage and three crafting units)
function UNIFIED() return prototypes.entity["me-network-controller"] ~= nil and prototypes.entity["me-controller"] == nil end

--- after the ME network of the fluid drives exists (its controller)
local function setup_patterns(place)
	if not (remote.interfaces[A] and prototypes.entity["me-pattern-provider"]) then
		storage.patterns = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-PATTERNS skipped (no pattern providers in this version)")
		return
	end
	local at = one_tile_assembler() and PT_ASSEMBLER_1 or PT_ASSEMBLER
	local m = place("me-molecular-assembler", at[1], at[2])
	m.force.recipes[PT_RECIPE].enabled = true
	m.set_recipe(PT_RECIPE)
	place("me-pattern-provider", PT_PROVIDER_A[1], PT_PROVIDER_A[2])
	place("iron-furnace", PT_FURNACE[1], PT_FURNACE[2])
	local p = place("me-pattern-provider", PT_PROVIDER_F[1], PT_PROVIDER_F[2])
	if R1() then                                       -- the providers need cables to the controller
		remote.call(NET, "connect", { game.surfaces[1].find_entity("me-network-controller", { 6, Y }),
			game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A), p }, 16)
	end
	--- versions with encoded patterns (issue #80, 0.5.0 and later): the providers get a crafting pattern of the
	--- assembler's recipe and a processing pattern of the furnace recipe, encoded through the terminal's function
	local choice = false
	if remote.interfaces[A].insert_pattern then
		local function key(x) return x.type == "fluid" and ("fluid/" .. x.name) or x.name end
		local function rows(list)
			local out = {}
			for _, x in pairs(list) do out[#out + 1] = { key = key(x), amount = x.amount } end
			return out
		end
		p.force.recipes[PT_FURNACE_RECIPE].enabled = true
		local fr = prototypes.recipe[PT_FURNACE_RECIPE]
		local inv = game.create_inventory(2)
		for _, give in pairs({
			{ game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A), { kind = "crafting", recipe = PT_RECIPE } },
			{ p, { kind = "processing", inputs = rows(fr.ingredients), outputs = rows(fr.products), recipe = PT_FURNACE_RECIPE } },
		}) do
			inv.insert{ name = "me-blank-pattern", count = 1 }
			if remote.interfaces[PATTERN_TERMINAL] and remote.interfaces[PATTERN_TERMINAL].encode_def then
				remote.call(PATTERN_TERMINAL, "encode_def", inv, nil, give[2])   -- me-network 0.5.0 and later (issue #206)
			else
				remote.call("gregtorio-me-terminal", "encode_def", false, inv, false, give[2])
			end
			local stack = inv.find_item_stack("me-encoded-pattern")
			choice = (stack and remote.call(A, "insert_pattern", give[1], stack)) and true or false
			inv.clear()
		end
		inv.destroy()
	end
	local set = {}
	for _, k in pairs(remote.call(A, "craftable", p)) do set[k] = true end
	--- the furnace's recipe, chosen in its provider (versions with the choice, issue #27)
	if remote.interfaces[A].set_recipe and not remote.interfaces[A].insert_pattern then
		p.force.recipes[PT_FURNACE_RECIPE].enabled = true
		choice = remote.call(A, "set_recipe", p, PT_FURNACE_RECIPE) == true
	end
	--- encoded: the old version keeps encoded patterns in its providers (issue #80); before it, the provider of a 3x3
	--- assembler loses its pattern on the way through me-network 0.5.0 (issue #219)
	storage.patterns = { provider = p, ok = set["iron-gear-wheel"] == true, choice = choice,
		encoded = remote.interfaces[A].insert_pattern ~= nil,
		assembler_provider = game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A) }
	log("DEVCHECK-MIGRATE-SETUP-PATTERNS " .. (set["iron-gear-wheel"] and "ok" or "failed") .. (choice and " (furnace recipe chosen)" or ""))
	--- a job of the old version on a crafting CPU (own power for the CPU and the assembler)
	local eei = place("electric-energy-interface", 12, Y + 15)
	eei.power_production = 1e6
	eei.electric_buffer_size = 1e7
	place("substation", 12, Y + 12)
	local cpus = {}
	if prototypes.entity["me-crafting-cpu"] then
		cpus[1] = place("me-crafting-cpu", 9, Y + 9)
	else
		for _, blk in pairs(CPU_BLOCKS) do cpus[#cpus + 1] = place(blk[1], blk[2], blk[3]) end
	end
	local drive
	if R1() then                                       -- the cable network of issue #68 (R1): a drive with cells
		drive = place("me-drive", 8.5, Y + 12.5)
		local inv = game.create_inventory(1)
		for slot = 1, 4 do
			inv[1].set_stack{ name = "me-16k-storage-cell", count = 1 }
			remote.call(NET, "insert_cell", drive, inv[1], slot)
		end
		inv.destroy()
		remote.call(NET, "store_in_drive", drive, "iron-plate", 50)
		remote.call(NET, "store_in_drive", drive, "iron-stick", 50)
		--- issue #580 (me-network #503): lenses that issue #370 renamed (apatite -> green sapphire, lapis -> sapphire) in the
		--- network: its storage keeps them under their old names, which a JSON migration does not reach
		if prototypes.item["apatite-lens"] and prototypes.item["lapis-lens"] then
			remote.call(NET, "store_in_drive", drive, "apatite-lens", ME_LENSES[1])
			remote.call(NET, "store_in_drive", drive, "lapis-lens", ME_LENSES[2])
			storage.me_lenses = { drive = drive }
		end
		local ctrl = game.surfaces[1].find_entity("me-network-controller", { 6, Y })
		local members = { ctrl, drive, p, game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A) }
		for _, c in pairs(cpus) do members[#members + 1] = c end
		if storage.fluid_old then
			members[#members + 1] = storage.fluid_old.e1
			members[#members + 1] = storage.fluid_old.e2
		end
		remote.call(NET, "connect", members, 16)
	else
		drive = place("me-drive-16k", 8.5, Y + 12.5)
		drive.insert{ name = "iron-plate", count = 50 }
		drive.insert{ name = "iron-stick", count = 50 }
	end
	local id, why = remote.call(A, "start", p, "iron-gear-wheel", JOB_GEARS)
	--- crafting CPUs are multiblocks since me-network 0.3.0 (issue #6): a lone ME Crafting CPU is no CPU there, no job
	--- (a version without the legacy CPU has the multiblock one built above: a job that does not start there fails)
	local no_cpu = not id and why == "no-free-cpu" and prototypes.entity["me-crafting-unit"] and prototypes.entity["me-crafting-cpu"]
	storage.job = { id = id, provider = p, skipped = no_cpu and true or nil,
		multiblock = not prototypes.entity["me-crafting-cpu"] or nil }
	log("DEVCHECK-MIGRATE-SETUP-JOB " .. (id and "ok" or no_cpu and "skipped (crafting CPUs are multiblocks since me-network 0.3.0)"
		or ("failed (" .. tostring(why) .. ")")))
	--- a level maintainer keeping a few more gears than the job makes (it waits while the job runs)
	if R1() and prototypes.entity["me-level-maintainer"] and remote.interfaces["gregtorio-me-circuit"] then
		local m = place("me-level-maintainer", MAINT_POS[1], MAINT_POS[2])
		remote.call(NET, "connect", { game.surfaces[1].find_entity("me-network-controller", { 6, Y }), m }, 16)
		local ok = remote.call("gregtorio-me-circuit", "set_maintainer", m, "iron-gear-wheel", MAINT_KEEP, false)
		storage.job.maintainer = ok and m or nil
		log("DEVCHECK-MIGRATE-SETUP-MAINTAINER " .. (ok and "ok" or "failed"))
	end
end

--- issue #580: the lenses of the old save are green sapphire and sapphire lenses in the network now (ME_NETWORK.replace_item
--- with prototypes/data/item-renames.lua), none under the old names, and a circuit interface built on it writes their signals
--- (the crash of me-network #503 was the first write of one)
ME_LENSES = { 7, 3 }
local function check_me_lenses()
	local st = storage.me_lenses
	if not st then
		log("DEVCHECK-MIGRATE-MELENSES skipped (no apatite or lapis lens in this version, or no cable network)")
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local d = st.drive
	local contents = d.valid and remote.call(NET, "contents", d) or {}
	local old = {}
	for key, n in pairs(contents) do
		local name = key:match("^[^@#]*")
		if name == "apatite-lens" or name == "lapis-lens" then old[#old + 1] = key .. " " .. n end
	end
	expect(#old == 0, "the network still holds the old lenses: " .. table.concat(old, ", "))
	expect(contents["green-sapphire-lens"] == ME_LENSES[1] and contents["sapphire-lens"] == ME_LENSES[2],
		"green sapphire and sapphire lenses in the network: " .. tostring(contents["green-sapphire-lens"]) .. ", "
		.. tostring(contents["sapphire-lens"]) .. " (want " .. ME_LENSES[1] .. ", " .. ME_LENSES[2] .. ")")
	local s, ci = d.surface, nil
	for _, off in ipairs({ { 0, 1 }, { 0, -1 }, { 1, 0 }, { -1, 0 } }) do
		local pos = { d.position.x + off[1], d.position.y + off[2] }
		if s.can_place_entity{ name = "me-circuit-interface", position = pos, force = "player" } then
			ci = s.create_entity{ name = "me-circuit-interface", position = pos, force = "player", raise_built = true }
			break
		end
	end
	local info = ci and remote.call("gregtorio-me-circuit", "get_circuit", ci)
	local lens
	for _, f in pairs(ci and ci.get_or_create_control_behavior().get_section(1).filters or {}) do
		if f.value and f.value.name == "green-sapphire-lens" then lens = f.min end
	end
	expect(info and info.signals and info.signals > 0 and lens == ME_LENSES[1], "a circuit interface built next to the drive: "
		.. serpent.line(info) .. ", its green sapphire lens signal " .. tostring(lens))
	for _, p in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL ME lenses: " .. p) end
	log("DEVCHECK-MIGRATE-MELENSES " .. (#problems == 0 and "ok" or "failed") .. " (" .. ME_LENSES[1] .. " apatite and "
		.. ME_LENSES[2] .. " lapis lenses of the old save are green sapphire and sapphire lenses in the network, a circuit "
		.. "interface built on it writes their signals)")
end

local function check_job()
	local st = storage.job
	if not (st and st.id) then
		log("DEVCHECK-MIGRATE-JOB " .. (st and not st.skipped and "failed (no job in the old save)" or "skipped"))
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local j = remote.call(A, "job", st.id)
	--- issue #206: the legacy CPU is gone; the job was queued with what it held and went on on the multiblock CPU
	if st.after then
		expect(st.after == "queued", "the job of the old save right after the load (its legacy CPU is gone): " .. st.after)
	end
	local m = game.surfaces[1].find_entity("me-molecular-assembler", PT_ASSEMBLER)
		or game.surfaces[1].find_entity("me-molecular-assembler", PT_ASSEMBLER_1)
	local status = "gone"
	if m then for k, v in pairs(defines.entity_status) do if v == m.status then status = k end end end
	expect(j and j.status == "done", "the job of the old save: " .. serpent.line(j) .. ", assembler " .. status
		.. " progress " .. (m and m.crafting_progress or -1))
	local p = st.provider
	if p.valid then
		local gears
		if remote.interfaces[NET] then
			gears = remote.call(NET, "count", p, "iron-gear-wheel")
		else
			local net = p.surface.find_logistic_network_by_position(p.position, p.force)
			gears = net and net.get_item_count{ name = "iron-gear-wheel", quality = "normal" } or 0
		end
		expect(gears >= JOB_GEARS, "gears in storage after the job: " .. gears)
		local n, free, _, slots = remote.call(A, "cpus", p)
		expect(n == 1 and slots == 1 and free == 1, "the CPU: " .. n .. " CPUs, " .. tostring(slots) .. " slots, " .. free .. " free")
		--- the maintainer of the old save: a job of its own on the migrated pattern after the old job, its amount reached
		local m = st.maintainer
		if m then
			local own = false
			for _, job in pairs(remote.call(A, "jobs", p)) do
				if job.item == "iron-gear-wheel" and job.owner == m.unit_number and job.status == "done" then own = true end
			end
			expect(m.valid and own, "the maintainer of the old save did not finish a job: " .. serpent.line(remote.call("gregtorio-me-circuit", "get_maintainer", m)))
			expect(gears >= MAINT_KEEP, "gears with the maintainer: " .. gears .. ", it keeps " .. MAINT_KEEP)
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL job: " .. m) end
	log("DEVCHECK-MIGRATE-JOB " .. (#problems == 0 and "ok" or "failed") .. (st.maintainer and " (and the level maintainer's job)" or "")
		.. (st.after and " (legacy CPU gone: the job was queued and went on on a multiblock CPU)" or ""))
end

local function check_patterns()
	local st = storage.patterns
	if st == nil or st == "skipped" then
		log("DEVCHECK-MIGRATE-PATTERNS skipped")
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local p = st.provider
	local function craftable()
		local set = {}
		for _, k in pairs(remote.call(A, "craftable", p)) do set[k] = true end
		return set
	end
	expect(st.ok, "the assembler was no pattern in the old save")
	expect(p.valid and st.assembler_provider and st.assembler_provider.valid, "an old provider is gone")
	local note = ""
	if p.valid and st.assembler_provider and st.assembler_provider.valid then
		--- issue #157: a 3x3 assembler of an older version is one tile after the update, its centre where it was: its
		--- provider has no machine (as me-network's own migrate test checks); the player moves it next to the provider
		local old = game.surfaces[1].find_entity("me-molecular-assembler", PT_ASSEMBLER)
		if old and one_tile_assembler() then
			local slot = (remote.call(A, "provider_info", st.assembler_provider) or { slots = {} }).slots[1]
			if st.encoded then
				expect(slot and not slot.ok and slot.machines == 0,
					"the provider still points at the one-tile assembler two tiles away: " .. serpent.line(slot))
			else
				--- issue #219: a save from before the encoded patterns (issue #80) goes through me-network 0.5.0, which makes
				--- the assembler one tile before it turns the providers' recipes into patterns: the assembler's centre is
				--- two tiles from its provider, so the provider gets no pattern at all (a player's provider is empty too)
				expect(slot == nil, "the provider of the 3x3 assembler got a pattern through the intermediate load: "
					.. serpent.line(slot))
			end
			local recipe = old.get_recipe()
			old.destroy{ raise_destroy = true }
			local moved = game.surfaces[1].create_entity{ name = "me-molecular-assembler", position = PT_ASSEMBLER_1,
				force = "player", raise_built = true }
			if moved and recipe then moved.set_recipe(recipe) end
			expect(moved ~= nil, "the assembler could not be moved next to its provider")
			note = " (the one-tile assembler moved next to its provider)"
			if not st.encoded and moved then
				--- as a player: encode the crafting pattern again in the ME Pattern Terminal and put it into the provider
				local inv = game.create_inventory(2)
				inv.insert{ name = "me-blank-pattern", count = 1 }
				remote.call(PATTERN_TERMINAL, "encode_def", inv, nil, { kind = "crafting", recipe = PT_RECIPE })
				local stack = inv.find_item_stack("me-encoded-pattern")
				expect(stack and remote.call(A, "insert_pattern", st.assembler_provider, stack),
					"the crafting pattern could not be encoded again and put into the provider")
				inv.destroy()
				note = note .. " (its pattern encoded again, as before issue #80 the provider is empty after the update)"
			end
		end
		--- issue #80: the providers hold encoded patterns for what they provided
		p.force.recipes[PT_FURNACE_RECIPE].enabled = true
		local ia = remote.call(A, "provider_info", st.assembler_provider)
		local a1 = ia and ia.slots[1]
		expect(a1 and a1.kind == "crafting" and a1.recipe == PT_RECIPE and a1.ok and not ia.slots[2],
			"the assembler's provider after the update: " .. serpent.line(ia and ia.slots))
		expect(craftable()["iron-gear-wheel"], "the assembler is no pattern after the update")
		local fi = remote.call(A, "provider_info", p)
		local f1 = fi and fi.slots[1]
		if st.choice then
			expect(f1 and f1.kind == "processing" and f1.recipe == PT_FURNACE_RECIPE and f1.ok and f1.machines == 1 and not fi.slots[2],
				"the furnace's provider after the update: " .. serpent.line(fi and fi.slots))
			expect(craftable()["iron-ingot"], "the furnace with the old choice is no pattern after the update")
			local plan = remote.call(A, "plan", p, "iron-ingot", 1)
			expect(plan and not plan.no_pattern and plan.pids and plan.pids[1] and plan.pids[1]:sub(1, 2) == "p/",
				"plan of an ingot on the migrated furnace pattern: " .. serpent.line(plan))
			note = " (crafting pattern " .. PT_RECIPE .. ", processing pattern " .. PT_FURNACE_RECIPE .. ")" .. note
		else
			expect(not f1, "a fresh furnace without a choice got a pattern: " .. serpent.line(fi and fi.slots))
			note = " (crafting pattern " .. PT_RECIPE .. ", the furnace had no recipe)" .. note
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL patterns: " .. m) end
	log("DEVCHECK-MIGRATE-PATTERNS " .. (#problems == 0 and "ok" or "failed") .. note)
end

--- the reports of me-network's conversion of an old ME network (issue #68), from its interface or, when me-network 0.5.1
--- dropped them after the intermediate load (issue #209), from the copy taken in on_configuration_changed
local MIGRATE = "gregtorio-me-migrate"
function migrate_report(name)
	local mig = remote.interfaces[MIGRATE]
	if mig and mig[name] then return remote.call(MIGRATE, name) end
	return storage.me_reports and storage.me_reports[name]
end

--- how many old entities (or ghosts) of a filter are left after the update; none when the working copies no longer have
--- the prototype (me-network 0.5.1 removed the old blocks, issue #209), where searching by its name would be an error
function old_left(s, filter)
	if not prototypes.entity[filter.name or filter.ghost_name] then return 0 end
	return #s.find_entities_filtered(filter)
end

--- issue #68: the old item network (see the top of the file); only for versions with the logistic ME network
local IT_DRIVE, IT_IFACE, IT_CTRL2 = { 12.5, Y + 3.5 }, { 14.5, Y + 3.5 }, { 22, Y }
local IT_TERMINAL, IT_CELLS, IT_GHOST = { 3.5, Y + 5.5 }, { 30.5, Y + 20.5 }, { 24.5, Y + 3.5 }
local IT_JOB = { ["iron-plate"] = true, ["iron-stick"] = true, ["iron-gear-wheel"] = true }

function setup_items(place)
	local s = game.surfaces[1]
	if R1() or not (prototypes.entity["me-drive-1k"] and prototypes.entity["me-drive-1k"].type == "logistic-container"
		and prototypes.entity["me-controller"] and prototypes.entity["me-controller"].type == "roboport") then
		storage.items = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-ITEMS skipped (no logistic ME network in this version)")
		return
	end
	local drive = place("me-drive-1k", IT_DRIVE[1], IT_DRIVE[2])
	drive.insert{ name = "copper-plate", count = 100 }
	drive.insert{ name = "stone", count = 37 }
	drive.insert{ name = "iron-plate", count = 5, quality = "uncommon" }
	drive.insert{ name = "blueprint", count = 1 }
	local iface = place("me-interface", IT_IFACE[1], IT_IFACE[2])
	iface.get_inventory(defines.inventory.chest).insert{ name = "copper-cable", count = 20 }
	iface.get_inventory(defines.inventory.logistic_container_trash).insert{ name = "stone-brick", count = 10 }
	place("me-terminal", IT_TERMINAL[1], IT_TERMINAL[2])
	place("me-controller", IT_CTRL2[1], IT_CTRL2[2])
	local chest = place("iron-chest", IT_CELLS[1], IT_CELLS[2])
	chest.insert{ name = "me-1k-storage-cell", count = 16 }
	chest.insert{ name = "me-drive-4k", count = 2 }
	local ghost = s.create_entity{ name = "entity-ghost", inner_name = "me-drive-4k", position = IT_GHOST, force = "player" }
	--- the totals of every old ME chest (the job's items move while the job runs: counted, not compared)
	local totals = {}
	for _, e in pairs(s.find_entities_filtered{ name = { "me-drive-1k", "me-drive-16k", "me-interface" } }) do
		for _, id in pairs({ defines.inventory.chest, defines.inventory.logistic_container_trash }) do
			local inv = e.get_inventory(id)
			for _, c in pairs(inv and inv.get_contents() or {}) do
				local key = c.name .. "@" .. (c.quality or "normal")
				totals[key] = (totals[key] or 0) + c.count
			end
		end
	end
	local ln = s.find_logistic_network_by_position({ 6, Y }, "player")
	local ln2 = s.find_logistic_network_by_position(IT_CTRL2, "player")
	storage.items = { totals = totals, one_network = ln and ln2 and ln.network_id == ln2.network_id, ghost = ghost and ghost.valid }
	log("DEVCHECK-MIGRATE-SETUP-ITEMS " .. (storage.items.one_network and "ok" or "failed (the second controller is in another logistic network)")
		.. " (ghost of an old drive: " .. tostring(storage.items.ghost) .. ")")
end

function check_items()
	local st = storage.items
	if st == nil or st == "skipped" then
		log("DEVCHECK-MIGRATE-ITEMS skipped")
		return
	end
	local s = game.surfaces[1]
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	expect(st.one_network, "test setup: the two old controllers were not in one logistic network")
	--- every old entity is replaced
	for _, name in pairs({ "me-drive-1k", "me-drive-4k", "me-drive-16k", "me-drive-64k", "me-drive-256k" }) do
		expect(old_left(s, { name = name, type = "logistic-container" }) == 0, "an old " .. name .. " is left")
	end
	expect(old_left(s, { name = "me-controller", type = "roboport" }) == 0, "an old controller is left")
	expect(old_left(s, { name = "me-interface", type = "logistic-container" }) == 0, "an old interface is left")
	local ctrl = s.find_entity("me-network-controller", { 6, Y })
	local drive = s.find_entity("me-drive", IT_DRIVE)
	local iface = s.find_entity("me-network-interface", IT_IFACE)
	local terminal = s.find_entity("me-terminal", IT_TERMINAL)
	expect(ctrl and drive and iface and terminal, "new entities missing: controller " .. tostring(ctrl ~= nil) .. ", drive "
		.. tostring(drive ~= nil) .. ", interface " .. tostring(iface ~= nil) .. ", terminal " .. tostring(terminal ~= nil))
	if #problems == 0 then
		local n = remote.call(NET, "network", ctrl)
		expect(n and n.ok and n.controllers == 1, "the new network " .. serpent.line(n))
		for _, e in pairs({ drive, iface, terminal, s.find_entity("me-drive", FL_D1), s.find_entity("me-drive", FL_D2),
			prototypes.entity["me-crafting-cpu"] and s.find_entity("me-crafting-cpu", { 9, Y + 9 })
				or s.find_entity(CPU_BLOCKS[1][1], { CPU_BLOCKS[1][2], CPU_BLOCKS[1][3] }),
			storage.patterns.provider, s.find_entity("me-drive", { 8.5, Y + 12.5 }) }) do
			expect(e and e.valid and remote.call(NET, "same_network", ctrl, e), (e and e.valid and e.name or "?") .. " is not connected to the controller")
		end
		--- the drive has four 1k cells, the 16k drive four 16k cells
		local cells = remote.call(NET, "drive", drive)
		expect(cells[4] and cells[4].name == "me-1k-storage-cell" and not cells[5], "new 1k drive " .. serpent.line(cells))
		local big = remote.call(NET, "drive", s.find_entity("me-drive", { 8.5, Y + 12.5 }))
		expect(big[4] and big[4].name == "me-16k-storage-cell", "new 16k drive " .. serpent.line(big))
		--- item totals: what the old chests held (+ the second controller) is in the network, the blueprint in a chest
		local report = migrate_report("report")
		expect(report and report.diff == 0 and report.groups >= 1, "migration report " .. serpent.line(report and { report.groups, report.diff }))
		local want = {}
		for k, v in pairs(st.totals) do want[k] = v end
		want["me-controller@normal"] = (want["me-controller@normal"] or 0) + 1
		for k, v in pairs(want) do
			expect(report and report.before[k] == v, "the migration counted " .. tostring(report and report.before[k]) .. " " .. k .. ", the old save had " .. v)
		end
		local contents = remote.call(NET, "contents", ctrl)
		local overflow = {}
		for _, c in pairs(s.find_entities_filtered{ name = "iron-chest", position = { 6, Y }, radius = 40 }) do
			for _, it in pairs(c.get_inventory(defines.inventory.chest).get_contents()) do
				local k = it.name .. "@" .. (it.quality or "normal")
				overflow[k] = (overflow[k] or 0) + it.count
			end
		end
		for k, v in pairs(want) do
			local name, q = k:match("^([^@]+)@(.+)$")
			if not IT_JOB[name] then
				local key = q == "normal" and name or k
				local got = (contents[key] or 0) + (overflow[k] or 0)
				expect(got == v, k .. ": " .. got .. " after the update (network " .. (contents[key] or 0) .. ", chests "
					.. (overflow[k] or 0) .. "), " .. v .. " before")
			end
		end
		expect((overflow["blueprint@normal"] or 0) == 1, "the blueprint is not in an overflow chest: " .. serpent.line(overflow))
		--- the cells of the stack of 16 and the old drive items are kept; the ghost is an ME Drive ghost
		local chest = s.find_entity("iron-chest", IT_CELLS)
		expect(chest and chest.get_item_count("me-1k-storage-cell") == 16, "cells in the chest: " .. (chest and chest.get_item_count("me-1k-storage-cell") or -1))
		expect(chest and chest.get_item_count("me-drive-4k") == 2, "old drive items in the chest: " .. (chest and chest.get_item_count("me-drive-4k") or -1))
		--- the ghost of an old drive: the game removes it when the save is loaded (no item builds the old prototype
		--- any more), before any script runs; if one is left, the migration makes it an ME Drive ghost
		local ghosts = s.find_entities_filtered{ ghost_name = "me-drive", position = IT_GHOST, radius = 0.5 }
		expect(old_left(s, { ghost_name = "me-drive-4k", position = IT_GHOST, radius = 0.5 }) == 0, "the ghost of an old drive is left")
		st.ghost_note = #ghosts == 1 and "old ghost became an ME Drive ghost" or "old ghost removed by the game on load"
		local total = 0
		for _, v in pairs(st.totals) do total = total + v end
		for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL items: " .. m) end
		log("DEVCHECK-MIGRATE-ITEMS " .. (#problems == 0 and "ok" or "failed") .. " (" .. total .. " items in the old chests, "
			.. (report and report.cables or 0) .. " cables placed, " .. (report and report.chests or 0) .. " overflow chests, "
			.. st.ghost_note .. ")")
		return
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL items: " .. m) end
	log("DEVCHECK-MIGRATE-ITEMS failed")
end

--- issue #68 step R2: the old fluid drives, their recovered fluid and a chest with loaded drive items become fluid
--- cells. Every unit must be kept: the drives' fluid in ME Drives with four 1k fluid cells at the same spots, the
--- recovered chlorine in the nearest drive with room (no network next to its place), the loaded items' water in
--- fluid cells next to the (untagged) items in the chest; the migration's report counts the same before and after.
function check_fluids()
	local st = storage.fluid_old
	local s = game.surfaces[1]
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function cells_fluid(drive)
		local out, n = {}, 0
		for _, cell in pairs(drive and remote.call(NET, "drive", drive) or {}) do
			n = n + 1
			for key, v in pairs(cell.items) do
				if key:sub(1, 6) == "fluid/" then out[key:sub(7)] = (out[key:sub(7)] or 0) + v end
			end
		end
		return out, n
	end
	for _, name in pairs({ "me-fluid-drive-1k", "me-fluid-drive-4k", "me-fluid-drive-16k", "me-fluid-drive-64k", "me-fluid-drive-256k" }) do
		expect(old_left(s, { name = name }) == 0, "an old " .. name .. " is left")
	end
	local d1, d2, lone = s.find_entity("me-drive", FL_D1), s.find_entity("me-drive", FL_D2), s.find_entity("me-drive", FL_LONE)
	expect(d1 and d2 and lone, "the old fluid drives are no ME Drives")
	if #problems == 0 then
		local c1, n1 = cells_fluid(d1)
		local c2, n2 = cells_fluid(d2)
		local c3, n3 = cells_fluid(lone)
		local info = remote.call(NET, "drive", d1)
		expect(n1 == 4 and n2 == 4 and n3 == 4 and info[1] and info[1].name == "me-1k-fluid-storage-cell",
			"cells in the new drives " .. n1 .. "/" .. n2 .. "/" .. n3 .. " " .. serpent.line(info[1]))
		expect(same(c1, st.d1) and same(c3, st.lone), "drive 1 " .. serpent.line(c1) .. " (" .. serpent.line(st.d1) .. "), lone "
			.. serpent.line(c3) .. " (" .. serpent.line(st.lone) .. ")")
		--- drive 2 keeps its fluid and takes the recovered chlorine (the nearest drive with room)
		local want2 = {}
		for k, v in pairs(st.d2) do want2[k] = v end
		for k, v in pairs(st.pool) do want2[k] = (want2[k] or 0) + v end
		expect(same(c2, want2), "drive 2 " .. serpent.line(c2) .. ", expected " .. serpent.line(want2))
		local totals = remote.call(F, "totals", d2)
		local want = {}
		for k, v in pairs(st.d1) do want[k] = v end
		for k, v in pairs(want2) do want[k] = (want[k] or 0) + v end
		expect(same(totals, want), "network holds " .. serpent.line(totals) .. ", expected " .. serpent.line(want))
		--- the loaded drive items: the items stay without tags, their water is in fluid cells in the chest
		local chest = s.find_entity("iron-chest", FL_ITEMS)
		local inv = chest and chest.get_inventory(defines.inventory.chest)
		local items, water = 0, 0
		for i = 1, inv and #inv or 0 do
			local stack = inv[i]
			if stack.valid_for_read and stack.name == "me-fluid-drive-1k" then
				items = items + stack.count
				local tags = stack.tags
				expect(not (tags and tags.fork_me_fluids), "a loaded drive item kept its fluid tags")
			elseif stack.valid_for_read and stack.name:find("fluid%-storage%-cell") then
				local tags = stack.tags
				water = water + (tags and tags.fork_me_cell and tags.fork_me_cell.items["fluid/water"] or 0)
			end
		end
		expect(items == 2 and near(water, 2 * FL_ITEM_WATER), "chest after the update: " .. items .. " old items, " .. water .. " water in cells")
		--- the migration report: the same before and after, every source counted
		local rep = migrate_report("fluid_report")
		local before = 0
		for _, v in pairs(rep and rep.before or {}) do before = before + v end
		local expected = 0
		for _, t in pairs({ st.d1, st.d2, st.lone, st.pool }) do for _, v in pairs(t) do expected = expected + v end end
		expected = expected + 2 * FL_ITEM_WATER
		expect(rep and rep.diff == 0 and near(before, expected) and rep.drives == 3 and rep.items == 1,
			"fluid migration report " .. serpent.line(rep and { rep.drives, rep.entries, rep.items, rep.diff, before }) .. ", expected " .. expected .. " units")
		for _, p in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL fluids: " .. p) end
		log("DEVCHECK-MIGRATE-FLUIDS " .. (#problems == 0 and "ok" or "failed") .. string.format(" (%.0f units in %d old drives, recovered fluid and %d loaded items kept)",
			expected, rep and rep.drives or 0, 2))
		return
	end
	for _, p in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL fluids: " .. p) end
	log("DEVCHECK-MIGRATE-FLUIDS failed")
end

--- Issue #83: the hand-over of the ME state to me-network. Versions with storage buses, fluid cells and drive
--- settings (0.4.0 and later) get one more network: a drive (priority, a partitioned item cell, a fluid cell) reached
--- only through an underground cable pair, an ME Interface with a config row, an import and an export bus with
--- filters, a storage bus on a chest and a fluid storage bus on a tank (filters, priority, mode), a fluid interface
--- set to export. Before the save the totals of the network (items and fluids, also in the chests and tanks of the
--- buses) plus what sits in the interface and the bus chests, and every block's settings are recorded; after the
--- update (me-network has the state now) they must be the same, and the drive must still be in the controller's
--- network (through the underground pair). Since me-network 0.2.0 (its issue #3) the fluid interface and the fluid
--- storage bus become an ME Interface and an ME Storage Bus in their place: the check finds them there and compares
--- their settings in the unified form (a fluid row on every side; fluid filters as "fluid/<name>").
local HO_Y = Y + 30
local SB, FSB, IO = "gregtorio-me-storagebus", "gregtorio-me-fluid-storagebus", "gregtorio-me-io"
local HO_CHECK_TICK = 90

local function handover_version()
	local function has(i, f) return remote.interfaces[i] and remote.interfaces[i][f] end
	return R2() and prototypes.entity["me-storage-bus"] and prototypes.entity["me-fluid-storage-bus"]
		and prototypes.entity["me-underground-cable"] and has(SB, "get_settings") and has(FSB, "get_settings")
		and has(NET, "drive_settings") and has(NET, "set_partition") and has(IO, "get_interface_config")
		-- the fluid interface of me-network before 0.2.0; with the unified interface (Gregtorio 0.5.1) there is no hand-over
		and has(F, "set_interface")
end

--- what the hand-over network holds: items and fluids of the network (cells, the storage bus chest, the tank of
--- the fluid storage bus) plus the interface's and the bus chests' items and the fluid interface's fluid
local function handover_totals(st)
	local out = {}
	local function add(k, v) out[k] = (out[k] or 0) + v end
	for k, v in pairs(remote.call(NET, "contents", st.ctrl) or {}) do add(k, v) end
	for k, v in pairs(remote.call(NET, "fluid_contents", st.ctrl) or {}) do add("fluid/" .. k, v) end
	for _, e in pairs({ st.iface, st.ichest, st.echest }) do
		for _, c in pairs(e.get_inventory(defines.inventory.chest).get_contents()) do
			add(c.quality == "normal" and c.name or (c.name .. "@" .. c.quality), c.count)
		end
	end
	if st.fiface.valid then
		for k, v in pairs(st.fiface.get_fluid_contents()) do add("fluid/" .. k, v) end
	else                                                  -- me-network 0.2.0: the unified interface's sides
		local new = game.surfaces[1].find_entity("me-network-interface", st.fiface_pos)
		for _, t in pairs(new and remote.call(IO, "interface_tanks", new) or {}) do
			for k, v in pairs(t.get_fluid_contents()) do add("fluid/" .. k, v) end
		end
	end
	return out
end

--- me-network 0.2.0: the replacements of the old fluid interface and fluid storage bus (at their positions)
local function unified_of(st)
	local s = game.surfaces[1]
	return s.find_entity("me-network-interface", st.fiface_pos), s.find_entity("me-storage-bus", st.fsbus_pos)
end

--- the settings of the fluid interface and the fluid storage bus in the unified form, before (old remote calls)
--- and after (the unified blocks) the update
local function unified_settings(st)
	if st.fiface.valid then
		local f = remote.call(F, "get_interface", st.fiface)
		local fs = remote.call(FSB, "get_settings", st.fsbus) or {}
		local rows, sides = {}, {}
		if f and f.mode == "export" and f.fluid then
			rows = { [1] = { type = "fluid", name = f.fluid, amount = f.level } }
			sides = { 1, 1, 1, 1 }
		end
		local filters = {}
		for i, name in ipairs(fs.filters or {}) do filters[i] = "fluid/" .. name end
		return { rows = rows, sides = sides }, { mode = fs.mode, priority = fs.priority, filters = filters }
	end
	local fi, fsb = unified_of(st)
	local config = fi and remote.call(IO, "get_interface_config", fi) or {}
	local rows = {}
	for i, c in pairs(config) do rows[i] = { type = c.type, name = c.name, amount = c.amount } end
	return { rows = rows, sides = fi and remote.call(IO, "get_interface_sides", fi) or {} },
		fsb and remote.call(SB, "get_settings", fsb) or {}
end

--- the settings of the blocks (without what a block reports about its last step: status, target)
local function handover_settings(st)
	local out = {
		interface = remote.call(IO, "get_interface_config", st.iface),
		import = remote.call(IO, "get_bus", st.ibus),
		export = remote.call(IO, "get_bus", st.ebus),
		storage_bus = remote.call(SB, "get_settings", st.sbus),
		drive = remote.call(NET, "drive_settings", st.drive),
	}
	out.fluid_interface, out.fluid_storage_bus = unified_settings(st)
	for _, t in pairs(out) do
		if type(t) == "table" then t.status, t.target = nil, nil end
	end
	return out
end

local function setup_handover()
	if not handover_version() then
		storage.handover = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-HANDOVER skipped (no storage buses, fluid cells or drive settings in this version)")
		return
	end
	local s = game.surfaces[1]
	local function place(name, x, y, dir)
		return s.create_entity{ name = name, position = { x, y }, force = "player", direction = dir, raise_built = true }
	end
	local eei = place("electric-energy-interface", 40, HO_Y + 2)
	eei.power_production = 1e6
	eei.electric_buffer_size = 1e7
	place("substation", 43, HO_Y + 2)
	local st = {}
	st.ctrl = place("me-network-controller", 46, HO_Y)
	st.ctrl.energy = st.ctrl.electric_buffer_size
	for x = 47.5, 52.5 do place("me-cable", x, HO_Y - 0.5) end
	local south = defines.direction.south
	st.iface = place("me-network-interface", 47.5, HO_Y + 0.5)
	st.fiface = place("me-fluid-interface", 47.5, HO_Y + 1.5)
	st.fiface_pos = { 47.5, HO_Y + 1.5 }
	st.ibus = place("me-import-bus", 48.5, HO_Y + 0.5, south)
	st.ichest = place("iron-chest", 48.5, HO_Y + 1.5)
	st.ebus = place("me-export-bus", 49.5, HO_Y + 0.5, south)
	st.echest = place("iron-chest", 49.5, HO_Y + 1.5)
	st.sbus = place("me-storage-bus", 50.5, HO_Y + 0.5, south)
	st.schest = place("iron-chest", 50.5, HO_Y + 1.5)
	st.schest.insert{ name = "stone", count = 77 }
	st.fsbus = place("me-fluid-storage-bus", 52.5, HO_Y + 0.5, south)
	st.fsbus_pos = { 52.5, HO_Y + 0.5 }
	st.tank = place("storage-tank", 53.5, HO_Y + 2.5)
	st.tank.insert_fluid{ name = "water", amount = 3000 }
	--- the drive is reached only through the underground pair
	st.u1 = place("me-underground-cable", 53.5, HO_Y - 0.5, defines.direction.east)
	st.u2 = place("me-underground-cable", 57.5, HO_Y - 0.5, defines.direction.west)
	st.drive = place("me-drive", 58.5, HO_Y - 0.5)
	local inv = game.create_inventory(1)
	inv[1].set_stack{ name = "me-1k-storage-cell", count = 1 }
	remote.call(NET, "insert_cell", st.drive, inv[1], 1)
	inv[1].set_stack{ name = "me-4k-storage-cell", count = 1 }
	remote.call(NET, "insert_cell", st.drive, inv[1], 2)
	inv[1].set_stack{ name = "me-1k-fluid-storage-cell", count = 1 }
	remote.call(NET, "insert_cell", st.drive, inv[1], 3)
	inv.destroy()
	remote.call(NET, "set_partition", st.drive, 1, { "iron-plate" })
	remote.call(NET, "set_priority", st.drive, 7)
	remote.call(NET, "store_in_drive", st.drive, "iron-plate", 123)
	remote.call(NET, "store_in_drive", st.drive, "copper-plate", 45)
	remote.call(NET, "store_in_drive", st.drive, "copper-plate", 3, "uncommon")
	remote.call(NET, "store_fluid_in_drive", st.drive, "chlorine", 1500)
	--- settings
	remote.call(IO, "set_interface_config", st.iface, { [1] = { name = "iron-plate", amount = 10 } })
	remote.call(IO, "set_bus_filters", st.ibus, { "copper-cable" })
	remote.call(IO, "set_bus_filters", st.ebus, { "iron-gear-wheel" })
	remote.call(SB, "set_settings", st.sbus, { priority = 3, filters = { "stone" }, mode = "readwrite" })
	remote.call(FSB, "set_settings", st.fsbus, { priority = -2, filters = { "water" } })
	remote.call(F, "set_interface", st.fiface, "export", "crude-oil", 500)
	st.connected = remote.call(NET, "same_network", st.ctrl, st.drive)
	st.totals = handover_totals(st)
	st.settings = handover_settings(st)
	storage.handover = st
	local n = 0
	for _ in pairs(st.totals) do n = n + 1 end
	log("DEVCHECK-MIGRATE-SETUP-HANDOVER " .. (st.connected and n >= 5 and "ok" or "failed") .. " (" .. n .. " kinds: "
		.. serpent.line(st.totals) .. ")")
end

local function check_handover()
	local st = storage.handover
	if st == nil or st == "skipped" then
		log("DEVCHECK-MIGRATE-HANDOVER skipped")
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	expect(st.connected, "test setup: the drive was not connected through the underground pair in the old save")
	local valid = true
	for _, k in pairs({ "ctrl", "iface", "ibus", "ebus", "sbus", "drive", "u1", "u2" }) do
		if not (st[k] and st[k].valid) then valid = false; expect(false, k .. " is gone") end
	end
	--- me-network 0.2.0: the fluid interface and the fluid storage bus are the unified blocks now
	local fi, fsb = unified_of(st)
	if not (fi and fsb and not st.fiface.valid and not st.fsbus.valid) then
		valid = false
		expect(false, "the fluid interface and the fluid storage bus were not replaced by the unified blocks: "
			.. tostring(fi) .. ", " .. tostring(fsb))
	end
	if valid then
		expect(remote.call(NET, "same_network", st.ctrl, st.drive), "the drive is not in the controller's network (underground pair)")
		expect(remote.call(NET, "underground_partner", st.u1) == st.u2.unit_number, "the underground ends are not paired")
		local now = handover_totals(st)
		for k, v in pairs(st.totals) do
			expect(math.abs((now[k] or 0) - v) < 1e-6, k .. ": " .. tostring(now[k]) .. " after the update, " .. v .. " before")
		end
		for k, v in pairs(now) do
			expect(st.totals[k] ~= nil, k .. ": " .. v .. " after the update, none before")
		end
		local settings = handover_settings(st)
		for k, v in pairs(st.settings) do
			expect(serpent.line(settings[k]) == serpent.line(v), k .. " settings " .. serpent.line(settings[k]) .. ", before "
				.. serpent.line(v))
		end
	end
	local n = 0
	for _ in pairs(st.totals) do n = n + 1 end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL handover: " .. m) end
	log("DEVCHECK-MIGRATE-HANDOVER " .. (#problems == 0 and "ok" or "failed") .. " (" .. n
		.. " item and fluid kinds equal, settings of 7 blocks kept, drive behind the underground pair connected)")
end

--- Issue #529: the Space Age planets are deleted. The old save gets a surface of each (a few chunks, an iron chest with
--- iron plates); after the update the save must load, and the check reports what became of each surface and generates
--- new chunks on one that is left (DEVCHECK-MIGRATE-PLANETS)
local REMOVED_PLANETS = { "vulcanus", "gleba", "fulgora", "aquilo" }
local function setup_planets()
	local made = {}
	for _, name in pairs(REMOVED_PLANETS) do
		local planet = game.planets[name]
		if planet then
			local s = planet.surface or planet.create_surface()
			s.request_to_generate_chunks({ 0, 0 }, 1)
			s.force_generate_chunk_requests()
			local at = s.find_non_colliding_position("iron-chest", { 0, 0 }, 64, 1)
			local chest = at and s.create_entity{ name = "iron-chest", position = at, force = "player" }
			if chest then chest.insert{ name = "iron-plate", count = 10 } end
			made[#made + 1] = name
		end
	end
	storage.planets = made
	log("DEVCHECK-MIGRATE-SETUP-PLANETS " .. (#made > 0 and "ok (" .. table.concat(made, ", ") .. ")" or "skipped"))
end

local function check_planets()
	if type(storage.planets) ~= "table" or #storage.planets == 0 then
		log("DEVCHECK-MIGRATE-PLANETS skipped")
		return
	end
	local parts, problems = {}, {}
	for _, name in pairs(storage.planets) do
		if game.planets[name] then problems[#problems + 1] = name .. " is still a planet" end
		local s = game.surfaces[name]
		if not s then
			parts[#parts + 1] = name .. ": surface deleted"
		else
			local chests = s.count_entities_filtered{ name = "iron-chest" }
			local ok = pcall(function()
				s.request_to_generate_chunks({ 320, 320 }, 0)
				s.force_generate_chunk_requests()
			end)
			parts[#parts + 1] = name .. ": surface kept (planet " .. (s.planet and s.planet.name or "none") .. ", " .. chests
				.. " chest, new chunks " .. (ok and s.is_chunk_generated({ 10, 10 }) and "generated" or "not generated") .. ")"
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL planets: " .. m) end
	log("DEVCHECK-MIGRATE-PLANETS " .. (#problems == 0 and "ok" or "failed") .. " (" .. table.concat(parts, "; ") .. ")")
end

--- Issue #529: one control per vein; the size slider of gt-ore-veins scaled every vein before and is the share of cells
--- with a vein now. An old save with the map veins (before #529) gets size 1.5 on gt-ore-veins and notes the cell size
--- and the veins of a few cells; after the update every vein control of Nauvis must have size 1.5, the grid's 1, and
--- the cells and veins must be the same (DEVCHECK-MIGRATE-VEINGRID)
local VG_SIZE, VG_CELLS = 1.5, { { 300, 300 }, { -700, 500 }, { 900, -1100 }, { -1500, -1300 }, { 2100, 1700 } }
local function vein_grid(s)
	local p = s.calculate_tile_properties({ "gt_cell_size", "gt_vein_id", "gt_vein_r" }, VG_CELLS)
	return { size = p.gt_cell_size[1], ids = p.gt_vein_id, r = p.gt_vein_r }
end
local function setup_vein_grid()
	local s = game.surfaces.nauvis
	if not prototypes.autoplace_control["gt-ore-veins"] or prototypes.autoplace_control["gt-vein-Coal"] then
		log("DEVCHECK-MIGRATE-SETUP-VEINGRID skipped (" .. (prototypes.autoplace_control["gt-vein-Coal"]
			and "the veins have their own controls in this version" or "no map veins in this version") .. ")")
		return
	end
	local mgs = s.map_gen_settings
	mgs.autoplace_controls["gt-ore-veins"] = { frequency = 1, size = VG_SIZE, richness = 1 }
	s.map_gen_settings = mgs
	storage.vein_grid = vein_grid(s)
	log("DEVCHECK-MIGRATE-SETUP-VEINGRID ok (size " .. VG_SIZE .. ", cells of " .. storage.vein_grid.size .. " tiles)")
end

local function check_vein_grid()
	local before = storage.vein_grid
	if not before or classic_mode() then   -- (issue #563: classic mode has no veins on the map)
		log("DEVCHECK-MIGRATE-VEINGRID skipped" .. (before and " (classic ore mode)" or ""))
		return
	end
	local problems = {}
	local s = game.surfaces.nauvis
	local controls = s.map_gen_settings.autoplace_controls
	local n = 0
	for name, c in pairs(controls) do
		if name:match("^gt%-vein%-") then
			n = n + 1
			if math.abs(c.size - VG_SIZE) > 1e-6 then problems[#problems + 1] = name .. " has size " .. c.size end
		end
	end
	if n == 0 then problems[#problems + 1] = "no vein control in the map settings of Nauvis" end
	if math.abs(controls["gt-ore-veins"].size - 1) > 1e-6 then
		problems[#problems + 1] = "gt-ore-veins has size " .. controls["gt-ore-veins"].size .. ", not 1"
	end
	local after = vein_grid(s)
	if math.abs(after.size - before.size) > 1e-6 then
		problems[#problems + 1] = "cells of " .. after.size .. " tiles, " .. before.size .. " before"
	end
	for i in ipairs(VG_CELLS) do
		if math.abs(after.ids[i] - before.ids[i]) > 1e-6 or math.abs(after.r[i] - before.r[i]) > 1e-3 then
			problems[#problems + 1] = string.format("cell %d: vein %d radius %.2f, before %d radius %.2f", i, after.ids[i],
				after.r[i], before.ids[i], before.r[i])
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL vein grid: " .. m) end
	log("DEVCHECK-MIGRATE-VEINGRID " .. (#problems == 0 and "ok" or "failed") .. " (" .. n .. " vein controls at size "
		.. VG_SIZE .. ", cells of " .. after.size .. " tiles, " .. #VG_CELLS .. " cells with the same vein and radius)")
end

--- Issue #534: a save whose map settings name the veins while its chunks have no ore of them (the maintainer's, from a map
--- settings editor). An old save with the map veins gets its generated chunks' vein ore (regenerated first, to match a
--- changed grid above) counted and then deleted; after the update the same chunks must hold the same ore again
--- (DEVCHECK-MIGRATE-VEINORES). Issue #552: an old version that has #534's Lua migration ran it already (Factorio runs a Lua
--- migration once per save, and marks every one of a new map's version as done), so nothing would bring the ores back
--- and the setup is skipped (OLD_MIGRATIONS, at the top)
local VEINORES_MIGRATION = "2026-10-23-issue-534-vein-ores.lua"
local function vein_ores()
	local names = {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "resource" } }) do
		if p.resource_category == "gt-ore" then names[#names + 1] = name end
	end
	return names
end
local function setup_vein_ores()
	local s = game.surfaces.nauvis
	if not (s.map_gen_settings.property_expression_names or {}).gt_vein_id then
		log("DEVCHECK-MIGRATE-SETUP-VEINORES skipped (no map veins in this version)")
		return
	end
	if OLD_MIGRATIONS[VEINORES_MIGRATION] then
		storage.vein_ores_skipped = "the old version has #534's migration " .. VEINORES_MIGRATION .. ", which a save runs once"
		log("DEVCHECK-MIGRATE-SETUP-VEINORES skipped (" .. storage.vein_ores_skipped .. ")")
		return
	end
	local names, chunks = vein_ores(), {}
	for c in s.get_chunks() do
		if s.is_chunk_generated(c) then chunks[#chunks + 1] = { x = c.x, y = c.y } end
	end
	s.regenerate_entity(names, chunks)
	local ores = s.find_entities_filtered{ type = "resource", name = names }
	storage.vein_ores = { tiles = #ores, chunks = #chunks, list = chunks }
	for _, e in pairs(ores) do e.destroy() end
	log("DEVCHECK-MIGRATE-SETUP-VEINORES ok (" .. #ores .. " ore tiles in " .. #chunks .. " chunks deleted, the map settings "
		.. "keep the veins)")
end

local function check_vein_ores()
	local before = storage.vein_ores
	if not before then
		log("DEVCHECK-MIGRATE-VEINORES skipped" .. (storage.vein_ores_skipped and " (" .. storage.vein_ores_skipped .. ")" or ""))
		return
	end
	if classic_mode() then
		--- issue #563: classic mode brings no vein ore back into the chunks whose ore was deleted (the ore the old save
		--- has elsewhere, in chunks generated after the set-up, stays)
		local tiles, names, ns = 0, vein_ores(), game.surfaces.nauvis
		for _, c in pairs(before.list or {}) do
			tiles = tiles + ns.count_entities_filtered{ type = "resource", name = names,
				area = { { c.x * 32, c.y * 32 }, { c.x * 32 + 32, c.y * 32 + 32 } } }
		end
		if tiles > 0 then log("DEVCHECK-MIGRATE-FAIL vein ores: " .. tiles .. " ore tiles regenerated in classic mode") end
		log("DEVCHECK-MIGRATE-VEINORES " .. (tiles == 0 and "ok" or "failed") .. " (classic ore mode: " .. tiles
			.. " ore tiles of the veins in the " .. before.chunks .. " chunks after the update, " .. before.tiles .. " deleted before)")
		return
	end
	local s = game.surfaces.nauvis
	--- (issue #540: the update deletes the chunks of a Space Age save without buildings; they are generated again here)
	for _, c in pairs(before.list or {}) do s.request_to_generate_chunks({ c.x * 32 + 16, c.y * 32 + 16 }, 0) end
	s.force_generate_chunk_requests()
	local tiles = s.count_entities_filtered{ type = "resource", name = vein_ores() }
	--- the landfill the helper puts over water after this count gets ore too
	local ok = tiles >= before.tiles and math.abs(tiles - before.tiles) <= before.tiles * 0.02 + 50
	if not ok then
		log("DEVCHECK-MIGRATE-FAIL vein ores: " .. tiles .. " ore tiles after the update, " .. before.tiles .. " before the deletion")
	end
	log("DEVCHECK-MIGRATE-VEINORES " .. (ok and "ok" or "failed") .. " (" .. tiles .. " ore tiles of the veins after the update, "
		.. before.tiles .. " before they were deleted, in " .. before.chunks .. " chunks)")
end

--- Issue #540: a map made with Space Age keeps every planet's autoplace controls on its Nauvis surface; since #529 (the
--- planets deleted, their controls hidden) and Factorio 2.1 they place Gleba's plants and other planets' tiles in Nauvis'
--- new chunks. An old save of Factorio 2.0 (mode "space-age") gets every control on Nauvis, as such a map has them, a
--- chunk with a chest and a Space Age plant, rock, decorative and tile (a chunk generated with the wrong settings) and
--- one with a plant and no building; its Nether surface is made in 2.0. After the update Nauvis may keep only the
--- controls of its prototype, new chunks far away must hold nothing of Space Age (tiles, trees, plants, rocks, cliffs,
--- decoratives), the chunk without a building must be generated anew, the one with the chest must keep its tile, its
--- chest and its trees and lose the rest. A save of Factorio 2.1 (mode "fresh": 0.5.7, made without the cause) must stay
--- as it was: an area near the spawn and a far one the same after the load, the far one and an area of the Nether,
--- Twilight Forest and End (3 x 3 chunks) deleted and generated anew, the middle chunk the same as in the old save (the
--- outer ones meet chunks of the old save at their edges, whose tile transitions differ a few tiles: also without #540). The Nether, Twilight Forest and End
--- surfaces (made now when the old save has none) must have their planet's settings (DEVCHECK-MIGRATE-MAPGEN)
local MG_KEPT, MG_GONE, MG_FAR = { -10, -10 }, { 10, -10 }, { { 100, 0 }, { -100, 60 } }        -- chunk positions
local MG_NEAR, MG_FRESH = { -12, 10 }, { 60, -60 }     -- (MG_NEAR outside the map's first chunks: VEINORES deletes their ore)
local MG_PLANETS = { "gt-nether", "gt-twilight", "gt-end" }
local MG_TYPES = { "tree", "plant", "simple-entity", "cliff" }
local function from_space_age(kind, name)
	local h = prototypes.get_history(kind, name)
	return h ~= nil and h.created == "space-age"
end
local function chunk_area(c, r)
	r = r or 0
	return { { (c[1] - r) * 32, (c[2] - r) * 32 }, { (c[1] + r + 1) * 32, (c[2] + r + 1) * 32 } }
end
local function generate(s, c, r)
	s.request_to_generate_chunks({ c[1] * 32 + 16, c[2] * 32 + 16 }, r or 0)
	s.force_generate_chunk_requests()
end
--- what of Space Age the area holds, as sorted "kind name=count"
local function space_age_in(s, area)
	local found = {}
	local function add(key) found[key] = (found[key] or 0) + 1 end
	for name in pairs(prototypes.tile) do
		if from_space_age("tile", name) then
			local n = s.count_tiles_filtered{ area = area, name = name }
			if n > 0 then found["tile " .. name] = n end
		end
	end
	for _, e in pairs(s.find_entities_filtered{ area = area, type = MG_TYPES }) do
		if from_space_age(e.type, e.name) then add(e.type .. " " .. e.name) end
	end
	for _, d in pairs(s.find_decoratives_filtered{ area = area }) do
		if from_space_age("optimized-decorative", d.decorative.name) then add("decorative " .. d.decorative.name) end
	end
	local list = {}
	for k, n in pairs(found) do list[#list + 1] = k .. "=" .. n end
	table.sort(list)
	return list
end
--- tiles, entities (no units and fish: they move) and decoratives of the area: per name the count and sums of the positions
local function snapshot(s, area)
	local sums = {}
	local function add(key, p)
		local x, y = math.floor(p.x * 2), math.floor(p.y * 2)
		local t = sums[key] or { 0, 0, 0, 0 }
		t[1], t[2], t[3], t[4] = t[1] + 1, t[2] + x, t[3] + y, t[4] + x * y
		sums[key] = t
	end
	for _, t in pairs(s.find_tiles_filtered{ area = area }) do add("tile " .. t.name, t.position) end
	for _, e in pairs(s.find_entities_filtered{ area = area }) do
		if e.type ~= "unit" and e.type ~= "fish" then add(e.type .. " " .. e.name, e.position) end
	end
	for _, d in pairs(s.find_decoratives_filtered{ area = area }) do add("decorative " .. d.decorative.name, d.position) end
	local out = {}
	for k, t in pairs(sums) do out[k] = table.concat(t, ":") end
	return out
end
--- (issue #563: without_veins leaves out the vein ores, which an area generated anew in classic mode lacks)
local function snapshot_diff(a, b, without_veins)
	local diff = {}
	local function skip(k) return without_veins and k:match("^resource gt%-ore%-") end
	for k, v in pairs(a) do if b[k] ~= v and not skip(k) then diff[#diff + 1] = k .. " " .. v .. " -> " .. (b[k] or "none") end end
	for k, v in pairs(b) do if a[k] == nil and not skip(k) then diff[#diff + 1] = k .. " none -> " .. v end end
	table.sort(diff)
	return diff
end
local function pick(kind, preferred, ok)
	for _, name in pairs(preferred) do
		if prototypes[kind][name] and ok(name) then return name end
	end
	local names = {}
	for name in pairs(prototypes[kind]) do if ok(name) then names[#names + 1] = name end end
	table.sort(names)
	return names[1]
end
--- Nauvis' trees in the chunk, 2 tiles from its edges (deleting a neighbour also deletes a tree whose box reaches into it)
local function own_trees(s, c)
	local n = 0
	for _, e in pairs(s.find_entities_filtered{ area = { { c[1] * 32 + 2, c[2] * 32 + 2 }, { c[1] * 32 + 30, c[2] * 32 + 30 } },
		type = "tree" }) do
		if not from_space_age("tree", e.name) then n = n + 1 end
	end
	return n
end
local function planet_area(p) return p == "gt-end" and { 0, 2 } or { 3, 3 } end

local function setup_mapgen()
	local s = game.surfaces.nauvis
	if not (prototypes.space_location and prototypes.space_location.nauvis and prototypes.autoplace_control["gt-ore-veins"]) then
		log("DEVCHECK-MIGRATE-SETUP-MAPGEN skipped (no map veins in this version)")
		return
	end
	local mg = { mode = script.active_mods.base:match("^2%.0%.") and "space-age" or "fresh" }
	storage.mapgen = mg
	if mg.mode == "fresh" then
		generate(s, MG_NEAR, 1)
		generate(s, MG_FRESH, 1)
		mg.near, mg.fresh, mg.planets = snapshot(s, chunk_area(MG_NEAR, 1)), snapshot(s, chunk_area(MG_FRESH, 1)), {}
		mg.fresh_centre, mg.centres = snapshot(s, chunk_area(MG_FRESH)), {}
		for _, p in pairs(MG_PLANETS) do
			local planet = game.planets[p]
			if planet then
				local ps = planet.surface or planet.create_surface()
				generate(ps, planet_area(p), 1)
				mg.planets[p] = snapshot(ps, chunk_area(planet_area(p), 1))
				mg.centres[p] = snapshot(ps, chunk_area(planet_area(p)))
			end
		end
		log("DEVCHECK-MIGRATE-SETUP-MAPGEN ok (a save of Factorio 2.1: two areas of Nauvis and one of the Nether, Twilight "
			.. "Forest and End noted)")
		return
	end
	local mgs = s.map_gen_settings
	local added = 0
	for name in pairs(prototypes.autoplace_control) do
		if not mgs.autoplace_controls[name] then
			mgs.autoplace_controls[name] = { frequency = 1, size = 1, richness = 1 }
			added = added + 1
		end
	end
	mgs.default_enable_all_autoplace_controls = false
	s.map_gen_settings = mgs
	--- (the chunks on land: the first one without water from MG_KEPT and MG_GONE on)
	local function land(c)
		for i = 0, 20 do
			local at = { c[1] - i, c[2] - i }
			generate(s, at, 0)
			if s.count_tiles_filtered{ area = chunk_area(at), collision_mask = "water_tile" } == 0 then return at end
		end
	end
	local kept_at, gone_at = land(MG_KEPT), land(MG_GONE)
	mg.kept, mg.gone = kept_at, gone_at
	local plant = pick("entity", { "stingfrond", "funneltrunk" }, function(n)
		local t = prototypes.entity[n].type
		return (t == "tree" or t == "plant") and from_space_age(t, n)
	end)
	local rock = pick("entity", { "big-volcanic-rock" }, function(n)
		return prototypes.entity[n].type == "simple-entity" and n:find("rock") ~= nil and from_space_age("simple-entity", n)
	end)
	local dec = pick("decorative", { "knobbly-roots-orange" }, function(n) return from_space_age("optimized-decorative", n) end)
	local tile = pick("tile", { "natural-yumako-soil", "lowland-olive-blubber" }, function(n)
		return from_space_age("tile", n) and not n:find("platform") and not n:find("foundation") and not n:find("space")
	end)
	local function place(name, c, dx, dy, force)
		local at = s.find_non_colliding_position(name, { c[1] * 32 + dx, c[2] * 32 + dy }, 12, 0.5, true)
		return at and s.create_entity{ name = name, position = at, force = force or "neutral" }
	end
	local chest = kept_at and place("iron-chest", kept_at, 16, 16, "player")
	--- a radar of the chunk that reaches into its east neighbour, which has no building of its own: the neighbour stays
	local radar_at = kept_at and { kept_at[1] * 32 + 31.5, kept_at[2] * 32 + 8.5 }
	if radar_at then
		for _, e in pairs(s.find_entities_filtered{ area = { { radar_at[1] - 2, radar_at[2] - 2 }, { radar_at[1] + 2, radar_at[2] + 2 } } }) do
			if e.type == "tree" or e.type == "simple-entity" then e.destroy() end
		end
		local radar = s.create_entity{ name = "radar", position = radar_at, force = "player" }
		mg.radar = radar and radar.position
	end
	local placed = { kept_at and place(plant, kept_at, 8, 24), kept_at and place(rock, kept_at, 24, 8),
		gone_at and place(plant, gone_at, 16, 16) }
	local x0, y0 = (kept_at or MG_KEPT)[1] * 32, (kept_at or MG_KEPT)[2] * 32
	s.create_decoratives{ check_collision = false, decoratives = { { name = dec, position = { x0 + 26, y0 + 26 }, amount = 1 } } }
	s.set_tiles({ { name = tile, position = { x0 + 2, y0 + 2 } } }, false)
	local trees = own_trees(s, kept_at or MG_KEPT)
	mg.chest, mg.tile, mg.trees = chest and chest.position, tile, trees
	--- the Nether of a save of Factorio 2.0
	local nether = game.planets["gt-nether"]
	if nether and not nether.surface then nether.create_surface() end
	local ok = chest and placed[1] and placed[2] and placed[3] and tile and dec
	if not ok then
		mg.mode = "setup-failed"
		log("DEVCHECK-MIGRATE-SETUP-MAPGEN-DEBUG chest " .. tostring(chest ~= nil) .. ", plant " .. tostring(placed[1] ~= nil)
			.. ", rock " .. tostring(placed[2] ~= nil) .. ", plant without a building " .. tostring(placed[3] ~= nil))
	end
	log("DEVCHECK-MIGRATE-SETUP-MAPGEN " .. (ok and "ok" or "failed") .. " (a save of Factorio 2.0: " .. added
		.. " controls added to Nauvis, " .. tostring(plant) .. ", " .. tostring(rock) .. ", " .. tostring(dec) .. " and "
		.. tostring(tile) .. " next to a chest, " .. tostring(plant) .. " in a chunk without a building)")
end

local function planet_settings(parts, problems)
	for _, p in pairs(MG_PLANETS) do
		local planet = game.planets[p]
		if planet then
			local made = not planet.surface
			local pm = (planet.surface or planet.create_surface()).map_gen_settings
			local pp = prototypes.space_location[p].map_gen_settings
			local diff = {}
			for name in pairs(pm.autoplace_controls or {}) do
				if not (pp.autoplace_controls or {})[name] then diff[#diff + 1] = "+control " .. name end
			end
			for name in pairs(pp.autoplace_controls or {}) do
				if not (pm.autoplace_controls or {})[name] then diff[#diff + 1] = "-control " .. name end
			end
			for _, kind in pairs({ "tile", "entity", "decorative" }) do
				local a = ((pm.autoplace_settings or {})[kind] or {}).settings or {}
				local b = ((pp.autoplace_settings or {})[kind] or {}).settings or {}
				for n in pairs(a) do if not b[n] then diff[#diff + 1] = "+" .. kind .. " " .. n end end
				for n in pairs(b) do if not a[n] then diff[#diff + 1] = "-" .. kind .. " " .. n end end
			end
			table.sort(diff)
			if #diff > 0 then
				problems[#problems + 1] = p .. "'s surface differs from its planet: " .. table.concat(diff, ", ")
			end
			parts[#parts + 1] = p .. (made and " made now" or " of the old save") .. (#diff == 0 and " as its planet" or " differs")
		end
	end
end

local function check_mapgen()
	local mg = storage.mapgen
	if not mg then
		log("DEVCHECK-MIGRATE-MAPGEN skipped")
		return
	end
	local parts, problems = {}, {}
	local s = game.surfaces.nauvis
	local proto = prototypes.space_location.nauvis.map_gen_settings
	local extra = {}
	for name in pairs(s.map_gen_settings.autoplace_controls or {}) do
		if not (proto.autoplace_controls or {})[name] then extra[#extra + 1] = name end
	end
	table.sort(extra)
	if #extra > 0 then
		problems[#problems + 1] = "Nauvis has " .. #extra .. " autoplace controls its planet does not list: " .. table.concat(extra, ", ")
	end
	parts[#parts + 1] = #extra .. " foreign controls on Nauvis"
	if mg.mode == "fresh" then
		local d = snapshot_diff(mg.near, snapshot(s, chunk_area(MG_NEAR, 1)))
		if #d > 0 then problems[#problems + 1] = "the area near the spawn changed: " .. table.concat(d, "; ") end
		d = snapshot_diff(mg.fresh, snapshot(s, chunk_area(MG_FRESH, 1)))
		if #d > 0 then problems[#problems + 1] = "the far area changed: " .. table.concat(d, "; ") end
		for p, snap in pairs(mg.planets) do
			local ps = game.surfaces[p]
			d = ps and snapshot_diff(snap, snapshot(ps, chunk_area(planet_area(p), 1))) or { "surface gone" }
			if #d > 0 then problems[#problems + 1] = p .. "'s area changed: " .. table.concat(d, "; ") end
		end
		--- generated anew in the next check (deleting a chunk takes effect at the end of the tick)
		local function delete(ps, c)
			for dx = -1, 1 do for dy = -1, 1 do ps.delete_chunk({ c[1] + dx, c[2] + dy }) end end
		end
		delete(s, MG_FRESH)
		for p in pairs(mg.planets) do if game.surfaces[p] then delete(game.surfaces[p], planet_area(p)) end end
		mg.phase = { parts = parts, problems = problems }
		return
	elseif mg.mode == "space-age" then
		local new = {}
		for _, c in pairs(MG_FAR) do
			generate(s, c, 2)
			local found = space_age_in(s, chunk_area(c, 2))
			if #found > 0 then
				problems[#problems + 1] = "new chunks around chunk " .. c[1] .. "," .. c[2] .. " hold " .. table.concat(found, ", ")
			end
			new[#new + 1] = #found
		end
		parts[#parts + 1] = "Space Age kinds in 2 x 25 new chunks: " .. table.concat(new, " and ")
		generate(s, mg.gone, 0)
		local gone = space_age_in(s, chunk_area(mg.gone))
		if #gone > 0 then
			problems[#problems + 1] = "the chunk without a building was not generated anew, it holds " .. table.concat(gone, ", ")
		end
		local kept = space_age_in(s, chunk_area(mg.kept))
		if #kept ~= 1 or kept[1] ~= "tile " .. mg.tile .. "=1" then
			problems[#problems + 1] = "the chunk with the chest holds " .. (#kept > 0 and table.concat(kept, ", ") or "nothing of Space Age")
				.. ", only its tile " .. mg.tile .. " should stay"
		end
		if not s.find_entity("iron-chest", mg.chest) then problems[#problems + 1] = "the chest is gone" end
		if not (mg.radar and s.find_entity("radar", mg.radar)) then
			problems[#problems + 1] = "the radar that reaches into the next chunk is gone"
		end
		local trees = own_trees(s, mg.kept)
		if trees ~= mg.trees then problems[#problems + 1] = "the chunk with the chest has " .. trees .. " trees, " .. mg.trees .. " before" end
		parts[#parts + 1] = "chunk without a building " .. (#gone == 0 and "generated anew" or "kept")
			.. ", chunk with the chest: " .. (#kept > 0 and table.concat(kept, ", ") or "nothing of Space Age") .. ", " .. trees .. " trees"
	else
		problems[#problems + 1] = "the old save's set-up failed"
	end
	planet_settings(parts, problems)
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL map generation: " .. m) end
	log("DEVCHECK-MIGRATE-MAPGEN " .. (#problems == 0 and "ok" or "failed") .. " (" .. table.concat(parts, "; ") .. ")")
end

--- the fresh save's deleted areas generated anew: the same as in the old save
local function check_mapgen_fresh()
	local mg = storage.mapgen
	local parts, problems = mg.phase.parts, mg.phase.problems
	mg.phase = nil
	local s = game.surfaces.nauvis
	generate(s, MG_FRESH, 1)
	local far = snapshot_diff(mg.fresh_centre, snapshot(s, chunk_area(MG_FRESH)), classic_mode())
	if #far > 0 then problems[#problems + 1] = "the far area generated anew differs: " .. table.concat(far, "; ") end
	local same = 0
	for p, snap in pairs(mg.centres) do
		local ps = game.surfaces[p]
		generate(ps, planet_area(p), 1)
		local d = snapshot_diff(snap, snapshot(ps, chunk_area(planet_area(p))), classic_mode())
		if #d > 0 then problems[#problems + 1] = p .. "'s area generated anew differs: " .. table.concat(d, "; ") else same = same + 1 end
	end
	parts[#parts + 1] = "Nauvis near the spawn the same, far area generated anew " .. (#far == 0 and "the same" or "differs")
		.. ", " .. same .. " of " .. table_size(mg.planets) .. " dimension areas generated anew the same"
	planet_settings(parts, problems)
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL map generation: " .. m) end
	log("DEVCHECK-MIGRATE-MAPGEN " .. (#problems == 0 and "ok" or "failed") .. " (" .. table.concat(parts, "; ") .. ")")
end

--- Issue #560: the ore machines (macerators, ore washers, thermal centrifuges, centrifuges and their multiblocks) are
--- furnaces since 0.5.9. The old save has every one of them placed, unpowered, with a recipe of one item (and one fluid
--- where it takes one), twice its ingredients in the input, three of its main product in the output, a craft at half
--- progress, and the first one wired to a constant combinator. After the update each must be a furnace of its name at its
--- place (scripts/fork-ore-furnaces.lua rebuilds them) that holds the input items (with the craft's ingredients given back),
--- the output and the input fluid, and the wire must be there (DEVCHECK-MIGRATE-FURNACES). A version whose ore machines
--- are furnaces already is skipped.
local FU_AT, FU_ROW = { 200.5, Y + 80.5 }, 20
local function ore_machine(p)
	if p.type ~= "assembling-machine" or not (p.items_to_place_this and #p.items_to_place_this > 0) then return false end
	local any = false
	for c in pairs(p.crafting_categories or {}) do
		local rest = c:match("^%a+%-(.+)%-recipes$")
		if c == "parameters" then
			-- (the engine's category of every crafting machine)
		elseif not (c == "steam-macerator-recipes" or rest == "macerator" or rest == "ore-washer" or rest == "thermal-centrifuge"
			or rest == "centrifuge") then return false
		else
			any = true
		end
	end
	return any
end
--- a recipe's categories (Factorio 2.1: a list; 2.0, the versions up to 0.5.6: one)
local function recipe_categories(r)
	local ok, cats = pcall(function() return r.categories end)
	return ok and cats or { r.category }
end
local function furnace_recipe(p)
	local names = {}
	for name, r in pairs(prototypes.recipe) do
		if not r.hidden and p.crafting_categories[recipe_categories(r)[1]] then names[#names + 1] = name end
	end
	table.sort(names)
	for _, name in pairs(names) do
		local items, fluids = 0, 0
		for _, ing in pairs(prototypes.recipe[name].ingredients) do
			if ing.type == "item" then items = items + 1 else fluids = fluids + 1 end
		end
		if items == 1 and fluids <= 1 then return prototypes.recipe[name] end
	end
end

local function setup_furnaces()
	local names = {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "assembling-machine" } }) do
		if ore_machine(p) then names[#names + 1] = name end
	end
	table.sort(names)
	if #names == 0 then
		log("DEVCHECK-MIGRATE-SETUP-FURNACES skipped (the ore machines are furnaces in this version)")
		return
	end
	local s = game.surfaces[1]
	local area = { { FU_AT[1] - 6, FU_AT[2] - 6 }, { FU_AT[1] + 8 * FU_ROW + 6, FU_AT[2] + 8 * math.ceil(#names / FU_ROW) + 6 } }
	s.request_to_generate_chunks({ FU_AT[1] + 80, FU_AT[2] + 16 }, 4)
	s.force_generate_chunk_requests()
	local land = {}
	for _, t in pairs(s.find_tiles_filtered{ area = area, collision_mask = "water_tile" }) do
		land[#land + 1] = { name = "landfill", position = t.position }
	end
	s.set_tiles(land)
	for _, e in pairs(s.find_entities_filtered{ area = area, type = { "tree", "simple-entity", "cliff", "resource" } }) do e.destroy() end
	local list, wired = {}, nil
	for i, name in pairs(names) do
		local r = furnace_recipe(prototypes.entity[name])
		local pos = { FU_AT[1] + 8 * ((i - 1) % FU_ROW), FU_AT[2] + 8 * math.floor((i - 1) / FU_ROW) }
		local e = r and s.create_entity{ name = name, position = pos, force = "player", raise_built = true }
		if e then
			game.forces.player.recipes[r.name].enabled = true
			e.set_recipe(r.name)
			local m = { name = name, pos = e.position, recipe = r.name }
			for _, ing in pairs(r.ingredients) do
				if ing.type == "item" then
					m.item, m.count, m.per_craft = ing.name, e.insert{ name = ing.name, count = ing.amount * 2 }, ing.amount
				else
					m.fluid = { name = ing.name, amount = e.insert_fluid{ name = ing.name, amount = ing.amount * 2 }, per_craft = ing.amount }
				end
			end
			for _, pr in pairs(r.products) do
				if pr.type == "item" and not m.product then
					m.product = pr.name
					m.product_count = e.get_inventory(defines.inventory.crafter_output).insert{ name = pr.name, count = 3 }
				end
			end
			m.progress = pcall(function() e.crafting_progress = 0.5 end) and e.crafting_progress or 0
			if not wired then
				local cc = s.create_entity{ name = "constant-combinator", position = { pos[1], pos[2] - 3 }, force = "player" }
				if cc then
					cc.get_wire_connector(defines.wire_connector_id.circuit_red, true).connect_to(
						e.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.player)
					wired = true
					m.wired = true
				end
			end
			list[#list + 1] = m
		end
	end
	storage.furnaces = { list = list }
	local mid = 0
	for _, m in pairs(list) do if m.progress > 0 then mid = mid + 1 end end
	log("DEVCHECK-MIGRATE-SETUP-FURNACES ok (" .. #list .. " of " .. #names .. " ore machines placed with a recipe, " .. mid
		.. " of them mid-craft)")
end

local function check_furnaces()
	local st = storage.furnaces
	if not st then
		log("DEVCHECK-MIGRATE-FURNACES skipped")
		return
	end
	local s = game.surfaces[1]
	local problems, furnaces, back = {}, 0, 0
	for _, m in pairs(st.list) do
		local f = s.find_entity(m.name, m.pos)
		if not f then
			problems[#problems + 1] = m.name .. " (" .. m.recipe .. ") is gone"
		elseif f.type ~= "furnace" then
			problems[#problems + 1] = m.name .. " is a " .. f.type .. ", not a furnace"
		else
			furnaces = furnaces + 1
			--- the input items, on the ground too (what fits nowhere is spilled), with the craft's ingredients given back; a
			--- furnace that picked its recipe at once has taken one craft's ingredients (and holds twice a craft's fluid at most)
			local crafting = f.is_crafting()
			local n = f.get_item_count(m.item) + (crafting and m.per_craft or 0)
			for _, it in pairs(s.find_entities_filtered{ position = m.pos, radius = 4, name = "item-on-ground" }) do
				if it.stack.name == m.item then n = n + it.stack.count end
			end
			local had = m.count + (m.product == m.item and m.product_count or 0)
			if n < had then
				problems[#problems + 1] = m.name .. " holds " .. n .. " " .. m.item .. " of " .. had
			elseif m.progress > 0 and n >= had + m.per_craft then
				back = back + 1
			end
			local out = f.get_inventory(defines.inventory.crafter_output).get_item_count(m.product)
			if m.product ~= m.item and out < m.product_count then
				problems[#problems + 1] = m.name .. "'s output holds " .. out .. " " .. m.product .. " of " .. m.product_count
			end
			if m.fluid and m.fluid.amount > 0 then
				local got = f.get_fluid_count(m.fluid.name) + (crafting and m.fluid.per_craft or 0)
				if got < m.fluid.amount - 1e-3 then
					problems[#problems + 1] = m.name .. " holds " .. got .. " " .. m.fluid.name .. " of " .. m.fluid.amount
				end
			end
			if m.wired then
				local c = f.get_wire_connector(defines.wire_connector_id.circuit_red, false)
				if not (c and c.connection_count > 0) then problems[#problems + 1] = m.name .. " lost its red wire" end
			end
		end
	end
	for _, p in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL furnaces: " .. p) end
	log("DEVCHECK-MIGRATE-FURNACES " .. (#problems == 0 and "ok" or "failed") .. " (" .. furnaces .. " of " .. #st.list
		.. " ore machines are furnaces with their contents, " .. back .. " got the ingredients of their craft back)")
end

script.on_init(function()
	setup_furnaces()
	setup_vein_grid()
	setup_vein_ores()
	setup_power()
	setup_turbine()
	setup_techs()
	setup_removed()
	setup_planets()
	setup_mapgen()
	storage.items = "skipped"
	storage.patterns = "skipped"
	storage.state = "skipped"
	if not ((remote.interfaces[F] and prototypes.entity[DRIVE] and prototypes.entity["me-controller"]) or UNIFIED()) then
		log("DEVCHECK-MIGRATE-SETUP skipped (no ME fluid drives in this version)")
		log("DEVCHECK-MIGRATE-SETUP-PATTERNS skipped (no ME fluid drives in this version)")
		return
	end
	local s = game.surfaces[1]
	s.request_to_generate_chunks({ 0, Y }, 2)
	s.request_to_generate_chunks({ 120, Y }, 1)
	s.force_generate_chunk_requests()
	--- issue #68: the migration lays cables between the old ME blocks; on water it cannot (the player connects such
	--- a block), so the test area is land
	local land = {}
	for _, t in pairs(s.find_tiles_filtered{ area = { { -40, Y - 40 }, { 140, Y + 60 } }, collision_mask = "water_tile" }) do
		land[#land + 1] = { name = "landfill", position = t.position }
	end
	s.set_tiles(land)
	for _, e in pairs(s.find_entities_filtered{ area = { { -40, Y - 40 }, { 140, Y + 60 } }, type = { "tree", "simple-entity", "cliff" } }) do
		e.destroy()
	end
	local function place(name, x, y)
		return s.create_entity{ name = name, position = { x, y }, force = "player", raise_built = true }
	end
	local eei = place("electric-energy-interface", 0, Y)
	eei.power_production = 1e6
	eei.electric_buffer_size = 1e7
	place("substation", 3, Y)
	if R1() then
		local ctrl = place("me-network-controller", 6, Y)
		ctrl.energy = ctrl.electric_buffer_size                -- works at once (the fluid goes in during on_init)
	else
		place("me-controller", 6, Y)
	end
	if R2() then
		log("DEVCHECK-MIGRATE-SETUP skipped (fluid cells in this version: no fluid drives to convert)")
		setup_patterns(place)
		setup_items(place)
		setup_handover()
		return
	end
	local d1, d2 = place(DRIVE, FL_D1[1], FL_D1[2]), place(DRIVE, FL_D2[1], FL_D2[2])
	local lone = place(DRIVE, FL_LONE[1], FL_LONE[2])
	if R1() then remote.call(NET, "connect", { s.find_entity("me-network-controller", { 6, Y }), d1, d2 }, 16) end
	local ok = near(remote.call(F, "insert", d1, "water", TOTAL.water), TOTAL.water)
		and near(remote.call(F, "insert", d1, "chlorine", TOTAL.chlorine), TOTAL.chlorine)
	remote.call(F, "unpack_drive", lone, { fork_me_fluids = LONE })
	local pool = {}
	if remote.interfaces[F].salvage_items then
		local inv = game.create_inventory(1)
		inv[1].set_stack{ name = DRIVE, count = 1 }
		inv[1].tags = { fork_me_fluids = OLD_POOL }
		remote.call(F, "salvage_items", inv, s, "player", OLD_POOL_AT)
		inv.destroy()
		pool = remote.call(F, "recovered", s, "player")
		ok = ok and same(pool, OLD_POOL)
	end
	--- two loaded drive items (one stack, the same tags) in a chest
	local chest = place("iron-chest", FL_ITEMS[1], FL_ITEMS[2])
	chest.insert{ name = DRIVE, count = 2 }
	chest.get_inventory(defines.inventory.chest)[1].tags = { fork_me_fluids = { water = FL_ITEM_WATER } }
	storage.fluid_old = { d1 = remote.call(F, "drive", d1).contents, d2 = remote.call(F, "drive", d2).contents,
		lone = remote.call(F, "drive", lone).contents, pool = pool, e1 = d1, e2 = d2 }
	storage.state = ok and "ready" or "setup-failed"
	log("DEVCHECK-MIGRATE-SETUP " .. (ok and "ok" or "failed") .. (R1() and " (the cable network of R1)" or ""))
	setup_patterns(place)
	setup_items(place)
end)

--- runs after every mod or prototype change: tells the check which path ran
script.on_configuration_changed(function()
	storage.config_changed = true
	--- issue #209: a save from before me-network 0.5.0 is converted in the intermediate load with me-network 0.5.0; me-network
	--- 0.5.1 drops the conversion's reports (and their interface) on the next load, so the checks keep a copy
	local mig = remote.interfaces[MIGRATE]
	if mig then
		storage.me_reports = { report = mig.report and remote.call(MIGRATE, "report"),
			fluid_report = mig.fluid_report and remote.call(MIGRATE, "fluid_report") }
	end
end)

script.on_nth_tick(30, function(event)
	--- issue #206 (me-network #145): in a version without the legacy Crafting CPU (gone on load) the job of the old save is
	--- noted right after the load (queued, with what it held) and a multiblock CPU is built where the old CPU stood
	local job = storage.job
	if job and job.id and not job.after and not job.multiblock and not prototypes.entity["me-crafting-cpu"] then
		local j = remote.call(A, "job", job.id)
		job.after = j and j.status or "gone"
		for _, b in pairs(CPU_BLOCKS) do
			game.surfaces[1].create_entity{ name = b[1], position = { b[2], b[3] }, force = "player", raise_built = true }
		end
	end
	--- the turbine has to run first (this handler also fires at tick 0)
	if not storage.turbine_checked and event.tick >= 120 then
		storage.turbine_checked = true
		check_turbine()
	end
	--- the update resets the technology effects: the gear recipe, enabled by script in the old save, is
	--- researched in a real game
	if storage.job and not storage.job_recipe then
		storage.job_recipe = true
		game.forces.player.recipes[PT_RECIPE].enabled = true
	end
	if not storage.techs_checked and event.tick >= TT_CHECK_TICK then
		storage.techs_checked = true
		check_techs()
		check_removed()
		check_furnaces()
		check_planets()
		check_vein_grid()
		check_vein_ores()
		check_mapgen()
	end
	if storage.mapgen and storage.mapgen.phase and event.tick >= TT_CHECK_TICK + 30 then check_mapgen_fresh() end
	if not storage.handover_checked and event.tick >= HO_CHECK_TICK then
		storage.handover_checked = true
		check_handover()
	end
	if not storage.job_checked and event.tick >= CHECK_TICK then
		storage.job_checked = true
		check_job()
	end
	if storage.checked then return end
	storage.checked = true
	check_power()
	check_patterns()
	check_items()
	check_me_lenses()
	if storage.state ~= "ready" then
		log("DEVCHECK-MIGRATE-FLUIDS " .. (storage.state == "skipped" and "skipped" or "failed (" .. tostring(storage.state) .. ")"))
		return
	end
	check_fluids()
end)
