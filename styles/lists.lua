data:extend(
{
  {
    type = "font",
    name = "Proxy_Wars_title",
    from = "default",
    size = 28
  },
  {
    type = "font",
    name = "Proxy_Wars_header",
    from = "default",
    size = 20
  },
  {
    type = "font",
    name = "Proxy_Wars_entry",
    from = "default",
    size = 16
  }
})

--~~~~~ General ~~~~~--
data.raw["gui-style"].default["Proxy_Wars_lists_title"] =
{
	type = "label_style",
	font = "Proxy_Wars_title"
}

data.raw["gui-style"].default["Proxy_Wars_lists_separator"] =
{
	type = "label_style",
	font = "Proxy_Wars_header"
}

--~~~~~ Footer ~~~~~--
data.raw["gui-style"].default["Proxy_Wars_lists_close"] =
{
	type = "button_style",
	font = "Proxy_Wars_header"
}