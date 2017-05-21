--This is the minimum time to wait before the host can start the game (seconds) 
--Less than ~20 seconds will mean that the individual surfaces are not fully loaded
wait_before_start = 20

--This is the length between each round of fighting (minutes)
round_length = 10

--The clock will turn yellow below this time (seconds)
round_timer_yellow = 180

--A warning will sound for all players and the clock will go red below this time (seconds)
round_timer_warning = 60

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