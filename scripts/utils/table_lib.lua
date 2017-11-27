Utils.Table = {}
Utils.Table.Filter = {}

--Filter out elements of a table whose key does not pass the given test
-- @param t table to filter
-- @param func function to compare each key to
-- @return filtered table
Utils.Table.Filter.ByKey = function(t, func)
	if not t then return nil end
	local newTable = {}
	
	for key, value in pairs(t) do
		if func(key) then
			newTable[key] = value
		end
	end
	return newTable
end

--Filter out elements of a table whose value does not pass the given test
-- @param t table to filter
-- @param func function to compare each value to
-- @return filtered table
Utils.Table.Filter.ByValue = function(t, func)
	if not t then return nil end
	local newTable = {}
	
	for key, value in pairs(t) do
		if func(value) then
			newTable[key] = value
		end
	end
	return newTable
end

--Filter a number index table based on a given test
--For tables that you would run through ipairs instead of pairs
-- @param t table to filter
-- @param func function to compare each value to
-- @return filtered table
Utils.Table.iFilterByValue = function(t, func)
	if not t then return nil end
	local newTable = {}
	
	for _, value in ipairs(t) do
		if func(value) then
			table.insert(newTable, value)
		end
	end
	return newTable
end

--Taken from base game's utils
Utils.Table.Deepcopy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        -- don't copy factorio rich objects
        elseif object.__self then
          return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end