--------------------------------------------------------------------------------
--- FORK: PICTURES THAT TURN WITH THE MACHINE (issue #812)
---
--- A crafting machine whose collision box is not square turns its box when a player rotates it (R before placing, or
--- on the placed machine): the Bricked Blast Furnace (3x4), the Electric Blast Furnaces, the Alloy Blast Smelters, the
--- distillation towers, the crackers, the pyrolyse ovens, the drilling rigs, the Large Sifter and the assembly lines.
--- Their graphics had one direction, so a machine facing east or west drew its upright picture over a lying box: the
--- picture covered tiles the machine did not take and left tiles it took, and inserters and pipes seemed to be off.
--- Locking the rotation is no way out for them: their pipe connections turn with the machine, and saves have turned ones.
---
--- This file gives every such machine its picture per direction: the picture it has for north, and that picture turned
--- by 90, 180 and 270 degrees for east, south and west, so the controller and the hatches drawn on it follow the pipe
--- connections. The turned pictures are files beside the original (`<name>-east.png`, `-south.png`, `-west.png`),
--- written by `tools/devcheck/devcheck.py check --rotated-sprites` from FORK_ROTATED_GRAPHICS.files; devcheck fails when
--- one is missing or is not the turned original, and for a machine that turns with one picture (section ROTATE), unless
--- it is in the allow-list FORK_ROTATED_GRAPHICS_OK with its reason.
---
--- Loaded at the end of data-final-fixes.lua, after every file that makes or changes a machine's graphics.
--------------------------------------------------------------------------------

--- source file -> { width, height, frame_count, line_length, x, y } of its frames (the sheet devcheck turns)
FORK_ROTATED_GRAPHICS = { files = {}, machines = 0, skipped = {} }
--- entity -> reason: the entities that may turn with one picture
FORK_ROTATED_GRAPHICS_OK = {}

local PREFIX = "__gregtorio-continued__/"
local DIRECTIONS = { "east", "south", "west" }

--- a sheet devcheck can turn: one file of this mod with plain frames
local function plain(layer)
	return type(layer.filename) == "string" and layer.filename:sub(1, #PREFIX) == PREFIX and layer.filename:find("%.png$")
		and layer.width and layer.height and not layer.stripes and not layer.filenames and not layer.draw_as_shadow
end

local function layers_of(anim)
	return anim.layers or { anim }
end

local function turnable(anim)
	for _, layer in pairs(layers_of(anim)) do
		if not plain(layer) then return false end
	end
	return true
end

--- the layer turned clockwise to `direction`: the turned file, frame size and shift
local function turned_layer(layer, direction)
	local l = table.deepcopy(layer)
	local frames = layer.frame_count or 1
	FORK_ROTATED_GRAPHICS.files[layer.filename] = { layer.width, layer.height, frames, layer.line_length or frames,
		layer.x or 0, layer.y or 0 }
	l.filename = layer.filename:gsub("%.png$", "-" .. direction .. ".png")
	l.x, l.y = nil, nil
	local shift = layer.shift or { 0, 0 }
	local sx, sy = shift[1] or shift.x or 0, shift[2] or shift.y or 0
	if direction == "east" then
		l.width, l.height, l.shift = layer.height, layer.width, { -sy, sx }
	elseif direction == "south" then
		l.shift = { -sx, -sy }
	else
		l.width, l.height, l.shift = layer.height, layer.width, { sy, -sx }
	end
	return l
end

local function turned(anim, direction)
	local layers = {}
	for _, layer in pairs(layers_of(anim)) do layers[#layers + 1] = turned_layer(layer, direction) end
	return { layers = layers }
end

local function four_way(anim)
	local out = { north = anim }
	for _, direction in pairs(DIRECTIONS) do out[direction] = turned(anim, direction) end
	return out
end

local function is_four_way(anim)
	return anim.north ~= nil or anim.east ~= nil or anim.south ~= nil or anim.west ~= nil
end

for _, machine_type in pairs({ "assembling-machine", "furnace" }) do
	for name, m in pairs(data.raw[machine_type] or {}) do
		local box, gs = m.collision_box, m.graphics_set
		local a, b = box and (box[1] or box.left_top), box and (box[2] or box.right_bottom)
		local square = not box or math.abs(((b[1] or b.x) - (a[1] or a.x)) - ((b[2] or b.y) - (a[2] or a.y))) < 0.05
		local locked = false
		for _, flag in pairs(m.flags or {}) do if flag == "not-rotatable" then locked = true end end
		if not square and not locked and gs and not FORK_ROTATED_GRAPHICS_OK[name] then
			--- every picture of the machine turns, or none (a half turned machine would be worse than the old one)
			local ok, any = true, false
			for _, key in pairs({ "animation", "idle_animation" }) do
				local anim = gs[key]
				if anim and not is_four_way(anim) then
					any = true
					if not turnable(anim) then ok = false end
				end
			end
			for _, v in pairs(gs.working_visualisations or {}) do
				if v.animation and not v.north_animation then
					any = true
					if not turnable(v.animation) then ok = false end
				end
			end
			if any and not ok then
				FORK_ROTATED_GRAPHICS.skipped[#FORK_ROTATED_GRAPHICS.skipped + 1] = name
			elseif any then
				for _, key in pairs({ "animation", "idle_animation" }) do
					local anim = gs[key]
					if anim and not is_four_way(anim) then gs[key] = four_way(anim) end
				end
				for _, v in pairs(gs.working_visualisations or {}) do
					if v.animation and not v.north_animation then
						v.north_animation = v.animation
						for _, direction in pairs(DIRECTIONS) do v[direction .. "_animation"] = turned(v.animation, direction) end
						v.animation = nil
					end
				end
				FORK_ROTATED_GRAPHICS.machines = FORK_ROTATED_GRAPHICS.machines + 1
			end
		end
	end
end

local files = 0
for _ in pairs(FORK_ROTATED_GRAPHICS.files) do files = files + 1 end
log("FORK-ROTATED-GRAPHICS: " .. FORK_ROTATED_GRAPHICS.machines .. " machines with a box that is not square draw "
	.. files .. " pictures per direction (issue #812)"
	.. (#FORK_ROTATED_GRAPHICS.skipped > 0 and "; not turned: " .. table.concat(FORK_ROTATED_GRAPHICS.skipped, ", ") or ""))
