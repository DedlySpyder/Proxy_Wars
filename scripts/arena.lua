arena_size_x = 200
arena_size_y = 200
arena_radius = 100

--Attempts to start the current round of fighting
--Either spawns biters and starts fight or skips the round if not enough teams bought biters
function startFightRound()
	if spawnBiters() then
		--Play a normal round
		drawArenaButtonAll()
		--global.secondly_balancer:addAction(giveMoveCommandsGroup, " ", "give_move_commands_group")
	else
		local teams, num = getTeamsWhoBoughtBiters()
		if num == 1 then
			--Only 1 person bought biters, give them the win
			for team, _ in pairs(teams) do
				global.spawned_biters[team] = global.bought_biters[team]
				global.bought_biters[team] = getBlankBitersTable()
				endRound(team)
			end
		else
			--No one bought biters
			messageAll({"Proxy_Wars_fight_skip_round"})
			startRound()
		end
	end
end

--Send a player to the arena (while leaving their character behind)
-- @param player obj
function spectateArena(player)
	global.player_at_arena[player.name] = true
	global.characters[player.name] = player.character
	player.character = nil
	teleportPlayer(player, "Proxy_Wars_Arena")
end

--Send a player back to their character and surface
-- @param player obj
function stopSpectatingArena(player)
	global.player_at_arena[player.name] = false
	teleportPlayer(player, global.player_list[player.name])
	player.character = global.characters[player.name]
end

--Check the participants to see if only one (or none in a draw) remain
function checkForWinner()
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
	Debug.log("There are still "..num.." team(s) in the fight.")
	
	if num == 0 then
		messageAll({"Proxy_Wars_fight_result_draw"})
		Debug.log("Fight round ending in a draw")
		endRound()
	elseif num == 1 then
		for winner, _ in pairs(participants) do
			endRound(winner)
		end
	end
end

--Spawn biters for this round of fighting
-- @return true or false if biters were spawned
function spawnBiters()
	local arena = game.surfaces["Proxy_Wars_Arena"]
	local spawns = determineSpawns()
	local bought_biters = global.bought_biters
	
	--Spawn biters only if enough teams are ready
	if spawns then
		for teamName, spawnPosition in pairs(spawns) do
			local force = game.forces[teamName]
			local unitGroup = arena.create_unit_group{position=spawnPosition, force=force}
			local spawnZoneRadius = (arena_radius * 0.1) * 2
			for biter, amount in pairs(bought_biters[teamName]) do
				local spawned = 0
				for i=1, amount do
					local position = arena.find_non_colliding_position(biter, spawnPosition, spawnZoneRadius, 0.1)
					if position then
						local biter = arena.create_entity{name=biter, position=position, force=force}
						unitGroup.add_member(biter)
						--biter.set_command({type=defines.command.attack_area, radius=10, destination={0,0}})
						--table.insert(global.spawned_biters[teamName], biter)
						
						local actionData = {entity=biter, lastPosition=biter.position, chances=0}
						--global.secondly_balancer:addAction(giveMoveCommandsBiter, actionData, "give_move_commands_biter_"..force.name.."_"..spawned)
						
						spawned = spawned + 1
					end
				end
				global.spawned_biters[teamName][biter] = spawned
				global.bought_biters[teamName][biter] = amount - spawned
				Debug.log("Spawned "..spawned.." "..biter.."(s) at position ("..spawnPosition.x..", "..spawnPosition.y..") for "..teamName)
			end
			unitGroup.set_command({type=defines.command.go_to_location, destination={0,0}, distraction=defines.distraction.by_damage})
			global.biter_groups[teamName] = unitGroup
			--Debug.log("Biter Group:# - "..#global.biter_groups[teamName].members)
		end
		global.last_fight_death = nil
		global.secondly_balancer:addAction(roundTimeOut, " ", "round_timeout")
		return true
	end
	return false
end

--Determine the spawns for the fight round, based on the eligible teams
-- @return table of [teamName] = spawnPosition
function determineSpawns()
	local teams, num = getTeamsWhoBoughtBiters()
	if num > 1 then
		Debug.log("There are "..num.." teams ready to start the round")
		local spawns = calculateSpawnPoints(num)
		local i = 1
		for team, _ in pairs(teams) do
			messageAll({"Proxy_Wars_fight_entering_fight", playerName})
			Debug.log(playerName.." is entering the fight") 
			teams[team] = spawns[i]
			i = i + 1
		end
	else
		Debug.log("There are only "..num.." teams ready to start the round")
		return nil
	end
	return teams
end

--Get a list of all the teams who bought biters this round
-- @return table of [teamName] = true
--		   number of teams
function getTeamsWhoBoughtBiters()
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
function calculateSpawnPoints(num)
	local spawnRadius = arena_radius * 0.9
	local twoPi = 2 * math.pi
	local spawnPoints = {}
	local i = 0
	
	for a=0, twoPi, twoPi/num do
		if i < num then
			local x = round(math.cos(a) * spawnRadius)
			local y = round(math.sin(a) * spawnRadius)
			table.insert(spawnPoints, {x=x, y=y})
			Debug.log("Calculating spawn point at ("..x..", "..y..")")
		end
		i = i + 1
	end
	
	return spawnPoints
end