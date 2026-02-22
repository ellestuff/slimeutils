slimeutils = {
	-- Add to this if you want a custom cardarea with upgradable cards
	upgrade_areas = {
		'jokers',
		'consumeables',
		'hand'
	},
	is_transforming = false,
	
	-- Functions for drawing large soul sprites
	large_soul = {}
}

--		[[ File List ]]
local files = {
	--"soul", -- this shit will need soooooo much reworking to get set up properly T~T
	"upgrades",
	"use",
	"misc",
	"config"
}

for i, v in ipairs(files) do
	assert(SMODS.load_file("lua/"..v..".lua"))()
end

--[[	- Use button table format -
	slime_active {
		calculate(self, card)		- Actual active ability
		can_use(self, card)			- Whether you can use the ability
		should_close(self, card)	- Whether to un-highlight the card upon using the ability (Recommended for value changes)
		name(card)					- (Optional) Different button name, instead of localized "Use"
	}
]]

--[[	- Upgrade button table format -
	slime_upgrade {
		card				- key of card it turns into
		values(self, card)	- values to carry over
			return{
				<target_value> = value,
				<target_value> = value
			}
			
			eg:
			xmult = 1 + card.ability.extra.mult * 0.1
		}
		calculate(self, card)	- What to do when upgrading, usually to fulfil the upgrade conditions
		can_use(self, card)	- Whether you can upgrade the card
	}
]]

