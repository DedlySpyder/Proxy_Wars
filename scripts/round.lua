Round = {}

--How long a fight will last without biter kills before the fight ends
Round.FIGHT_TIMEOUT = 60*30

Round.Start = function()
	Debug.info("Starting round")
	global.round_time = settings.global["Proxy_Wars_round_length"].value * 60
	global.current_round = global.current_round + 1
end

--Cleanup after the fight round is finished
-- @param winner teamName of the winner (if available)
Round.End = function()
	if winner then
		local playerName = global.assigned_teams[winner].name
		Utils.MessageAll({"Proxy_Wars_fight_result_winner", playerName})
		Debug.info(playerName.." won a round.")
		for _, data in ipairs(global.points) do
			if data.player == playerName then
				data.points = data.points + 1
			end
		end
		Debug.log_table(global.points)
	end
	GUI.ArenaButton.Destroy()
	global.secondly_balancer:removeAction("round_timeout")
	
	--Send everyone back home
	Arena.Spectate.Leave()
	
	--Cleanup remaining biters
	local remainingBiters = game.surfaces[Arena.SURFACE_NAME].find_entities()
	for _, biter in pairs(remainingBiters) do
		biter.destroy()
	end
	
	--Cleanup the biter uniter groups
	for teamName, _ in pairs(global.spawned_biters) do
		global.spawned_biters[teamName] = PW_Game.GetEmptyBitersTable()
		
		local unitGroup = global.biter_groups[teamName]
		if unitGroup and unitGroup.valid then
			unitGroup.destroy()
		end
		
		global.biter_groups[teamName] = nil
	end
	
	--Determine if the game should continue or not
	if global.current_round < settings.global["Proxy_Wars_game_length"].value then
		--Game not over yet
		Round.Start()
	elseif PW_Game.isTied() then
		--Game is tied
		Utils.MessageAll({Proxy_Wars_game_tied})
		Round.Start()
	else
		--Game is over
		Utils.MessageAll({"Proxy_Wars_ending_game"})
		Utils.MessageAll({"Proxy_Wars_game_winner", global.points[1].player})
		
		--Reset the timer and kill the on_tick event
		global.round_time = 0
		for _, player in pairs(game.players) do
			Round.Time.Update(player)
		end
		script.on_event(defines.events.on_tick, nil)
	end
end

--Attempts to start the current round of fighting
--Either spawns biters and starts fight or skips the round if not enough teams bought biters
Round.StartFight = function()
	if Round.SpawnBiters() then
		--Play a normal round
		GUI.ArenaButton.Draw()
		--global.secondly_balancer:addAction(giveMoveCommandsGroup, " ", "give_move_commands_group")
	else
		for _, player in pairs(game.players) do
			Round.Time.Update(player)
		end
		local teams, num = Arena.GetTeamsWhoBoughtBiters()
		if num == 1 then
			--Only 1 person bought biters, give them the win
			for team, _ in pairs(teams) do
				global.spawned_biters[team] = global.bought_biters[team]
				global.bought_biters[team] = PW_Game.GetEmptyBitersTable()
				Round.End(team)
			end
		else
			--No one bought biters
			Utils.MessageAll({"Proxy_Wars_fight_skip_round"})
			Round.Start()
		end
	end
end

--Check if the fight has not had a kill in a while (can be caused by some biters not wanting to fight)
Round.TimeOutFight = function()
	if global.last_fight_death then
		if game.tick - global.last_fight_death > Round.FIGHT_TIMEOUT then
			Debug.info("Round timeout")
			Utils.MessageAll({"Proxy_Wars_fight_timeout"})
			local finalPoints = {}
			for teamName, biters in pairs(global.spawned_biters) do
				local teamPoints = 0
				for biterName, amount in pairs(biters) do
					local biterValue = math.max(biter_costs[biterName], 1) --TODO - config migration
					teamPoints = teamPoints + (biterValue * amount)
				end
				finalPoints[teamName] = teamPoints
				Debug.info(teamName.." ending the round with "..points)
				Utils.MessageAll({"Proxy_Wars_fight_timeout_points", global.assigned_teams[teamName].name, teamPoints})
			end
			
			local winner = nil
			local highestPoints = 0
			for teamName, points in pairs(finalPoints) do
				if points > highestPoints then 
					winner = teamName
				elseif points == highestPoints then
					winner = nil
				end
			end
			Round.End(winner)
		end
	end
end

--Spawn biters for this round of fighting
-- @return true or false if biters were spawned
Round.SpawnBiters = function()
	local arena = game.surfaces[Arena.SURFACE_NAME]
	local spawns = Arena.DetermineSpawns()
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
				Debug.info("Spawned "..spawned.." "..biter.."(s) at position ("..spawnPosition.x..", "..spawnPosition.y..") for "..teamName)
			end
			unitGroup.set_command({type=defines.command.go_to_location, destination={0,0}, distraction=defines.distraction.by_damage})
			global.biter_groups[teamName] = unitGroup
			--Debug.info("Biter Group:# - "..#global.biter_groups[teamName].members)
		end
		global.last_fight_death = nil
		global.secondly_balancer:addAction(Round.TimeOutFight, " ", "round_timeout")
		return true
	end
	return false
end

Round.Time = {}

--Action to update the timers for a player
-- @param player obj
Round.Time.Update = function(player)
	if GUI.TopMenu.Verify(player) then
		--Debug.info("Updating Round Time for "..player.name) --DEBUG
		local timer = mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"]["Proxy_Wars_round_timer"]
		local currentTime = global.round_time
		timer.caption = Utils.String.FormatTime(currentTime)
		if currentTime == settings.global["Proxy_Wars_round_timer_alert"].value then
			timer.style.font_color = {r = 1, g = 0, b = 0, a = 0.8}
		elseif currentTime == settings.global["Proxy_Wars_round_timer_warning"].value then
			timer.style.font_color = {r = 1, g = 1, b = 0.2,  a = 0.8}
		elseif currentTime == 0 then
			timer.style.font_color = {r = 1, g = 1, b = 1, a = 1}
		end
	end
end

--Action to lower the round time
Round.Time.TickDown = function()
	--Debug.info("Old round time: "..global.round_time) --DEBUG
	local currentTime = global.round_time - 1
	if currentTime > 0 then
		if currentTime == settings.global["Proxy_Wars_round_timer_alert"].value then
			Utils.SoundKlaxon()
		end
		global.round_time = currentTime
	elseif currentTime == 0 then
		Utils.SoundKlaxon()
		global.round_time = currentTime
		Round.StartFight()
	end
end

