Utils.String = {}

--Formats the number to have commas when necessary
--Formatting taken from http://lua-users.org/wiki/FormattingNumbers
-- @param num number to format
-- @return formatted number
Utils.String.FormatNumber = function(num)
	if num then
		local flag = 1
		while flag ~= 0 do
			num, flag = string.gsub(num, "^(-?%d+)(%d%d%d)", '%1,%2')
		end
	end
	return num
end

--Format the given string as MM:SS
-- #param num number to format
-- @return formatted time as a string
Utils.String.FormatTime = function(num)
	local mins = math.floor(num/60)
	local secs = (num % 60)
	if mins < 10 then 
		mins = "0"..mins
	end
	if secs < 10 then
		secs = "0"..secs
	end
	return mins..":"..secs
end