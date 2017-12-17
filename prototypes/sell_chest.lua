data:extend ({
	{
		type = "recipe",
		name = "sell-chest-proxy-wars",
		enabled = true,
		ingredients =
		{
			{"iron-chest", 1},
			{"electronic-circuit", 4}
		},
		result = "sell-chest-proxy-wars",
		energy_required = 4
	},
	{
		type = "item",
		name = "sell-chest-proxy-wars",
		icon = "__Proxy_Wars__/graphics/sell_chest_icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar"},
		subgroup = "logistic-network",
		order = "b[storage]-c[zsell-chest-proxy-wars]",
		place_result = "sell-chest-proxy-wars",
		stack_size = 50
	}
})

local chest = util.table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])

chest.name = "sell-chest-proxy-wars"
chest.icon = "__Proxy_Wars__/graphics/sell_chest_icon.png"
chest.icon_size = 32
chest.minable = {hardness = 0.2, mining_time = 0.5, result = "sell-chest-proxy-wars"}
chest.picture = {
	filename = "__Proxy_Wars__/graphics/sell_chest.png",
	priority = "extra-high",
	width = 38,
	height = 32,
	shift = {0.09375, 0}
}

data:extend ({ chest })