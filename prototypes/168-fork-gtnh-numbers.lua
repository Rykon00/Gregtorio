--------------------------------------------------------------------------------
--- FORK GTNH NUMBERS (issue #689)
--- Gregtorio's recipes are written per issue from GT's source and by generators (143's casts, 155's ore chain, 158's
--- parts) that follow GT's formulas only roughly, so 3,307 of the 10,016 recipes that have a GT New Horizons recipe with
--- the same items in and out had other numbers (`devcheck.py gtnh-diff`, #679). prototypes/data/gtnh-numbers.lua holds
--- GT's numbers of those recipes, written by `devcheck.py check --gtnh-numbers` from the recipe dump of tools/gtnh_dump/
--- through tools/gtnh_map.py; this file sets them, in Gregtorio's units:
---   t   the tier from GT's EU/t (ULV counts as LV), only downward: the recipe moves into the category of that tier of its
---       machine, which every higher machine of the kind runs as well; a higher tier needs a later machine and moves the
---       recipe's unlock (#724), and the blast furnace's tier is its coil heat (#620)
---   e   energy_required: GT's seconds x the speed of the tier (Gregtorio's rule, so a machine of the recipe's tier takes
---       GT's time), x the batch when the recipe is several GT recipes at once (16 rods -> 64 bolts)
---   i   the item ingredients, o the item results per chance (GT gives an item once sure and once by chance as two
---       results); not for a recipe whose fluids differ from GT's tenth too (#671: they would no longer fit)
--- Left out (tools/gtnh_map.py, NUMBERS_SKIP_MAPS): the crafting table's recipes (GT's tools merge recipes with and
--- without a tool, #688), 157's recycling (GT's formulas on Gregtorio's own recipes, the decision on #190) and every
--- fluid amount (#671). devcheck's `check` fails for a recipe with a GT recipe whose numbers in this scope differ from
--- GT's and that neither the table nor FORK_GTNH_NUMBERS_KEPT names, and for a table that is not what `--gtnh-numbers`
--- writes. Loads after every file that makes recipes (after 157) and before 150, 196, 197, 198 and 199.
--------------------------------------------------------------------------------

local DATA = require("prototypes.data.gtnh-numbers")
local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }

--- recipes that keep their own numbers, with the reason (devcheck fails for an entry without one or for a recipe without
--- a GT recipe of other numbers; `--gtnh-numbers` leaves them out of the table)
FORK_GTNH_NUMBERS_KEPT = FORK_GTNH_NUMBERS_KEPT or {}
for _, cable in pairs({ "niobium-titanium", "vanadium-gallium", "naquadah", "naquadah-alloy", "bedrockium", "draconium",
	"fluxed-electrum", "lumiium", "nether-star", "quantium" }) do
	FORK_GTNH_NUMBERS_KEPT[cable .. "-cable"] = "issue #690: GT insulates one wire in the assembler's cable map with rubber "
		.. "or a pulp; Gregtorio's cable recipe takes 4 wires and its foils, the cable map is #690's"
end

FORK_GTNH_NUMBERS = { recipes = 0, tiers = 0, times = 0, amounts = 0, missing = {} }

local function tier_of(category)
	for _, t in pairs(TIERS) do
		if category:sub(1, #t + 1) == t .. "-" then return t end
	end
	return nil
end

local function is_item(x)
	return (x.type or "item") == "item"
end

for name, n in pairs(DATA) do
	local r = data.raw.recipe[name]
	if not r then
		FORK_GTNH_NUMBERS.missing[#FORK_GTNH_NUMBERS.missing + 1] = name
	elseif not FORK_GTNH_NUMBERS_KEPT[name] then
		FORK_GTNH_NUMBERS.recipes = FORK_GTNH_NUMBERS.recipes + 1
		if n.t then
			local cat = fork_category(r)
			local cur = tier_of(cat)
			local new = cur and (n.t .. cat:sub(#cur + 1))
			if new and new ~= cat and data.raw["recipe-category"][new] then
				fork_set_category(r, new)
				FORK_GTNH_NUMBERS.tiers = FORK_GTNH_NUMBERS.tiers + 1
			end
		end
		if n.e and r.energy_required ~= n.e then
			r.energy_required = n.e
			FORK_GTNH_NUMBERS.times = FORK_GTNH_NUMBERS.times + 1
		end
		if n.i then
			for _, x in pairs(r.ingredients or {}) do
				if is_item(x) and n.i[x.name] then x.amount = n.i[x.name] end
			end
		end
		if n.o then
			-- (an item's results are GT's stacks in its place: a sure one and one per chance)
			local stacks = {}
			for _, s in pairs(n.o) do
				stacks[s[1]] = stacks[s[1]] or {}
				table.insert(stacks[s[1]], s)
			end
			local results, done = {}, {}
			for _, x in pairs(r.results or {}) do
				if is_item(x) and stacks[x.name] then
					if not done[x.name] then
						done[x.name] = true
						for _, s in pairs(stacks[x.name]) do
							local res = table.deepcopy(x)
							res.amount, res.amount_min, res.amount_max = s[2], nil, nil
							res.probability, res.independent_probability = nil, s[3]
							results[#results + 1] = res
						end
					end
				else
					results[#results + 1] = x
				end
			end
			-- (a recipe of one result that now has two needs a main product or an icon)
			if #results > 1 and #(r.results or {}) == 1 and not (r.main_product or r.icon or r.icons) then
				r.main_product = r.results[1].name
			end
			r.results = results
			FORK_GTNH_NUMBERS.amounts = FORK_GTNH_NUMBERS.amounts + 1
		end
	end
end
table.sort(FORK_GTNH_NUMBERS.missing)
log("FORK-GTNH-NUMBERS: " .. FORK_GTNH_NUMBERS.recipes .. " recipes with GT's numbers (" .. FORK_GTNH_NUMBERS.tiers
	.. " tiers, " .. FORK_GTNH_NUMBERS.times .. " times), " .. #FORK_GTNH_NUMBERS.missing .. " of the table missing: "
	.. table.concat(FORK_GTNH_NUMBERS.missing, ", "))
