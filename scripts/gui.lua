--Handler for clicking the start button
function onClickedStartButton()
	startGame()
end

--Handler for clicking the arena transfer button
-- @param player obj
function onClickedArenaButton(player)
	if global.player_at_arena[player.name] then
		stopSpectatingArena(player)
		updateArenaButton(player, false)
	else
		spectateArena(player)
		updateArenaButton(player, true)
	end
end

--Attempts to buy a biter for the player's teamName
-- @param player obj
-- @param biterName to purchase
function buyBiter(player, biter)
	if biter then
		local teamName = player.force.name
		local modifier = global.buy_biters_modifier[player.name]
		local price = biter_costs[biter] * (modifier or 1)
		local money = global.money[teamName]
		Debug.info(player.name.." is purchasing "..modifier.." "..biter.." for "..price)
		
		if price <= money then
			global.money[teamName] = money - price
			global.bought_biters[teamName][biter] = global.bought_biters[teamName][biter] + modifier
			updateBuyBiters(player)
			
			Debug.info(teamName.." now has "..global.bought_biters[teamName][biter].. " "..biter)
		else
			player.print({"Proxy_Wars_insufficient_funds"})
			Debug.warn(player.name.." attempted to buy a "..biter.." at "..price..", only having money")
		end
	end
end

--Increase the buy biters modifier for a player
-- @param player obj
function increaseBuyBitersModifier(player)
	local currentModifier = global.buy_biters_modifier[player.name]
	if currentModifier ~= 100 then
		global.buy_biters_modifier[player.name] = currentModifier * 10
	else
		global.buy_biters_modifier[player.name] = 1
	end
	
	updateBuyBiters(player)
end

--Sorts the points table
function sortPoints()
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

--Format the round time
-- @return formatted time as a string
function formatRoundTime()
	local roundTime = global.round_time 
	local mins = math.floor(roundTime/60)
	local secs = (roundTime % 60)
	if mins < 10 then 
		mins = "0"..mins
	end
	if secs < 10 then
		secs = "0"..secs
	end
	return mins..":"..secs
end

--Sorts a copy of the item values table
-- @return copy of the item values table sorted
function getSortedValueList()
	local values = makeSortableValueList()
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
-- @return table
function makeSortableValueList()
	local newTable = {}
	for item, value in pairs(global.item_values) do
		table.insert(newTable, {item=item, value=value})
	end
	return newTable
end

--Formats the number to have commas when necessary
--Formatting taken from here:
--http://lua-users.org/wiki/FormattingNumbers
-- @param num number to formatRoundTime
-- @return formatted number
function getFormattedNumber(num)
	if num then
		local flag = 1
		while flag ~= 0 do
			num, flag = string.gsub(num, "^(-?%d+)(%d%d%d)", '%1,%2')
		end
	end
	return num
end