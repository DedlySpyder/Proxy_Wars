--~~~~~~~~~~ Start Button ~~~~~~~~~~--
--The start button is only made for the host
GUI.StartButton = {}
GUI.StartButton.NAME = "Proxy_Wars_start"

GUI.StartButton.Draw = function()
	local host = global.host
	if not GUI.StartButton.Verify(host) then
		Debug.info("Drawing Start Button for "..host.name)
		mod_gui.get_button_flow(host).add{
			type="button", 
			name=GUI.StartButton.NAME, 
			caption={"Proxy_Wars_host_start_button"}, 
			tooltip={"Proxy_Wars_host_start_button_tooltip"},
			style=mod_gui.button_style
		}
		host.print({"Proxy_Wars_host_can_start"})
	end
end

GUI.StartButton.Destroy = function()
	local host = global.host
	if GUI.StartButton.Verify(host) then
		mod_gui.get_button_flow(host)[GUI.StartButton.NAME].destroy()
	end
end

GUI.StartButton.Verify = function(player)
	local buttonFlow = mod_gui.get_button_flow(player)
	if buttonFlow[GUI.StartButton.NAME] and buttonFlow[GUI.StartButton.NAME].valid then
		return true
	end
	return false
end

GUI.StartButton.OnClick = function(event)
	local player = game.players[event.player_index]
	Debug.info("Start button pressed by "..player.name)
	
	if player == global.host then
		Utils.MessageAll({"Proxy_Wars_starting_game"})
		PW_Game.StartGame()
		
		script.on_event(defines.events.on_tick, Control.on_tick)
		global.game_started = true
	else
		player.print({"Proxy_Wars_warning_start_not_host"})
	end
end
