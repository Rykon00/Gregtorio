--------------------------------------------------------------------------------
--- FORK STAND-IN (issue #651): a stand-in for a player and its GUI elements, so devcheck's runtime tests drive the
--- scripts' player paths (the portals, the Ender panel, a player's fast replace) without a player, as me-network's
--- stand-in GUI tests do: the headless harness has none, and a headless Factorio cannot join a game as a client.
--- Only the fields and functions the scripts use; the scripts take a stand-in where they take a LuaPlayer.
--------------------------------------------------------------------------------

local M = {}

--- a GUI element: add, destroy, its children by name, the fields the scripts set and read
local function element(spec, parent)
	local el = { type = spec.type, name = spec.name, caption = spec.caption, items = spec.items,
		selected_index = spec.selected_index, tags = spec.tags, valid = true, parent = parent, children = {},
		stand_in = true }
	el.add = function(s)
		local child = element(s, el)
		el.children[#el.children + 1] = child
		if child.name then el[child.name] = child end
		return child
	end
	el.destroy = function()
		el.valid = false
		if parent then
			if el.name and parent[el.name] == el then parent[el.name] = nil end
			for i, c in pairs(parent.children) do
				if c == el then table.remove(parent.children, i) break end
			end
		end
	end
	return el
end

--- a player of index `index` (not a real player's: e.g. 1000 + n) with `character`
function M.player(index, character)
	return {
		index = index, valid = true, stand_in = true, character = character,
		surface = character and character.surface, position = character and character.position,
		gui = { relative = element({ type = "flow", name = "relative" }) },
		teleport = function(position, surface) return character.teleport(position, surface) end,
	}
end

return M
