require "mod-gui"

require "scripts/debugger"
require "scripts/utils/utils"

require "scripts/gui/gui"

require "scripts/arena"
require "scripts/commands"
require "scripts/load_balancer_factory"
require "scripts/pw_game"
require "scripts/round"
require "scripts/surfaces"
require "scripts/values"

require "config" --TODO - for now - this will be a standalone menu

script.on_init(function()
	Debug.init_log()
	Utils.Events.GUI.Init()
	Utils.TabLib.Init()
	
	GUI.Init()
	
	global.map_gen_settings = global.map_gen_settings or game.surfaces["nauvis"].map_gen_settings
	
	global.item_values = global.item_values or item_values			--[itemName] = value			--TODO - config migration
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
	
	--Other globals used but don't need initialized:
	-- global.host
	-- global.game_started
	
	Values.Generate()
	Surfaces.Init()
	PW_Game.InitForces()
	
	--Load_Balancer_Factory.create() for each
	--Load balancer for every second
	global.second_load_balancer_work = global.second_load_balancer_work or {}
	global.secondly_balancer = Load_Balancer_Factory.create("Second", global.second_load_balancer_work, 60, "Secondly_")
	global.secondly_balancer:addAction(Round.Time.TickDown, 1)
	
	--Load balancer for every 5 seconds
	global.chest_load_balancer_work = global.chest_load_balancer_work or {}
	global.chest_balancer = Load_Balancer_Factory.create("Chest", global.chest_load_balancer_work, 300, "Chest_Action_")
	
	script.on_event(defines.events.on_tick, waiting_for_players)
end)

script.on_load(function()
	if global.game_started then
		script.on_event(defines.events.on_tick, Control.on_tick)
	else
		script.on_event(defines.events.on_tick, Control.waiting_for_players)
	end
end)

Control = {}

--Player connected event handler
Control.on_player_joined_game = function(event)
	if game.tick ~= 0 then
		Debug.init_log(event.player_index)
	end
end

script.on_event(defines.events.on_player_joined_game, Control.on_player_joined_game)

--Setting change event handler
Control.on_runtime_mod_setting_changed = function(event)
	Debug.setDebugLevel(event)
end

script.on_event(defines.events.on_runtime_mod_setting_changed, Control.on_runtime_mod_setting_changed)

--On tick event handler for the pre-game
--Replaced when the Proxy Wars game actually starts
Control.waiting_for_players = function()
	if game.tick ~= 0 then
		local wait_before_start = settings.global["Proxy_Wars_wait_before_start"].value
		if wait_before_start > 0 then
			if game.tick % (wait_before_start * 60) == 0 then
				drawStartButton()
			end
		else
			drawStartButton()
		end
	end
end

--On tick handler for the rest of the game
Control.on_tick = function()
	global.secondly_balancer:on_tick()
	global.chest_balancer:on_tick()
	--:on_tick() for each load balancer
end

--Player created event handler
Control.on_player_created = function(event)
	local player = game.players[event.player_index]
	
	--Set the first player to the host
	if not global.host then
		global.host = player
		player.print({"Proxy_Wars_host"})
	end
	
	--Attempt to assign the player to a team
	if PW_Game.AssignTeam(player) then
		player.print({"Proxy_Wars_assigned_team", global.player_list[player.name]})
		player.print({"Proxy_Wars_warning_dropping"})
		
		local wait_before_start = settings.global["Proxy_Wars_wait_before_start"].value
		if wait_before_start > 0 then
			player.print({"Proxy_Wars_waiting_for_start", wait_before_start})
		end
		
		GUI.TopMenu.AddPlayerButtons(player)
		
		player.character.active = false
		global.timer_actions[player.name] = global.secondly_balancer:addAction(Round.Time.Update, player)
	else
		GUI.TopMenu.Draw(player)
		--TODO - SPECTATORS - assign to spectators?
		--god controllers?
		--Need new ui for it
	end
	
	global.player_at_arena[player.name] = false
end

script.on_event(defines.events.on_player_created, Control.on_player_created)

--Entity built event handler
Control.on_built_entity = function(event)
	local entity = event.created_entity
	
	if entity.name == "sell-chest-proxy-wars" then
		global.chest_actions[Utils.PositionToString(entity.position)] = global.chest_balancer:addAction(PW_Game.SellChest, entity)
	end
end

script.on_event(defines.events.on_built_entity, Control.on_built_entity)
script.on_event(defines.events.on_robot_built_entity, Control.on_built_entity)

--Entity removed event handler
Control.on_entity_removed = function(event)
	--TODO? - event.force for the killing blow is in here, if we want to use that
	local entity = event.entity
	
	--If it is a biter of a team force
	if biter_costs[entity.name] then --TODO - migration - config
		if global.assigned_teams[entity.force.name] then
			global.spawned_biters[entity.force.name][entity.name] = global.spawned_biters[entity.force.name][entity.name] - 1
			global.last_fight_death = game.tick
			--local func = function(arg) return entity == arg end
			--global.spawned_biters[entity.force.name] = Utils.Table.Filter.ByValue(global.spawned_biters[entity.force.name], func)
			--Debug.info(entity.force.name.." lost a "..entity.name.." "..#global.spawned_biters[entity.force.name].." remaining")
			Arena.CheckForWinner()
			return
		end
	end
	
	if entity.name == "sell-chest-proxy-wars" then
		global.chest_balancer:removeAction(global.chest_actions[Utils.PositionToString(entity.position)])
		global.chest_actions[Utils.PositionToString(entity.position)] = nil
		return
	end
end

script.on_event(defines.events.on_entity_died, Control.on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, Control.on_entity_removed)
script.on_event(defines.events.on_preplayer_mined_item, Control.on_entity_removed)

--GUI click events are entirely handled by the Event Utils
script.on_event(defines.events.on_gui_click, Utils.Events.GUI.OnGuiClicked)

--Hotkey event handlers
Control.on_buy_biter_modifier = function(event)
	local player = game.players[event.player_index]
	Debug.info(player.name.." pressed the buy biters modifier hotkey")
	
	if GUI.BuyBiters.Verify(player) then
		GUI.BuyBiterModifier.Change(player)
	end
end

script.on_event("Proxy_Wars_view_scoreboard", GUI.Scoreboard.OnToggle)
script.on_event("Proxy_Wars_view_value_list", GUI.ValueList.OnToggle)
script.on_event("Proxy_Wars_view_buy_biters", GUI.BuyBiters.OnToggle)
script.on_event("Proxy_Wars_buy_biter_modifier", Control.on_buy_biter_modifier)
script.on_event("Proxy_Wars_view_help", GUI.Help.OnToggle)
