--------------------------------------------------------------------------------
--- FORK: ROCKETS AS THE GATE OF THE REACH TECHNOLOGIES (issue #615, the maintainer's decisions of 2026-10-27 and
--- 2026-11-01)
--- GTNH reaches the planets by rocket: the T1 rocket flies to the Moon (its HV goal), T2 to Mars, T3 to the asteroids,
--- the Jovian moons and Ross128b, T4 to Venus, T5 to Ross128ba (DimensionHelper.java). Here every Reach technology from
--- the Moon on is a `craft-item` trigger technology of its tier's rocket: crafting the rocket researches it (its
--- prerequisites researched). A new technology per tier, Tier N Rocketry, takes the units and prerequisites the Reach
--- technology had and unlocks the rocket and its new parts; Reach the Jovian Moons and Reach Ross128 are triggered by
--- the T3 rocket as well (no units of their own now, a rocket each).
--- Recipes: GTNH's (the NEI dump of GTNH daily 2026-10-28+804, #714: Galacticraft's and GalaxySpace's NASA workbench
--- rockets T1 to T5 and the assembler, implosion compressor and assembly line recipes of their parts), in the assembler
--- of the recipe's GT tier (time = GT seconds x the tier's speed); the NASA workbench rockets and the shaped landers
--- have no tier: the assembler of their Reach technology's tier, 20 s. Heavy duty plates: GT's 8 TNT -> 1 explosive
--- (155's rule).
--- Galacticraft's, GalaxySpace's, OpenComputers' and ProjectRed's other items are stand-ins (the maintainer's
--- decision):
---   * a compressed plate (GT: a triple plate + 2 TNT) -> the triple plate; a compressed dual plate -> the dense plate;
---     meteoric iron (no Gregtorio material) -> iron; quantium plates (Gregtorio's quantium is UHV, the T5 rocket ZPM)
---     -> quantium dust, 3 per compressed plate (24 for the T5 ingot, 6 for a dual plate); the T2 ingot's tungstensteel
---     (Gregtorio's tungsten comes from Mars) -> titanium; the canvas -> a polyethylene sheet; the buggy seat (bounce
---     pads, compressed steel) -> rubber sheets and triple steel plates; the steel pole -> a long steel rod; the
---     inverted red cage lamp -> the lamp; the frequency module -> an HV sensor; the activity detector cover -> an LV
---     sensor; the blank fuel tank and the filled fuel canister -> the Empty Canister (its fuel: diesel, GT's fuel);
---   * named items: the Compressed Ice Plate (GTNH: compressed ledox + compressed callisto ice plate in coolant; here a
---     triple ledox plate and callisto ice dust), the Compressed Alloy "SDHC-120" (GTNH: dual bronze + dual aluminium +
---     compressed coal in stainless steel, then the implosion compressor; here one assembler step with coal), the
---     Parachute (canvas -> polyethylene sheets), the Flight Computer Case T1/T2 (OpenComputers' computer case with its
---     keyboard and display: GT's machine casing, plates, rotors, item casings, a computer monitor, circuits,
---     polyethylene).
--- Old saves keep their researched Reach technologies; migrations/2026-11-01-issue-615-rockets.lua researches the Tier
--- N Rocketry technology of every researched Reach technology.
--------------------------------------------------------------------------------

local ICON = "__gregtorio-continued__/graphics/icons/"
local CAT = { lv = "lv-assembling-machine-recipes", mv = "mv-assembling-machine-recipes",
	hv = "hv-assembling-machine-recipes", ev = "ev-assembling-machine-recipes", iv = "iv-assembling-machine-recipes",
	luv = "luv-assembling-machine-recipes", zpm = "zpm-assembling-machine-recipes" }
local SPEED = { lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED, iv = IV_SPEED, luv = LUV_SPEED,
	zpm = ZPM_SPEED }
local IMPLOSION = "lv-implosion-compressor-recipes"
local SUBGROUP = "subgroup-fork-rockets"

--- the Reach technologies a rocket tier gates; the first one's units and prerequisites go to Tier N Rocketry
local TIERS = {
	{ tier = "hv", reach = { "reach-the-moon" } },
	{ tier = "ev", reach = { "reach-mars" } },
	{ tier = "iv", reach = { "reach-the-asteroid-belt", "reach-the-jovian-moons", "reach-ross128" } },
	{ tier = "luv", reach = { "reach-venus" } },
	{ tier = "zpm", reach = { "reach-ross128ba" } },
}

data:extend({ { type = "item-subgroup", name = SUBGROUP, group = data.raw["item-subgroup"]["subgroup-mining"].group,
	order = (data.raw["item-subgroup"]["subgroup-mining"].order or "") .. "-rockets" } })

local made = {}       -- the items of this file
local order = 0
--- one item and its recipe; `tech` collects the recipe
local function part(name, cat, seconds, ingredients, tech, results)
	order = order + 1
	if not data.raw.item[name] then
		create_item{ skip_recipe = true, name = name, subgroup = SUBGROUP, order = string.format("a%03d", order),
			stack_size = name:match("rocket$") and 1 or 64 }
	end
	local ing = {}
	for _, i in pairs(ingredients) do
		assert(data.raw.item[i[1]] or data.raw.fluid[i[1]], "FORK-ROCKETS: no item or fluid " .. i[1])
		ing[#ing + 1] = { type = data.raw.fluid[i[1]] and "fluid" or "item", name = i[1], amount = i[2] }
	end
	local res = { { type = "item", name = name, amount = 1 } }
	for _, r in pairs(results or {}) do res[#res + 1] = { type = "item", name = r[1], amount = r[2] } end
	create_recipe{ recipe_name = name, category = cat, subgroup = SUBGROUP, energy_required = seconds, ingredients = ing,
		results = res, main_product = name }
	made[name] = true
	tech.recipes[#tech.recipes + 1] = name
end
--- an assembler recipe of GT's tier `t`: GT seconds x the tier's speed
local function asm(name, t, gt_seconds, ingredients, tech)
	part(name, CAT[t], gt_seconds * SPEED[t], ingredients, tech)
end
--- a heavy duty plate: GT's implosion of its ingot with 8 TNT per tier (one explosive each), 1 s; GT's tiny piles
local function plate(n, tech, tiny, count)
	part("heavy-duty-plate-t" .. n, IMPLOSION, LV_SPEED * 1,
		{ { "heavy-duty-alloy-ingot-t" .. n, 1 }, { "explosives", n } }, tech, tiny and { { tiny, count } })
end

local T = {}
for i, x in pairs(TIERS) do
	local later = {}
	for j = i, #TIERS do for _, r in pairs(TIERS[j].reach) do later[r] = true end end
	T[i] = { recipes = {}, tier = x.tier, later = later }
end

--------------------------------------------------------------------------------
--- T1 (HV, Reach the Moon)
--------------------------------------------------------------------------------
asm("heavy-duty-alloy-ingot-t1", "hv", 15, { { "triple-bronze-plate", 1 }, { "triple-aluminium-plate", 1 },
	{ "triple-steel-plate", 1 }, { "molten-stainless-steel", 7.2 } }, T[1])
plate(1, T[1], "tiny-pile-of-stainless-steel-dust", 1)
asm("compressed-sdhc-120-alloy", "lv", 1, { { "dense-bronze-plate", 1 }, { "dense-aluminium-plate", 1 },
	{ "coal", 9 }, { "molten-stainless-steel", 7.2 } }, T[1])
asm("empty-fuel-canister", "lv", 10, { { "triple-steel-plate", 4 }, { "steel-ring", 4 } }, T[1])
asm("oxygen-vent", "mv", 1, { { "triple-tin-plate", 4 }, { "triple-steel-plate", 1 }, { "steel-rod", 4 } }, T[1])
asm("tier-1-rocket-engine", "lv", 5, { { "compressed-sdhc-120-alloy", 2 }, { "heavy-duty-plate-t1", 4 },
	{ "empty-fuel-canister", 1 }, { "steel-firebox-casing", 1 }, { "lv-sensor", 1 } }, T[1])
asm("tier-1-booster", "lv", 2.5, { { "triple-iron-plate", 3 }, { "heavy-duty-plate-t1", 4 }, { "oxygen-vent", 1 },
	{ "diesel", 100 } }, T[1])
asm("nose-cone", "lv", 2.5, { { "small-lamp", 1 }, { "heavy-duty-plate-t1", 4 }, { "molten-stainless-steel", 3.6 } },
	T[1])
asm("rocket-fins", "lv", 2.5, { { "triple-steel-plate", 2 }, { "heavy-duty-plate-t1", 4 } }, T[1])
asm("small-fuel-canister", "lv", 1, { { "dense-bronze-plate", 1 }, { "dense-aluminium-plate", 1 },
	{ "empty-fuel-canister", 1 }, { "molten-stainless-steel", 7.2 } }, T[1])
asm("flight-computer-case-t1", "mv", 10, { { "mv-machine-casing", 1 }, { "aluminium-plate", 2 },
	{ "plastic-circuit-board", 1 }, { "electronic-circuit", 3 }, { "aluminium-rotor", 2 },
	{ "aluminium-item-casing", 3 }, { "computer-monitor", 1 }, { "iron-screw", 2 }, { "tin-cable", 1 },
	{ "polyethylene", 21.6 } }, T[1])
asm("rocket-control-computer-t1", "hv", 30, { { "flight-computer-case-t1", 1 }, { "hv-emitter", 1 },
	{ "hv-sensor", 1 }, { "heavy-duty-plate-t1", 1 }, { "soldering-alloy", 57.6 } }, T[1])
asm("lander-t1", "hv", 20, { { "hv-sensor", 1 }, { "triple-steel-plate", 8 }, { "long-steel-rod", 2 },
	{ "rubber-sheet", 3 }, { "tier-1-rocket-engine", 1 }, { "triple-copper-plate", 1 } }, T[1])
asm("tier-1-rocket", "hv", 20, { { "lander-t1", 1 }, { "rocket-control-computer-t1", 1 },
	{ "small-fuel-canister", 2 }, { "nose-cone", 1 }, { "heavy-duty-plate-t1", 8 }, { "tier-1-rocket-engine", 1 },
	{ "rocket-fins", 4 } }, T[1])

--------------------------------------------------------------------------------
--- T2 (EV, Reach Mars)
--------------------------------------------------------------------------------
--- (GT: 72 L tungstensteel; Gregtorio's tungsten comes from Mars, so titanium stands in)
asm("heavy-duty-alloy-ingot-t2", "ev", 15, { { "heavy-duty-plate-t1", 1 }, { "iron-plate", 2 },
	{ "molten-titanium", 7.2 } }, T[2])
plate(2, T[2], "tiny-pile-of-tungstensteel-dust", 2)
asm("parachute", "hv", 15, { { "polyethylene-sheet", 4 }, { "fine-steel-wire", 3 } }, T[2])
asm("rocket-control-computer-t2", "ev", 30, { { "flight-computer-case-t1", 1 }, { "ev-field-generator", 2 },
	{ "heavy-duty-plate-t2", 1 }, { "soldering-alloy", 86.4 } }, T[2])
asm("lander-t2", "ev", 20, { { "gold-foil", 4 }, { "polyethylene-sheet", 3 }, { "parachute", 1 }, { "lander-t1", 1 } },
	T[2])
asm("tier-2-rocket", "ev", 20, { { "lander-t2", 1 }, { "rocket-control-computer-t2", 1 },
	{ "small-fuel-canister", 3 }, { "nose-cone", 1 }, { "heavy-duty-plate-t2", 10 }, { "tier-1-rocket-engine", 2 },
	{ "rocket-fins", 4 }, { "tier-1-booster", 2 } }, T[2])

--------------------------------------------------------------------------------
--- T3 (IV, Reach the Asteroid Belt, the Jovian Moons and Ross128)
--------------------------------------------------------------------------------
asm("heavy-duty-alloy-ingot-t3", "iv", 15, { { "heavy-duty-plate-t1", 1 }, { "desh-plate", 4 },
	{ "molten-platinum", 7.2 } }, T[3])
plate(3, T[3])
asm("heavy-nose-cone", "mv", 2.5, { { "nose-cone", 1 }, { "heavy-duty-plate-t3", 4 }, { "molten-titanium", 3.6 } },
	T[3])
asm("heavy-rocket-engine", "mv", 5, { { "tier-1-booster", 2 }, { "tier-1-rocket-engine", 2 },
	{ "heavy-duty-plate-t3", 5 } }, T[3])
asm("heavy-rocket-fins", "mv", 2.5, { { "heavy-duty-plate-t2", 2 }, { "heavy-duty-plate-t3", 4 } }, T[3])
asm("medium-fuel-canister", "mv", 1, { { "small-fuel-canister", 1 }, { "dense-titanium-plate", 1 },
	{ "dense-desh-plate", 1 }, { "molten-titanium", 7.2 } }, T[3])
asm("rocket-control-computer-t3", "iv", 30, { { "flight-computer-case-t1", 1 }, { "iv-emitter", 1 },
	{ "iv-sensor", 1 }, { "heavy-duty-plate-t3", 1 }, { "soldering-alloy", 115.2 } }, T[3])
asm("lander-t3", "iv", 20, { { "dense-desh-plate", 6 }, { "long-steel-rod", 2 }, { "lander-t2", 1 } }, T[3])
asm("tier-3-rocket", "iv", 20, { { "lander-t3", 1 }, { "rocket-control-computer-t3", 1 },
	{ "small-fuel-canister", 2 }, { "medium-fuel-canister", 2 }, { "heavy-nose-cone", 1 }, { "heavy-duty-plate-t2", 2 },
	{ "heavy-duty-plate-t3", 12 }, { "heavy-rocket-engine", 1 }, { "heavy-rocket-fins", 4 }, { "tier-1-booster", 2 } },
	T[3])

--------------------------------------------------------------------------------
--- T4 (LuV, Reach Venus)
--------------------------------------------------------------------------------
asm("compressed-ice-plate", "iv", 15, { { "triple-ledox-plate", 1 }, { "callisto-ice-dust", 9 }, { "coolant", 100 } },
	T[4])
part("heavy-duty-alloy-ingot-t4", "luv-assembly-line-recipes", 15 * LUV_SPEED, { { "heavy-duty-plate-t1", 1 },
	{ "compressed-ice-plate", 6 }, { "ruridit-bolt", 4 }, { "molten-indalloy-140", 3.6 } }, T[4])
plate(4, T[4], "tiny-pile-of-ruridit-dust", 4)
asm("flight-computer-case-t2", "hv", 10, { { "hv-machine-casing", 1 }, { "aluminium-plate", 2 },
	{ "epoxy-circuit-board", 1 }, { "advanced-circuit", 1 }, { "electronic-circuit", 2 }, { "aluminium-rotor", 2 },
	{ "aluminium-item-casing", 3 }, { "computer-monitor", 1 }, { "iron-screw", 2 }, { "tin-cable", 1 },
	{ "polyethylene", 21.6 } }, T[4])
asm("rocket-control-computer-t4", "iv", 30, { { "flight-computer-case-t2", 1 }, { "iv-emitter", 1 },
	{ "iv-sensor", 1 }, { "heavy-duty-plate-t4", 1 }, { "soldering-alloy", 172.8 } }, T[4])
asm("tier-4-rocket", "luv", 20, { { "lander-t3", 1 }, { "rocket-control-computer-t4", 1 },
	{ "medium-fuel-canister", 4 }, { "heavy-nose-cone", 1 }, { "heavy-duty-plate-t4", 12 }, { "heavy-rocket-engine", 2 },
	{ "heavy-rocket-fins", 6 }, { "tier-1-booster", 4 } }, T[4])

--------------------------------------------------------------------------------
--- T5 (ZPM, Reach Ross128ba)
--------------------------------------------------------------------------------
part("heavy-duty-alloy-ingot-t5", "zpm-assembly-line-recipes", 15 * ZPM_SPEED, { { "heavy-duty-plate-t4", 1 },
	{ "quantium-dust", 24 }, { "europium-bolt", 8 }, { "molten-indalloy-140", 7.2 } }, T[5])
plate(5, T[5], "tiny-pile-of-europium-dust", 5)
asm("tier-2-booster", "mv", 2.5, { { "triple-ledox-plate", 3 }, { "heavy-duty-plate-t3", 4 }, { "tier-1-booster", 1 },
	{ "compressed-sdhc-120-alloy", 1 } }, T[5])
asm("heavy-duty-nose-cone-t3", "hv", 2.5, { { "heavy-nose-cone", 1 }, { "heavy-duty-plate-t5", 4 },
	{ "molten-tungstensteel", 3.6 } }, T[5])
asm("heavy-duty-rocket-engine-t3", "hv", 5, { { "tier-2-booster", 2 }, { "heavy-rocket-engine", 2 },
	{ "heavy-duty-plate-t5", 5 } }, T[5])
asm("heavy-duty-rocket-fins-t3", "hv", 2.5, { { "heavy-duty-plate-t4", 2 }, { "heavy-duty-plate-t5", 4 },
	{ "compressed-sdhc-120-alloy", 1 } }, T[5])
asm("large-fuel-canister", "hv", 1, { { "medium-fuel-canister", 1 }, { "quantium-dust", 6 },
	{ "compressed-ice-plate", 2 }, { "molten-chrome", 7.2 } }, T[5])
asm("rocket-control-computer-t5", "luv", 30, { { "flight-computer-case-t2", 1 }, { "luv-emitter", 1 },
	{ "luv-sensor", 1 }, { "heavy-duty-plate-t5", 1 }, { "soldering-alloy", 230.4 } }, T[5])
asm("tier-5-rocket", "zpm", 20, { { "lander-t3", 1 }, { "rocket-control-computer-t5", 1 },
	{ "medium-fuel-canister", 2 }, { "large-fuel-canister", 2 }, { "heavy-duty-nose-cone-t3", 1 },
	{ "heavy-duty-plate-t5", 12 }, { "heavy-duty-rocket-engine-t3", 4 }, { "heavy-duty-rocket-fins-t3", 6 },
	{ "tier-2-booster", 4 } }, T[5])

--------------------------------------------------------------------------------
--- the technologies: Tier N Rocketry (the units and prerequisites of the tier's first Reach technology; the first
--- technology of every outside ingredient comes in data-final-fixes.lua, FORK_ROCKETS.prerequisites()); the Reach
--- technologies become craft-item triggers of the rocket
--------------------------------------------------------------------------------
local rocketry = {}
for i, x in pairs(TIERS) do
	local reach = data.raw.technology[x.reach[1]]
	local name = "tier-" .. i .. "-rocketry"
	local pre = {}
	for _, p in pairs(reach.prerequisites or {}) do pre[p] = true end
	for j = 1, i - 1 do pre["tier-" .. j .. "-rocketry"] = nil end
	if i > 1 then pre["tier-" .. (i - 1) .. "-rocketry"] = true end
	--- (a Reach technology of this tier, or an earlier one, cannot be a prerequisite of its own rocketry: it needs the rocket)
	for _, r in pairs(x.reach) do pre[r] = nil end
	local list = {}
	for p in pairs(pre) do list[#list + 1] = p end
	table.sort(list)
	local effects = {}
	for _, r in pairs(T[i].recipes) do effects[#effects + 1] = { type = "unlock-recipe", recipe = r } end
	data:extend({ {
		type = "technology", name = name, icon = ICON .. "tier-" .. i .. "-rocket.png", icon_size = 32,
		effects = effects, prerequisites = list, unit = reach.unit,
	} })
	--- (149's last rescale would divide the copied, already divided units again)
	if FORK_EARLY_RESEARCH then FORK_EARLY_RESEARCH.seen[name] = reach.unit end
	rocketry[i] = name
	for _, r in pairs(x.reach) do
		local t = data.raw.technology[r]
		local rp = {}
		for _, p in pairs(t.prerequisites or {}) do rp[p] = true end
		rp[name] = true
		local rl = {}
		for p in pairs(rp) do rl[#rl + 1] = p end
		table.sort(rl)
		t.prerequisites = rl
		t.unit = nil
		t.research_trigger = { type = "craft-item", item = "tier-" .. i .. "-rocket" }
	end
	FORK_TRIGGER_ONLY_ITEMS["tier-" .. i .. "-rocket"] = "issue #615: crafting the tier's rocket researches its Reach "
		.. "technologies (" .. table.concat(x.reach, ", ") .. ")"
end

data:extend({ { type = "mod-data", name = "fork-rockets", data = { rocketry = rocketry, reach = (function()
	local m = {}
	for i, x in pairs(TIERS) do for _, r in pairs(x.reach) do m[r] = rocketry[i] end end
	return m
end)() } } })

--------------------------------------------------------------------------------
--- FORK_ROCKETS.prerequisites(), called by data-final-fixes.lua once the vanilla technologies are disabled and the
--- unlocks are final (before 149's last rescale and 142's FORK_UNLOCK_TREE.apply): each Tier N Rocketry gets the
--- technology of the lowest science (then by name) that unlocks a recipe of every outside ingredient of its recipes,
--- leaving out a disabled or hidden technology and one that needs a Reach technology of this tier or a later one (that
--- would close a loop through the rocket: Gregtorio's tungsten comes from Mars, for one)
--------------------------------------------------------------------------------
FORK_ROCKETS = { tiers = T, rocketry = rocketry, made = made }
function FORK_ROCKETS.prerequisites()
	--- the science rank of a technology: the highest pack of its unit (0: a trigger technology or a red one)
	local PACKS = { "automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack",
		"production-science-pack", "utility-science-pack", "space-science-pack", "metallurgic-science-pack",
		"agricultural-science-pack", "electromagnetic-science-pack", "cryogenic-science-pack", "promethium-science-pack",
		"umv-science-pack", "uxv-science-pack", "max-science-pack" }
	local RANK = {}
	for i, p in pairs(PACKS) do RANK[p] = i end
	local function rank(tn)
		local t = data.raw.technology[tn]
		local r = 0
		for _, i in pairs(t and t.unit and t.unit.ingredients or {}) do r = math.max(r, RANK[i[1] or i.name] or 0) end
		return r
	end
	--- a technology that can be researched: not disabled or hidden, nor behind such a one (vanilla's Explosives is behind
	--- Sulfur Processing and is disabled after this call, issue #640)
	local usable_memo = {}
	local function usable(tn)
		if usable_memo[tn] == nil then
			usable_memo[tn] = false
			local t = data.raw.technology[tn]
			local ok = t and t.enabled ~= false and not t.hidden
			for _, p in pairs(ok and t.prerequisites or {}) do ok = ok and usable(p) end
			usable_memo[tn] = ok and true or false
		end
		return usable_memo[tn]
	end
	--- the technologies of every recipe that makes an item (as 173); nil: from the start
	local unlocked_by = {}
	for tn, tech in pairs(data.raw.technology) do
		if usable(tn) then for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" then unlocked_by[e.recipe] = unlocked_by[e.recipe] or {}; table.insert(unlocked_by[e.recipe], tn) end
		end end
	end
	local function item_techs(name)
		local out = {}
		for rname, r in pairs(data.raw.recipe) do
			if not r.hidden and not rname:match("recycling") then
				for _, res in pairs(r.results or {}) do
					if res.name == name then
						if r.enabled ~= false then return nil end
						for _, tn in pairs(unlocked_by[rname] or {}) do out[#out + 1] = tn end
					end
				end
			end
		end
		return out
	end
	--- the technologies of every machine that crafts a category (by its item)
	local function machine_techs(cat)
		local out = {}
		for _, kind in pairs({ "assembling-machine", "furnace" }) do
			for en, e in pairs(data.raw[kind]) do
				for _, c in pairs(e.crafting_categories or {}) do
					if c == cat then
						local g = item_techs(en)
						if g == nil then return nil end
						for _, t in pairs(g) do out[#out + 1] = t end
					end
				end
			end
		end
		return out
	end
	--- whether a technology needs (through its prerequisites) one of the Reach technologies `later` (a set)
	local closures = {}
	local function closure(tn)
		if not closures[tn] then
			closures[tn] = {}
			local c = { [tn] = true }
			for _, p in pairs(data.raw.technology[tn] and data.raw.technology[tn].prerequisites or {}) do
				for q in pairs(closure(p)) do c[q] = true end
			end
			closures[tn] = c
		end
		return closures[tn]
	end
	local function needs_reach(tn, later)
		for r in pairs(later) do if closure(tn)[r] then return true end end
		return false
	end
	for i, tier in pairs(T) do
		local tech = data.raw.technology[rocketry[i]]
		local pre = {}
		for _, p in pairs(tech.prerequisites or {}) do pre[p] = true end
		for _, rn in pairs(tier.recipes) do
			local needs = {}
			for _, ing in pairs(data.raw.recipe[rn].ingredients) do
				if not made[ing.name] then needs[#needs + 1] = item_techs(ing.name) end
			end
			--- the machines of the recipe's category (the assembly lines come later than the assemblers)
			needs[#needs + 1] = machine_techs(data.raw.recipe[rn].categories[1])
			for _, g in pairs(needs) do
				if g and g[1] then
					table.sort(g, function(a, b) local ra, rb = rank(a), rank(b) if ra ~= rb then return ra < rb end return a < b end)
					local pick
					for _, t in pairs(g) do
						if not needs_reach(t, tier.later) then pick = t break end
					end
					assert(pick, "FORK-ROCKETS: every technology of an input of " .. rn .. " needs a Reach technology of its rocket")
					pre[pick] = true
				end
			end
		end
		--- (a prerequisite that another one already needs is left out)
		local list = {}
		for p in pairs(pre) do
			local implied = false
			for q in pairs(pre) do if q ~= p and closure(q)[p] then implied = true break end end
			if not implied then list[#list + 1] = p end
		end
		table.sort(list)
		tech.prerequisites = list
		log("FORK-ROCKETS: " .. rocketry[i] .. " after " .. table.concat(list, ", "))
	end
end
