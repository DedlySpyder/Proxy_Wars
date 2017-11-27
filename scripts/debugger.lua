--Debug Functions

--Setup: Require this file

--Setup (Log):	Call Debug.setDebugLevel(event) in your on_runtime_mod_setting_changed, where event is the event given to the handler
--				Call Debug.init_log() in you on_init event handler
--				Call Debug.init_log(player_index) in your on_player_joined_game event handler (for any tick besides tick 0)
--					**Note: this will clear that players log each time they connect, or create a new game
--					This odd way to do it is only needed if you will have logs on tick 0, otherwise, catching all players as they join will be enough
--				Change Debug.LOG_SETTING_NAME below to the name of your setting for log levels
--				Change Debug.LOG_NAME below to your mod name

--Use:	Call Debug.console() to write to the console
--		Call Debug.info(), .warn(), or .error() to write to the log file with the current tick number
--		Use the below flags to turn this on or off (so that player's are not spammed) (NOTE: For .console() only)
--		log_level should be set by a global setting that can only be "None", "Error", "Warn", or "Info"

-- Created by DedlySpyder
-- Version: 0.0.3

Debug = {}

Debug.DEBUGGER_LEVELS = {
	None = 0,
	Error = 1,
	Warn = 2,
	Info = 3
}

--Flags to write logs or to the console
Debug.CONSOLE_WRITE_FLAG = true
Debug.SPECIAL_LOG = special_debug

Debug.LOG_SETTING_NAME = "Proxy_Wars_log_level"
Debug.LOG_NAME = "proxy_wars.log"

Debug.LOG_LEVEL = Debug.DEBUGGER_LEVELS[settings.global[Debug.LOG_SETTING_NAME].value]

--Send messages to the players
-- @param message - message to be written to the players
function Debug.console(message)
	if Debug.CONSOLE_WRITE_FLAG then
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
end

--~~Info Level~~--

--Writes to the file [Debug.LOG_NAME].log in [factorio folder]/script-output with the current tick and [INFO] prepended to the message
-- @param message - message to be logged
function Debug.info(message)
	if Debug.LOG_LEVEL >= Debug.DEBUGGER_LEVELS.Info then
		if message then
			Debug.log("[INFO]"..message)
		end
	end
end

--~~Warn Level~~--

--Writes to the file [Debug.LOG_NAME].log in [factorio folder]/script-output with the current tick and [WARN] prepended to the message
-- @param message - message to be logged
function Debug.warn(message)
	if Debug.LOG_LEVEL >= Debug.DEBUGGER_LEVELS.Warn then
		if message then
			Debug.log("[WARN]"..message)
		end
	end
end

--~~Error Level~~--

--Writes to the file [Debug.LOG_NAME].log in [factorio folder]/script-output with the current tick and [ERROR] prepended to the message
-- @param message - message to be logged
function Debug.error(message)
	if Debug.LOG_LEVEL >= Debug.DEBUGGER_LEVELS.Error then
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
	game.write_file(Debug.LOG_NAME, message, true)
end

--Writes to the file [Debug.LOG_NAME] in [factorio folder]/script-output without the current tick
-- @param message - message to be logged
function Debug.log_no_tick(message, player_index)
	if Debug.LOG_LEVEL > Debug.DEBUGGER_LEVELS.None then
		if message then
			if player_index then
				game.write_file(Debug.LOG_NAME, message.."\n", true, player_index)
			else
				game.write_file(Debug.LOG_NAME, message.."\n", true)
			end
		end
	end
end

--Writes a table's key-value pairs the file [Debug.LOG_NAME] in [factorio folder]/script-output without the current tick
-- @param t - table of data
function Debug.log_table(t)
	if Debug.LOG_LEVEL > Debug.DEBUGGER_LEVELS.None then
		if t then
			game.write_file(Debug.LOG_NAME, serpent.block(t, {comment = false}).."\n", true)
		end
	end
end

--Writes to the file [Debug.LOG_NAME] in [factorio folder]/script-output with the current tick prepended to the message
--Only used for special occasions
-- @param message - message to be logged
function Debug.special(message)
	if Debug.SPECIAL_LOG then
		if message then
			game.write_file(Debug.LOG_NAME, message.."\n", true)
		end
	end
end

--Writes a table's key-value pairs the file [Debug.LOG_NAME] in [factorio folder]/script-output without the current tick
--Only used for special occasions
-- @param t - table of data
function Debug.special_table(t)
	if Debug.SPECIAL_LOG then
		if t then
			game.write_file(Debug.LOG_NAME, serpent.block(t, {comment = false}).."\n", true)
		end
	end
end

--Handler for initializing the log either for a player or for the headless server
-- @param player_index
function Debug.init_log(player_index)
	if player_index then
		game.write_file(Debug.LOG_NAME, "", false, player_index)
	else
		game.write_file(Debug.LOG_NAME, "")
	end
	Debug.log_no_tick("Mods:", player_index)
	for mod, version in pairs(game.active_mods) do
		Debug.log_no_tick(mod.." - "..version, player_index)
	end
end

--Handler for changing the debug levels
-- @param event - event obj given to the original handler
function Debug.setDebugLevel(event)
	local setting = event.setting
	
	if setting == Debug.LOG_SETTING_NAME then
		Debug.LOG_LEVEL = Debug.DEBUGGER_LEVELS[settings.global[Debug.LOG_SETTING_NAME].value]
	end
end