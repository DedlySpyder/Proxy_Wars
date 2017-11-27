--~~~~~~~~~~ Event Utils ~~~~~~~~~~--

--[[
This Utils will accept the name of a gui element and a function to use when the event for clicking that element is thrown

The function will be given the event from Factorio
]]--

Utils.Events = {}
Utils.Events.GUI = {}
Utils.Events.GUI.Init = function()
	global.UtilsGuiEvents = global.UtilsGuiEvents or {} --[name] = callback_function
	global.UtilsGuiEventsPartial = global.UtilsGuiEventsPartial or {} --[partial_name] = callback_function
end

Utils.Events.GUI.OnGuiClicked = function(event)
	local element = event.element
	
	for name, func in pairs(global.UtilsGuiEvents) do
		if name == element.name then
			Debug.info("Mod button "..name.." pressed by "..game.players[event.player_index].name)
			global.UtilsGuiEvents[name](event)
			return
		end
	end
	
	for name, func in pairs(global.UtilsGuiEventsPartial) do
		if string.find(element.name, name) then
			Debug.info("Mod button "..name.." pressed by "..game.players[event.player_index].name)
			global.UtilsGuiEventsPartial[name](event)
		end
	end
end

--Add a new GUI clicked event to the GUI event (will not overwrite unless the 3rd parameter is used)
-- @param name name of the element
-- @param func function to be called for it
-- @param force boolean to force add the func even if it already exists
Utils.Events.GUI.Add = function(name, func, force)
	if force or not global.UtilsGuiEvents[name] then
		Debug.info("Registering event for "..name)
		global.UtilsGuiEvents[name] = func
	end
end

--Add a new GUI clicked event to the GUI event (will not overwrite unless the 3rd parameter is used)
--This function will match successfully if the name given is within the name of the gui element, not an exact match
-- @param name partial name of the element
-- @param func function to be called for it
-- @param force boolean to force add the func even if it already exists
Utils.Events.GUI.AddPartial = function(name, func, force)
	if force or not global.UtilsGuiEventsPartial[name] then
		Debug.info("Registering partial event for "..name)
		global.UtilsGuiEventsPartial[name] = func
	end
end

--Remove a GUI clicked event from the GUI event
-- @param name name of the element
Utils.Events.GUI.Remove = function(name)
	local test = function(k) return name ~= k end
	global.UtilsGuiEvents = Utils.Table.Filter.ByKey(global.UtilsGuiEvents, test)
end

--Remove a partial name GUI clicked event from the GUI event
-- @param name name of the element
Utils.Events.GUI.RemovePartial = function(name)
	local test = function(k) return name ~= k end
	global.UtilsGuiEventsPartial = Utils.Table.Filter.ByKey(global.UtilsGuiEventsPartial, test)
end