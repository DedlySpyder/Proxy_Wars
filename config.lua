--TODO - replace this file with a tabbed menu for the host

team_names = {
	"Player_1",
	"Player_2",
	"Player_3",
	"Player_4",
	"Player_5",
	"Player_6",
	"Player_7",
	"Player_8"
}

--This is how much each biter will cost to buy for a fight
biter_costs = {}

biter_costs["small-biter"] = 100
biter_costs["medium-biter"] = 1000
biter_costs["big-biter"] = 10000
biter_costs["behemoth-biter"] = 100000
biter_costs["small-spitter"] = 100
biter_costs["medium-spitter"] = 1000
biter_costs["big-spitter"] = 10000
biter_costs["behemoth-spitter"] = 100000


--Item Values
item_values = {}

--Set item values by copying the following line (without the "--") and 
--filling in the item name in the quotes, and replacing the X with the desired value
--item_values[""] = X

--The below items are required to have values
--Any others added will override the automatic value generation
item_values["iron-ore"] = 1
item_values["copper-ore"] = 1
item_values["stone"] = 1
item_values["coal"] = 2
item_values["water"] = 1
item_values["crude-oil"] = 2
item_values["raw-fish"] = 5
item_values["raw-wood"] = 2
item_values["alien-artifact"] = 5

--These will effect the automatic value generation buy multiply these values by the respective value
ingredient_modifier = 1.0
tech_level_modifier = 1.0 --Not currently in use
energy_modifier = 1.0
overall_modifier = 1.0

--This allows commands for debugging the game
debug_mode = false

special_debug = false