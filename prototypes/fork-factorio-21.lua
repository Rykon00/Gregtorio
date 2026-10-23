--- Fork: Factorio 2.1 (issue #535), helpers for the keys that changed. Required at the top of data.lua.
--- A recipe has `categories`, a list, instead of `category` and `additional_categories` (a recipe may be made in machines of
--- several categories; the vanilla recipes use that since 2.1: `electronic-circuit` is { "crafting", "electromagnetics" }),
--- and a product `independent_probability` instead of `probability`. Every Gregtorio recipe has one category; the data
--- stage reads and sets it through these helpers, so a vanilla recipe of several categories is read the same way. A recipe
--- without `categories` is in "crafting".

--- the category of recipe `r` (its first one; a Gregtorio recipe has one)
function fork_category(r)
	local c = r.categories
	return c and c[1] or "crafting"
end

--- sets the one category of recipe `r`
function fork_set_category(r, category)
	r.categories = { category }
end

--- is recipe `r` in `category`?
function fork_has_category(r, category)
	for _, c in pairs(r.categories or { "crafting" }) do
		if c == category then return true end
	end
	return false
end

--- the category of recipe `r` when it is set explicitly, is its only one and is a key of the table `set` (nil otherwise), as
--- 2.0's `set[r.category]` read it: a recipe without the key (in "crafting" by default) did not count, and the vanilla
--- recipes that 2.1 gives several categories had one of 2.0's combined categories ("electronics", "pressing", ...), which
--- no list of Gregtorio names
function fork_category_in(r, set)
	local c = r.categories
	if c and #c == 1 and set[c[1]] then return c[1] end
	return nil
end

--- the chance that a craft makes product `p` (nil and 1: certain)
function fork_probability(p)
	return p.independent_probability or 1
end

--- a generator's `pictures` (GeneratorPrototype::pictures since 2.1) from 2.0's `horizontal_animation` and
--- `vertical_animation`: north and south show the vertical one, east and west the horizontal one
function fork_generator_pictures(horizontal, vertical)
	return {
		north = { animation = vertical }, south = { animation = table.deepcopy(vertical) },
		east = { animation = horizontal }, west = { animation = table.deepcopy(horizontal) },
	}
end

--- the base mod of 2.1 keeps the assembling machines' pipe pictures in a module (prototypes/entity/assembler-pictures.lua)
--- instead of 2.0's global functions assembler2pipepictures and assembler3pipepictures, which the upstream files call
local assembler_pictures = require("__base__/prototypes/entity/assembler-pictures")
assembler2pipepictures = assembler2pipepictures or function() return table.deepcopy(assembler_pictures.assembler2pipepictures) end
assembler3pipepictures = assembler3pipepictures or function() return table.deepcopy(assembler_pictures.assembler3pipepictures) end
