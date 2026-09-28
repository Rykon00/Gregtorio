
ICON_PATH = "__Gregtorio__/graphics/icons/"

YAFC_MODE = false

require("prototypes.03-helper-functions-module")
require("prototypes.04-item-groups-module")
require("prototypes.05-definitions-module")
require("prototypes.06-fluids-module")
require("prototypes.07-ore-processing-module")
require("prototypes.08-material-processing-module")
require("prototypes.09-steam-age-item")
require("prototypes.10-steam-age-entity")
require("prototypes.11-lv-age-item")
require("prototypes.12-lv-age-entity")
require("prototypes.13-mv-age-item")
require("prototypes.14-mv-age-entity")
require("prototypes.15-hv-age-item")
require("prototypes.16-hv-age-entity")
require("prototypes.17-ev-age-item")
require("prototypes.18-ev-age-entity")
require("prototypes.19-iv-age-item")
require("prototypes.20-iv-age-entity")
require("prototypes.21-luv-age-item")
require("prototypes.50-ae2-module")
require("prototypes.52-microverse-module")
require("prototypes.98-technology")

if YAFC_MODE then require("prototypes.99-yafc-module") end



-- Log all defined fluids
for name, fluid in pairs(data.raw["fluid"]) do
	log("DEBUG: Fluid found in data.lua: " .. name)
end

-- Check for bad fluid entries in recipes
for name, recipe in pairs(data.raw.recipe) do
	local function scan(t)
		if t then
			for _, v in pairs(t) do
				if v.type == "fluid" and (not v.name or not data.raw["fluid"][v.name]) then
					log("⚠️ Invalid fluid in recipe '" .. name .. "': " .. serpent.block(v))
				end
			end
		end
	end
	scan(recipe.ingredients)
	scan(recipe.results)
end


---FLUID VOIDING WITH FLUID TRASHCAN
local blacklist = {
	["fluid-unknown"] = true,
	["parameter-0"] = true,
	["parameter-1"] = true,
	["parameter-2"] = true,
	["parameter-3"] = true,
	["parameter-4"] = true,
	["parameter-5"] = true,
	["parameter-6"] = true,
	["parameter-7"] = true,
	["parameter-8"] = true,
	["parameter-9"] = true
}
for _, fluid in pairs(data.raw["fluid"]) do
	-- fluids can have disable_voiding set to true to prevent a voiding recipe from being made
	if not fluid.disable_voiding and not blacklist[fluid.name] then
		create_recipe{
			icon = "__Gregtorio__/graphics/fluids/black-fluid.png",
			category = "fluid-voiding-recipes",
			name = "void-" .. fluid.name,
			ingredients = {{type = "fluid", name = fluid.name, amount = 100}},
			results = {},
			order = "a[fluid-voiding]-[" .. fluid.name .. "]",
			hidden_in_factoriopedia = true,
			hide_from_player_crafting = true,
			enabled = true
		}
	end
end

--- Fork: progression fixes (must be loaded after 98-technology)
require("prototypes.100-fork-fixes")
require("prototypes.101-fork-machines")
require("prototypes.102-fork-resources")
require("prototypes.110-fork-luv")
require("prototypes.120-fork-ae2")
require("prototypes.125-fork-luv-endgame")
require("prototypes.126-fork-zpm")
require("prototypes.127-fork-uv")
require("prototypes.130-fork-molds")
require("prototypes.190-fork-manual-labor")
require("prototypes.199-fork-finalize")
