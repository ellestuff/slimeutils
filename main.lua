-- Improved Card:set_ability() function, also handling values in the new ability
function change_joker_ability(card, joker, vars)
	vars = vars or {}
	if Cryptid ~= nil then card:set_ability(G.P_CENTERS[joker], true, nil)
	else card:set_ability(joker) end
	card:set_cost() -- Update cost
	
	-- Carry over values from old joker if u want
	for i,v in pairs(vars) do
		card.ability.extra[i] = v
	end
	card:set_cost() -- Update cost again bc it misses cards that hook Card:set_cost()
end

-- Like change_joker_ability(), but with more juice :3
function transform_joker(card, joker, vars, calculate)
	-- Flip card
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		func = function()
			card:flip()
			play_sound('card1')
			card:juice_up(.4,0.4)
			return true
	end}))
	
	-- Handle calculate effect *after* flipping card
	if (calculate) then 
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			func = function()
				calculate(card)
				return true
		end}))
	end
	
	-- Give it a few shakes :33
	for i=1,3 do
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 2,
			func = function()
				card:juice_up(.8,0.8)
				play_sound('tarot2')
				return true
		end}))
	end
	
	-- Change joker
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 2,
		func = function()
			change_joker_ability(card, joker, vars)
			
			card:flip()
			play_sound('tarot1')
			card:juice_up(.4,0.4)
			
			return true
	end}))
end

-- Faster animation
function transform_joker(card, joker, t)
	--	t {
	--		vars,
	--		calculate,
	--		end_sound,
	--		shakes
	--	}
	t = t or {}
	
	-- Flip card
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		func = function()
			card:flip()
			play_sound('card1')
			card:juice_up(.4,0.4)
			return true
	end}))
	
	-- Handle calculate effect *after* flipping card
	if (t.calculate) then 
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			func = function()
				t.calculate(card)
				return true
		end}))
	end
	
	-- Give it a few shakes :33
	if t.shakes then
		for i=1,t.shakes do
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 2,
				func = function()
					card:juice_up(.8,0.8)
					play_sound('tarot2')
					return true
			end}))
		end
	end
	
	-- Change joker
	G.E_MANAGER:add_event(Event({
		trigger = "after",
		delay = 2,
		func = function()
			change_joker_ability(card, joker, t.vars)
			
			card:flip()
			if t.end_sound then play_sound(t.end_sound) end
			card:juice_up(.4,0.4)
			
			return true
	end}))
end

-- Use button on jokers, copied and modified from the lobcorp mod
local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = use_and_sell_buttonsref(card)
	
	-- Don't do this shit if you aren't in the joker tray
	if (card.area ~= G.jokers) then return t end
	
	local _nodes = t.nodes[1].nodes
	
	-- Use Button
    if t and t.nodes[1] and card.config.center.slime_active and type(card.config.center.slime_active) == "table" then
        table.insert(_nodes[#_nodes].nodes, 
            {n=G.UIT.C, config={align = "cr"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = 0.6, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'slime_active_ability', func = 'slime_can_use_active'}, nodes={
                    {n=G.UIT.B, config = {w=0.1,h=0.6}},
                    {n=G.UIT.T, config={text = card.config.center.slime_active.name and card.config.center.slime_active:name(card) or localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                }}
            }}
        )
    end
	
	if t and t.nodes[1] and card.config.center.slime_upgrade and type(card.config.center.slime_upgrade) == "table" then
		
		-- Make 3rd node for Upgrade Button
        if (card.config.center.slime_active) then
			table.insert(_nodes,{
				nodes = {},
				n = 4,
				config = {
					align= "cl",
			}})
		end
		
		table.insert(_nodes[#_nodes].nodes, 
            {n=G.UIT.C, config={align = "cr"}, nodes={
                {n=G.UIT.C, config={ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = 0.4, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'slime_active_upgrade', func = 'slime_can_upgrade'}, nodes={
                    {n=G.UIT.B, config = {w=0.1,h=0.4}},
                    {n=G.UIT.T, config={text = "UPGRADE",colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                }}
            }}
        )
    end
	
    return t
end

-- Use Button Functions
--[[	- Use button table format -
	slime_active {
		calculate(self, card)		- Actual active ability
		can_use(self, card)			- Whether you can use the ability
		should_close(self, card)	- Whether to un-highlight the card upon using the ability (Recommended for value changes)
		name(card)					- (Optional) Different button name, instead of localized "Use"
	}
]]
G.FUNCS.slime_can_use_active = function(e)
    local card = e.config.ref_table
    local can_use = 
    not (not skip_check and ((G.play and #G.play.cards > 0) or
    (G.CONTROLLER.locked) or
    (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))) and
    G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and
    card.area == G.jokers and not card.debuff and
	card.config.center.slime_active and
    (not card.config.center.slime_active.can_use or card.config.center.slime_active:can_use(card))
    if can_use then 
        e.config.colour = G.C.RED
        e.config.button = 'slime_active_ability'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.slime_active_ability = function(e, mute, nosave)
    local card = e.config.ref_table

    G.E_MANAGER:add_event(Event({func = function()
        e.disable_button = nil
        e.config.button = 'slime_active_ability'
    return true end }))

	if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
	if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
	
    card.config.center.slime_active:calculate(card)
	card.area:remove_from_highlighted(card)
	
	if (card.config.center.slime_active.should_close and not card.config.center.slime_active:should_close(card)) then card.area:add_to_highlighted(card) end
end

-- Upgrade Button Functions
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
G.FUNCS.slime_can_upgrade = function(e)
    local card = e.config.ref_table
    local can_use = 
    not (not skip_check and ((G.play and #G.play.cards > 0) or
    (G.CONTROLLER.locked) or
    (G.GAME.STOP_USE and G.GAME.STOP_USE > 0))) and
    G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT and
    card.area == G.jokers and not card.debuff and
	card.config.center.slime_upgrade and
    (not card.config.center.slime_upgrade.can_use or card.config.center.slime_upgrade:can_use(card)) and
	card.config.center.unlocked
    if can_use then 
        e.config.colour = HEX("ff53a9")
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

	if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
	if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
	
	local values = card.config.center.slime_upgrade.values and card.config.center.slime_upgrade:values(card) or {}
	
	card.area:remove_from_highlighted(card)
	
	transform_joker(card, card.config.center.slime_upgrade.card, {
		vars = values,
		calculate = card.config.center.slime_upgrade.calculate,
		end_sound = 'tarot1',
		shakes = 3
	})
end

function table_create_badge(t)
	return create_badge(
		t.text or "Badge",
		t.colour or G.C.UI.TEXT_DARK,
		t.text_colour or G.C.WHITE,
		t.scale or 0.8
	)
end

function get_hand_types(visible)
	local _poker_hands = {}
	for handname, _ in pairs(G.GAME.hands) do
		if SMODS.is_poker_hand_visible(handname) or not visible then
			_poker_hands[#_poker_hands + 1] = handname
		end
	end
	return _poker_hands
end