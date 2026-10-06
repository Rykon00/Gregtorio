--------------------------------------------------------------------------------
--- FORK ORE CHAIN, PHASE O1 (issue #185; plan docs/ORE-CHAIN.md, decision #176)
--- GT New Horizons' ore processing instead of upstream's crushed -> dust shortcut. For every ore of create_ore (07) with a
--- crushed form, from GTNH's byproduct list of the ore (ORE_CHAIN below, appendix B of docs/ORE-CHAIN.md; a step takes
--- entry 1, 2 or 3 of the list, a short list repeats its last entry, an empty one the ore's own dust), with GTNH's numbers
--- in Gregtorio's units (time = GT seconds x LV speed, a tenth of GT's litres; appendix A):
---   ore washer         crushed + 100 water (25 s) or 20 distilled water (15 s) -> purified crushed + byproduct 1, 11.11 %
---   thermal centrifuge crushed or purified -> centrifuged crushed + byproduct 2, 11.11 % (25 s)
---   macerator          crushed -> impure dust + byproduct 1, purified -> pure dust + byproduct 2, centrifuged -> dust +
---                      byproduct 3, each 10 % (20 s)
---   centrifuge         impure dust -> dust + byproduct 1, pure dust -> dust + byproduct 2, 11.11 % (GT mass x 8 ticks)
---   furnaces           impure and pure dust -> the ingot, where the dust smelts
--- GT's stone dust of the washer and the thermal centrifuge is left out (Gregtorio's ores have no host rock; the raw ore
--- macerator never gave it). The shortcuts go: the washer recipe crushed -> dust (named after the dust) and
--- centrifuging-<crushed>; migrations/2026-10-06-issue-185-ore-chain.json maps their names onto the washer recipe of
--- the purified ore and the centrifuge recipe of the impure dust, so an old machine keeps running. Not touched: platinum and
--- palladium (their washing is the platinum line's, 146), firestone (no source of its ore), and every other recipe that
--- takes a crushed ore.
--- New recipes are unlocked with the technologies of the recipes they replace (the washer's, else the centrifuge's) or of
--- the crushed ore (macerator and furnace steps). The nine byproducts Gregtorio lacked are new dusts with GT's
--- decomposition (ProcessingDust.java) as their use. Masses: GT's Materials.getMass (bornite, a bartworks material: copper's).
--- Loads after 149 (every ore exists, 137 removed infused gold) and before 150, 196, 198, 199 and 200.
--------------------------------------------------------------------------------

local ORE_CHAIN = {
	["iron"] = { dust = "iron-dust", byproducts = { "nickel-dust", "tin-dust" }, mass = 56 },   -- GT Iron: Nickel, Tin
	["vanadium-magnetite"] = { dust = "vanadium-magnetite-dust", byproducts = { "magnetite-dust", "vanadium-dust" }, mass = 42 },   -- GT VanadiumMagnetite: Magnetite, Vanadium
	["gold"] = { dust = "gold-dust", byproducts = { "copper-dust", "nickel-dust" }, mass = 196 },   -- GT Gold: Copper, Nickel
	["fullers-earth"] = { dust = "fullers-earth", byproducts = { "alumina", "silicon-dioxide", "magnesium" }, mass = 16 },   -- GT FullersEarth: Aluminiumoxide, SiliconDioxide, Magnesium
	["copper"] = { dust = "copper-dust", byproducts = { "cobalt-dust", "gold-dust", "nickel-dust" }, mass = 63 },   -- GT Copper: Cobalt, Gold, Nickel
	["tin"] = { dust = "tin-dust", byproducts = { "iron-dust", "zinc-dust", "bismuth" }, mass = 118 },   -- GT Tin: Iron, Zinc; 3rd: bismuth, Gregtorio's (its only source, GTNH has a bismuth ore)
	["realgar"] = { dust = "realgar-dust", byproducts = {  }, mass = 53 },   -- GT Realgar: no byproducts (itself)
	["galena"] = { dust = "galena-dust", byproducts = { "sulfur", "silver-dust", "lead-dust" }, mass = 119 },   -- GT Galena: Sulfur, Silver, Lead
	["lead"] = { dust = "lead-dust", byproducts = { "silver-dust", "sulfur" }, mass = 207 },   -- GT Lead: Silver, Sulfur
	["silver"] = { dust = "silver-dust", byproducts = { "lead-dust", "sulfur" }, mass = 107 },   -- GT Silver: Lead, Sulfur
	["cryolite"] = { dust = "cryolite", byproducts = { "alumina", "sodium" }, mass = 20 },   -- GT Cryolite: Aluminiumoxide, Sodium
	["tetrahedrite"] = { dust = "tetrahedrite-dust", byproducts = { "antimony", "zinc-dust" }, mass = 57 },   -- GT Tetrahedrite: Antimony, Zinc
	["stibnite"] = { dust = "antimony", byproducts = { "antimony" }, mass = 67 },   -- GT Stibnite: Antimony
	["sphalerite"] = { dust = "sphalerite-dust", byproducts = { "yellow-garnet-dust", "cadmium", "gallium", "zinc-dust" }, mass = 48 },   -- GT Sphalerite: GarnetYellow, Cadmium, Gallium, Zinc
	["bauxite"] = { dust = "bauxite-dust", byproducts = { "grossular-dust", "rutile-dust", "gallium" }, mass = 18 },   -- GT Bauxite: Grossular, Rutile, Gallium
	["aluminium"] = { dust = "aluminium-dust", byproducts = { "bauxite-dust" }, mass = 26 },   -- GT Aluminium: Bauxite
	["ilmenite"] = { dust = "ilmenite-dust", byproducts = { "iron-dust", "rutile-dust" }, mass = 60 },   -- GT Ilmenite: Iron, Rutile
	["redstone"] = { dust = "redstone-dust", byproducts = { "cinnabar-dust", "rare-earth", "glowstone-dust" }, mass = 85 },   -- GT Redstone: Cinnabar, RareEarth, Glowstone
	["ruby"] = { dust = "ruby-dust", byproducts = { "chromium-dust", "red-garnet-dust" }, mass = 25 },   -- GT Ruby: Chrome, GarnetRed
	["cinnabar"] = { dust = "cinnabar-dust", byproducts = { "redstone-dust", "sulfur", "glowstone-dust" }, mass = 116 },   -- GT Cinnabar: Redstone, Sulfur, Glowstone
	["coal"] = { dust = "coal-dust", byproducts = { "lignite-dust", "thorium-dust" }, mass = 24 },   -- GT Coal: Lignite, Thorium
	["graphite"] = { dust = "graphite", byproducts = { "carbon" }, mass = 12 },   -- GT Graphite: Carbon
	["diamond"] = { dust = "diamond-dust", byproducts = { "graphite" }, mass = 768 },   -- GT Diamond: Graphite
	["salt"] = { dust = "salt", byproducts = { "rock-salt", "borax" }, mass = 28 },   -- GT Salt: RockSalt, Borax
	["rock-salt"] = { dust = "rock-salt", byproducts = { "salt", "borax" }, mass = 37 },   -- GT RockSalt: Salt, Borax
	["lepidolite"] = { dust = "lepidolite", byproducts = { "lithium", "caesium-dust" }, mass = 18 },   -- GT Lepidolite: Lithium, Caesium
	["nether-quartz"] = { dust = "nether-quartz-dust", byproducts = { "netherrack-dust" }, mass = 98 },   -- GT NetherQuartz: Netherrack
	["barite"] = { dust = "barite", byproducts = {  }, mass = 38 },   -- GT Barite: no byproducts (itself)
	["certus-quartz"] = { dust = "certus-quartz-dust", byproducts = { "quartzite-dust", "barite" }, mass = 98 },   -- GT CertusQuartz: Quartzite, Barite
	["apatite"] = { dust = "apatite", byproducts = { "tricalcium-phosphate", "phosphate", "pyrochlore" }, mass = 32 },   -- GT Apatite: TricalciumPhosphate, Phosphate, Pyrochlore
	["tricalcium-phosphate"] = { dust = "tricalcium-phosphate", byproducts = { "apatite", "phosphate", "pyrochlore" }, mass = 31 },   -- GT TricalciumPhosphate: Apatite, Phosphate, Pyrochlore
	["pyrochlore"] = { dust = "pyrochlore", byproducts = { "apatite", "calcite", "niobium-dust" }, mass = 34 },   -- GT Pyrochlore: Apatite, Calcite, Niobium
	["nickel"] = { dust = "nickel-dust", byproducts = { "cobalt-dust", "platinum-dust", "iron-dust" }, mass = 58 },   -- GT Nickel: Cobalt, Platinum, Iron
	["pentlandite"] = { dust = "pentlandite-dust", byproducts = { "iron-dust", "sulfur", "cobalt-dust" }, mass = 45 },   -- GT Pentlandite: Iron, Sulfur, Cobalt
	["cobaltite"] = { dust = "cobalt-dust", byproducts = { "cobalt-dust" }, mass = 55 },   -- GT Cobaltite: Cobalt
	["lazurite"] = { dust = "lazurite-dust", byproducts = { "sodalite-dust", "lapis-dust" }, mass = 29 },   -- GT Lazurite: Sodalite, Lapis
	["sodalite"] = { dust = "sodalite-dust", byproducts = { "lazurite-dust", "lapis-dust" }, mass = 25 },   -- GT Sodalite: Lazurite, Lapis
	["lapis"] = { dust = "lapis-dust", byproducts = { "lazurite-dust", "sodalite-dust", "pyrite-dust" }, mass = 28 },   -- GT Lapis: Lazurite, Sodalite, Pyrite
	["beryllium"] = { dust = "beryllium-dust", byproducts = { "emerald-dust" }, mass = 9 },   -- GT Beryllium: Emerald
	["emerald"] = { dust = "emerald-dust", byproducts = { "beryllium-dust", "alumina" }, mass = 18 },   -- GT Emerald: Beryllium, Aluminiumoxide
	["thorium"] = { dust = "thorium-dust", byproducts = { "uranium-238-dust", "lead-dust" }, mass = 230 },   -- GT Thorium: Uranium, Lead
	["bastnasite"] = { dust = "bastnasite-dust", byproducts = { "neodymium-dust", "rare-earth" }, mass = 36 },   -- GT Bastnasite: Neodymium, RareEarth
	["monazite"] = { dust = "monazite-dust", byproducts = { "thorium-dust", "neodymium-dust", "rare-earth" }, mass = 58 },   -- GT Monazite: Thorium, Neodymium, RareEarth
	["molybdenite"] = { dust = "molybdenite-dust", byproducts = { "molybdenum-dust" }, mass = 53 },   -- GT Molybdenite: Molybdenum
	["neodymium"] = { dust = "neodymium-dust", byproducts = { "monazite-dust", "rare-earth" }, mass = 144 },   -- GT Neodymium: Monazite, RareEarth
	["grossular"] = { dust = "grossular-dust", byproducts = { "yellow-garnet-dust", "calcium" }, mass = 22 },   -- GT Grossular: GarnetYellow, Calcium
	["spessartine"] = { dust = "spessartine-dust", byproducts = { "red-garnet-dust", "manganese-dust" }, mass = 24 },   -- GT Spessartine: GarnetRed, Manganese
	["pyrolusite"] = { dust = "pyrolusite-dust", byproducts = { "manganese-dust", "tantalite-dust", "niobium-dust" }, mass = 29 },   -- GT Pyrolusite: Manganese, Tantalite, Niobium
	["tantalite"] = { dust = "tantalite-dust", byproducts = { "manganese-dust", "niobium-dust", "tantalum-dust" }, mass = 56 },   -- GT Tantalite: Manganese, Niobium, Tantalum
	["bornite"] = { dust = "copper-dust", byproducts = { "copper-dust", "iron-dust", "sulfur" }, mass = 63 },   -- GT Bornite: Copper, Iron, Sulfur
	["sheldonite"] = { dust = "sheldonite-dust", byproducts = { "palladium-dust", "nickel-dust", "iridium-dust" }, mass = 130 },   -- GT Cooperite: Palladium, Nickel, Iridium
	["platinum"] = { dust = "platinum-dust", byproducts = { "nickel-dust", "iridium-dust" }, mass = 195 },   -- GT Platinum: Nickel, Iridium
	["palladium"] = { dust = "palladium-dust", byproducts = {  }, mass = 106 },   -- GT Palladium: no byproducts (itself)
	["scheelite"] = { dust = "scheelite-dust", byproducts = { "manganese-dust", "molybdenum-dust", "calcium" }, mass = 47 },   -- GT Scheelite: Manganese, Molybdenum, Calcium
	["tungstate"] = { dust = "tungstate-dust", byproducts = { "manganese-dust", "silver-dust", "lithium" }, mass = 37 },   -- GT Tungstate: Manganese, Silver, Lithium
	["pitchblende"] = { dust = "pitchblende-dust", byproducts = { "thorium-dust", "uranium-238-dust", "lead-dust" }, mass = 141 },   -- GT Pitchblende: Thorium, Uranium, Lead
	["uraninite"] = { dust = "uraninite-dust", byproducts = { "uranium-238-dust", "thorium-dust", "uranium-235-dust" }, mass = 90 },   -- GT Uraninite: Uranium, Thorium, Uranium235
	["chromite"] = { dust = "chromium-dust", byproducts = { "iron-dust", "magnesium" }, mass = 32 },   -- GT Chromite: Iron, Magnesium
	["ledox"] = { dust = "ledox-dust", byproducts = {  }, mass = 98 },   -- GT Ledox: no byproducts (itself)
	["naquadah"] = { dust = "naquadah-oxide-mixture", byproducts = { "enriched-naquadah-dust" }, mass = 330 },   -- GT Naquadah: NaquadahEnriched
	["firestone"] = { dust = "firestone-dust", byproducts = {  }, mass = 98 },   -- GT Firestone: no byproducts (itself)
	["infused-gold"] = { dust = "infused-gold-dust", byproducts = { "gold-dust" }, mass = 98 },   -- GT InfusedGold: Gold
	["neutronium"] = { dust = "neutronium-dust", byproducts = { "neutronium-dust" }, mass = 100 },   -- GT Neutronium: Neutronium
	["adamantium"] = { dust = "adamantium-dust", byproducts = {  }, mass = 98 },   -- GT Adamantium: no byproducts (itself)
	["black-plutonium"] = { dust = "black-plutonium-dust", byproducts = {  }, mass = 98 },   -- GT BlackPlutonium: no byproducts (itself)
	["borax"] = { dust = "borax", byproducts = {  }, mass = 11 },   -- GT Borax: no byproducts (itself)
	["bedrockium"] = { dust = "bedrockium-dust", byproducts = {  }, mass = 20 },   -- GT Bedrockium: no byproducts (itself)
	["infinity-catalyst"] = { dust = "infinity-catalyst-dust", byproducts = {  }, mass = 98 },   -- GT InfinityCatalyst: no byproducts (itself)
	["cosmic-neutronium"] = { dust = "cosmic-neutronium-dust", byproducts = {  }, mass = 98 },   -- GT CosmicNeutronium: no byproducts (itself)
}
--- skipped: platinum and palladium (their washing is the platinum line's, 146) and firestone (no source of its ore: its
--- recipes stay locked in 142's FORK_RECIPES_LOCKED)
FORK_ORE_CHAIN = { ores = ORE_CHAIN, skip = { platinum = true, palladium = true, firestone = true }, migrated = {} }

local P = "__gregtorio-continued__/graphics/icons/"

local function tech_list(recipe)
	local out = {}
	for name, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and e.recipe == recipe then out[#out + 1] = name end
		end
	end
	table.sort(out)
	return out
end

local function unlock(recipe, techs)
	for _, t in pairs(techs) do fork_add_unlock(t, recipe) end
end

local function item(name, amount, probability)
	return { type = "item", name = name, amount = amount or 1, probability = probability }
end

local function fluid(name, amount)
	return { type = "fluid", name = name, amount = amount }
end

local function recipe(def)
	data:extend({ {
		type = "recipe", name = def.name, category = def.category, enabled = false, energy_required = def.time,
		ingredients = def.ingredients, results = def.results, main_product = def.main, subgroup = def.subgroup,
	} })
	return def.name
end

local function remove_recipe(name)
	if not data.raw.recipe[name] then return end
	data.raw.recipe[name] = nil
	for _, tech in pairs(data.raw.technology) do
		if tech.effects then
			local keep = {}
			for _, e in pairs(tech.effects) do
				if not (e.type == "unlock-recipe" and e.recipe == name) then keep[#keep + 1] = e end
			end
			tech.effects = keep
		end
	end
	log("FORK-REMOVED: recipe " .. name)
end

--- the nine byproducts of GTNH's lists that Gregtorio lacked, with GT's decomposition (ProcessingDust.java:165-266:
--- electrolyzer protons x 2 ticks, centrifuge mass x 4 ticks, per input dust; netherrack: CentrifugeRecipes.java:546)
--- (malachite, the tenth, is GTNH's byproduct of calcite only, which has no crushed form here: not made)
for _, n in pairs({ "andradite-dust", "red-garnet-dust", "yellow-garnet-dust", "lignite-dust", "magnetite-dust",
	"netherrack-dust", "pyrite-dust", "quartzite-dust" }) do
	data:extend({ { type = "item", name = n, icon = P .. n .. ".png", icon_size = 32,
		subgroup = "subgroup-macerator-dust", order = "z-" .. n, stack_size = 100 } })
end
--- GT burns lignite for 1200 ticks, coal for 1600 (GTProxy.java:380-414): three quarters of coal's fuel value
do
	local coal = data.raw.item["coal"]
	if coal and coal.fuel_value then
		local lig = data.raw.item["lignite-dust"]
		local num, unit = coal.fuel_value:match("^([%d%.]+)(%a+)$")
		if num then
			lig.fuel_category = coal.fuel_category or "chemical"
			lig.fuel_value = (tonumber(num) * 0.75) .. unit
		end
	end
end
--- GT's red garnet also gives pyrope and almandine, its yellow garnet uvarovite: Gregtorio has none of them, left out
local DECOMPOSE = {
	{ "andradite-dust", "lv-electrolyzer-recipes", 24, 20,
		{ item("calcium", 3), item("iron-dust", 2), item("raw-silicon", 3), fluid("oxygen", 1200) } },
	{ "red-garnet-dust", "lv-centrifuge-recipes", 73.6, 16, { item("spessartine-dust", 8) } },
	{ "yellow-garnet-dust", "lv-centrifuge-recipes", 73.6, 16, { item("andradite-dust", 5), item("grossular-dust", 8) } },
	{ "lignite-dust", "lv-electrolyzer-recipes", 2, 4, { item("carbon", 3), fluid("water", 100) } },
	{ "magnetite-dust", "lv-electrolyzer-recipes", 10.5, 7, { item("iron-dust", 3), fluid("oxygen", 400) } },
	{ "netherrack-dust", "lv-centrifuge-recipes", 288, 36,
		{ item("redstone-dust", 4, 0.5625), item("sulfur", 9, 0.99), item("coal-dust", 4, 0.5625), item("gold-dust", 1, 0.25) } },
	{ "pyrite-dust", "lv-electrolyzer-recipes", 5.7, 3, { item("iron-dust", 1), item("sulfur", 2) } },
	--- GT has no decomposition of quartzite (a quartz): Gregtorio's, into silicon dioxide
	{ "quartzite-dust", "lv-centrifuge-recipes", 2, 1, { item("silicon-dioxide", 1) } },
}
local decompose_of = {}
for _, d in pairs(DECOMPOSE) do
	local name = d[1] .. "-decomposition"
	recipe{ name = name, category = d[2], time = d[3], ingredients = { item(d[1], d[4]) }, results = d[5],
		main = d[5][1].name }
	decompose_of[d[1]] = name
end

local made = 0
for x, ore in pairs(ORE_CHAIN) do
	local crushed = "crushed-" .. x
	if data.raw.item[crushed] and data.raw.item[ore.dust] and not FORK_ORE_CHAIN.skip[x] then
		made = made + 1
		local b = ore.byproducts
		local function byp(i)
			if #b == 0 then return ore.dust end
			return b[math.min(i, #b)]
		end
		local purified, centrifuged = "purified-" .. x, "centrifuged-" .. x
		local impure, pure = "impure-" .. x .. "-dust", "pure-" .. x .. "-dust"
		local ci = data.raw.item[crushed]
		local csub = ci.subgroup or "subgroup-macerator-crushed"
		local dsub = data.raw.item[ore.dust].subgroup or "subgroup-macerator-dust"
		for _, f in pairs({ { purified, csub, "b" }, { centrifuged, csub, "c" }, { impure, dsub, "b" }, { pure, dsub, "c" } }) do
			data:extend({ { type = "item", name = f[1], icon = P .. f[1] .. ".png", icon_size = 32, subgroup = f[2],
				order = (ci.order or x) .. "-" .. f[3], stack_size = ci.stack_size or 100 } })
		end

		--- the technologies of the recipes this replaces
		local old_wash = data.raw.recipe[ore.dust]
		local wash_ok = old_wash ~= nil and old_wash.category == "lv-ore-washer-recipes"
		local old_cf = "centrifuging-" .. crushed
		local t_crush = tech_list(crushed)
		if #t_crush == 0 then t_crush = tech_list("centrifuging-" .. crushed) end
		local t_cf = tech_list(old_cf)
		local t_wash = wash_ok and tech_list(ore.dust) or t_cf
		if #t_wash == 0 then t_wash = #t_cf > 0 and t_cf or t_crush end
		if #t_cf == 0 then t_cf = t_wash end

		unlock(recipe{ name = purified, category = "lv-ore-washer-recipes", time = 25, main = purified,
			ingredients = { item(crushed), fluid("water", 100) },
			results = { item(purified), item(byp(1), 1, 0.1111) } }, t_wash)
		unlock(recipe{ name = purified .. "-distilled-water", category = "lv-ore-washer-recipes", time = 15, main = purified,
			ingredients = { item(crushed), fluid("distilled-water", 20) },
			results = { item(purified), item(byp(1), 1, 0.1111) } }, t_wash)
		unlock(recipe{ name = centrifuged, category = "lv-thermal-centrifuge-recipes", time = 25, main = centrifuged,
			ingredients = { item(purified) }, results = { item(centrifuged), item(byp(2), 1, 0.1111) } }, t_cf)
		unlock(recipe{ name = centrifuged .. "-from-crushed", category = "lv-thermal-centrifuge-recipes", time = 25,
			main = centrifuged, ingredients = { item(crushed) }, results = { item(centrifuged), item(byp(2), 1, 0.1111) } }, t_cf)
		unlock(recipe{ name = impure, category = "lv-macerator-recipes", time = 20, main = impure,
			ingredients = { item(crushed) }, results = { item(impure), item(byp(1), 1, 0.1) } }, t_crush)
		unlock(recipe{ name = pure, category = "lv-macerator-recipes", time = 20, main = pure,
			ingredients = { item(purified) }, results = { item(pure), item(byp(2), 1, 0.1) } }, t_wash)
		unlock(recipe{ name = centrifuged .. "-maceration", category = "lv-macerator-recipes", time = 20, main = ore.dust,
			ingredients = { item(centrifuged) }, results = { item(ore.dust), item(byp(3), 1, 0.1) } }, t_cf)
		local cf_time = math.max(0.05, ore.mass * 8 / 20)
		unlock(recipe{ name = "centrifuging-" .. impure, category = "lv-centrifuge-recipes", time = cf_time, main = ore.dust,
			ingredients = { item(impure) }, results = { item(ore.dust), item(byp(1), 1, 0.1111) } }, t_cf)
		unlock(recipe{ name = "centrifuging-" .. pure, category = "lv-centrifuge-recipes", time = cf_time, main = ore.dust,
			ingredients = { item(pure) }, results = { item(ore.dust), item(byp(2), 1, 0.1111) } }, t_cf)
		local smelt = data.raw.recipe[ore.dust .. "-smelter"]
		if smelt and smelt.category == "smelting" then
			for _, f in pairs({ { impure, t_crush }, { pure, t_wash } }) do
				local r = table.deepcopy(smelt)
				r.name = f[1] .. "-smelter"
				r.ingredients = { item(f[1]) }
				r.enabled = false
				data:extend({ r })
				unlock(r.name, f[2])
			end
		end
		--- the byproducts Gregtorio lacked come with the recipe that uses them
		for i = 1, 3 do
			local d = decompose_of[byp(i)]
			if d then unlock(d, t_wash) end
		end

		--- the shortcuts go; their names are mapped by the JSON migration
		if wash_ok then
			remove_recipe(ore.dust)
			FORK_ORE_CHAIN.migrated[ore.dust] = purified
		end
		if data.raw.recipe[old_cf] then
			remove_recipe(old_cf)
			FORK_ORE_CHAIN.migrated[old_cf] = "centrifuging-" .. impure
		end
	end
end
--- a technology that unlocks a thermal centrifuge recipe without leading to the LV thermal centrifuge (galena,
--- hydrochloric acid) unlocks the machine too (its parts are there)
do
	local machine_techs = tech_list("lv-thermal-centrifuge")
	local function closure(name, seen)
		seen = seen or {}
		if seen[name] then return seen end
		seen[name] = true
		local tech = data.raw.technology[name]
		for _, pr in pairs(tech and tech.prerequisites or {}) do closure(pr, seen) end
		return seen
	end
	local done = {}
	for name, r in pairs(data.raw.recipe) do
		if r.category == "lv-thermal-centrifuge-recipes" then
			for _, tn in pairs(tech_list(name)) do
				if not done[tn] then
					done[tn] = true
					local cl, reaches = closure(tn), false
					for _, m in pairs(machine_techs) do if cl[m] then reaches = true end end
					if not reaches then
						fork_add_unlock(tn, "lv-thermal-centrifuge")
						log("FORK-ORE-CHAIN: " .. tn .. " unlocks the LV thermal centrifuge too")
					end
				end
			end
		end
	end
end

--- andradite comes from the decomposition of yellow garnet: unlocked with it
unlock(decompose_of["andradite-dust"], tech_list(decompose_of["yellow-garnet-dust"]))
log("FORK-ORE-CHAIN: " .. made .. " ores with GTNH's chain")
