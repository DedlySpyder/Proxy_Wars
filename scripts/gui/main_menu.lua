require "buy_biters"
require "help"
require "scoreboard"
require "value_list"

GUI.MainMenu = {}

--PlayerTabData["player"] must be set before use
GUI.MainMenu.PayerTabData = {
	name = "Proxy_Wars_Main_Menu",
	navButtons = 
	{
		{
			name = GUI.Help.TAB_NAME,
			caption = "Help"
		},
		{
			name = GUI.Scoreboard.TAB_NAME,
			caption = "Scoreboard"
		},
		{
			name = GUI.ValueList.TAB_NAME,
			caption = "Value List"
		},
		{
			name = GUI.BuyBiters.TAB_NAME,
			caption = "Buy Biters"
		}
	},
	tabs = 
	{
		help = GUI.Help.Tab,
		scoreboard = GUI.Scoreboard.Tab,
		value_list = GUI.ValueList.Tab,
		buy_biters = GUI.BuyBiters.Tab
	}
}
--[[
--SpectatorTabData["player"] must be set before use
GUI.MainMenu.SpectatorTabData = {
	name = "Proxy_Wars_Main_Menu",
	navButtons = 
	{
		{
			name = GUI.Help.TAB_NAME,
			caption = "Help"
		},
		{
			name = GUI.Scoreboard.TAB_NAME,
			caption = "Scoreboard"
		},
		{
			name = GUI.ValueList.TAB_NAME,
			caption = "Value List"
		}
	},
	tabs = 
	{
		help = GUI.Help.Tab,
		scoreboard = GUI.Scoreboard.Tab,
		value_list = GUI.ValueList.Tab,
		buy_biters = GUI.BuyBiters.Tab
	}
}
]]--

-- TODO - QUESTION? - Would this cause a desync OR do the player's share this one table and stuff processes asynchronously??
--					I don't think I can return a new copy of this table without having serialization issues? Unless I do some other trickery on a reload?
GUI.MainMenu.GetTabData = function(player)
	--TODO - SPECTATORS - this will need to decided which data to send when/if spectators are implemented
	data = Utils.Table.Deepcopy(GUI.MainMenu.PayerTabData)
	data["player"] = player
	return data
end
