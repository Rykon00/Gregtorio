--------------------------------------------------------------------------------
--- FORK FLUID STEPS (issue #117): fluid amounts of recipes on the engine's grid
--- The game stores the fluid amounts of a recipe, and what a machine holds, in steps of 2^-24 and cuts a recipe's
--- amount off at the step below it (measured, 2.0.77: 14.4 becomes 14.399999976158). Gregtorio's amounts are a tenth of
--- GT's litres (14.4 per ingot), none of them on the grid, so
---   * the extractor's output box showed 14.3 and the tooltips could not show 14.4,
---   * every amount was cut on its own: nine melted ingots (129.599999785) did not fill a block cast (129.599999964),
---     a tenth melt was needed and its rest stayed in the tank; large gears and rotors the same.
--- Every fluid amount that is not on the grid is therefore set on it here, for every recipe of the load (upstream,
--- fork, me-network, the base game's, wherever one has a fraction):
---   * what a recipe takes is rounded UP to the next step (the tooltip shows 129.6, not 129.5);
---   * what a recipe gives is rounded up to the next step and then by GIVE_STEPS more. A cast takes at most a ninth of
---     an ingot's melt (the nugget), every cast's take is up to one step above its true value, so an ingot's melt must
---     be at least nine steps above its true value for n melts to cover every combination of casts n ingots are worth
---     (checked with the casting test of the runtime check: nine ingots fill one block cast, one an ingot cast).
--- The surplus is below one millionth of a unit per melt. An amount that is on the grid (14.5, 0.0625) is left alone:
--- sums of such amounts are exact.
--- Must load after every file that creates or changes a recipe; the check of devcheck.py fails for an amount off the grid.
--------------------------------------------------------------------------------

local STEP = 2 ^ -24
local GIVE_STEPS = 9
local EPSILON = 1e-3        -- an amount within this many steps of the grid is on it (a sum like 1.44 * 10)

FORK_FLUID_STEPS = { amounts = 0, recipes = 0 }

--- the steps of an amount: nil when it is on the grid, else the steps rounded up
local function steps_up(a)
	local s = a / STEP                               -- exact: STEP is a power of two
	local r = math.floor(s + 0.5)
	if math.abs(s - r) < EPSILON then return r, true end
	return math.ceil(s), false
end

local function round_up(p, field, gives)
	local a = p[field]
	if type(a) ~= "number" then return false end
	local s, on_grid = steps_up(a)
	if on_grid then
		-- a tiny error of a sum (1.44 * 10) snapped onto the grid; the amount itself changes only then
		if s * STEP ~= a then p[field] = s * STEP; return true end
		return false
	end
	if gives then s = s + GIVE_STEPS end
	p[field] = s * STEP
	return true
end

for _, r in pairs(data.raw.recipe) do
	local changed = false
	for _, i in pairs(r.ingredients or {}) do
		if i.type == "fluid" and round_up(i, "amount", false) then
			changed = true
			FORK_FLUID_STEPS.amounts = FORK_FLUID_STEPS.amounts + 1
		end
	end
	for _, i in pairs(r.results or {}) do
		if i.type == "fluid" then
			for _, f in pairs({ "amount", "amount_min", "amount_max" }) do
				if round_up(i, f, true) then
					changed = true
					FORK_FLUID_STEPS.amounts = FORK_FLUID_STEPS.amounts + 1
				end
			end
		end
	end
	if changed then FORK_FLUID_STEPS.recipes = FORK_FLUID_STEPS.recipes + 1 end
end
log("FORK-FLUID-STEPS: " .. FORK_FLUID_STEPS.amounts .. " fluid amounts of " .. FORK_FLUID_STEPS.recipes
	.. " recipes set on the grid of 2^-24 (issue #117)")
