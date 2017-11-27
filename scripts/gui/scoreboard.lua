--~~~~~~~~~~ Scoreboard GUI ~~~~~~~~~~--
GUI.Scoreboard = {}
GUI.Scoreboard.NAME = "Proxy_Wars_view_scoreboard"
GUI.Scoreboard.TAB_NAME = "scoreboard"

GUI.Scoreboard.Create = function(player)
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.Scoreboard.TAB_NAME
	
	Utils.TabLib.Create(data)
end

GUI.Scoreboard.Destroy = function(player)
	data = GUI.MainMenu.GetTabData(player)
	
	Utils.TabLib.Destroy(data)
end

GUI.Scoreboard.OnToggle = function(event)
	local player = game.players[event.player_index]
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.Scoreboard.TAB_NAME
	
	Utils.TabLib.Toggle(data)
end

GUI.Scoreboard.Close = function(event)
	local player = game.players[event.player_index]
	
	GUI.Scoreboard.Destroy(player)
end

--TODO - stylings
GUI.Scoreboard.Tab = function(flow)
	player = game.players[flow.player_index]
	
	Debug.info("Drawing Scoreboard GUI for "..player.name)
	--local frame = player.gui.center.add{type="frame", name="Proxy_Wars_scoreboard", direction="vertical"}
	flow.add{type="label", caption={"Proxy_Wars_scoreboard_title"}, style="Proxy_Wars_lists_title"}
	
	local header = flow.add{type="flow", name="PW_Scoreboard_header_flow", direction="horizontal"}
	header.add{type="label", caption="#", style="Proxy_Wars_scoreboard_header_number"}
	header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
	header.add{type="label", caption={"Proxy_Wars_scoreboard_header_player_name"}, style="Proxy_Wars_scoreboard_header_player_name"}
	header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
	header.add{type="label", caption={"Proxy_Wars_scoreboard_header_points"}, style="Proxy_Wars_scoreboard_header_points"}
	
	GUI.SortPoints()
	for i, data in ipairs(global.points) do
		local color = {r = 1, g = 1, b = 1, a = 1}
		if data.player == player.name then color = {r = 0.8, g = 0.4, b = 0, a = 1} end
		
		local entry = flow.add{type="flow", name=data.player.."_entry_flow", direction="horizontal"}
		entry.add{type="label", caption=i, style="Proxy_Wars_scoreboard_entry_number"}.style.font_color = color
		entry.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}.style.font_color = color
		entry.add{type="label", caption=data.player, style="Proxy_Wars_scoreboard_entry_player_name"}.style.font_color = color
		entry.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}.style.font_color = color
		entry.add{type="label", caption=data.points, style="Proxy_Wars_scoreboard_entry_points"}.style.font_color = color
	end
	
	local footer = flow.add{type="flow", name="PW_Scoreboard_footer_row", direction="horizontal"}
	footer.add{type="label", style="Proxy_Wars_scoreboard_close_spacer"}
	footer.add{type="button", name="Proxy_Wars_scoreboard_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
end
