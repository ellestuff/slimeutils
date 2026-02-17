-- This shit does NOT work, sorry

-- Draw a soul sprite with different dimensions to the center
function slimeutils.large_soul.draw(card, scale_mod, rotate_mod)
	local spr = card.children.floating_sprite
	--print(spr.ARGS)
	--[[
		INFO - [G] Table:
			prep_shader: Table:
			cursor_pos: Table:
				1: 1350.3778456189
				2: 204.81240062842
				y: -1.0186217708249
				x: -1.3441345763848


			draw_from_offset: Table:
			y: -1.0186217708249
			x: -1.3441345763848
	]]

	if spr.ARGS then
		if spr.ARGS.draw_from_offset then
			spr.ARGS.draw_from_offset.x = spr.role.offset.x or 0
			spr.ARGS.draw_from_offset.y = spr.role.offset.y or 0
		end
		if spr.ARGS.prep_shader then
			spr.ARGS.prep_shader.cursor_pos.x = spr.role.offset.x
			spr.ARGS.prep_shader.cursor_pos.y = spr.role.offset.y
			spr.ARGS.prep_shader.cursor_pos[1] = 0
			spr.ARGS.prep_shader.cursor_pos[2] = 0

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
		local float_atlas = G.ASSET_ATLAS[spr.atlas.key]
		local center_atlas = G.ASSET_ATLAS[self.atlas]

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