--~~~~~ Header ~~~~~--
data.raw["gui-style"].default["Proxy_Wars_buy_biters_header_biter"] =
{
	type = "label_style",
	font = "Proxy_Wars_header"
}

data.raw["gui-style"].default["Proxy_Wars_buy_biters_header_current"] =
{
	type = "label_style",
	font = "Proxy_Wars_header"
}

data.raw["gui-style"].default["Proxy_Wars_buy_biters_header_cost"] =
{
	type = "label_style",
	font = "Proxy_Wars_header",
	right_padding = 20
}

--~~~~~ General ~~~~~--
data.raw["gui-style"].default["Proxy_Wars_buy_biters_entry_biter"] =
{
	type = "button_style",
	parent = "button_style",
	width = 40,
	height = 40,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	left_click_sound =
	{
		{
			filename = "__core__/sound/gui-click.ogg",
			volume = 1
		}
	}
}

data.raw["gui-style"].default["Proxy_Wars_buy_biters_entry_current"] =
{
	type = "label_style",
	font = "Proxy_Wars_entry",
	top_padding = 6,
	minimal_width = 135,
	maximal_width = 135
}

data.raw["gui-style"].default["Proxy_Wars_buy_biters_entry_cost"] =
{
	type = "label_style",
	font = "Proxy_Wars_entry",
	top_padding = 6
}

--~~~~~ Footer ~~~~~--
data.raw["gui-style"].default["Proxy_Wars_buy_biters_current_money"] =
{
	type = "label_style",
	font = "Proxy_Wars_entry",
	top_padding = 13,
	minimal_width = 250
}