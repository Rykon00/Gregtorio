--------------------------------------------------------------------------------
--- FORK BURNER FIRE (issue #137)
--- Upstream drew the stone furnace and the iron furnace as one picture without fire (nothing showed that they work),
--- and the small coal boiler as one picture with its fire always burning. Now:
---   * the furnaces keep their picture and get a fire animation in the lower opening that is drawn only while they smelt
---     (`working_visualisations`, as a glow, so it shines at night),
---   * the boiler's picture is the one without fire (steam-boiler-off.png, which upstream shipped and did not use) and the
---     fire animation of its own fire pixels (`fire`) is drawn while it burns.
--- The animations come from tools/gen_fire_sprites.py. Loaded after 10 (the entities) and 190.
--------------------------------------------------------------------------------

local P = "__gregtorio-continued__/graphics/entity/"

local function fire(file, size, scale)
	return {
		filename = P .. file, width = size, height = size, frame_count = 4, line_length = 4,
		animation_speed = 0.2, scale = scale, shift = { 0, 0 },
	}
end

for _, def in pairs({ { "stone-furnace", "furnace-fire.png" }, { "iron-furnace", "iron-furnace-fire.png" } }) do
	local f = data.raw.furnace[def[1]]
	if f and f.graphics_set then
		local anim = fire(def[2], 128, 0.5)
		anim.draw_as_glow = true
		f.graphics_set.working_visualisations = { { animation = anim } }
	end
end

local boiler = data.raw.boiler["small-coal-boiler"]
if boiler and boiler.pictures then
	for _, dir in pairs({ "north", "east", "south", "west" }) do
		local pic = boiler.pictures[dir]
		if pic and pic.structure and pic.structure.layers then
			pic.structure.layers[1].filename = P .. "small-coal-boiler/steam-boiler-off.png"
			pic.fire = fire("small-coal-boiler/small-coal-boiler-fire.png", 96, 1)
		end
	end
end
