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

-- Character Icons, based off @vman_2002's code
local cardpopup_ref = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local ret_val = cardpopup_ref(card)
    local obj = card.config.center
    if obj then
		if (obj.slime_desc_icon) then
			local s = obj.slime_desc_icon.scale or 1
			local obj = Sprite(0,0,s,s,G.ASSET_ATLAS[obj.slime_desc_icon.atlas], obj.slime_desc_icon.pos)
			obj.states.drag.can = false
			obj.config.no_fill = true
			obj:juice_up(0.2)
		
			local tag = {
				n = G.UIT.R,
				config = { align = 'br', padding = s*-0.5, no_fill = true },
				nodes = {
					{
						n = G.UIT.O,
						config = { object = obj }
					}
				}
			}
			
			table.insert(ret_val.nodes[1].nodes[1].nodes[1].nodes, tag)
		end
    end
    return ret_val
end