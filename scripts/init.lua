--Sizes taken from arena.lua
local sizeX = arena_size_x
local sizeY = arena_size_y

--Initialize the surfaces
--Teams surfaces and arena
function initializeSurfaces()
	Debug.log("Initializing surfaces")
	createArena()
	
	for _, name in ipairs(team_names) do
		Debug.log("Creating surface "..name)
		local surface = game.create_surface(name, global.map_gen_settings)
		surface.request_to_generate_chunks({0, 0}, 6)
		surface.regenerate_entity({
			"iron-ore",
			"copper-ore",
			"stone",
			"coal"
		})
	end
end

--Initialize the forces
function initializeForces()
	Debug.log("Initializing forces")
	for _, name in ipairs(team_names) do
		Debug.log("Creating force "..name)
		local force = game.create_force(name)
		force.chart("Proxy_Wars_Arena", {{-sizeX, -sizeY}, {sizeX, sizeY}})
	end
end

--Create the arena surface
function createArena()
	local arena = game.create_surface("Proxy_Wars_Arena", {width = sizeX, height = sizeY})
	
	local tiles = {}
	for x=-sizeX, sizeX do
		for y=-sizeY, sizeY do
			table.insert(tiles, {name="grass-1", position={x, y}})
		end
	end
	arena.set_tiles(tiles, false)
	
	local chunks = {}
	for x=math.floor(-sizeX/32), math.floor(sizeX/32) do
		for y=math.floor(-sizeY/32), math.floor(sizeY/32) do
			table.insert(chunks, {x, y})
		end
	end
	for _, chunk in ipairs(chunks) do
		arena.set_chunk_generated_status(chunk, defines.chunk_generated_status.entities)
	end
	arena.always_day = true
end

--Assign a player to a team
-- @param player obj
-- @return true or false if the player was assigned
function assignTeam(player)
	for _, teamName in ipairs(team_names) do
		if not global.assigned_teams[teamName] then
			Debug.log("Assigning "..player.name.." to team "..teamName)
			global.assigned_teams[teamName] = player
			global.player_list[player.name] = teamName
			
			table.insert(global.points, {player=player.name, points=0})
			global.bought_biters[teamName] = global.bought_biters[teamName] or getBlankBitersTable()
			global.spawned_biters[teamName] = global.spawned_biters[teamName] or getBlankBitersTable() --{} --TODO
			global.buy_biters_modifier[player.name] = 1
			global.money[teamName] = global.money[teamName] or 0
			
			player.force = teamName
			return true
		end
	end
	return false
end

--Start the game
function startGame()
	for playerName, surfaceName in pairs(global.player_list) do
		if playerName then
			local player = game.players[playerName]
			teleportPlayer(player, surfaceName)
			player.force.chart(surfaceName, {{-200, -200}, {200, 200}})
			player.character.active = true
		end
	end
	destroyStartButton()
	startRound()
end