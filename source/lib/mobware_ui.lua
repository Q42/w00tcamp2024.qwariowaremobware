--[[
	library of functions for displaying varius mobware UI elements
]]

local gfx <const> = playdate.graphics

mobware = {}

-- Crank Indicator
local crank_spritesheet = gfx.imagetable.new("images/crank")
mobware.crankIndicator = {}
function mobware.crankIndicator.start()
	mobware.crankIndicator_sprite = AnimatedSprite.new( crank_spritesheet )
	mobware.crankIndicator_sprite:addState("crank", 1, 8, {tickStep = 4}, true)
	mobware.crankIndicator_sprite:moveTo(360,200)
	mobware.crankIndicator_sprite:setZIndex(1000)
	mobware.crankIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.crankIndicator.stop()
	if mobware.crankIndicator_sprite then
		mobware.crankIndicator_sprite:remove()
	end
end


-- "A" button indicator
local Abutton_spritesheet = gfx.imagetable.new("images/A-button")
mobware.AbuttonIndicator = {}
function mobware.AbuttonIndicator.start(x,y)
	mobware.AbuttonIndicator.AbuttonIndicator_sprite = AnimatedSprite.new( Abutton_spritesheet )
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:addState("mash",1,6, {tickStep = 2}, true )
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:moveTo(364,205)
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:setZIndex(1000)
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.AbuttonIndicator.stop()
	if mobware.AbuttonIndicator.AbuttonIndicator_sprite then
		mobware.AbuttonIndicator.AbuttonIndicator_sprite:remove()
	end
end




-- "B" button indicator
local Bbutton_spritesheet = gfx.imagetable.new("images/B-button")
mobware.BbuttonIndicator = {}
function mobware.BbuttonIndicator.start()
	mobware.BbuttonIndicator.BbuttonIndicator_sprite = AnimatedSprite.new( Bbutton_spritesheet )
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:addState("mash",1,6, {tickStep = 2}, true )
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:moveTo(275,205)
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:setZIndex(1000)
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.BbuttonIndicator.stop()
	if mobware.BbuttonIndicator.BbuttonIndicator_sprite then
		mobware.BbuttonIndicator.BbuttonIndicator_sprite:remove()
	end
end


-- D-pad indicator
local Dpad_spritesheet = gfx.imagetable.new("images/d-pad")
mobware.DpadIndicator = {}

-- if no inputs are given, d-pad indicator shows D-pad moving in a circle
function mobware.DpadIndicator.start(direction1, direction2)
	mobware.DpadIndicator_sprite = AnimatedSprite.new(Dpad_spritesheet)

	-- if no inputs are given, d-pad indicator shows D-pad moving in a circle
	mobware.DpadIndicator_sprite:addState("circle",2,5, {tickStep = 3}, true)

	-- If one or two directions are provided as input, use them to create a custom animation state:
	if direction1 then
		local directions = {["up"] = 2, ["right"] = 3, ["down"] = 4, ["left"] = 5}
		frame1 = directions[direction1] or 1
		frame2 = directions[direction2] or 1
		mobware.DpadIndicator_sprite:addState("custom",nil,nil, {tickStep = 3, frames = {frame1,frame2}}, true)
		mobware.DpadIndicator_sprite:changeState("custom")
	end
	mobware.DpadIndicator_sprite:moveTo(70,205)
	mobware.DpadIndicator_sprite:setZIndex(1000)
	mobware.DpadIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.DpadIndicator.stop()
	if mobware.DpadIndicator_sprite then
		mobware.DpadIndicator_sprite:remove()
	end
end



-- Accelerometer indicator
local Accelerometer_spritesheet = gfx.imagetable.new("images/Accelerometer")
mobware.AccelerometerIndicator = {}

-- if no inputs are given, d-pad indicator shows D-pad moving in a circle
function mobware.AccelerometerIndicator.start(direction1, direction2)
	mobware.AccelerometerIndicator_sprite = AnimatedSprite.new(Accelerometer_spritesheet )

	-- if no inputs are given, indicator shows playdate moving in every direction
	--mobware.AccelerometerIndicator_sprite:addState("circle",2,5, {tickStep = 3}, true)
	--mobware.AccelerometerIndicator_sprite:addState("circle",nil,nil, {tickStep = 4, frames = {2,1,3,1,4,1,5,1}}, true)
	mobware.AccelerometerIndicator_sprite:addState("circle",nil,nil, {tickStep = 3, frames = {3,1,5,1,2,1,4,1}}, true)

	-- If one or two directions are provided as input, use them to create a custom animation state:
	if direction1 then
		local directions = {["up"] = 2, ["right"] = 3, ["down"] = 4, ["left"] = 5}
		frame1 = directions[direction1] or 1
		if direction2 then
			frame2 = directions[direction2] or 1
			mobware.AccelerometerIndicator_sprite:addState("custom",nil,nil, {tickStep = 2, frames = {frame1, 1, frame2}, yoyo=true}, true)
			mobware.AccelerometerIndicator_sprite:changeState("custom")
		else
			mobware.AccelerometerIndicator_sprite:addState("custom",nil,nil, {tickStep = 2, frames = {frame1, 1}}, true)
			mobware.AccelerometerIndicator_sprite:changeState("custom")
		end
	end
	mobware.AccelerometerIndicator_sprite:moveTo(200,190)
	mobware.AccelerometerIndicator_sprite:setZIndex(1000)
	mobware.AccelerometerIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.AccelerometerIndicator.stop()
	if mobware.AccelerometerIndicator_sprite then
		mobware.AccelerometerIndicator_sprite:remove()
	end
end



-- Microphone indicator
local Mic_input_spritesheet = gfx.imagetable.new("images/mic-input")
mobware.MicIndicator = {}
function mobware.MicIndicator.start()
	mobware.MicIndicator_sprite = AnimatedSprite.new( Mic_input_spritesheet )
	mobware.MicIndicator_sprite:addState("animate",nil,nil, {tickStep = 4}, true )
	mobware.MicIndicator_sprite:moveTo(200,190)
	mobware.MicIndicator_sprite:setZIndex(1000)
	mobware.MicIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.MicIndicator.stop()
	if mobware.MicIndicator_sprite then
		mobware.MicIndicator_sprite:remove()
	end
end


-- Menu button indicator
local menu_button_spritesheet = gfx.imagetable.new("images/menu-button")
mobware.MenuIndicator = {}
function mobware.MenuIndicator.start()
	mobware.MenuIndicator_sprite = AnimatedSprite.new( menu_button_spritesheet )
	mobware.MenuIndicator_sprite:addState("animate",nil,nil, {tickStep = 6}, true )
	mobware.MenuIndicator_sprite:moveTo(380,50)
	mobware.MenuIndicator_sprite:setZIndex(1000)
	mobware.MenuIndicator_sprite:setIgnoresDrawOffset(true)
end

function mobware.MenuIndicator.stop()
	if mobware.MicIndicator_sprite then
		mobware.MenuIndicator_sprite:remove()
	end
end



-- Q Timer indicator
local q_timer_spritesheet_black = gfx.imagetable.new("images/q-timer")
local q_timer_spritesheet_white = gfx.imagetable.new("images/q-timer-white")
local q_timer_spritesheet = q_timer_spritesheet_white
mobware.timer = {}
mobware.timer.defaultZIndex = 1000
mobware.timer.sprite = gfx.sprite.new(q_timer_spritesheet_black:getImage(1))
mobware.timer.sprite:setZIndex(1000)
function mobware.timer.setGameProgress(progress)
	local frameIdx = progress * q_timer_spritesheet:getLength()
	-- clamp frameIdx to the length of the spritesheet
	frameIdx = math.min(frameIdx, q_timer_spritesheet:getLength())
	frameIdx = math.max(frameIdx, 1)
	frameIdx = math.floor(frameIdx)
	mobware.timer.sprite:setImage(q_timer_spritesheet:getImage(frameIdx))
end

function mobware.timer.setPosition(pos)
	if pos == "topLeft" then
		mobware.timer.sprite:moveTo(20, 30)
	elseif pos == "topRight" then
		mobware.timer.sprite:moveTo(381, 26)
	elseif pos == "bottomLeft" then
		mobware.timer.sprite:moveTo(18, 215)
	elseif pos == "bottomRight" then
		mobware.timer.sprite:moveTo(381, 215)
	end
end

function mobware.timer.setColor(color)
	if color == "black" then
		q_timer_spritesheet = q_timer_spritesheet_black
		mobware.timer.sprite:setImage(q_timer_spritesheet_black:getImage(1))
	elseif color == "white" then
		q_timer_spritesheet = q_timer_spritesheet_white
	end
	mobware.timer.sprite:setImage(q_timer_spritesheet:getImage(1))

end

function mobware.timer.reset()
	print "mobware timer reset"
	mobware.timer.setPosition("bottomLeft")
	mobware.timer.sprite:setImage(q_timer_spritesheet_black:getImage(1))
	mobware.timer.sprite:setZIndex(mobware.timer.defaultZIndex)
	mobware.timer.setColor("black")
end

-- initialize text box used for mobware.print
local text_box = gfx.nineSlice.new("images/text-bubble", 16, 16, 32, 32)
--local text_box = gfx.nineSlice.new("images/text-bubble-background3", 16, 16, 32, 32)

-- Function to print text in auto-sized comic-styled bubble
function mobware.print(text, x, y)
	-- if mobware.print is called without x and y parameters, print text in the center of the screen
	local text_width, text_height = gfx.getTextSize(text)
	local centered_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the screen
	local centered_y = (240 - text_height) / 2 -- this should put the minigame name in the center of the screen
	local draw_x = x or centered_x
	local draw_y = y or centered_y

	-- print text in comic-styled bubble
	text_box:drawInRect(draw_x - 16, draw_y - 16, text_width + 32, text_height + 32)
	--text_box:setIgnoresDrawOffset(true)
	gfx.drawTextAligned(text, draw_x, draw_y)
end

