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
	["cassiterite"] = { dust = "cassiterite-dust", byproducts = { "tin-dust" }, mass = 50 },   -- GT Cassiterite: Tin (issue #202: its own crushed ore since then)
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

--- issue #199: GTNH sends every ore processing output through bartworks' PlatinumSludgeOutputs.convert
--- (gtenhancement/PlatinumSludgeOutputs.java, called from ProcessingDirty, ProcessingCrushedOre, ProcessingPure and
--- ProcessingDust): a platinum, palladium or iridium dust becomes two of the platinum line's powder or residue, so the
--- nickel and sheldonite byproducts go through the platinum line (146) as in GTNH. Osmium, ruthenium and rhodium have no
--- dust among the byproducts here.
local PGM_OUTPUT = { ["platinum-dust"] = "metallic-platinum-powder", ["palladium-dust"] = "metallic-palladium-powder",
	["iridium-dust"] = "iridium-metal-residue" }

local function recipe(def)
	for _, r in pairs(def.results or {}) do
		local to = PGM_OUTPUT[r.name]
		if to and r.name ~= def.main and data.raw.item[to] then
			r.name = to
			r.amount = (r.amount or 1) * 2
		end
	end
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
	--- issue #202: cassiterite (SnO2, protons 22: 3 dusts x 44 ticks)
	{ "cassiterite-dust", "lv-electrolyzer-recipes", 6.6, 3, { item("tin-dust", 1), fluid("oxygen", 200) } },
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
		--- the macerator recipes raw ore -> this crushed ore (issue #202: Raw Tin's is macerating-raw-tin)
		local t_crush, seen = {}, {}
		for rname, r in pairs(data.raw.recipe) do
			if r.category == "lv-macerator-recipes" and r.results and #r.results == 1 and r.results[1].name == crushed then
				for _, t in pairs(tech_list(rname)) do
					if not seen[t] then seen[t] = true; t_crush[#t_crush + 1] = t end
				end
			end
		end
		table.sort(t_crush)
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

--------------------------------------------------------------------------------
--- PHASE O2 (issue #186): GTNH's chemical bath washing (OP/ProcessingDirty.java:128-193). The ore itself and then its
--- byproducts are checked in order; the first one tagged WASHING_MERCURY gives crushed + 100 mercury (GT 1000 L) ->
--- purified + that material's dust at 70 %, else the first tagged WASHING_MERCURY_99_PERCENT the same at 99 %; the first
--- tagged WASHING_SODIUMPERSULFATE gives crushed + 10 sodium persulfate (GT 100 L) -> purified + its dust at 70 %. 40 s.
--- The tags (MaterialsInit.java) by Gregtorio ore name and by dust; GT's stone dust (40 %) is left out as in O1. Bornite
--- is bartworks' and only checks its own tags (none). Unlocked with the first technology that comes after the chemical
--- bath, a source of the fluid and the ore washer recipe of the ore (or, if none of them comes after the others, with the
--- technology with the fewest ancestors that has all three before it).
--------------------------------------------------------------------------------
local BATH_TAGS = {
	mercury = { ore = { gold = true, platinum = true, sheldonite = true },
		dust = { ["gold-dust"] = true, ["platinum-dust"] = true, ["sheldonite-dust"] = true, ["osmium-dust"] = true } },
	mercury99 = { ore = { silver = true }, dust = { ["silver-dust"] = true } },
	persulfate = { ore = { copper = true, nickel = true, cobaltite = true, tetrahedrite = true },
		dust = { ["cobalt-dust"] = true, ["copper-dust"] = true, ["nickel-dust"] = true, ["zinc-dust"] = true,
			["tetrahedrite-dust"] = true } },
}
local BATH_SKIP = { bornite = true }

--- the technologies that unlock a recipe making the fluid (an enabled one: none needed)
local function producer_techs(fluid_name)
	local out, free = {}, false
	for name, r in pairs(data.raw.recipe) do
		for _, res in pairs(r.results or {}) do
			if res.type == "fluid" and res.name == fluid_name then
				if r.enabled ~= false then free = true end
				for _, t in pairs(tech_list(name)) do out[#out + 1] = t end
			end
		end
	end
	return out, free
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

--- the earliest technology (fewest ancestors, then by name) of the groups that has one of every group at or before it
local function size(set)
	local n = 0
	for _ in pairs(set) do n = n + 1 end
	return n
end
local function after_all(groups)
	local cand = {}
	for _, g in pairs(groups) do
		for _, t in pairs(g) do cand[t] = true end
	end
	local names = {}
	for t in pairs(cand) do names[#names + 1] = t end
	table.sort(names)
	local found, found_n
	for _, c in pairs(names) do
		local a, ok = ancestors(c), true
		for _, g in pairs(groups) do
			local hit = false
			for _, t in pairs(g) do
				if t == c or a[t] then hit = true break end
			end
			if not hit then ok = false break end
		end
		if ok and (not found or size(a) < found_n) then found, found_n = c, size(a) end
	end
	if found then return found end
	--- none of them comes after the others (the chemical bath and the mercury of the centrifuge are on parallel
	--- branches): the technology with the fewest ancestors that has one of every group before it
	local best, best_n
	for name, tech in pairs(data.raw.technology) do
		if not tech.hidden and tech.enabled ~= false then
			local a, ok = ancestors(name), true
			for _, g in pairs(groups) do
				local hit = false
				for _, t in pairs(g) do
					if a[t] then hit = true break end
				end
				if not hit then ok = false break end
			end
			if ok then
				local n = 0
				for _ in pairs(a) do n = n + 1 end
				if not best or n < best_n or (n == best_n and name < best) then best, best_n = name, n end
			end
		end
	end
	if best then log("FORK-ORE-CHAIN: a recipe after parallel technologies goes to " .. best) end
	return best
end

local bath_techs = tech_list("lv-chemical-bath")
local fluid_techs = {}
for _, f in pairs({ "mercury", "sodium-persulfate" }) do
	local techs, free = producer_techs(f)
	fluid_techs[f] = (not free) and techs or nil
end

local baths = 0
for x, ore in pairs(ORE_CHAIN) do
	local purified, crushed = "purified-" .. x, "crushed-" .. x
	if data.raw.recipe[purified] and not BATH_SKIP[x] then
		local found = {}
		local list = { { name = ore.dust, self = true } }
		for _, b in pairs(ore.byproducts) do list[#list + 1] = { name = b } end
		for _, e in pairs(list) do
			local function tagged(tag)
				return (e.self and BATH_TAGS[tag].ore[x]) or ((not e.self) and BATH_TAGS[tag].dust[e.name])
			end
			if not found.mercury and tagged("mercury") then
				found.mercury = { e.name, 0.7 }
			elseif not found.mercury and tagged("mercury99") then
				found.mercury = { e.name, 0.99 }
			end
			if not found.persulfate and tagged("persulfate") then found.persulfate = { e.name, 0.7 } end
		end
		for _, k in pairs({ { "mercury", "mercury", 100 }, { "persulfate", "sodium-persulfate", 10 } }) do
			local f = found[k[1]]
			if f then
				local groups = { bath_techs, tech_list(purified) }
				if fluid_techs[k[2]] then groups[#groups + 1] = fluid_techs[k[2]] end
				local tech = after_all(groups)
				local name = purified .. "-" .. k[2]
				recipe{ name = name, category = "lv-chemical-bath-recipes", time = 40, main = purified,
					ingredients = { item(crushed), fluid(k[2], k[3]) }, results = { item(purified), item(f[1], 1, f[2]) } }
				if tech then
					fork_add_unlock(tech, name)
				else
					log("FORK-ORE-CHAIN: no technology after the chemical bath, " .. k[2] .. " and " .. purified .. " for " .. name)
				end
				baths = baths + 1
			end
		end
	end
end
log("FORK-ORE-CHAIN: " .. baths .. " chemical bath washing recipes")

--------------------------------------------------------------------------------
--- PHASES O3 AND O4 (issues #187 and #188): unlocks. A recipe goes to the first technology after a machine of its
--- category and the recipe that makes its input (after_all); an input made from the start counts as given, and a
--- recipe whose machine and input are both there from the start is enabled.
--------------------------------------------------------------------------------
local techs_of_recipe = {}
for tname, tech in pairs(data.raw.technology) do
	for _, e in pairs(tech.effects or {}) do
		if e.type == "unlock-recipe" then
			techs_of_recipe[e.recipe] = techs_of_recipe[e.recipe] or {}
			table.insert(techs_of_recipe[e.recipe], tname)
		end
	end
end
local makers = {}   -- item -> recipes that make it
for rname, r in pairs(data.raw.recipe) do
	for _, res in pairs(r.results or {}) do
		makers[res.name] = makers[res.name] or {}
		table.insert(makers[res.name], rname)
	end
end
--- the technologies that give an item (nil: it is there from the start)
local function item_techs(name)
	local out = {}
	for _, rname in pairs(makers[name] or {}) do
		local r = data.raw.recipe[rname]
		if r.enabled ~= false and not r.hidden then return nil end
		for _, t in pairs(techs_of_recipe[rname] or {}) do out[#out + 1] = t end
	end
	return out
end
local machine_techs_cache = {}
--- the technologies that give a machine of a category (nil: one is there from the start)
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
--- unlock a recipe after its machine and its inputs (each a list of technologies, nil = there from the start)
local function unlock_after(name, groups)
	local g = {}
	for _, x in pairs(groups) do
		if x ~= nil and x ~= false then
			if #x == 0 then
				log("FORK-ORE-CHAIN: nothing gives an input of " .. name)
				return
			end
			g[#g + 1] = x
		end
	end
	local r = data.raw.recipe[name]
	if #g == 0 then
		r.enabled = true
		return
	end
	local tech = after_all(g)
	if tech then
		fork_add_unlock(tech, name)
		techs_of_recipe[name] = { tech }
	else
		log("FORK-ORE-CHAIN: no technology for " .. name)
	end
end
local function add_item(name, sub, order, extra)
	local it = { type = "item", name = name, icon = P .. name .. ".png", icon_size = 32, subgroup = sub,
		order = order, stack_size = 64 }
	for k, v in pairs(extra or {}) do it[k] = v end
	data:extend({ it })
	makers[name] = makers[name] or {}
end
local function made(rname)
	local r = data.raw.recipe[rname]
	for _, res in pairs(r.results or {}) do
		makers[res.name] = makers[res.name] or {}
		table.insert(makers[res.name], rname)
	end
	return rname
end
local function sub_of(name, default)
	local it = data.raw.item[name]
	return it and it.subgroup or default
end
local the_ores = {}
for x in pairs(ORE_CHAIN) do
	if data.raw.recipe["purified-" .. x] then the_ores[#the_ores + 1] = x end
end
table.sort(the_ores)

--------------------------------------------------------------------------------
--- PHASE O3 (issue #187): GTNH's Electromagnetic Separator (OP/ProcessingDust.java:406-449). The pure dust of an ore
--- tagged GOLD, IRON or NEODYMIUM (MaterialsInit.java; appendix B, column EM separator) -> its dust, a small dust of the
--- metal at 40 % and a nugget of it at 20 %, 20 s (GT 400 ticks, 24 EU/t). The small dusts and nuggets are new (decision
--- on #187): 4 small dusts make a dust at the crafting table (GT's shapeless recipe; GT's packager recipe needs a machine
--- Gregtorio lacks), 9 nuggets an ingot in the alloy smelter with the mold (GT ProcessingNugget.java:47-55, 10 s).
--------------------------------------------------------------------------------
local EMS_TAG = {
	["vanadium-magnetite"] = "gold",
	tin = "iron", ilmenite = "iron", nickel = "iron", pentlandite = "iron", chromite = "iron", bornite = "iron",
	bastnasite = "neodymium", monazite = "neodymium",
}
local EMS_CAT = "lv-electromagnetic-separator-recipes"
for _, m in pairs({ "gold", "iron", "neodymium" }) do
	local dust, ingot = m .. "-dust", m .. "-ingot"
	local small, nugget = "small-pile-of-" .. m .. "-dust", m .. "-nugget"
	add_item(small, sub_of(dust, "subgroup-macerator-dust"), "z-" .. small)
	add_item(nugget, sub_of(ingot, "subgroup-smelting"), "z-" .. nugget)
end
local separations = 0
for _, x in pairs(the_ores) do
	local m = EMS_TAG[x]
	if m then
		local ore, pure = ORE_CHAIN[x], "pure-" .. x .. "-dust"
		local name = made(recipe{ name = "separating-" .. pure, category = EMS_CAT, time = 20, main = ore.dust,
			ingredients = { item(pure) },
			results = { item(ore.dust), item("small-pile-of-" .. m .. "-dust", 1, 0.4), item(m .. "-nugget", 1, 0.2) } })
		unlock_after(name, { machine_techs(EMS_CAT), techs_of_recipe[pure] })
		separations = separations + 1
	end
end
for _, m in pairs({ "gold", "iron", "neodymium" }) do
	local small, nugget = "small-pile-of-" .. m .. "-dust", m .. "-nugget"
	local name = made(recipe{ name = m .. "-dust-from-small-piles", category = "crafting", time = 0.5, main = m .. "-dust",
		ingredients = { item(small, 4) }, results = { item(m .. "-dust") } })
	unlock_after(name, { item_techs(small) })
	if data.raw.item[m .. "-ingot"] then
		--- in the alloy smelter's row (the ingot's row is in the Material parts tab, which has items only)
		name = made(recipe{ name = m .. "-ingot-from-nuggets", category = "lv-alloy-smelter-recipes", time = 10,
			subgroup = "subgroup-lv-alloy-smelter-recipes", main = m .. "-ingot", ingredients = { item(nugget, 9), item("mold") },
			results = { item(m .. "-ingot"), item("mold") } })
		unlock_after(name, { machine_techs("lv-alloy-smelter-recipes"), item_techs(nugget) })
	end
end
log("FORK-ORE-CHAIN: " .. separations .. " electromagnetic separator recipes")

--------------------------------------------------------------------------------
--- PHASE O4 (issue #188), 1: the gems. GT's grades (chipped, flawed, gem, flawless, exquisite) for the gem ores of the
--- sifter (OP/ProcessingCrushedOre.java:80-122), new items where Gregtorio had none (decision on #188; diamond had
--- them), and the gems Gregtorio lacked (apatite, tricalcium phosphate, lazurite, sodalite, monazite: their "gem" was
--- the dust; named <x>-gem, an item "monazite" is in a draft recipe of the monazite line). Uses as GT's
--- (OP/ProcessingGem.java, ProcessingLens.java):
---   forge hammer        exquisite -> 2 flawless -> 2 gems -> 2 flawed -> 2 chipped (3.2 s)
---   implosion           3 chipped -> flawed, 3 flawed -> gem, 3 gems -> flawless, 3 flawless -> exquisite, with an
---                       explosive (GT: 8 TNT, Gregtorio's iridium plate takes one explosive for GT's 8) (1 s)
---                       and 2 tiny piles of dark ash (issue #193)
---   lathe               exquisite -> 3 lenses + a dust for GT's gem lenses: ruby, emerald, diamond (2 min; the
---                       emerald and diamond lens are new, issue #193)
---   laser engraver      3 chipped -> flawed (30 s, LV), 3 flawed -> gem (30 s, MV), 3 gems -> flawless (60 s, HV),
---                       3 flawless -> exquisite (2 min, EV), with a lens of the gem's colour that stays (issue #193):
---                       red the ruby lens (ruby), green the emerald lens (emerald, monazite), white the diamond lens
---                       (diamond, nether quartz). GT's other colours (certus quartz light gray, apatite and lazurite
---                       cyan, tricalcium phosphate yellow, sodalite and lapis blue) come from lenses of materials
---                       Gregtorio lacks (sapphire, topaz ...): no engraver steps for them. Gregtorio's laser engraver
---                       starts at MV: the LV step is in the MV category with its LV time (an MV engraver runs it
---                       twice as fast, as GT's overclock)
---   macerator           the grades back into dust: chipped 1 small pile, flawed 2 small piles of the gem's dust
---                       (new, issue #193; 4 make a dust at the crafting table), flawless 2, exquisite 4 dusts; the new
---                       gems -> 1 dust. Times scaled from Gregtorio's diamond (2.8 s per gem)
--- Dark ash (GT's AshDark, issue #193): 9 tiny piles make a dust at the crafting table, the dust -> carbon in the
--- electrolyzer (GT's electrolyzer recipe of the material, carbon's 6 protons x 2 ticks).
--------------------------------------------------------------------------------
local GEMS = {
	--  ore                         gem item                    table       crystallisable (autoclave)
	{ "ruby",                 "ruby",                     "precious", false },
	{ "emerald",              "emerald",                  "precious", false },
	{ "diamond",              "diamond",                  "precious", false },
	{ "nether-quartz",        "nether-quartz",            "default",  true },
	{ "certus-quartz",        "certus-quartz",            "default",  true },
	{ "apatite",              "apatite-gem",              "default",  true },
	{ "tricalcium-phosphate", "tricalcium-phosphate-gem", "default",  false },
	{ "lazurite",             "lazurite-gem",             "default",  true },
	{ "sodalite",             "sodalite-gem",             "default",  true },
	{ "lapis",                "lapis-lazuli",             "default",  true },
	{ "monazite",             "monazite-gem",             "default",  true },
}
--- GT's sifter tables: exquisite, flawless, gem, flawed, chipped, dust (ProcessingCrushedOre.java:90-120)
local SIFT = { precious = { 0.03, 0.12, 0.45, 0.14, 0.28, 0.35 }, default = { 0.01, 0.04, 0.15, 0.20, 0.40, 0.50 } }
local GRADES = { "chipped", "flawed", "gem", "flawless", "exquisite" }
--- dusts (count, or small piles for the two lower grades)
local MACERATE = { chipped = { 1, small = true }, flawed = { 2, small = true }, gem = { 1 }, flawless = { 2 }, exquisite = { 4 } }
--- the lenses the lathe makes from an exquisite gem (GT: the gems whose material keeps the lens prefix)
--- issue #205: the red and yellow garnet lens (GT's GarnetRed and GarnetYellow keep the lens prefix)
local LENS = { ruby = "ruby-lens", emerald = "emerald-lens", diamond = "diamond-lens", ["red-garnet"] = "red-garnet-lens",
	["yellow-garnet"] = "yellow-garnet-lens" }
--- the lens of the gem's colour for the laser engraver (MaterialsInit.java setColor; GT takes any lens of the colour)
--- (issue #205: quartzite white, red garnet red, yellow garnet yellow; tricalcium phosphate, yellow, gets the yellow garnet
--- lens after the byproduct gems below)
local ENGRAVER_LENS = { ruby = "ruby-lens", emerald = "emerald-lens", monazite = "emerald-lens",
	diamond = "diamond-lens", ["nether-quartz"] = "diamond-lens", quartzite = "diamond-lens", ["red-garnet"] = "ruby-lens",
	["yellow-garnet"] = "yellow-garnet-lens" }
--- grade -> the engraver category and time of the step up (GT tier: LV, MV, HV, EV; time x the tier's speed)
local ENGRAVE = { chipped = { "mv-laser-engraver-recipes", 30 }, flawed = { "mv-laser-engraver-recipes", 60 },
	gem = { "hv-laser-engraver-recipes", 240 }, flawless = { "ev-laser-engraver-recipes", 960 } }

--- issue #193: GT's dark ash, the implosion's waste
local DARK_TINY, DARK_DUST = "tiny-pile-of-dark-ash-dust", "dark-ash-dust"
add_item(DARK_TINY, "subgroup-macerator-dust", "z-dark-ash-a")
add_item(DARK_DUST, "subgroup-macerator-dust", "z-dark-ash-b")
for _, lens in pairs({ "emerald-lens", "diamond-lens", "red-garnet-lens", "yellow-garnet-lens" }) do
	if not data.raw.item[lens] then add_item(lens, sub_of("ruby-lens", "subgroup-lv-lathe-recipes"), "z-" .. lens) end
end

local function macerates(name)
	for rname, r in pairs(data.raw.recipe) do
		if r.category and r.category:match("%-macerator%-recipes$") and r.ingredients and #r.ingredients == 1
			and r.ingredients[1].name == name then return rname end
	end
end

--- issue #205: unlock now, or (pending given) later, when every input has a producer (grades that only their own
--- recipes make)
local function later(pending, name, groups)
	if pending then pending[#pending + 1] = { name, groups } else unlock_after(name, groups()) end
end
--- unlock the pending recipes in the order their inputs get a producer
local function unlock_pending(pending)
	local progress = true
	while progress and #pending > 0 do
		progress = false
		local rest = {}
		for _, p in pairs(pending) do
			local ready = true
			for _, g in pairs(p[2]()) do
				if g ~= nil and g ~= false and #g == 0 then ready = false end
			end
			if ready then
				unlock_after(p[1], p[2]())
				progress = true
			else
				rest[#rest + 1] = p
			end
		end
		pending = rest
	end
	for _, p in pairs(pending) do unlock_after(p[1], p[2]()) end   -- logs what nothing gives
end

--- the laser engraver steps of a gem's grades with a lens of its colour, which stays; returns the number of recipes
local function engrave(grade, lens, pending)
	local n = 0
	for i, k in pairs(GRADES) do
		local up = GRADES[i + 1]
		if up then
			local e = ENGRAVE[k]
			local name = made(recipe{ name = "engraving-" .. grade[k] .. "-to-" .. up, category = e[1], time = e[2],
				main = grade[up], ingredients = { item(grade[k], 3), item(lens) }, results = { item(grade[up]), item(lens) } })
			later(pending, name, function() return { machine_techs(e[1]), item_techs(grade[k]), item_techs(lens) } end)
			n = n + 1
		end
	end
	return n
end

--- the grades of a gem material x (grade: its chipped, flawed, gem, flawless and exquisite items) and its dust: the
--- small piles, the lathe's lens, forge hammer, implosion, laser engraver and macerator steps; returns the number of recipes
local function gem_grades(x, grade, dust, pending)
	local n = 0
	--- issue #193: the small piles of the gem's dust (from chipped and flawed gems)
	local small = "small-pile-of-" .. x .. "-dust"
	if not data.raw.item[small] then add_item(small, sub_of(dust, "subgroup-macerator-dust"), "z-" .. small) end

	local name
	--- the lens first: the engraver steps below need it
	if LENS[x] and data.raw.item[LENS[x]] then
		name = made(recipe{ name = LENS[x] .. "-from-exquisite", category = "lv-lathe-recipes", time = 120, main = LENS[x],
			ingredients = { item(grade.exquisite) }, results = { item(LENS[x], 3), item(dust) } })
		later(pending, name, function() return { machine_techs("lv-lathe-recipes"), item_techs(grade.exquisite) } end)
		n = n + 1
	end

	--- the grades into each other and back into dust
	for i, k in pairs(GRADES) do
		local up, down = GRADES[i + 1], GRADES[i - 1]
		if down then
			name = made(recipe{ name = "hammering-" .. grade[k], category = "lv-forge-hammer-recipes", time = 3.2,
				main = grade[down], ingredients = { item(grade[k]) }, results = { item(grade[down], 2) } })
			later(pending, name, function() return { machine_techs("lv-forge-hammer-recipes"), item_techs(grade[k]) } end)
			n = n + 1
		end
		if up then
			name = made(recipe{ name = "implosion-" .. grade[k] .. "-to-" .. up, category = "lv-implosion-compressor-recipes",
				time = 1, main = grade[up], ingredients = { item(grade[k], 3), item("explosives") },
				results = { item(grade[up]), item(DARK_TINY, 2) } })
			later(pending, name, function() return { machine_techs("lv-implosion-compressor-recipes"), item_techs(grade[k]),
				item_techs("explosives") } end)
			n = n + 1
		end
		if not macerates(grade[k]) then
			local mac = MACERATE[k]
			local out = mac.small and small or dust
			name = made(recipe{ name = grade[k] .. "-maceration", category = "lv-macerator-recipes",
				time = mac.small and 0.7 * mac[1] or 2.8 * mac[1], main = out, ingredients = { item(grade[k]) },
				results = { item(out, mac[1]) } })
			later(pending, name, function() return { machine_techs("lv-macerator-recipes"), item_techs(grade[k]) } end)
			n = n + 1
		end
	end
	name = made(recipe{ name = dust .. "-from-small-piles", category = "crafting", time = 0.5, main = dust,
		ingredients = { item(small, 4) }, results = { item(dust) } })
	later(pending, name, function() return { item_techs(small) } end)
	n = n + 1
	if ENGRAVER_LENS[x] then n = n + engrave(grade, ENGRAVER_LENS[x], pending) end
	return n
end

local gem_recipes = 0
for _, g in pairs(GEMS) do
	local x, gem, tbl = g[1], g[2], g[3]
	local ore = ORE_CHAIN[x]
	local purified = "purified-" .. x
	if ore and data.raw.recipe[purified] then
		local grade = { gem = gem }
		for _, k in pairs({ "chipped", "flawed", "flawless", "exquisite" }) do grade[k] = k .. "-" .. x end
		local sub = sub_of(gem, sub_of(ore.dust, "subgroup-macerator-dust"))
		if not data.raw.item[gem] then
			add_item(gem, sub, "z-" .. x .. "-c")
		end
		for i, k in pairs({ "chipped", "flawed", "flawless", "exquisite" }) do
			if not data.raw.item[grade[k]] then add_item(grade[k], sub, "z-" .. x .. "-" .. ({ "a", "b", "d", "e" })[i]) end
		end

		--- the sifter (diamond's recipe of upstream sifts crushed diamond: GT sifts the purified ore)
		local chances = SIFT[tbl]
		local name = (x == "diamond" and data.raw.recipe["diamond-sifter"]) and "diamond-sifter" or ("sifting-" .. purified)
		if name == "diamond-sifter" then data.raw.recipe[name] = nil end
		recipe{ name = name, category = "lv-sifter-recipes", time = 40, main = gem, ingredients = { item(purified) },
			results = { item(grade.exquisite, 1, chances[1]), item(grade.flawless, 1, chances[2]), item(gem, 1, chances[3]),
				item(grade.flawed, 1, chances[4]), item(grade.chipped, 1, chances[5]), item(ore.dust, 1, chances[6]) } }
		made(name)
		unlock_after(name, { machine_techs("lv-sifter-recipes"), techs_of_recipe[purified] })
		gem_recipes = gem_recipes + 1

		gem_recipes = gem_recipes + gem_grades(x, grade, ore.dust)

		--- PHASE O4, 2: the autoclave grows the gem from impure and pure dust of the crystallisable ores
		--- (OP/ProcessingDust.java:450-479): 200 L water (here 20) 90 % / 95 % in 100 s, 100 L distilled water (10)
		--- 95 % / 100 % in 75 s. GT's third variant with molten Void is not made: 137-fork-endgame-materials.lua
		--- removed void metal (a Thaumcraft material) on purpose (issue #193).
		if g[4] then
			for _, d in pairs({ { "impure-" .. x .. "-dust", 0.9, 0.95 }, { "pure-" .. x .. "-dust", 0.95, 1 } }) do
				for _, w in pairs({ { "water", 20, 100, d[2], "" }, { "distilled-water", 10, 75, d[3], "-distilled-water" } }) do
					name = made(recipe{ name = "autoclave-" .. d[1] .. w[5], category = "lv-autoclave-recipes", time = w[3],
						main = gem, ingredients = { item(d[1]), fluid(w[1], w[2]) },
						results = { item(gem, 1, w[4] < 1 and w[4] or nil) } })
					unlock_after(name, { machine_techs("lv-autoclave-recipes"), item_techs(d[1]) })
					gem_recipes = gem_recipes + 1
				end
			end
		end
	end
end
do
	local name = made(recipe{ name = DARK_DUST .. "-from-tiny-piles", category = "crafting", time = 0.5, main = DARK_DUST,
		ingredients = { item(DARK_TINY, 9) }, results = { item(DARK_DUST) } })
	unlock_after(name, { item_techs(DARK_TINY) })
	name = made(recipe{ name = DARK_DUST .. "-electrolysis", category = "lv-electrolyzer-recipes", time = 0.6, main = "carbon",
		ingredients = { item(DARK_DUST) }, results = { item("carbon") } })
	unlock_after(name, { machine_techs("lv-electrolyzer-recipes"), item_techs(DARK_DUST) })
end
log("FORK-ORE-CHAIN: " .. gem_recipes .. " gem recipes (sifter, grades, lenses, engraver, autoclave)")

--------------------------------------------------------------------------------
--- Issue #205, 1: GT's gems of four byproduct materials Gregtorio had as dusts only (MaterialsInit.java addGemItems:
--- Lignite, Quartzite, GarnetRed, GarnetYellow), with GT's grades: the raw ore macerator gives them (part 3), their
--- recipes follow it (end of the file). Lignite coal burns like lignite dust (GTProxy.java:380-391: gem and dust 1200
--- ticks, a small pile 375).
--------------------------------------------------------------------------------
local BYPRODUCT_GEMS = {
	--  material          dust                  gem
	{ "lignite",       "lignite-dust",       "lignite-gem" },
	{ "quartzite",     "quartzite-dust",     "quartzite-gem" },
	{ "red-garnet",    "red-garnet-dust",    "red-garnet-gem" },
	{ "yellow-garnet", "yellow-garnet-dust", "yellow-garnet-gem" },
}
for _, g in pairs(BYPRODUCT_GEMS) do
	local sub = sub_of(g[2], "subgroup-macerator-dust")
	local dust = data.raw.item[g[2]]
	add_item(g[3], sub, "z-" .. g[1] .. "-c", dust.fuel_value and { fuel_category = dust.fuel_category,
		fuel_value = dust.fuel_value } or nil)
	for i, k in pairs({ "chipped", "flawed", "flawless", "exquisite" }) do
		add_item(k .. "-" .. g[1], sub, "z-" .. g[1] .. "-" .. ({ "a", "b", "d", "e" })[i])
	end
end

--------------------------------------------------------------------------------
--- PHASE O4, 3: forge hammer crushing (OP/ProcessingRawOre.java:201-212, ProcessingDirty.java:43-49,
--- ProcessingPure.java:163-168, ProcessingCrushedOre.java:37-44): raw ore -> crushed ore (GT's ore multiplier, half
--- of the macerator's), crushed -> impure dust, purified -> pure dust, centrifuged -> dust, each 10 ticks (0.5 s), in
--- every forge hammer (the steam one runs the LV category too). No byproducts, as in GT.
--- Issue #202: GTNH's raw ore recipes for every raw ore with a macerator recipe to a crushed item
--- (OP/ProcessingRawOre.java registerStandardOreRecipes; bornite: bartworks RawOreLoader.java), the ore multiplier is
--- GT's (07): the forge hammer gives the multiplier x the crushed ore, or x the gem where GT's material has one
--- (FORK_ORE_HAMMER_GEM); the macerator 2 x the multiplier crushed ores and the first of GT's byproducts at 5 % x GT's
--- byproduct multiplier (an ore without byproducts: its own dust), as a gem where GT's byproduct material has one and
--- Gregtorio the item (lignite, quartzite and the garnets have none here: their dust), platinum group dusts as the
--- platinum line's powders (#199); GT's stone dust is left out (phase O1). Hammer recipes are named after the raw ore.
--- FORK_ORE_HAMMER_SKIP: raw ores without them on purpose, with the reason (devcheck fails for any other).
--------------------------------------------------------------------------------
FORK_ORE_HAMMER_SKIP = {
	["raw-firestone-ore"] = "no source of firestone ore: its macerator recipe stays locked (142's FORK_RECIPES_LOCKED)",
}
FORK_ORE_HAMMER_GEM = {
	["raw-coal"] = "coal", ["raw-ruby"] = "ruby", ["raw-emerald"] = "emerald", ["raw-diamond"] = "diamond",
	["raw-lapis"] = "lapis-lazuli", ["raw-lazurite"] = "lazurite-gem", ["raw-sodalite"] = "sodalite-gem",
	["raw-apatite"] = "apatite-gem", ["raw-certus-quartz"] = "certus-quartz", ["raw-nether-quartz"] = "nether-quartz",
	["raw-monazite"] = "monazite-gem", ["raw-tricalcium-phosphate"] = "tricalcium-phosphate-gem",
}
--- the first byproduct of the ores ORE_CHAIN leaves out (GT Platinum: Nickel; GT Palladium: none, its own dust)
local RAW_BYPRODUCT = { ["raw-platinum"] = "nickel-dust", ["raw-palladium"] = "palladium-dust" }
--- GT's gems of byproduct materials that Gregtorio has
local BYPRODUCT_GEM = { ["emerald-dust"] = "emerald", ["apatite"] = "apatite-gem",
	["tricalcium-phosphate"] = "tricalcium-phosphate-gem", ["lazurite-dust"] = "lazurite-gem",
	["sodalite-dust"] = "sodalite-gem", ["monazite-dust"] = "monazite-gem" }
for _, g in pairs(BYPRODUCT_GEMS) do BYPRODUCT_GEM[g[2]] = g[3] end   -- issue #205
--- GT's byproduct multipliers (Materials.java setByProductMultiplier; 1 for every other ore)
local BYPRODUCT_MULT = { ["raw-apatite"] = 2, ["raw-coal"] = 2, ["raw-cryolite"] = 4, ["raw-lapis"] = 4,
	["raw-sodalite"] = 4, ["raw-lazurite"] = 4, ["raw-monazite"] = 2 }
local hammered = 0
local macerated = {}
for rname, r in pairs(data.raw.recipe) do
	if r.category == "lv-macerator-recipes" and not r.hidden and #(r.ingredients or {}) == 1 then
		local raw = r.ingredients[1].name or ""
		if raw:sub(1, 4) == "raw-" and data.raw.item[raw] and r.ingredients[1].amount == 1
			and not FORK_ORE_HAMMER_SKIP[raw] then
			for _, res in pairs(r.results or {}) do
				if (res.name or ""):sub(1, 8) == "crushed-" and data.raw.item[res.name] and res.amount then
					macerated[#macerated + 1] = { raw, res.name, math.max(1, math.floor(res.amount / 2)), rname }
				end
			end
		end
	end
end
table.sort(macerated, function(a, b) return a[4] < b[4] end)
local byproducts = 0
for _, s in pairs(macerated) do
	local out = FORK_ORE_HAMMER_GEM[s[1]] or s[2]
	local name = made(recipe{ name = "hammering-" .. s[1], category = "lv-forge-hammer-recipes", time = 0.5, main = out,
		ingredients = { item(s[1]) }, results = { item(out, s[3]) } })
	unlock_after(name, { machine_techs("lv-forge-hammer-recipes"), item_techs(s[1]) })
	hammered = hammered + 1
	local ore = ORE_CHAIN[s[1]:sub(5)]
	local byp = RAW_BYPRODUCT[s[1]] or (ore and (ore.byproducts[1] or ore.dust))
	if byp then
		byp = BYPRODUCT_GEM[byp] or byp
		local amount = 1
		if PGM_OUTPUT[byp] and data.raw.item[PGM_OUTPUT[byp]] then byp, amount = PGM_OUTPUT[byp], 2 end
		local mac = data.raw.recipe[s[4]]
		table.insert(mac.results, item(byp, amount, 0.05 * (BYPRODUCT_MULT[s[1]] or 1)))
		mac.main_product = s[2]
		made(s[4])
		byproducts = byproducts + 1
	else
		log("FORK-ORE-CHAIN: no byproduct known for the macerator recipe " .. s[4])
	end
end
log("FORK-ORE-CHAIN: " .. byproducts .. " raw ore macerator recipes with GT's byproduct")
--- issue #202: cassiterite dust, new with its own crushed ore, decomposes in the electrolyzer
unlock_after(decompose_of["cassiterite-dust"], { machine_techs("lv-electrolyzer-recipes"), item_techs("cassiterite-dust") })
for _, x in pairs(the_ores) do
	local ore = ORE_CHAIN[x]
	local crushed = "crushed-" .. x
	local steps = {
		{ crushed, "impure-" .. x .. "-dust", 1 },
		{ "purified-" .. x, "pure-" .. x .. "-dust", 1 },
		{ "centrifuged-" .. x, ore.dust, 1 },
	}
	for _, s in pairs(steps) do
		local name = made(recipe{ name = "hammering-" .. s[1], category = "lv-forge-hammer-recipes", time = 0.5, main = s[2],
			ingredients = { item(s[1]) }, results = { item(s[2], s[3]) } })
		unlock_after(name, { machine_techs("lv-forge-hammer-recipes"), item_techs(s[1]) })
		hammered = hammered + 1
	end
end
log("FORK-ORE-CHAIN: " .. hammered .. " forge hammer crushing recipes")

--------------------------------------------------------------------------------
--- Issue #205, 1 (continued): the grades of the four byproduct gems (as the sifted gems' above: hammer, implosion,
--- lathe lens, engraver with a lens of the colour, macerator into dust and small piles); tricalcium phosphate (yellow)
--- gets the engraver steps with the new yellow garnet lens. GT's ways from dust to gem (OP/ProcessingDust.java:269-297,
--- 326-395): the crystallisable gems grow in the autoclave from their dust (200 L water, here 20, 70 % in 100 s; 100 L
--- distilled water, here 10, 90 % in 75 s; 24 EU/t, LV; upstream's MV autoclave recipe of a gem becomes the distilled
--- water one; GT's Void variant is not made, see O4 above), ruby, emerald, the garnets and monazite are imploded (4 dusts
--- -> 3 gems in 1 s, LV, with GT's TNT as explosives, one for GT's 8 TNT: ruby and emerald 24 TNT and 12 tiny piles of
--- dark ash, the garnets and monazite 16 and 8). Upstream's autoclave recipes of ruby, emerald and diamond have no GT
--- counterpart and stay.
--------------------------------------------------------------------------------
local late_gems = 0
local pending = {}
for _, g in pairs(BYPRODUCT_GEMS) do
	local grade = { gem = g[3] }
	for _, k in pairs({ "chipped", "flawed", "flawless", "exquisite" }) do grade[k] = k .. "-" .. g[1] end
	late_gems = late_gems + gem_grades(g[1], grade, g[2], pending)
end
do
	--- a small pile of lignite burns 375 of the dust's 1200 ticks
	local lig, small = data.raw.item["lignite-dust"], data.raw.item["small-pile-of-lignite-dust"]
	local num, unit = (lig.fuel_value or ""):match("^([%d%.]+)(%a+)$")
	if num and small then
		small.fuel_category = lig.fuel_category
		small.fuel_value = (tonumber(num) * 375 / 1200) .. unit
	end
	local tcp = { gem = "tricalcium-phosphate-gem" }
	for _, k in pairs({ "chipped", "flawed", "flawless", "exquisite" }) do tcp[k] = k .. "-tricalcium-phosphate" end
	if data.raw.item[tcp.chipped] then late_gems = late_gems + engrave(tcp, "yellow-garnet-lens", pending) end
end
unlock_pending(pending)
local DUST_GEMS = {
	--  dust                    gem                         autoclave  implosion: explosives, tiny piles of dark ash
	{ "nether-quartz-dust",  "nether-quartz",            true },
	{ "certus-quartz-dust",  "certus-quartz",            true },
	{ "apatite",             "apatite-gem",              true },
	{ "lazurite-dust",       "lazurite-gem",             true },
	{ "sodalite-dust",       "sodalite-gem",             true },
	{ "lapis-dust",          "lapis-lazuli",             true },
	{ "monazite-dust",       "monazite-gem",             true,      { 2, 8 } },
	{ "quartzite-dust",      "quartzite-gem",            true },
	{ "ruby-dust",           "ruby",                     false,     { 3, 12 } },
	{ "emerald-dust",        "emerald",                  false,     { 3, 12 } },
	{ "red-garnet-dust",     "red-garnet-gem",           false,     { 2, 8 } },
	{ "yellow-garnet-dust",  "yellow-garnet-gem",        false,     { 2, 8 } },
}
for _, g in pairs(DUST_GEMS) do
	local dust, gem = g[1], g[2]
	if data.raw.item[dust] and data.raw.item[gem] then
		if g[3] then
			--- upstream's autoclave recipe of the gem (MV, 5 distilled water) is GT's distilled water one
			local upstream
			for rname, r in pairs(data.raw.recipe) do
				if r.category and r.category:match("%-autoclave%-recipes$") and r.ingredients and #r.ingredients == 2
					and r.ingredients[1].name == dust and r.results and #r.results == 1 and r.results[1].name == gem then
					upstream = rname
				end
			end
			local name = recipe{ name = "autoclave-" .. dust, category = "lv-autoclave-recipes", time = 100, main = gem,
				ingredients = { item(dust), fluid("water", 20) }, results = { item(gem, 1, 0.7) } }
			unlock_after(made(name), { machine_techs("lv-autoclave-recipes"), item_techs(dust) })
			local r = upstream and data.raw.recipe[upstream]
			if r then
				r.category, r.energy_required = "lv-autoclave-recipes", 75
				r.ingredients = { item(dust), fluid("distilled-water", 10) }
				r.results = { item(gem, 1, 0.9) }
				r.main_product = gem
			else
				name = recipe{ name = "autoclave-" .. dust .. "-distilled-water", category = "lv-autoclave-recipes", time = 75,
					main = gem, ingredients = { item(dust), fluid("distilled-water", 10) }, results = { item(gem, 1, 0.9) } }
				unlock_after(made(name), { machine_techs("lv-autoclave-recipes"), item_techs(dust) })
			end
			late_gems = late_gems + 2
		end
		if g[4] then
			local name = recipe{ name = "implosion-" .. dust .. "-to-gem", category = "lv-implosion-compressor-recipes",
				time = 1, main = gem, ingredients = { item(dust, 4), item("explosives", g[4][1]) },
				results = { item(gem, 3), item(DARK_TINY, g[4][2]) } }
			unlock_after(made(name), { machine_techs("lv-implosion-compressor-recipes"), item_techs(dust),
				item_techs("explosives") })
			late_gems = late_gems + 1
		end
	end
end
log("FORK-ORE-CHAIN: " .. late_gems .. " recipes of the byproduct gems and from dust to gem (issue #205)")

--------------------------------------------------------------------------------
--- Issue #205, 3: GT's furnace recipes of the ore forms (OP/ProcessingOreSmelting.java; GTNH's config
--- mixedOreOnlyYieldsTwoThirdsOfPureOre is false): crushed, purified and centrifuged ore of an ore that smelts into
--- itself -> 10 nuggets, of one that smelts into another metal (setDirectSmelting) -> 1 ingot of it; its dust, impure
--- and pure dust -> 1 ingot. Nothing for ores that need the blast furnace, NO_SMELTING ores and ores without an ingot
--- (MaterialsInit.java); a platinum ingot as 2 platinum metallic powder (PlatinumSludgeOutputs.convertSmelting).
--- Platinum and palladium ore stay the platinum line's (146); bornite is bartworks' and keeps upstream's dust smelting;
--- a recipe Gregtorio has already stays. 10 s, the furnace only (as the impure and pure dusts of phase O1).
--- New where Gregtorio lacked them: the nuggets of these metals (9 make an ingot in the alloy smelter with the mold, as
--- phase O3's) and the ingots of realgar, thorium, antimony and molybdenum (from their dust in the furnace, back into
--- dust in the macerator in GT mass ticks).
--------------------------------------------------------------------------------
local SMELT_SELF = { "iron", "gold", "copper", "tin", "lead", "silver", "nickel", "beryllium", "thorium", "ledox",
	"realgar" }
local SMELT_INTO = { cassiterite = "tin", galena = "lead", molybdenite = "molybdenum", pentlandite = "nickel",
	sphalerite = "zinc", stibnite = "antimony", tetrahedrite = "copper", sheldonite = "platinum" }
--- the ingots GT has and Gregtorio lacked: their dust and GT mass
local NEW_INGOTS = { realgar = { "realgar-dust", 53 }, thorium = { "thorium-dust", 230 }, antimony = { "antimony", 122 },
	molybdenum = { "molybdenum-dust", 96 } }
local smelt_into = {}
for _, m in pairs(SMELT_SELF) do smelt_into[m] = m end
for x, m in pairs(SMELT_INTO) do smelt_into[x] = m end
local metal_sub = sub_of("tin-ingot", "subgroup-smelting")
local new_items = 0
for m, _ in pairs(NEW_INGOTS) do
	if not data.raw.item[m .. "-ingot"] then
		add_item(m .. "-ingot", metal_sub, "z-" .. m .. "-ingot")
		new_items = new_items + 1
	end
end
for _, m in pairs(SMELT_SELF) do
	if not data.raw.item[m .. "-nugget"] then
		add_item(m .. "-nugget", metal_sub, "z-" .. m .. "-nugget")
		new_items = new_items + 1
	end
end
local function smelts(name)
	for _, r in pairs(data.raw.recipe) do
		if r.category == "smelting" and r.ingredients and #r.ingredients == 1 and r.ingredients[1].name == name then
			return true
		end
	end
end
local smelted = 0
local function smelt(input, out, amount)
	if not data.raw.item[input] or smelts(input) then return end
	if out == "platinum-ingot" then out, amount = "metallic-platinum-powder", amount * 2 end
	local name = input .. "-smelter"
	if data.raw.recipe[name] then
		log("FORK-ORE-CHAIN: " .. name .. " exists and is no furnace recipe of " .. input)
		return
	end
	recipe{ name = name, category = "smelting", subgroup = "subgroup-smelting", time = 10, main = out,
		ingredients = { item(input) }, results = { item(out, amount) } }
	unlock_after(made(name), { item_techs(input) })
	smelted = smelted + 1
end
for x, m in pairs(smelt_into) do
	local ore = ORE_CHAIN[x]
	if ore then
		for _, f in pairs({ "crushed-" .. x, "purified-" .. x, "centrifuged-" .. x }) do
			if m == x then smelt(f, m .. "-nugget", 10) else smelt(f, m .. "-ingot", 1) end
		end
		for _, f in pairs({ ore.dust, "impure-" .. x .. "-dust", "pure-" .. x .. "-dust" }) do smelt(f, m .. "-ingot", 1) end
	end
end
for m, d in pairs(NEW_INGOTS) do
	smelt(d[1], m .. "-ingot", 1)
	local name = d[1] .. "-macerator"
	if not data.raw.recipe[name] then
		recipe{ name = name, category = "lv-macerator-recipes", time = d[2] / 20, main = d[1],
			ingredients = { item(m .. "-ingot") }, results = { item(d[1]) } }
		unlock_after(made(name), { machine_techs("lv-macerator-recipes"), item_techs(m .. "-ingot") })
	end
end
for _, m in pairs(SMELT_SELF) do
	local name = m .. "-ingot-from-nuggets"
	if not data.raw.recipe[name] and data.raw.item[m .. "-ingot"] then
		--- in the alloy smelter's row (the ingot's row is in the Material parts tab, which has items only)
		recipe{ name = name, category = "lv-alloy-smelter-recipes", time = 10, subgroup = "subgroup-lv-alloy-smelter-recipes",
			main = m .. "-ingot", ingredients = { item(m .. "-nugget", 9), item("mold") },
			results = { item(m .. "-ingot"), item("mold") } }
		unlock_after(made(name), { machine_techs("lv-alloy-smelter-recipes"), item_techs(m .. "-nugget") })
	end
end
log("FORK-ORE-CHAIN: " .. smelted .. " furnace recipes of ore forms, " .. new_items .. " new ingots and nuggets (issue #205)")
