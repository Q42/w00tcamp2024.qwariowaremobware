
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

local numberOfSlices = 5
-- array with float values between 0 and 1
local slicesStates = { 0.0, 0.0, 0.0, 0.0, 0.0 } --, 0.0 }

local pizza_image = gfx.image.new("Minigames/pizza/images/pizza")
local checkmark_image = gfx.image.new("Minigames/pizza/images/checkmark-filled")
local checkmark_spritesheet = gfx.imagetable.new("Minigames/pizza/images/checkmark-filling")
local fire_spritesheet = gfx.imagetable.new("Minigames/pizza/images/fire")
local fire_sprite
local victory_noise = playdate.sound.sampleplayer.new('Minigames/pizza/sounds/pizza_calzone')

-- Variable to store the time of the previous frame
local previousTime = playdate.getCurrentTimeMilliseconds()

function pizza.setUp()
    print("setUp called.")

	-- fire_sprite = AnimatedSprite.new(fire_spritesheet)
	-- fire_sprite:addState("mash",1,6, {tickStep = 2}, true)
	-- fire_sprite:setZIndex(1000)
	-- fire_sprite:setIgnoresDrawOffset(true)
end

pizza.setUp()

function pizza.drawPizza()
	assert(pizza_image, "pizza_image is nil")
	assert(checkmark_image, "checkmark_image is nil")
	assert(checkmark_spritesheet, "checkmark_spritesheet is nil")

	-- Clear the screen
	playdate.graphics.clear()

	-- draw fire sprite
	do 
		local index = math.floor(playdate.getCurrentTimeMilliseconds() / 100) % 2 + 1
		fire_spritesheet:getImage(index):drawScaled(90, 180, 1.25, 1)
	end

	-- Define the parameters for drawSampled
    local z = 100 -- Depth (not typically used in 2D)
    local tiltAngle = 20 -- Tilt angle in degrees

	-- local currentTime = playdate.getCurrentTimeMilliseconds()
	-- local frequency = 0.0001 -- Frequency of the sine wave
	-- local amplitude = 45 -- Amplitude of the sine wave
	-- local sineValue = math.sin(currentTime * frequency) * amplitude

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

		local image
		if slicesStates[i] >= 1.0 then
			image = checkmark_image
		else 
			-- select correct progress checkmark image from image table bases on slicesStates[i] so we can use it for drawSampled
			local index = math.floor(slicesStates[i] * 25) + 1
			index = math.min(index, 25)
			image = checkmark_spritesheet:getImage(index)
			local assertionMessage = "image is nil, could not load, i: " .. i .. ", slicesStates[i]: " .. slicesStates[i] .. ", index: " .. index
			assert(image, assertionMessage)
		end

		image:drawSampled(
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
	playdate.frameTimer.updateTimers()

	-- Get the current time
	local currentTime = playdate.getCurrentTimeMilliseconds()
	local deltaTime = (currentTime - previousTime) / 1000
	previousTime = currentTime
	
	-- Print deltaTime to the console for debugging
	print("Delta Time: " .. deltaTime)

	local selectedSliceIndex = math.floor((1 - ((playdate.getCrankPosition() - 180 / numberOfSlices) / 360)) * numberOfSlices) + 1

	print(selectedSliceIndex)
	if selectedSliceIndex > numberOfSlices then
		selectedSliceIndex = 1
	end
	print(selectedSliceIndex)
	
	-- increment slice value by dt
	for i = 1, numberOfSlices do
		if i == selectedSliceIndex then
			slicesStates[i] = math.min(slicesStates[i] + deltaTime, 2.0)
		elseif  slicesStates[i] < 1.0 then
			slicesStates[i] = math.max(slicesStates[i] - deltaTime / 2, 0.0)
		end
	end

	-- determine win condition
	local allSlicesBaked = true
	-- local isSliceBurned = false // TO DO

	do 
		for i = 1, numberOfSlices do
			if slicesStates[i] < 1.0 then
				allSlicesBaked = false
				break
			end
		end

		if allSlicesBaked then
			gamestate = 'victory'
		end
	end

	if gamestate == 'start' then
		-- do nothing
	elseif gamestate == 'victory' then
		gfx.sprite.update() 
		mobware.print("DAT RUIKT HEERLIJK")
		victory_noise:play()
		playdate.wait(3000)
		return 1
	elseif gamestate == 'defeat' then
		gfx.sprite.update() 
		mobware.print("DAT DUURT TE LANG")
		playdate.wait(2000)	
		return 0
	elseif gamestate == 'timeUp' then
		gfx.sprite.update() 
		mobware.print("WAT DUURT DAT LANG")
		playdate.wait(2000)	
		return 0
	end
end

return pizza
