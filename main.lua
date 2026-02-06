slimeutils = {
	-- Add to this if you want a custom cardarea with upgradable cards
	upgrade_areas = {
		'jokers',
		'consumeables',
		'hand'
	},
	
	-- Functions for drawing large soul sprites
	large_soul = {}
}

-- Draw a soul sprite with different dimensions to the center
function slimeutils.large_soul.draw(card, scale_mod, rotate_mod)
	local spr = card.children.floating_sprite
	if spr.ARGS then
		if spr.ARGS.draw_from_offset then
			spr.ARGS.draw_from_offset.x = spr.role.offset.x or 0
			spr.ARGS.draw_from_offset.y = spr.role.offset.y or 0
		end
		if spr.ARGS.prep_shader then
			spr.ARGS.prep_shader.cursor_pos.x = spr.role.offset.x
			spr.ARGS.prep_shader.cursor_pos.y = spr.role.offset.y
		end
	end
	
	
	
	-- Shadow
	spr:draw_shader(
		'dissolve', 0, nil, nil,
		card.children.center,
		scale_mod, rotate_mod,
		spr.role.offset.x,
		spr.role.offset.y + 0.03*math.sin(1.8*G.TIMERS.REAL),
		nil, 0.6)
	
	-- Not shadow
	spr:draw_shader(
		'dissolve', nil, nil, nil,
		card.children.center,
		scale_mod, rotate_mod,
		spr.role.offset.x or 0,
		spr.role.offset.y or 0)
end

-- Update a soul sprite with different dimensions to the center
-- (Necessary due to cropping if put in the card draw func)
-- Thanks to @thewintercomet for helping with this lol
function slimeutils.large_soul.update(self,card)
	if card.config.center.discovered or card.bypass_discovery_center then
		local spr = card.children.floating_sprite
		local float_atlas = G.ASSET_ATLAS[spr.atlas]
		local center_atlas = G.ASSET_ATLAS[self.atlas]
		spr.atlas = float_atlas
		
		spr:reset()
		
		local x_scale = float_atlas.px / center_atlas.px
		local y_scale = float_atlas.py / center_atlas.py

		spr.scale.x = card.children.center.scale.x*x_scale
		spr.scale.y = card.children.center.scale.y*y_scale

		local x_offset = (x_scale * card.T.w - card.T.w) / 2 * card.VT.scale
		local y_offset = (y_scale * card.T.h - card.T.h) / 2 * card.VT.scale
		spr.offset = {x = -x_offset, y = -y_offset}
		spr.hover_offset = {x = -x_offset, y = -y_offset}
		spr.click_offset = {x = -x_offset, y = -y_offset}
		
		spr:set_role({
			--role_type = 'Minor',
			offset = {x = -x_offset, y = -y_offset},
			--hover_offset = {x = -x_offset, y = -y_offset},
			--click_offset = {x = -x_offset, y = -y_offset},
			major = card,
			draw_major = card,
			--xy_bond = 'Strong',
			--wh_bond = 'Strong',
			--r_bond = 'Strong',
			scale_bond = 'Strong'
		}) 
	end
end


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
			
			return true
	end}))
end

--#region Use Button Functions

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
	
	return t
end

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

	--if card.children.use_button then card.children.use_button:remove(); card.children.use_button = nil end
	--if card.children.sell_button then card.children.sell_button:remove(); card.children.sell_button = nil end
	
    card.config.center.slime_active:calculate(card)
	card.area:remove_from_highlighted(card)
	
	if (card.config.center.slime_active.should_close and not card.config.center.slime_active:should_close(card)) then card.area:add_to_highlighted(card) end
end
--#endregion

--[[	- Use button table format -
	slime_active {
		calculate(self, card)		- Actual active ability
		can_use(self, card)			- Whether you can use the ability
		should_close(self, card)	- Whether to un-highlight the card upon using the ability (Recommended for value changes)
		name(card)					- (Optional) Different button name, instead of localized "Use"
	}
]]

--#region Upgrade Button Functions
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
		card.config.center.slime_upgrade and
		(not card.config.center.slime_upgrade.can_use or card.config.center.slime_upgrade:can_use(card)) and
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
	
	local values = card.config.center.slime_upgrade.values and card.config.center.slime_upgrade:values(card) or {}
	
	card.area:remove_from_highlighted(card)
	
	slimeutils.transform_card(card, card.config.center.slime_upgrade.card, {
		vars = values,
		calculate = card.config.center.slime_upgrade.calculate,
		shake_sound = 'multhit1',
		end_sound = 'timpani',
		shakes = 3
	})
end

function slimeutils.table_create_badge(t)
	t = t or {}
	return create_badge(
		t.text or "Badge",
		t.colour or G.C.UI.TEXT_DARK,
		t.text_colour or G.C.WHITE,
		t.scale or 0.8
	)
end

function slimeutils.get_hand_types(visible)
	local _poker_hands = {}
	for handname, _ in pairs(G.GAME.hands) do
		if SMODS.is_poker_hand_visible(handname) or not visible then
			_poker_hands[#_poker_hands + 1] = handname
		end
	end
	return _poker_hands
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

local highlight_ref = Card.highlight
function Card.highlight(self, is_highlighted)
	local area_check = false
	for i,v in ipairs(slimeutils.upgrade_areas) do
		if self.area == G[v] then area_check = true break end
	end
	
	if is_highlighted and area_check and self.config.center.slime_upgrade then
		self.children.slime_upgrade_button = slimeutils.create_upgrade_button_ui(self)
	elseif self.children.slime_upgrade_button then
		self.children.slime_upgrade_button:remove()
		self.children.slime_upgrade_button = nil
	end

	return highlight_ref(self, is_highlighted)
end
--#endregion

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

local stop_drag_hook = Card.stop_drag
function Card:stop_drag()
	stop_drag_hook(self)
	SMODS.calculate_context {
		slime_stop_drag = true,
		card = self
	}
	-- Update hand when dragging card
	if self.area == G.hand then G.hand:parse_highlighted() end
end