PW_Game = {}

--Initialize the teams' forces
PW_Game.InitForces = function()
	local size = Arena.SIZE
	local arenaSurfaceName = Arena.SURFACE_NAME
	
	Debug.info("Initializing forces")
	for _, name in ipairs(team_names) do
		Debug.info("Creating force "..name)
		local force = game.create_force(name)
		force.chart(arenaSurfaceName, {{-size, -size}, {size, size}})
	end
end

--Assign a player to a team
-- @param player obj
-- @return true or false if the player was assigned
PW_Game.AssignTeam = function(player)
	for _, teamName in ipairs(team_names) do
		if not global.assigned_teams[teamName] then
			Debug.info("Assigning "..player.name.." to team "..teamName)
			global.assigned_teams[teamName] = player
			global.player_list[player.name] = teamName
			
			table.insert(global.points, {player=player.name, points=0})
			global.bought_biters[teamName] = global.bought_biters[teamName] or PW_Game.GetEmptyBitersTable()
			global.spawned_biters[teamName] = global.spawned_biters[teamName] or PW_Game.GetEmptyBitersTable()
			global.buy_biters_modifier[player.name] = 1
			global.money[teamName] = global.money[teamName] or 0
			
			player.force = teamName
			return true
		end
	end
	return false
end

--Start the Proxy Wars game
--Sends each player to their surface, cleans up pre-game GUI, and starts the first round
PW_Game.StartGame = function()
	for playerName, surfaceName in pairs(global.player_list) do
		if playerName then
			local player = game.players[playerName]
			Surfaces.TeleportPlayer(player, surfaceName)
			player.force.chart(surfaceName, {{-200, -200}, {200, 200}})
			player.character.active = true
		end
	end
	GUI.StartButton.Destroy()
	Round.Start()
end

--Attempts to buy a biter for the player's teamName
-- @param player obj
-- @param biterName to purchase
PW_Game.BuyBiter = function(player, biter)
	if biter then
		local teamName = player.force.name
		local modifier = global.buy_biters_modifier[player.name]
		local price = biter_costs[biter] * (modifier or 1) --TODO - config migration
		local money = global.money[teamName]
		Debug.info(player.name.." is purchasing "..modifier.." "..biter.." for "..price)
		
		if price <= money then
			global.money[teamName] = money - price
			global.bought_biters[teamName][biter] = global.bought_biters[teamName][biter] + modifier
			Debug.info(teamName.." now has "..global.bought_biters[teamName][biter].. " "..biter)
			
			GUI.BuyBiters.Refresh(player)
		else
			player.print({"Proxy_Wars_insufficient_funds"})
			Debug.warn(player.name.." attempted to buy a "..biter.." at "..price..", only having "..money)
		end
	end
end

--Checks if first and second have the same points
-- @return true or false
PW_Game.isTied = function()
	GUI.SortPoints()
	
	--Make sure there is not a tie for first
	if global.points[1] and global.points[2] and global.points[1].points == global.points[2].points then
		return true
	end
	return false
end

--Get an empty biters table
-- @return table with biters for keys and 0 for the values
PW_Game.GetEmptyBitersTable = function()
	local t = {}
	for name, _ in pairs(biter_costs) do --TODO - config migration
		t[name] = 0
	end
	return t
end

--Load balancer action to check the sell chests for items and give the team money
-- @param chest entity obj
PW_Game.SellChest = function(chest)
	local force = chest.force
	local inventory = chest.get_inventory(defines.inventory.chest)
	
	for item, amount in pairs(inventory.get_contents()) do
		local value = global.item_values[item]
		if value > 0 then
			global.money[force.name] = global.money[force.name] + (value * amount)
			inventory.remove({name=item, count=amount})
		end
	end
end
