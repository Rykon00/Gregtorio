--------------------------------------------------------------------------------
--- FORK RECYCLING (issue #190)
--- GT New Horizons has no disassembler (GTModHandler.RecipeBits.DISMANTLEABLE: "Disassembler was removed"): an item is
--- recycled into the MATERIALS it is made of, never into its parts. Every item with material data (ItemData) gets
--- recycling recipes (gregtech/api/util/GTRecipeRegistrator.java registerMaterialRecycling, 184-209):
---   macerator      the main material and its 3 largest byproducts as dusts, max(16, sum of amount x mass) ticks,
---                  4 EU/t (registerReverseMacerating, 459-498); a platinum group dust is two of the platinum line's
---                  powder or residue, as in the ore chain (issue #199)
---   arc furnace    the metals as ingots (a metal's arc smelting material: copper -> annealed copper), the non-metals
---                  dropped, up to 9 outputs, with oxygen as the gas: max(16, sum of amount x mass) ticks and as many
---                  litres of oxygen, LV (registerReverseArcSmelting, 311-408)
---   fluid extractor the main material as its melt (144 L per ingot), the first byproduct as ingots, max(1, 24 x amount)
---                  ticks (registerReverseFluidSmelting, 217-249)
--- Where the data comes from (GTModHandler.java 1098-1160): only a crafting table recipe with the REVERSIBLE bit gives an
--- item data, the sum of its ingredients' data (machines through addMachineCraftingRecipe, motors, casings ...);
--- assembler recipes give none, circuits have none (amount -1). The machine hull is set explicitly as its casing and
--- two cables (MTERecipeLoader.java 2549-2599). Gregtorio's counterpart (maintainer's decision on #190, "the GTNH rule"):
--- the items whose own recipe (the recipe named after the item) is a crafting table recipe (categories crafting,
--- crafting-or-assembling-recipes, crafting-table-recipes), their composition summed recursively through the recipes of
--- their ingredients down to the material parts (ingot, plate, rod ... in ingots: 143's melt per part, GT's for wires and
--- foils), circuits and things without materials counting nothing. Against loops: per material the least any recipe of
--- the item needs (an item with two recipes gives back only what both have), and the material parts themselves (ingots,
--- plates ...) are not recycled by this rule (143 melts and casts them; issue #686 gives them GT's own recycling below). GT's output is dusts plus small and tiny dusts; here whole
--- dusts and ingots, the rest is lost (decision on #190: never more than the item is worth). No Recycler: GTNH's turns
--- items into scrap, which has no use in Gregtorio (decision on #190).
--- The masses (FORK_RECYCLING_MASS) are GT's Materials.getMass (MaterialsInit.java: the element's protons and neutrons,
--- an alloy's from its composition and density); the GT++ and bartworks alloys (not in MaterialsInit) take GT's own
--- mass of a material without composition, technetium's 98. The mass only sets the time.
--- Recipes are named recycling-<machine>-<item> and listed in FORK_RECYCLING.recipes, which 199's auto-unlock ignores
--- like the casts. Unlocked with the first technology after the machine and the item (after_all as in 155), in
--- FORK_RECYCLING.unlock(), which data-final-fixes.lua calls after it set and disabled the vanilla technologies.
--- Loads after every file that makes recipes (after 156) and before 150, 196, 198 and 199.
--------------------------------------------------------------------------------

FORK_RECYCLING_MASS = {
	["aluminium"] = 26, ["americium"] = 245, ["annealed-copper"] = 63, ["battery-alloy"] = 189, ["bedrockium"] = 20,
	["beryllium"] = 9, ["black-plutonium"] = 98, ["black-steel"] = 64, ["blue-steel"] = 75, ["brass"] = 63,
	["bronze"] = 76, ["chromium"] = 52, ["chromnorox"] = 98, ["cobalt-brass"] = 68, ["conductive-iron"] = 69,
	["copper"] = 63, ["cosmic-neutronium"] = 98, ["cupronickel"] = 60, ["dark-steel"] = 27, ["diamond"] = 768,
	["dracofinium"] = 98, ["draconium"] = 98, ["electrical-steel"] = 36, ["electrum"] = 151, ["emerald"] = 18,
	["end-steel"] = 102, ["enderium"] = 129, ["energetic-alloy"] = 109, ["enriched-naquadah"] = 98, ["eternity"] = 98,
	["europium"] = 151, ["fluxed-electrum"] = 98, ["gallium"] = 70, ["gold"] = 196, ["hsse"] = 81, ["hssg"] = 98,
	["hsss"] = 129, ["hypocosmium"] = 98, ["infinity"] = 98, ["invar"] = 56, ["iridium"] = 192, ["iridium-alloy"] = 192,
	["iron"] = 56, ["kanthal"] = 44, ["lapis"] = 28, ["lead"] = 207, ["ledox"] = 98, ["magmatter"] = 98,
	["magnalium"] = 25, ["naquadah"] = 330, ["naquadah-alloy"] = 98, ["naquadria"] = 98, ["neodymium"] = 144,
	["nether-quartz"] = 98, ["neutronium"] = 100, ["nichrome"] = 56, ["nickel"] = 58, ["nickel-zinc-ferrite"] = 33,
	["niobium-titanium"] = 71, ["osmiridium"] = 191, ["osmium"] = 190, ["palladium"] = 106, ["platinum"] = 195,
	["pulsating-iron"] = 61, ["quantium"] = 98, ["red-alloy"] = 403, ["samarium"] = 150,
	["silicon"] = 28, ["silver"] = 107, ["soularium"] = 102, ["spacetime"] = 98, ["stainless-steel"] = 55,
	["steel"] = 56, ["tantalum"] = 180, ["tin"] = 118, ["titanium"] = 48, ["transcendent-metal"] = 98, ["trinium"] = 98,
	["tritanium"] = 323, ["tungsten"] = 183, ["tungsten-carbide"] = 97, ["tungstensteel"] = 119, ["ultimet"] = 61,
	["universium"] = 98, ["vanadium-gallium"] = 55, ["vanadium-steel"] = 55, ["vibrant-alloy"] = 107,
	["yttrium-barium-cuprate"] = 51, ["zinc"] = 65,
}
local DEFAULT_MASS = 98   -- GT: a material without element and composition (technetium)

--- items never recycled, with the reason (devcheck fails for an entry without one or for an item that does not exist)
--- (data.lua's files before this one may already have listed theirs)
FORK_RECYCLING_BLACKLIST = FORK_RECYCLING_BLACKLIST or {}
FORK_RECYCLING_BLACKLIST["blaze-rod"] = "GT: registerMaterialRecycling skips the blaze rod (GTRecipeRegistrator.java 185)"
FORK_RECYCLING_BLACKLIST["obsidian"] = "GT: registerMaterialRecycling skips obsidian (GTRecipeRegistrator.java 188)"

FORK_RECYCLING = { recipes = {}, pending = {}, items = 0, by_kind = { macerator = 0, ["arc-furnace"] = 0, ["fluid-extractor"] = 0,
	["alloy-smelter"] = 0, furnace = 0 } }

local P = "__gregtorio-continued__/graphics/icons/"
local CRAFTING = { ["crafting"] = true, ["crafting-or-assembling-recipes"] = true, ["crafting-table-recipes"] = true }

--- the material parts, in ingots (143's melt per part / 14.4; GT's amounts for the forms 143 does not cast)
local FORMS = {
	{ "hot-", "-ingot", 1 }, { "superdense-", "-plate", 64 }, { "dense-", "-plate", 9 }, { "long-", "-rod", 1 },
	{ "large-", "-gear", 4 }, { "fine-", "-wire", 1 / 8 }, { "block-of-", "", 9 }, { "", "-ingot", 1 },
	{ "", "-nugget", 1 / 9 }, { "", "-plate", 1 }, { "", "-foil", 1 / 4 }, { "", "-rod", 1 / 2 }, { "", "-round", 1 / 9 },
	{ "", "-bolt", 1 / 8 }, { "", "-screw", 1 / 8 }, { "", "-ring", 1 / 4 }, { "", "-gear", 1 }, { "", "-rotor", 4.25 },
	{ "", "-wire", 1 / 2 }, { "", "-cable", 1 / 2 }, { "", "-dust", 1 },
}
local SPECIAL = { ["iron-stick"] = { "iron", 1 / 2 }, ["iron-gear-wheel"] = { "iron", 1 } }
--- a metal's arc smelting material (GT Materials.mArcSmeltInto; iron stays iron: GT5-Unofficial merged the wrought iron it
--- used to arc-smelt into with Cast Iron, which arc-smelts into itself, issue #448)
local ARC_INTO = { ["copper"] = "annealed-copper" }

local function item_exists(n)
	return data.raw.item[n] ~= nil or data.raw.tool[n] ~= nil
end
--- a material: it has an ingot, or a dust and a plate (gems)
local function is_material(m)
	if m:find("^impure%-") or m:find("^pure%-") or m:find("^small%-pile%-of%-") or m:find("^tiny%-pile%-of%-") then
		return false
	end
	return item_exists(m .. "-ingot") or (item_exists(m .. "-dust") and item_exists(m .. "-plate"))
end
local function parse(name)
	if SPECIAL[name] then return SPECIAL[name][1], SPECIAL[name][2] end
	for _, f in pairs(FORMS) do
		local pre, suf = f[1], f[2]
		if name:sub(1, #pre) == pre and (suf == "" or name:sub(-#suf) == suf) and #name > #pre + #suf then
			local m = name:sub(#pre + 1, #name - #suf)
			if is_material(m) then return m, f[3] end
		end
	end
end
local CIRCUIT = { "circuit", "processor", "mainframe", "computer", "chip", "wafer", "smd", "transistor", "resistor",
	"capacitor", "diode", "inductor" }
local function is_circuit(name)
	for _, w in pairs(CIRCUIT) do
		if name:find(w, 1, true) then return true end
	end
	return false
end

--- the item a recipe makes: its main product, else its only item, else the item of its own name, else none. The items
--- a recipe gives back do not count (issue #423): a machine upgrade returns the old energy hatch, and counting it as a
--- producer of the hatch put loops into the sums, which then depended on the order of the items
local function main_item(name, r)
	if r.main_product then return r.main_product ~= "" and r.main_product or nil end
	local only
	for _, res in pairs(r.results) do
		if res.type ~= "fluid" then
			if res.name == name then return name end
			only = only == nil and res.name or false
		end
	end
	return only or nil
end

--- the producers of every item (not the casts and melts of 143, not recycling)
local casting = FORK_CASTING and FORK_CASTING.recipes or {}
local producers = {}
for name, r in pairs(data.raw.recipe) do
	if not casting[name] and not name:find("recycling", 1, true) and not name:find("^void%-") and r.results then
		local item = main_item(name, r)
		if item then
			producers[item] = producers[item] or {}
			table.insert(producers[item], r)
		end
	end
end
local function amount(s)
	local a = s.amount or ((s.amount_min or 0) + (s.amount_max or 0)) / 2
	return a * (s.independent_probability or 1)
end

--- the composition of an item in ingots per material: per material the least any of its recipes needs
local memo = {}
local function comp(name, stack)
	if memo[name] then return memo[name] end
	local m, a = parse(name)
	if m then
		memo[name] = { [m] = a }
		return memo[name]
	end
	if is_circuit(name) or stack[name] then return {} end
	stack[name] = true
	local result
	local hull_tier = name:match("^(%a+)%-machine%-hull$")
	for _, r in pairs(producers[name] or {}) do
		local out = 0
		for _, s in pairs(r.results) do
			if s.name == name then out = out + amount(s) end
		end
		if out > 0 then
			local c = {}
			for _, i in pairs(r.ingredients or {}) do
				--- GT sets the hull as its casing and two cables, its other parts do not count
				local counts = i.type ~= "fluid" and (not hull_tier or i.name:find("%-machine%-casing$") or i.name:find("%-cable$"))
				if counts then
					local n = hull_tier and (i.name:find("%-cable$") and 2 or 1) or i.amount
					for mm, aa in pairs(comp(i.name, stack)) do
						c[mm] = (c[mm] or 0) + aa * n / out
					end
				end
			end
			if result == nil then
				result = c
			else
				for mm, aa in pairs(result) do
					result[mm] = math.min(aa, c[mm] or 0)
				end
			end
		end
	end
	stack[name] = nil
	memo[name] = result or {}
	return memo[name]
end

--- the subgroups of the recipe rows, next to their machine's row
for _, k in pairs({ { "macerator", "lv-macerator-recipes" }, { "arc-furnace", "lv-arc-furnace-recipes" },
	{ "fluid-extractor", "lv-fluid-extractor-recipes" } }) do
	local base = data.raw["item-subgroup"]["subgroup-" .. k[2]]
	data:extend({ { type = "item-subgroup", name = "fork-recycling-" .. k[1], group = base and base.group or "processing-machine-recipes",
		order = (base and base.order or "z") .. "-recycling" } })
end

--- the recipe shows the item it recycles
local function icons_of(item)
	local it = data.raw.item[item] or data.raw.tool[item]
	if it.icons then return table.deepcopy(it.icons) end
	return { { icon = it.icon, icon_size = it.icon_size or 64 } }
end

local function recipe(kind, category, item, time, ingredients, results)
	local name = "recycling-" .. kind .. "-" .. item
	data:extend({ {
		type = "recipe", name = name, categories = { category }, enabled = false, energy_required = time,
		ingredients = ingredients, results = results, subgroup = "fork-recycling-" .. kind,
		icons = icons_of(item),
		localised_name = { "recipe-name.fork-recycling-" .. kind, FORK_LOCALE.name_of("item", item) },
		hide_from_player_crafting = true, allow_productivity = false, auto_recycle = false,
	} })
	FORK_RECYCLING.recipes[name] = true
	FORK_RECYCLING.by_kind[kind] = FORK_RECYCLING.by_kind[kind] + 1
	table.insert(FORK_RECYCLING.pending, { name, category, item })
end

local function mass(m) return FORK_RECYCLING_MASS[m] or DEFAULT_MASS end
--- issue #199: a dust of the platinum group is two of the platinum line's powder or residue (bartworks'
--- PlatinumSludgeOutputs.convert: Platinum, Palladium, Iridium, Osmium -> PT/PD metallic powder, Ir and Ir/Os leach residue)
local PGM_DUST = { ["platinum"] = "metallic-platinum-powder", ["palladium"] = "metallic-palladium-powder",
	["iridium"] = "iridium-metal-residue", ["osmium"] = "rarest-metal-mixture" }
--- a fluid amount on the engine's grid of 2^-24, rounded down (197's rule)
local function grid(x) return math.floor(x * 16777216) / 16777216 end

--- the items: own recipe a crafting table recipe, not a material part, not a circuit, not blacklisted
local names = {}
for name, r in pairs(data.raw.recipe) do
	--- the machine hulls too: GT sets their data explicitly (an assembler recipe here)
	if (fork_category_in(r, CRAFTING) or name:match("^%a+%-machine%-hull$")) and not r.hidden and item_exists(name)
		and not parse(name) and not is_circuit(name)
		and not FORK_RECYCLING_BLACKLIST[name] then
		for _, s in pairs(r.results or {}) do
			if s.name == name then names[#names + 1] = name break end
		end
	end
end
--- issue #686: and the other items GT New Horizons recycles (components, casings, machines; prototypes/data/gtnh-recycling.lua,
--- from GT's recipe dump), whatever their own recipe is
local GTNH_RECYCLING = require("prototypes.data.gtnh-recycling")
do
	local listed = {}
	for _, n in pairs(names) do listed[n] = true end
	for _, n in pairs(GTNH_RECYCLING.items or {}) do
		if not listed[n] and item_exists(n) and not parse(n) and not is_circuit(n) and not FORK_RECYCLING_BLACKLIST[n] then
			names[#names + 1] = n
			listed[n] = true
		end
	end
end
table.sort(names)

for _, item in pairs(names) do
	local c = comp(item, {})
	local list = {}
	for m, a in pairs(c) do
		if a >= 1 then list[#list + 1] = { m, a } end
	end
	table.sort(list, function(x, y) return x[2] > y[2] or (x[2] == y[2] and x[1] < y[1]) end)
	if #list > 0 then
		FORK_RECYCLING.items = FORK_RECYCLING.items + 1
		local input = { { type = "item", name = item, amount = 1 } }
		--- macerator: the main material and 3 byproducts as dusts
		local res, ticks = {}, 0
		for i = 1, math.min(4, #list) do
			local m, a = list[i][1], math.floor(list[i][2])
			if PGM_DUST[m] and item_exists(PGM_DUST[m]) then
				res[#res + 1] = { type = "item", name = PGM_DUST[m], amount = 2 * a }
				ticks = ticks + a * mass(m)
			elseif item_exists(m .. "-dust") then
				res[#res + 1] = { type = "item", name = m .. "-dust", amount = a }
				ticks = ticks + a * mass(m)
			end
		end
		if #res > 0 then
			recipe("macerator", "lv-macerator-recipes", item, math.max(16, ticks) / 20 * LV_SPEED, input, res)
		end
		--- arc furnace: the metals as ingots (their arc smelting material), up to 9, oxygen as the gas
		res, ticks = {}, 0
		for i = 1, #list do
			local m, a = list[i][1], math.floor(list[i][2])
			local into = ARC_INTO[m] or m
			if #res < 9 and item_exists(into .. "-ingot") then
				res[#res + 1] = { type = "item", name = into .. "-ingot", amount = a }
				ticks = ticks + a * mass(m)
			end
		end
		if #res > 0 then
			local t = math.max(16, ticks)
			recipe("arc-furnace", "lv-arc-furnace-recipes", item, t / 20 * LV_SPEED,
				{ input[1], { type = "fluid", name = "oxygen", amount = grid(t / 10) } }, res)
		end
		--- fluid extractor: the main material's melt and the first byproduct's ingots
		local main = list[1][1]
		if data.raw.fluid["molten-" .. main] then
			res = { { type = "fluid", name = "molten-" .. main, amount = grid(list[1][2] * 14.4) } }
			if list[2] and item_exists(list[2][1] .. "-ingot") and math.floor(list[2][2]) >= 1 then
				res[2] = { type = "item", name = list[2][1] .. "-ingot", amount = math.floor(list[2][2]) }
			end
			recipe("fluid-extractor", "lv-fluid-extractor-recipes", item, math.max(1, 24 * list[1][2]) / 20 * LV_SPEED, input, res)
		end
	end
end
--------------------------------------------------------------------------------
--- Issue #686: GT New Horizons recycles every material part (plates, foils, rods, bolts, screws, rounds, rings, springs,
--- fine wire, wires, cables, item casings, frames, gears, rotors, pipes, nuggets): the macerator into dusts, the arc
--- furnace into ingots or nuggets with oxygen, the fluid extractor into the melt, the alloy smelter (with the mold) and
--- the furnace into ingots or nuggets (GTRecipeRegistrator.registerMaterialRecycling and GT's furnace and alloy smelter
--- part recipes, from the material amount of each prefix). prototypes/data/gtnh-recycling.lua holds them as GT New
--- Horizons' recipe dump has them (tools/gtnh_dump/), mapped onto Gregtorio's names and units by tools/gtnh_map.py
--- (`recycling_imports`: the tier from GT's EU/t, its time x the tier's speed, a tenth of GT's litres; a furnace recipe
--- 10 s as Gregtorio's smelting); `devcheck.py check --gtnh-recycling` writes it and `check` fails when it is out of
--- date. A part whose machine takes it already (a furnace machine runs one recipe per input) keeps that recipe. Named
--- recycling-<kind>-<part>, in FORK_RECYCLING.recipes and unlocked by FORK_RECYCLING.unlock() like the rest. The same
--- file's `items` (the components, casings and machines GT recycles) join the items of the rule above.
--------------------------------------------------------------------------------
do
	local PARTS = GTNH_RECYCLING.parts
	for _, k in pairs({ { "alloy-smelter", "lv-alloy-smelter-recipes" }, { "furnace", "smelting" } }) do
		local base = data.raw["item-subgroup"]["subgroup-" .. k[2]]
		data:extend({ { type = "item-subgroup", name = "fork-recycling-" .. k[1], group = base and base.group or "processing-machine-recipes",
			order = (base and base.order or "z") .. "-recycling" } })
	end
	FORK_RECYCLING.parts = 0
	for _, p in pairs(PARTS) do
		local kind, item = p[1], p[2]
		if item_exists(item) and not data.raw.recipe["recycling-" .. kind .. "-" .. item] then
			local ing = { { type = "item", name = item, amount = 1 } }
			for _, f in pairs(p.f or {}) do ing[#ing + 1] = { type = "fluid", name = f[1], amount = grid(f[2]) } end
			local res = {}
			for _, o in pairs(p.o or {}) do
				-- (a platinum group dust is two of the platinum line's powder or residue, as above)
				local m = o[1]:match("^(%a+)%-dust$")
				if PGM_DUST[m] and item_exists(PGM_DUST[m]) then
					res[#res + 1] = { type = "item", name = PGM_DUST[m], amount = 2 * o[2], independent_probability = o[3] }
				else
					res[#res + 1] = { type = "item", name = o[1], amount = o[2], independent_probability = o[3] }
				end
			end
			for _, f in pairs(p.fo or {}) do res[#res + 1] = { type = "fluid", name = f[1], amount = grid(f[2]) } end
			if p.mold then
				ing[#ing + 1] = { type = "item", name = "mold", amount = 1 }
				res[#res + 1] = { type = "item", name = "mold", amount = 1 }
			end
			recipe(kind, p.cat, item, p.e, ing, res)
			FORK_RECYCLING.parts = FORK_RECYCLING.parts + 1
		end
	end
end
--------------------------------------------------------------------------------
--- Issue #670: the material blocks. GT gives a storage block (OrePrefixes.block: 9 units of its material) the material
--- recycling above with 9 units (GTRecipeRegistrator.registerMaterialRecycling: 9 dusts in max(16, 9 x mass) ticks, 9
--- ingots of the arc smelting material in as many ticks with as many litres of oxygen, the melt of 9 ingots in 216 ticks)
--- and the recipes of ProcessingBlock.java: the cutting machine cuts it into 9 plates (when the plate exists and the
--- material's processing voltage is below IV: water, max(4, min(1000, mass x 10 x 30 / 320)) L, 2 x mass x 10 ticks, LV;
--- GT's distilled water, lubricant and superfluid variants are left out, as for 158's bolts; GT++'s alloys,
--- RecipeGenPlates.java: no fluid, mass x 10 ticks at the alloy's voltage), and the forge hammer breaks a gem block into 9
--- gems (5 s, 24 EU/t). GTNH has no block -> ingot crafting (its config storageblockdecrafting is unused).
--- A material block is block-of-<material> or <material>-block whose recipe takes 9 of one item (an ingot, a gem or a
--- dust); its melt is the one its solidifier recipe takes, else 9 times the melt of that item. Everything comes from the
--- recipes and 158's data (prototypes/gt-parts-data.lua: mass, processing voltage, GT++ or not). Unlocked like the
--- recycling (FORK_RECYCLING.unlock(): the first technology after the machine and the block); the cutting and forge
--- hammer recipes are FORK_RECYCLING.blocks, which 199's auto-unlock ignores like the recycling recipes. devcheck fails
--- for a reachable material block that no recipe takes, unless it is in FORK_BLOCKS_DEAD_END with its reason.
--------------------------------------------------------------------------------
FORK_BLOCKS_DEAD_END = FORK_BLOCKS_DEAD_END or {}
FORK_RECYCLING.blocks = {}
FORK_RECYCLING.block_counts = { blocks = 0, ["cutting-machine"] = 0, ["forge-hammer"] = 0 }
do
	local GT = require("prototypes.gt-parts-data")
	local SPEED = { lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED, iv = IV_SPEED, luv = LUV_SPEED,
		zpm = ZPM_SPEED, uv = UV_SPEED, uhv = UHV_SPEED, uev = UEV_SPEED, uiv = UIV_SPEED, umv = UMV_SPEED, uxv = UXV_SPEED }
	local BELOW_IV = { lv = true, mv = true, hv = true, ev = true }
	--- a gem whose dust and plate have another material name (lapis-lazuli, lapis-dust, lapis-plate)
	local GEM_MATERIAL = { ["lapis-lazuli"] = "lapis" }
	local function is_block(n) return n:find("^block%-of%-") ~= nil or n:find("%-block$") ~= nil end
	--- the blocks with their item of 9 and their melt; the melt of every item from the fluid extractor
	local source, block_melt, melt_of, takers = {}, {}, {}, {}
	for name, r in pairs(data.raw.recipe) do
		local ing, res = r.ingredients or {}, r.results or {}
		if not r.hidden and #ing == 1 and #res == 1 and res[1].type ~= "fluid" and is_block(res[1].name) and res[1].amount == 1 then
			local b, i = res[1].name, ing[1]
			if i.type ~= "fluid" and i.amount == 9 then
				source[b] = source[b] or i.name
			elseif i.type == "fluid" and i.name:find("^molten%-") then
				block_melt[b] = block_melt[b] or { i.name, i.amount }
			end
		end
		if not r.hidden and #ing == 1 and ing[1].type ~= "fluid" and ing[1].amount == 1 and #res == 1 and res[1].type == "fluid"
			and res[1].name:find("^molten%-") then
			for _, c in pairs(r.categories or {}) do
				if c:find("fluid-extractor", 1, true) then melt_of[ing[1].name] = { res[1].name, res[1].amount } end
			end
		end
		for _, i in pairs(ing) do
			if is_block(i.name) then
				takers[i.name] = takers[i.name] or {}
				table.insert(takers[i.name], r)
			end
		end
	end
	local function taken_by(block, kind)
		for _, r in pairs(takers[block] or {}) do
			for _, c in pairs(r.categories or {}) do
				if c:find(kind, 1, true) then return true end
			end
		end
		return false
	end
	local function block_recipe(name, kind, tier, time, block, ingredients, results)
		local category = tier .. "-" .. kind .. "-recipes"
		if not data.raw["recipe-category"][category] or data.raw.recipe[name] then return end
		data:extend({ {
			type = "recipe", name = name, categories = { category }, enabled = false, energy_required = time,
			ingredients = ingredients, results = results, main_product = results[1].name,
			subgroup = data.raw["item-subgroup"]["subgroup-" .. category] and ("subgroup-" .. category) or nil,
			allow_productivity = false, auto_recycle = false,
		} })
		FORK_RECYCLING.blocks[name] = true
		FORK_RECYCLING.block_counts[kind] = FORK_RECYCLING.block_counts[kind] + 1
		table.insert(FORK_RECYCLING.pending, { name, category, block })
	end
	local blocks = {}
	for b in pairs(source) do
		if item_exists(b) then blocks[#blocks + 1] = b end
	end
	table.sort(blocks)
	for _, b in pairs(blocks) do
		local src = source[b]
		local kind = src:find("%-ingot$") and "ingot" or src:find("%-dust$") and "dust" or "gem"
		local m = src:match("^(.+)%-ingot$") or src:match("^(.+)%-dust$") or src:match("^(.+)%-gem$") or src
		m = GEM_MATERIAL[m] or m
		local d = GT[m] or {}
		local ms = d.mass or FORK_RECYCLING_MASS[m] or DEFAULT_MASS
		local input = { { type = "item", name = b, amount = 1 } }
		FORK_RECYCLING.block_counts.blocks = FORK_RECYCLING.block_counts.blocks + 1
		--- macerator: 9 dusts (a platinum group metal: the platinum line's powder or residue, as above)
		local dust = kind == "dust" and src or (d.dust and item_exists(d.dust) and d.dust) or (m .. "-dust")
		local t = math.max(16, 9 * ms)
		if PGM_DUST[m] and item_exists(PGM_DUST[m]) then
			recipe("macerator", "lv-macerator-recipes", b, t / 20 * LV_SPEED, input,
				{ { type = "item", name = PGM_DUST[m], amount = 18 } })
		elseif item_exists(dust) then
			recipe("macerator", "lv-macerator-recipes", b, t / 20 * LV_SPEED, input, { { type = "item", name = dust, amount = 9 } })
		end
		--- arc furnace: 9 ingots of a metal's arc smelting material (gems and dusts are no metals: GT drops them)
		local into = (ARC_INTO[m] or m) .. "-ingot"
		if kind == "ingot" and item_exists(into) then
			recipe("arc-furnace", "lv-arc-furnace-recipes", b, t / 20 * LV_SPEED,
				{ input[1], { type = "fluid", name = "oxygen", amount = grid(t / 10) } }, { { type = "item", name = into, amount = 9 } })
		end
		--- fluid extractor: the melt of 9 ingots
		local melt = block_melt[b] or (melt_of[src] and { melt_of[src][1], melt_of[src][2] * 9 })
		if melt and data.raw.fluid[melt[1]] then
			recipe("fluid-extractor", "lv-fluid-extractor-recipes", b, math.max(1, 24 * 9) / 20 * LV_SPEED, input,
				{ { type = "fluid", name = melt[1], amount = grid(melt[2]) } })
		end
		--- cutting machine: 9 plates
		local plate = m .. "-plate"
		if item_exists(plate) and not taken_by(b, "cutting-machine") then
			local out = { { type = "item", name = plate, amount = 9 } }
			local m10 = math.max(1, ms * 10)
			if d.source == "gtpp" then
				local tier = d.tier or "lv"
				block_recipe("cut-" .. b, "cutting-machine", tier, m10 / 20 * SPEED[tier], b, input, out)
			elseif not d.tier or BELOW_IV[d.tier] then
				local water = math.max(4, math.min(1000, math.floor(m10 * 30 / 320))) / 10
				block_recipe("cut-" .. b, "cutting-machine", "lv", 2 * m10 / 20 * LV_SPEED, b,
					{ input[1], { type = "fluid", name = "water", amount = grid(water) } }, out)
			end
		end
		--- forge hammer: 9 gems
		if kind == "gem" and not taken_by(b, "forge-hammer") then
			block_recipe("hammer-" .. b, "forge-hammer", "lv", 5 * LV_SPEED, b, input, { { type = "item", name = src, amount = 9 } })
		end
	end
	log("FORK-RECYCLING: " .. FORK_RECYCLING.block_counts.blocks .. " material blocks, "
		.. FORK_RECYCLING.block_counts["cutting-machine"] .. " cutting machine and " .. FORK_RECYCLING.block_counts["forge-hammer"]
		.. " forge hammer recipes (issue #670)")
end
log("FORK-RECYCLING: " .. FORK_RECYCLING.items .. " items, " .. FORK_RECYCLING.by_kind.macerator .. " macerator, "
	.. FORK_RECYCLING.by_kind["arc-furnace"] .. " arc furnace, " .. FORK_RECYCLING.by_kind["fluid-extractor"]
	.. " fluid extractor recycling recipes")

--- the unlocks, called from data-final-fixes.lua after it set and disabled the vanilla technologies (it replaces the
--- effects of some of them, fluid-handling and the rail technologies, and disables others): the first researchable
--- technology after the machine and the item (the helpers of 155); a recipe no researchable technology can give is removed
function FORK_RECYCLING.unlock()
	local techs_of_recipe = {}
	for tname, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and tech.enabled ~= false and not tech.hidden then
				techs_of_recipe[e.recipe] = techs_of_recipe[e.recipe] or {}
				table.insert(techs_of_recipe[e.recipe], tname)
			end
		end
	end
	local function item_techs(name)
		local out = {}
		for _, r in pairs(producers[name] or {}) do
			if r.enabled ~= false and not r.hidden then return nil end
			for _, t in pairs(techs_of_recipe[r.name] or {}) do out[#out + 1] = t end
		end
		return out
	end
	local machine_techs_cache = {}
	local function machine_techs(category)
		if machine_techs_cache[category] ~= nil then return machine_techs_cache[category] or nil end
		local out = {}
		for _, kind in pairs({ "assembling-machine", "furnace" }) do
			for ename, e in pairs(data.raw[kind] or {}) do
				for _, c in pairs(e.crafting_categories or {}) do
					if c == category then
						for iname, it in pairs(data.raw.item) do
							if it.place_result == ename then
								local t = item_techs(iname)
								if t == nil then
									machine_techs_cache[category] = false
									return nil
								end
								for _, x in pairs(t) do out[#out + 1] = x end
							end
						end
					end
				end
			end
		end
		machine_techs_cache[category] = out
		return out
	end
	local ancestors_cache = {}
	local function ancestors(tech)
		if ancestors_cache[tech] then return ancestors_cache[tech] end
		local seen = {}
		local function walk(n)
			local t = data.raw.technology[n]
			for _, pre in pairs(t and t.prerequisites or {}) do
				if not seen[pre] then
					seen[pre] = true
					walk(pre)
				end
			end
		end
		walk(tech)
		ancestors_cache[tech] = seen
		return seen
	end
	local function size(set)
		local n = 0
		for _ in pairs(set) do n = n + 1 end
		return n
	end
	local function covers(c, groups)
		local a = ancestors(c)
		for _, g in pairs(groups) do
			local hit = false
			for _, t in pairs(g) do
				if t == c or a[t] then hit = true break end
			end
			if not hit then return false end
		end
		return true
	end
	local after_cache = {}
	local function after_all(groups)
		local key = {}
		for _, g in pairs(groups) do
			local s = {}
			for _, t in pairs(g) do s[#s + 1] = t end
			table.sort(s)
			key[#key + 1] = table.concat(s, ",")
		end
		table.sort(key)
		key = table.concat(key, "|")
		if after_cache[key] ~= nil then return after_cache[key] or nil end
		local found, found_n
		for _, g in pairs(groups) do
			for _, c in pairs(g) do
				if covers(c, groups) and (not found or size(ancestors(c)) < found_n or (size(ancestors(c)) == found_n and c < found)) then
					found, found_n = c, size(ancestors(c))
				end
			end
		end
		if not found then
			for name, tech in pairs(data.raw.technology) do
				if not tech.hidden and tech.enabled ~= false and covers(name, groups) then
					local n = size(ancestors(name))
					if not found or n < found_n or (n == found_n and name < found) then found, found_n = name, n end
				end
			end
		end
		after_cache[key] = found or false
		return found
	end
	local function unlock_after(name, groups)
		local g = {}
		for _, x in pairs(groups) do
			if x ~= nil and x ~= false then
				if #x == 0 then return false end
				g[#g + 1] = x
			end
		end
		if #g == 0 then
			data.raw.recipe[name].enabled = true
			return true
		end
		local tech = after_all(g)
		if tech then fork_add_unlock(tech, name) end
		return tech ~= nil
	end
	local removed = 0
	for _, p in pairs(FORK_RECYCLING.pending) do
		if not unlock_after(p[1], { machine_techs(p[2]), item_techs(p[3]) }) then
			data.raw.recipe[p[1]] = nil
			FORK_RECYCLING.recipes[p[1]] = nil
			FORK_RECYCLING.blocks[p[1]] = nil
			removed = removed + 1
		end
	end
	log("FORK-RECYCLING: " .. removed .. " recycling recipes removed (their item or machine has no researchable technology)")
end
