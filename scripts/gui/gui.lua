GUI = {}

require "arena_button"
require "start_button"
require "main_menu" --Main menu requires its tabs
require "top_menu"

GUI.Init = function()
	--Arena Button
	Utils.Events.GUI.Add(GUI.ArenaButton.NAME, GUI.ArenaButton.OnClick)
	
	--Start Button
	Utils.Events.GUI.Add(GUI.StartButton.NAME, GUI.StartButton.OnClick)
	
	--Help GUI
	Utils.Events.GUI.Add(GUI.Help.NAME, GUI.Help.OnToggle)
	Utils.Events.GUI.Add("Proxy_Wars_help_close", GUI.Help.Close)
	
	--Scoreboard GUI
	Utils.Events.GUI.Add(GUI.Scoreboard.NAME, GUI.Scoreboard.OnToggle)
	Utils.Events.GUI.Add("Proxy_Wars_scoreboard_close", GUI.Scoreboard.Close)
	
	--Value List GUI
	Utils.Events.GUI.Add(GUI.ValueList.NAME, GUI.ValueList.OnToggle)
	Utils.Events.GUI.Add("Proxy_Wars_value_list_close", GUI.ValueList.Close)
	
	--Buy Biters GUI
	Utils.Events.GUI.Add(GUI.BuyBiters.NAME, GUI.BuyBiters.OnToggle)
	Utils.Events.GUI.Add("Proxy_Wars_buy_biters_close", GUI.BuyBiters.Close)
	Utils.Events.GUI.AddPartial("Proxy_Wars_buy_", GUI.BuyBiters.OnClickBuy)
end

GUI.BuyBiterModifier = {}
GUI.BuyBiterModifier.BASE_AMOUNT = 10
GUI.BuyBiterModifier.MAX_MODIFIER = 100

--Increase the buy biters modifier for a player
-- @param player obj
GUI.BuyBiterModifier.Change = function(player)
	local currentModifier = global.buy_biters_modifier[player.name]
	if currentModifier < GUI.BuyBiterModifier.MAX_MODIFIER then
		global.buy_biters_modifier[player.name] = currentModifier * GUI.BuyBiterModifier.BASE_AMOUNT
	else
		global.buy_biters_modifier[player.name] = 1
	end
	
	GUI.BuyBiters.Refresh(player)
end

--Sorts the global points table
GUI.SortPoints = function()
	Debug.info("Sorting Points")
	local flag = true
	local points = global.points
	local temp
	
	while flag do
		flag = false
		for i=1, (#points)-1 do
			if points[i+1].points > points[i].points then
				temp = points[i]
				points[i] = points[i+1]
				points[i+1] = temp
				
				flag = true
			end
		end
	end
	Debug.info("Sorted Points:")
	for i, data in ipairs(global.points) do
		Debug.log_no_tick(i..":")
		Debug.log_table(data)
	end
end

--Sorts a copy of the item values table
-- @return copy of the item values table sorted
GUI.GetSortedValueList = function()
	local values = GUI.MakeSortableValueList()
	local flag = true
	local temp
	
	while flag do
		flag = false
		for i=1, (#values)-1 do
			if values[i+1].item < values[i].item then
				temp = values[i]
				values[i] = values[i+1]
				values[i+1] = temp
				
				flag = true
			end
		end
	end
	
	return values
end

--Makes a copy of the item values list that can be sorted
-- @return number indexed table of {item=_, value=_}
GUI.MakeSortableValueList = function()
	local newTable = {}
	for item, value in pairs(global.item_values) do
		table.insert(newTable, {item=item, value=value})
	end
	return newTable
end

--Formats the number to have commas when necessary
--Formatting taken from here:
--http://lua-users.org/wiki/FormattingNumbers
-- @param num number to format
-- @return formatted number
GUI.GetFormattedNumber = function(num)
	if num then
		local flag = 1
		while flag ~= 0 do
			num, flag = string.gsub(num, "^(-?%d+)(%d%d%d)", '%1,%2')
		end
	end
	return num
end
