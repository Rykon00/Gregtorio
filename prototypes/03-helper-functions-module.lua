
--------------------------
---     CREATE ITEM    ---
--------------------------

function create_item(def)
	
	local icon = def.icon or (ICON_PATH .. def.name .. ".png")
	local category = def.category or "crafting-or-assembling-recipes"
	local order = def.order or ("a[" .. category .. "]-[" .. def.name .. "]")
	local icon_size = def.icon_size or 32
	local stack_size = def.stack_size or 64
	local subgroup = def.subgroup or ("subgroup-" .. category)

	local item = {
		type = "item",
		name = def.name,
		icon = icon,
		icon_size = icon_size,
		stack_size = stack_size,
		subgroup = subgroup,
		order = order
	}
	
	if def.type then
		item.type = def.type
		item.durability = def.durability
	end

	if def.place_result then
		item.place_result = def.place_result
	end
	
	if def.fuel_category then
		item.fuel_category = def.fuel_category
		item.fuel_value = def.fuel_value
	end
	
	if def.burnt_result then
		item.burnt_result = def.burnt_result
	end

	data:extend{item}

	if not def.skip_recipe then
		create_recipe{
			recipe_name = def.recipe_name or def.name,
			category = category,
			subgroup = subgroup,
			order = order,
			energy_required = def.energy_required or 1,
			ingredients = def.ingredients,
			results = def.results or {
				{type = "item", name = def.name, amount = 1}
			},
			main_product = def.main_product or def.name
		}
	end
end










----------------------------
---     CREATE RECIPE    ---
----------------------------
function create_recipe(def)

	local category = def.category or "crafting-or-assembling-recipes"
	local name = def.name or def.recipe_name

	local recipe = {
		type = "recipe",
		name = name,
		category = category,
		enabled = false,
		energy_required = def.energy_required or 1,
		ingredients = def.ingredients,
		results = def.results or {
			{type = "item", name = name, amount = 1}
		},
		hide_from_player_crafting = not (category == "manual-only-recipes" or category == "crafting-table-recipes" or category == "crafting-or-assembling-recipes"),
		subgroup = def.subgroup or "subgroup-" .. category,
		order = def.order,
		main_product = def.main_product
	}
	if def.icon then
		recipe.icon = def.icon
		recipe.icon_size = def.icon_size or 32
	end
	recipe.enabled = def.enabled or false
	data:extend{recipe}
end










--------------------------
---     FLUID PORT     ---
--------------------------

function fluid_port(x, y, port_type, direction)
  return {
    production_type = port_type,
    volume = 1000,
    pipe_connections = {
      {
        flow_direction = port_type,
        direction = direction,
        position = {x, y}
      }
    }
  }
end










----------------------------------
---RECIPE CATEGORY AND SUBGROUP---
----------------------------------

local order_counter = 0

-- Generates a sequential alphabetical string like "a", "b", ..., "z", "aa", ..., "zz", "aaa" ..., for ordering purposes
local function next_order()
	order_counter = order_counter + 1
	local n = order_counter
	local s = ""
	repeat
		n = n - 1
		s = string.char(97 + (n % 26)) .. s
		n = math.floor(n / 26)
	until n == 0
	return s
end

function recipe_category_and_subgroup( n, group )
	local group = group or "processing-machine-recipes"
	local rc = { type = "recipe-category", name = n }
	local ig = {
		type = "item-subgroup",
		name = "subgroup-" .. n,
		group = group,
		order = next_order()
	}
	data:extend({rc, ig})
end










--------------------------
---     CREATE ORE     ---
--------------------------

function create_ore(raw_ore, ingot, crushed, dust, raw_smelt_result, crush_result, centrifuge_result, byproduct, ore_multiplier, define_byproduct, smelt_dust)
	local multiplier = ore_multiplier or 1
	local crush_output = 2 * multiplier
	local smelt_output = 1 * multiplier
	local multismelt_output = 64 * multiplier

	create_item{name = raw_ore, subgroup = "subgroup-mining", skip_recipe = true}

	if ingot then
		create_item{name = ingot, subgroup = "subgroup-smelting", skip_recipe = true}
	end

	if crushed then
		create_item{name = crushed, subgroup = "subgroup-macerator-crushed", skip_recipe = true}
	end

	if dust then
		create_item{name = dust, subgroup = "subgroup-macerator-dust", skip_recipe = true}
	end

	if define_byproduct then
		create_item{name = byproduct, subgroup = "subgroup-macerator-dust", order = "b", skip_recipe = true}
	end

	if raw_smelt_result then
		create_recipe{
			recipe_name = raw_ore .. "-smelter",
			category = "smelting",
			subgroup = "subgroup-smelting",
			order = "a",
			energy_required = 10,
			ingredients = {
				{type = "item", name = raw_ore, amount = 1}
			},
			results = {
				{type = "item", name = raw_smelt_result, amount = smelt_output}
			}
		}

		create_recipe{
			recipe_name = raw_ore .. "-multismelter",
			category = "multismelter-recipes",
			subgroup = "subgroup-multismelter-recipes",
			order = "b",
			energy_required = 10,
			ingredients = {
				{type = "item", name = raw_ore, amount = 64}
			},
			results = {
				{type = "item", name = raw_smelt_result, amount = multismelt_output}
			}
		}
	end

	if crush_result then
		create_recipe{
			recipe_name = crush_result,
			category = "lv-macerator-recipes",
			subgroup = "subgroup-macerator-crushed",
			order = "a",
			energy_required = 20,
			ingredients = {
				{type = "item", name = raw_ore, amount = 1}
			},
			results = {
				{type = "item", name = crush_result, amount = crush_output}
			}
		}
	end

	if centrifuge_result then
		create_recipe{
			recipe_name = centrifuge_result,
			category = "lv-ore-washer-recipes",
			order = "c",
			energy_required = 1,
			ingredients = {
				{type = "item", name = crush_result, amount = 1},
				{type = "fluid", name = "water", amount = 10}
			},
			results = {
				{type = "item", name = centrifuge_result, amount = 1}
			}
		}

		create_recipe{
			recipe_name = "centrifuging-" .. crush_result,
			category = "lv-centrifuge-recipes",
			subgroup = "subgroup-macerator-dust",
			order = "d",
			energy_required = 4,
			ingredients = {
				{type = "item", name = crush_result, amount = 1}
			},
			results = {
				{type = "item", name = centrifuge_result, amount = 1},
				{type = "item", name = byproduct, amount = 1, probability = 0.1}
			},
			main_product = centrifuge_result
		}
	end

	if smelt_dust then
		create_recipe{
			recipe_name = dust .. "-smelter",
			category = "smelting",
			subgroup = "subgroup-smelting",
			order = "e",
			energy_required = 10,
			ingredients = {
				{type = "item", name = dust, amount = 1 }
			},
			results = {
				{type = "item", name = ingot, amount = 1 }
			}
		}

		create_recipe{
			recipe_name = dust .. "-multismelter",
			category = "multismelter-recipes",
			subgroup = "subgroup-multismelter-recipes",
			order = "f",
			energy_required = 10,
			ingredients = {
				{type = "item", name = dust, amount = 64 }
			},
			results = {
				{type = "item", name = ingot, amount = 64 }
			}
		}
	end
end










--------------------------
---    CREATE INGOT    ---
--------------------------

function create_ingot( material,
	dust_tier, dust_speed, dust_ingredients, dust_count,
	ebf_tier, ebf_speed, inert_gas,
	freezer_tier, freezer_speed, cryo_helium,
	make_ebf, make_abs, abs_speed_override, make_freezer, make_fluid_solidify )

--- First, we make the EBF version of the ingot chain
	if make_ebf then
		if dust_tier then
			create_item{
				name = material .. "-dust",
				category = dust_tier .. "-mixer-recipes",
				energy_required = dust_speed,
				ingredients = dust_ingredients,
				results = {{type = "item", name = material .. "-dust", amount = dust_count}},
				order = "a[dust]" .. material
			}
		end

		local ebf_ingredients = {
			{type = "item", name = material .. "-dust", amount = 1}
		}
		if inert_gas then table.insert(ebf_ingredients, inert_gas) end

		if make_freezer then
			create_item{
				name = "hot-" .. material .. "-ingot",
				category = ebf_tier .. "-electric-blast-furnace-recipes",
				energy_required = ebf_speed,
				ingredients = ebf_ingredients,
				results = {{type = "item", name = "hot-" .. material .. "-ingot", amount = 1}},
				order = "a[hot-ingot]" .. material
			}
		else
			create_item{
				name = material .. "-ingot",
				category = ebf_tier .. "-electric-blast-furnace-recipes",
				energy_required = ebf_speed,
				ingredients = ebf_ingredients,
				results = {{type = "item", name = material .. "-ingot", amount = 1}},
				order = "a[ingot]" .. material
			}
		end

		if make_freezer then
			local freezer_ingredients = {
				{type = "item", name = "hot-" .. material .. "-ingot", amount = 1}
			}
			local freezer_results = {
				{type = "item", name = material .. "-ingot", amount = 1}
			}
			if cryo_helium then
				table.insert(freezer_ingredients, {type = "fluid", name = "cryogenic-helium", amount = 50})
				table.insert(freezer_results, {type = "fluid", name = "helium", amount = 25})
			end
			create_item{
				name = material .. "-ingot",
				category = freezer_tier .. "-vacuum-freezer-recipes",
				energy_required = freezer_speed,
				ingredients = freezer_ingredients,
				results = freezer_results,
				main_product = material .. "-ingot",
				recipe_name = material .. "-ingot",
				order = "a[ingot]" .. material
			}
		end
	end

--- Then Alloy Blast Furnace version
	if make_abs then
		local abs_ingredients = {}
		for i, ing in ipairs(dust_ingredients) do
			abs_ingredients[i] = table.deepcopy(ing)
		end
		if inert_gas then
			table.insert(abs_ingredients, {
				type = inert_gas.type,
				name = inert_gas.name,
				amount = inert_gas.amount * dust_count
			})
		end
		local abs_speed = abs_speed_override or (ebf_speed * dust_count * 0.75)
		data:extend{{
			type = "recipe",
			name = "molten-" .. material,
			category = ebf_tier .. "-alloy-blast-smelter-recipes",
			order = "a[molten]" .. material,
			energy_required = abs_speed,
			ingredients = abs_ingredients,
			results = {{type = "fluid", name = "molten-" .. material, amount = 14.4 * dust_count}},
			enabled = false,
			hide_from_player_crafting = true
		}}

		local solidify_ingredients = {{type = "fluid", name = "molten-" .. material, amount = 14.4}}
		local solidify_results = {{type = "item", name = material .. "-ingot", amount = 1}}
		if cryo_helium then
			table.insert(solidify_ingredients, {type = "fluid", name = "cryogenic-helium", amount = 50})
			table.insert(solidify_results, {type = "fluid", name = "helium", amount = 25})
		end
		local solidify_machine = make_freezer and "-vacuum-freezer-recipes" or "-fluid-solidifier-recipes"
		create_item{
			name = material .. "-ingot",
			category = freezer_tier .. solidify_machine,
			energy_required = freezer_speed,
			ingredients = solidify_ingredients,
			results = solidify_results,
			main_product = material .. "-ingot",
			recipe_name = "solidify-" .. material .. "-ingot",
			order = "a[ingot]" .. material
		}
	end
end










--------------------------------
---    CREATE METAL PARTS    ---
--------------------------------

function create_metal_parts(def)
	local material = def.material
	local speed = def.speed

	if def.make_plate then
		create_item{
			name = material .. "-plate",
			category = "lv-bending-machine-recipes",
			energy_required = speed,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-plate", amount = 1}},
			order = "a[plate]"
		}
	end
	
	if def.make_dense_plate then
		create_item{
			name = "dense-" .. material .. "-plate",
			category = "lv-bending-machine-recipes",
			energy_required = speed * 9,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 9}},
			results = {{type = "item", name = "dense-" .. material .. "-plate", amount = 1}},
			order = "b[dense-plate]"
		}
	end

	if def.make_foil then
		create_item{
			name = material .. "-foil",
			category = "lv-bending-machine-recipes",
			energy_required = speed,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-foil", amount = 4}},
			order = "c[foil]"
		}
	end

	if def.make_spring then
		create_item{
			name = material .. "-spring",
			category = "lv-bending-machine-recipes",
			energy_required = 10,
			ingredients = {{type = "item", name = "long-" .. material .. "-rod", amount = 1}},
			results = {{type = "item", name = material .. "-spring", amount = 1}},
			order = "d[spring]"
		}
	end

	if def.make_wire then
		create_item{
			name = material .. "-wire",
			category = "lv-wiremill-recipes",
			energy_required = speed * 1.5,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-wire", amount = 2}},
			order = "e[wire]"
		}
	end
	
	if def.make_wire_16x then
		create_item{
			name = material .. "-wire-16x",
			category = "lv-wiremill-recipes",
			energy_required = speed * 12,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 8}},
			results = {{type = "item", name = material .. "-wire-16x", amount = 1}},
			order = "f[wire]"
		}
	end

	if def.make_fine_wire then
		create_item{
			name = "fine-" .. material .. "-wire",
			category = "lv-wiremill-recipes",
			energy_required = speed * 3,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = "fine-" .. material .. "-wire", amount = 8}},
			order = "g[fine-wire]"
		}
	end

	if def.make_rod then
		create_item{
			name = material .. "-rod",
			category = "lv-lathe-recipes",
			energy_required = speed * 2,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-rod", amount = 2}},
			order = "g[rod]"
		}
	end

	if def.make_screw then
		create_item{
			name = material .. "-screw",
			category = "lv-lathe-recipes",
			energy_required = speed * 0.125,
			ingredients = {{type = "item", name = material .. "-bolt", amount = 1}},
			results = {{type = "item", name = material .. "-screw", amount = 1}},
			order = "h[screw]"
		}
	end

	if def.make_round then
		create_item{
			name = material .. "-round",
			category = "lv-lathe-recipes",
			energy_required = 5,
			ingredients = {{type = "item", name = material .. "-nugget", amount = 1}},
			results = {{type = "item", name = material .. "-round", amount = 1}},
			order = "i[round]"
		}
	end

	if def.make_gear then
		create_item{
			name = material .. "-gear",
			category = "mv-extruder-recipes",
			energy_required = speed,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-gear", amount = 1}},
			order = "j[gear]"
		}
	end

	if def.make_large_gear then
		create_item{
			name = "large-" .. material .. "-gear",
			category = "mv-extruder-recipes",
			energy_required = speed * 5,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 4}},
			results = {{type = "item", name = "large-" .. material .. "-gear", amount = 1}},
			order = "b[large-gear]"
		}
	end

	if def.make_rotor then
		create_item{
			name = material .. "-rotor",
			category = "mv-extruder-recipes",
			energy_required = speed * 4,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 4}},
			results = {{type = "item", name = material .. "-rotor", amount = 1}},
			order = "c[rotor]"
		}
	end

	if def.make_long_rod then
		create_item{
			name = "long-" .. material .. "-rod",
			category = "mv-extruder-recipes",
			energy_required = speed,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = "long-" .. material .. "-rod", amount = 1}},
			order = "d[long-rod]"
		}
	end

	if def.make_ring then
		create_item{
			name = material .. "-ring",
			category = "mv-extruder-recipes",
			energy_required = speed * 2,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-ring", amount = 4}},
			order = "e[ring]"
		}
	end

	if def.make_nugget then
		create_item{
			name = material .. "-nugget",
			category = "mv-extruder-recipes",
			energy_required = speed,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 1}},
			results = {{type = "item", name = material .. "-nugget", amount = 9}},
			order = "f[nugget]"
		}
	end

	if def.make_bolt then
		create_item{
			name = material .. "-bolt",
			category = "lv-cutting-machine-recipes",
			energy_required = speed * 2,
			ingredients = {{type = "item", name = material .. "-rod", amount = 1}},
			results = {{type = "item", name = material .. "-bolt", amount = 4}},
			order = "a[bolt]"
		}
	end

	if def.make_block then
		create_item{
			name = "block-of-" .. material,
			category = "lv-compressor-recipes",
			energy_required = 15,
			ingredients = {{type = "item", name = material .. "-ingot", amount = 9}},
			results = {{type = "item", name = "block-of-" .. material, amount = 1}},
			order = "a[block]"
		}
	end

	if def.make_frame then
		create_item{
			name = material .. "-frame",
			ingredients = {{type = "item", name = material .. "-rod", amount = 4}},
			results = {{type = "item", name = material .. "-frame", amount = 1}},
			order = "a[frame]"
		}
	end
end










-----------------------------
--- MAKE ELECTRIC MACHINE ---
-----------------------------

--- NAME, ICON_NAME, ENTITY_PATH, CATEGORIES, FAST_REPLACE, ENERGY, CRAFTSPEED, FRAMES, ANISPEED, LENGTH, WIDTH, FLUID_CONFIG
function make_electric_machine(name, icon_name, entity_path, categories, fast_replace, energy, craftspeed, frames, anispeed, length, width, fluid_config)
	local half_length = length / 2
	local half_width = width / 2

	local machine = {
		type = "assembling-machine",
		name = name,
		icon = ICON_PATH .. icon_name .. ".png",
		icon_size = 32,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = { mining_time = 0.5, result = name },
		max_health = 300,
		corpse = "small-remnants",
		dying_explosion = "medium-explosion",
		resistances = {
			{ type = "fire", percent = 70 },
			{ type = "impact", percent = 30 }
		},
		collision_box = {
			{ -half_length + 0.2, -half_width + 0.2 },
			{  half_length - 0.2,  half_width - 0.2 }
		},
		selection_box = {
			{ -half_length, -half_width },
			{  half_length,  half_width }
		},
		fast_replaceable_group = fast_replace,
		crafting_categories = categories,
		crafting_speed = craftspeed,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 1 },
			drain = "0W",
		},
		energy_usage = energy,
		graphics_set = {
			idle_animation = {
				layers = {
					{
						filename = "__Gregtorio__/graphics/entity/" .. entity_path .. "/" .. entity_path .. "-idle.png",
						width = length * 32,
						height = width * 32,
						frame_count = 1,
						repeat_count = frames,
						shift = {0, 0},
					} 
				}
			},
			animation = {
				layers = {
					{
						filename = "__Gregtorio__/graphics/entity/" .. entity_path .. "/" .. entity_path .. "-working.png",
						width = length * 32,
						height = width * 32,
						frame_count = frames,
						line_length = 1,
						animation_speed = anispeed,
						shift = {0, 0},
					}
				}
			}
		},
		working_sound = {
			sound = { filename = "__base__/sound/assembling-machine-t1-1.ogg", volume = 0.5 },
			idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.3 },
			apparent_volume = 1.5
		},
		allowed_effects = { },
		}

		if fluid_config then
			machine.fluid_boxes = {}
			for _, box in pairs(fluid_config) do
				table.insert(machine.fluid_boxes, {
				production_type = box.production_type,
				volume = box.volume or 1000,
				pipe_connections = box.pipe_connections,
				pipe_covers = pipecoverspictures(),
				pipe_picture = assembler2pipepictures()
			})
		end
		machine.fluid_boxes_off_when_no_fluid_recipe = true
  end
  
  
	machine.circuit_wire_connection_points = circuit_connector_definitions["assembling-machine"].points
	machine.circuit_connector_sprites = circuit_connector_definitions["assembling-machine"].sprites
	machine.circuit_wire_max_distance = default_circuit_wire_max_distance

	data:extend({ machine })
end








-----------------------------
--- MAKE BURNER GENERATOR ---
-----------------------------

function create_burner_generator(def)
	data:extend({{
		type = "burner-generator",
		name = def.name,
		icon = def.icon or ("__Gregtorio__/graphics/icons/" .. def.name .. ".png"),
		icon_size = def.icon_size or 32,
		flags = {"placeable-neutral", "player-creation"},
		minable = {mining_time = 0.5, result = def.name},
		max_health = 300,
		corpse = "medium-remnants",
		collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		max_power_output = def.max_power,
		burner = {
			type = "burner",
			fuel_categories = def.fuel_categories,
			effectivity = def.efficiency,
			fuel_inventory_size = 1,
			burnt_inventory_size = 1,
			smoke = {{
				name = "smoke",
				deviation = {0.1, 0.1},
				frequency = 10,
				position = {0.0, -1.0},
				starting_vertical_speed = 0.08,
				starting_frame_deviation = 60
			}}
		},
		energy_source = {
			type = "electric",
			usage_priority = def.usage_priority or "secondary-output"
		},
		animation = {
			filename = def.working_animation or ("__Gregtorio__/graphics/entity/" .. def.name .. "/" .. def.name .. "-working.png"),
			width = def.width or 96,
			height = def.height or 96,
			frame_count = def.frame_count or 2,
			line_length = def.line_length or 1,
			animation_speed = def.animation_speed or 0.5
		},
		idle_animation = {
			filename = def.idle_animation or ("__Gregtorio__/graphics/entity/" .. def.name .. "/" .. def.name .. "-idle.png"),
			width = def.width or 96,
			height = def.height or 96,
			frame_count = def.frame_count or 1,
			line_length = def.line_length or 1,
			repeat_count = def.frame_count or 2,
			animation_speed = def.animation_speed or 0.5
		}
	}})
end









------------------------------------
---     CREATE ENDGAME PARTS    ---
------------------------------------

--[[
create_endgame_parts{
	name = "eternity",
	tier = "umv",
	speed = UMV_SPEED,
	skip_ingot = true,
	skip_block = true,
	skip_plate = true,
	skip_long_rod = true,
	skip_rod = true,
	skip_frame = true,
	skip_wire = true,
	skip_fine_wire = true,
	skip_foil = true,
	skip_large_gear = true,
	skip_gear = true,
	skip_ring = true,
	skip_round = true,
	skip_bolt = true,
	skip_screw = true,
	skip_rotor = true,
	skip_dense_plate = true,
	skip_superdense_plate = true
}
]]--

function create_endgame_parts(def)
	local name = def.name
	local tier = def.tier
	local speed = def.speed

	if not def.skip_ingot then
		create_item{
			name = name .. "-ingot",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 1.6,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 14.4 },
			},
			results = {
				{ type = "item", name = name .. "-ingot", amount = 1 },
			}
		}
	end

	if not def.skip_block then
		create_item{
			name = "block-of-" .. name,
			category = tier .. "-extruder-recipes",
			energy_required = speed * 0.5,
			ingredients = {
				{ type = "item", name = name .. "-ingot", amount = 9 },
			},
			results = {
				{ type = "item", name = "block-of-" .. name, amount = 1 },
			}
		}
	end

	if not def.skip_plate then
		create_item{
			name = name .. "-plate",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 1.6,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 14.4 },
			},
			results = {
				{ type = "item", name = name .. "-plate", amount = 1 },
			}
		}
	end

	if not def.skip_long_rod then
		create_item{
			name = "long-" .. name .. "-rod",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 15,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 14.4 },
			},
			results = {
				{ type = "item", name = "long-" .. name .. "-rod", amount = 1 },
			}
		}
	end

	if not def.skip_rod then
		create_item{
			name = name .. "-rod",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 7.5,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 7.2 },
			},
			results = {
				{ type = "item", name = name .. "-rod", amount = 1 },
			}
		}
	end

	if not def.skip_frame then
		create_item{
			name = name .. "-frame",
			category = tier .. "-assembling-machine-recipes",
			energy_required = speed * 3.2,
			ingredients = {
				{ type = "item", name = name .. "-rod", amount = 4 },
			},
			results = {
				{ type = "item", name = name .. "-frame", amount = 1 },
			}
		}
	end

	if not def.skip_wire then
		create_item{
			name = name .. "-wire",
			category = tier .. "-extruder-recipes",
			energy_required = speed * 9.8,
			ingredients = {
				{ type = "item", name = name .. "-ingot", amount = 1 },
			},
			results = {
				{ type = "item", name = name .. "-wire", amount = 2 },
			}
		}
	end

	if not def.skip_fine_wire then
		create_item{
			name = "fine-" .. name .. "-wire",
			category = tier .. "-wiremill-recipes",
			energy_required = speed * 5,
			ingredients = {
				{ type = "item", name = name .. "-ingot", amount = 1 },
			},
			results = {
				{ type = "item", name = "fine-" .. name .. "-wire", amount = 8 },
			}
		}
	end

	if not def.skip_foil then
		create_item{
			name = name .. "-foil",
			category = tier .. "-bending-machine-recipes",
			energy_required = speed * 4.9,
			ingredients = {
				{ type = "item", name = name .. "-plate", amount = 1 },
			},
			results = {
				{ type = "item", name = name .. "-foil", amount = 4 },
			}
		}
	end

	if not def.skip_large_gear then
		create_item{
			name = "large-" .. name .. "-gear",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 6.4,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 576.2 },
			},
			results = {
				{ type = "item", name = "large-" .. name .. "-gear", amount = 1 },
			}
		}
	end

	if not def.skip_gear then
		create_item{
			name = name .. "-gear",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 0.8,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 14.4 },
			},
			results = {
				{ type = "item", name = name .. "-gear", amount = 1 },
			}
		}
	end

	if not def.skip_ring then
		create_item{
			name = name .. "-ring",
			category = tier .. "-extruder-recipes",
			energy_required = speed * 9.8,
			ingredients = {
				{ type = "item", name = name .. "-ingot", amount = 1 },
			},
			results = {
				{ type = "item", name = name .. "-ring", amount = 4 },
			}
		}
	end

	if not def.skip_round then
		create_item{
			name = name .. "-round",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 2.5,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 1.8 },
			},
			results = {
				{ type = "item", name = name .. "-round", amount = 1 },
			}
		}
	end

	if not def.skip_bolt then
		create_item{
			name = name .. "-bolt",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 2.5,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 1.8 },
			},
			results = {
				{ type = "item", name = name .. "-bolt", amount = 1 },
			}
		}
	end

	if not def.skip_screw then
		create_item{
			name = name .. "-screw",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 2.5,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 1.8 },
			},
			results = {
				{ type = "item", name = name .. "-screw", amount = 1 },
			}
		}
	end

	if not def.skip_rotor then
		create_item{
			name = name .. "-rotor",
			category = tier .. "-fluid-solidifier-recipes",
			energy_required = speed * 4.9,
			ingredients = {
				{ type = "fluid", name = "molten-" .. name, amount = 61.2 },
			},
			results = {
				{ type = "item", name = name .. "-rotor", amount = 1 },
			}
		}
	end

	if not def.skip_dense_plate then
		create_item{
			name = "dense-" .. name .. "-plate",
			category = tier .. "-bending-machine-recipes",
			energy_required = speed * 44.1,
			ingredients = {
				{ type = "item", name = name .. "-ingot", amount = 9 },
			},
			results = {
				{ type = "item", name = "dense-" .. name .. "-plate", amount = 1 },
			}
		}
	end

	if not def.skip_superdense_plate then
		create_item{
			name = "superdense-" .. name .. "-plate",
			category = "uxv-stabalized-black-hole-recipes",
			energy_required = speed * 156.8,
			ingredients = {
				{ type = "item", name = name .. "-plate", amount = 64 },
			},
			results = {
				{ type = "item", name = "superdense-" .. name .. "-plate", amount = 1 },
			}
		}
	end
end