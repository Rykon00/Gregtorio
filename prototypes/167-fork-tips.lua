--------------------------------------------------------------------------------
--- Issue #625: the tier goals as tips. GT New Horizons guides through every tier with a quest line of its quest book
--- (GT-New-Horizons-Modpack config/betterquesting/DefaultQuests/QuestLinesOrder.txt:3-16: "Tier 0 - Stone Age" to
--- "Tier 12 - UMV", one quest line per voltage tier); Gregtorio has one tip per tier in its own category of the Tips and
--- tricks window, unlocked by researching the technology of the tier's science pack. The texts (locale/en/fork.cfg,
--- [tips-and-tricks-item-description]) name the tier's goals in Gregtorio's technologies, in the order of GTNH's quest
--- lines (QuestLines/Tier*/QuestLine.json): steam to electricity, the moon at HV, the platinum line and the assembly line
--- at IV, fusion from LuV on.
--------------------------------------------------------------------------------
data:extend{
	{ type = "tips-and-tricks-item-category", name = "gregtorio", order = "0-[gregtorio]" },
	{
		type = "tips-and-tricks-item",
		name = "gregtorio-tiers",
		category = "gregtorio",
		order = "a",
		is_title = true,
		starting_status = "unlocked",
	},
}

--- tip, the technology that unlocks it (the one of the tier's science pack) and the pack shown in its tag
local TIERS = {
	{ "steam", nil, "automation-science-pack" },
	{ "lv", "logistic-science-pack", "logistic-science-pack" },
	{ "mv", "military-science-pack", "military-science-pack" },
	{ "hv", "chemical-science-pack", "chemical-science-pack" },
	{ "ev", "production-science-pack", "production-science-pack" },
	{ "iv", "utility-science-pack", "utility-science-pack" },
	{ "luv", "space-science-pack", "space-science-pack" },
	{ "zpm", "metallurgic-science-pack", "metallurgic-science-pack" },
	{ "uv", "agricultural-science-pack", "agricultural-science-pack" },
	{ "uhv", "electromagnetic-science-pack", "electromagnetic-science-pack" },
	{ "uev", "cryogenic-science-pack", "cryogenic-science-pack" },
	{ "uiv", "promethium-science-pack", "promethium-science-pack" },
	{ "umv", "umv-science-pack", "umv-science-pack" },
	{ "uxv", "uxv-science-pack", "uxv-science-pack" },
	{ "max", "stargate", "max-science-pack" },
}
for i, t in ipairs(TIERS) do
	local tip = {
		type = "tips-and-tricks-item",
		name = "gregtorio-tier-" .. t[1],
		category = "gregtorio",
		order = string.format("b-%02d", i),
		indent = 1,
		tag = "[item=" .. t[3] .. "]",
		dependencies = { "gregtorio-tiers" },
	}
	if t[2] then
		tip.trigger = { type = "research", technology = t[2] }
	else
		tip.starting_status = "unlocked"
	end
	data:extend{ tip }
end
