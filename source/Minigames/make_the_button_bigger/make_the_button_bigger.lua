
--[[
	Author: Nino

	make_the_button_bigger for Mobware Minigames

	feel free to search and replace "make_the_button_bigger" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
]]


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local make_the_button_bigger = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- title image
-- Load the title screen
local title_sprite = gfx.sprite.new(gfx.image.new("Minigames/make_the_button_bigger/images/make_the_button_bigger_title"))

title_sprite:moveTo(200, 120)
title_sprite:add()

local bg_sprite = gfx.sprite.new(gfx.image.new("Minigames/make_the_button_bigger/images/make_the_button_bigger_background"))
bg_sprite:moveTo(200, 120)

local button_sale = 1.0
local button_target_scale = 1.0 -- will be set when transitioning to playing state
local button_sprite = gfx.sprite.new(gfx.image.new("Minigames/make_the_button_bigger/images/button_buy"))
local button_outline_sprite = gfx.sprite.new(gfx.image.new("Minigames/make_the_button_bigger/images/button_outline"))
button_sprite:moveTo(200, 120)
button_outline_sprite:moveTo(200, 120)

mobware.timer.setPosition("bottomLeft")
mobware.timer.sprite:add()

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'title'
-- mobware.BbuttonIndicator.start()

-- start timer	 
local MAX_GAME_TIME = 12 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
game_timer.timerEndedCallback = function() gamestate = "defeat" end
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


function make_the_button_bigger.update()

	-- updates all sprites
	gfx.sprite.update()

	-- update timer
	playdate.frameTimer.updateTimers()

	mobware.timer.setGameProgress(game_timer.value)

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'title' then
		playdate.wait(1500)
		title_sprite:remove()
		bg_sprite:add()
		gamestate = 'playing'
		button_sprite:add()
		button_outline_sprite:add()
		button_outline_sprite:setScale(1.8)
		button_sale = 1.0
		button_target_scale = 1.0 + math.random() * 2
		button_outline_sprite:setScale(button_target_scale)
	elseif gamestate == 'playing' then
		local scaleChange = playdate.getCrankChange() / 30
		button_sale = button_sale + scaleChange
		if button_sale < 0.1 then
			button_sale = 0.1
		end
		if button_sale > 4.0 then
			button_sale = 4.0
		end
		button_sprite:setScale(button_sale)

		if math.abs(button_target_scale - button_sale) < 0.1 then
			gamestate = 'victory'
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
return make_the_button_bigger