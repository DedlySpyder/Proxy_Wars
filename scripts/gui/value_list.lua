--~~~~~~~~~~ Value GUI ~~~~~~~~~~--

--Shows a list of all values that items will sell for

GUI.ValueList = {}
GUI.ValueList.NAME = "Proxy_Wars_view_value_list"
GUI.ValueList.TAB_NAME = "value_list"

GUI.ValueList.Destroy = function(player)
	data = GUI.MainMenu.GetTabData(player)
	
	Utils.TabLib.Destroy(data)
end

--See Utils.TabLib.Toggle for more info
GUI.ValueList.OnToggle = function(event)
	local player = game.players[event.player_index]
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.ValueList.TAB_NAME
	
	Utils.TabLib.Toggle(data)
end

GUI.ValueList.Close = function(event)
	local player = game.players[event.player_index]
	
	GUI.ValueList.Destroy(player)
end

--TODO - stylings
GUI.ValueList.Tab = function(tabFlow)
	player = game.players[tabFlow.player_index]
	
	Debug.info("Drawing Value List GUI for "..player.name)
	--local frame = player.gui.center.add{type="frame", name="Proxy_Wars_value_list", direction="vertical"}
	local flow = tabFlow.add{type="flow", direction="vertical", style="Proxy_Wars_tab_flow"}
	flow.add{type="label", caption={"Proxy_Wars_value_list_title"}, style="Proxy_Wars_lists_title"}
	
	local header = flow.add{type="flow", name="PW_Value_List_header_row", direction="horizontal"}
	header.add{type="label", caption={"Proxy_Wars_value_list_header_item"}, style="Proxy_Wars_value_list_header_name"}
	header.add{type="label", caption={"Proxy_Wars_value_list_header_value"}, style="Proxy_Wars_value_list_header_value"}
	
	local entries = flow.add{type="scroll-pane", name="PW_Value_List_scroll_pane", direction="vertical", style="Proxy_Wars_value_list_scroll_pane"}
	
	local itemPrototypes = game.item_prototypes
	local sortedValues = GUI.GetSortedValueList()
	for _, data in pairs(sortedValues) do
		if itemPrototypes[data.item] then
			if data.value > 0 then
				local entry = entries.add{type="flow", name="PW_Value_List_entry_"..data.item, direction="horizontal"}
				entry.add{type="label", caption=itemPrototypes[data.item].localised_name, style="Proxy_Wars_value_list_entry_item"}
				entry.add{type="label", caption=Utils.String.FormatNumber(data.value), style="Proxy_Wars_value_list_entry_value"}
			end
		end
	end
	
	local footer = tabFlow.add{type="flow", name="PW_Value_List_footer_row", direction="horizontal"}
	footer.add{type="label", caption={"Proxy_Wars_current_money", Utils.String.FormatNumber(global.money[player.force.name])}, style="Proxy_Wars_value_list_current_money"}
	footer.add{type="button", name="Proxy_Wars_value_list_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
end
