slimeutils.microgames = {
	running = false
}

function slimeutils.microgames.enqueue(queue,microgame,t)
	t = t or {}
	queue[#queue+1] = {
		microgame = microgame,
		t = t
	}
end

local stage = 0
local stagetimer = 0
local stageframe = 0

function slimeutils.microgames.draw()
	if not slimeutils.microgames.microgame then return end

	local w,h = love.graphics.getDimensions()
	local mw = (slimeutils.microgames.microgame.width or 320)*2
	local mh = (slimeutils.microgames.microgame.height or 240)*2
	local s = math.min(h/480,w/640,2)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill",0,0,w,h)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(slimeutils.microgames.canvas,w/2,h/2,0,s,s,mw/2,mh/2)
end

function slimeutils.microgames:init(queue,anims)
	if #queue<1 or self.running then return end
	self.running = true
	self.playing = false
	self.microgame = nil
	self.queue = queue
	self.anims = anims or {}

	self.hits = 0

	G.CONTROLLER.locks.slime_microgame = true

	stage = self.anims.start and 0 or 1
	stagetimer = 0
	stageframe = 0
	
	G.E_MANAGER:add_event(Event({func = function()
		return not self.running
	end}))
end

local animslist = {"start","pre_game","play","post_game","finish"}

local function setTimer()
	-- Timer stuff
	slimeutils.microgames.timer = stagetimer

	if stage == 1 then slimeutils.microgames.timer = slimeutils.microgames.timer - (slimeutils.microgames.anims.durations.pre_game or 0)
	elseif stage == 3 then slimeutils.microgames.timer = slimeutils.microgames.timer + (slimeutils.microgames.microgame.duration or 0) end
end

if not love.update then function love.update(dt) end end
local update_hook = love.update
function love.update(dt)
	update_hook(dt)
	if slimeutils.microgames.running then
		-- End of Start Animation
		if stage == 0 and stagetimer >= slimeutils.microgames.anims.durations.start then
			stage = 1
			stagetimer = 0
			stageframe = 0
		
		-- End of Microgame Start Animation
		elseif stage == 1 and (not slimeutils.microgames.anims.pre_game or stagetimer >= slimeutils.microgames.anims.durations.pre_game) then
			stage = 2
			stagetimer = 0
			stageframe = 0
			slimeutils.microgames.playing = true
			if slimeutils.microgames.microgame.start then slimeutils.microgames.microgame.start() end
		-- End of Microgame
		elseif stage == 2 and stagetimer >= slimeutils.microgames.microgame.duration then
			stage = 3
			stagetimer = 0
			stageframe = 0
			slimeutils.microgames.playing = false

		-- End of Microgame Start Animation
		elseif stage == 3 and (not slimeutils.microgames.anims.post_game or stagetimer >= slimeutils.microgames.anims.durations.post_game) then
			-- Run optional End function
			if slimeutils.microgames.queue[1].t.end_func then slimeutils.microgames.queue[1].t.end_func() end
			
			table.remove(slimeutils.microgames.queue,1)

			-- Reset Cycle
			if #slimeutils.microgames.queue>0 then
				stage = 1
			else
				stage = 4
				slimeutils.microgames.microgame = nil
			end

			stagetimer = 0
			stageframe = 0

		-- End of Finish Animation
		elseif stage == 4 and (not slimeutils.microgames.anims.finish or stagetimer >= slimeutils.microgames.anims.durations.finish) then
			slimeutils.microgames.running = false
			G.CONTROLLER.locks.slime_microgame = false
		end

		-- Init microgame
		if stage == 1 and stageframe == 0 then
			setTimer()

			slimeutils.microgames.microgame = slimeutils.microgames.queue[1].microgame

			if slimeutils.microgames.canvas then slimeutils.microgames.canvas:release() end
			slimeutils.microgames.canvas = love.graphics.newCanvas(slimeutils.microgames.microgame.width and slimeutils.microgames.microgame.width*2 or 640, slimeutils.microgames.microgame.height and slimeutils.microgames.microgame.height*2 or 480)
			if slimeutils.microgames.microgame.init then slimeutils.microgames.microgame.init() end
		end

		stagetimer = stagetimer + dt
		stageframe = stageframe + 1

		-- Microgame :33
		if slimeutils.microgames.microgame then
			setTimer()
			if slimeutils.microgames.microgame.update then slimeutils.microgames.microgame.update(dt) end
		end
	end
end


if not love.draw then function love.draw() end end
local draw_hook = love.draw
function love.draw()
	draw_hook()
	if slimeutils.microgames.running then
		if slimeutils.microgames.microgame then
			love.graphics.push()
			love.graphics.origin()
			local c = love.graphics.getCanvas()
			love.graphics.setCanvas({slimeutils.microgames.canvas, stencil = true})
			slimeutils.microgames.microgame.draw()
			love.graphics.setCanvas(c)
			love.graphics.pop()
		end

		love.graphics.setColor(1,1,1,1)
		if not slimeutils.microgames.anims[animslist[stage+1]] then -- Fallback if no custom microgame play animation
			slimeutils.microgames.draw()
		else
			slimeutils.microgames.anims[animslist[stage+1]](stagetimer, stageframe)
		end
	end
end