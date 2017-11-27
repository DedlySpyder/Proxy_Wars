--~~~~~~~~~~ Help GUI ~~~~~~~~~~--
GUI.Help = {}
GUI.Help.NAME = "Proxy_Wars_view_help"
GUI.Help.TAB_NAME = "help"

GUI.Help.Create = function(player)
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.Help.TAB_NAME
	
	Utils.TabLib.Create(data)
end

GUI.Help.Destroy = function(player)
	data = GUI.MainMenu.GetTabData(player)
	
	Utils.TabLib.Destroy(data)
end

GUI.Help.OnToggle = function(event)
	local player = game.players[event.player_index]
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.Help.TAB_NAME
	
	Utils.TabLib.Toggle(data)
end

GUI.Help.Close = function(event)
	local player = game.players[event.player_index]
	
	GUI.Help.Destroy(player)
end

--TODO - stylings
GUI.Help.Tab = function(flow)
	player = game.players[flow.player_index]

	Debug.info("Drawing Help GUI for "..player.name)
	--local frame = player.gui.center.add{type="frame", name="Proxy_Wars_help", direction="vertical", style="Proxy_Wars_help_frame"}
	flow.add{type="label", caption={"Proxy_Wars_help_title"}, style="Proxy_Wars_lists_title"}
	
	--See the locale for the full help text
	for i=1, 11 do
		flow.add{type="label", single_line=false, caption={"Proxy_Wars_help_"..i}, style="Proxy_Wars_help_body"}
	end
	
	local footer = flow.add{type="flow", name="PW_Help_footer_row", direction="horizontal"}
	footer.add{type="label", style="Proxy_Wars_help_close_spacer"}
	footer.add{type="button", name="Proxy_Wars_help_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
end
