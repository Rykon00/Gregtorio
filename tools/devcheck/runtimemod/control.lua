--- Places every assembling machine that has an item, gives it a recipe and power, then lets
--- the benchmark run the map. Any runtime error in Gregtorio's scripts or the entities fails
--- the run. Results are logged as DEVCHECK-RUNTIME lines.
--- The ME network's runtime tests are in the mod me-network since issue #83 (its tools/devcheck).
--- Molds (prototypes/150-fork-molds.lua): an LV alloy smelter with a mold recipe must stop
--- without a mold, run with a mold in its mold slot and keep the mold there.
--- Endgame power (prototypes/136-fork-power.lua): a plasma turbine and a naquadah reactor under load
--- must burn their fuel and make power; the turbine's output hatch gets the cooled fluid.
--- Fuel check (issue #25): steam and the other generator's fuel stop a generator; the right fuel runs it.
--- Turbine tiers (issue #34): the UHV to UXV plasma turbines under an overload give exactly four amps of
--- their tier and return the cooled fluid of the plasma they burnt.
--- Recipes of issue #35: grades 7 and 8, FPIC/APIC wafers and chips, complex SMDs and the recipes that
--- use them are crafted once each (setup_recipe_test).
--- Steam turbines (issue #97): the large and the high pressure steam turbine make their GT output, burn their GT flow
--- and give back distilled water and steam through output hatches; the wrong steam stops them; the multiblocks of
--- issue #97 can be blueprinted and mined.
--- Nuclear chain (issue #97): fluid nuclear reactor -> large heat exchanger -> high pressure steam turbine -> large
--- steam turbine makes power from fuel rods; depleted rods come out; the steam recipe of the heat exchanger is exact.
--- Lapotronic supercapacitor (issue #97): charges and discharges at two amps of its tier, holds its capacity by tier
--- and loses GT's 1 % per day.
--- Offered recipes (issue #126): the machine recipes that were hidden from the crafting menu are offered by the machines.
--- Melts and casts (issue #117): nine melted ingots fill one block cast, one fills an ingot cast; n melts cover every cast combination.
--- Supercapacitor upgrade (issue #124): a replaced supercapacitor keeps its charge (capped at the new capacity).
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
	check(storage.steam and storage.steam.done, "steam turbines")
	check(storage.chain and storage.chain.done, "nuclear chain")
	check(storage.lsc and storage.lsc.done, "supercapacitor")
	check(storage.lsup and storage.lsup.done, "supercapacitor upgrade")
	check(storage.offer and storage.offer.done, "recipes offered by machines")
	check(storage.melt and storage.melt.done, "melts and casts")
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
	--- an input-output fluid box keeps part of its fluid in the pipeline segment, which
	--- get_fluid_count does not report
	local function fluid_in(e, fluid)
		local seg = e.fluidbox.get_fluid_segment_contents(1)
		return e.get_fluid_count(fluid) + ((seg and seg[fluid]) or 0)
	end
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

--- an input-output fluid box keeps part of its fluid in the pipeline segment (see the power test)
local function fc_fluid_in(e, fluid)
	local seg = e.fluidbox.get_fluid_segment_contents(1)
	return e.get_fluid_count(fluid) + ((seg and seg[fluid]) or 0)
end

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
	g.remove_fluid{ name = def[6], amount = 1e9 }
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
				g.remove_fluid{ name = def[4], amount = 1e9 }
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
		local seg = c.g.fluidbox.get_fluid_segment_contents(1)
		local burnt = def[4] - c.g.get_fluid_count(def[3]) - ((seg and seg[def[3]]) or 0)
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
			fh.removed = fh.removed + fh.h.remove_fluid{ name = "helium", amount = 4000 }
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
			local seg = c.g.fluidbox.get_fluid_segment_contents(1)
			local burnt = def[4] - c.g.get_fluid_count(def[3]) - ((seg and seg[def[3]]) or 0)
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
	{ "iv-extractor", "molten-quantium" },
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
	-- (ender tank, component assembly line), a microminer mission and recipes that were never unlocked
	{ "lv-alloy-smelter", "signalum-ingot" },
	{ "ev-electric-blast-furnace", "naquadah-doped-monocrystaline-silicon-boule" },
	{ "mv-pyrolyse-oven", "charcoal-byproducts" },
	{ "ev-large-chemical-reactor", "cyanoacetic-acid" },
	{ "iv-large-chemical-reactor", "super-glue" },
	{ "nether-air-ender-tank", "nether-air-collection" },
	{ "component-assembly-line", "lv-motor-coal" },
	{ "lv-assembling-machine", "microminer-neutronium" },
	-- issue #126 (prototypes/148-fork-gtnh-table-items.lua): GTNH's machine recipes of the items the crafting table made
	{ "lv-fluid-solidifier", "anvil-fluid-solidifier" },
	{ "mv-alloy-smelter", "anvil-alloy-smelter" },
	{ "lv-assembling-machine", "firebrick-block-assembling-machine" },
	{ "lv-chemical-bath", "paper-chemical-bath" },
	-- issue #126, part B: the vanilla hand-only recipes in the assembling machines
	{ "lv-assembling-machine", "firearm-magazine" },
	{ "lv-assembling-machine", "light-armor" },
	{ "lv-assembling-machine", "rail-ramp" },
	{ "lv-assembling-machine", "rail-support" },
	{ "lv-assembling-machine", "wood-processing" },
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
	{ "lv-extractor", "melt-steel-ingot" },
	{ "ev-extractor", "melt-titanium-ingot" },
	{ "iv-extractor", "melt-iridium-ingot" },
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
			e.set_recipe(def[2])
			-- a recipe that needs a mold (prototypes/150-fork-molds.lua) gets one in the mold slot
			local molds = prototypes.mod_data["fork-mold-recipes"]
			if molds and molds.data[def[2]] then e.get_module_inventory().insert{ name = molds.data[def[2]] } end
			for _, ing in pairs(prototypes.recipe[def[2]].ingredients) do
				if ing.type == "item" then
					local n = e.insert{ name = ing.name, count = ing.amount }
					assert(n == ing.amount, "only " .. n .. " of " .. ing.amount .. " " .. ing.name .. " fit")
				else
					local n = e.insert_fluid{ name = ing.name, amount = ing.amount }
					assert(math.abs(n - ing.amount) < 1e-6, "only " .. n .. " of " .. ing.amount .. " " .. ing.name .. " fit")
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
			if made >= (p.amount or p.amount_min or 1) - 1e-6 or ((p.probability or 1) < 1 and e.products_finished > 0) then
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

local MOLD_Y = 120
local MOLD_RECIPE = "glass-alloy-smelter"
local MOLD_DEADLINE = 900                               -- ticks for the first glass with the mold in (361 needed)

function setup_mold_test(s)
	local ok, err = pcall(function()
		local eei = s.create_entity{ name = "electric-energy-interface", position = { 0, MOLD_Y }, force = "player" }
		eei.power_production = 1e6
		eei.electric_buffer_size = 1e7
		s.create_entity{ name = "substation", position = { 3, MOLD_Y }, force = "player" }
		local m = s.create_entity{ name = "lv-alloy-smelter", position = { 6, MOLD_Y }, force = "player", raise_built = true }
		m.force.recipes[MOLD_RECIPE].enabled = true
		m.set_recipe(MOLD_RECIPE)
		m.insert{ name = "glass-dust", count = 20 }
		storage.mold_machine = m
	end)
	if not ok then return { "mold test setup: " .. tostring(err) } end
	return {}
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
--- at LS_SWITCH; then a UHV air collector (40.96 MW, a recipe without ingredients, its air removed every tick) runs
--- from it. It must charge from tick LS_FROM to LS_SWITCH and discharge from LS_SWITCH + LS_FROM to LS_TICK at its
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
		ls.load = s.create_entity{ name = "uhv-air-collector", position = { LS_X + 6, LS_Y + 5 }, force = "player" }
		for name, r in pairs(prototypes.recipe) do
			if r.category == "lv-air-collector-recipes" and #r.ingredients == 0 then ls.recipe = name break end
		end
		if not ls.recipe then fails[#fails + 1] = "supercapacitor test: no air collector recipe" end
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
				if m.crafting_categories[proto.category] and m.items_to_place_this and #m.items_to_place_this > 0
						and (not best or m.get_crafting_speed() < best.get_crafting_speed()) then
					best = m
				end
			end
			assert(best, "no machine for " .. proto.category)
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
--- 2) In machines: ten ingots melted in an LV extractor, the melt of nine of them in an LV fluid solidifier on the block
---    cast (it must start with no tenth melt and make the block), the tenth one's on the ingot cast (it must make the
---    ingot); ten melts must hold at least 144.
local CT_X, CT_Y = -60, 200
local CT_DEADLINE = 900
local CT_INGOT_TENTHS = 144

local function ct_gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end

local function melt_coverage()
	local melts, casts = {}, {}
	for name, r in pairs(prototypes.recipe) do
		local c = r.category
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
		st.extractor = machine("lv-extractor", CT_X + 6, "melt-iron-ingot")
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
			local got = ex.remove_fluid{ name = "molten-iron", amount = 1000 }
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

script.on_event(defines.events.on_tick, function(event)
	fuel_window_tick()
	chain_tick(event.tick)
	lsc_tick(event.tick)
	cooled_load_tick(event.tick)
	local m = storage.mold_machine
	if storage.mold_done then return end
	local function glass_made()
		return m and m.valid and m.get_inventory(defines.inventory.crafter_output or defines.inventory.assembling_machine_output).get_item_count("glass") or 0
	end
	--- phase 2 as soon as the first glass is out, at the latest MOLD_DEADLINE ticks after the mold went in
	local phase
	if not storage.mold_phase1 and event.tick >= 60 then
		phase = 1
		storage.mold_phase1 = event.tick
	elseif storage.mold_phase1 and (glass_made() > 0 or event.tick >= storage.mold_phase1 + MOLD_DEADLINE) then
		phase = 2
		storage.mold_done = true
	else
		return
	end
	local problems = {}
	local function expect(ok, what) if not ok then problems[#problems + 1] = what end end
	expect(m and m.valid, "mold test machine missing")
	if #problems == 0 then
		local glass = glass_made()
		local inv = m.get_module_inventory()
		if phase == 1 then
			expect(m.disabled_by_script, "mold test: machine without mold is not stopped")
			expect(glass == 0, "mold test: crafted " .. glass .. " glass without a mold")
			expect(inv and inv.insert{ name = "mold", count = 1 } == 1, "mold test: mold does not fit into the mold slot")
		else
			expect(not m.disabled_by_script, "mold test: machine with mold is still stopped")
			expect(glass > 0, "mold test: no glass crafted with the mold inserted")
			expect(inv.get_item_count("mold") == 1, "mold test: mold left the mold slot")
			expect(m.get_item_count("mold") == 1, "mold test: mold was duplicated or moved")
			log("DEVCHECK-RUNTIME-MOLD " .. (#problems == 0 and "ok" or "failed") .. " (glass " .. glass .. " after " .. (event.tick - storage.mold_phase1) .. " ticks)")
		end
	end
	for _, p in pairs(problems) do log("DEVCHECK-RUNTIME-FAIL " .. p) end
	if #problems > 0 and phase == 1 then
		storage.mold_done = true
		log("DEVCHECK-RUNTIME-MOLD failed")
	end
end)

script.on_nth_tick(10, function()
	if not (storage.fuel and storage.fuel.done) then fuel_test() end
	if not (storage.cooled and storage.cooled.done) then cooled_test() end
	if not (storage.tiers and storage.tiers.done) then tier_test() end
	if not (storage.recipe_test and storage.recipe_test.done) then recipe_test() end
	steam_test()
	chain_test()
	lsc_test()
	lsup_test()
	offer_test()
	melt_test()
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
	for rn, r in pairs(prototypes.recipe) do recipe_for[r.category] = recipe_for[r.category] or rn end
	local x, y, placed, with_recipe, fails = -150, -150, 0, 0, {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "assembling-machine" } }) do
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
	for _, f in pairs(setup_steam_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_chain_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_lsc_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_lsup_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_offer_test(s)) do fails[#fails + 1] = f end
	for _, f in pairs(setup_melt_test(s)) do fails[#fails + 1] = f end
	log("DEVCHECK-RUNTIME placed=" .. placed .. " with_recipe=" .. with_recipe .. " failed=" .. #fails)
	for _, f in pairs(fails) do log("DEVCHECK-RUNTIME-FAIL " .. f) end
end)
