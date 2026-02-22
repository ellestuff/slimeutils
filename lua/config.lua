-- add mod description page
SMODS.current_mod.custom_ui = function(mod_nodes)
	mod_nodes = EMPTY(mod_nodes)
	
	mod_nodes[#mod_nodes+1] = {n = G.UIT.C, config = {padding = 0.1}, nodes = {
		{n = G.UIT.R,
			config = {
				align = "cm"
			}, nodes = {
				{n = G.UIT.R,
					config = {
						r = 0.1,
						align = "cm",
						padding = 0.1,
						colour = G.C.BLUE,
					}, nodes = {
						{n = G.UIT.C,
							config = {
								r = 0.1,
								align = "cm",
								padding = 0.2,
								colour = G.C.BLACK
							}, nodes = {
								{n = G.UIT.T, config = {text = "slimeutils.", scale = .75, colour = G.C.WHITE}}
						}}
				}}
		}},
		{n = G.UIT.R, config = {align = "tm"}, nodes = {
			{n = G.UIT.T, config = {text = "Upgrades and shit", scale = .3, colour = G.C.WHITE}},
			{n = G.UIT.T, config = {text = "TM", scale = .15, colour = G.C.WHITE}}
		}},
		{n = G.UIT.R, config = {align = "cm", padding = 0.2}, nodes = {
			{n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.R,
					config = {
						emboss = 0.05,
						r = 0.1,
						minw = 6,
						minh = 2,
						align = "cm",
						padding = 0.1,
						colour = G.C.L_BLACK
					}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.T, config = {text = "This mod adds ", scale = .4, colour = G.C.WHITE}},
							{n = G.UIT.T, config = {text = "Upgrades", scale = .4, colour = G.C.FILTER}},
							{n = G.UIT.T, config = {text = " to", scale = .4, colour = G.C.WHITE}}
						}},
						{n = G.UIT.R, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = "the game, for use by other", scale = .4, colour = G.C.WHITE}}}},
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.T, config = {text = "mods such as ", scale = .4, colour = G.C.WHITE}},
							{n = G.UIT.T, config = {text = "ellejokers.", scale = .4, colour = HEX("ff53a9")}}
						}},
				}}
			}},
			{n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.R,
					config = {
						emboss = 0.05,
						r = 0.1,
						minw = 6,
						minh = 2,
						align = "cm",
						padding = 0.1,
						colour = G.C.L_BLACK
					}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {text = "Icons can also be added to", scale = .4, colour = G.C.WHITE}}}},
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.T, config = {text = "the corner of ", scale = .4, colour = G.C.WHITE}},
							{n = G.UIT.T, config = {text = "Joker Descriptions", scale = .4, colour = G.C.FILTER}}
					}},
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.T, config = {text = "Based off code by ", scale = .3, colour = G.C.WHITE}},
							{n = G.UIT.T, config = {text = "VMan2002", scale = .3, colour = G.C.FILTER}}
						}},
				}}
			}}
		}}
	}}
end