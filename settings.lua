data:extend({
	{
		name = "Proxy_Wars_game_speed",
		type = "int-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_log_level",
		type = "string-setting",
		setting_type = "runtime-global",
		default_value = "Info",
		allowed_values = {"Info", "Warn", "Error", "None"}
	}
})