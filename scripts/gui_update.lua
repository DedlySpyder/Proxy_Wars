--~~~~~ Start Button ~~~~~--
function drawStartButton()
	local host = global.host
	if not verifyStartButton(host) then
		mod_gui.get_button_flow(host).add{
			type="button", 
			name="Proxy_Wars_start", 
			caption={"Proxy_Wars_host_start_button"}, 
			tooltip={"Proxy_Wars_host_start_button_tooltip"},
			style=mod_gui.button_style
		}
		host.print({"Proxy_Wars_host_can_start"})
	end
end

function destroyStartButton()
	local host = global.host
	if verifyStartButton(host) then
		mod_gui.get_button_flow(host)["Proxy_Wars_start"].destroy()
	end
end

function verifyStartButton(player)
	if mod_gui.get_button_flow(player)["Proxy_Wars_start"] and mod_gui.get_button_flow(player)["Proxy_Wars_start"].valid then
		return true
	end
	return false
end

--~~~~~ Arena Button ~~~~~--
function drawArenaButtonAll()
	for _, player in pairs(game.players) do
		drawArenaButton(player)
	end
end

function destroyArenaButtonAll()
	for _, player in pairs(game.players) do
		destroyArenaButton(player)
	end
end

function drawArenaButton(player)
	if not verifyArenaButton(player) then
		Debug.log("Drawing Go To Arena for "..player.name)
		mod_gui.get_button_flow(player).add{
			type="button", 
			name="Proxy_Wars_arena", 
			caption={"Proxy_Wars_arena_button"}, 
			tooltip={"Proxy_Wars_arena_button_tooltip"},
			style=mod_gui.button_style
		}
		player.print({"Proxy_Wars_fight_start_message"})
	end
end

function updateArenaButton(player, toArenaFlag)
	if toArenaFlag then
		mod_gui.get_button_flow(player)["Proxy_Wars_arena"].caption = {"Proxy_Wars_arena_button_back"}
		mod_gui.get_button_flow(player)["Proxy_Wars_arena"].tooltip = {"Proxy_Wars_arena_button_back_tooltip"}
	else
		mod_gui.get_button_flow(player)["Proxy_Wars_arena"].caption = {"Proxy_Wars_arena_button"}
		mod_gui.get_button_flow(player)["Proxy_Wars_arena"].tooltip = {"Proxy_Wars_arena_button_tooltip"}
	end
end

function destroyArenaButton(player)
	if verifyArenaButton(player) then
		Debug.log("Destroying Go To Arena for "..player.name)
		mod_gui.get_button_flow(player)["Proxy_Wars_arena"].destroy()
	end
end

function verifyArenaButton(player)
	if mod_gui.get_button_flow(player)["Proxy_Wars_arena"] and mod_gui.get_button_flow(player)["Proxy_Wars_arena"].valid then
		return true
	end
	return false
end

--~~~~~ Main Menu GUI ~~~~~--
function drawMainMenu(player)
	if not verifyMainMenu(player) then
		Debug.log("Drawing Main Menu for "..player.name)
		mod_gui.get_frame_flow(player).add{
			type="frame", 
			name="Proxy_Wars_main_frame", 
			direction="horizontal",
			style = mod_gui.frame_style
		}
		local frame = mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"]
		frame.add{type="label", name="Proxy_Wars_round_timer", caption=formatRoundTime(global.round_time), style="Proxy_Wars_main_menu_round_timer"}
		
		frame.add{
			type="sprite-button", 
			name="Proxy_Wars_view_help",
			tooltip={"Proxy_Wars_view_help_button"},
			sprite="proxy_wars_gui_view_help",
			style="Proxy_Wars_players_buttons"
		}
		return true
	end
	return false
end

function destroyMainMenu(player)
	if verifyMainMenu(player) then
		Debug.log("Destroying Main Menu GUI for "..player.name)
		mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"].destroy()
		return true
	end
	return false
end

function verifyMainMenu(player)
	if mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"] and mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"].valid then
		return true
	end
	return false
end

--~~~~~ Proxy Player Buttons GUI ~~~~~--
--Adds player buttons to Main GUI
function drawProxyWarsPlayerMenu(player)
	drawMainMenu(player)
	Debug.log("Adding Proxy Player buttons for "..player.name)

	local frame = mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"]

	frame.add{
		type="sprite-button", 
		name="Proxy_Wars_view_scoreboard",
		tooltip={"Proxy_Wars_view_scoreboard_button"},
		sprite="proxy_wars_gui_view_scoreboard",
		style="Proxy_Wars_players_buttons"
	}
	frame.add{
		type="sprite-button", 
		name="Proxy_Wars_view_value_list", 
		tooltip={"Proxy_Wars_view_value_list_button"},
		sprite="proxy_wars_gui_view_value_list", 
		style="Proxy_Wars_players_buttons"
	}
	frame.add{
		type="sprite-button", 
		name="Proxy_Wars_view_buy_biters", 
		tooltip={"Proxy_Wars_view_buy_biters_button"},
		sprite="proxy_wars_gui_view_buy_biters", 
		style="Proxy_Wars_players_buttons"
	}
	return true
end

--~~~~~ Lists GUIs ~~~~~--
--Returns true if there aren't any open center gui (for Proxy Wars)
function verifyOpenCenterGUI(player)
	if not verifyScoreboard(player) then
		if not verifyValueList(player) then
			if not verifyBuyBiters(player) then
				if not verifyHelpMenu(player) then
					return true
				end
			end
		end
	end
	return false
end

--~~~~~ Scoreboard GUI ~~~~~--
function drawScoreboard(player)
	if verifyOpenCenterGUI(player) then
		Debug.log("Drawing Scoreboard GUI for "..player.name)
		local frame = player.gui.center.add{type="frame", name="Proxy_Wars_scoreboard", direction="vertical"}
		frame.add{type="label", caption={"Proxy_Wars_scoreboard_title"}, style="Proxy_Wars_lists_title"}
		
		local header = frame.add{type="flow", name="header_row", direction="horizontal"}
		header.add{type="label", caption="#", style="Proxy_Wars_scoreboard_header_number"}
		header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		header.add{type="label", caption={"Proxy_Wars_scoreboard_header_player_name"}, style="Proxy_Wars_scoreboard_header_player_name"}
		header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		header.add{type="label", caption={"Proxy_Wars_scoreboard_header_points"}, style="Proxy_Wars_scoreboard_header_points"}
		
		sortPoints()
		for i, data in ipairs(global.points) do
			local color = {r = 1, g = 1, b = 1, a = 1}
			if data.player == player.name then color = {r = 0.8, g = 0.4, b = 0, a = 1} end
			
			local entry = frame.add{type="flow", name=data.player.."_entry_flow", direction="horizontal"}
			entry.add{type="label", caption=i, style="Proxy_Wars_scoreboard_entry_number"}.style.font_color = color
			entry.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}.style.font_color = color
			entry.add{type="label", caption=data.player, style="Proxy_Wars_scoreboard_entry_player_name"}.style.font_color = color
			entry.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}.style.font_color = color
			entry.add{type="label", caption=data.points, style="Proxy_Wars_scoreboard_entry_points"}.style.font_color = color
			
		end
		
		local footer = frame.add{type="flow", name="footer_row", direction="horizontal"}
		footer.add{type="label", style="Proxy_Wars_scoreboard_close_spacer"}
		footer.add{type="button", name="Proxy_Wars_scoreboard_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
		
		return true
	end
	return false
end

function destroyScoreboard(player)
	if verifyScoreboard(player) then
		Debug.log("Destroying Scoreboard GUI for "..player.name)
		player.gui.center["Proxy_Wars_scoreboard"].destroy()
		return true
	end
	return false
end

function verifyScoreboard(player)
	if player.gui.center["Proxy_Wars_scoreboard"] and player.gui.center["Proxy_Wars_scoreboard"].valid then
		return true
	end
	return false
end

--~~~~~ Value List GUI ~~~~~--
function drawValueList(player)
	if verifyOpenCenterGUI(player) then
		Debug.log("Drawing Value List GUI for "..player.name)
		local frame = player.gui.center.add{type="frame", name="Proxy_Wars_value_list", direction="vertical"}
		frame.add{type="label", caption={"Proxy_Wars_value_list_title"}, style="Proxy_Wars_lists_title"}
		
		local header = frame.add{type="flow", name="header_row", direction="horizontal"}
		header.add{type="label", caption={"Proxy_Wars_value_list_header_item"}, style="Proxy_Wars_value_list_header_name"}
		header.add{type="label", caption={"Proxy_Wars_value_list_header_value"}, style="Proxy_Wars_value_list_header_value"}
		
		local entries = frame.add{type="scroll-pane", name="scroll_pane", direction="vertical", style="Proxy_Wars_value_list_scroll_pane"}
		
		local itemPrototypes = game.item_prototypes
		local sortedValues = getSortedValueList()
		Debug.special("[Listing values]")
		for _, data in pairs(sortedValues) do
			if itemPrototypes[data.item] then
				if data.value > 0 then
					local entry = entries.add{type="flow", name="entry_"..data.item, direction="horizontal"}
					entry.add{type="label", caption=itemPrototypes[data.item].localised_name, style="Proxy_Wars_value_list_entry_item"}
					entry.add{type="label", caption=getFormattedNumber(data.value), style="Proxy_Wars_value_list_entry_value"}
					Debug.special_table(data)
				end
			end
		end
		
		local footer = frame.add{type="flow", name="footer_row", direction="horizontal"}
		footer.add{type="label", caption={"Proxy_Wars_current_money", getFormattedNumber(global.money[player.force.name])}, style="Proxy_Wars_value_list_current_money"}
		Debug.special("Money amount: "..global.money[player.force.name])
		footer.add{type="button", name="Proxy_Wars_value_list_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
		return true
	end
	return false
end

function destroyValueList(player)
	if verifyValueList(player) then
		Debug.log("Destroying Value List GUI for "..player.name)
		player.gui.center["Proxy_Wars_value_list"].destroy()
		return true
	end
	return false
end

function verifyValueList(player)
	if player.gui.center["Proxy_Wars_value_list"] and player.gui.center["Proxy_Wars_value_list"].valid then
		return true
	end
	return false
end

--~~~~~ Buy Biters GUI ~~~~~--
function drawBuyBiters(player)
	if verifyOpenCenterGUI(player) then
		Debug.log("Drawing Buy Biters GUI for "..player.name)
		local modifier = global.buy_biters_modifier[player.name]
		
		local frame = player.gui.center.add{type="frame", name="Proxy_Wars_buy_biters", direction="vertical"}
		frame.add{type="label", caption={"Proxy_Wars_buy_biters_title", modifier}, tooltip={"Proxy_Wars_buy_biters_title_tooltip"}, style="Proxy_Wars_lists_title"}
		
		local header = frame.add{type="flow", name="header_row", direction="horizontal"}
		header.add{type="label", caption={"Proxy_Wars_buy_biters_header_biter"}, style="Proxy_Wars_buy_biters_header_biter"}
		header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		header.add{type="label", caption={"Proxy_Wars_buy_biters_header_current"}, style="Proxy_Wars_buy_biters_header_current"}
		header.add{type="label", caption="|", style="Proxy_Wars_lists_separator"}
		header.add{type="label", caption={"Proxy_Wars_buy_biters_header_cost"}, style="Proxy_Wars_buy_biters_header_cost"}
		
		for name, cost in pairs(biter_costs) do
			local biter = frame.add{type="flow", name=name.."_cost", direction="horizontal"}
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
			biter.add{type="label", caption=getFormattedNumber(cost * modifier), style="Proxy_Wars_buy_biters_entry_cost"}
			Debug.special("Cost for biter ("..name..") at "..(cost * modifier))
		end
		
		local footer = frame.add{type="flow", name="footer_row", direction="horizontal"}
		footer.add{type="label", caption={"Proxy_Wars_current_money", getFormattedNumber(global.money[player.force.name])}, style="Proxy_Wars_buy_biters_current_money"}
		Debug.special("Money amount: "..global.money[player.force.name])
		footer.add{type="button", name="Proxy_Wars_buy_biters_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
		return true
	end
	return false
end

function updateBuyBiters(player)
	if verifyBuyBiters(player) then
		Debug.log("Updating Buy Biters GUI for "..player.name)
		local modifier = global.buy_biters_modifier[player.name]
		if destroyBuyBiters(player) then
			if modifier then global.buy_biters_modifier[player.name] = modifier end
			drawBuyBiters(player)
		end
		return true
	end
	return false
end

function destroyBuyBiters(player)
	if verifyBuyBiters(player) then
		Debug.log("Destroying Buy Biters GUI for "..player.name)
		player.gui.center["Proxy_Wars_buy_biters"].destroy()
		global.buy_biters_modifier[player.name] = 1
		return true
	end
	return false
end

function verifyBuyBiters(player)
	if player.gui.center["Proxy_Wars_buy_biters"] and player.gui.center["Proxy_Wars_buy_biters"].valid then
		return true
	end
	return false
end

--~~~~~ Help GUI ~~~~~--
function drawHelpMenu(player)
	if verifyOpenCenterGUI(player) then
		Debug.log("Drawing Help GUI for "..player.name)
		local frame = player.gui.center.add{type="frame", name="Proxy_Wars_help", direction="vertical", style="Proxy_Wars_help_frame"}
		frame.add{type="label", caption={"Proxy_Wars_help_title"}, style="Proxy_Wars_lists_title"}
		
		for i=1, 11 do
			frame.add{type="label", single_line=false, caption={"Proxy_Wars_help_"..i}, style="Proxy_Wars_help_body"}
		end
		
		local footer = frame.add{type="flow", name="footer_row", direction="horizontal"}
		footer.add{type="label", style="Proxy_Wars_help_close_spacer"}
		footer.add{type="button", name="Proxy_Wars_help_close", caption={"Proxy_Wars_lists_close"}, style="Proxy_Wars_lists_close"}
		return true
	end
	return false
end

function destroyHelpMenu(player)
	if verifyHelpMenu(player) then
		Debug.log("Destroying Help GUI for "..player.name)
		player.gui.center["Proxy_Wars_help"].destroy()
		return true
	end
	return false
end

function verifyHelpMenu(player)
	if player.gui.center["Proxy_Wars_help"] and player.gui.center["Proxy_Wars_help"].valid then
		return true
	end
	return false
end