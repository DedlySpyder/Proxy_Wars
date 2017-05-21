--Action to update the timers for a player
-- @param player obj
function updateRoundTime(player)
	if verifyMainMenu(player) then
		--Debug.info("Updating Round Time for "..player.name) --DEBUG
		local timer = mod_gui.get_frame_flow(player)["Proxy_Wars_main_frame"]["Proxy_Wars_round_timer"]
		local currentTime = global.round_time
		timer.caption = formatRoundTime(currentTime)
		if currentTime == round_timer_warning then
			timer.style.font_color = {r = 1, g = 0, b = 0, a = 0.8}
		elseif currentTime == round_timer_yellow then
			timer.style.font_color = {r = 1, g = 1, b = 0.2,  a = 0.8}
		elseif currentTime == 0 then
			timer.style.font_color = {r = 1, g = 1, b = 1, a = 1}
		end
	end
end

--Action to lower the round time
function tickRoundTimeDown()
	--Debug.info("Old round time: "..global.round_time) --DEBUG
	local currentTime = global.round_time - 1
	if currentTime > 0 then
		if currentTime == round_timer_warning then
			soundKlaxonAll()
		end
		global.round_time = currentTime
	elseif currentTime == 0 then
		soundKlaxonAll()
		global.round_time = currentTime
		startFightRound()
	end
end

function roundTimeOut()
	if global.last_fight_death then
		if game.tick - global.last_fight_death > 1800 then
			Debug.info("Round timeout")
			messageAll({"Proxy_Wars_fight_timeout"})
			local finalPoints = {}
			for teamName, biters in pairs(global.spawned_biters) do
				local teamPoints = 0
				for biterName, amount in pairs(biters) do
					local biterValue = math.max(biter_costs[biterName], 1)
					teamPoints = teamPoints + (biterValue * amount)
				end
				finalPoints[teamName] = teamPoints
				Debug.info(teamName.." ending the round with "..points)
				messageAll({"Proxy_Wars_fight_timeout_points", global.assigned_teams[teamName].name, teamPoints})
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
			endRound(winner)
		end
	end
end

--[[
--Action to give the move command to biters in the arena, until the command sticks
--Biters were not reliably moving otherwise
--Removes itself as needed
function giveMoveCommandsGroup()
	local didWork = false
	for teamName, unitGroup in pairs(global.biter_groups) do
		Debug.console("Commanding biters") --TODO
		if unitGroup and unitGroup.valid then
			Debug.console("#:"..#unitGroup.members.." State:"..unitGroup.state)
			if unitGroup.state ~= 1 and unitGroup.state ~= 2 and unitGroup.state ~= 3 then
				Debug.console("Giving command") --TODO
				unitGroup.set_command({type=defines.command.attack_area, radius=10, destination={0,0}})
				Debug.info(teamName.." biters are moving to 0,0")
				didWork = true
			end
			local n = 0
			for _, biter in pairs(unitGroup.members) do
				if biter.has_command then n = n + 1 end
			end
			--Debug.info("w/ commands:"..n)
			unitGroup.start_moving()
		else
			Debug.info("Error with "..teamName.."'s unit group in arena")
		end
	end
	
	if not didWork then
		global.secondly_balancer:removeAction("give_move_commands_group")
	end
end

--TODO
--{entity=biter, lastPosition=biter.position}
function giveMoveCommandsBiter(biter)
	local entity = biter.entity
	
	if entity and entity.valid then
		local position = entity.position
		if not movedCloserToCenter(entity, biter.lastPosition) then
			Debug.info("A "..entity.force.name.." biter isn't moving closer")
			biter.chances = biter.chances + 1
		end
		
		if biter.chances > 5 then
			local force = entity.force
			local name = entity.name
			local newBiter = entity.surface.create_entity({name=name, force=force, position=position})
			local spawnedGlobal = global.spawned_biters[force.name]
			
			table.insert(spawnedGlobal, newBiter)
			newBiter.set_command({type=defines.command.attack_area, radius=10, destination={0,0}})
			
			local func = function(arg) return arg == entity end
			spawnedGlobal = removeFromTable(func, spawnedGlobal)
			entity.destroy()
			
			biter.entity = newBiter
			biter.chances = 0
		end
		biter.lastPosition = position
	end
	return biter
end

function movedCloserToCenter(biter, lastPosition)
	local currentX = math.abs(biter.position.x)
	local currentY = math.abs(biter.position.y)
	
	if currentX > 10 or currentY > 10 then
		local lastX = math.abs(lastPosition.x)
		local lastY = math.abs(lastPosition.y)
		
		local flag = nil
		
		if currentX < lastX or currentY < lastY then
			Debug.info("Moving closer:current("..currentX..","..currentY.."),last("..lastX..","..lastY..")")
			return true
		else
			Debug.info("NOT Moving closer:current("..currentX..","..currentY.."),last("..lastX..","..lastY..")")
			return false
		end
	end
end
]]

--Action to check the sell chests for items and give the team money
-- @param chest entity obj
function chestWork(chest)
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