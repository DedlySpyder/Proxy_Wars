Arena = {}

Arena.SURFACE_NAME = "Proxy_Wars_Arena"
Arena.SIZE = 200
Arena.RADIUS = Arena.SIZE / 2

--Create the arena surface
Arena.Create = function()
	local size = Arena.SIZE
	local arena = game.create_surface(Arena.SURFACE_NAME, {width = size, height = size})
	
	local tiles = {}
	for x=-size, size do
		for y=-size, size do
			table.insert(tiles, {name="grass", position={x, y}})
		end
	end
	arena.set_tiles(tiles, false)
	
	local chunks = {}
	for x=math.floor(-size/32), math.floor(size/32) do
		for y=math.floor(-size/32), math.floor(size/32) do
			table.insert(chunks, {x, y})
		end
	end
	for _, chunk in ipairs(chunks) do
		arena.set_chunk_generated_status(chunk, defines.chunk_generated_status.entities)
	end
	arena.always_day = true
end

Arena.Spectate = {}

--Toggle the spectating state of a player
-- @param player obj
Arena.Spectate.Toggle = function(player)
	if global.player_at_arena[player.name] then
		Arena.Spectate.Leave(player)
	else
		Arena.Spectate.Join(player)
	end
end

--Send a player to the arena (while leaving their character behind)
--If no player is provided then it will run on all players
-- @param player obj
Arena.Spectate.Join = function(player)
	if not player then
		for _, p in pairs(game.players) do
			Arena.Spectate.Join(p)
		end
		return nil
	end
	
	if not global.player_at_arena[player.name] then
		global.characters[player.name] = player.character
		player.character = nil
		if Surfaces.TeleportPlayer(player, Arena.SURFACE_NAME) then
			global.player_at_arena[player.name] = true
		else
			player.print("Couldn't spectate") --TODO - handle this somehow?
		end
	end
end

--Send a player back to their character and surface
--If no player is provided then it will run on all players
-- @param player obj (if not provided then it will be applied to all players)
Arena.Spectate.Leave = function(player)
	if not player then
		for _, p in pairs(game.players) do
			Arena.Spectate.Leave(p)
		end
		return nil
	end
	
	if global.player_at_arena[player.name] then
		if Surfaces.TeleportPlayer(player, global.player_list[player.name]) then
			player.character = global.characters[player.name]
			global.player_at_arena[player.name] = false
		else
			player.print("Couldn't stop spectating") --TODO - handle this somehow?
		end
	end
end

--Check the participants to see if only one (or none in a draw) remain
Arena.CheckForWinner = function()
	local participants = {}
	local num = 0
	for teamName, biters in pairs(global.spawned_biters) do
		for biter, amount in pairs(biters) do
			if amount > 0 then
				participants[teamName] = true
			end
		end
		if participants[teamName] then
			num = num + 1
		end
	end
	--[[
	for teamName, biters in pairs(global.spawned_biters) do
		if #biters > 0 then
			participants[teamName] = true
			num = num + 1
		end
	end
	]]
	Debug.info("There are still "..num.." team(s) in the fight.")
	
	if num == 0 then
		Utils.MessageAll({"Proxy_Wars_fight_result_draw"})
		Debug.info("Fight round ending in a draw")
		Round.End()
	elseif num == 1 then
		for winner, _ in pairs(participants) do
			Round.End(winner)
		end
	end
end

--Determine the spawns for the fight round, based on the eligible teams
-- @return table of [teamName] = spawnPosition
Arena.DetermineSpawns = function()
	local teams, num = Arena.GetTeamsWhoBoughtBiters()
	if num > 1 then
		Debug.info("There are "..num.." teams ready to start the round")
		local spawns = Arena.CalculateSpawnPoints(num)
		local i = 1
		for team, _ in pairs(teams) do
			Utils.MessageAll({"Proxy_Wars_fight_entering_fight", playerName})
			Debug.info(playerName.." is entering the fight") 
			teams[team] = spawns[i]
			i = i + 1
		end
	else
		Debug.warn("There is/are only "..num.." teams ready to start the round")
		return nil
	end
	return teams
end

--Get a list of all the teams who bought biters this round
-- @return table of [teamName] = true
-- @return number of teams
Arena.GetTeamsWhoBoughtBiters = function()
	local teams = {}
	local num = 0
	for teamName, biters in pairs(global.bought_biters) do
		for biterName, amount in pairs(biters) do
			if amount > 0 then
				teams[teamName] = true
			end
		end
		if teams[teamName] then 
			local playerName = global.assigned_teams[teamName].name
			num = num + 1
		end
	end
	return teams, num
end

--Calculate the spawn points for the num of provided teams
-- @param num number of spawn points to calculate
-- @return table of spawn points
Arena.CalculateSpawnPoints = function(num)
	local spawnRadius = Arena.RADIUS * 0.9
	local twoPi = 2 * math.pi
	local spawnPoints = {}
	local i = 0
	
	for a=0, twoPi, twoPi/num do
		if i < num then
			local x = Utils.RoundToDecimal(math.cos(a) * spawnRadius)
			local y = Utils.RoundToDecimal(math.sin(a) * spawnRadius)
			table.insert(spawnPoints, {x=x, y=y})
			Debug.info("Calculating spawn point at ("..x..", "..y..")")
		end
		i = i + 1
	end
	
	return spawnPoints
end
