
--[[
	Author: Paul Kros
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
local snd = playdate.sound

-- change this based on the amount of miems in minigame_folders
local miemAmount = 24

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local stickthememe = {}

--> Initialize music / sound effects

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

-- start timer	 
local MAX_GAME_TIME = 8 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "timeUp" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

	local randomMiem = math.random(miemAmount)
	local miemPath = "Minigames/stickthememe/images/miems/" .. randomMiem .. ".png"
	local miem_image = gfx.image.new(miemPath)
	local miem_sprite = gfx.sprite.new(miem_image)
	local handPath = "Minigames/stickthememe/images/hand.png"
	local thumbPath = "Minigames/stickthememe/images/thumb.png"
	local hand_image = gfx.image.new(handPath)
	local hand_sprite = gfx.sprite.new(hand_image)
	local thumb_image = gfx.image.new(thumbPath)
	local thumb_sprite = gfx.sprite.new(thumb_image)
	local miem_image = gfx.image.new(miemPath)
	local miem_sprite = gfx.sprite.new(miem_image)
	local y = 280
	local miemYOffset = 86
	local miemXOffset = 76
	local stickitSound = snd.sampleplayer.new("Minigames/stickthememe/sounds/stickit.wav")

function stickthememe.setUp()
	local randomInt = math.random(3)
	local bg_path = "Minigames/stickthememe/images/backgrounds/" .. randomInt .. ".png"
	local background_image = gfx.image.new(bg_path)
	mobware.AbuttonIndicator.start()


	assert(background_image, "Failed to load background image")
	gfx.sprite.setBackgroundDrawingCallback(function()
		background_image:draw(0, 0)
	end)

	local backgroundMusic = snd.sampleplayer.new("Minigames/stickthememe/sounds/nyan.wav")
	backgroundMusic:play(0)
end

local x = -100
local currentTime = 0

-- Randomly decide the direction of progression
local isAscending = math.random() > 0.5 -- true for -100 to 300, false for 300 to -100

-- Set up the timer with an updateCallback
local game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20, function() gamestate = "timeUp" end)

-- Define the updateCallback to update the value based on the timer's progress
game_timer.updateCallback = function(timer)
    currentTime = currentTime + 1

    -- Calculate the progress as a fraction of the total duration
    local progress = currentTime / timer.duration

    -- Calculate x based on the progress and the direction
    if isAscending then
        x = -100 + (progress * 400) -- Ascending from -100 to 300
    else
        x = 300 - (progress * 400) -- Descending from 300 to -100
    end
end

stickthememe.setUp()

function stickthememe.update()
	hand_sprite:setCenter(0,1)
	hand_sprite:moveTo(x, y)
	hand_sprite:add()

	miem_sprite:setCenter(0,1)
	miem_sprite:moveTo(x + miemXOffset, y - miemYOffset)
	miem_sprite:add()

	thumb_sprite:setCenter(0,1)
	thumb_sprite:moveTo(x, y)
	thumb_sprite:add()
	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	if gamestate == 'start' then
		if playdate.buttonIsPressed('a') then
			stickitSound:play(1)
			if x >= 52 and x <= 122 then
				gamestate = 'victory'
			else
				gamestate = 'victory'
			end
		end
	end

	if gamestate == 'victory' then
		mobware.AbuttonIndicator.stop()
		mobware.print("Lekkâh bezag!",200, 120)
		playdate.wait(2000)
		return 1

	elseif gamestate == 'defeat' then
		mobware.AbuttonIndicator.stop()
		gfx.sprite.update() 
		mobware.print("Jè scheve!",200, 120)
		playdate.wait(2000)	
		return 0

	elseif gamestate == 'timeUp' then
		mobware.AbuttonIndicator.stop()
		gfx.sprite.update() 
		mobware.print("Je mot plakke hè?")
		playdate.wait(2000)	
		return 0
	end
end

return stickthememe