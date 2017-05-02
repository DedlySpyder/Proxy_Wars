data:extend(
{
  {
    type = "font",
    name = "font_top_gui",
    from = "default",
    size = 28
  }
})

data.raw["gui-style"].default["Proxy_Wars_main_menu_round_timer"] =
{
	type = "label_style",
	font = "font_top_gui"
}

data.raw["gui-style"].default["Proxy_Wars_players_buttons"] =
{
	type = "button_style",
	parent = "button_style",
	width = 40,
	height = 40,
	top_margin = 100,
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