Utils = {}

require "table_lib"
require "string_lib"
require "events"
require "tab_lib"

--Convert a position table to a string
-- @param position table
-- @return string position
Utils.PositionToString = function(position)
	if position.x then
		return "("..position.x..","..position.y..")"
	else
		return "("..position[1]..","..position[2]..")"
	end
end

--Round a number to X decimal places
--http://lua-users.org/wiki/SimpleRound
-- @param num number to round
-- @param numDecimalPlaces number of decimal places to round
-- @return rounded number
Utils.RoundToDecimal = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

--Send a message to all players
-- @param message string to send to players
Utils.MessageAll = function(message)
	for _, player in pairs(game.players) do
		player.print(message)
	end
end

--Sound the klaxon near one player
--Works for all players if one is not supplied
-- @param player obj
Utils.SoundKlaxon = function(player)
	if not player then
		Debug.info("Sounding klaxon for all players")
		for _, p in pairs(game.players) do
			Utils.SoundKlaxon(p)
		end
		return nil
	end
	
	player.surface.create_entity({name="Proxy_Wars_klaxon", position=player.position})
end
