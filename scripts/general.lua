--Reset the timer
function startRound()
	Debug.info("Starting round")
	global.round_time = round_length * 60
end

--Cleanup after the fight round is finished
-- @param winner teamName of the winner (if available)
function endRound(winner)
	if winner then
		local playerName = global.assigned_teams[winner].name
		messageAll({"Proxy_Wars_fight_result_winner", playerName})
		Debug.info(playerName.." won a round.")
		for _, data in ipairs(global.points) do
			if data.player == playerName then
				data.points = data.points + 1
			end
		end
		Debug.log_table(global.points)
	end
	destroyArenaButtonAll()
	global.secondly_balancer:removeAction("round_timeout")
	
	--Send everyone back home
	for playerName, atArena in pairs(global.player_at_arena) do
		if atArena then
			stopSpectatingArena(game.players[playerName])
		end
	end
	
	--Cleanup remaining biters
	local remainingBiters = game.surfaces["Proxy_Wars_Arena"].find_entities_filtered{}
	for _, biter in pairs(remainingBiters) do
		biter.destroy()
	end
	
	for teamName, _ in pairs(global.spawned_biters) do
		global.spawned_biters[teamName] = getBlankBitersTable()
		
		local unitGroup = global.biter_groups[teamName]
		if unitGroup and unitGroup.valid then
			unitGroup.destroy()
		end
		
		global.biter_groups[teamName] = nil
	end
	startRound()
end

--Get an empty biters table
-- @return table with biters for keys and 0 for the values
function getBlankBitersTable()
	local t = {}
	for name, _ in pairs(biter_costs) do
		t[name] = 0
	end
	return t
end

--Send a message to all players
-- @param message string to send to players
function messageAll(message)
	for _, player in pairs(game.players) do
		player.print(message)
	end
end

--Sound the klaxon for all players
function soundKlaxonAll()
	Debug.info("Sounding klaxon for all players")
	for _, player in pairs(game.players) do
		soundKlaxon(player)
	end
end

--Sound the klaxon near one player
-- @param player obj
function soundKlaxon(player)
	player.surface.create_entity({name="Proxy_Wars_klaxon", position=player.position})
end

--Round a number to X decimal places
--http://lua-users.org/wiki/SimpleRound
-- @param num number to round
-- @param numDecimalPlaces number of decimal places to round
-- @return rounded number
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

--Convert a position table to a string
-- @param position table
-- @return string position
function positionToString(position)
	if position.x then
		return "("..position.x..","..position.y..")"
	else
		return "("..position[1]..","..position[2]..")"
	end
end

--Removes an entity from a table (testing versus the values of the table)
-- @param func test for values
-- @param oldTable table to remove the entry from
-- @return table with entry(s) removed
function removeFromTable(func, oldTable)
	if (oldTable == nil) then return nil end
	local newTable = {}
	for _, row in ipairs(oldTable) do
		if not func(row) then table.insert(newTable, row) end
	end
	return newTable
end

--Removes an entity from a table (testing versus the keys of the table)
-- @param func test for keys
-- @param oldTable table to remove the entry from
-- @return table with entry(s) removed
function removeFromTableWithKey(func, oldTable)
	if (oldTable == nil) then return nil end
	local newTable = {}
	for key, row in pairs(oldTable) do
		if not func(key) then newTable[key] = row end
	end
	return newTable
end