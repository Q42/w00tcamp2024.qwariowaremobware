
--[[
	Author: Nino

	threading_needle for Mobware Minigames

	feel free to search and replace "threading_needle" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
]]


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local threading_needle = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- title image
-- Load the title screen
local title_sprite = gfx.sprite.new(gfx.image.new("Minigames/threading_needle/images/threading_needle_title"))

title_sprite:moveTo(200, 120)
title_sprite:add()

local handThreadSprite = gfx.sprite.new(gfx.image.new("Minigames/threading_needle/images/hand_with_thread"))
local needleSprite = gfx.sprite.new(gfx.image.new("Minigames/threading_needle/images/needle"))
handThreadSprite:setCollideRect(0, 20, 10, 10)
needleSprite:setCollideRect(0, 0, 10, 20)
handThreadSprite:moveTo(250, 120)
needleSprite:moveTo(100, 120)

local neutralAccX = 0.0
local neutralAccY = 0.0

mobware.timer.setPosition("bottomLeft")
mobware.timer.sprite:add()

playdate.startAccelerometer()

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'title'
-- mobware.BbuttonIndicator.start()

-- start timer	 
local MAX_GAME_TIME = 12000 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
game_timer.timerEndedCallback = function() gamestate = "defeat" end
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


function threading_needle.update()

	-- updates all sprites
	gfx.sprite.update()

	-- update timer
	playdate.frameTimer.updateTimers()

	mobware.timer.setGameProgress(game_timer.value)

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'title' then
		playdate.wait(1500)
		neutralAccX, neutralAccY = playdate.readAccelerometer()
		print("NaccX: " .. neutralAccX .. " NaccY: " .. neutralAccY)

		title_sprite:remove()
		gamestate = 'playing'
		needleSprite:add()
		handThreadSprite:add()
	elseif gamestate == 'playing' then
		local curAccX, curAccY = playdate.readAccelerometer()
		local accX = curAccX - neutralAccX
		local accY = curAccY - neutralAccY
		handThreadSprite:moveBy(accX*5, accY*5)
		if #handThreadSprite:overlappingSprites() > 0 then
			gamestate = "victory"
		end
	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		mobware.print("good job!")

		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then
		mobware.print("JAMMER JOH")
		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end

-- Minigame package should return itself
return threading_needle