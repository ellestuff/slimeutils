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
                {n=G.UIT.C, config={ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, minh = card.config.center.slime_active.h and (card.config.center.slime_active.h*0.6) or 0.6, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'slime_active_ability', func = 'slime_can_use_active'}, nodes={
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