GUI.TopMenu = {}
GUI.TopMenu.NAME = "Proxy_Wars_top_menu"

GUI.TopMenu.Draw = function(player)
	if not player then
		for _, p in pairs(game.players) do
			GUI.TopMenu.Draw(p)
		end
		return nil
	end
	
	if not GUI.TopMenu.Verify(player) then
		Debug.info("Drawing Top Menu for "..player.name)
		mod_gui.get_frame_flow(player).add{
			type="frame", 
			name=GUI.TopMenu.NAME, 
			direction="horizontal",
			style = mod_gui.frame_style
		}
		local frame = mod_gui.get_frame_flow(player)[GUI.TopMenu.NAME]
		frame.add{
			type="label", 
			name="Proxy_Wars_round_timer", 
			caption=Utils.String.FormatTime(global.round_time), 
			style="Proxy_Wars_main_menu_round_timer"
		}
		
		frame.add{
			type="sprite-button", 
			name=GUI.Help.NAME,
			tooltip={"Proxy_Wars_view_help_button"},
			sprite="proxy_wars_gui_view_help",
			style="Proxy_Wars_players_buttons"
		}
		frame.add{
			type="sprite-button", 
			name=GUI.Scoreboard.NAME,
			tooltip={"Proxy_Wars_view_scoreboard_button"},
			sprite="proxy_wars_gui_view_scoreboard",
			style="Proxy_Wars_players_buttons"
		}
		frame.add{
			type="sprite-button", 
			name=GUI.ValueList.NAME, 
			tooltip={"Proxy_Wars_view_value_list_button"},
			sprite="proxy_wars_gui_view_value_list", 
			style="Proxy_Wars_players_buttons"
		}
		return true
	end
	return false
end

GUI.TopMenu.AddPlayerButtons = function(player)
	if not player then
		for _, p in pairs(game.players) do
			GUI.TopMenu.AddPlayerButtons(p)
		end
		return nil
	end
	
	GUI.TopMenu.Draw(player)
	Debug.info("Adding Top Menu Player buttons for "..player.name)

	local frame = mod_gui.get_frame_flow(player)[GUI.TopMenu.NAME]
	frame.add{
		type="sprite-button", 
		name=GUI.BuyBiters.NAME, 
		tooltip={"Proxy_Wars_view_buy_biters_button"},
		sprite="proxy_wars_gui_view_buy_biters", 
		style="Proxy_Wars_players_buttons"
	}
	return true
end

GUI.TopMenu.Destroy = function(player)
	if not player then
		for _, p in pairs(game.players) do
			GUI.TopMenu.Destroy(p)
		end
		return nil
	end
	
	if GUI.TopMenu.Verify(player) then
		Debug.info("Destroying Top Menu GUI for "..player.name)
		mod_gui.get_frame_flow(player)[GUI.TopMenu.NAME].destroy()
		return true
	end
	return false
end

GUI.TopMenu.Verify = function(player)
	if mod_gui.get_frame_flow(player)[GUI.TopMenu.NAME] and mod_gui.get_frame_flow(player)[GUI.TopMenu.NAME].valid then
		return true
	end
	return false
end
