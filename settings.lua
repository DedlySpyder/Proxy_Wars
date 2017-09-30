data:extend({
	{
		name = "Proxy_Wars_game_speed",
		type = "int-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_game_length",
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 25,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_round_length",
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 10,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_wait_before_start",
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 20,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_round_timer_warning",
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 180,
		minimum_value = 1
	},
	{
		name = "Proxy_Wars_round_timer_alert",
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 60,
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