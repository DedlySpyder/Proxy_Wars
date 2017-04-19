local teleport_accuracy = 20
--Attempts to teleport a player within teleport_accuracy tiles
-- @param player obj
-- @param surfaceName string
-- @param position table
-- @return true or false if successful
function teleportPlayer(player, surfaceName, position)
	--Default position
	if not position then position = {0, 0} end
	Debug.log("Attempting to teleport "..player.name.." to {"..position[1]..", "..position[2].."} on "..surfaceName)
	local surface = game.surfaces[surfaceName]
	
	--Check that the surface has been generated
	if surface.is_chunk_generated(position) then
		Debug.log("Generating chunks on "..surface.name)
		surface.request_to_generate_chunks(position, 2)
	end
	
	--Find a good teleport position
	local realPosition = surface.find_non_colliding_position("player", position, teleport_accuracy, 1)
	if realPosition then
		Debug.log("Valid position found at {"..realPosition.x..", "..realPosition.y.."} for teleport of "..player.name)
		if player and player.valid then
			 if player.teleport(realPosition, surface) then
				Debug.log("Teleport of "..player.name.." succeeded")
				return true
			 end
		end
	else 
		Debug.log("[WARN]Non-colliding position not found for teleport of "..player.name) 
	end
	Debug.log("[WARN]Failed to teleport "..player.name)
	return false
end
