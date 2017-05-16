--Debug Functions

--Setup: Require this file

--Setup (Log):	Call Debug.log_on_init() in your script.on_init
--				Change Debug.log_name below to your mod name

--Use:	Call Debug.console to write to the console
--		Call Debug.log to write to the log file with the current tick number
--		Use the below flags to turn this on or off (so that player's are not spammed)

--Created by DedlySpyder

Debug = {}

--Flags to write logs or to the console
Debug.console_write_flag = true
Debug.log_write_flag = true
Debug.special_log = special_debug

Debug.log_name = "proxy_wars"

--Send messages to the players
-- @param message - message to be written to the players
function Debug.console(message)
	if Debug.console_write_flag then
		for _, player in pairs(game.players) do
			player.print(message)
		end
	end
end

--Writes to the file [Debug.log_name].log in [factorio folder]/script-output with the current tick prepended to the message
-- @param message - message to be logged
function Debug.log(message)
	if Debug.log_write_flag then
		message = "["..game.tick.."]"..message.."\n"
		game.write_file(Debug.log_name..".log", message, true)
	end
end

--Writes to the file [Debug.log_name].log in [factorio folder]/script-output without the current tick
-- @param message - message to be logged
function Debug.log_no_tick(message)
	if Debug.log_write_flag then
		game.write_file(Debug.log_name..".log", message.."\n", true)
	end
end

--Writes a table's key-value pairs the file [Debug.log_name].log in [factorio folder]/script-output without the current tick
-- @param t - table of data
function Debug.log_table(t)
	if Debug.log_write_flag then
		game.write_file(Debug.log_name..".log", serpent.block(t, {comment = false}).."\n", true)
	end
end

function Debug.special(message)
	if Debug.special_log then
		game.write_file(Debug.log_name..".log", message.."\n", true)
	end
end

function Debug.special_table(t)
	if Debug.special_log then
		game.write_file(Debug.log_name..".log", serpent.block(t, {comment = false}).."\n", true)
	end
end

function Debug.log_on_init(data)
	if Debug.log_write_flag then
		game.write_file(Debug.log_name..".log", "")
		Debug.log_no_tick("Mods:")
		for mod, version in pairs(game.active_mods) do
			Debug.log_no_tick(mod.." - "..version)
		end
	end
end