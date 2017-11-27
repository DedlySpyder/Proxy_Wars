--TODO - tweak these

data:extend(
{
  {
    type = "font",
    name = "Proxy_Wars_tab_nav",
    from = "default",
    size = 20
  }
})

data.raw["gui-style"].default["Proxy_Wars_tab_nav_active"] = 
{
	type = "label_style",
	font = "Proxy_Wars_tab_nav",
	height = 35,
	top_padding = 0,
	left_padding = 6,
	right_padding = 5
}

data.raw["gui-style"].default["Proxy_Wars_tab_nav_inactive"] = 
{
	type = "button_style",
	height = 35,
	top_padding = 0
}
