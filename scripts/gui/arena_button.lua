--~~~~~~~~~~ Arena Button ~~~~~~~~~~--
--Handle the go to arena button
--The Draw and Destroy functions for this button will do their action for all players if one is not provided
GUI.ArenaButton = {}
GUI.ArenaButton.NAME = "Proxy_Wars_arena"

GUI.ArenaButton.Draw = function(player)
	if not player then
		for _, p in pairs(game.players) do
			GUI.ArenaButton.Draw(p)
		end
		return nil
	end
	
	if not GUI.ArenaButton.Verify then
		Debug.info("Drawing Go To Arena for "..player.name)
		mod_gui.get_button_flow(player).add{
			type="button", 
			name=GUI.ArenaButton.NAME, 
			caption={"Proxy_Wars_arena_button"}, 
			tooltip={"Proxy_Wars_arena_button_tooltip"},
			style=mod_gui.button_style
		}
		player.print({"Proxy_Wars_fight_start_message"})
	end
end

--Toggle the Arena Button between go to arena, and leave arena
GUI.ArenaButton.Toggle = function(player)
	local buttonFlow = mod_gui.get_button_flow(player)
	if global.player_at_arena[player.name] then
		--Leaving the Arena (need the button to)
		buttonFlow[GUI.ArenaButton.NAME].caption = {"Proxy_Wars_arena_button"}
		buttonFlow[GUI.ArenaButton.NAME].tooltip = {"Proxy_Wars_arena_button_tooltip"}
	else
		--Heading to the Arena (need the button back)
		buttonFlow[GUI.ArenaButton.NAME].caption = {"Proxy_Wars_arena_button_back"}
		buttonFlow[GUI.ArenaButton.NAME].tooltip = {"Proxy_Wars_arena_button_back_tooltip"}
	end
end

GUI.ArenaButton.Destroy = function(player)
	if not player then
		for _, p in pairs(game.players) do
			GUI.StartButton.Draw(p)
		end
		return nil
	end
	
	if GUI.ArenaButton.Verify(player) then
		Debug.info("Destroying Go To Arena for "..player.name)
		mod_gui.get_button_flow(player)[GUI.ArenaButton.NAME].destroy()
	end
end

GUI.ArenaButton.Verify = function(player)
	local buttonFlow = mod_gui.get_button_flow(player)
	if buttonFlow[GUI.ArenaButton.NAME] and buttonFlow[GUI.ArenaButton.NAME].valid then
		return true
	end
	return false
end

--On click handler for arena button
GUI.ArenaButton.OnClick = function(event)
	local player = game.players[event.player_index]
	
	Arena.Spectate.Toggle(player)
	GUI.ArenaButton.Toggle(player)
end
