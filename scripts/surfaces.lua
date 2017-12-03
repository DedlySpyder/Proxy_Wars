Surfaces = {}

--Accuracy of TeleportPlayer
Surfaces.TELEPORT_ACCURACY = 20

--Initialize the surfaces
--Teams surfaces and arena surface
Surfaces.Init = function()
	Debug.info("Initializing surfaces")
	Arena.Create()
	
	for _, name in ipairs(team_names) do --TODO - config migration
		Debug.info("Creating surface "..name)
		local surface = game.create_surface(name, global.map_gen_settings)
		surface.request_to_generate_chunks({0, 0}, 6)
		surface.regenerate_entity({
			"iron-ore",
			"copper-ore",
			"stone",
			"coal"
		})
	end
end

--Attempts to teleport a player within Surfaces.TELEPORT_ACCURACY tiles
-- @param player obj
-- @param surfaceName string
-- @param position table
-- @return true or false if successful
Surfaces.TeleportPlayer = function(player, surfaceName, position)
	if not player or not surfaceName then return false end
	
	--Default position
	if not position then position = {0, 0} end
	Debug.info("Attempting to teleport "..player.name.." to {"..position[1]..", "..position[2].."} on "..surfaceName)
	local surface = game.surfaces[surfaceName]
	
	--Check that the surface has been generated
	if surface.is_chunk_generated(position) then
		Debug.info("Generating chunks on "..surface.name)
		surface.request_to_generate_chunks(position, 2)
	end
	
	--Find a good teleport position
	local realPosition = surface.find_non_colliding_position("player", position, Surfaces.TELEPORT_ACCURACY, 1)
	if realPosition then
		Debug.info("Valid position found at {"..realPosition.x..", "..realPosition.y.."} for teleport of "..player.name)
		if player and player.valid then
			 if player.teleport(realPosition, surface) then
				Debug.info("Teleport of "..player.name.." succeeded")
				return true
			 end
		end
	else 
		Debug.warn("Non-colliding position not found for teleport of "..player.name) 
	end
	Debug.error("Failed to teleport "..player.name)
	return false
end
