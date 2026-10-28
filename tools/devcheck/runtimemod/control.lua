--- Places every assembling machine that has an item, gives it a recipe and power, then lets
--- the benchmark run the map. Any runtime error in Gregtorio's scripts or the entities fails
--- the run. Results are logged as DEVCHECK-RUNTIME lines.
--- The ME network's runtime tests are in the mod me-network since issue #83 (its tools/devcheck).
--- Molds (prototypes/150-fork-molds.lua): an LV alloy smelter with a mold recipe must stop
--- without a mold, run with a mold in its mold slot and keep the mold there; issue #316: the same for an EV laser
--- engraver with a gem step and its lens ("Missing lens"); issue #642: a machine cloned onto its spot (on_entity_cloned).
--- Endgame power (prototypes/136-fork-power.lua): a plasma turbine and a naquadah reactor under load
--- must burn their fuel and make power; the turbine's output hatch gets the cooled fluid.
--- Fuel check (issue #25): steam and the other generator's fuel stop a generator; the right fuel runs it.
--- Turbine tiers (issue #34): the UHV to UXV plasma turbines under an overload give exactly four amps of
--- their tier and return the cooled fluid of the plasma they burnt.
--- Recipes of issue #35: grades 7 and 8, FPIC/APIC wafers and chips, complex SMDs and the recipes that
--- use them are crafted once each (setup_recipe_test).
--- Raw ore crushing (issue #202): with the unlocking technology researched (bedrockium for Raw Borax), the macerator and
--- the forge hammers (the steam one included) crush Raw Borax, Raw Tin, Raw Cassiterite and Raw Platinum, the hammer half.
--- Steam turbines (issue #97): the large and the high pressure steam turbine make their GT output, burn their GT flow
--- and give back distilled water and steam through output hatches; the wrong steam stops them; the multiblocks of
--- issue #97 can be blueprinted and mined.
--- Nuclear chain (issue #97): fluid nuclear reactor -> large heat exchanger -> high pressure steam turbine -> large
--- steam turbine makes power from fuel rods; depleted rods come out; the steam recipe of the heat exchanger is exact.
--- LFTR (issue #386, scripts/fork-power.lua): the reactor with fuel and coolant for two runs, a load of its 40.96 MW and
--- a substation. At LF_TICK the reactor works, its dynamo produces 40.96 MW and the load got energy; then the reactor is
--- destroyed and LF_GONE ticks later its dynamo must be gone.

--- Issue #535 (Factorio 2.1): what `e` and the fluid segment of its first box hold of `fluid`. An input-output box keeps part
--- of its fluid in the pipeline segment; 2.0's get_fluid_count gave the entity's part and LuaFluidBox's segment contents
--- the rest, 2.1's segment fluid is the whole segment, the entity's part with it
function fluid_total(e, fluid)
	if e.has_fluid_segment(1) then
		local f = e.get_fluid_segment_fluid(1)
		return f and f.name == fluid and f.amount or 0
	end
	return e.get_fluid_count(fluid)
end

local LF_X, LF_Y = -320.5, 250.5
local LF_TICK, LF_GONE = 600, 30
local LF_W = 40.96e6

function setup_lftr_test(s)
	local fails = {}
	local lf = {}
	storage.lftr = lf
	local ok, err = pcall(function()
		lf.reactor = s.create_entity{ name = "liquid-fluoride-thorium-reactor", position = { LF_X, LF_Y }, force = "player",
			raise_built = true }
		game.forces.player.recipes["lftr-fuel-1-burning"].enabled = true
		lf.reactor.set_recipe("lftr-fuel-1-burning")
		for _, f in pairs({ { "lftr-fuel-1", 20 }, { "lithium-tetrafluoroberyllate", 40 } }) do
			local got = lf.reactor.insert_fluid{ name = f[1], amount = f[2] }
			if math.abs(got - f[2]) > 1e-6 then fails[#fails + 1] = "LFTR test: the reactor took only " .. got .. " " .. f[1] end
		end
		lf.load = s.create_entity{ name = "electric-energy-interface", position = { LF_X, LF_Y + 6 }, force = "player" }
		lf.load.power_production = 0
		lf.load.power_usage = LF_W / 60
		lf.load.electric_buffer_size = 1e9
		lf.load.energy = 0
		s.create_entity{ name = "substation", position = { LF_X + 4, LF_Y + 3 }, force = "player" }
	end)
	if not ok then fails[#fails + 1] = "LFTR test: " .. tostring(err) end
	return fails
end

function lftr_test()
	local lf = storage.lftr
	if not lf or lf.done or game.tick < LF_TICK then return end
	local s = game.surfaces[1]
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	if not lf.destroyed_at then
		expect(lf.reactor and lf.reactor.valid, "the reactor is missing")
		if #problems == 0 then
			local r = lf.reactor
			local d = s.find_entity("lftr-dynamo", r.position)
			expect(r.status == defines.entity_status.working, "the reactor does not work (status " .. tostring(r.status) .. ")")
			expect(d ~= nil, "no dynamo under the reactor")
			if d then
				expect(math.abs(d.power_production * 60 - LF_W) < 1, "the dynamo produces " .. d.power_production * 60 .. " W, not 40.96 MW")
			end
			expect(lf.load.valid and lf.load.energy > 0, "the load got no energy")
			lf.summary = string.format(" (dynamo %.2f MW, load %.1f MJ in its buffer)", d and d.power_production * 60 / 1e6 or 0,
				lf.load.valid and lf.load.energy / 1e6 or 0)
			lf.position = r.position
			r.destroy{ raise_destroy = true }
			lf.destroyed_at = game.tick
		end
		if #problems > 0 then lf.done = true end
	elseif game.tick >= lf.destroyed_at + LF_GONE then
		expect(s.find_entity("lftr-dynamo", lf.position) == nil, "the dynamo stayed after the reactor was destroyed")
		lf.done = true
	else
		return
	end
	if not lf.done then return end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL LFTR test: " .. p) end
	log("DEVCHECK-RUNTIME-LFTR " .. (#problems == 0 and "ok" or "failed") .. (lf.summary or ""))
end

--- Lapotronic supercapacitor (issue #97): charges and discharges at two amps of its tier, holds its capacity by tier
--- and loses GT's 1 % per day.
--- Offered recipes (issue #126): the machine recipes that were hidden from the crafting menu are offered by the machines.
--- Melts and casts (issue #117): nine melted ingots fill one block cast, one fills an ingot cast; n melts cover every cast combination.
--- Supercapacitor upgrade (issue #124): a replaced supercapacitor keeps its charge (capped at the new capacity).
--- Electric mine (issue #335): a Manual Mine replaced by the Ore Drilling Plant Mk I by fast replace and by the upgrade
--- planner (construction robots) keeps its neighbouring inserters and belts, the items of its slots come back, and the
--- plant drills a vein with Drilling Fluid.
--- LFTR (issue #386): the Liquid Fluoride Thorium Reactor on LFTR Fuel 1 runs without power and its hidden dynamo gives
--- 40.96 MW into a network with a load; mined, the dynamo goes with it.
--- Victory: when the other tests have reported, `victory` is researched by script and must win the game.

local VICTORY_DEADLINE = 1450
local function tests_running()
	local running = {}
	local function check(done, name) if not done then running[#running + 1] = name end end
	check(storage.mold_done, "mold")
	check(storage.power_checked, "power")
	check(storage.fuel and storage.fuel.done, "fuel check")
	check(storage.cooled and storage.cooled.done, "cooled fluid")
	check(storage.tiers and storage.tiers.done, "turbine tiers")
	check(storage.recipe_test and storage.recipe_test.done, "recipes of issue #35")
	check(storage.crush and storage.crush.done, "raw ore crushing")
	check(storage.steam and storage.steam.done, "steam turbines")
	check(storage.chain and storage.chain.done, "nuclear chain")
	check(storage.lsc and storage.lsc.done, "supercapacitor")
	check(storage.lsup and storage.lsup.done, "supercapacitor upgrade")
	check(storage.elevator and storage.elevator.done, "space elevator")
	check(storage.offer and storage.offer.done, "recipes offered by machines")
	check(storage.melt and storage.melt.done, "melts and casts")
	check(storage.emine and storage.emine.done, "electric mine")
	check(storage.lftr and storage.lftr.done, "LFTR")
	check(storage.solar and storage.solar.done, "solar boilers")
	check(storage.coal_boiler and storage.coal_boiler.done, "coal boiler")
	check(storage.torch and storage.torch.done, "torch")
	check(storage.battery and storage.battery.done, "battery buffers")
	return running
end

function victory_test()
	if storage.victory_checked then return end
	local running = tests_running()
	if #running > 0 and game.tick < VICTORY_DEADLINE then return end
	storage.victory_checked = true
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	expect(#running == 0, "tests still running at tick " .. game.tick .. ": " .. table.concat(running, ", "))
	local ok, err = pcall(function() game.forces.player.technologies["victory"].researched = true end)
	expect(ok, "victory test: " .. tostring(err))
	--- (can_continue cannot be read before a player chooses to go on; the script passes it, see fork-victory.lua)
	expect(game.finished, "victory test: researching `victory` did not finish the game")
	--- Phase 6b: after victory, the post-victory technologies (MAX science) must be researchable. `victory` is
	--- infinite, so it is no prerequisite; their prerequisites are researched by script, then the engine must
	--- accept `godforge-upgrades` (the infinite sink) in the research queue, and researching its first level
	--- must give the godforge's magmatter recipe its productivity and leave the godforge unlocked.
	local force = game.forces.player
	local seen = {}
	local function research_prerequisites(tech)
		for name, pre in pairs(tech.prerequisites) do
			if not seen[name] then
				seen[name] = true
				research_prerequisites(pre)
				if not pre.researched then pre.researched = true end
			end
		end
	end
	local upgrades = force.technologies["godforge-upgrades"]
	ok, err = pcall(function()
		research_prerequisites(upgrades)
		force.research_queue = { "godforge-upgrades" }
	end)
	expect(ok, "post-victory test: " .. tostring(err))
	local queued = force.research_queue[1]
	expect(queued and queued.name == "godforge-upgrades",
		"post-victory test: godforge-upgrades was not accepted for research (prerequisites not met)")
	force.research_queue = {}
	upgrades.researched = true
	expect(upgrades.level == 2, "post-victory test: godforge-upgrades is at level " .. upgrades.level .. ", not 2")
	local bonus = force.recipes["molten-magmatter-from-neutronium"].productivity_bonus
	expect(math.abs(bonus - 0.05) < 1e-6, "post-victory test: magmatter productivity " .. bonus .. ", not 0.05")
	expect(force.recipes["godforge"].enabled and force.technologies["max-materials"].enabled,
		"post-victory test: the godforge recipe is not unlocked")
	log("DEVCHECK-RUNTIME-POSTVICTORY " .. (#problems == 0 and "ok" or "failed") .. " (godforge-upgrades level 1, "
		.. (seen["victory"] and "victory is a prerequisite" or "after victory") .. ")")
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL " .. p) end
	log("DEVCHECK-RUNTIME-VICTORY " .. (#problems == 0 and "ok" or "failed") .. " (tick " .. game.tick .. ")")
end

--- Endgame power (prototypes/136-fork-power.lua, scripts/fork-power.lua): a LuV large plasma turbine
--- with helium plasma and a turbine output hatch next to it, and a UV large naquadah reactor with
--- naquadah based fuel MK1, each loaded by an electric energy interface that draws the generator's
--- full output. After 7 s both must have produced power and burnt fuel, and the hatch must hold the
--- cooled fluid (helium) for the plasma the turbine burnt (see the cooled fluid test below).
local PW_Y = 260                                        -- below the fluid test and its roboport area
local PW_TICK = 420
local PW = {
	turbine = { "luv-large-plasma-turbine", 1.5, PW_Y + 1.5, "helium-plasma", 100, 81.92e6 },
	hatch = { "turbine-output-hatch", 3.5, PW_Y + 1.5 },
	reactor = { "uv-large-naquadah-reactor", 42.5, PW_Y + 2.5, "naquadah-based-fuel-mk1", 10, 327.68e6 },
}

function setup_power_test(s)
	local fails = {}
	local function place(def)
		local ok, e = pcall(function()
			return s.create_entity{ name = def[1], position = { def[2], def[3] }, force = "player", raise_built = true }
		end)
		if not (ok and e) then fails[#fails + 1] = "power test " .. def[1] .. ": " .. tostring(e) return nil end
		return e
	end
	for _, key in pairs({ "turbine", "reactor" }) do
		local def = PW[key]
		local g = place(def)
		if g then
			local got = g.insert_fluid{ name = def[4], amount = def[5] }
			if got < def[5] then fails[#fails + 1] = "power test: " .. def[1] .. " took only " .. got .. " " .. def[4] end
			local ok, err = pcall(function()
				local eei = s.create_entity{ name = "electric-energy-interface", position = { def[2], def[3] + 6 }, force = "player" }
				eei.power_production = 0
				eei.power_usage = def[6] / 60
				eei.electric_buffer_size = 1e8
				s.create_entity{ name = "substation", position = { def[2] + 4, def[3] + 6 }, force = "player" }
			end)
			if not ok then fails[#fails + 1] = "power test load: " .. tostring(err) end
		end
	end
	place(PW.hatch)
	return fails
end

script.on_nth_tick(PW_TICK, function(event)
	if storage.power_checked or event.tick == 0 then return end
	storage.power_checked = true
	local s = game.surfaces[1]
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function find(def) return s.find_entity(def[1], { def[2], def[3] }) end
	local turbine, hatch, reactor = find(PW.turbine), find(PW.hatch), find(PW.reactor)
	expect(turbine and hatch and reactor, "power test entities missing")
	--- an input-output fluid box keeps part of its fluid in the pipeline segment (fluid_total)
	local function fluid_in(e, fluid) return fluid_total(e, fluid) end
	local summary = ""
	if #problems == 0 then
		local seconds = event.tick / 60
		--- turbine: 81.92 MW on helium plasma (81.92 MJ per unit) burns one unit per second
		local left = fluid_in(turbine, "helium-plasma")
		local burnt = PW.turbine[5] - left
		expect(turbine.energy_generated_last_tick > 0, "plasma turbine generates nothing")
		expect(burnt > 0.6 * seconds and burnt < 1.2 * seconds, "plasma turbine burnt " .. burnt .. " helium plasma in " .. seconds .. " s")
		local helium = hatch.get_fluid_count("helium")
		local owed = remote.call("gregtorio-power", "debt", turbine) + remote.call("gregtorio-power", "energy", turbine) / PW.turbine[6]
		expect(helium > 0, "the output hatch got no helium")
		expect(math.abs(helium + owed - burnt) <= cooled_tolerance(burnt), "hatch holds " .. helium .. " helium (+ " .. owed .. " owed) for " .. burnt .. " plasma burnt")
		expect(hatch.get_fluid_count("helium-plasma") == 0, "plasma leaked into the output hatch")
		--- reactor: 327.68 MW on fuel MK1 (58.5 GJ per unit) burns 0.0056 units per second
		local fuel_left = fluid_in(reactor, "naquadah-based-fuel-mk1")
		local fuel_burnt = PW.reactor[5] - fuel_left
		expect(reactor.energy_generated_last_tick > 0, "naquadah reactor generates nothing")
		expect(fuel_burnt > 0.003 * seconds and fuel_burnt < 0.007 * seconds, "naquadah reactor burnt " .. fuel_burnt .. " fuel in " .. seconds .. " s")
		summary = string.format(" (turbine %.2f plasma -> %.2f helium, %.1f MW; reactor %.4f fuel, %.1f MW)",
			burnt, helium, turbine.energy_generated_last_tick * 60 / 1e6, fuel_burnt, reactor.energy_generated_last_tick * 60 / 1e6)
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL " .. p) end
	log("DEVCHECK-RUNTIME-POWER " .. (#problems == 0 and "ok" or "failed") .. summary)
end)

--- Fuel check (issue #25, scripts/fork-power.lua): generators on a wrong fluid, each with its own
--- load of the generator's full output and its own network (25 tiles apart). Steam (through a pipe)
--- in a plasma turbine, steam in a naquadah reactor, naquadah fuel in a plasma turbine and plasma in
--- a naquadah reactor must make no power, keep their fluid and show "Wrong fuel"; after the right
--- fuel is put in they run. A running turbine whose plasma is replaced by steam burns steam for at
--- most one check interval (10 ticks, the documented window) and then stops.
local FC_Y = PW_Y
local FC_WINDOW_TICKS = 10
local FC = {
	--  key            generator                     x      wrong fluid                amount  right fuel                 amount  load (W)
	{ "steam_turbine", "luv-large-plasma-turbine",   75.5,  "steam",                   100,    "helium-plasma",           100,    81.92e6, pipe = true },
	{ "steam_reactor", "uv-large-naquadah-reactor",  100.5, "steam",                   500,    "naquadah-based-fuel-mk1", 10,     327.68e6 },
	{ "fuel_turbine",  "luv-large-plasma-turbine",   125.5, "naquadah-based-fuel-mk1", 10,     "helium-plasma",           100,    81.92e6 },
	{ "plasma_reactor", "uv-large-naquadah-reactor", 150.5, "helium-plasma",           100,    "naquadah-based-fuel-mk1", 10,     327.68e6 },
	--- issue #34: the new tiers take the same fuel check (1000 plasma: 7.8 s of the UXV turbine)
	{ "steam_uxv",     "uxv-large-plasma-turbine",   200.5, "steam",                   100,    "helium-plasma",           1000,   10485.76e6 },
	{ "fuel_uev",      "uev-large-plasma-turbine",   225.5, "naquadah-based-fuel-mk1", 10,     "helium-plasma",           100,    1310.72e6 },
	{ "window",        "luv-large-plasma-turbine",   175.5, "steam",                   500,    "helium-plasma",           100,    81.92e6 },
}

--- an input-output fluid box keeps part of its fluid in the pipeline segment (fluid_total, see the power test)
local function fc_fluid_in(e, fluid) return fluid_total(e, fluid) end

function setup_fuel_test(s)
	local fails = {}
	storage.fuel = { gens = {} }
	for _, def in ipairs(FC) do
		local ok, err = pcall(function()
			local y = FC_Y + (def[2]:find("reactor") and 2.5 or 1.5)
			local g = s.create_entity{ name = def[2], position = { def[3], y }, force = "player", raise_built = true }
			local first, amount = def[4], def[5]
			if def[1] == "window" then first, amount = def[6], def[7] end
			if def.pipe then
				--- the north connection of the 3x3 turbine is one tile above its top edge
				local pipe = s.create_entity{ name = "pipe", position = { def[3], y - 2 }, force = "player" }
				local got = pipe.insert_fluid{ name = first, amount = amount }
				if got < amount then fails[#fails + 1] = "fuel test: the pipe took only " .. got .. " " .. first end
			else
				local got = g.insert_fluid{ name = first, amount = amount }
				if got < amount then fails[#fails + 1] = "fuel test: " .. def[1] .. " took only " .. got .. " " .. first end
			end
			local eei = s.create_entity{ name = "electric-energy-interface", position = { def[3], y + 6 }, force = "player" }
			eei.power_production = 0
			eei.power_usage = def[8] / 60
			eei.electric_buffer_size = math.max(1e8, 2 * def[8] / 60)
			s.create_entity{ name = "substation", position = { def[3] + 4, y + 6 }, force = "player" }
			storage.fuel.gens[def[1]] = g
		end)
		if not ok then fails[#fails + 1] = "fuel test " .. def[1] .. ": " .. tostring(err) end
	end
	return fails
end

--- The window turbine: from the swap on, its plasma is taken out every tick, and on the tick it is
--- empty the steam goes in, so the fuel check (every 10 ticks) meets steam that may have burnt since
function fuel_window_tick()
	local st = storage.fuel
	if not (st and st.phase and not st.window_swapped and not st.done) then return end
	local def = FC[#FC]
	local g = st.gens.window
	if not (g and g.valid) then return end
	g.extract_fluid{ name = def[6], amount = 1e9 }
	if fc_fluid_in(g, def[6]) > 0 then return end
	local got = g.insert_fluid{ name = def[4], amount = def[5] }
	if math.abs(got - def[5]) > 1e-6 then log("DEVCHECK-RUNTIME-FAIL fuel test: window turbine took only " .. got .. " steam") end
	st.window_swapped, st.window_stopped = game.tick, g.disabled_by_script
end

function fuel_test()
	local st = storage.fuel
	if not st then return end
	local tick = game.tick
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function label_key(e)
		local cs = e.custom_status
		return cs and type(cs.label) == "table" and cs.label[1] or nil
	end
	local function finish(summary)
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL fuel test: " .. p) end
		log("DEVCHECK-RUNTIME-FUEL " .. (#problems == 0 and "ok" or "failed") .. (summary or ""))
	end
	for _, def in ipairs(FC) do
		if not (st.gens[def[1]] and st.gens[def[1]].valid) then
			problems[#problems + 1] = "generator " .. def[1] .. " missing"
			return finish()
		end
	end
	if not st.phase and tick >= 120 then
		--- wrong fuels: no power, fluid kept, status set; the window turbine runs on plasma
		for _, def in ipairs(FC) do
			local g = st.gens[def[1]]
			if def[1] == "window" then
				expect(g.energy_generated_last_tick > 0, "window turbine does not run on plasma")
				expect(not g.disabled_by_script, "window turbine stopped on plasma")
			else
				local left = fc_fluid_in(g, def[4])
				expect(g.energy_generated_last_tick == 0, def[1] .. " generates " .. g.energy_generated_last_tick .. " J/tick on " .. def[4])
				expect(math.abs(left - def[5]) < 1e-6, def[1] .. " holds " .. left .. " " .. def[4] .. " of " .. def[5])
				expect(g.disabled_by_script, def[1] .. " is not stopped")
				expect(label_key(g) == "entity-status.fork-wrong-fuel", def[1] .. " status " .. serpent.line(g.custom_status))
			end
		end
		if #problems > 0 then return finish() end
		st.phase, st.drain = "draining", 0
	elseif st.phase == "draining" then
		--- swap: empty the stopped ones (removing takes only the entity's share, the segment gives
		--- the rest back over the next ticks), then put the right fuel in; the window turbine is
		--- swapped every tick by fuel_window_tick
		local left = 0
		for _, def in ipairs(FC) do
			if def[1] ~= "window" then
				local g = st.gens[def[1]]
				g.extract_fluid{ name = def[4], amount = 1e9 }
				left = left + fc_fluid_in(g, def[4])
			end
		end
		st.drain = st.drain + 1
		if left > 0 then
			if st.drain > 30 then
				problems[#problems + 1] = "could not empty the generators (" .. left .. " left)"
				return finish()
			end
			return
		end
		for _, def in ipairs(FC) do
			if def[1] ~= "window" then
				local g = st.gens[def[1]]
				local got = g.insert_fluid{ name = def[6], amount = def[7] }
				expect(math.abs(got - def[7]) < 1e-6, def[1] .. " took only " .. got .. " " .. def[6] .. " after emptying it")
			end
		end
		st.phase, st.swapped = "right", tick
		if #problems > 0 then return finish() end
	elseif st.phase == "right" and st.window_swapped and not st.window_mid and tick >= st.window_swapped + FC_WINDOW_TICKS + 10 then
		st.window_mid = fc_fluid_in(st.gens.window, FC[#FC][4])
	elseif st.phase == "right" and st.window_mid and tick >= math.max(st.swapped, st.window_swapped) + 60 then
		local summary = ""
		for _, def in ipairs(FC) do
			local g = st.gens[def[1]]
			if def[1] == "window" then
				--- at most one interval of the full output on steam (+1 tick for the check order)
				local burnt = def[5] - fc_fluid_in(g, def[4])
				local max = def[8] * (FC_WINDOW_TICKS + 1) / 60 / prototypes.fluid[def[4]].fuel_value
				expect(burnt <= max, "window turbine burnt " .. burnt .. " steam, more than " .. max)
				--- a stopped generator keeps its last energy_generated_last_tick: the steam must not move
				expect(st.window_mid and math.abs(fc_fluid_in(g, def[4]) - st.window_mid) < 1e-6,
					"window turbine still burns steam (" .. tostring(st.window_mid) .. " -> " .. fc_fluid_in(g, def[4]) .. ")")
				expect(g.disabled_by_script, "window turbine is not stopped")
				expect(label_key(g) == "entity-status.fork-wrong-fuel", "window turbine status " .. serpent.line(g.custom_status))
				summary = string.format(" (window: %.1f steam = %.2f MJ burnt, swapped on tick %d %s)", burnt,
					burnt * prototypes.fluid[def[4]].fuel_value / 1e6, st.window_swapped,
					st.window_stopped and "after the turbine had stopped" or "while the turbine ran")
			else
				local burnt = def[7] - fc_fluid_in(g, def[6])
				expect(g.energy_generated_last_tick > 0, def[1] .. " does not run on " .. def[6])
				expect(burnt > 0, def[1] .. " burnt no " .. def[6])
				expect(not g.disabled_by_script, def[1] .. " still stopped on " .. def[6])
				expect(g.custom_status == nil, def[1] .. " still has status " .. serpent.line(g.custom_status))
			end
		end
		return finish(summary)
	elseif tick > 900 then
		problems[#problems + 1] = "timed out in phase " .. tostring(st.phase)
		return finish()
	end
end

--- Cooled fluid (issue #28, scripts/fork-power.lua): the cooled fluid in a turbine's output hatch
--- must match the plasma it burnt, one unit per unit, within COOLED_TOL (relative) + COOLED_ABS
--- units, whatever the load. Every LuV plasma turbine has its own load (an electric energy interface
--- that draws exactly the given share of 81.92 MW per tick, no buffer), set every tick:
---   full, partial (40 %), burst (full for 5 ticks out of 23, idle in between): a known amount of
---     helium plasma burnt to the last drop, then the hatch must hold exactly that much helium;
---   idle: no load; only the first fill of the load's buffer is burnt, and returned;
---   full_hatch: the hatch starts with 3999 of its 4000 helium, so the rest stays owed; once it is
---     emptied it must get all of it;
---   pair_a, pair_b: two turbines side by side on helium and nitrogen plasma, one hatch each: each
---     hatch gets only its own cooled fluid, in the right amount.
--- A running turbine is compared as hatch + owed + the energy of the current step / fuel value.
local CO_Y = 370
local COOLED_TOL, COOLED_ABS = 1e-3, 1e-3
local CO_DEADLINE = 1300
local CO_POWER = 81.92e6
local CO = {
	--  key           x      plasma            amount  load(tick)                                       hatch x offset
	{ "full",       200.5, "helium-plasma",   4,     function() return 1 end,                         2 },
	{ "partial",    225.5, "helium-plasma",   2,     function() return 0.4 end,                       2 },
	{ "burst",      250.5, "helium-plasma",   1.5,   function(t) return t % 23 < 5 and 1 or 0 end,    2 },
	{ "idle",       275.5, "helium-plasma",   10,    function() return 0 end,                         2 },
	{ "full_hatch", 300.5, "helium-plasma",   100,   function() return 1 end,                         2 },
	{ "pair_a",     330.5, "helium-plasma",   100,   function() return 1 end,                         -2 },
	{ "pair_b",     333.5, "nitrogen-plasma", 100,   function() return 1 end,                         2 },
}
local CO_PREFILL = 3999

function cooled_tolerance(burnt) return COOLED_ABS + COOLED_TOL * burnt end

function setup_cooled_test(s)
	local fails = {}
	storage.cooled = { t = {} }
	for i, def in ipairs(CO) do
		local ok, err = pcall(function()
			local g = s.create_entity{ name = "luv-large-plasma-turbine", position = { def[2], CO_Y }, force = "player", raise_built = true }
			local got = g.insert_fluid{ name = def[3], amount = def[4] }
			if math.abs(got - def[4]) > 1e-6 then fails[#fails + 1] = "cooled test: " .. def[1] .. " took only " .. got .. " " .. def[3] end
			local eei = s.create_entity{ name = "electric-energy-interface", position = { def[2], CO_Y + 6 }, force = "player" }
			eei.power_production = 0
			eei.power_usage = 0
			eei.electric_buffer_size = CO_POWER / 60
			s.create_entity{ name = "substation", position = { def[2] + (def[6] > 0 and 4 or -4), CO_Y + 6 }, force = "player" }
			local h = s.create_entity{ name = "turbine-output-hatch", position = { def[2] + def[6], CO_Y }, force = "player", raise_built = true }
			storage.cooled.t[def[1]] = { g = g, eei = eei, h = h, i = i, removed = 0 }
		end)
		if not ok then fails[#fails + 1] = "cooled test " .. def[1] .. ": " .. tostring(err) end
	end
	local fh = storage.cooled.t.full_hatch
	if fh then
		local got = fh.h.insert_fluid{ name = "helium", amount = CO_PREFILL }
		if math.abs(got - CO_PREFILL) > 1e-6 then fails[#fails + 1] = "cooled test: the full hatch took only " .. got .. " helium" end
	end
	return fails
end

--- Every tick: the load of each turbine
function cooled_load_tick(tick)
	local st = storage.cooled
	if not st or st.done then return end
	for _, c in pairs(st.t) do
		if c.eei.valid then c.eei.power_usage = CO_POWER / 60 * CO[c.i][5](tick) end
	end
end

function cooled_test()
	local st = storage.cooled
	if not st then return end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function finish(summary)
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL cooled fluid test: " .. p) end
		log("DEVCHECK-RUNTIME-COOLED " .. (#problems == 0 and "ok" or "failed") .. (summary or ""))
	end
	for _, def in ipairs(CO) do
		local c = st.t[def[1]]
		if not (c and c.g.valid and c.h.valid and c.eei.valid) then
			problems[#problems + 1] = def[1] .. " missing"
			return finish()
		end
	end
	local P = "gregtorio-power"
	--- the plasma a turbine burnt (entity and segment) and the cooled fluid it returned: in the hatch
	--- (and taken out of it by the test), owed, and the energy of the current step
	local function account(c)
		local def = CO[c.i]
		local fuel = prototypes.fluid[def[3]].fuel_value
		local out = def[3] == "helium-plasma" and "helium" or "nitrogen"
		local burnt = def[4] - fluid_total(c.g, def[3])
		local prefill = def[1] == "full_hatch" and CO_PREFILL or 0
		local hatch = c.h.get_fluid_count(out) + c.removed - prefill
		local owed = remote.call(P, "debt", c.g, out)
		local pending = remote.call(P, "energy", c.g) / fuel
		return burnt, hatch, owed, pending, out
	end
	local function matches(key, c)
		local burnt, hatch, owed, pending, out = account(c)
		local ok = math.abs(hatch + owed + pending - burnt) <= cooled_tolerance(burnt)
		st.worst = math.max(st.worst or 0, math.abs(hatch + owed + pending - burnt) / burnt)
		expect(ok, string.format("%s: %.6f plasma burnt, hatch got %.6f %s, %.6f owed, %.6f pending", key, burnt, hatch, out, owed, pending))
		return burnt, hatch + owed + pending - burnt
	end
	local tick = game.tick
	st.dry = st.dry or {}
	--- the known amounts: burnt to the last drop, stopped for "no fuel", nothing owed or pending
	for _, key in pairs({ "full", "partial", "burst" }) do
		local c = st.t[key]
		if not st.dry[key] then
			local burnt, hatch, owed, pending = account(c)
			local amount = CO[c.i][4]
			if burnt >= amount - 1e-9 and owed < 1e-4 and pending == 0 and c.g.disabled_by_script then
				st.dry[key] = { tick = tick, hatch = hatch }
				st.worst = math.max(st.worst or 0, math.abs(hatch - amount) / amount)
				expect(math.abs(hatch - amount) <= cooled_tolerance(amount),
					string.format("%s: %.6f plasma burnt, the hatch got %.6f", key, amount, hatch))
			end
		end
	end
	--- the full hatch: full, the rest owed; then emptied, and it must get everything
	local fh = st.t.full_hatch
	if not st.hatch_phase then
		local burnt, _, owed = account(fh)
		if burnt >= 3 then
			expect(math.abs(fh.h.get_fluid_count("helium") - 4000) < 1e-3, "full hatch holds " .. fh.h.get_fluid_count("helium") .. " of 4000")
			expect(owed > 1.5, "full hatch: only " .. owed .. " helium owed for " .. burnt .. " plasma burnt")
			matches("full_hatch (full)", fh)
			st.hatch_owed = owed
			fh.removed = fh.removed + fh.h.extract_fluid{ name = "helium", amount = 4000 }
			st.hatch_phase = tick
		end
	elseif st.hatch_phase ~= true and tick >= st.hatch_phase + 60 then
		matches("full_hatch (emptied)", fh)
		local _, _, owed = account(fh)
		expect(owed < 0.2, "full hatch: still " .. owed .. " helium owed after it was emptied")
		st.hatch_phase = true
	end
	--- the pair: own fluid only, right amounts
	if not st.pair_checked and account(st.t.pair_a) >= 3 then
		matches("pair_a", st.t.pair_a)
		matches("pair_b", st.t.pair_b)
		expect(st.t.pair_a.h.get_fluid_count("nitrogen") == 0, "pair_a's hatch got nitrogen")
		expect(st.t.pair_b.h.get_fluid_count("helium") == 0, "pair_b's hatch got helium")
		expect(account(st.t.pair_b) > 1, "pair_b burnt only " .. account(st.t.pair_b) .. " nitrogen plasma")
		st.pair_checked = true
	end
	if #problems > 0 then return finish() end
	if st.dry.full and st.dry.partial and st.dry.burst and st.hatch_phase == true and st.pair_checked then
		--- idle: only the first fill of its load's buffer (one tick of output each) is burnt
		local idle_burnt = matches("idle", st.t.idle)
		expect(idle_burnt < 3 / 60 + 1e-6, "idle turbine burnt " .. idle_burnt .. " plasma")
		return finish(string.format(" (4/2/1.5 plasma -> %.6f/%.6f/%.6f helium at full/40%%/burst load, worst error %.1e, full hatch owed %.2f)",
			st.dry.full.hatch, st.dry.partial.hatch, st.dry.burst.hatch, st.worst or 0, st.hatch_owed))
	end
	if tick > CO_DEADLINE then
		local left = {}
		for _, key in pairs({ "full", "partial", "burst" }) do
			if not st.dry[key] then
				local burnt, hatch, owed, pending = account(st.t[key])
				left[key] = { burnt = burnt, hatch = hatch, owed = owed, pending = pending, stopped = st.t[key].g.disabled_by_script }
			end
		end
		expect(false, "timed out: dry " .. serpent.line(st.dry) .. " (not yet: " .. serpent.line(left) .. ")" .. ", full hatch " .. tostring(st.hatch_phase) .. ", pair " .. tostring(st.pair_checked))
		return finish()
	end
end

--- Turbine tiers (issue #34, prototypes/136-fork-power.lua): one UHV to UXV (and MAX, phase 6b) large plasma turbine each
--- and a second UXV one on neon plasma, with an output hatch and a load of twice its output (an electric
--- energy interface in its own network). While it runs, every turbine must generate exactly four amps
--- of its tier per tick (the cap, not the load; fluid_usage_per_tick must let the weakest plasma, neon,
--- reach it too); once its plasma (one to one and a half seconds of full output) is burnt to the last
--- drop, its hatch must hold exactly that much cooled fluid (tolerance of the cooled fluid test).
--- The runtime code is the one of the LuV turbines: the new turbines are only listed in the mod data.
local TT_Y = -260                                       -- above the machine grid, below the recipe test
local TT_CHECK_TICK = 20
local TT_DEADLINE = 600
local TT = {
	--  turbine                     x      plasma            amount  cooled fluid    cap (W)
	{ "uhv-large-plasma-turbine", 100.5, "helium-plasma",   8,      "helium",       655.36e6 },
	{ "uev-large-plasma-turbine", 125.5, "helium-plasma",   16,     "helium",       1310.72e6 },
	{ "uiv-large-plasma-turbine", 150.5, "nitrogen-plasma", 30,     "nitrogen",     2621.44e6 },
	{ "umv-large-plasma-turbine", 175.5, "iron-plasma",     30,     "molten-iron",  5242.88e6 },
	{ "uxv-large-plasma-turbine", 200.5, "helium-plasma",   128,    "helium",       10485.76e6 },
	--- the weakest plasma (20.48 MJ): the UXV turbine needs 8.53 of its 9 units per tick for the cap
	{ "uxv-large-plasma-turbine", 225.5, "neon-plasma",     512,    "neon",         10485.76e6 },
	--- phase 6b (prototypes/141-fork-max.lua): the MAX turbine, also on the weakest plasma (17.07 of its 18 units)
	{ "max-large-plasma-turbine", 250.5, "helium-plasma",   256,    "helium",       20971.52e6 },
	{ "max-large-plasma-turbine", 275.5, "neon-plasma",     960,    "neon",         20971.52e6 },
}

function setup_tier_test(s)
	local fails = {}
	storage.tiers = { t = {}, dry = {} }
	for i, def in ipairs(TT) do
		local ok, err = pcall(function()
			local g = s.create_entity{ name = def[1], position = { def[2], TT_Y }, force = "player", raise_built = true }
			local got = g.insert_fluid{ name = def[3], amount = def[4] }
			if math.abs(got - def[4]) > 1e-6 then fails[#fails + 1] = "tier test: " .. def[1] .. " took only " .. got .. " " .. def[3] end
			local eei = s.create_entity{ name = "electric-energy-interface", position = { def[2], TT_Y + 6 }, force = "player" }
			eei.power_production = 0
			eei.power_usage = 2 * def[6] / 60
			eei.electric_buffer_size = 4 * def[6] / 60
			s.create_entity{ name = "substation", position = { def[2] + 4, TT_Y + 6 }, force = "player" }
			local h = s.create_entity{ name = "turbine-output-hatch", position = { def[2] + 2, TT_Y }, force = "player", raise_built = true }
			storage.tiers.t[i] = { g = g, h = h }
		end)
		if not ok then fails[#fails + 1] = "tier test " .. def[1] .. ": " .. tostring(err) end
	end
	return fails
end

function tier_test()
	local st = storage.tiers
	if not st then return end
	local tick = game.tick
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function finish(summary)
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL turbine tier test: " .. p) end
		log("DEVCHECK-RUNTIME-TIERS " .. (#problems == 0 and "ok" or "failed") .. (summary or ""))
	end
	for i, def in ipairs(TT) do
		local c = st.t[i]
		if not (c and c.g.valid and c.h.valid) then
			problems[#problems + 1] = def[1] .. " missing"
			return finish()
		end
	end
	--- the cap: four amps of the tier per tick under twice that load, as the prototype says
	if not st.capped and tick >= TT_CHECK_TICK then
		for i, def in ipairs(TT) do
			local g = st.t[i].g
			local per_tick = def[6] / 60
			local max = g.prototype.get_max_power_output()
			expect(math.abs(max - per_tick) <= 1e-6 * per_tick, def[1] .. ": max_power_output " .. max * 60 .. " W, expected " .. def[6])
			expect(not g.disabled_by_script, def[1] .. " is stopped on " .. def[3] .. " (" .. serpent.line(g.custom_status) .. ")")
			expect(math.abs(g.energy_generated_last_tick - per_tick) <= 1e-6 * per_tick,
				string.format("%s generates %.6g W under a load of %.6g W, expected the cap %.6g W", def[1],
					g.energy_generated_last_tick * 60, 2 * def[6], def[6]))
		end
		st.capped = true
		if #problems > 0 then return finish() end
	end
	--- the cooled fluid: burnt to the last drop (stopped for "no fuel", nothing owed or pending)
	for i, def in ipairs(TT) do
		local c = st.t[i]
		if not st.dry[i] then
			local burnt = def[4] - fluid_total(c.g, def[3])
			local owed = remote.call("gregtorio-power", "debt", c.g, def[5])
			local pending = remote.call("gregtorio-power", "energy", c.g)
			if burnt >= def[4] - 1e-9 and owed < 1e-4 and pending == 0 and c.g.disabled_by_script then
				local hatch = c.h.get_fluid_count(def[5])
				st.dry[i] = { tick = tick, hatch = hatch }
				st.worst = math.max(st.worst or 0, math.abs(hatch - def[4]) / def[4])
				expect(math.abs(hatch - def[4]) <= cooled_tolerance(def[4]),
					string.format("%s: %.6f %s burnt, the hatch got %.6f %s", def[1], def[4], def[3], hatch, def[5]))
				expect(c.h.get_fluid_count(def[3]) == 0, def[1] .. ": plasma leaked into the output hatch")
			end
		end
	end
	if #problems > 0 then return finish() end
	if st.capped and table_size(st.dry) == #TT then
		local parts = {}
		for i, def in ipairs(TT) do
			parts[#parts + 1] = string.format("%s %.6g MW: %g -> %.6f", def[1]:sub(1, 3), def[6] / 1e6, def[4], st.dry[i].hatch)
		end
		return finish(string.format(" (%s; worst error %.1e)", table.concat(parts, ", "), st.worst or 0))
	end
	if tick > TT_DEADLINE then
		expect(false, "timed out: capped " .. tostring(st.capped) .. ", dry " .. serpent.line(st.dry))
		return finish()
	end
end

--- New recipes of issue #35 (prototypes/129-fork-water-purification.lua): grades 7 and 8 in the water
--- purification plant, the FPIC and APIC wafers and chips, the complex SMDs, the quark creation catalyst
--- and recipes that take the new parts; the same for issues #39 and #36 and phase 6a (plasma forge, QFT).
--- Each machine gets one craft's ingredients (placed above the machine grid, powered like it); once it
--- crafts, its progress is set close to the end (the grades take 25 and 30 s, a mainframe 12 minutes), and
--- the main product must come out (a main product with a probability: the craft must finish).
local RT_Y = -300
local RT_DEADLINE = 900
local RT = {
	{ "water-purification-plant", "grade-7-water" },
	{ "water-purification-plant", "grade-8-water" },
	{ "uhv-laser-engraver", "fpic-wafer" },
	{ "uev-laser-engraver", "apic-wafer" },
	{ "uhv-assembling-machine", "femto-power-ic" },
	{ "uev-assembling-machine", "atto-power-ic" },
	{ "uv-assembling-machine", "complex-smd-transistor" },
	{ "uv-assembling-machine", "complex-smd-resistor" },
	{ "uv-assembling-machine", "complex-smd-capacitor" },
	{ "uv-assembling-machine", "complex-smd-diode" },
	{ "uv-assembling-machine", "complex-smd-inductor" },
	{ "zpm-assembly-line", "quark-creation-catalyst" },
	{ "zpm-assembly-line", "uev-energy-hatch" },
	{ "zpm-assembly-line", "uiv-energy-hatch" },
	{ "zpm-assembly-line", "fusion-reactor-mk4-controller" },
	{ "luv-circuit-assembly-line", "wetware-processor-mainframe" },
	-- issues #39 and #36 (prototypes/137-fork-endgame-materials.lua): the drafts made real, the new
	-- materials and recipes that take them
	{ "iv-circuit-assembler", "lapotronic-energy-orb-cluster" },
	{ "ev-assembling-machine", "wrapped-plutonium-ingot" },
	{ "hv-implosion-compressor", "high-density-plutonium-nugget" },
	{ "luv-mixer", "plutonium-based-liquid-fuel" },
	{ "hv-mixer", "super-coolant" },
	{ "hv-canning-machine", "1080k-super-coolant-cell" },
	{ "zpm-electric-blast-furnace", "hot-fluxed-electrum-ingot" },
	{ "zpm-alloy-blast-smelter", "molten-fluxed-electrum" },
	{ "uv-electric-blast-furnace", "hot-bedrockium-ingot" },
	{ "uhv-electric-blast-furnace", "hot-quantium-ingot" },
	{ "iv-fluid-extractor", "molten-quantium" },
	{ "uhv-mixer", "naquadah-based-fuel-mk2" },
	{ "water-purification-plant", "grade-5-water" },
	{ "zpm-assembly-line", "uxv-energy-hatch" },
	-- phase 6a (prototypes/139-fork-endgame-multiblocks.lua): a plasma forge recipe (the catalyst and a metal) and
	-- a quantum force transformer recipe in the real machines
	{ "dimensionally-transcendent-plasma-forge", "excited-dimensionally-transcendent-crude-catalyst" },
	{ "dimensionally-transcendent-plasma-forge", "molten-spacetime-dtpf-crude" },
	{ "quantum-force-transformer", "metallic-platinum-powder-qft-platinum-dust" },
	-- phase 6b (prototypes/140-fork-godforge.lua, 141-fork-max.lua): godforge recipes (star matter, magmatter), the
	-- stellar catalyst in the plasma forge, a MAX component, a recipe in a MAX machine and the MAX pack from MAX parts
	{ "godforge", "raw-star-matter" },
	{ "godforge", "molten-magmatter-from-neutronium" },
	{ "dimensionally-transcendent-plasma-forge", "excited-dimensionally-transcendent-stellar-catalyst" },
	{ "zpm-assembly-line", "max-motor" },
	{ "max-assembling-machine", "maximum-voltage-coil" },
	{ "uxv-assembling-machine", "max-science-pack-from-magmatter" },
	-- issue #91 (prototypes/142-fork-recipe-unlocks.lua): the producers GT has and Gregtorio lacked, the new machines
	-- (component assembly line) and recipes that were never unlocked
	{ "ev-electric-blast-furnace", "naquadah-doped-monocrystaline-silicon-boule" },
	{ "mv-pyrolyse-oven", "charcoal-byproducts" },
	{ "ev-large-chemical-reactor", "cyanoacetic-acid" },
	{ "iv-large-chemical-reactor", "cyanoacrylate-polymer" },   -- (issue #635: super glue takes two steps)
	-- issue #635 (prototypes/101-fork-machines.lua): the fluid heater (water into steam, the glue line's polymer) and the
	-- packager (a pile twin)
	{ "hv-fluid-heater", "super-glue" },
	-- issue #628 (prototypes/164-fork-chemistry.lua section 51): GTNH's wetware printed board and the PCB Factory's optical one
	{ "hv-chemical-reactor", "wetware-printed-circuit-board" },
	{ "pcb-factory", "optical-printed-circuit-board" },
	{ "lv-fluid-heater", "water-fluid-heater" },
	{ "lv-packager", "packager-iron-dust-from-small-piles" },
	{ "component-assembly-line", "lv-motor-coal" },
	-- issue #126 (prototypes/148-fork-gtnh-table-items.lua): GTNH's machine recipes of the items the crafting table made
	{ "lv-fluid-solidifier", "anvil-fluid-solidifier" },
	{ "mv-alloy-smelter", "anvil-alloy-smelter" },
	{ "lv-assembling-machine", "firebrick-block-assembling-machine" },
	{ "lv-chemical-bath", "paper-chemical-bath" },
	-- issue #185 (prototypes/155-fork-ore-chain.lua): GTNH's ore chain for iron, the thermal centrifuge, a new byproduct dust
	{ "lv-ore-washer", "purified-iron" },
	{ "lv-thermal-centrifuge", "centrifuged-iron" },
	{ "iv-thermal-centrifuge", "centrifuged-copper-from-crushed" },
	{ "lv-macerator", "impure-iron-dust" },
	{ "lv-macerator", "centrifuged-iron-maceration" },
	{ "lv-centrifuge", "centrifuging-pure-iron-dust" },
	{ "mv-electrolyzer", "pyrite-dust-decomposition" },   -- issue #223: MV as GT's
	-- issues #222 and #223: GT's parts of the new ingots, nugget recipes, bricked blast furnace and raw ore smelting
	{ "mv-bending-machine", "double-thorium-plate" },
	{ "lv-lathe", "antimony-rod" },
	{ "lv-alloy-smelter", "iron-nugget-from-ingot" },
	{ "lv-macerator", "copper-nugget-maceration" },
	{ "primitive-blast-furnace", "galena-dust-pbf-coke" },
	-- issue #227: GT's parts of every metal (158)
	{ "mv-bending-machine", "double-steel-plate" },
	{ "lv-alloy-smelter", "steel-item-casing" },
	{ "hv-extruder", "staballoy-ring" },
	-- issue #186: chemical bath washing with mercury and sodium persulfate
	{ "lv-chemical-bath", "purified-gold-mercury" },
	{ "mv-chemical-bath", "purified-iron-sodium-persulfate" },
	-- issue #199: nickel's platinum byproduct is the platinum line's metallic powder
	{ "lv-macerator", "pure-nickel-dust" },
	-- issues #187 and #188: the electromagnetic separator, gem sifting and grades, the autoclave, forge hammer crushing
	-- (the steam forge hammer runs the same category, but the test gives steam machines no steam)
	{ "lv-electromagnetic-separator", "separating-pure-tin-dust" },
	{ "iv-electromagnetic-separator", "separating-pure-bastnasite-dust" },
	{ "lv-sifting-machine", "sifting-purified-ruby" },
	{ "lv-forge-hammer", "hammering-exquisite-ruby" },
	{ "hv-implosion-compressor", "implosion-chipped-emerald-to-flawed" },
	{ "lv-lathe", "ruby-lens-from-exquisite" },
	{ "lv-macerator", "flawless-lapis-maceration" },
	{ "mv-autoclave", "autoclave-pure-lapis-dust-distilled-water" },
	{ "lv-forge-hammer", "hammering-raw-iron" },
	{ "lv-forge-hammer", "hammering-centrifuged-copper" },
	-- issue #193: the LV autoclave, a laser engraver grade step with its lens, small piles and dark ash
	{ "lv-autoclave", "autoclave-impure-certus-quartz-dust" },
	{ "mv-laser-engraver", "engraving-chipped-ruby-to-flawed" },
	{ "ev-laser-engraver", "engraving-flawless-emerald-to-exquisite" },
	{ "lv-lathe", "diamond-lens-from-exquisite" },
	{ "lv-macerator", "flawed-ruby-maceration" },
	{ "lv-electrolyzer", "dark-ash-dust-electrolysis" },
	-- issue #170 (prototypes/101-fork-machines.lua): the electric Forge Hammer with a plate and a new hammer recipe
	{ "lv-forge-hammer", "iron-plate-forge-hammer" },
	{ "iv-forge-hammer", "sand-forge-hammer" },
	-- issue #171: the Arc Furnace makes annealed copper (copper and oxygen)
	{ "lv-arc-furnace", "annealed-copper-ingot" },
	-- issue #190 (prototypes/157-fork-recycling.lua): an item back into its materials in the three machines
	{ "lv-macerator", "recycling-macerator-lv-motor" },
	{ "lv-arc-furnace", "recycling-arc-furnace-lv-machine-casing" },
	{ "lv-fluid-extractor", "recycling-fluid-extractor-lv-machine-casing" },
	{ "iv-arc-furnace", "annealed-copper-ingot" },
	-- issue #173: the Forming Press presses the printed circuits of the ME processors
	{ "lv-forming-press", "printed-silicon" },
	{ "iv-forming-press", "printed-engineering-circuit" },
	-- issue #174: the Electric Furnace smelts
	{ "lv-electric-furnace", "iron-dust-smelter" },
	{ "iv-electric-furnace", "brick-smelter" },
	-- issue #175: the Sifting Machine runs the sifter recipes of the Large Sifter
	{ "lv-sifting-machine", "coal-sifter" },
	{ "iv-sifting-machine", "refined-platinum-salt" },
	-- issue #153 (prototypes/153-fork-compressor-air.lua): air from the compressor
	{ "lv-compressor", "air-collection" },
	{ "iv-large-electric-compressor", "air-collection" },
	-- issues #159 and #195 (prototypes/120-fork-me-network-compat.lua): the ME Pattern Terminal and its nether quartz
	-- plate, me-network's Acceleration Card
	{ "lv-bending-machine", "nether-quartz-plate" },
	{ "mv-assembling-machine", "me-pattern-terminal" },
	{ "lv-assembling-machine", "me-acceleration-card" },
	-- issue #126, part B: the vanilla hand-only recipes in the assembling machines
	{ "lv-assembling-machine", "firearm-magazine" },
	{ "lv-assembling-machine", "light-armor" },
	{ "lv-assembling-machine", "rail-ramp" },
	{ "lv-assembling-machine", "rail-support" },
	{ "lv-assembling-machine", "tree-seed" },          -- (wood-processing before Factorio 2.1, issue #535)
	{ "mv-canning-machine", "depleted-uranium-fuel-rod-centrifuging" },
	{ "lv-compressor", "block-of-copper" },
	{ "iv-alloy-blast-smelter", "molten-hastelloy-c276" },
	{ "ev-fluid-solidifier", "solidify-hastelloy-c276-ingot" },
	-- issue #91 part 2 (prototypes/143-fork-casting.lua): a cast of every form (with the mold) and melts of the
	-- extractor, a new melt (steel), one whose old melt came at ZPM (titanium) and one at IV (iridium)
	{ "lv-fluid-solidifier", "solidify-steel-ingot" },
	{ "lv-fluid-solidifier", "solidify-steel-plate" },
	{ "lv-fluid-solidifier", "solidify-block-of-steel" },
	{ "mv-fluid-solidifier", "solidify-hsss-nugget" },
	{ "lv-fluid-solidifier", "solidify-steel-gear" },
	{ "lv-fluid-solidifier", "solidify-large-steel-gear" },
	{ "lv-fluid-solidifier", "solidify-steel-rotor" },
	{ "lv-fluid-solidifier", "solidify-steel-rod" },
	{ "lv-fluid-solidifier", "solidify-long-steel-rod" },
	{ "lv-fluid-solidifier", "solidify-steel-bolt" },
	{ "lv-fluid-solidifier", "solidify-tin-ring" },
	{ "lv-fluid-solidifier", "solidify-steel-screw" },
	{ "ev-fluid-solidifier", "solidify-soularium-round" },
	{ "lv-fluid-extractor", "melt-steel-ingot" },
	{ "ev-fluid-extractor", "melt-titanium-ingot" },
	{ "iv-fluid-extractor", "melt-iridium-ingot" },
	-- issue #152 (prototypes/151-fork-fluid-extractor.lua): the item recipes stay in the Extractor, the Large Fluid
	-- Extractor melts
	{ "lv-extractor", "sticky-resin" },
	{ "lv-extractor", "raw-rubber-pulp-extractor" },
	{ "iv-large-extractor", "melt-copper-ingot" },
	-- issue #91 part 3 (prototypes/144-fork-dead-fluids.lua): blast furnace recipes with neon, krypton and xenon, nitric
	-- acid from nitrogen dioxide, raw gasoline, gasoline and its cell
	{ "ev-electric-blast-furnace", "hot-titanium-ingot-neon" },
	{ "ev-electric-blast-furnace", "hot-tungsten-ingot-krypton" },
	{ "iv-electric-blast-furnace", "hot-iridium-ingot-xenon" },
	{ "hv-large-chemical-reactor", "nitric-acid-from-nitrogen-dioxide" },
	{ "hv-large-chemical-reactor", "raw-gasoline" },
	{ "hv-large-chemical-reactor", "gasoline" },
	{ "lv-canning-machine", "gasoline-cell" },
	-- issue #98 (prototypes/147-fork-gt-routes.lua): the second printed board and sodium persulfate, black plutonium
	-- and cosmic neutronium in the blast furnace (without gas and with a gas) and the vacuum freezer, the high octane
	-- line (its reactor recipe has five fluid inputs), GT's deuterium and PPIC wafer
	{ "lv-chemical-reactor", "plastic-printed-circuit-board-sodium-persulfate" },
	{ "lv-electrolyzer", "sodium-persulfate" },
	{ "zpm-electric-blast-furnace", "hot-black-plutonium-ingot" },
	{ "zpm-electric-blast-furnace", "hot-cosmic-neutronium-ingot-xenon" },
	{ "zpm-vacuum-freezer", "black-plutonium-ingot" },
	{ "zpm-vacuum-freezer", "cosmic-neutronium-ingot-from-hot-ingot" },
	{ "hv-cracker", "hydrocracked-light-fuel" },
	{ "hv-tall-distillation-tower", "distilling-hydrocracked-light-fuel" },
	{ "ev-large-chemical-reactor", "high-octane-gasoline" },
	{ "lv-canning-machine", "high-octane-gasoline-cell" },
	{ "lv-centrifuge", "deuterium" },
	{ "zpm-large-chemical-reactor", "ppic-wafer-sunnarium" },
	-- issue #96 (prototypes/146-fork-platinum-line.lua): GTNH's platinum line, the sludge to platinum and palladium dust
	{ "lv-chemical-reactor", "platinum-group-sludge-pentlandite" },
	{ "lv-centrifuge", "platinum-group-sludge-centrifuging" },
	{ "lv-chemical-reactor", "platinum-concentrate" },
	{ "hv-large-chemical-reactor", "platinum-salt" },
	{ "hv-large-sifter", "refined-platinum-salt" },
	{ "mv-electric-blast-furnace", "metallic-platinum-powder-from-refined-salt" },
	{ "lv-chemical-reactor", "reprecipitated-platinum-processing" },
	{ "lv-chemical-reactor", "palladium-salt" },
	{ "hv-large-chemical-reactor", "reprecipitated-palladium-processing" },
	{ "lv-ore-washer", "crushed-platinum-washing" },
	-- the residue branches (rhodium, ruthenium, osmium, iridium)
	{ "lv-chemical-reactor", "potassium-disulfate" },
	{ "mv-electric-blast-furnace", "platinum-group-residue-processing" },
	{ "hv-large-chemical-reactor", "rhodium-sulfate-processing" },
	{ "hv-large-sifter", "rhodium-filter-cake" },
	{ "hv-large-chemical-reactor", "reprecipitated-rhodium-processing" },
	{ "mv-electric-blast-furnace", "iridium-group-sludge-processing" },
	{ "hv-tall-distillation-tower", "ruthenium-tetroxide-solution-distillation" },
	{ "mv-fluid-solidifier", "ruthenium-tetroxide" },
	{ "iv-tall-distillation-tower", "osmium-solution" },
	{ "hv-large-chemical-reactor", "iridium-chloride" },
	{ "ev-large-chemical-reactor", "iridium-dust" },
	{ "lv-centrifuge", "sludge-dust-residue-centrifuging" },
	-- issue #205: the byproduct gems and GT's dust-to-gem routes, ore-form smelting's new nuggets and ingots, the
	-- naquadah line as GT's
	{ "hv-implosion-compressor", "implosion-ruby-dust-to-gem" },
	{ "lv-autoclave", "autoclave-quartzite-dust" },
	{ "lv-lathe", "yellow-garnet-lens-from-exquisite" },
	{ "mv-laser-engraver", "engraving-chipped-tricalcium-phosphate-to-flawed" },
	{ "lv-alloy-smelter", "copper-ingot-from-nuggets" },
	{ "lv-macerator", "thorium-dust-macerator" },
	{ "lv-chemical-reactor", "gallium-from-gallium-hydroxide" },
	{ "lv-mixer", "indium-gallium-phosphide-from-indium-phosphate" },
	{ "iv-electric-blast-furnace", "hot-naquadah-ingot" },
	{ "hv-autoclave", "concentrated-enriched-naquadah-sludge" },
	{ "zpm-centrifuge", "naquadria-oxide-mixture-centrifuging" },
	{ "iv-large-chemical-reactor", "naquadria-rich-solution-from-phosphate" },
}

local function rt_product(recipe)
	local r = prototypes.recipe[recipe]
	for _, p in pairs(r.products) do
		if p.name == (r.main_product and r.main_product.name or p.name) then return p end
	end
end

function setup_recipe_test(s)
	local fails = {}
	storage.recipe_test = { m = {}, ok = {} }
	local x = -150
	for i, def in pairs(RT) do
		local ok, err = pcall(function()
			local e = s.create_entity{ name = def[1], position = { x, RT_Y }, force = "player", raise_built = true }
			s.create_entity{ name = "electric-energy-interface", position = { x, RT_Y + 7 }, force = "player" }
			s.create_entity{ name = "substation", position = { x + 5, RT_Y + 7 }, force = "player" }
			e.force.recipes[def[2]].enabled = true
			-- issue #560: a furnace (the ore machines) picks the recipe from the ingredients
			if e.type ~= "furnace" then e.set_recipe(def[2]) end
			-- a recipe that needs a mold (prototypes/150-fork-molds.lua) gets one in the mold slot
			local molds = prototypes.mod_data["fork-mold-recipes"]
			if molds and molds.data[def[2]] then e.get_module_inventory().insert{ name = molds.data[def[2]] } end
			-- (fluids first: a furnace takes the item of an item and fluid recipe only with the fluid in it, issue #560)
			for _, kind in pairs({ "fluid", "item" }) do
				for _, ing in pairs(prototypes.recipe[def[2]].ingredients) do
					if ing.type == "item" and kind == "item" then
						local n = e.insert{ name = ing.name, count = ing.amount }
						assert(n == ing.amount, "only " .. n .. " of " .. ing.amount .. " " .. ing.name .. " fit")
					elseif ing.type == "fluid" and kind == "fluid" then
						local n = e.insert_fluid{ name = ing.name, amount = ing.amount }
						assert(math.abs(n - ing.amount) < 1e-6, "only " .. n .. " of " .. ing.amount .. " " .. ing.name .. " fit")
					end
				end
			end
			storage.recipe_test.m[i] = e
		end)
		if not ok then fails[#fails + 1] = "recipe test " .. def[2] .. " in " .. def[1] .. ": " .. tostring(err) end
		x = x + 18
	end
	return fails
end

function recipe_test()
	local st = storage.recipe_test
	if not st or st.done then return end
	local pending = {}
	for i, def in pairs(RT) do
		local e = st.m[i]
		if e and e.valid and not st.ok[i] then
			local p = rt_product(def[2])
			local made = p.type == "fluid" and e.get_fluid_count(p.name) or
				e.get_inventory(defines.inventory.crafter_output).get_item_count(p.name)
			-- a main product with a probability (the QFT's focused output) may roll nothing: a finished craft counts
			if made >= (p.amount or p.amount_min or 1) - 1e-6 or (p.independent_probability < 1 and e.products_finished > 0) then
				st.ok[i] = true
			else
				if e.crafting_progress > 0 and e.crafting_progress < 0.999 then e.crafting_progress = 0.999 end
				local status
				for name, v in pairs(defines.entity_status) do if e.status == v then status = name end end
				pending[#pending + 1] = def[2] .. " (" .. tostring(status) .. ", progress " .. e.crafting_progress .. ", made " .. made .. ")"
			end
		end
	end
	local n = 0
	for _ in pairs(st.ok) do n = n + 1 end
	if #pending == 0 or game.tick > RT_DEADLINE then
		st.done = true
		local problems = {}
		if n < #RT then problems[#problems + 1] = "recipe test: " .. (#RT - n) .. " of " .. #RT .. " recipes made nothing: " .. table.concat(pending, ", ") end
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL " .. p) end
		log("DEVCHECK-RUNTIME-RECIPES " .. (#problems == 0 and "ok" or "failed") .. " (" .. n .. " of " .. #RT .. " recipes crafted by tick " .. game.tick .. ")")
	end
end

--- Raw ore crushing (issue #202, prototypes/155-fork-ore-chain.lua phase O4): with only the technology that unlocks each
--- recipe researched by script (Raw Borax's: bedrockium, also the technology of its only source), the LV macerator crushes
--- the raw ore and the forge hammers do through hammering-<raw ore>, with half the macerator's crushed ores. Borax in every
--- forge hammer (the steam one on steam put into its energy box), tin, cassiterite, platinum and ruby (the hammer gives GT's
--- gem) in the LV and the steam one.
--- One raw ore per machine; once a machine crafts, its progress is set close to the end (the macerator takes 20 s).
local CR_Y, CR_X = -350, -370
local CR_DEADLINE = 900
local CR = {
	--  raw ore            macerator recipe        hammer recipe                 technology   every hammer  hammer gives
	{ "raw-borax",       "crushed-borax",       "hammering-raw-borax",        "bedrockium", true },
	{ "raw-tin",         "macerating-raw-tin",  "hammering-raw-tin" },
	{ "raw-cassiterite", "crushed-cassiterite", "hammering-raw-cassiterite" },
	{ "raw-platinum",    "crushed-platinum",    "hammering-raw-platinum" },
	{ "raw-ruby",        "crushed-ruby",        "hammering-raw-ruby",         nil,         nil,          "ruby" },
}

local function cr_techs(recipe)
	local out = {}
	for tname, t in pairs(prototypes.technology) do
		for _, e in pairs(t.effects) do
			if e.type == "unlock-recipe" and e.recipe == recipe then out[#out + 1] = tname end
		end
	end
	table.sort(out)
	return out
end

function setup_crush_test(s)
	local fails = {}
	storage.crush = { m = {}, ok = {}, researched = {} }
	local st = storage.crush
	local force = game.forces.player
	local hammers = {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "assembling-machine" } }) do
		if p.crafting_categories["lv-forge-hammer-recipes"] and p.items_to_place_this and #p.items_to_place_this > 0 then
			hammers[#hammers + 1] = name
		end
	end
	table.sort(hammers)
	local x = CR_X
	for _, def in ipairs(CR) do
		local ok, err = pcall(function()
			local mac, ham = prototypes.recipe[def[2]], prototypes.recipe[def[3]]
			assert(mac and ham, "no recipe " .. (mac and def[3] or def[2]))
			local mac_out, ham_out = mac.products[1], ham.products[1]
			assert(mac.ingredients[1].name == def[1] and ham.ingredients[1].name == def[1], "the recipes do not take " .. def[1])
			assert(ham_out.name == (def[6] or mac_out.name) and ham_out.amount * 2 == mac_out.amount, def[3] .. " gives " .. ham_out.amount
				.. " " .. ham_out.name .. ", " .. def[2] .. " " .. mac_out.amount .. " " .. mac_out.name .. " (GTNH: half)")
			for _, r in pairs({ def[2], def[3] }) do
				local techs = cr_techs(r)
				assert(#techs > 0, "no technology unlocks " .. r)
				if def[4] then
					assert(#techs == 1 and techs[1] == def[4], r .. " is unlocked by " .. table.concat(techs, ", ") .. ", not " .. def[4])
				end
				force.technologies[techs[1]].researched = true
				st.researched[techs[1]] = true
				assert(force.recipes[r].enabled, r .. " not enabled after researching " .. techs[1])
			end
			local machines = { { "lv-macerator", def[2] } }
			for _, h in pairs(def[5] and hammers or { "steam-forge-hammer", "lv-forge-hammer" }) do
				machines[#machines + 1] = { h, def[3] }
			end
			for _, m in pairs(machines) do
				local e = s.create_entity{ name = m[1], position = { x, CR_Y }, force = "player", raise_built = true }
				if e.prototype.electric_energy_source_prototype then
					s.create_entity{ name = "electric-energy-interface", position = { x, CR_Y + 7 }, force = "player" }
					s.create_entity{ name = "substation", position = { x + 3, CR_Y + 7 }, force = "player" }
				end
				if e.type ~= "furnace" then e.set_recipe(m[2]) end      -- (issue #560: the macerator picks it)
				assert(e.insert{ name = def[1], count = 1 } == 1, m[1] .. " took no " .. def[1])
				st.m[#st.m + 1] = { e = e, recipe = m[2], machine = m[1], product = prototypes.recipe[m[2]].products[1] }
				x = x + 9
			end
		end)
		if not ok then fails[#fails + 1] = "crush test " .. def[1] .. ": " .. tostring(err) end
	end
	st.hammers = #hammers
	return fails
end

function crush_test()
	local st = storage.crush
	if not st or st.done then return end
	local pending = {}
	for i, c in pairs(st.m) do
		local e = c.e
		if not st.ok[i] then
			if not e.valid then
				pending[#pending + 1] = c.recipe .. " in " .. c.machine .. " (machine gone)"
			else
				local made = e.get_inventory(defines.inventory.crafter_output).get_item_count(c.product.name)
				if made >= c.product.amount then
					st.ok[i] = made == c.product.amount or (c.recipe .. " in " .. c.machine .. " made " .. made)
				else
					if not e.prototype.electric_energy_source_prototype then
						pcall(function() e.insert_fluid{ name = "steam", amount = 100 } end)
					end
					if e.crafting_progress > 0 and e.crafting_progress < 0.999 then e.crafting_progress = 0.999 end
					local status
					for name, v in pairs(defines.entity_status) do if e.status == v then status = name end end
					pending[#pending + 1] = c.recipe .. " in " .. c.machine .. " (" .. tostring(status) .. ", made " .. made .. ")"
				end
			end
		end
	end
	if #pending > 0 and game.tick <= CR_DEADLINE then return end
	st.done = true
	local problems, n = {}, 0
	for _, v in pairs(st.ok) do
		if v == true then n = n + 1 else problems[#problems + 1] = v end
	end
	if #pending > 0 then problems[#problems + 1] = #pending .. " machines made nothing: " .. table.concat(pending, ", ") end
	if #st.m < 2 + 3 * #CR or st.hammers < 2 then problems[#problems + 1] = "only " .. #st.m .. " machines set up, " .. st.hammers .. " forge hammers" end
	local techs = {}
	for t in pairs(st.researched) do techs[#techs + 1] = t end
	table.sort(techs)
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL crush test: " .. p) end
	log("DEVCHECK-RUNTIME-CRUSH " .. (#problems == 0 and "ok" or "failed") .. " (" .. n .. " of " .. #st.m .. " crushed by tick "
		.. game.tick .. ", " .. st.hammers .. " forge hammers; researched " .. table.concat(techs, ", ") .. ")")
end

--- The ore line as furnaces (issue #560, prototypes/101-fork-machines.lua section 2n): GTNH's iron chain from raw ore to dust
--- in LV machines that get no recipe set. Raw iron goes into a macerator; the script carries each machine's main product
--- into the next one (as inserters would) and keeps the ore washer's water up; once a machine crafts, its progress is set
--- close to the end. Each machine must be a furnace, pick the expected recipe from its input, have an output slot for every
--- result of it (the byproducts) and make the product; both iron dust routes must end in iron dust.
local OL_X, OL_Y = 180.5, -60.5
local OL_DEADLINE = 1500
local OL = {
	--  machine                  recipe it must pick              input (from station)  the product it passes on
	{ "lv-macerator",          "crushed-iron",                  { "raw-iron", 2 },     "crushed-iron" },
	{ "lv-ore-washer",         "purified-iron",                 { from = 1, take = 1 }, "purified-iron", water = true },
	{ "lv-thermal-centrifuge", "centrifuged-iron",              { from = 2, take = 1 }, "centrifuged-iron" },
	{ "lv-macerator",          "centrifuged-iron-maceration",   { from = 3, take = 1 }, "iron-dust" },
	{ "lv-macerator",          "impure-iron-dust",              { from = 1, take = 1 }, "impure-iron-dust" },
	{ "lv-centrifuge",         "centrifuging-impure-iron-dust", { from = 5, take = 1 }, "iron-dust" },
}

local function furnace_recipe_name(e)
	local r = e.get_recipe()
	if r then return r.name end
	local p = e.previous_recipe
	local n = p and p.name
	return n and (type(n) == "string" and n or n.name) or nil
end

function setup_orefurnace_test(s)
	local fails = {}
	local st = { m = {}, taken = {}, picked = {} }
	storage.orefurnace = st
	local ok, err = pcall(function()
		for i, def in ipairs(OL) do
			local x = OL_X + 9 * (i - 1)
			local e = s.create_entity{ name = def[1], position = { x, OL_Y }, force = "player", raise_built = true }
			s.create_entity{ name = "electric-energy-interface", position = { x, OL_Y + 7 }, force = "player" }
			s.create_entity{ name = "substation", position = { x + 3, OL_Y + 7 }, force = "player" }
			e.force.recipes[def[2]].enabled = true
			if def[3][1] then assert(e.insert{ name = def[3][1], count = def[3][2] } == def[3][2], def[1] .. " took no " .. def[3][1]) end
			st.m[i] = e
			st.taken[i] = 0
		end
	end)
	if not ok then
		fails[#fails + 1] = "ore furnace test setup: " .. tostring(err)
		st.done = true
		log("DEVCHECK-RUNTIME-OREFURNACE failed (setup)")
	end
	return fails
end

function orefurnace_test()
	local st = storage.orefurnace
	if not st or st.done then return end
	local pending = {}
	for i, def in ipairs(OL) do
		local e = st.m[i]
		if e and e.valid then
			st.picked[i] = st.picked[i] or (e.get_recipe() and e.get_recipe().name)
			--- (the water first: the washer takes crushed ore only with water in it)
			local water = def.water and 200 - e.get_fluid_count("water") or 0
			if water > 0 then e.insert_fluid{ name = "water", amount = water } end
			local src = def[3].from and st.m[def[3].from]
			if src and src.valid and st.taken[i] < def[3].take then
				local out = src.get_inventory(defines.inventory.crafter_output)
				local item = OL[def[3].from][4]
				local n = math.min(out.get_item_count(item), def[3].take - st.taken[i])
				if n > 0 then
					local put = e.insert{ name = item, count = n }
					if put > 0 then out.remove{ name = item, count = put } end
					st.taken[i] = st.taken[i] + put
				end
			end
			if e.crafting_progress > 0 and e.crafting_progress < 0.999 then e.crafting_progress = 0.999 end
			if e.products_finished == 0 then pending[#pending + 1] = def[2] .. " in " .. def[1] end
		end
	end
	if #pending > 0 and game.tick <= OL_DEADLINE then return end
	st.done = true
	local problems = {}
	for i, def in ipairs(OL) do
		local e = st.m[i]
		if not (e and e.valid) then
			problems[#problems + 1] = def[1] .. " (station " .. i .. ") is gone"
		else
			if e.type ~= "furnace" then problems[#problems + 1] = def[1] .. " is a " .. e.type .. ", not a furnace" end
			local picked = st.picked[i] or furnace_recipe_name(e)
			if picked ~= def[2] then
				problems[#problems + 1] = def[1] .. " (station " .. i .. ") picked " .. tostring(picked) .. ", not " .. def[2]
			end
			local slots = #e.get_inventory(defines.inventory.crafter_output)
			local items = 0
			for _, p in pairs(prototypes.recipe[def[2]].products) do if p.type == "item" then items = items + 1 end end
			if slots < items then
				problems[#problems + 1] = def[1] .. " has " .. slots .. " output slots for the " .. items .. " results of " .. def[2]
			end
		end
	end
	if #pending > 0 then problems[#problems + 1] = "made nothing: " .. table.concat(pending, ", ") end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL ore furnace test: " .. p) end
	log("DEVCHECK-RUNTIME-OREFURNACE " .. (#problems == 0 and "ok" or "failed") .. " (" .. #OL .. " furnaces from raw iron to "
		.. "iron dust without a recipe set, by tick " .. game.tick .. ")")
end

--- Solar boilers (issue #446, scripts/fork-steam-boilers.lua): on a surface of their own with the time of day frozen, a
--- Simple Solar Boiler stops at midnight (status "No sunlight") and makes steam at noon, 1.2 per second times the boiler
--- output setting (issue #593)
local SB_WAIT = 150
--- issue #593: the boiler output setting of this load (1: GT New Horizons)
BOILER_FACTOR = settings.startup["gregtorio-continued-boiler-output"] and settings.startup["gregtorio-continued-boiler-output"].value
	or 1
function setup_solar_test(_)
	local ss = game.create_surface("devcheck-solar")
	ss.always_day = false
	ss.freeze_daytime = true
	ss.daytime = 0.5
	ss.request_to_generate_chunks({ 0, 0 }, 1)
	ss.force_generate_chunk_requests()
	local e = ss.create_entity{ name = "simple-solar-boiler", position = { 0, 0 }, force = "player", raise_built = true }
	if not e then return { "solar boiler test: could not place the Simple Solar Boiler" } end
	e.insert_fluid{ name = "water", amount = 100 }
	storage.solar = { e = e, surface = ss, phase = "night", at = game.tick }
	return {}
end

function solar_test()
	local st = storage.solar
	if not st or st.done then return end
	if game.tick < st.at + SB_WAIT then return end
	local problems = st.problems or {}
	st.problems = problems
	local e = st.e
	if not (e and e.valid) then
		problems[#problems + 1] = "the boiler is gone"
	elseif st.phase == "night" then
		local cs = e.custom_status
		if not e.disabled_by_script then problems[#problems + 1] = "it runs at midnight" end
		if not (cs and type(cs.label) == "table" and cs.label[1] == "entity-status.fork-no-sunlight") then
			problems[#problems + 1] = "no status 'No sunlight' at midnight"
		end
		st.night_steam = e.get_fluid_count("steam")
		st.surface.daytime = 0
		e.insert_fluid{ name = "water", amount = 100 }
		st.phase, st.at = "day", game.tick
		return
	else
		if e.disabled_by_script then problems[#problems + 1] = "it is stopped at noon" end
		st.day_steam = e.get_fluid_count("steam")
		if not (st.day_steam > (st.night_steam or 0)) then problems[#problems + 1] = "no steam at noon" end
		-- issue #593: one craft a second, its steam is 1.2 times the boiler output setting
		st.crafts = e.products_finished
		st.per_craft = st.crafts > 0 and (st.day_steam - (st.night_steam or 0)) / st.crafts or 0
		if math.abs(st.per_craft - 1.2 * BOILER_FACTOR) > 1e-3 then
			problems[#problems + 1] = string.format("%.4f steam per second by day, not %.4f (boiler output %g)", st.per_craft,
				1.2 * BOILER_FACTOR, BOILER_FACTOR)
		end
	end
	st.done = true
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL solar boiler test: " .. p) end
	log("DEVCHECK-RUNTIME-SOLAR " .. (#problems == 0 and "ok" or "failed") .. string.format(" (steam %.1f at midnight, %.1f at noon"
		.. " from %d crafts of 1 s: %.2f steam/s by day)", st.night_steam or 0, st.day_steam or 0, st.crafts or 0, st.per_craft or 0))
end

--- Coal boiler (issue #593, prototypes/fork-boiler-output.lua): a Small Coal Boiler with water and coal, on the solar test's
--- surface, makes 1.2 steam per second times the boiler output setting and burns 36 kW of coal times the setting, measured
--- over CB_TICKS after CB_WARM ticks (the fuel is the coal in its inventory and what still burns)
CB_WARM, CB_TICKS = 60, 300   -- (globals: the main chunk is near Lua's 200 locals)
function setup_coal_boiler_test(_)
	local ss = game.surfaces["devcheck-solar"]
	if not ss then return { "coal boiler test: no surface (the solar boiler test makes it)" } end
	local e = ss.create_entity{ name = "small-coal-boiler", position = { 10.5, 0.5 }, force = "player", raise_built = true }
	if not e then return { "coal boiler test: could not place the Small Coal Boiler" } end
	e.insert_fluid{ name = "water", amount = 150 }
	e.insert{ name = "coal", count = 10 }
	storage.coal_boiler = { e = e, at = game.tick }
	return {}
end

function coal_boiler_fuel(e)
	return e.get_item_count("coal") * prototypes.item["coal"].fuel_value + e.burner.remaining_burning_fuel
end

function coal_boiler_test()
	local st = storage.coal_boiler
	if not st or st.done then return end
	local e = st.e
	local problems = {}
	if not (e and e.valid) then
		problems[#problems + 1] = "the boiler is gone"
	elseif not st.t1 then
		if game.tick < st.at + CB_WARM then return end
		e.insert_fluid{ name = "water", amount = 150 }
		st.t1, st.s1, st.f1 = game.tick, e.get_fluid_count("steam"), coal_boiler_fuel(e)
		return
	else
		if game.tick < st.t1 + CB_TICKS then return end
		local secs = (game.tick - st.t1) / 60
		st.steam = (e.get_fluid_count("steam") - st.s1) / secs
		st.watts = (st.f1 - coal_boiler_fuel(e)) / secs
		st.coal = st.watts / prototypes.item["coal"].fuel_value
		local want_steam, want_watts = 1.2 * BOILER_FACTOR, 36e3 * BOILER_FACTOR
		if math.abs(st.steam - want_steam) > want_steam * 0.02 then
			problems[#problems + 1] = string.format("%.3f steam/s, not %.3f", st.steam, want_steam)
		end
		if math.abs(st.watts - want_watts) > want_watts * 0.05 then
			problems[#problems + 1] = string.format("burns %.0f W of coal, not %.0f", st.watts, want_watts)
		end
	end
	st.done = true
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL coal boiler test: " .. p) end
	log("DEVCHECK-RUNTIME-COALBOILER " .. (#problems == 0 and "ok" or "failed") .. string.format(" (boiler output %g: %.3f steam/s, "
		.. "%.4f coal/s = %.1f kW)", BOILER_FACTOR, st.steam or 0, st.coal or 0, (st.watts or 0) / 1e3))
end

--- The torch (issue #555, prototypes/100-fork-fixes.lua): on a surface of its own frozen at midnight, without any power,
--- a torch works (lit) while vanilla's electric lamp next to it does not; a character can stand on the torch's tile, not
--- on the lamp's
local TORCH_WAIT = 60
function setup_torch_test(_)
	local ts = game.create_surface("devcheck-torch")
	ts.always_day = false
	ts.freeze_daytime = true
	ts.daytime = 0.5
	ts.request_to_generate_chunks({ 0, 0 }, 1)
	ts.force_generate_chunk_requests()
	local tiles = {}
	for x = -3, 7 do for y = -3, 3 do tiles[#tiles + 1] = { name = "landfill", position = { x, y } } end end
	ts.set_tiles(tiles)
	for _, e in pairs(ts.find_entities{ { -3, -3 }, { 8, 4 } }) do e.destroy() end
	local t = ts.create_entity{ name = "gt-torch", position = { 0.5, 0.5 }, force = "player", raise_built = true }
	local l = ts.create_entity{ name = "small-lamp", position = { 4.5, 0.5 }, force = "player", raise_built = true }
	if not (t and l) then return { "torch test: could not place the torch and the lamp" } end
	storage.torch = { torch = t, lamp = l, surface = ts, at = game.tick }
	return {}
end

function torch_test()
	local st = storage.torch
	if not st or st.done or game.tick < st.at + TORCH_WAIT then return end
	local problems, t, l = {}, st.torch, st.lamp
	local name = function(s) for k, v in pairs(defines.entity_status) do if v == s then return k end end return tostring(s) end
	if not (t.valid and l.valid) then
		problems[#problems + 1] = "the torch or the lamp is gone"
	else
		if t.status ~= defines.entity_status.working then
			problems[#problems + 1] = "the torch is not lit at midnight without power (" .. name(t.status) .. ")"
		end
		if l.status == defines.entity_status.working then problems[#problems + 1] = "the electric lamp works without power" end
		if not st.surface.can_place_entity{ name = "character", position = t.position } then
			problems[#problems + 1] = "a character cannot stand on the torch's tile"
		end
		if st.surface.can_place_entity{ name = "character", position = l.position } then
			problems[#problems + 1] = "a character can stand on the lamp's tile (the walk test sees nothing)"
		end
	end
	st.done = true
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL torch test: " .. p) end
	log("DEVCHECK-RUNTIME-TORCH " .. (#problems == 0 and "ok" or "failed") .. " (torch " .. name(t.valid and t.status)
		.. ", electric lamp " .. name(l.valid and l.status) .. " at midnight without power)")
end

--- Battery buffers (issue #444, prototypes/145-fork-power-multiblocks.lua section 8): an LV Battery Buffer (1 battery)
--- holds 33.33 MJ, takes 1.28 MW and gives 640 kW; on a network with an LV Combustion Generator on a Bio Diesel Cell it
--- charges, and with the generator gone it feeds an LV compressor on air
local BB_X, BB_Y, BB_WAIT = 350, 350, 120

--- Mining drills (issue #499, prototypes/163-fork-electric-mine.lua): every drill stands on a 5 x 5 patch of its own ore
--- (the natural ores of its area removed first) with a chest at its output; at DR_TICK each chest holds its ore, the
--- Manual Mine burnt manual labor, the plants with Drilling Fluid drank some (scripts/fork-ore-drills.lua) and the Mk II
--- without any stopped after a few ores.
local DR_Y, DR_TICK, DR_FLUID, DR_PER_ORE = -300.5, 600, 1000, 200 / 64
local DR = { { "manual-mine", -330.5, "magnetite" }, { "lv-miner", -300.5, "chalcopyrite" }, { "mv-miner", -270.5, "coal" },
	{ "hv-miner", -240.5, "pyrite" }, { "ore-drilling-plant-mk1", -150.5, "lignite", true },
	{ "ore-drilling-plant-mk2", 0.5, "iron", false }, { "ore-drilling-plant-mk3", 150.5, "copper", true },
	{ "ore-drilling-plant-mk4", 300.5, "gold", true } }

function setup_drill_test(s)
	local fails, dt = {}, { drills = {} }
	storage.drill_test = dt
	local ok, err = pcall(function()
		for i, d in pairs(DR) do
			local x, r = d[2], prototypes.entity[d[1]].mining_drill_radius
			for _, e in pairs(s.find_entities_filtered{ type = "resource", area = { { x - r - 1, DR_Y - r - 1 }, { x + r + 1, DR_Y + r + 1 } } }) do
				e.destroy()
			end
			for dx = -2, 2 do
				for dy = -2, 2 do
					s.create_entity{ name = "gt-ore-" .. d[3], position = { x + dx, DR_Y + dy }, amount = 1000 }
				end
			end
			local e = s.create_entity{ name = d[1], position = { x, DR_Y }, force = "player", raise_built = true }
			local chest = s.create_entity{ name = "iron-chest", position = { x, DR_Y - 3 }, force = "player" }
			if d[1] == "manual-mine" then
				assert(e.get_fuel_inventory().insert{ name = "manual-labor", count = 50 } == 50, "the Manual Mine took no manual labor")
			else
				s.create_entity{ name = "substation", position = { x + 4, DR_Y + 4 }, force = "player" }
				s.create_entity{ name = "electric-energy-interface", position = { x + 7, DR_Y + 4 }, force = "player" }
			end
			if d[4] then
				local tank = s.find_entity("ore-drilling-plant-fluid-input", e.position)
				assert(tank and tank.insert_fluid{ name = "drilling-fluid", amount = DR_FLUID } > 0, d[1] .. " took no drilling fluid")
			end
			dt.drills[i] = { entity = e, chest = chest }
		end
	end)
	if not ok then fails[#fails + 1] = "mining drill test: " .. tostring(err) end
	return fails
end

function drill_test()
	local dt = storage.drill_test
	if not dt or dt.done or game.tick < DR_TICK then return end
	dt.done = true
	local problems, got = {}, {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	for i, d in pairs(DR) do
		local rec = dt.drills[i]
		local e = rec and rec.entity
		if not (e and e.valid and rec.chest.valid) then
			expect(false, d[1] .. ": the drill or its chest is gone")
		else
			local n = rec.chest.get_item_count("raw-" .. d[3])
			got[#got + 1] = d[1] .. " " .. n
			if d[4] == false then
				expect(e.disabled_by_script, d[1] .. " without Drilling Fluid still runs (status " .. tostring(e.status) .. ")")
				expect(n < 30, d[1] .. " without Drilling Fluid mined " .. n .. " raw " .. d[3])
			else
				expect(n > 0, d[1] .. " mined no raw " .. d[3] .. " (status " .. tostring(e.status) .. ")")
			end
			if d[4] then
				local tank = e.surface.find_entity("ore-drilling-plant-fluid-input", e.position)
				local left = tank and tank.get_fluid_count("drilling-fluid") or DR_FLUID
				local per_ore = (DR_FLUID - left) / math.max(n, 1)
				got[#got] = got[#got] .. string.format(" (%.2f fluid per ore)", per_ore)
				expect(math.abs(per_ore - DR_PER_ORE) <= DR_PER_ORE / 2, string.format("%s drank %.2f Drilling Fluid per ore, not %.3f",
					d[1], per_ore, DR_PER_ORE))
				--- one that stops has drunk its tank (the Mk IV drinks 1000 in 4 s)
				expect(not e.disabled_by_script or left < 50, d[1] .. " stopped with " .. left .. " Drilling Fluid")
			end
			if d[1] == "manual-mine" then
				expect(e.get_fuel_inventory().get_item_count("manual-labor") < 50, "the Manual Mine burnt no manual labor")
			end
		end
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL mining drill test: " .. p) end
	log("DEVCHECK-RUNTIME-DRILLS " .. (#problems == 0 and "ok" or "failed") .. " (" .. table.concat(got, ", ") .. " in "
		.. DR_TICK .. " ticks)")
end

--- Map veins (issue #497, prototypes/165-fork-ore-veins.lua): on a surface with Nauvis' map generation and a fixed seed
--- the cells' veins are read from the noise (calculate_tile_properties at the cell centres) to find a cell of every vein of
--- Nauvis, its largest; the chunks of those veins are generated; inside each vein every tile holds one ore at most, only
--- ores of its vein, and every ore of its layers is there; the four cells around the origin hold the start veins.
local VT_SEED, VT_CELLS, VT_TRIES = 4242, 40, 3

--- issue #501: one planet's veins: per vein its VT_TRIES largest cells (on Nauvis on land: ore is not placed on water;
--- on the Nether lava lakes may hold a vein), generated one after the other until one holds every ore of the vein;
--- returns the summary and, on Nauvis, the cell size and the start cells' veins
local function check_planet_veins(d, planet, vt)
	local info = d.planets[planet]
	local mgs = prototypes.space_location[planet].map_gen_settings
	mgs.seed = VT_SEED
	local s = game.create_surface("devcheck-veins-" .. planet, mgs)
	local size = s.calculate_tile_properties({ "gt_cell_size" }, { { 0, 0 } }).gt_cell_size[1]
	local pos = {}
	for cy = -VT_CELLS, VT_CELLS - 1 do
		for cx = -VT_CELLS, VT_CELLS - 1 do pos[#pos + 1] = { x = (cx + 0.5) * size, y = (cy + 0.5) * size } end
	end
	local p = s.calculate_tile_properties({ "gt_vein_id", "gt_vein_cx", "gt_vein_cy", "gt_vein_r" }, pos)
	local land = {}
	if planet == "nauvis" then
		--- its centre and four points at half its radius above sea level
		local probe = {}
		for i in ipairs(pos) do
			local x, y, q = p.gt_vein_cx[i], p.gt_vein_cy[i], p.gt_vein_r[i] / 2
			for _, o in pairs({ { 0, 0 }, { q, 0 }, { -q, 0 }, { 0, q }, { 0, -q } }) do probe[#probe + 1] = { x = x + o[1], y = y + o[2] } end
		end
		local elevation = s.calculate_tile_properties({ "elevation" }, probe).elevation
		for i in ipairs(pos) do
			land[i] = true
			for j = 5 * i - 4, 5 * i do if elevation[j] <= 0 then land[i] = false end end
		end
	end
	local cands, cells = {}, 0
	for i in ipairs(pos) do
		local id = math.floor(p.gt_vein_id[i] + 0.5)
		if id > 0 then cells = cells + 1 end
		if id > 0 and (planet ~= "nauvis" or land[i]) then
			cands[id] = cands[id] or {}
			table.insert(cands[id], { x = p.gt_vein_cx[i], y = p.gt_vein_cy[i], r = p.gt_vein_r[i] })
		end
	end
	local seen, tiles, dup = {}, 0, 0
	for _, id in pairs(info.veins) do
		local v, list = d.veins[tostring(id)], cands[id] or {}
		table.sort(list, function(a, b) return a.r > b.r end)
		local missing = "no cell of " .. #pos .. " holds it"
		for k = 1, math.min(VT_TRIES, #list) do
			local b = list[k]
			s.request_to_generate_chunks({ b.x, b.y }, math.ceil(b.r / 32) + 1)
			s.force_generate_chunk_requests()
			local allowed, found = {}, {}
			for _, r in pairs(v.resources) do allowed[r] = true end
			for _, e in pairs(s.find_entities_filtered{ type = "resource", position = { b.x, b.y }, radius = b.r }) do
				local key = e.position.x .. "," .. e.position.y
				if seen[key] then dup = dup + 1 end
				seen[key] = true
				tiles = tiles + 1
				if allowed[e.name] then
					found[e.name] = (found[e.name] or 0) + 1
				else
					vt.problems[#vt.problems + 1] = v.text .. ": " .. e.name .. " at " .. key .. " is not one of its ores"
				end
			end
			missing = nil
			for _, r in pairs(v.resources) do
				if not found[r] then
					missing = string.format("no %s in the vein at %.0f,%.0f (radius %.1f)", r, b.x, b.y, b.r)
				end
			end
			if not missing then break end
		end
		if missing then vt.problems[#vt.problems + 1] = planet .. ": " .. v.text .. ": " .. missing end
	end
	if dup > 0 then vt.problems[#vt.problems + 1] = planet .. ": " .. dup .. " tiles hold a second ore" end
	local got = {}
	if #info.start > 0 then
		--- the start cells: north-west, north-east, south-west, south-east of the origin
		local h = size / 2
		for _, v in pairs(s.calculate_tile_properties({ "gt_vein_id" }, { { -h, -h }, { h, -h }, { -h, h }, { h, h } }).gt_vein_id) do
			got[#got + 1] = math.floor(v + 0.5)
		end
		local want = {}
		for _, v in pairs(info.start) do want[#want + 1] = v end
		table.sort(got)
		table.sort(want)
		if table.concat(got, ",") ~= table.concat(want, ",") then
			vt.problems[#vt.problems + 1] = "the start cells hold the veins " .. table.concat(got, ",") .. ", not " .. table.concat(want, ",")
		end
	end
	game.delete_surface(s)
	return string.format("%d veins of %s, %d of %d cells with a vein, %d ore tiles%s", #info.veins, planet, cells, #pos,
		tiles, #got > 0 and (", start veins " .. table.concat(got, ",")) or ""), size
end

--- Issue #529: the veins' own controls. Two surfaces with Nauvis' map generation and the test's seed: the default one and
--- one with the Coal Vein off (size 0, as the map generator's checkbox) and the Iron Vein at size 2, both start veins.
--- The noise counts the cells of each vein in VC_CELLS x VC_CELLS cells around the origin, and the chunks of a fixed square
--- (VC_AREA tiles around the origin) are generated to count the ore tiles of each vein (its vein by gt_vein_id there):
--- the vein that is off has no cell and no tile, its start cell holds another vein or none, the other veins fill its
--- cells (the share of cells with a vein stays), the vein at size 2 has twice the mean radius, its start vein more ore
--- tiles at the same coverage (ore tiles per pi r^2 of its start cell: a magnified copy), and the cells keep room for it
--- (88 x 2 tiles).
local VC_CELLS, VC_AREA, VC_OFF, VC_BIG = 60, 192, "Coal", "Iron"
local function vein_counts(s, off_id, big_id)
	local size = s.calculate_tile_properties({ "gt_cell_size" }, { { 0, 0 } }).gt_cell_size[1]
	local pos = {}
	for cy = -VC_CELLS / 2, VC_CELLS / 2 - 1 do
		for cx = -VC_CELLS / 2, VC_CELLS / 2 - 1 do pos[#pos + 1] = { x = (cx + 0.5) * size, y = (cy + 0.5) * size } end
	end
	local p = s.calculate_tile_properties({ "gt_vein_id", "gt_vein_r" }, pos)
	local c = { size = size, with = 0, off = 0, big = 0, big_r = 0, tiles = 0, off_tiles = 0, big_tiles = 0 }
	for i in ipairs(pos) do
		local id = math.floor(p.gt_vein_id[i] + 0.5)
		if id > 0 then c.with = c.with + 1 end
		if id == off_id then c.off = c.off + 1 end
		if id == big_id then c.big = c.big + 1; c.big_r = c.big_r + p.gt_vein_r[i] end
	end
	c.big_r = c.big_r / math.max(c.big, 1)
	s.request_to_generate_chunks({ 0, 0 }, math.ceil(VC_AREA / 32))
	s.force_generate_chunk_requests()
	local ores = s.find_entities_filtered{ type = "resource", area = { { -VC_AREA, -VC_AREA }, { VC_AREA, VC_AREA } } }
	local at = {}
	for i, e in ipairs(ores) do at[i] = e.position end
	local ids = #at > 0 and s.calculate_tile_properties({ "gt_vein_id" }, at).gt_vein_id or {}
	for i in ipairs(at) do
		local id = math.floor(ids[i] + 0.5)
		c.tiles = c.tiles + 1
		if id == off_id then c.off_tiles = c.off_tiles + 1 end
		--- the big vein's start vein: its tiles in the four start cells
		if id == big_id and math.abs(at[i].x) < size and math.abs(at[i].y) < size then c.big_tiles = c.big_tiles + 1 end
	end
	local h = size / 2
	local q = s.calculate_tile_properties({ "gt_vein_id", "gt_vein_r" }, { { -h, -h }, { h, -h }, { -h, h }, { h, h } })
	c.start, c.big_start_r = {}, 0
	for i, v in pairs(q.gt_vein_id) do
		c.start[#c.start + 1] = math.floor(v + 0.5)
		if c.start[#c.start] == big_id then c.big_start_r = q.gt_vein_r[i] end
	end
	c.cover = c.big_tiles / math.max(math.pi * c.big_start_r * c.big_start_r, 1)
	return c
end

local function check_vein_controls(d, vt)
	local off_id, big_id
	for id, v in pairs(d.veins) do
		if v.control == "gt-vein-" .. VC_OFF then off_id = tonumber(id) end
		if v.control == "gt-vein-" .. VC_BIG then big_id = tonumber(id) end
	end
	if not (off_id and big_id) then
		vt.problems[#vt.problems + 1] = "controls: no vein with the control gt-vein-" .. VC_OFF .. " or gt-vein-" .. VC_BIG
		return ""
	end
	local function surface(name, controls)
		local mgs = prototypes.space_location.nauvis.map_gen_settings
		mgs.seed = VT_SEED
		for k, v in pairs(controls) do mgs.autoplace_controls[k] = v end
		return game.create_surface(name, mgs)
	end
	local sd = surface("devcheck-controls-default", {})
	local sm = surface("devcheck-controls-set", { ["gt-vein-" .. VC_OFF] = { frequency = 1, size = 0, richness = 1 },
		["gt-vein-" .. VC_BIG] = { frequency = 1, size = 2, richness = 1 } })
	local a, b = vein_counts(sd, off_id, big_id), vein_counts(sm, off_id, big_id)
	game.delete_surface(sd)
	game.delete_surface(sm)
	local n = VC_CELLS * VC_CELLS
	local function expect(ok, what) if not ok then vt.problems[#vt.problems + 1] = "controls: " .. what end end
	expect(a.off > 0 and a.off_tiles > 0, VC_OFF .. " has no cell or tile on the default map")
	expect(b.off == 0 and b.off_tiles == 0, string.format("%s is off but has %d cells and %d ore tiles", VC_OFF, b.off, b.off_tiles))
	expect(math.abs(b.with / n - a.with / n) < 0.03, string.format("%d of %d cells with a vein, %d on the default map: the other "
		.. "veins do not fill the cells of %s", b.with, n, a.with, VC_OFF))
	local ratio = b.big_r / math.max(a.big_r, 1)
	expect(ratio > 1.7 and ratio < 2.3, string.format("%s at size 2 has %.2f times the mean radius", VC_BIG, ratio))
	expect(b.big_tiles > a.big_tiles and b.cover / math.max(a.cover, 1e-6) > 0.75 and b.cover / math.max(a.cover, 1e-6) < 1.33,
		string.format("%s at size 2: its start vein (radius %.1f) has %d ore tiles, %.2f per tile of its area; on the default map "
		.. "(radius %.1f) %d, %.2f", VC_BIG, b.big_start_r, b.big_tiles, b.cover, a.big_start_r, a.big_tiles, a.cover))
	expect(math.abs(a.size - 128) < 1e-6 and math.abs(b.size - 176) < 1e-6, string.format("cells of %.0f and %.0f tiles, not 128 "
		.. "and 176", a.size, b.size))
	local start_big, start_off = false, false
	for _, id in pairs(b.start) do
		if id == big_id then start_big = true end
		if id == off_id then start_off = true end
	end
	expect(start_big and not start_off, "the start cells hold " .. table.concat(b.start, ",") .. " with " .. VC_OFF .. " off and "
		.. VC_BIG .. " at size 2")
	return string.format("; controls: %s off: %d of %d cells (default %d), %d ore tiles in %d x %d tiles (default %d), the start "
		.. "cells hold veins %s; %s at size 2: %.2f times the mean radius, its start vein radius %.1f with %d ore tiles, %.2f per "
		.. "tile of its area (default radius %.1f, %d, %.2f); cells of %.0f tiles, %d with a vein (default %d)", VC_OFF, b.off, n, a.off,
		b.off_tiles, 2 * VC_AREA, 2 * VC_AREA, a.off_tiles, table.concat(b.start, ","), VC_BIG, ratio, b.big_start_r, b.big_tiles,
		b.cover, a.big_start_r, a.big_tiles, a.cover, b.size, b.with, a.with)
end

--- issue #563: the startup setting gregtorio-continued-ore-mode; classic mode (vein-recipes) has no map veins
local CLASSIC = settings.startup["gregtorio-continued-ore-mode"].value == "vein-recipes"
function gt_ore_names()
	local names = {}
	for name, e in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "resource" } }) do
		if e.resource_category == "gt-ore" then names[#names + 1] = name end
	end
	return names
end

function setup_veins_test()
	local fails, vt = {}, { problems = {} }
	storage.veins_test = vt
	if CLASSIC then
		--- (veins_test checks that no planet's surface has vein ore; Nauvis now, before the drill test places its patches)
		vt.nauvis = game.surfaces.nauvis.count_entities_filtered{ type = "resource", name = gt_ore_names() }
		return fails
	end
	local ok, err = pcall(function()
		local d = prototypes.mod_data["fork-ore-veins"].data
		local parts, size = {}, nil
		for _, planet in pairs({ "nauvis", "gt-nether", "gt-twilight", "gt-end" }) do
			if d.planets[planet] then
				local text, sz = check_planet_veins(d, planet, vt)
				parts[#parts + 1] = text
				if planet == "nauvis" then size = sz end
			end
		end
		vt.summary = " (" .. table.concat(parts, "; ") .. check_vein_controls(d, vt) .. ")"
		local h = size / 2
		--- the chart tag (scripts/fork-ore-veins.lua): chart the start veins of Nauvis, the tags are checked at VT_TAG_TICK
		local n = game.surfaces.nauvis
		local q = n.calculate_tile_properties({ "gt_vein_id", "gt_vein_cx", "gt_vein_cy" }, { { -h, -h }, { h, -h }, { -h, h }, { h, h } })
		vt.tags = {}
		for i = 1, 4 do
			local id, x, y = math.floor(q.gt_vein_id[i] + 0.5), q.gt_vein_cx[i], q.gt_vein_cy[i]
			vt.tags[#vt.tags + 1] = { text = d.veins[tostring(id)].text, x = x, y = y }
			game.forces.player.chart(n, { { x - 1, y - 1 }, { x + 1, y + 1 } })
		end
	end)
	if not ok then vt.problems[#vt.problems + 1] = tostring(err) end
	return fails
end
local VT_TAG_TICK = 300

function veins_test()
	local vt = storage.veins_test
	if not vt or vt.done or game.tick < VT_TAG_TICK then return end
	vt.done = true
	if CLASSIC then
		--- issue #563: no surface has an ore of the map veins (Nauvis' test area, the Nether, Twilight Forest and End of the
		--- portal test), and their map settings name no vein
		local parts = {}
		for _, surface in pairs(game.surfaces) do
			if surface.planet then
				local n = surface.name == "nauvis" and vt.nauvis
					or surface.count_entities_filtered{ type = "resource", name = gt_ore_names() }
				local mgs = surface.map_gen_settings
				parts[#parts + 1] = surface.name .. " " .. n
				if n > 0 then vt.problems[#vt.problems + 1] = n .. " vein ores on " .. surface.name .. " in classic mode" end
				if (mgs.property_expression_names or {}).gt_vein_id or (mgs.autoplace_controls or {})["gt-ore-veins"] then
					vt.problems[#vt.problems + 1] = surface.name .. "'s map settings name the veins in classic mode"
				end
			end
		end
		vt.summary = " (classic ore mode: vein ores " .. table.concat(parts, ", ") .. ")"
	end
	local n, tagged = game.surfaces.nauvis, 0
	--- headless runs raise no on_chunk_charted: the remote call tags the chunk as the event would, twice (one tag only)
	for _, t in pairs(vt.tags or {}) do
		for _ = 1, 2 do
			remote.call("fork-ore-veins", "tag_chunk", "player", "nauvis", { x = math.floor(t.x / 32), y = math.floor(t.y / 32) })
		end
	end
	for _, t in pairs(vt.tags or {}) do
		local found = game.forces.player.find_chart_tags(n, { { t.x - 1, t.y - 1 }, { t.x + 1, t.y + 1 } })   -- (none in classic mode)
		if #found == 1 and found[1].text == t.text then
			tagged = tagged + 1
		else
			vt.problems[#vt.problems + 1] = string.format("no single chart tag \"%s\" at %.0f,%.0f (%d tags)", t.text, t.x, t.y, #found)
		end
	end
	vt.summary = (vt.summary or "") .. ", " .. tagged .. " start veins tagged on the map"
	for _, p in pairs(vt.problems) do log("DEVCHECK-RUNTIME-FAIL map vein test: " .. p) end
	log("DEVCHECK-RUNTIME-VEINS " .. (#vt.problems == 0 and "ok" or "failed") .. (vt.summary or ""))
end

--- Classic vein recipes (issue #563, prototypes/166-fork-classic-veins.lua): in classic mode a Dimension Mine (called
--- Manual Mine there) on plain ground, without any ore under it, runs Nauvis' iron vein recipe with an iron pickaxe use and
--- manual labor: after CV_TICK its output holds the recipe's results of two operations; the recipe and its twins are not
--- hidden. In map-vein mode the recipe is hidden (the test only says so).
local CV_X, CV_Y, CV_TICK, CV_RECIPE = -360.5, -180.5, 1300, "mining-iron-vein"

function setup_classic_test(s)
	local fails, ct = {}, {}
	storage.classic_test = ct
	if not CLASSIC then return fails end
	local ok, err = pcall(function()
		for _, e in pairs(s.find_entities_filtered{ area = { { CV_X - 4, CV_Y - 4 }, { CV_X + 4, CV_Y + 4 } } }) do
			if e.valid and e.type ~= "character" then e.destroy() end
		end
		game.forces.player.recipes[CV_RECIPE].enabled = true
		local mine = s.create_entity{ name = "dimension-mine", position = { CV_X, CV_Y }, force = "player", raise_built = true }
		mine.set_recipe(CV_RECIPE)
		local labor = 0
		for _, i in pairs(prototypes.recipe[CV_RECIPE].ingredients) do
			if i.name == "manual-labor" then labor = i.amount end
		end
		local input = mine.get_inventory(defines.inventory.crafter_input)
		assert(input.insert{ name = "iron-pickaxe-usage", count = 2 } == 2, "the mine took no pickaxe")
		assert(input.insert{ name = "manual-labor", count = 2 * labor } == 2 * labor, "the mine took no manual labor")
		ct.mine = mine
		ct.ores = s.count_entities_filtered{ type = "resource", area = { { CV_X - 3, CV_Y - 3 }, { CV_X + 3, CV_Y + 3 } } }
	end)
	if not ok then fails[#fails + 1] = "classic vein test: " .. tostring(err) end
	return fails
end

function classic_test()
	local ct = storage.classic_test
	if not ct or ct.done then return end
	if not CLASSIC then
		ct.done = true
		local r = prototypes.recipe[CV_RECIPE]
		local hidden = r and r.hidden
		if not hidden then log("DEVCHECK-RUNTIME-FAIL classic vein test: " .. CV_RECIPE .. " is not hidden in map-vein mode") end
		log("DEVCHECK-RUNTIME-CLASSIC " .. (hidden and "ok" or "failed") .. " (map-vein mode: " .. CV_RECIPE .. " hidden)")
		return
	end
	if game.tick < CV_TICK then return end
	ct.done = true
	local problems, got = {}, {}
	local function expect(c, what) if not c then problems[#problems + 1] = what end end
	local mine = ct.mine
	expect(mine and mine.valid, "the Dimension Mine is gone")
	expect(ct.ores == 0, ct.ores .. " ore tiles under the mine")
	if mine and mine.valid then
		local out = mine.get_inventory(defines.inventory.crafter_output)
		for _, r in pairs(prototypes.recipe[CV_RECIPE].products) do
			local n = out.get_item_count(r.name)
			got[#got + 1] = n .. " " .. r.name
			expect(n == 2 * r.amount, string.format("%d %s in the output, not %d (status %s)", n, r.name, 2 * r.amount,
				tostring(mine.status)))
		end
	end
	for _, n in pairs({ CV_RECIPE, "drilling-iron-vein", "miner-iron-vein", "mining-iron-vein-with-stone-pickaxe" }) do
		expect(prototypes.recipe[n] and not prototypes.recipe[n].hidden, n .. " is hidden in classic mode")
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL classic vein test: " .. p) end
	log("DEVCHECK-RUNTIME-CLASSIC " .. (#problems == 0 and "ok" or "failed") .. " (a Dimension Mine on plain ground ran "
		.. CV_RECIPE .. " twice: " .. table.concat(got, ", ") .. ")")
end

--- Nether Portal (issue #501, scripts/fork-portals.lua): a character next to a portal on Nauvis goes through it (the
--- remote does what stepping onto it does for a player) and arrives on gt-nether next to a new portal at an eighth of the
--- position; the Nether has gt-dimension 2, no water and lava, no biters; the way back leads to the first portal, not a
--- new one. Issue #502: the Twilight Portal the same way at 1:1 to gt-twilight (gt-dimension 3, the daytime frozen at
--- dusk, a dense forest without biters). Issue #503: the End Portal to gt-end (gt-dimension 4, frozen night): the exit
--- portal at the origin on end stone, the void 600 tiles out, no water, trees or biters; the way back to the first portal.
local PT_X, PT_Y = 200.5, 300.5
local TT_X, TT_Y = -300, 200
local ET_X, ET_Y = 400.5, -300.5

function setup_portal_test(s)
	local fails, pt = {}, {}
	storage.portal_test = pt
	local ok, err = pcall(function()
		local portal = s.create_entity{ name = "nether-portal", position = { PT_X, PT_Y }, force = "player", raise_built = true }
		local c = s.create_entity{ name = "character", position = { PT_X, PT_Y + 3 }, force = "player" }
		c.insert{ name = "iron-plate", count = 7 }
		local out = remote.call("fork-portals", "travel", c, portal)
		local problems = {}
		local function expect(ok2, what) if not ok2 then problems[#problems + 1] = what end end
		expect(out and out.valid and out.surface.name == "gt-nether", "no portal on the other side")
		expect(c.valid and c.surface.name == "gt-nether", "the character is not in the Nether")
		if out and out.valid then
			expect(math.abs(out.position.x - PT_X / 8) < 40 and math.abs(out.position.y - PT_Y / 8) < 40,
				string.format("the Nether's portal is at %.1f,%.1f, not near %.1f,%.1f", out.position.x, out.position.y, PT_X / 8, PT_Y / 8))
			local n = out.surface
			expect(n.get_property("gt-dimension") == 2, "the Nether's gt-dimension is " .. tostring(n.get_property("gt-dimension")))
			n.request_to_generate_chunks({ 0, 0 }, 6)
			n.force_generate_chunk_requests()
			local area = { { -192, -192 }, { 192, 192 } }
			pt.water = n.count_tiles_filtered{ area = area, name = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" } }   -- (lava has the water_tile layer too)
			pt.lava = n.count_tiles_filtered{ area = area, name = { "lava", "lava-hot" } }
			expect(pt.water == 0, pt.water .. " water tiles in the Nether")
			expect(pt.lava > 0, "no lava in the Nether")
			local spawners = n.count_entities_filtered{ area = area, type = { "unit-spawner", "turret" } }
			expect(spawners == 0, spawners .. " biter nests or worms in the Nether")
		end
		expect(c.valid and c.get_item_count("iron-plate") == 7, "the character's inventory did not come along")
		local back = remote.call("fork-portals", "travel", c, out)
		expect(back == portal, "the way back leads to " .. tostring(back and back.position.x) .. "," .. tostring(back and back.position.y)
			.. ", not to the first portal")
		expect(c.valid and c.surface.name == "nauvis", "the character did not come back to Nauvis")
		expect(s.get_property("gt-dimension") == 1, "Nauvis' gt-dimension is " .. tostring(s.get_property("gt-dimension")))
		--- issue #502: the Twilight Portal
		local tp = s.create_entity{ name = "twilight-portal", position = { TT_X, TT_Y }, force = "player", raise_built = true }
		local tout = remote.call("fork-portals", "travel", c, tp)
		expect(tout and tout.valid and tout.surface.name == "gt-twilight", "no Twilight Portal on the other side")
		expect(c.valid and c.surface.name == "gt-twilight", "the character is not in the Twilight Forest")
		if tout and tout.valid then
			local t = tout.surface
			expect(math.abs(tout.position.x - TT_X) < 40 and math.abs(tout.position.y - TT_Y) < 40,
				string.format("the Twilight Forest's portal is at %.1f,%.1f, not near %d,%d", tout.position.x, tout.position.y, TT_X, TT_Y))
			expect(t.get_property("gt-dimension") == 3, "the Twilight Forest's gt-dimension is " .. tostring(t.get_property("gt-dimension")))
			expect(t.freeze_daytime and math.abs(t.daytime - 0.35) < 0.01,
				string.format("the Twilight Forest's daytime is %.2f (frozen: %s), not dusk", t.daytime, tostring(t.freeze_daytime)))
			t.request_to_generate_chunks({ 0, 0 }, 6)
			t.force_generate_chunk_requests()
			local area = { { -192, -192 }, { 192, 192 } }
			pt.trees = t.count_entities_filtered{ area = area, type = "tree" }
			pt.home_trees = s.count_entities_filtered{ area = area, type = "tree" }
			local spawners = t.count_entities_filtered{ area = area, type = { "unit-spawner", "turret" } }
			expect(spawners == 0, spawners .. " biter nests or worms in the Twilight Forest")
			expect(pt.trees > 384 * 384 / 25, pt.trees .. " trees around the Twilight Forest's origin: no dense forest")
		end
		local tback = remote.call("fork-portals", "travel", c, tout)
		expect(tback == tp, "the way back from the Twilight Forest leads to " .. tostring(tback and tback.position.x) .. ","
			.. tostring(tback and tback.position.y) .. ", not to the first portal")
		expect(c.valid and c.surface.name == "nauvis", "the character did not come back from the Twilight Forest")
		--- issue #503: the End Portal
		local ep = s.create_entity{ name = "end-portal", position = { ET_X, ET_Y }, force = "player", raise_built = true }
		local eout = remote.call("fork-portals", "travel", c, ep)
		expect(eout and eout.valid and eout.surface.name == "gt-end", "no End Portal on the other side")
		expect(c.valid and c.surface.name == "gt-end", "the character is not in The End")
		if eout and eout.valid then
			local e = eout.surface
			expect(math.abs(eout.position.x) < 40 and math.abs(eout.position.y) < 40,
				string.format("The End's portal is at %.1f,%.1f, not near the origin", eout.position.x, eout.position.y))
			expect(e.get_property("gt-dimension") == 4, "The End's gt-dimension is " .. tostring(e.get_property("gt-dimension")))
			expect(e.freeze_daytime, "The End's daytime is not frozen")
			expect(e.get_tile(eout.position.x, eout.position.y).name == "gt-end-stone",
				"The End's portal stands on " .. e.get_tile(eout.position.x, eout.position.y).name)
			e.request_to_generate_chunks({ 0, 0 }, 6)
			e.request_to_generate_chunks({ 600, 0 }, 1)
			e.force_generate_chunk_requests()
			local area = { { -192, -192 }, { 192, 192 } }
			pt.end_stone = e.count_tiles_filtered{ area = area, name = "gt-end-stone" }
			pt.end_void = e.count_tiles_filtered{ area = { { 584, -16 }, { 616, 16 } }, name = "gt-end-void" }
			expect(pt.end_stone > 384 * 384 * 0.9, pt.end_stone .. " end stone tiles around The End's origin")
			expect(pt.end_void == 32 * 32, pt.end_void .. " void tiles of 1024 at 600,0 (the main island reaches out there)")
			local other = e.count_entities_filtered{ area = area, type = { "tree", "unit-spawner", "turret", "fish" } }
			expect(other == 0, other .. " trees, nests or fish in The End")
		end
		local eback = remote.call("fork-portals", "travel", c, eout)
		expect(eback == ep, "the way back from The End leads to " .. tostring(eback and eback.position.x) .. ","
			.. tostring(eback and eback.position.y) .. ", not to the first portal")
		expect(c.valid and c.surface.name == "nauvis", "the character did not come back from The End")
		pt.problems = problems
	end)
	if not ok then fails[#fails + 1] = "portal test: " .. tostring(err) end
	return fails
end

function portal_test()
	local pt = storage.portal_test
	if not pt or pt.done then return end
	pt.done = true
	local problems = pt.problems or { "it did not run" }
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL portal test: " .. p) end
	log("DEVCHECK-RUNTIME-PORTAL " .. (#problems == 0 and "ok" or "failed") .. string.format(" (through to the Nether and back; "
		.. "%s water and %s lava tiles around the Nether's origin; to the Twilight Forest and back, %s trees around its origin, "
		.. "%s around Nauvis'; to The End and back, %s end stone tiles around its origin, %s void tiles at 600,0)",
		tostring(pt.water), tostring(pt.lava), tostring(pt.trees), tostring(pt.home_trees), tostring(pt.end_stone),
		tostring(pt.end_void)))
end

--- Ender Storage (issue #504, scripts/fork-ender.lua): an Ender Chest on Nauvis and one in the Nether with the same code
--- share their slots, a third with another code does not; an Ender Tank of water on Nauvis and an empty one in the
--- Nether with the same code hold half each after the levelling, a third with another code stays empty; a chest and a
--- tank built from a blueprint get the codes of its tags (issue #546). Issue #545: the drop-downs list the colours
--- alphabetically and map back to the same code; a chest of an old save with link_id 3803 shows red, green, blue and
--- shares with a chest set to red, green, blue through the drop-downs.
local EN_WAIT = 61   -- three levelling intervals

function setup_ender_test(s)
	local fails, et = {}, {}
	storage.ender_test = et
	local ok, err = pcall(function()
		local planet = game.planets["gt-nether"]
		local n = planet.surface or planet.create_surface()
		n.request_to_generate_chunks({ 0, 0 }, 2)
		n.force_generate_chunk_requests()
		local function place(surface, name, at)
			local pos = surface == s and at or surface.find_non_colliding_position(name, at, 64, 1)
			return surface.create_entity{ name = name, position = pos, force = "player", raise_built = true }
		end
		local a, b, c = place(s, "ender-chest", { -200.5, -250.5 }), place(n, "ender-chest", { 10, 10 }),
			place(n, "ender-chest", { 20, 10 })
		local t1, t2, t3 = place(s, "ender-tank", { -195.5, -250.5 }), place(n, "ender-tank", { 10, 20 }),
			place(s, "ender-tank", { -190.5, -250.5 })
		for e, code in pairs({ [a] = 1234, [b] = 1234, [c] = 0, [t1] = 777, [t2] = 777, [t3] = 778 }) do
			remote.call("fork-ender", "set_code", e, code)
		end
		-- issue #545: a chest of an old save (red, green, blue: link_id 3803) and one set through the drop-downs
		local old, new = place(s, "ender-chest", { -200.5, -245.5 }), place(n, "ender-chest", { 30, 10 })
		old.link_id = 3803
		et.old_shown = remote.call("fork-ender", "shown_of", remote.call("fork-ender", "get_code", old))
		remote.call("fork-ender", "set_code", new, remote.call("fork-ender", "code_of", et.old_shown))
		old.insert{ name = "copper-plate", count = 3 }
		a.insert{ name = "iron-plate", count = 7 }
		t1.insert_fluid{ name = "water", amount = 1000 }
		et.chests, et.tanks, et.tick = { a, b, c, old, new }, { t1, t2, t3 }, game.tick
		et.code = remote.call("fork-ender", "get_code", b)
		--- issue #546: a blueprint keeps the codes as entity tag; built by script with the chest's link_id taken out (a
		--- ghost a player places has lost it), the chest and the tank get their codes from the tag; a blueprint without
		--- the tag (made before) still gives the chest its link_id
		local d, t4 = place(s, "ender-chest", { -200.5, -255.5 }), place(s, "ender-tank", { -195.5, -255.5 })
		remote.call("fork-ender", "set_code", d, 2345)
		remote.call("fork-ender", "set_code", t4, 999)
		local inv = game.create_inventory(2)
		inv.insert{ name = "blueprint", count = 2 }
		local tagged, old = inv[1], inv[2]
		local area = { { -202, -258 }, { -193, -253 } }
		remote.call("fork-ender", "tag_blueprint", tagged,
			tagged.create_blueprint{ surface = s, force = "player", area = area })
		old.create_blueprint{ surface = s, force = "player", area = area }
		local ents, bp = tagged.get_blueprint_entities() or {}, { tag = {}, ghosts = 0 }
		for _, be in pairs(ents) do
			bp.tag[be.name] = be.tags and be.tags.fork_ender_code
			if be.name == "ender-chest" then be.link_id = 0 end
		end
		tagged.set_blueprint_entities(ents)
		for key, y in pairs({ tagged = -263, old = -269 }) do
			local ghosts = (key == "tagged" and tagged or old).build_blueprint{ surface = s, force = "player",
				position = { -197, y }, build_mode = defines.build_mode.forced }
			for _, g in pairs(ghosts) do
				bp.ghosts = bp.ghosts + 1
				local _, e = g.revive{ raise_revive = true }
				if e then bp[key .. "-" .. e.name] = remote.call("fork-ender", "get_code", e) end
			end
		end
		inv.destroy()
		et.bp = bp
	end)
	if not ok then fails[#fails + 1] = "ender storage test: " .. tostring(err) end
	return fails
end

function ender_test()
	local et = storage.ender_test
	if not et or et.done or not et.tick or game.tick < et.tick + EN_WAIT then return end
	et.done = true
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local a, b, c = et.chests[1], et.chests[2], et.chests[3]
	expect(b.surface.name == "gt-nether", "the second Ender Chest is on " .. b.surface.name)
	expect(et.code == 1234, "the Nether's chest has the code " .. tostring(et.code))
	expect(b.get_item_count("iron-plate") == 7, "the Nether's Ender Chest holds " .. b.get_item_count("iron-plate")
		.. " iron plates of Nauvis' 7")
	expect(c.get_item_count("iron-plate") == 0, "the Ender Chest of another code holds iron plates")
	local function amount(t) return t.get_fluid_count("water") end
	local w1, w2, w3 = amount(et.tanks[1]), amount(et.tanks[2]), amount(et.tanks[3])
	expect(math.abs(w1 - 500) < 1e-3 and math.abs(w2 - 500) < 1e-3,
		string.format("the Ender Tanks of one code hold %.1f (Nauvis) and %.1f (Nether), not 500 each", w1, w2))
	expect(w3 == 0, "the Ender Tank of another code holds " .. w3 .. " water")
	-- the drop-downs (issue #545): alphabetical, every code survives a round trip, an old chest shows its colours
	local names = remote.call("fork-ender", "shown_colours")
	local seen = {}
	for i, name in ipairs(names) do
		seen[name] = true
		if i > 1 then expect(names[i - 1] < name, "the drop-down lists " .. names[i - 1] .. " before " .. name) end
	end
	expect(#names == 16 and table_size(seen) == 16, "the drop-down has " .. #names .. " items, " .. table_size(seen)
		.. " different")
	local trips = 0
	for code = 0, 4095 do
		if remote.call("fork-ender", "code_of", remote.call("fork-ender", "shown_of", code)) == code then
			trips = trips + 1
		end
	end
	expect(trips == 4096, (4096 - trips) .. " codes change on the way through the drop-downs")
	local shown = et.old_shown
	local function name(i) return names[i] or tostring(i) end
	expect(name(shown[1]) == "red" and name(shown[2]) == "green" and name(shown[3]) == "blue",
		"the chest with link_id 3803 shows " .. name(shown[1]) .. ", " .. name(shown[2]) .. ", " .. name(shown[3])
		.. ", not red, green, blue")
	local new = et.chests[5]
	expect(new.link_id == 3803, "the chest set to red, green, blue through the drop-downs has link_id " .. new.link_id)
	expect(new.get_item_count("copper-plate") == 3, "the new red, green, blue chest holds "
		.. new.get_item_count("copper-plate") .. " of the old one's 3 copper plates")
	local bp = et.bp or { tag = {}, ghosts = 0 }
	expect(bp.tag["ender-chest"] == 2345 and bp.tag["ender-tank"] == 999, string.format("the blueprint's tags are %s "
		.. "(chest) and %s (tank), not 2345 and 999", tostring(bp.tag["ender-chest"]), tostring(bp.tag["ender-tank"])))
	expect(bp.ghosts == 4, bp.ghosts .. " ghosts of the two blueprints, not 4")
	expect(bp["tagged-ender-chest"] == 2345, "the chest built from the tagged blueprint without link_id has the code "
		.. tostring(bp["tagged-ender-chest"]) .. ", not 2345")
	expect(bp["tagged-ender-tank"] == 999, "the tank built from the tagged blueprint has the code "
		.. tostring(bp["tagged-ender-tank"]) .. ", not 999")
	expect(bp["old-ender-chest"] == 2345, "the chest built from a blueprint without the tag has the code "
		.. tostring(bp["old-ender-chest"]) .. ", not its link_id 2345")
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL ender storage test: " .. p) end
	log("DEVCHECK-RUNTIME-ENDER " .. (#problems == 0 and "ok" or "failed") .. string.format(" (7 iron plates through the "
		.. "Ender Chests to the Nether, %d there; water levelled %.0f / %.0f between Nauvis and the Nether; drop-downs "
		.. "alphabetical, %d of 4096 codes round-trip, link_id 3803 shows %s, %s, %s; from a blueprint the codes %s "
		.. "(chest by tag), %s (tank by tag), %s (chest of an old blueprint by link_id))",
		b.get_item_count("iron-plate"), w1, w2, trips, name(shown[1]), name(shown[2]), name(shown[3]),
		tostring(bp["tagged-ender-chest"]), tostring(bp["tagged-ender-tank"]), tostring(bp["old-ender-chest"])))
end

function setup_battery_test(s)
	local fails, bb = {}, {}
	storage.battery = bb
	local ok, err = pcall(function()
		bb.buffer = s.create_entity{ name = "lv-battery-buffer-1", position = { BB_X, BB_Y }, force = "player", raise_built = true }
		bb.gen = s.create_entity{ name = "lv-combustion-generator", position = { BB_X + 4, BB_Y }, force = "player", raise_built = true }
		bb.gen.insert{ name = "bio-diesel-cell", count = 5 }
		s.create_entity{ name = "substation", position = { BB_X + 2, BB_Y + 3 }, force = "player" }
		bb.load = s.create_entity{ name = "lv-compressor", position = { BB_X - 4, BB_Y + 4 }, force = "player" }
		for name, r in pairs(prototypes.recipe) do
			if r.categories[1] == "lv-compressor-recipes" and #r.ingredients == 0 then bb.load.set_recipe(name) break end
		end
		bb.load.disabled_by_script = true
		bb.phase, bb.at = "charge", game.tick
	end)
	if not ok then fails[#fails + 1] = "battery buffer test: " .. tostring(err) end
	return fails
end

function battery_test()
	local bb = storage.battery
	if not bb or bb.done or not bb.buffer then return end
	if game.tick < bb.at + BB_WAIT then return end
	local problems = bb.problems or {}
	bb.problems = problems
	local e = bb.buffer
	if not e.valid then
		problems[#problems + 1] = "the buffer is gone"
	elseif bb.phase == "charge" then
		if math.abs(e.electric_buffer_size - 100000 / 3 * 1000) > 1 then
			problems[#problems + 1] = "capacity " .. e.electric_buffer_size .. " J, not 33.33 MJ"
		end
		bb.charged = e.energy
		if not (bb.charged > 0) then problems[#problems + 1] = "it did not charge" end
		--- at most 1.28 MW in (2 amps), the generator gives 640 kW
		if bb.charged > 1.28e6 * BB_WAIT / 60 * 1.01 then problems[#problems + 1] = "it charged faster than 1.28 MW" end
		if bb.gen.valid then bb.gen.destroy() end
		bb.load.disabled_by_script = false
		bb.phase, bb.at = "discharge", game.tick
		return
	else
		bb.left = e.energy
		if not (bb.left < bb.charged) then problems[#problems + 1] = "it did not feed the compressor" end
		--- at most 640 kW out (1 amp)
		if bb.charged - bb.left > 6.4e5 * BB_WAIT / 60 * 1.01 then problems[#problems + 1] = "it gave more than 640 kW" end
	end
	bb.done = true
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL battery buffer test: " .. p) end
	log("DEVCHECK-RUNTIME-BATTERY " .. (#problems == 0 and "ok" or "failed") .. string.format(" (%.2f MJ charged in %d ticks, %.2f MJ left after feeding the compressor)",
		(bb.charged or 0) / 1e6, BB_WAIT, (bb.left or 0) / 1e6))
end

--- Molds and lenses (prototypes/150-fork-molds.lua, issue #316): a machine with a recipe that needs one stops without it
--- (status: the missing mold or lens), runs with it in its module slot and keeps it there (nothing in the output)
local MOLD_Y = 120
local MOLD_DEADLINE = 900                               -- ticks for the first product with the tool in (361 needed)
local TOOL_TESTS = {
	{ key = "MOLD", x = 6, machine = "lv-alloy-smelter", recipe = "glass-alloy-smelter", input = { "glass-dust", 20 },
		tool = "mold", product = "glass", status = "entity-status.fork-missing-mold" },
	{ key = "LENS", x = 20, machine = "ev-laser-engraver", recipe = "engraving-chipped-ruby-to-flawed",
		input = { "chipped-ruby", 12 }, tool = "ruby-lens", product = "flawed-ruby", status = "entity-status.fork-missing-lens" },
	--- issue #642: a cloned machine (on_entity_cloned) is checked too: built away from the spot without telling the mod,
	--- cloned onto it, the original removed
	{ key = "MOLDCLONE", x = 34, machine = "lv-alloy-smelter", recipe = "glass-alloy-smelter", input = { "glass-dust", 20 },
		tool = "mold", product = "glass", status = "entity-status.fork-missing-mold", clone = true },
}

function setup_mold_test(s)
	local fails = {}
	storage.mold_tests = {}
	for i, t in pairs(TOOL_TESTS) do
		local ok, err = pcall(function()
			local eei = s.create_entity{ name = "electric-energy-interface", position = { t.x - 6, MOLD_Y }, force = "player" }
			eei.power_production = 1e8
			eei.electric_buffer_size = 1e9
			s.create_entity{ name = "substation", position = { t.x - 3, MOLD_Y }, force = "player" }
			local m = s.create_entity{ name = t.machine, position = { t.x, MOLD_Y + (t.clone and 6 or 0) }, force = "player",
				raise_built = not t.clone }
			m.force.recipes[t.recipe].enabled = true
			m.set_recipe(t.recipe)
			m.insert{ name = t.input[1], count = t.input[2] }
			if t.clone then
				local original = m
				m = original.clone{ position = { t.x, MOLD_Y }, surface = s }
				original.destroy()
			end
			storage.mold_tests[i] = { machine = m }
		end)
		if not ok then
			fails[#fails + 1] = t.key:lower() .. " test setup: " .. tostring(err)
			storage.mold_tests[i] = { done = true }
			log("DEVCHECK-RUNTIME-" .. t.key .. " failed (setup)")
		end
	end
	return fails
end

--- phase 1 at tick 60: stopped, nothing made, the status names the tool; the tool goes in. Phase 2 as soon as the first
--- product is out, at the latest MOLD_DEADLINE ticks later: running, the tool still in the slot and nowhere else
local function tool_test_tick(t, st, tick)
	local m = st.machine
	local function made()
		return m and m.valid and m.get_inventory(defines.inventory.crafter_output).get_item_count(t.product) or 0
	end
	local phase
	if not st.phase1 and tick >= 60 then
		phase = 1
		st.phase1 = tick
	elseif st.phase1 and (made() > 0 or tick >= st.phase1 + MOLD_DEADLINE) then
		phase = 2
		st.done = true
	else
		return
	end
	local what = t.key:lower() .. " test"
	local problems = {}
	local function expect(ok, text) if not ok then problems[#problems + 1] = what .. ": " .. text end end
	expect(m and m.valid, "machine missing")
	if #problems == 0 then
		local n = made()
		local inv = m.get_module_inventory()
		if phase == 1 then
			local status = m.custom_status
			expect(m.disabled_by_script, "machine without " .. t.tool .. " is not stopped")
			expect(n == 0, "made " .. n .. " " .. t.product .. " without " .. t.tool)
			expect(status and status.label and status.label[1] == t.status,
				"status is " .. serpent.line(status and status.label) .. ", not " .. t.status)
			expect(inv and inv.insert{ name = t.tool, count = 1 } == 1, t.tool .. " does not fit into the module slot")
		else
			expect(not m.disabled_by_script, "machine with " .. t.tool .. " is still stopped")
			expect(n > 0, "no " .. t.product .. " made with " .. t.tool .. " inserted")
			expect(inv.get_item_count(t.tool) == 1, t.tool .. " left the module slot")
			expect(m.get_item_count(t.tool) == 1, t.tool .. " was duplicated or moved")
			log("DEVCHECK-RUNTIME-" .. t.key .. " " .. (#problems == 0 and "ok" or "failed") .. " (" .. t.product .. " " .. n
				.. " after " .. (tick - st.phase1) .. " ticks)")
		end
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL " .. p) end
	if #problems > 0 and phase == 1 then
		st.done = true
		log("DEVCHECK-RUNTIME-" .. t.key .. " failed")
	end
end

--- Steam turbines (issue #97, prototypes/145-fork-power-multiblocks.lua): a large steam turbine on steam and a high
--- pressure steam turbine on superheated steam, each overloaded by an electric energy interface and with a turbine
--- output hatch next to it. At ST_TICK each must make its full output (11.25 MW, 28.35 MW), have burnt about its GT
--- flow (180 steam/s, 210 superheated steam/s; the fluid counted in the turbine and its pipeline segment), and its
--- hatch must hold what it gives back: 0.0625 distilled water per steam, one steam per superheated steam (hatch +
--- owed + the energy of the current step). Fuel check: superheated steam in the large turbine and steam in the high
--- pressure one make no power and stay. Placement: each multiblock of issue #97 is put into a blueprint (it must be
--- in it) and mined into an inventory (its item must come back).
local ST_Y = 310                                        -- between the power test (260) and the cooled fluid test (370)
local ST_TICK = 240
local ST = {
	--  key      entity                          x       fluid               amount  power (W)  fuel x effectivity  back               ratio   flow/s
	{ "lst",     "large-steam-turbine",          -200.5, "steam",             1000,   11.25e6,   100e3 * 0.625,      "distilled-water", 0.0625, 180 },
	{ "hp",      "high-pressure-steam-turbine",  -170.5, "superheated-steam", 1000,   28.35e6,   200e3 * 0.675,      "steam",           1,      210 },
	{ "lst_sh",  "large-steam-turbine",          -140.5, "superheated-steam", 100,    11.25e6 },
	{ "hp_st",   "high-pressure-steam-turbine",  -110.5, "steam",             100,    28.35e6 },
}
--- the multiblocks of issue #97 that exist in this version (the placement test)
ST_PLACE = { "large-steam-turbine", "high-pressure-steam-turbine", "large-heat-exchanger", "fluid-nuclear-reactor",
	"lapotronic-supercapacitor" }
local ST_PLACE_X = -80.5

function setup_steam_test(s)
	local fails = {}
	storage.steam = { t = {} }
	for _, def in ipairs(ST) do
		local ok, err = pcall(function()
			local g = s.create_entity{ name = def[2], position = { def[3], ST_Y }, force = "player", raise_built = true }
			local got = g.insert_fluid{ name = def[4], amount = def[5] }
			if math.abs(got - def[5]) > 1e-6 then fails[#fails + 1] = "steam test: " .. def[1] .. " took only " .. got .. " " .. def[4] end
			local eei = s.create_entity{ name = "electric-energy-interface", position = { def[3], ST_Y + 6 }, force = "player" }
			eei.power_production = 0
			eei.power_usage = 1.5 * def[6] / 60
			eei.electric_buffer_size = 1e8
			s.create_entity{ name = "substation", position = { def[3] + 4, ST_Y + 6 }, force = "player" }
			local h = def[8] and s.create_entity{ name = "turbine-output-hatch", position = { def[3] + 2, ST_Y }, force = "player", raise_built = true }
			storage.steam.t[def[1]] = { g = g, h = h }
		end)
		if not ok then fails[#fails + 1] = "steam test " .. def[1] .. ": " .. tostring(err) end
	end
	--- placement: built 10 tiles apart
	storage.steam.place = {}
	for i, name in ipairs(ST_PLACE) do
		local ok, err = pcall(function()
			local e = s.create_entity{ name = name, position = { ST_PLACE_X + 10 * (i - 1), ST_Y }, force = "player", raise_built = true }
			storage.steam.place[name] = e
		end)
		if not ok then fails[#fails + 1] = "placement test " .. name .. ": " .. tostring(err) end
	end
	return fails
end

function steam_test()
	local st = storage.steam
	if not st or st.done or game.tick < ST_TICK then return end
	st.done = true
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local seconds = game.tick / 60
	local parts = {}
	for _, def in ipairs(ST) do
		local c = st.t[def[1]]
		if not (c and c.g.valid and (not def[8] or (c.h and c.h.valid))) then
			expect(false, def[1] .. " missing")
		elseif def[8] then
			local g, h = c.g, c.h
			local mw = g.energy_generated_last_tick * 60 / 1e6
			expect(math.abs(mw * 1e6 - def[6]) <= 1e-3 * def[6], def[1] .. " makes " .. mw .. " MW, not " .. def[6] / 1e6)
			local burnt = def[5] - fc_fluid_in(g, def[4])
			expect(burnt > 0.9 * def[10] * (seconds - 0.2) and burnt < 1.02 * def[10] * seconds,
				def[1] .. " burnt " .. burnt .. " " .. def[4] .. " in " .. seconds .. " s (GT flow " .. def[10] .. "/s)")
			local back = h.get_fluid_count(def[8])
			local owed = remote.call("gregtorio-power", "debt", g, def[8])
				+ remote.call("gregtorio-power", "energy", g) / def[7] * def[9]
			local want = burnt * def[9]
			expect(back > 0, def[1] .. ": the output hatch got no " .. def[8])
			expect(math.abs(back + owed - want) <= cooled_tolerance(want),
				def[1] .. ": hatch holds " .. back .. " " .. def[8] .. " (+ " .. owed .. " owed) for " .. burnt .. " " .. def[4] .. " burnt")
			expect(h.get_fluid_count(def[4]) == 0, def[1] .. ": " .. def[4] .. " leaked into the output hatch")
			parts[#parts + 1] = string.format("%s %.2f MW, %.1f %s -> %.3f %s", def[2], mw, burnt, def[4], back + owed, def[8])
		else
			local g = c.g
			local left = fc_fluid_in(g, def[4])
			expect(g.energy_generated_last_tick == 0, def[1] .. ": runs on " .. def[4])
			expect(math.abs(left - def[5]) < 1e-6, def[1] .. ": burnt " .. (def[5] - left) .. " " .. def[4])
			local cs = g.custom_status
			expect(g.disabled_by_script and cs and cs.label[1] == "entity-status.fork-wrong-fuel",
				def[1] .. ": not stopped with \"Wrong fuel\"")
		end
	end
	--- placement: blueprint, then mine
	local inv = game.create_inventory(4)
	local placed = 0
	for name, e in pairs(st.place or {}) do
		if not (e and e.valid) then
			expect(false, "placement test: " .. name .. " missing")
		else
			inv.clear()
			inv.insert{ name = "blueprint" }
			local bp = inv[1]
			local box = e.selection_box
			bp.create_blueprint{ surface = e.surface, force = e.force, area = { { box.left_top.x - 0.5, box.left_top.y - 0.5 },
				{ box.right_bottom.x + 0.5, box.right_bottom.y + 0.5 } } }
			local found = false
			for _, be in pairs(bp.get_blueprint_entities() or {}) do
				if be.name == name then found = true end
			end
			expect(found, "placement test: " .. name .. " is not in its blueprint")
			inv.clear()
			expect(e.mine{ inventory = inv, force = true }, "placement test: " .. name .. " could not be mined")
			expect(inv.get_item_count(name) == 1, "placement test: mining " .. name .. " gave " .. inv.get_item_count(name) .. " items")
			placed = placed + 1
		end
	end
	inv.destroy()
	expect(placed == #ST_PLACE, "placement test: " .. placed .. " of " .. #ST_PLACE .. " multiblocks checked")
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL steam turbine test: " .. p) end
	log("DEVCHECK-RUNTIME-STEAM " .. (#problems == 0 and "ok" or "failed") .. " (" .. table.concat(parts, "; ")
		.. "; wrong fuels stopped; " .. placed .. " placed, blueprinted and mined)")
end

--- Nuclear chain (issue #97): a fluid nuclear reactor with two uranium rods and coolant, piped into a large heat
--- exchanger on superheated steam (distilled water put in), a high pressure steam turbine on top of it, its steam
--- through a turbine output hatch and pipes into a large steam turbine (with its own hatch for the water), both
--- turbines on one network with a load of twice their output. The first rod is shortened to 2 s, so a depleted rod
--- must come out while the second one burns. At NC_TICK: every machine has run, both turbines have made power, the
--- energy of the two turbines since NC_FROM is 3.95 MJ per hot coolant the reactor made in that time (20
--- superheated steam x 135 kJ + 20 steam x 62.5 kJ) within the pipes' and the 4 s crafts' slack, and the large steam
--- turbine's hatch holds distilled water. Coolant and distilled water are topped up every tick (a crafting machine's
--- input box holds twice the recipe's amount). A second heat exchanger on the steam recipe gets 32 hot coolant and 80
--- distilled water: exactly 1280 steam and 32 coolant, nothing left.
local NC_Y = 345
local NC_X = -250.5
local NC_FROM, NC_TICK = 300, 1380
local NC_PER_HOT = 20 * 200e3 * 0.675 + 20 * 100e3 * 0.625

function setup_chain_test(s)
	local fails = {}
	local x, y = NC_X, NC_Y
	local nc = {}
	storage.chain = nc
	local ok, err = pcall(function()
		local function make(name, px, py)
			return s.create_entity{ name = name, position = { px, py }, force = "player", raise_built = true }
		end
		nc.reactor = make("fluid-nuclear-reactor", x - 4, y)
		nc.lhe = make("large-heat-exchanger", x, y)
		nc.hp = make("high-pressure-steam-turbine", x, y - 3)
		nc.hatch = make("turbine-output-hatch", x + 2, y - 3)
		nc.lst = make("large-steam-turbine", x + 2, y - 8)
		nc.water = make("turbine-output-hatch", x, y - 8)
		for _, p in pairs({ { x - 4, y - 2 }, { x - 3, y - 2 }, { x - 2, y - 2 }, { x - 2, y - 1 }, { x - 2, y },
			{ x + 2, y - 4 }, { x + 2, y - 5 }, { x + 2, y - 6 } }) do
			make("pipe", p[1], p[2])
		end
		for _, r in pairs({ "hot-coolant", "large-heat-exchanger-superheated-steam", "large-heat-exchanger-steam" }) do
			game.forces.player.recipes[r].enabled = true
		end
		nc.reactor.set_recipe("hot-coolant")
		nc.lhe.set_recipe("large-heat-exchanger-superheated-steam")
		local function put(e, fluid, n)
			local got = e.insert_fluid{ name = fluid, amount = n }
			if math.abs(got - n) > 1e-6 then fails[#fails + 1] = "chain test: " .. e.name .. " took only " .. got .. " " .. fluid end
		end
		put(nc.reactor, "coolant", 42)
		put(nc.lhe, "distilled-water", 40)
		local rods = nc.reactor.get_fuel_inventory().insert{ name = "uranium-fuel-rod", count = 2 }
		if rods ~= 2 then fails[#fails + 1] = "chain test: the reactor took " .. rods .. " fuel rods" end
		local eei = s.create_entity{ name = "electric-energy-interface", position = { x + 7, y - 2 }, force = "player" }
		eei.power_production = 0
		eei.power_usage = 2 * (28.35e6 + 11.25e6) / 60
		eei.electric_buffer_size = 1e8
		s.create_entity{ name = "substation", position = { x + 7, y - 6 }, force = "player" }
		--- the heat exchanger on steam, alone
		nc.lhe2 = make("large-heat-exchanger", x + 20, y)
		nc.lhe2.set_recipe("large-heat-exchanger-steam")
		put(nc.lhe2, "hot-coolant", 32)
		put(nc.lhe2, "distilled-water", 80)
		nc.energy, nc.hp_on, nc.lst_on = 0, false, false
	end)
	if not ok then fails[#fails + 1] = "chain test: " .. tostring(err) end
	return fails
end

--- every tick: shorten the first rod, add up the turbines' energy
function chain_tick(tick)
	local nc = storage.chain
	if not nc or nc.done or not (nc.hp and nc.hp.valid and nc.lst and nc.lst.valid and nc.reactor.valid) then return end
	nc.reactor.insert_fluid{ name = "coolant", amount = 100 }
	nc.lhe.insert_fluid{ name = "distilled-water", amount = 100 }
	if tick == 30 then
		local b = nc.reactor.burner
		if b.currently_burning then b.remaining_burning_fuel = 2 * 10.5e6 end
	end
	local hp, lst = nc.hp.energy_generated_last_tick, nc.lst.energy_generated_last_tick
	if hp > 0 then nc.hp_on = true end
	if lst > 0 then nc.lst_on = true end
	if tick == NC_FROM then nc.from = nc.reactor.products_finished end
	if tick > NC_FROM then nc.energy = nc.energy + hp + lst end
end

function chain_test()
	local nc = storage.chain
	if not nc or nc.done or game.tick < NC_TICK then return end
	nc.done = true
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local summary = ""
	for _, k in pairs({ "reactor", "lhe", "hp", "hatch", "lst", "water", "lhe2" }) do
		expect(nc[k] and nc[k].valid, k .. " missing")
	end
	if #problems == 0 then
		local r = nc.reactor
		local depleted = r.get_burnt_result_inventory().get_item_count("depleted-uranium-fuel-rod")
		expect(depleted == 1, "the reactor gave " .. depleted .. " depleted rods (one rod was shortened to 2 s)")
		expect(r.burner.currently_burning ~= nil, "the reactor does not burn the second rod")
		expect(r.products_finished >= 4, "the reactor made only " .. r.products_finished .. " crafts of hot coolant")
		expect(nc.lhe.products_finished >= 4, "the heat exchanger made only " .. nc.lhe.products_finished .. " crafts")
		expect(nc.hp_on and nc.lst_on, "a turbine never made power (high pressure " .. tostring(nc.hp_on)
			.. ", large " .. tostring(nc.lst_on) .. ")")
		local hot = 21 * (r.products_finished - (nc.from or 0))
		local want = hot * NC_PER_HOT
		local ratio = want > 0 and nc.energy / want or 0
		expect(ratio > 0.6 and ratio < 1.25, string.format("the turbines made %.1f MJ for %d hot coolant (%.1f MJ expected)",
			nc.energy / 1e6, hot, want / 1e6))
		local water = nc.water.get_fluid_count("distilled-water")
		expect(water > 0, "no distilled water in the large steam turbine's hatch")
		local seconds = (NC_TICK - NC_FROM) / 60
		--- the heat exchanger on steam: two crafts
		local e2 = nc.lhe2
		local steam, cool = e2.get_fluid_count("steam"), e2.get_fluid_count("coolant")
		local wleft, hleft = e2.get_fluid_count("distilled-water"), e2.get_fluid_count("hot-coolant")
		expect(math.abs(steam - 1280) < 1e-6 and math.abs(cool - 32) < 1e-6 and wleft < 1e-6 and hleft < 1e-6,
			string.format("heat exchanger on steam: %.3f steam, %.3f coolant, %.3f water and %.3f hot coolant left (1280, 32, 0, 0)",
				steam, cool, wleft, hleft))
		summary = string.format(" (%d hot coolant in %.0f s -> %.1f MW from both turbines, %.0f %% of 3.95 MJ per hot coolant;"
			.. " %d depleted rod; %.2f distilled water back; steam recipe 32 hot coolant -> %.0f steam)",
			hot, seconds, nc.energy / seconds / 1e6, ratio * 100, depleted, water, steam)
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL nuclear chain test: " .. p) end
	log("DEVCHECK-RUNTIME-CHAIN " .. (#problems == 0 and "ok" or "failed") .. summary)
end

--- Lapotronic supercapacitor (issue #97): an IV one on a network with a LuV plasma turbine (81.92 MW, secondary
--- output; an electric energy interface is tertiary like the accumulator and does not charge it), which is removed
--- at LS_SWITCH; then a UIV compressor making air (40.96 MW, a recipe without ingredients, its air removed every tick;
--- the UHV air collector until issue #153) runs from it. It must charge from tick LS_FROM to LS_SWITCH and discharge from LS_SWITCH + LS_FROM to LS_TICK at its
--- 20.48 MW (within 3 %; its own loss is 0.6 % of that). The IV, LuV and ZPM ones must hold 27 blocks of 37.5,
--- 187.5 and 937.5 GJ. Loss: a ZPM one without a network is set to 1 TJ at tick 100; at LS_TICK it must have lost
--- exactly 1 % of its capacity per day for the whole steps of 10 ticks since (scripts/fork-power.lua).
local LS_Y = 345
local LS_X = -170.5
local LS_FROM, LS_SWITCH, LS_TICK = 20, 300, 600
local LS_LOSS_FROM = 100
local LS_FLOW = 20.48e6
local LS = {
	{ "lapotronic-supercapacitor", 27 * 37.5e9 },
	{ "luv-lapotronic-supercapacitor", 27 * 187.5e9 },
	{ "zpm-lapotronic-supercapacitor", 27 * 937.5e9 },
}

function setup_lsc_test(s)
	local fails = {}
	local ls = {}
	storage.lsc = ls
	local ok, err = pcall(function()
		ls.iv = s.create_entity{ name = LS[1][1], position = { LS_X, LS_Y }, force = "player", raise_built = true }
		ls.turbine = s.create_entity{ name = "luv-large-plasma-turbine", position = { LS_X + 6, LS_Y - 1 }, force = "player",
			raise_built = true }
		local got = ls.turbine.insert_fluid{ name = "helium-plasma", amount = 100 }
		if got < 100 then fails[#fails + 1] = "supercapacitor test: the turbine took only " .. got .. " plasma" end
		--- (issue #616: with GT overclocking a machine's power grows 4x per tier, so the LuV compressor is the old UIV load)
		local oc = settings.startup["gregtorio-continued-gt-overclocking"]
		ls.load = s.create_entity{ name = oc and oc.value and "luv-compressor" or "uiv-compressor", position = { LS_X + 6, LS_Y + 5 },
			force = "player" }
		for name, r in pairs(prototypes.recipe) do
			if r.categories[1] == "lv-compressor-recipes" and #r.ingredients == 0 then ls.recipe = name break end
		end
		if not ls.recipe then fails[#fails + 1] = "supercapacitor test: no compressor recipe without ingredients (air)" end
		s.create_entity{ name = "substation", position = { LS_X + 4, LS_Y - 4 }, force = "player" }
		ls.others = {}
		for i, def in ipairs(LS) do
			if i > 1 then
				ls.others[def[1]] = s.create_entity{ name = def[1], position = { LS_X + 12 * (i - 1), LS_Y + 20 },
					force = "player", raise_built = true }
			end
		end
	end)
	if not ok then fails[#fails + 1] = "supercapacitor test: " .. tostring(err) end
	return fails
end

function lsc_tick(tick)
	local ls = storage.lsc
	if not ls or ls.done or not (ls.iv and ls.iv.valid and ls.load and ls.load.valid) then return end
	if tick == LS_FROM then ls.e0 = ls.iv.energy end
	if tick == LS_LOSS_FROM then
		local z = ls.others[LS[3][1]]
		if z and z.valid then z.energy = 1e12 end
	end
	if tick == LS_SWITCH then
		ls.e1 = ls.iv.energy
		if ls.turbine and ls.turbine.valid then ls.turbine.destroy() end
		ls.load.force.recipes[ls.recipe].enabled = true
		ls.load.set_recipe(ls.recipe)
	end
	if tick == LS_SWITCH + LS_FROM then ls.e2 = ls.iv.energy end
	if tick > LS_SWITCH then ls.load.clear_fluid_inside() end
end

function lsc_test()
	local ls = storage.lsc
	if not ls or ls.done or game.tick < LS_TICK then return end
	ls.done = true
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local summary = ""
	local z = ls.others and ls.others[LS[3][1]]
	if not (ls.iv and ls.iv.valid and z and z.valid and ls.e0 and ls.e1 and ls.e2) then
		expect(false, "supercapacitors missing or a phase did not run")
	else
		for _, def in ipairs(LS) do
			local e = def[1] == LS[1][1] and ls.iv or ls.others[def[1]]
			expect(e and e.valid and math.abs(e.electric_buffer_size - def[2]) <= 1e-9 * def[2],
				def[1] .. " holds " .. (e and e.valid and e.electric_buffer_size or 0) .. " J, not " .. def[2])
		end
		local charged = ls.e1 - ls.e0
		local want_in = LS_FLOW * (LS_SWITCH - LS_FROM) / 60
		expect(charged > 0.97 * want_in and charged <= want_in * 1.0001,
			string.format("charged %.1f MJ in %d ticks (%.1f MJ at 20.48 MW)", charged / 1e6, LS_SWITCH - LS_FROM, want_in / 1e6))
		local out = ls.e2 - ls.iv.energy
		local want_out = LS_FLOW * (LS_TICK - LS_SWITCH - LS_FROM) / 60
		expect(out > 0.97 * want_out and out < 1.03 * want_out,
			string.format("gave %.1f MJ in %d ticks (%.1f MJ at 20.48 MW)", out / 1e6, LS_TICK - LS_SWITCH - LS_FROM, want_out / 1e6))
		local steps = 0
		for t = LS_LOSS_FROM + 1, game.tick do if t % 10 == 0 then steps = steps + 1 end end
		local loss = LS[3][2] / 100 / 86400 * 10 / 60 * steps
		local lost = 1e12 - z.energy
		expect(math.abs(lost - loss) <= 1e-6 * loss + 1,
			string.format("the ZPM supercapacitor lost %.0f J in %d steps, not %.0f", lost, steps, loss))
		summary = string.format(" (IV: %.2f MW in, %.2f MW out; capacities %.1f / %.1f / %.1f GJ; ZPM loss %.0f kW)",
			charged / ((LS_SWITCH - LS_FROM) / 60) / 1e6, out / ((LS_TICK - LS_SWITCH - LS_FROM) / 60) / 1e6,
			LS[1][2] / 1e9, LS[2][2] / 1e9, LS[3][2] / 1e9, lost / (steps * 10 / 60) / 1e3)
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL supercapacitor test: " .. p) end
	log("DEVCHECK-RUNTIME-LSC " .. (#problems == 0 and "ok" or "failed") .. summary)
end

--- Machine recipes of items that also have a crafting table recipe (issue #126, part C): with the technology of the recipe
--- researched by script the recipe must be enabled, not hidden from the crafting menu, and the lowest machine of its
--- category must take it (what an LV assembling machine offers a player once automation-2 is researched).
local OFFER = { "burner-inserter", "iron-chest", "iron-stick", "pipe", "chest" }

function setup_offer_test(s)
	local fails, offered = {}, {}
	storage.offer = { offered = offered }
	local force = game.forces.player
	for _, name in ipairs(OFFER) do
		local ok, err = pcall(function()
			local proto = prototypes.recipe[name]
			assert(proto, "no such recipe")
			assert(not proto.hidden, "hidden")
			assert(not proto.hide_from_player_crafting, "hidden from the crafting menu")
			local tech
			for tname, t in pairs(prototypes.technology) do
				for _, e in pairs(t.effects) do
					if e.type == "unlock-recipe" and e.recipe == name then tech = tname end
				end
			end
			assert(tech, "no technology unlocks it")
			force.technologies[tech].researched = true
			assert(force.recipes[name].enabled, "not enabled after researching " .. tech)
			local best
			for mname, m in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "assembling-machine" } }) do
				if m.crafting_categories[proto.categories[1]] and m.items_to_place_this and #m.items_to_place_this > 0
						and (not best or m.get_crafting_speed() < best.get_crafting_speed()) then
					best = m
				end
			end
			assert(best, "no machine for " .. proto.categories[1])
			local e = s.create_entity{ name = best.name, position = { -60 + 8 * #offered, 260 }, force = "player", raise_built = true }
			e.set_recipe(name)
			assert(e.get_recipe() and e.get_recipe().name == name, "the machine did not take it")
			offered[#offered + 1] = name .. " in " .. best.name .. " (" .. tech .. ")"
		end)
		if not ok then fails[#fails + 1] = "offer test " .. name .. ": " .. tostring(err) end
	end
	return fails
end

function offer_test()
	local st = storage.offer
	if not st or st.done then return end
	st.done = true
	log("DEVCHECK-RUNTIME-OFFER " .. (#st.offered == #OFFER and "ok" or "failed") .. " (" .. table.concat(st.offered, "; ") .. ")")
end

--- Melts and casts (issue #117, prototypes/197-fork-fluid-steps.lua). The game cuts fluid amounts at steps of 2^-24, so n melted
--- ingots must cover every combination of casts that n ingots are worth, with the amounts the engine holds.
--- 1) For every melt (an extractor recipe giving 14.4 of a fluid per ingot) and every cast that takes only that fluid (a
---    recipe of the solidifier categories, one fluid in, true amount in tenths): n ingots (n * 14.4 = m * the cast's
---    amount) must give at least what m casts take.
--- 2) In machines: ten ingots melted in an LV fluid extractor, the melt of nine of them in an LV fluid solidifier on the block
---    cast (it must start with no tenth melt and make the block), the tenth one's on the ingot cast (it must make the
---    ingot); ten melts must hold at least 144.
local CT_X, CT_Y = -60, 200
local CT_DEADLINE = 900
local CT_INGOT_TENTHS = 144

local function ct_gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end

local function melt_coverage()
	local melts, casts = {}, {}
	for name, r in pairs(prototypes.recipe) do
		local c = r.categories[1]       -- (a list since Factorio 2.1; a Gregtorio recipe has one, issue #535)
		if c:find("extractor%-recipes$") and #r.products == 1 and r.products[1].type == "fluid" and #r.ingredients == 1
				and r.ingredients[1].type == "item" and r.ingredients[1].name:sub(-6) == "-ingot"
				and math.abs(r.products[1].amount - 14.4) < 1e-3 then
			melts[#melts + 1] = { name = name, fluid = r.products[1].name, amount = r.products[1].amount }
		elseif (c:find("fluid%-solidifier%-recipes$") or c:find("vacuum%-freezer%-recipes$")) and #r.ingredients == 1
				and r.ingredients[1].type == "fluid" then
			casts[#casts + 1] = { name = name, fluid = r.ingredients[1].name, amount = r.ingredients[1].amount }
		end
	end
	local checked, problems = 0, {}
	for _, m in pairs(melts) do
		for _, c in pairs(casts) do
			if c.fluid == m.fluid then
				local tenths = math.floor(c.amount * 10 + 0.5)
				if tenths > 0 and math.abs(c.amount * 10 - tenths) < 1e-3 then
					local g = ct_gcd(CT_INGOT_TENTHS, tenths)
					local casts_n, ingots = CT_INGOT_TENTHS / g, tenths / g
					checked = checked + 1
					if ingots * m.amount < casts_n * c.amount then
						problems[#problems + 1] = string.format("%d melts (%s, %.9f each) give %.9f, %d casts (%s, %.9f each) take %.9f",
							ingots, m.name, m.amount, ingots * m.amount, casts_n, c.name, c.amount, casts_n * c.amount)
					end
				end
			end
		end
	end
	return #melts, checked, problems
end

function setup_melt_test(s)
	local fails = {}
	local nmelts, nchecked, problems = melt_coverage()
	for i, p in ipairs(problems) do
		if i <= 10 then fails[#fails + 1] = "melt test: " .. p end
	end
	if #problems > 10 then fails[#fails + 1] = "melt test: ... and " .. (#problems - 10) .. " more combinations that do not fit" end
	storage.melt = { n = 0, total = 0, taken = {}, coverage = nmelts .. " melts, " .. nchecked .. " cast combinations" }
	local ok, err = pcall(function()
		local st = storage.melt
		local eei = s.create_entity{ name = "electric-energy-interface", position = { CT_X, CT_Y }, force = "player" }
		eei.power_production = 1e6
		eei.electric_buffer_size = 1e7
		s.create_entity{ name = "substation", position = { CT_X + 3, CT_Y }, force = "player" }
		s.create_entity{ name = "substation", position = { CT_X + 15, CT_Y }, force = "player" }
		local molds = prototypes.mod_data["fork-mold-recipes"]
		local function machine(name, x, recipe)
			local e = s.create_entity{ name = name, position = { x, CT_Y + 4 }, force = "player", raise_built = true }
			e.force.recipes[recipe].enabled = true
			e.set_recipe(recipe)
			if molds and molds.data[recipe] then e.get_module_inventory().insert{ name = molds.data[recipe] } end
			return e
		end
		st.extractor = machine("lv-fluid-extractor", CT_X + 6, "melt-iron-ingot")
		st.block = machine("lv-fluid-solidifier", CT_X + 12, "solidify-block-of-iron")
		st.ingot = machine("lv-fluid-solidifier", CT_X + 18, "solidify-iron-ingot")
		st.extractor.insert{ name = "iron-ingot", count = 10 }
	end)
	if not ok then fails[#fails + 1] = "melt test setup: " .. tostring(err) end
	return fails
end

function melt_test()
	local st = storage.melt
	if not st or st.done or not st.extractor then return end
	local ex, problems = st.extractor, {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function finish()
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL melt test: " .. p) end
		log("DEVCHECK-RUNTIME-MELT " .. (#problems == 0 and "ok" or "failed") .. " (" .. st.coverage .. "; one melt "
			.. string.format("%.9f", st.taken[1] or 0) .. ", ten " .. string.format("%.9f", st.total) .. ", block cast "
			.. (st.block_made or 0) .. ", ingot cast " .. (st.ingot_made or 0) .. ", tick " .. game.tick .. ")")
	end
	if not (ex.valid and st.block.valid and st.ingot.valid) then
		expect(false, "a machine is missing")
		return finish()
	end
	if game.tick > CT_DEADLINE then
		expect(false, "timed out in phase " .. (st.phase or "melting") .. " after " .. st.n .. " melts")
		return finish()
	end
	if not st.phase then
		-- melting: a craft that is under way finishes at once; what it made is taken out of the box
		if ex.crafting_progress > 0 and ex.crafting_progress < 0.99 then ex.crafting_progress = 0.99 end
		if ex.products_finished > st.n then
			st.n = ex.products_finished
			local got = ex.extract_fluid{ name = "molten-iron", amount = 1000 }
			st.taken[st.n] = got
			st.total = st.total + got
			if st.n <= 9 then
				st.block_in = (st.block_in or 0) + st.block.insert_fluid{ name = "molten-iron", amount = got }
			else
				expect(st.ingot.insert_fluid{ name = "molten-iron", amount = got } == got, "the ingot cast's box did not take the tenth melt")
			end
			if st.n == 10 then
				expect(st.total >= 144, string.format("ten melts hold %.9f, not 144", st.total))
				expect(st.block_in >= 9 * st.taken[1] - 1e-9, string.format("the block cast's box took only %.9f of nine melts", st.block_in))
				st.phase = "casting"
				st.cast_from = game.tick
			end
		end
	else
		for _, key in pairs({ "block", "ingot" }) do
			local m = st[key]
			if m.crafting_progress > 0 and m.crafting_progress < 0.99 then m.crafting_progress = 0.99 end
		end
		st.block_made = st.block.get_output_inventory().get_item_count("block-of-iron")
		st.ingot_made = st.ingot.get_output_inventory().get_item_count("iron-ingot")
		if (st.block_made > 0 and st.ingot_made > 0) or game.tick > st.cast_from + 120 then
			expect(st.block_made > 0, string.format("nine melts (%.9f) did not start the block cast", st.block_in or 0))
			local status
			for n, v in pairs(defines.entity_status) do if st.ingot.status == v then status = n end end
			expect(st.ingot_made > 0, "the tenth melt (" .. st.ingot.get_fluid_count("molten-iron") .. ") did not start the ingot cast (" .. tostring(status) .. ", progress " .. st.ingot.crafting_progress .. ", recipe " .. tostring(st.ingot.get_recipe() and st.ingot.get_recipe().name) .. ")")
			finish()
		end
	end
end

--- Supercapacitor upgrade (issue #124): the game does not carry an accumulator's energy over to its replacement, so
--- scripts/fork-power.lua does. A charged IV supercapacitor replaced by a LuV one (fast replace, built event raised as for
--- a player and a robot) holds the same energy; the LuV one filled above the IV capacity and replaced by an IV one is capped
--- at the IV capacity; one that was mined and a LuV one built over the spot much later starts empty.
local LU_X, LU_Y = -230.5, 330
local LU_IV, LU_LUV = "lapotronic-supercapacitor", "luv-lapotronic-supercapacitor"

function setup_lsup_test(s)
	local fails = {}
	local ok, err = pcall(function()
		local st = { phase = 0 }
		storage.lsup = st
		st.a = s.create_entity{ name = LU_IV, position = { LU_X, LU_Y }, force = "player", raise_built = true }
		st.a.energy = 500e9
		st.c = s.create_entity{ name = LU_IV, position = { LU_X + 12, LU_Y }, force = "player", raise_built = true }
		st.c.energy = 400e9
	end)
	if not ok then fails[#fails + 1] = "supercapacitor upgrade test: " .. tostring(err) end
	return fails
end

local function lsup_replace(old, name)
	local pos, s = old.position, old.surface
	return s.create_entity{ name = name, position = pos, force = "player", fast_replace = true, spill = false,
		raise_built = true }
end

function lsup_test()
	local st = storage.lsup
	if not st or st.done then return end
	local t, problems = game.tick, {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local TOL = 5e6                                             -- J: a few steps of the passive loss
	if st.phase == 0 and t >= 30 then
		local b = lsup_replace(st.a, LU_LUV)
		st.b = b
		expect(b and b.valid, "the LuV supercapacitor was not built")
		if b and b.valid then
			st.up = b.energy
			expect(math.abs(b.energy - 500e9) < TOL, string.format("IV -> LuV: %.3f GJ left of 500 GJ", b.energy / 1e9))
			b.energy = 3000e9
		end
		st.c.destroy()
		st.phase, st.t1 = 1, t
	elseif st.phase == 1 and t >= st.t1 + 20 then
		local a2 = st.b.valid and lsup_replace(st.b, LU_IV)
		expect(a2 and a2.valid, "the IV supercapacitor was not built")
		if a2 and a2.valid then
			st.down = a2.energy
			expect(math.abs(a2.energy - a2.electric_buffer_size) < TOL,
				string.format("LuV -> IV: %.3f GJ, not the capacity %.3f GJ", a2.energy / 1e9, a2.electric_buffer_size / 1e9))
		end
		st.phase, st.t2 = 2, t
	elseif st.phase == 2 and t >= st.t2 + 60 then
		-- the spot of the destroyed one: nothing to carry over after this long
		local d = game.surfaces[1].create_entity{ name = LU_LUV, position = { LU_X + 12, LU_Y }, force = "player", raise_built = true }
		expect(d and d.valid and d.energy == 0, "a supercapacitor built on a spot that was empty for a while started with energy")
		st.phase, st.done = 3, true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL supercapacitor upgrade test: " .. p) end
		log("DEVCHECK-RUNTIME-LSUP " .. (#problems == 0 and "ok" or "failed") .. string.format(" (IV -> LuV kept %.1f of 500 GJ, LuV -> IV capped at %.1f GJ)",
			(st.up or 0) / 1e9, (st.down or 0) / 1e9))
		return
	end
	if #problems > 0 then
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL supercapacitor upgrade test: " .. p) end
		log("DEVCHECK-RUNTIME-LSUP failed")
	end
end

--- Space Elevator modules (issues #301, #302, scripts/fork-space-elevator.lua): a mining module without an elevator next to
--- it stops; next to a Mk-I elevator the first six Mk-I modules run, the seventh stops (its six slots are taken), a Mk-II
--- module stops (motors too weak); the elevator replaced by a Mk-II one runs the Mk-II module too; the elevator removed
--- stops them all. Issue #303: a Mk-I pump module (motors Mk-II) stops at the Mk-I elevator and runs at the Mk-II one, and
--- takes a pumping recipe; a Planetary Gas Siphon takes a siphon recipe.
local SE_X, SE_Y = 320, 300
local SE_MODS = { { 316, 292 }, { 320, 292 }, { 324, 292 }, { 316, 308 }, { 320, 308 }, { 324, 308 }, { 312, 300 } }

function setup_elevator_test(s)
	local fails = {}
	local ok, err = pcall(function()
		local st = { phase = 0, mods = {} }
		storage.elevator = st
		st.mods[1] = s.create_entity{ name = "space-elevator-mining-module-mk1", position = SE_MODS[1], force = "player",
			raise_built = true }
	end)
	if not ok then fails[#fails + 1] = "space elevator test: " .. tostring(err) end
	return fails
end

local function se_status(m)
	if not m.disabled_by_script then return "on" end
	local cs = m.custom_status
	return cs and type(cs.label) == "table" and cs.label[1]:gsub("^entity%-status%.fork%-space%-elevator%-", "") or "off"
end

function elevator_test()
	local st = storage.elevator
	if not st or st.done then return end
	local t, s, problems = game.tick, game.surfaces[1], {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	if st.phase == 0 and t >= 20 then
		expect(se_status(st.mods[1]) == "missing", "a module without an elevator: " .. se_status(st.mods[1]))
		st.el = s.create_entity{ name = "space-elevator-mk1", position = { SE_X, SE_Y }, force = "player", raise_built = true }
		for i = 2, #SE_MODS do
			st.mods[i] = s.create_entity{ name = "space-elevator-mining-module-mk1", position = SE_MODS[i], force = "player",
				raise_built = true }
		end
		st.mk2 = s.create_entity{ name = "space-elevator-mining-module-mk2", position = { 328, 300 }, force = "player",
			raise_built = true }
		st.pump = s.create_entity{ name = "space-elevator-pump-module-mk1", position = { 312, 292 }, force = "player",
			raise_built = true }
		local ok = pcall(function() st.pump.set_recipe("space-pump-lava") end)
		expect(ok and st.pump.get_recipe() and st.pump.get_recipe().name == "space-pump-lava", "the pump module takes no pumping recipe")
		local siphon = s.create_entity{ name = "planetary-gas-siphon", position = { 300, 280 }, force = "player", raise_built = true }
		ok = pcall(function() siphon.set_recipe("gas-siphon-jupiter-1") end)
		expect(ok and siphon.get_recipe() and siphon.get_recipe().name == "gas-siphon-jupiter-1", "the gas siphon takes no siphon recipe")
		st.phase = 1
	elseif st.phase == 1 then
		local on = 0
		for i = 1, 6 do if se_status(st.mods[i]) == "on" then on = on + 1 end end
		st.on = on
		expect(on == 6, "Mk-I elevator: " .. on .. " of the first 6 modules run")
		expect(se_status(st.mods[7]) == "full", "the seventh module: " .. se_status(st.mods[7]))
		expect(se_status(st.mk2) == "motors", "a Mk-II module at a Mk-I elevator: " .. se_status(st.mk2))
		expect(se_status(st.pump) == "motors", "a Mk-I pump module at a Mk-I elevator: " .. se_status(st.pump))
		st.el = s.create_entity{ name = "space-elevator-mk2", position = { SE_X, SE_Y }, force = "player", fast_replace = true,
			spill = false, raise_built = true }
		st.phase = 2
	elseif st.phase == 2 then
		expect(st.el and st.el.valid and st.el.name == "space-elevator-mk2", "the Mk-II elevator was not built")
		expect(se_status(st.mk2) == "on", "a Mk-II module at a Mk-II elevator: " .. se_status(st.mk2))
		expect(se_status(st.mods[7]) == "on", "the seventh module at 12 slots: " .. se_status(st.mods[7]))
		expect(se_status(st.pump) == "on", "a Mk-I pump module at a Mk-II elevator: " .. se_status(st.pump))
		st.el.destroy()
		st.phase, st.t3 = 3, t
	elseif st.phase == 3 and t >= st.t3 + 10 then
		local off = 0
		for _, m in pairs(st.mods) do if se_status(m) == "missing" then off = off + 1 end end
		expect(off == #SE_MODS and se_status(st.mk2) == "missing" and se_status(st.pump) == "missing", "after the elevator went: "
			.. off .. " of " .. #SE_MODS .. " modules stopped, the Mk-II one " .. se_status(st.mk2) .. ", the pump module "
			.. se_status(st.pump))
		st.done = true
	end
	if st.done or #problems > 0 then
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL space elevator test: " .. p) end
		log("DEVCHECK-RUNTIME-ELEVATOR " .. (#problems == 0 and "ok" or "failed")
			.. " (Mk-I elevator ran " .. tostring(st.on) .. " of 7 Mk-I modules)")
	end
end

--- Issue #499: the recipe machines are the dimension mines now (the mining drills took their names); hunting moved to the
--- Dig Site, so the recipe without a twin is the glowstone vein.
--- Electric mine (issue #335, prototypes/163-fork-electric-mine.lua): two Manual Mines with the iron vein recipe, a
--- pickaxe and manual labor in their input slots and raw copper in their output slot (stopped by script, so the slots stay
--- as they are), each with an inserter and a belt on two sides. Mine A is replaced by fast replace (no player: what the
--- plant cannot take is spilled), mine B by the upgrade planner's mapping Manual Mine -> Mk I and the T1 construction
--- robots of a T1 roboport (issue #336: the roboport must take them, and the T1 logistic robots) with the plant in a
--- storage chest (the robots bring the old machine and its items back). The
--- neighbours must stay, the items come back (on the ground, in the storage chest), and plant A drills the iron vein's
--- twin with Drilling Fluid and a mining pipe (issue #341, used up: #346, one per vein: #393): 40 raw copper in 12 s. Issue #337: the Manual Mine's upgrade chain goes through the LV, MV and
--- HV Miner to the plant; a third Manual Mine is replaced by fast replace with the HV Miner, which mines the iron vein's
--- Miner twin: 40 raw copper in 6 s, and its mining pipe is used up (issue #346; one per vein, #393).
local EM_X, EM_Y = 260.5, -120.5
local EM_C = 60                                          -- mine C (the HV Miner): x offset
local EM_CHAIN = { "dimension-mine", "lv-dimension-miner", "mv-dimension-miner", "hv-dimension-miner", "dimension-drilling-plant-mk1" }
--- Issue #342: a replaced mine keeps its vein (scripts/fork-electric-mine.lua). E: replaced by script after the remote
--- note_replace (what on_pre_build does for a player): Manual Mine -> LV Miner -> MV Miner -> Mk I must give
--- miner-copper-tin-vein, miner-copper-tin-vein, drilling-copper-tin-vein; a Manual Mine hunting blazes replaced by a Mk I has no recipe and
--- spills its manual labor. D: the same by order_upgrade and the T1 robots of a second network (each step on its own
--- mine); B (the upgrade planner above) must give drilling-copper-tin-vein too.
local EM_E_Y, EM_D_Y = -105.5, -122.5
local EM_D = { { 352.5, "dimension-mine", "mining-copper-tin-vein", "lv-dimension-miner", "miner-copper-tin-vein" },
	{ 360.5, "lv-dimension-miner", "miner-copper-tin-vein", "mv-dimension-miner", "miner-copper-tin-vein" },
	{ 368.5, "mv-dimension-miner", "miner-copper-tin-vein", "dimension-drilling-plant-mk1", "drilling-copper-tin-vein" },
	{ 376.5, "dimension-mine", "mining-glowstone-vein", "dimension-drilling-plant-mk1", nil } }
local EM_LABOR = 10

local function em_mine(s, name, x, y, recipe)
	local e = s.create_entity{ name = name, position = { x, y }, force = "player", raise_built = true }
	e.set_recipe(recipe)
	e.disabled_by_script = true
	if recipe == "mining-glowstone-vein" then
		assert(e.get_inventory(defines.inventory.crafter_input).insert{ name = "manual-labor", count = EM_LABOR }
			== EM_LABOR, "the hunting manual mine took no manual labor")
	end
	return e
end
local function em_recipe(e) return e and e.valid and e.get_recipe() and e.get_recipe().name or nil end
local EM_B = 30                                          -- mine B: x offset
local EM_ITEMS = { ["iron-pickaxe-usage"] = 1, ["manual-labor"] = 2, ["raw-copper"] = 10 }
local EM_PLANT = "dimension-drilling-plant-mk1"
local EM_ORES = 40   -- the copper-tin vein's raw copper per operation (issue #505: the iron vein's 64 are gone)

local function em_site(s, x, y)
	local mine = s.create_entity{ name = "dimension-mine", position = { x, y }, force = "player", raise_built = true }
	mine.set_recipe("mining-copper-tin-vein")
	mine.disabled_by_script = true
	local input = mine.get_inventory(defines.inventory.crafter_input)
	assert(input.insert{ name = "iron-pickaxe-usage", count = 1 } == 1, "the manual mine took no pickaxe")
	assert(input.insert{ name = "manual-labor", count = 2 } == 2, "the manual mine took no manual labor")
	assert(mine.get_inventory(defines.inventory.crafter_output).insert{ name = "raw-copper", count = 10 } == 10,
		"the manual mine's output slot took no raw copper")
	local around = {}
	for _, n in pairs({ { "inserter", 0, -3, defines.direction.north }, { "transport-belt", 0, 3, defines.direction.east },
		{ "inserter", 3, 0, defines.direction.east }, { "transport-belt", -3, 0, defines.direction.north } }) do
		local e = s.create_entity{ name = n[1], position = { x + n[2], y + n[3] }, direction = n[4], force = "player",
			raise_built = true }
		around[#around + 1] = e
	end
	return mine, around
end

local function em_items_in(list)
	local out = {}
	for _, e in pairs(list) do
		if e.valid then
			if e.type == "item-entity" then
				out[e.stack.name] = (out[e.stack.name] or 0) + e.stack.count
			else
				for _, c in pairs(e.get_inventory(defines.inventory.chest).get_contents()) do
					out[c.name] = (out[c.name] or 0) + c.count
				end
			end
		end
	end
	return out
end

function setup_emine_test(s)
	local fails = {}
	local ok, err = pcall(function()
		local st = { phase = 0 }
		storage.emine = st
		for _, r in pairs({ "mining-copper-tin-vein", "drilling-copper-tin-vein", "miner-copper-tin-vein", "mining-glowstone-vein" }) do
			game.forces.player.recipes[r].enabled = true
		end
		st.a, st.a_around = em_site(s, EM_X, EM_Y)
		st.b, st.b_around = em_site(s, EM_X + EM_B, EM_Y)
		st.c = em_site(s, EM_X + EM_C, EM_Y)
		for _, x in pairs({ EM_X, EM_X + EM_B, EM_X + EM_C }) do
			s.create_entity{ name = "substation", position = { x + 5.5, EM_Y - 4.5 }, force = "player" }
			s.create_entity{ name = "electric-energy-interface", position = { x + 8.5, EM_Y - 4.5 }, force = "player" }
		end
		local port = s.create_entity{ name = "roboport-mk1", position = { EM_X + EM_B + 7.5, EM_Y + 1.5 }, force = "player",
			raise_built = true }
		--- issue #336: the T1 robots' items place their robots, so the T1 roboport takes them
		local robots = port.get_inventory(defines.inventory.roboport_robot)
		assert(robots.insert{ name = "t1-construction-robot", count = 10 } == 10, "the T1 roboport took no T1 construction robots")
		assert(robots.insert{ name = "t1-logistic-robot", count = 10 } == 10, "the T1 roboport took no T1 logistic robots")
		port.energy = 300e6                                -- (it works from 60 MJ on, recharge_minimum)
		st.chest = s.create_entity{ name = "storage-chest", position = { EM_X + EM_B + 11.5, EM_Y + 1.5 }, force = "player",
			raise_built = true }
		st.chest.insert{ name = EM_PLANT, count = 1 }
		--- issue #342: D, a second robot network (its logistic area apart from B's)
		st.d = {}
		for i, m in pairs(EM_D) do st.d[i] = em_mine(s, m[2], m[1], EM_D_Y, m[3]) end
		local dport = s.create_entity{ name = "roboport-mk1", position = { 368, -110 }, force = "player", raise_built = true }
		dport.get_inventory(defines.inventory.roboport_robot).insert{ name = "t1-construction-robot", count = 10 }
		dport.energy = 300e6
		s.create_entity{ name = "substation", position = { 372, -114 }, force = "player" }
		s.create_entity{ name = "electric-energy-interface", position = { 375, -114 }, force = "player" }
		st.dchest = s.create_entity{ name = "storage-chest", position = { 372.5, -109.5 }, force = "player", raise_built = true }
		for _, n in pairs({ "lv-dimension-miner", "mv-dimension-miner", EM_PLANT, EM_PLANT }) do st.dchest.insert{ name = n, count = 1 } end
	end)
	if not ok then fails[#fails + 1] = "electric mine test: " .. tostring(err) end
	return fails
end

function emine_test()
	local st = storage.emine
	if not st or st.done then return end
	local t, s, problems = game.tick, game.surfaces[1], {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	local function around_kept(list, site)
		local kept = 0
		for _, e in pairs(list) do if e.valid then kept = kept + 1 end end
		expect(kept == #list, site .. ": " .. kept .. " of " .. #list .. " neighbouring inserters and belts stayed")
	end
	local function items_back(found, site)
		for name, n in pairs(EM_ITEMS) do
			expect((found[name] or 0) == n, site .. ": " .. (found[name] or 0) .. " of " .. n .. " " .. name .. " came back")
		end
	end
	if st.phase == 0 and t >= 20 then
		local mm = prototypes.entity["dimension-mine"]
		for i = 1, #EM_CHAIN - 1 do
			local e = prototypes.entity[EM_CHAIN[i]]
			expect(e.next_upgrade and e.next_upgrade.name == EM_CHAIN[i + 1], EM_CHAIN[i] .. "'s next upgrade is "
				.. tostring(e.next_upgrade and e.next_upgrade.name) .. ", not " .. EM_CHAIN[i + 1])
			expect(e.fast_replaceable_group == mm.fast_replaceable_group, EM_CHAIN[i + 1] .. " is not in the manual mine's"
				.. " fast replace group")
		end
		--- C (issue #337): fast replace with the HV Miner, the iron vein's Miner twin with its mining pipe (issue #393: one per vein)
		local okc, miner = pcall(function()
			return s.create_entity{ name = "hv-dimension-miner", position = st.c.position, force = "player", fast_replace = true,
				spill = true, raise_built = true }
		end)
		expect(okc and miner and miner.valid and miner.name == "hv-dimension-miner", "fast replace: no HV Miner built (" .. tostring(miner) .. ")")
		if okc and miner and miner.valid then
			st.miner = miner
			miner.set_recipe("miner-copper-tin-vein")
			expect(miner.get_inventory(defines.inventory.crafter_input).insert{ name = "mining-pipe", count = 1 } == 1,
				"the HV Miner took no mining pipes")
		end
		--- A: fast replace
		local pos = st.a.position
		local ok, plant = pcall(function()
			return s.create_entity{ name = EM_PLANT, position = pos, force = "player", fast_replace = true, spill = true,
				raise_built = true }
		end)
		expect(ok and plant and plant.valid and plant.name == EM_PLANT, "fast replace: no Mk I built (" .. tostring(plant) .. ")")
		expect(not st.a.valid, "fast replace: the manual mine is still there")
		if ok and plant and plant.valid then
			st.plant = plant
			around_kept(st.a_around, "fast replace")
			local area = { { pos.x - 6, pos.y - 6 }, { pos.x + 6, pos.y + 6 } }
			items_back(em_items_in(s.find_entities_filtered{ area = area, type = "item-entity" }), "fast replace")
			expect(plant.get_recipe() == nil, "fast replace: the Mk I kept a recipe")
			plant.set_recipe("drilling-copper-tin-vein")
			expect(plant.insert_fluid{ name = "drilling-fluid", amount = 400 } == 400, "the Mk I took no drilling fluid")
			--- issue #341: the plant takes mining pipes like the miners (used up, issue #346; one per vein, #393)
			expect(plant.get_inventory(defines.inventory.crafter_input).insert{ name = "mining-pipe", count = 1 } == 1,
				"the Mk I took no mining pipes")
		end
		--- issue #342, E: the chain by script, each step noted first as on_pre_build does for a player
		local e = em_mine(s, "dimension-mine", EM_X, EM_E_Y, "mining-copper-tin-vein")
		st.e_chain = {}
		for _, name in pairs({ "lv-dimension-miner", "mv-dimension-miner", EM_PLANT }) do
			remote.call("fork-electric-mine", "note_replace", e)
			e = s.create_entity{ name = name, position = { EM_X, EM_E_Y }, force = "player", fast_replace = true, spill = true,
				raise_built = true }
			st.e_chain[#st.e_chain + 1] = tostring(em_recipe(e))
		end
		expect(table.concat(st.e_chain, ",") == "miner-copper-tin-vein,miner-copper-tin-vein,drilling-copper-tin-vein",
			"replaced by script: the recipes were " .. table.concat(st.e_chain, ", "))
		local h = em_mine(s, "dimension-mine", EM_X + 10, EM_E_Y, "mining-glowstone-vein")
		remote.call("fork-electric-mine", "note_replace", h)
		h = s.create_entity{ name = EM_PLANT, position = { EM_X + 10, EM_E_Y }, force = "player", fast_replace = true,
			spill = true, raise_built = true }
		expect(h and h.valid and em_recipe(h) == nil, "hunting blazes replaced by a Mk I: recipe " .. tostring(em_recipe(h)))
		local labor = em_items_in(s.find_entities_filtered{ area = { { EM_X + 6, EM_E_Y - 4 }, { EM_X + 14, EM_E_Y + 4 } },
			type = "item-entity" })["manual-labor"] or 0
		expect(labor == EM_LABOR, "hunting blazes replaced by a Mk I: " .. labor .. " of " .. EM_LABOR .. " manual labor came back")
		--- issue #342, D: order_upgrade (on_marked_for_upgrade) and the robots
		for i, m in pairs(EM_D) do st.d[i].order_upgrade{ target = m[4], force = "player" } end
		--- B: the upgrade planner
		local inv = game.create_inventory(1)
		inv.insert{ name = "upgrade-planner" }
		local planner = inv[1]
		planner.set_mapper(1, "from", { type = "entity", name = "dimension-mine" })
		planner.set_mapper(1, "to", { type = "entity", name = EM_PLANT })
		local bp = st.b.position
		s.upgrade_area{ area = { { bp.x - 2, bp.y - 2 }, { bp.x + 2, bp.y + 2 } }, force = "player", item = planner }
		expect(st.b.to_be_upgraded(), "upgrade planner: the manual mine is not marked for the upgrade")
		inv.destroy()
		st.phase, st.t1 = 1, t
	elseif st.phase == 1 then
		local bp = { EM_X + EM_B, EM_Y }
		local b = s.find_entity(EM_PLANT, bp)
		local back = em_items_in({ st.chest })
		local all_back = b and (back["dimension-mine"] or 0) == 1
		for name, n in pairs(EM_ITEMS) do all_back = all_back and (back[name] or 0) == n end
		local drilled = st.plant and st.plant.valid and st.plant.get_inventory(defines.inventory.crafter_output)
			.get_item_count("raw-copper") or 0
		local mout = st.miner and st.miner.valid and st.miner.get_inventory(defines.inventory.crafter_output)
		local mined = mout and mout.get_item_count("raw-copper") or 0
		local pipes = st.miner and st.miner.valid and st.miner.get_item_count("mining-pipe") or 0
		local d_done = true
		for _, m in pairs(EM_D) do if not s.find_entity(m[4], { m[1], EM_D_Y }) then d_done = false end end
		if (all_back and drilled >= EM_ORES and mined >= EM_ORES and d_done) or t >= st.t1 + 1200 then
			--- issue #342: the recipes after the robots' upgrades
			expect(em_recipe(b) == "drilling-copper-tin-vein", "upgrade planner: the Mk I's recipe is " .. tostring(em_recipe(b)))
			for _, m in pairs(EM_D) do
				local new = s.find_entity(m[4], { m[1], EM_D_Y })
				expect(new ~= nil and em_recipe(new) == m[5], "robots: " .. m[2] .. " with " .. m[3] .. " -> " .. m[4] .. ": "
					.. (new and ("recipe " .. tostring(em_recipe(new))) or "not built") .. ", not " .. tostring(m[5]))
			end
			local dback = em_items_in({ st.dchest })["manual-labor"] or 0
			expect(dback == EM_LABOR, "robots: " .. dback .. " of " .. EM_LABOR .. " manual labor of the hunting mine came back")
			expect(mined == EM_ORES and pipes == 0, "the HV Miner mined " .. mined .. " raw copper and kept " .. pipes
				.. " mining pipes (" .. EM_ORES .. " in 6 s, the pipe used up; status " .. tostring(st.miner and st.miner.valid and st.miner.status) .. ")")
			st.mined = mined
			expect(b ~= nil, "upgrade planner: no Mk I at the manual mine's place after " .. (t - st.t1) .. " ticks")
			expect((back["dimension-mine"] or 0) == 1, "upgrade planner: the manual mine did not come back to the storage chest")
			items_back(back, "upgrade planner")
			around_kept(st.b_around, "upgrade planner")
			st.drilled, st.ticks = drilled, t - st.t1
			expect(drilled >= EM_ORES, "the Mk I drilled " .. drilled .. " raw copper (" .. EM_ORES .. " in 12 s with drilling fluid; status "
				.. tostring(st.plant and st.plant.valid and st.plant.status) .. ")")
			local left = st.plant and st.plant.valid and st.plant.get_item_count("mining-pipe") or 0
			expect(left == 0, "the Mk I kept " .. left .. " of its mining pipe (issue #346: used up)")
			st.done = true
		end
	end
	if st.done or #problems > 0 then
		st.done = true
		for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL electric mine test: " .. p) end
		log("DEVCHECK-RUNTIME-EMINE " .. (#problems == 0 and "ok" or "failed") .. " (fast replace and upgrade planner, "
			.. tostring(st.drilled) .. " raw copper drilled, " .. tostring(st.mined) .. " mined by the HV Miner, "
			.. tostring(st.ticks) .. " ticks)")
	end
end

script.on_event(defines.events.on_tick, function(event)
	fuel_window_tick()
	chain_tick(event.tick)
	lsc_tick(event.tick)
	cooled_load_tick(event.tick)
	if storage.mold_done then return end
	local running = false
	for i, t in pairs(TOOL_TESTS) do
		local st = (storage.mold_tests or {})[i]
		if st and not st.done then
			running = true
			tool_test_tick(t, st, event.tick)
		end
	end
	if not running then storage.mold_done = true end
end)

script.on_nth_tick(10, function()
	if not (storage.fuel and storage.fuel.done) then fuel_test() end
	if not (storage.cooled and storage.cooled.done) then cooled_test() end
	if not (storage.tiers and storage.tiers.done) then tier_test() end
	if not (storage.recipe_test and storage.recipe_test.done) then recipe_test() end
	crush_test()
	orefurnace_test()
	steam_test()
	chain_test()
	lftr_test()
	lsc_test()
	lsup_test()
	elevator_test()
	offer_test()
	melt_test()
	emine_test()
	solar_test()
	coal_boiler_test()
	torch_test()
	battery_test()
	veins_test()
	classic_test()
	drill_test()
	portal_test()
	ender_test()
	victory_test()
end)

local TEST_RADIUS = 12                                     -- chunks around { 0, 0 }; every test lies inside
local function clear_test_area(s)
	local r = TEST_RADIUS * 32
	local area = { { -r, -r }, { r + 32, r + 32 } }
	local removed, water = 0, {}
	for _, e in pairs(s.find_entities_filtered{ area = area, force = { "neutral", "enemy" } }) do
		if e.valid and e.type ~= "resource" then
			e.destroy()
			removed = removed + 1
		end
	end
	for _, t in pairs(s.find_tiles_filtered{ area = area, collision_mask = "water_tile" }) do
		water[#water + 1] = { name = "landfill", position = t.position }
	end
	s.set_tiles(water)
	s.destroy_decoratives{ area = area }
	s.peaceful_mode = true
	game.map_settings.enemy_expansion.enabled = false
	return removed, #water
end

script.on_init(function()
	local s = game.surfaces[1]
	s.always_day = true
	s.request_to_generate_chunks({ 0, 0 }, TEST_RADIUS)
	s.force_generate_chunk_requests()
	local removed, water = clear_test_area(s)
	log("DEVCHECK-RUNTIME-SEED " .. s.map_gen_settings.seed .. " (test area cleared: " .. removed .. " entities, " .. water .. " water tiles)")
	local recipe_for = {}
	for rn, r in pairs(prototypes.recipe) do recipe_for[r.categories[1]] = recipe_for[r.categories[1]] or rn end
	local x, y, placed, with_recipe, fails = -150, -150, 0, 0, {}
	--- (issue #560: the ore machines are furnaces; placed too, without a recipe)
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = { "assembling-machine", "furnace" } } }) do
		if p.items_to_place_this and #p.items_to_place_this > 0 then
			local ok, e = pcall(function()
				return s.create_entity{ name = name, position = { x, y }, force = "player", raise_built = true }
			end)
			if ok and e then
				placed = placed + 1
				for c, _ in pairs(p.crafting_categories) do
					if recipe_for[c] and pcall(function() e.set_recipe(recipe_for[c]) end) then
						with_recipe = with_recipe + 1
						break
					end
				end
				s.create_entity{ name = "electric-energy-interface", position = { x, y + 7 }, force = "player" }
				s.create_entity{ name = "substation", position = { x + 5, y + 7 }, force = "player" }
			else
				fails[#fails + 1] = name .. ": " .. tostring(e)
			end
			x = x + 14
			if x > 150 then x = -150; y = y + 14 end
		end
	end
	for _, f in pairs(setup_mold_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_power_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_fuel_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_cooled_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_tier_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_recipe_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_crush_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_orefurnace_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_steam_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_chain_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_lftr_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_lsc_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_lsup_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_elevator_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_offer_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_melt_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_emine_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_solar_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_coal_boiler_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_torch_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_battery_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_veins_test()) do fails[#fails + 1] = f end
	for _, f in pairs(setup_classic_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_drill_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_portal_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_ender_test(s)) do fails[#fails + 1] = f end
	log("DEVCHECK-RUNTIME placed=" .. placed .. " with_recipe=" .. with_recipe .. " failed=" .. #fails)
	for _, f in pairs(fails) do log("DEVCHECK-RUNTIME-FAIL " .. f) end
end)
