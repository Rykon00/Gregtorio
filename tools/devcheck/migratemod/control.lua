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
--- the job it must start a job of its own on the migrated pattern and reach its amount.
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

local function steam_in(e)
	local seg = e.fluidbox.get_fluid_segment_contents(1)
	return e.get_fluid_count("steam") + ((seg and seg.steam) or 0)
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
		local seg = t.fluidbox.get_fluid_segment_contents(1)
		burnt = p.plasma - t.get_fluid_count("helium-plasma") - ((seg and seg["helium-plasma"]) or 0)
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
local TT_TECHS = { "steam-compressor", "extruder", "end-steel", "alloy-blast-smelter", "industrial-mixer",
	"tier-three-microminers", "naquadah-processing", "uv-multiblocks", "osmium" }
local TT_CHECK_TICK = 60

local function setup_techs()
	local force, n = game.forces.player, 0
	local function research(name)
		local t = force.technologies[name]
		if not t or t.researched then return end
		for p, _ in pairs(t.prerequisites) do research(p) end
		t.researched = true
		n = n + 1
	end
	for _, name in pairs(TT_TECHS) do research(name) end
	storage.tt_enabled = {}
	for name, r in pairs(force.recipes) do if r.enabled then storage.tt_enabled[name] = true end end
	log("DEVCHECK-MIGRATE-SETUP-TECHS ok (" .. n .. " technologies researched)")
end

local function check_techs()
	if not storage.tt_enabled then
		log("DEVCHECK-MIGRATE-TECHS skipped")
		return
	end
	local force, problems, recipes, techs, new = game.forces.player, {}, 0, 0, 0
	for name, t in pairs(force.technologies) do
		if t.researched then
			techs = techs + 1
			for _, e in pairs(t.prototype.effects) do
				if e.type == "unlock-recipe" then
					local r = force.recipes[e.recipe]
					recipes = recipes + 1
					if not r.enabled then
						problems[#problems + 1] = e.recipe .. " of the researched technology " .. name .. " is not enabled"
					elseif not storage.tt_enabled[e.recipe] then
						new = new + 1
					end
				end
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
	["lv-air-collector"] = "lv-compressor", ["ev-air-collector"] = "ev-compressor",   -- issue #153
	["ev-greenhouse"] = "lv-greenhouse" }   -- issue #165
local RM_MACHINES = {
	{ "lv-chemical-reactor", "platinum-palladium-leachate-processing", nil },
	{ "lv-electrolyzer", "chloroplatinic-acid", nil },
	{ "lv-ore-washer", "palladium-dust", "crushed-palladium-washing" },
	{ "lv-mixer", "aqua-regia", "aqua-regia" },
	{ "mv-electric-blast-furnace", "platinum-group-residue-processing", "platinum-group-residue-processing" },
	{ "lv-chemical-reactor", "ammonia-hexachloroiridiate", nil },
	{ "lv-chemical-bath", "rhodium-sulfate-processing", nil },    -- the recipe stays, in the chemical reactor
	-- issue #152: every Extractor of an old save becomes the Fluid Extractor of its tier (the maintainer's choice): a melt
	-- keeps running, sticky resin is gone (an item recipe of the Extractor)
	{ "lv-extractor", "melt-iron-ingot", "melt-iron-ingot", "lv-fluid-extractor" },
	{ "lv-extractor", "sticky-resin", nil, "lv-fluid-extractor" },
	{ "ev-extractor", "melt-titanium-ingot", "melt-titanium-ingot", "ev-fluid-extractor" },
	-- issue #165: every greenhouse becomes the Extreme Industrial Greenhouse (lv-greenhouse), its recipe kept
	{ "hv-greenhouse", "growing-trees", "growing-trees", "lv-greenhouse" },
	-- issue #171: annealed copper moved to the Arc Furnace, the old electric blast furnace loads without it
	{ "mv-electric-blast-furnace", "annealed-copper-ingot", nil },
	-- issue #153: an Air Collector becomes the compressor of its tier and keeps making air (checked by the entity's
	-- name below)
	{ "lv-air-collector", "air-collection", "air-collection", "lv-compressor" },
	{ "hv-air-collector", "air-collection", "air-collection", "hv-compressor" },
}
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
		if prototypes.item[old] then items[#items + 1] = { old = old, new = new, count = chest.insert{ name = old, count = 5 } } end
	end
	local machines = {}
	for i, m in pairs(RM_MACHINES) do
		local r = prototypes.recipe[m[2]]
		if prototypes.entity[m[1]] and r then
			local e = s.create_entity{ name = m[1], position = { RM_AT[1] + 8 * (i - 1), RM_AT[2] + 12 }, force = "player",
				raise_built = true }
			game.forces.player.recipes[m[2]].enabled = true
			e.set_recipe(m[2])
			for _, ing in pairs(r.ingredients) do
				if ing.type == "item" then e.insert{ name = ing.name, count = ing.amount * 2 } end
			end
			machines[#machines + 1] = { entity = e, old = m[2], new = m[3], name = m[4] }
		end
	end
	if #list == 0 and #items == 0 and #machines == 0 then
		storage.removed = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-REMOVED skipped (none of the removed fluids or items in this version)")
		return
	end
	storage.removed = { tanks = list, chest = chest, items = items, machines = machines }
	log("DEVCHECK-MIGRATE-SETUP-REMOVED ok (" .. #list .. " fluids in tanks, " .. #items .. " items in a chest, "
		.. #machines .. " machines with recipes of the old line)")
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
		local r = m.entity.valid and m.entity.get_recipe()
		local got = r and r.name or nil
		if not m.entity.valid then
			problems[#problems + 1] = "the machine with " .. m.old .. " is gone"
		elseif got ~= m.new then
			problems[#problems + 1] = "the machine with " .. m.old .. " has " .. tostring(got) .. ", not " .. tostring(m.new)
		elseif m.name and m.entity.name ~= m.name then
			problems[#problems + 1] = "the machine with " .. m.old .. " is a " .. m.entity.name .. ", not a " .. m.name
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL removed: " .. m) end
	log("DEVCHECK-MIGRATE-REMOVED " .. (#problems == 0 and "ok" or "failed") .. " (" .. #p.tanks .. " fluids, "
		.. #p.items .. " items mapped, " .. #(p.machines or {}) .. " machines checked)")
end

local A = "gregtorio-me-autocraft"
local PT_ASSEMBLER, PT_FURNACE = { 14.5, Y + 8.5 }, { 19, Y + 13 }
local PT_PROVIDER_A, PT_PROVIDER_F = { 16.5, Y + 8.5 }, { 17.5, Y + 12.5 }
local PT_RECIPE, PT_FURNACE_RECIPE = "iron-gear-crafting-table", "iron-dust-smelter"
local JOB_GEARS = 5
local MAINT_POS, MAINT_KEEP = { 5.5, Y + 16.5 }, JOB_GEARS + 3        -- a level maintainer of the old save (issue #38)
local CHECK_TICK = 570                                                  -- the job and the maintainer are checked here

--- the version of the old save has the cable network of issue #68 step R1 (and still the old fluid drives)
function R1() return prototypes.entity["me-network-controller"] ~= nil end
--- the version of the old save stores fluids in fluid cells already (issue #68 step R2, 0.4.0 and later: the fluid
--- module has no `unpack_drive` any more): there are no fluid drives to convert, the network of the pattern, job and
--- maintainer checks is built without them
function R2() return remote.interfaces[F] ~= nil and not remote.interfaces[F].unpack_drive end

--- after the ME network of the fluid drives exists (its controller)
local function setup_patterns(place)
	if not (remote.interfaces[A] and prototypes.entity["me-pattern-provider"]) then
		storage.patterns = "skipped"
		log("DEVCHECK-MIGRATE-SETUP-PATTERNS skipped (no pattern providers in this version)")
		return
	end
	local m = place("me-molecular-assembler", PT_ASSEMBLER[1], PT_ASSEMBLER[2])
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
			remote.call("gregtorio-me-terminal", "encode_def", false, inv, false, give[2])
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
	storage.patterns = { provider = p, ok = set["iron-gear-wheel"] == true, choice = choice,
		assembler_provider = game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A) }
	log("DEVCHECK-MIGRATE-SETUP-PATTERNS " .. (set["iron-gear-wheel"] and "ok" or "failed") .. (choice and " (furnace recipe chosen)" or ""))
	--- a job of the old version on a crafting CPU (own power for the CPU and the assembler)
	local eei = place("electric-energy-interface", 12, Y + 15)
	eei.power_production = 1e6
	eei.electric_buffer_size = 1e7
	place("substation", 12, Y + 12)
	local cpu = place("me-crafting-cpu", 9, Y + 9)
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
		local ctrl = game.surfaces[1].find_entity("me-network-controller", { 6, Y })
		local members = { ctrl, cpu, drive, p, game.surfaces[1].find_entity("me-pattern-provider", PT_PROVIDER_A) }
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
	local no_cpu = not id and why == "no-free-cpu" and prototypes.entity["me-crafting-unit"]
	storage.job = { id = id, provider = p, skipped = no_cpu and true or nil }
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

local function check_job()
	local st = storage.job
	if not (st and st.id) then
		log("DEVCHECK-MIGRATE-JOB " .. (st and not st.skipped and "failed (no job in the old save)" or "skipped"))
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local j = remote.call(A, "job", st.id)
	local m = game.surfaces[1].find_entity("me-molecular-assembler", PT_ASSEMBLER)
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
		expect(n == 1 and slots == 1 and free == 1, "the old CPU: " .. n .. " CPUs, " .. tostring(slots) .. " slots, " .. free .. " free")
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
	log("DEVCHECK-MIGRATE-JOB " .. (#problems == 0 and "ok" or "failed") .. (st.maintainer and " (and the level maintainer's job)" or ""))
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
			note = " (crafting pattern " .. PT_RECIPE .. ", processing pattern " .. PT_FURNACE_RECIPE .. ")"
		else
			expect(not f1, "a fresh furnace without a choice got a pattern: " .. serpent.line(fi and fi.slots))
			note = " (crafting pattern " .. PT_RECIPE .. ", the furnace had no recipe)"
		end
	end
	for _, m in pairs(problems) do log("DEVCHECK-MIGRATE-FAIL patterns: " .. m) end
	log("DEVCHECK-MIGRATE-PATTERNS " .. (#problems == 0 and "ok" or "failed") .. note)
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
		expect(#s.find_entities_filtered{ name = name, type = "logistic-container" } == 0, "an old " .. name .. " is left")
	end
	expect(#s.find_entities_filtered{ name = "me-controller", type = "roboport" } == 0, "an old controller is left")
	expect(#s.find_entities_filtered{ name = "me-interface", type = "logistic-container" } == 0, "an old interface is left")
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
			s.find_entity("me-crafting-cpu", { 9, Y + 9 }), storage.patterns.provider, s.find_entity("me-drive", { 8.5, Y + 12.5 }) }) do
			expect(e and e.valid and remote.call(NET, "same_network", ctrl, e), (e and e.valid and e.name or "?") .. " is not connected to the controller")
		end
		--- the drive has four 1k cells, the 16k drive four 16k cells
		local cells = remote.call(NET, "drive", drive)
		expect(cells[4] and cells[4].name == "me-1k-storage-cell" and not cells[5], "new 1k drive " .. serpent.line(cells))
		local big = remote.call(NET, "drive", s.find_entity("me-drive", { 8.5, Y + 12.5 }))
		expect(big[4] and big[4].name == "me-16k-storage-cell", "new 16k drive " .. serpent.line(big))
		--- item totals: what the old chests held (+ the second controller) is in the network, the blueprint in a chest
		local report = remote.call("gregtorio-me-migrate", "report")
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
		local old = s.find_entities_filtered{ ghost_name = "me-drive-4k", position = IT_GHOST, radius = 0.5 }
		expect(#old == 0, "the ghost of an old drive is left")
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
		expect(#s.find_entities_filtered{ name = name } == 0, "an old " .. name .. " is left")
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
		local rep = remote.call("gregtorio-me-migrate", "fluid_report")
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

script.on_init(function()
	setup_power()
	setup_turbine()
	setup_techs()
	setup_removed()
	storage.items = "skipped"
	storage.patterns = "skipped"
	storage.state = "skipped"
	if not (remote.interfaces[F] and prototypes.entity[DRIVE] and prototypes.entity["me-controller"]) then
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
script.on_configuration_changed(function() storage.config_changed = true end)

script.on_nth_tick(30, function(event)
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
	end
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
	if storage.state ~= "ready" then
		log("DEVCHECK-MIGRATE-FLUIDS " .. (storage.state == "skipped" and "skipped" or "failed (" .. tostring(storage.state) .. ")"))
		return
	end
	check_fluids()
end)
