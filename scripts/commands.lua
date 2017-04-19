remote.add_interface("Proxy_Wars_debug", {
	-- /c remote.call("Proxy_Wars_debug", "change_surface", "")
	change_surface = function(surface)
		if debug_mode then
			local player = game.player
			if teleportPlayer(player, surface) then
				player.print("Teleported to "..surface)
			else
				player.print("Teleport to "..surface.." failed")
			end
		end
	end,
	
	-- /c remote.call("Proxy_Wars_debug", "check_force")
	check_force = function()
		if debug_mode then
			local player = game.player
			local force = player.force
			player.print("Your force is "..force.name)
			for _, name in ipairs(team_names) do
				if force.get_cease_fire(name) then
					player.print("You are at peace with "..name)
				else
					player.print("You are against "..name)
				end
			end
		end
	end,
	
	-- /c remote.call("Proxy_Wars_debug", "give_chests")
	give_chests = function()
		if debug_mode then
			game.player.insert({name="sell-chest-proxy-wars", count=20})
		end
	end
})

-- /c remote.call("Proxy_Wars_debug", "change_surface", "nauvis")
-- /c remote.call("Proxy_Wars_debug", "change_surface", "Proxy_Wars_Arena")