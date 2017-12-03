--~~~~~~~~~~ Buy Biters GUI ~~~~~~~~~~--

--The but biter GUI is a list of all of the available biters that a team can buy and buttons to let them buy it

GUI.BuyBiters = {}
GUI.BuyBiters.NAME = "Proxy_Wars_view_buy_biters"
GUI.BuyBiters.TAB_NAME = "buy_biters"

GUI.BuyBiters.Destroy = function(player)
	data = GUI.MainMenu.GetTabData(player)
	
	Utils.TabLib.Destroy(data)
	global.buy_biters_modifier[player.name] = 1
end

GUI.BuyBiters.Refresh = function(player)
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.BuyBiters.TAB_NAME
	
	Utils.TabLib.Refresh(data)
end

GUI.BuyBiters.Verify = function(player)
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.BuyBiters.TAB_NAME
	
	Utils.TabLib.Verify(data)
end

--See Utils.TabLib.Toggle for more info
GUI.BuyBiters.OnToggle = function(event)
	local player = game.players[event.player_index]
	data = GUI.MainMenu.GetTabData(player)
	data["active"] = GUI.BuyBiters.TAB_NAME
	
	Utils.TabLib.Toggle(data)
end

GUI.BuyBiters.Close = function(event)
	local player = game.players[event.player_index]
	
	GUI.BuyBiters.Destroy(player)
end

GUI.BuyBiters.OnClickBuy = function(event)
	local player = game.players[event.player_index]
	local biter = string.sub(event.element.name, 16)
	
	PW_Game.BuyBiter(player, biter)
end

--TODO - stylings
GUI.BuyBiters.Tab = function(tabFlow)
	player = game.players[tabFlow.player_index]
	
	Debug.info("Drawing Buy Biters GUI for "..player.name)
	local modifier = global.buy_biters_modifier[player.name]
	
	--local frame = player.gui.center.add{type="frame", name="Proxy_Wars_buy_biters", direction="vertical"}
	local flow = tabFlow.add{type="flow", direction="vertical", style="Proxy_Wars_tab_flow"}
	flow.add{type="label", caption={"Proxy_Wars_buy_biters_title", modifier}, tooltip={"Proxy_Wars_buy_biters_title_tooltip"}, style="Proxy_Wars_lists_title"}
	
	local header = flow.add{type="flow", name="PW_Buy_Biters_header_row", direction="horizontal"}
	header.add{type="label", caption={"Proxy_Wars_buy_biters_header_biter"}, style="Proxy_Wars_buy_biters_header_biter"}
	header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
	header.add{type="label", caption={"Proxy_Wars_buy_biters_header_current"}, style="Proxy_Wars_buy_biters_header_current"}
	header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
	header.add{type="label", caption={"Proxy_Wars_buy_biters_header_cost"}, style="Proxy_Wars_buy_biters_header_cost"}
	
	for name, cost in pairs(biter_costs) do --TODO - config migration
		local biter = flow.add{type="flow", name=name.."_cost", direction="horizontal"}
		biter.add{
			type="sprite-button", 
			name="Proxy_Wars_buy_"..name, 
			tooltip={"Proxy_Wars_buy_biters_entry_biter_tooltip", modifier, {"entity-name."..name}},
			sprite="entity/"..name,
			style="Proxy_Wars_buy_biters_entry_biter"
		}
		biter.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		biter.add{type="label", caption=global.bought_biters[player.force.name][name], style="Proxy_Wars_buy_biters_entry_current"}
		biter.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		biter.add{type="label", caption=Utils.String.FormatNumber(cost * modifier), style="Proxy_Wars_buy_biters_entry_cost"}
	end
	
	local footer = tabFlow.add{type="flow", name="PW_Buy_Biters_footer_row", direction="horizontal"}
	footer.add{type="label", caption={"Proxy_Wars_current_money", Utils.String.FormatNumber(global.money[player.force.name])}, style="Proxy_Wars_buy_biters_current_money"}
	footer.add{type="button", name="Proxy_Wars_buy_biters_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
end
