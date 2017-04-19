--[[
require "config"
biter_levels = 100

--Not efficient enough, long load times
for name, prototype in pairs(data.raw.unit) do
	if not string.find(name, "_pw_") then
		for i=1, biter_levels do
			log( serpent.block( name, {comment = false, numformat = '%1.8g' } ) )
			
			local biter = util.table.deepcopy(prototype)
			local newName = name.."_pw_"..i
			biter.name = newName
			biter.max_health = biter.max_health * i * 0.5
			biter.healing_per_tick = biter.healing_per_tick * i * 0.5
			biter.movement_speed = biter.movement_speed * i * 0.5
			biter.attack_parameters.cooldown = biter.attack_parameters.cooldown * i * 0.5
			
			if string.find(name, "biter") then
				biter.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount = biter.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount * i * 0.5
			else
				biter.attack_parameters.damage_modifier = biter.attack_parameters.damage_modifier * i * 0.5
			end
			
			data:extend ({ biter })
		end
	end
end
]]