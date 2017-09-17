require("mod-gui")

require "config"
require "scripts/debugger"
require "scripts/load_balancer_factory"
require "scripts/load_balancer_actions"
require "scripts/arena"
require "scripts/init"
require "scripts/general"
require "scripts/surfaces"
require "scripts/gui"
require "scripts/gui_update"
require "scripts/item_values"
require "scripts/commands"

script.on_init(function()
	Debug.init_log()
	global.map_gen_settings = global.map_gen_settings or game.surfaces["nauvis"].map_gen_settings
	
	global.item_values = global.item_values or item_values			--[itemName] = value
	global.player_list = global.player_list or {}					--[playerName] = teamName
	global.assigned_teams = global.assigned_teams or {}				--[teamName] = player (obj)
	global.points = global.points or {}								--[i] = {player=playerName, points=points}
	global.bought_biters = global.bought_biters or {}				--[teamName] = [biterName] = amount
	global.spawned_biters = global.spawned_biters or {}				--[teamName] = [biterName] = amount
	--global.spawned_biters = global.spawned_biters or {}				--[teamName] = biter objs --TODO
	global.biter_groups = global.biter_groups or {}					--[teamName] = unit group
	global.money = global.money or {}								--[teamName] = money
	global.buy_biters_modifier = global.buy_biters_modifier or {}	--[playerName] = modifier
	global.player_at_arena = global.player_at_arena or {}			--[playerName] = bool (flag for if they are in the arena)
	global.characters = global.characters or {}						--[playerName] = character
	
	global.timer_actions = global.timer_actions or {} -- Container for player timer updates action names
	global.chest_actions = global.chest_actions or {} -- Container for chest action names
	
	--global.host
	global.round_time = global.round_time or 0
	global.last_fight_death = global.last_fight_death or nil
	
	global.current_round = global.current_round or 0
	
	generateValues()
	initializeSurfaces()
	initializeForces()
	
	--Load balancer for every second
	global.second_load_balancer_work = global.second_load_balancer_work or {}
	global.secondly_balancer = Load_Balancer_Factory.create("Second", global.second_load_balancer_work, 60, "Secondly_")
	global.secondly_balancer:addAction(tickRoundTimeDown, 1)
	
	--Load balancer for every 5 seconds
	global.chest_load_balancer_work = global.chest_load_balancer_work or {}
	global.chest_balancer = Load_Balancer_Factory.create("Chest", global.chest_load_balancer_work, 300, "Chest_Action_")
	--Load_Balancer_Factory.create() for each
	
	script.on_event(defines.events.on_tick, waiting_for_players)
end)

script.on_load(function()
	if global.game_started then
		script.on_event(defines.events.on_tick, on_tick)
	else
		script.on_event(defines.events.on_tick, waiting_for_players)
	end
end)

--Player connected event handler
function on_player_joined_game(event)
	if game.tick ~= 0 then
		Debug.init_log(event.player_index)
	end
end

script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

--Setting change event handler
function on_runtime_mod_setting_changed(event)
	local setting = event.setting
	
	if setting == "Proxy_Wars_log_level" then
		Debug.log_level = debugger_levels[settings.global["Proxy_Wars_log_level"].value]
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)

--On tick event handler for the pre-game
--Replaced when the Proxy Wars game actually starts
function waiting_for_players()
	if game.tick ~= 0 then
		if wait_before_start > 0 then
			if game.tick % (wait_before_start * 60) == 0 then
				drawStartButton()
			end
		else
			drawStartButton()
		end
	end
end

function on_tick()
	global.secondly_balancer:on_tick()
	global.chest_balancer:on_tick()
	--:on_tick() for each load balancer
end

function on_player_created(event)
	local player = game.players[event.player_index]
	
	--Set the first player to the host
	if not global.host then
		global.host = player
		player.print({"Proxy_Wars_host"})
	end
	
	--Attempt to assign the player to a team
	if assignTeam(player) then
		player.print({"Proxy_Wars_assigned_team", global.player_list[player.name]})
		player.print({"Proxy_Wars_warning_dropping"})
		
		if wait_before_start > 0 then
			player.print({"Proxy_Wars_waiting_for_start", wait_before_start})
		end
		
		drawProxyWarsPlayerMenu(player)
		
		player.character.active = false
		global.timer_actions[player.name] = global.secondly_balancer:addAction(updateRoundTime, player)
	else
		drawMainMenu(player)
		--TODO - assign to spectators?
		--god controllers?
		--Need new ui for it
	end
	
	global.player_at_arena[player.name] = false
end

script.on_event(defines.events.on_player_created, on_player_created)

function on_built_entity(event)
	local entity = event.created_entity
	
	if entity.name == "sell-chest-proxy-wars" then
		global.chest_actions[positionToString(entity.position)] = global.chest_balancer:addAction(chestWork, entity)
	end
end

script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)

function on_entity_removed(event)
	--event.force for the killing blow is in here, if we want to use that
	local entity = event.entity
	
	--If it is a biter of a team force
	if biter_costs[entity.name] then
		if global.assigned_teams[entity.force.name] then
			global.spawned_biters[entity.force.name][entity.name] = global.spawned_biters[entity.force.name][entity.name] - 1
			global.last_fight_death = game.tick
			--local func = function(arg) return entity == arg end
			--global.spawned_biters[entity.force.name] = removeFromTable(func, global.spawned_biters[entity.force.name])
			--Debug.info(entity.force.name.." lost a "..entity.name.." "..#global.spawned_biters[entity.force.name].." remaining")
			checkForWinner()
			return
		end
	end
	
	if entity.name == "sell-chest-proxy-wars" then
		global.chest_balancer:removeAction(global.chest_actions[positionToString(entity.position)])
		global.chest_actions[positionToString(entity.position)] = nil
		return
	end
end

script.on_event(defines.events.on_entity_died, on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed)
script.on_event(defines.events.on_preplayer_mined_item, on_entity_removed)

function on_gui_click(event)
	local player = game.players[event.player_index]
	local element = event.element
	
	if string.sub(element.name, 1, 11) == "Proxy_Wars_" then
		Debug.info("Mod button "..element.name.." pressed by "..player.name)
		local modButton = string.sub(element.name, 12)
		
		--Start Game button
		if modButton == "start" then
			Debug.info("Start button pressed by "..player.name)
			if player == global.host then
				messageAll({"Proxy_Wars_starting_game"})
				onClickedStartButton()
				script.on_event(defines.events.on_tick, on_tick)
				global.game_started = true
			else
				player.print({"Proxy_Wars_warning_start_not_host"})
			end
			
		--Players Menu buttons
		elseif modButton == "view_help" then
			if not drawHelpMenu(player) then destroyHelpMenu(player) end
		elseif modButton == "view_scoreboard" then
			if not drawScoreboard(player) then destroyScoreboard(player) end
		elseif modButton == "view_value_list" then
			if not drawValueList(player) then destroyValueList(player) end
		elseif modButton == "view_buy_biters" then
			if not drawBuyBiters(player) then destroyBuyBiters(player) end
			
		--Close Help button
		elseif modButton == "help_close" then
			destroyHelpMenu(player)
			
		--Close Scoreboard button
		elseif modButton == "scoreboard_close" then
			destroyScoreboard(player)
		
		--Close Value List button
		elseif modButton == "value_list_close" then
			destroyValueList(player)
			
		--Close Buy Biters button
		elseif modButton == "buy_biters_close" then
			destroyBuyBiters(player)
			
		--Go To Arena button
		elseif modButton == "arena" then
			onClickedArenaButton(player)
			
		--Just the buy biters frame, which causes issues when clicked
		elseif modButton == "buy_biters" then
			return
			
		elseif string.sub(modButton, 1, 4) == "buy_" then
			buyBiter(player, string.sub(modButton, 5))
		end
	end
end

script.on_event(defines.events.on_gui_click, on_gui_click)

--Hotkeys
function on_view_scroreboard(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the view scoreboard hotkey")
	if not drawScoreboard(player) then destroyScoreboard(player) end
end

function on_view_value_list(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the view value list hotkey")
	if not drawValueList(player) then destroyValueList(player) end
end

function on_view_buy_biters(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the view buy biters hotkey")
	if not drawBuyBiters(player) then destroyBuyBiters(player) end
end

function on_buy_biter_modifier(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the buy biters modifier hotkey")
	if verifyBuyBiters(player) then increaseBuyBitersModifier(player) end
end

function on_view_help(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the view help hotkey")
	if not drawHelpMenu(player) then destroyHelpMenu(player) end
end

script.on_event("Proxy_Wars_view_scoreboard", on_view_scroreboard)
script.on_event("Proxy_Wars_view_value_list", on_view_value_list)
script.on_event("Proxy_Wars_view_buy_biters", on_view_buy_biters)
script.on_event("Proxy_Wars_buy_biter_modifier", on_buy_biter_modifier)
script.on_event("Proxy_Wars_view_help", on_view_help)
