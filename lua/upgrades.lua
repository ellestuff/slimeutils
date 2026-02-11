-- Improved Card:set_ability() function, also handling values in the new ability
function slimeutils.change_ability(card, key, vars)
	vars = vars or {}
	if Cryptid ~= nil then card:set_ability(G.P_CENTERS[key], true, nil)
	else card:set_ability(key) end
	card:set_cost() -- Update cost
	
	-- Carry over values from old joker if u want
	for i,v in pairs(vars) do
		card.ability.extra[i] = v
	end
	card:set_cost() -- Update cost again bc it misses cards that hook Card:set_cost()
end

-- Like change_joker_ability(), but with more juice :3
function slimeutils.transform_card(card, key, t)
	--	t {
	--		vars,
	--		calculate,
	--		end_sound,
	--		shake_sound,
	--		shakes,
	--		instant
	--	}
	t = t or {}
	slimeutils.is_transforming = true
	if (not t.instant) then
		-- Flip card
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			func = function()
				card:flip()
				play_sound('card1')
				card:juice_up(.4,0.4)
				return true
		end}))
		
		
		-- Give it a few shakes :33
		if t.shakes then
			for i=1,t.shakes do
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 2,
					func = function()
						card:juice_up(.8,0.8)
						play_sound(t.shake_sound or 'tarot2')
						return true
				end}))
			end
		end
	end
	
	-- Change joker
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 2,
		func = function()
			-- Handle calculate effect *after* flipping card
			if (t.calculate) then 
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					func = function()
						t.calculate(card)
						return true
				end}))
			end
			
			slimeutils.change_ability(card, key, t.vars)
			
			if (not t.instant) then card:flip() end
			if t.end_sound then play_sound(t.end_sound) end
			card:juice_up(.4,0.4)

			slimeutils.is_transforming = false
			return true
	end}))
end

function slimeutils.create_upgrade_button_ui(card)
	return UIBox {
		definition = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR },
			nodes = {{
				n = G.UIT.C,
				config = {
					align = 'cm',
					padding = 0.15,
					r = 0.08,
					hover = true,
					shadow = true,
					button = 'slime_active_upgrade',
					func = 'slime_can_upgrade',
					ref_table = card,
				},
				nodes = {{
					n = G.UIT.R,
					nodes = {{
						n = G.UIT.T,
						config = {
							text = localize("slime_upgrade"),
							scale = 0.25,
						}
					}}
				}}
			}}
		},
		config = {
			align = 'bm', -- position relative to the card, meaning "center left". Follow the SMODS UI guide for more alignment options
			major = card,
			parent = card,
			offset = { x = 0, y = -0.05 } -- depends on the alignment you want, without an offset the button will look as if floating next to the card, instead of behind it
		}
	}
end

G.FUNCS.slime_can_upgrade = function(e)
	local card = e.config.ref_table
	local can_use = 
		not (not skip_check and ((G.play and #G.play.cards > 0) or
		(G.CONTROLLER.locked) or
		(G.GAME.STOP_USE and G.GAME.STOP_USE > 0))) and
		G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and
		not card.debuff and
		slimeutils.card_get_upgrade(card) and
		slimeutils.can_upgrade_card(card) and
		not (#G.E_MANAGER.queues.base > 1) and
		card.config.center.unlocked
	
	if can_use then 
		e.config.colour = G.C.BLUE
		e.config.button = 'slime_active_upgrade'
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

G.FUNCS.slime_active_upgrade = function(e, mute, nosave)
    local card = e.config.ref_table

    G.E_MANAGER:add_event(Event({func = function()
        e.disable_button = nil
        e.config.button = 'slime_active_upgrade'
    return true end }))

	--if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
	--if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
	
	local upgrade = slimeutils.card_get_upgrade(card)

	local values = upgrade.values and upgrade:values(card) or {}

	card.area:remove_from_highlighted(card)
	
	slimeutils.transform_card(card, upgrade.card, {
		vars = values,
		calculate = upgrade.calculate,
		shake_sound = 'multhit1',
		end_sound = 'timpani',
		shakes = 3
	})

	SMODS.calculate_context {
		slime_upgrade = true,
		card = card
	}
end

SMODS.DrawStep {
	key = 'upgrade_button',
	order = -30, -- before the Card is drawn
	func = function(card, layer)
		if card.children.slime_upgrade_button then
			card.children.slime_upgrade_button:draw()
		end
	end
}

function slimeutils.card_get_upgrade(card)
	return card.config.center and card.config.center.slime_upgrade
end

function slimeutils.can_upgrade_card(card)
	local upgr = slimeutils.card_get_upgrade(card)
	if not upgr then return false end

	return not upgr.can_use or upgr:can_use(card)
end

local highlight_ref = Card.highlight
function Card.highlight(self, is_highlighted)
	local area_check = false
	for i,v in ipairs(slimeutils.upgrade_areas) do
		if self.area == G[v] then area_check = true break end
	end
	
	if is_highlighted and area_check and slimeutils.card_get_upgrade(self) then
		self.children.slime_upgrade_button = slimeutils.create_upgrade_button_ui(self)
	elseif self.children.slime_upgrade_button then
		self.children.slime_upgrade_button:remove()
		self.children.slime_upgrade_button = nil
	end

	return highlight_ref(self, is_highlighted)
end