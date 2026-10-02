
ICON_PATH = "__gregtorio-continued__/graphics/icons/"

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
			icon = "__gregtorio-continued__/graphics/fluids/black-fluid.png",
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
require("prototypes.103-fork-qol-techs")
require("prototypes.110-fork-luv")
--- the ME network is the mod me-network (issue #83): its recipes and technologies on Gregtorio's tiers
require("prototypes.120-fork-me-network-compat")
require("prototypes.125-fork-luv-endgame")
require("prototypes.126-fork-zpm")
require("prototypes.127-fork-uv")
require("prototypes.128-fork-uhv")
require("prototypes.129-fork-water-purification")
require("prototypes.131-fork-uev")
require("prototypes.132-fork-uiv")
require("prototypes.133-fork-umv")
require("prototypes.134-fork-uxv")
require("prototypes.135-fork-endgame")
require("prototypes.136-fork-power")
require("prototypes.137-fork-endgame-materials")
require("prototypes.139-fork-endgame-multiblocks")
require("prototypes.140-fork-godforge")
require("prototypes.141-fork-max")
require("prototypes.138-fork-research-balance")
--- issue #91: every Gregtorio recipe gets a technology (after every file that makes recipes and technologies)
require("prototypes.142-fork-recipe-unlocks")
--- issue #91: casts of every form, melts of every ingot, the missing melts (before the molds and the Fluids tab)
require("prototypes.143-fork-casting")
--- issue #91: GregTech's producers and uses of the fluids nothing made or used
require("prototypes.144-fork-dead-fluids")
require("prototypes.150-fork-molds")
require("prototypes.190-fork-manual-labor")
--- subgroups of the Fluids tab (after every file that creates fluids)
require("prototypes.196-fork-subgroups")
require("prototypes.198-fork-crafting-menu")
require("prototypes.199-fork-finalize")
