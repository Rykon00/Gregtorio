--- Fork: victory (roadmap phase 5b, see prototypes/135-fork-endgame.lua)
--- Researching the first level of the technology `victory` wins the game. The game goes on
--- (can_continue), and the further levels of the infinite technology stay plain research.
local fork_victory = {}

function fork_victory.on_research_finished(event)
	local research = event.research
	if not (research and research.valid and research.name == "victory") then return end
	if storage.fork_victory_declared then return end
	storage.fork_victory_declared = true
	game.set_game_state{
		game_finished = true,
		player_won = true,
		can_continue = true,
		victorious_force = research.force,
	}
end

return fork_victory
