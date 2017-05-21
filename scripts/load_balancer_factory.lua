--This file contains a factory to create load balancers
--The load balancers will balance the execution of any number of actions over a set span of time (default 60 ticks)
--The use case is if you need to run a large number of commands frequently, but not all at once

--If the action returns a value it will replace the current data

--Setup: Require this file
--		 Call Load_Balancer_Factory.create() in your script.on_init and catch the returned load balancer
--			Provide at least a global table for the balancer to work with (see below for more details)
--		 Call [load balancer]:on_tick() in your on_tick event

--		 NOTE: Debug statement taken from my Debugger and should be replaced or removed if not using it

--Use:	Call [load balancer]:addAction to add an action with it's needed data
--			the action can be named, or it will be named for you, either way a name is returned and should be stored
--		Call [load balancer]:modifyData to change the data by sending the name and a table of data
--		Call [load balancer]:replaceData to replace the data of the action
--		Call [load balancer]:replaceAction to replace the function of an action
--		Call [load balancer]:removeAction with the name of the action to remove it
--		Call [load balancer]:removeAllActions to clear all current actions from the load_balancer

--Created by DedlySpyder

Load_Balancer_Factory = {}

--Default Values
--This will complete the ticks every this many ticks
Load_Balancer_Factory.iteration_length = 60

--Default name when an action name is not supplied
Load_Balancer_Factory.default_name = "Action_"


--This function is called to create a load balancer instance
-- @param globalTable - global table to be used by the load balancer
-- @param iterationLength - length of each run of the load balancer in ticks *optional*
-- @param defaultName - default name for the actions of the load balancer *optional*
-- @return - the load balancer object or nil
function Load_Balancer_Factory.create(balancerName, globalTable, iterationLength, defaultName)
	if globalTable then
		local loadBalancer = {}
		
		loadBalancer.iteration_length = iterationLength or Load_Balancer_Factory.iteration_length
		loadBalancer.default_name = defaultName or Load_Balancer_Factory.default_name
		loadBalancer.global = globalTable
		
		Debug.info("[LB]Creating new load balancer: "..balancerName)
		Debug.info("[LB]New load blanacer iteration_length: "..loadBalancer.iteration_length)
		Debug.info("[LB]New load blanacer default_name: "..loadBalancer.default_name)
		
		--Initialize global variables
		loadBalancer.global.name = balancerName
		loadBalancer.global.actions = loadBalancer.global.actions or {action=nil, data=nil, name=nil}
		loadBalancer.global.actions_per_tick = loadBalancer.global.actions_per_tick or 0
		loadBalancer.global.temp_actions_per_tick = loadBalancer.global.temp_actions_per_tick or 0
		loadBalancer.global.tick_offset = loadBalancer.global.tick_offset or math.random(loadBalancer.iteration_length)
		loadBalancer.global.default_name_increment = loadBalancer.global.default_name_increment or 1
		
		--Called to add an action to be run in the load balancer
		-- @param action - function to be used
		-- @param data - data to be sent to the action
		-- @param name - name of the action *optional*
		-- @return name of the action or nil on error
		function loadBalancer:addAction(action, data, name)
			if action then
				if not data then
					Debug.warn("[LB]["..self.global.name.."]Data was null, continuing to add action.")
				end
				
				--Check if the name is already in use
				if name then
					for _, action in ipairs(self.global.actions) do
						if action.name == name then
							Debug.warn("[LB]["..self.global.name.."]While adding new action, name ("..name..") already in use. Using default naming scheme instead.")
							name = nil
						end
					end
				end
				if not name then
					name = self.default_name..self.global.default_name_increment
					self.global.default_name_increment = self.global.default_name_increment+1
				end
				table.insert(self.global.actions, {action=action, data=data, name=name})
				Debug.info("[LB]["..self.global.name.."]Adding action: "..name)
				self:rebalanceActions()
				return name
			end
			Debug.error("[LB]["..self.global.name.."]Action was null, could not add action.")
			return nil
		end
		
		--Called to modify the data of an existing action in the load balancer and returns the table entry for this action
		--NOTE: just a name can be passed to this and it will return the table entry
		--The data passed is added to the values already there
		-- @param name - name of the action
		-- @param arg - table of the data {}
		-- @return action table entry
		function loadBalancer:modifyData(name, arg)
			Debug.info("[LB]["..self.global.name.."]Modifying data: "..name)
			local index
			for i, action in ipairs(self.global.actions) do
				if action.name == name then index = i end
			end
			local thisAction = self.global.actions[index]
			if arg then
				--Add the data values to the data
				for key, value in pairs(arg) do
					if thisAction.data[key] then
						thisAction.data[key] = thisAction.data[key] + value
					end
				end
			else
				Debug.warn("[LB]["..self.global.name.."]No data found for modify data")
			end
			return thisAction
		end
		
		--Called to replace the data of an existing action in the load balancer
		--NOTE: just a name can be passed to this and it will return the table entry
		-- @param name - name of the action
		-- @param arg - new data to be used
		-- @return action table entry
		function loadBalancer:replaceData(name, arg)
			Debug.info("[LB]["..self.global.name.."]Replacing data: "..name)
			local index
			for i, action in ipairs(self.global.actions) do
				if action.name == name then index = i end
			end
			local thisAction = self.global.actions[index]
			if arg then
				if arg then
					thisAction.data = arg
				end
			else
				Debug.warn("[LB]["..self.global.name.."]No data found for replace data")
			end
			return thisAction
		end
		
		--Called to replace the action (function used) of an existing action in the load balancer
		--NOTE: just a name can be passed to this and it will return the table entry
		-- @param name - name of the action
		-- @param arg - new function to be used
		-- @return action table entry
		function loadBalancer:replaceAction(name, arg)
			Debug.info("[LB]["..self.global.name.."]Replacing action: "..name)
			local index
			for i, action in ipairs(self.global.actions) do
				if action.name == name then index = i end
			end
			local thisAction = self.global.actions[index]
			if arg then
				if arg then
					thisAction.action = arg
				end
			else
				Debug.warn("[LB]["..self.global.name.."]No data found for repalce action")
			end
			return thisAction
		end
		
		--Called to remove an action from the load balancer
		-- @param name - name of the action
		-- @return true/false
		function loadBalancer:removeAction(name)
			if name then
				Debug.info("[LB]["..self.global.name.."]Removing action: "..name)
				local newTable = {}
				local test = function (arg) return arg.name == name end
				for _, row in ipairs(self.global.actions) do
					if not test(row) then table.insert(newTable, row) end
				end
				self.global.actions = newTable
				self:rebalanceActions()
				return true
			end
			Debug.error("[LB]["..self.global.name.."]Cannot remove action, no name provided")
			return false
		end
		
		--Called to remove all actions from the load_balancer
		function loadBalancer:removeAllActions()
			Debug.info("[LB]["..self.global.name.."]Removing all actions")
			self.global.actions = {action=nil, data=nil, name=nil}
			self:rebalanceActions()
		end
		
		-- ~*~ Internal Functions ~*~ --

		--Called to figure out how many actions to complete per tick
		--Does not come into effect until the next iteration
		function loadBalancer:rebalanceActions()
			local count = #self.global.actions
			self.global.temp_actions_per_tick = math.ceil(count/self.iteration_length)
			--Debug.info("[LB]["..self.global.name.."]Rebalancing actions: count:"..count) --DEBUG
		end
		
		function loadBalancer:doAction(tick)
			--The game only increments tick infinitely, so the relative tick must be caculated for the current iteration
			local relativeTick = (tick - (math.floor(tick/self.iteration_length) * self.iteration_length + self.global.tick_offset))+1
			local startTick
			if relativeTick == 1 then
				startTick = 1
			else
				startTick = ((relativeTick-1)*self.global.actions_per_tick)+1
			end
			for i=startTick, startTick+self.global.actions_per_tick-1 do
				if self.global.actions[i] then
					--Debug.info("[LB]["..self.global.name.."]Executing action: "..self.global.actions[i].name) --DEBUG
					local data = self.global.actions[i].action(self.global.actions[i].data)
					if data then
						self.global.actions.data = data
					end
				end
			end
		end
		
		function loadBalancer:on_tick()
			local tick = game.tick
			if tick % self.iteration_length == self.global.tick_offset then
				self.global.actions_per_tick = self.global.temp_actions_per_tick
				--Debug.info("[LB]["..self.global.name.."]Setting new actions per tick: "..self.global.actions_per_tick) --DEBUG
			end
			self:doAction(tick)
		end
		
		return loadBalancer
	end
	
	local errMessage = "[LB]"
	if balancerName then
		errMessage = errMessage.."["..balancerName.."]"
	end
	errMessage = errMessage.."Global table not found"
	Debug.error(errMessage)
	return nil
end
