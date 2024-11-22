
--[[
	Author: Nino

	make_the_button_bigger for Mobware Minigames

	feel free to search and replace "make_the_button_bigger" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
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
	--> Note that all supporting files should be located in the minigame's directory "Minigames/make_the_button_bigger/" (or any subdirectory) 
--import 'Minigames/make_the_button_bigger/lib/AnimatedSprite' 


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


--[[
	function <minigame name>:update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
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
	elseif gamestate == 'playing' then
		-- todo
	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		mobware.print("good job!",90, 70)

		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then
		mobware.print("JAMMER JOH",90, 70)
		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end

-- Minigame package should return itself
return make_the_button_bigger