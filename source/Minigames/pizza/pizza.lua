
--[[
	Author: Edwin Veger
]]


--[[ NOTE: The following libraries are already imported in main.lua, so there's no need to define them in the minigame package
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer" 
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"
]]

-- Import any supporting libraries from minigame's folder
	--> Note that all supporting files should be located in the minigame's directory "Minigames/minigame_template/" (or any subdirectory) 
-- import 'lib/AnimatedSprite' 

local function ternary(cond, T, F )
    if cond then return T else return F end
end

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

local function makeCustomButton(name)
	local path

	if name == 'a' then
		path = "images/A-button"
	elseif name == 'b' then
		path = "images/B-button"
	else 
		assert(false, "Invalid button name")
	end

	local spritesheet = gfx.imagetable.new(path)
	local sprite = AnimatedSprite.new(spritesheet)
	sprite:addState("mash",1,6, {tickStep = 2}, true)
	sprite:setZIndex(1000)
	sprite:setIgnoresDrawOffset(true)
	return sprite
end

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local pizza = {}

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

-- start timer	 
local MAX_GAME_TIME = 5 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
-- local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "timeUp" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

local numberOfSlices = 6

local aButton = makeCustomButton('a')
local bButton = makeCustomButton('b')

local pizza_image = gfx.image.new("Minigames/pizza/images/pizza")
local checkmark_image = gfx.image.new("Minigames/pizza/images/checkmark")
-- local pizza_sprite = gfx.sprite.new(pizza_image)

function pizza.setUp()
    print("setUp called.")
	isFlipped = math.random() < 0.5
	
	-- pizza_sprite:moveTo(200, 120)
	-- pizza_sprite:add()

	if isFlipped then
		aButton:moveTo(36 + 72, 240 - 36 - 16)
		bButton:moveTo(364 - 72, 240 - 36 - 16)
	else 
		bButton:moveTo(36 + 72, 240 - 36 - 16)
		aButton:moveTo(364 - 72, 240 - 36 - 16)
	end
end

pizza.setUp()

function pizza.drawPizza()
	assert(pizza_image, "pizza_image is nil")
	assert(checkmark_image, "checkmark_image is nil")

	-- Clear the screen
	playdate.graphics.clear()

	-- Define the parameters for drawSampled
    local z = 100 -- Depth (not typically used in 2D)
    local tiltAngle = 20 -- Tilt angle in degrees

    -- Get the current time in milliseconds
	local currentTime = playdate.getCurrentTimeMilliseconds()

	-- Calculate a sine wave value based on the current time
	-- Adjust the frequency and amplitude as needed
	local frequency = 0.0001 -- Frequency of the sine wave
	local amplitude = 45 -- Amplitude of the sine wave
	local sineValue = math.sin(currentTime * frequency) * amplitude
	tiltAngle = sineValue
	print("tiltAngle", tiltAngle)

	local crankAngle = playdate.getCrankPosition() / 360 * (2 * math.pi) 
	local iHatX = math.cos(crankAngle) * 1.1
	local iHatY = math.sin(crankAngle) * 1.1
	local jHatX = -math.sin(crankAngle) * 1.1
	local jHatY = math.cos(crankAngle) * 1.1

	local x, y, width, height = 80 - 80, -40, 240 + 80, 280

    -- Draw the sampled image
    pizza_image:drawSampled(
		x, y, width, height, -- x, y, width, height
		0.5, 0.5, -- center x, y
		iHatX, jHatX,-- dxx, dyx
		iHatY, jHatY, -- dxy, dyy
		0.5, 0.5, -- dx, dy
		500, -- z
		45, -- tilt angle
		false -- tile
	)

	for i = 1, numberOfSlices do
		local angle = crankAngle + (i-1) * 2 * math.pi / numberOfSlices

		local iHatX = math.cos(angle) -- * 1.1
		local iHatY = math.sin(angle) -- * 1.1
		local jHatX = -math.sin(angle) -- * 1.1
		local jHatY = math.cos(angle) -- * 1.1

		-- local width, height = checkmark_image:getSize()

		checkmark_image:drawSampled(
			x, y, width, height, -- x, y, width, height
			0.5, 0.5, -- center x, y
			iHatX, jHatX,-- dxx, dyx
			iHatY, jHatY, -- dxy, dyy
			0.5, -3.6, -- dx, dy
			500, -- z
			45, -- tilt angle
			false -- tile
		)
	end

	-- field:drawSampled(0, 70, 200, 50,  -- x, y, width, height
	-- 				0.5, 0.95, -- center x, y
	-- 				c / fieldscale, s / fieldscale, -- dxx, dyx
	-- 				-s / fieldscale, c / fieldscale, -- dxy, dyy
	-- 				x/fieldwidth, y/fieldheight, -- dx, dy
	-- 				16, -- z
	-- 				16.6, -- tilt angle
	-- 				true); -- tile

    -- Update the display
    playdate.display.flush()
end

function pizza.update()
	-- updates all sprites
	-- gfx.sprite.update() 

	pizza.drawPizza()

	
	-- update timer
	-- playdate.frameTimer.updateTimers()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		if not isFlipped then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end
		
	end

	if playdate.buttonJustPressed(playdate.kButtonB) then
		if isFlipped then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end
	end

	if gamestate == 'start' then
	else 
		aButton:remove()
		bButton:remove()
	end 

	if gamestate == 'start' then
		-- do nothing
	elseif gamestate == 'victory' then
		gfx.sprite.update() 
		mobware.print("HET IS WEEKEND")
		playdate.wait(2000)
		return 1
	elseif gamestate == 'defeat' then
		gfx.sprite.update() 
		mobware.print("DAT DUURT TE LANG")
		playdate.wait(2000)	
		return 0
	elseif gamestate == 'timeUp' then
		gfx.sprite.update() 
		mobware.print("TE LAAT, JE PL IS BOOS")
		playdate.wait(2000)	
		return 0
	end
end

return pizza
