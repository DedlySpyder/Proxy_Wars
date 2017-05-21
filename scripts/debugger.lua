--Debug Functions

--Setup: Require this file

--Setup (Log):	Call Debug.init_log() in you on_init event handler
--				Call Debug.init_log(player_index) in your on_player_joined_game event handler (for any tick besides tick 0)
--					**Note: this will clear that players log each time they connect, or create a new game
--					This odd way to do it is only needed if you will have logs on tick 0, otherwise, catching all players as they join will be enough
--				Change Debug.log_name below to your mod name

--Use:	Call Debug.console() to write to the console
--		Call Debug.info(), .warn(), or .error() to write to the log file with the current tick number
--		Use the below flags to turn this on or off (so that player's are not spammed) (NOTE: For .console() only)
--		log_level should be set by a global setting that can only be "None", "Error", "Warn", or "Info"

--Created by DedlySpyder

debugger_levels = {
	None = 0,
	Error = 1,
	Warn = 2,
	Info = 3
}

Debug = {}

--Flags to write logs or to the console
Debug.console_write_flag = true
Debug.special_log = special_debug
Debug.log_level = debugger_levels[settings.global["Proxy_Wars_log_level"].value]

Debug.log_name = "proxy_wars.log"

--Send messages to the players
-- @param message - message to be written to the players
function Debug.console(message)
	if Debug.console_write_flag then
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
end

--~~Info Level~~--

--Writes to the file [Debug.log_name].log in [factorio folder]/script-output with the current tick and [INFO] prepended to the message
-- @param message - message to be logged
function Debug.info(message)
	if Debug.log_level >= debugger_levels.Info then
		if message then
			Debug.log("[INFO]"..message)
		end
	end
end

--~~Warn Level~~--

--Writes to the file [Debug.log_name].log in [factorio folder]/script-output with the current tick and [WARN] prepended to the message
-- @param message - message to be logged
function Debug.warn(message)
	if Debug.log_level >= debugger_levels.Warn then
		if message then
			Debug.log("[WARN]"..message)
		end
	end
end

--~~Error Level~~--

--Writes to the file [Debug.log_name].log in [factorio folder]/script-output with the current tick and [ERROR] prepended to the message
-- @param message - message to be logged
function Debug.error(message)
	if Debug.log_level >= debugger_levels.Error then
		if message then
			Debug.log("[ERROR]"..message)
		end
	end
end



--~~Internal Use~~--

--Supposed to be for internal use only, use .info(), .warn(), or .error()
-- @param message - message to be logged
function Debug.log(message)
	message = "["..game.tick.."]"..message.."\n"
	game.write_file(Debug.log_name, message, true)
end

--Writes to the file [Debug.log_name] in [factorio folder]/script-output without the current tick
-- @param message - message to be logged
function Debug.log_no_tick(message, player_index)
	if Debug.log_level > debugger_levels.None then
		if message then
			if player_index then
				game.write_file(Debug.log_name, message.."\n", true, player_index)
			else
				game.write_file(Debug.log_name, message.."\n", true)
			end
		end
	end
end

--Writes a table's key-value pairs the file [Debug.log_name] in [factorio folder]/script-output without the current tick
-- @param t - table of data
function Debug.log_table(t)
	if Debug.log_level > debugger_levels.None then
		if t then
			game.write_file(Debug.log_name, serpent.block(t, {comment = false}).."\n", true)
		end
	end
end

--Writes to the file [Debug.log_name] in [factorio folder]/script-output with the current tick prepended to the message
--Only used for special occasions
-- @param message - message to be logged
function Debug.special(message)
	if Debug.special_log then
		if message then
			game.write_file(Debug.log_name, message.."\n", true)
		end
	end
end

--Writes a table's key-value pairs the file [Debug.log_name] in [factorio folder]/script-output without the current tick
--Only used for special occasions
-- @param t - table of data
function Debug.special_table(t)
	if Debug.special_log then
		if t then
			game.write_file(Debug.log_name, serpent.block(t, {comment = false}).."\n", true)
		end
	end
end

function Debug.init_log(player_index)
	if player_index then
		game.write_file(Debug.log_name, "", false, player_index)
	else
		game.write_file(Debug.log_name, "")
	end
	Debug.log_no_tick("Mods:", player_index)
	for mod, version in pairs(game.active_mods) do
		Debug.log_no_tick(mod.." - "..version, player_index)
	end
end