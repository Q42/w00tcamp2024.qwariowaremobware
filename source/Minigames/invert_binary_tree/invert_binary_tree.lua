
--[[
	Author: Nino

	invert_binary_tree for Mobware Minigames

	feel free to search and replace "invert_binary_tree" in this code with your minigame's name,
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
	--> Note that all supporting files should be located in the minigame's directory "Minigames/invert_binary_tree/" (or any subdirectory) 
--import 'Minigames/invert_binary_tree/lib/AnimatedSprite' 


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local invert_binary_tree = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- update sprite's frame so that the sprite will reflect the crank's actual position
local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
local frame_num = math.floor( crank_position / 45 + 1 )

-- title image
-- Load the title screen
local title_sprite = gfx.sprite.new(gfx.image.new("Minigames/invert_binary_tree/images/invert_binary_tree_title"))

title_sprite:moveTo(200, 120)
title_sprite:add()

local function createNumberObject(number)
	local numberObject = {
		val = number,
		spr = gfx.sprite.new(gfx.imageWithText("" .. number, 200, 200))
	}
	return numberObject
end

local numberStates = {}
numberStates[1] =  { createNumberObject(1) }
numberStates[2] =  { createNumberObject(2), createNumberObject(3) }

local testNumberObject = createNumberObject(1337)
testNumberObject.spr:moveTo(100, 50)
testNumberObject.spr:add()

local function showBinaryTreeRow(states, center_x, level)
	local spacing = 100  - 20 * level
	local halfSpacing = spacing / 2
	local y = 20 + level * 80
	for index, value in ipairs(states) do
		local pos_x = center_x - halfSpacing + spacing * (index - 1 ) -- + 0 if index 1, + spacing if index 2
		value.spr:moveTo(pos_x, y)
	end
end

local function updateBinaryTree()
	for index, value in ipairs(numberStates) do
		showBinaryTreeRow(value, 200, index) -- todo centerPoint
	end
end

local function showBinaryTree()
	updateBinaryTree()
	for index, value in ipairs(numberStates) do
		for index2, value2 in ipairs(value) do
			value2.spr:add()
		end
	end
end



--> Initialize music / sound effects
local click_noise = playdate.sound.sampleplayer.new('Minigames/invert_binary_tree/sounds/click')

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'title'
mobware.BbuttonIndicator.start()

-- start timer	 
local MAX_GAME_TIME = 600 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


--[[
	function <minigame name>:update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
function invert_binary_tree.update()

	-- updates all sprites
	gfx.sprite.update()

	-- update timer
	playdate.frameTimer.updateTimers()

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'title' then
		playdate.wait(1000)
		title_sprite:remove()
		updateBinaryTree()
		showBinaryTree()
		gamestate = 'playing'
	elseif gamestate == 'playing' then
		

	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		mobware.print("good job!",90, 70)

		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		-- if player has lost, show images of playdate running out of power 
		-- local playdate_low_battery_image = gfx.image.new("Minigames/invert_binary_tree/images/playdate_low_battery")
		-- local low_battery = gfx.sprite.new(playdate_low_battery_image)
		-- low_battery:moveTo(150, 75)
		-- low_battery:addSprite()
		-- gfx.sprite.update() 

		-- -- wait another 2 seconds then exit
		-- playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end


--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function invert_binary_tree.cranked(change, acceleratedChange)
	-- When crank is turned, play clicking noise
	click_noise:play(1)

	-- update sprite's frame so that the sprite will reflect the crank's actual position
	local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	local frame_num = math.floor( crank_position / 45.1 + 1 ) -- adding .1 to fix bug that occurs if crank_position ~= 360
	pd_sprite:setImage(playdate_image_table:getImage(frame_num))

end


-- Minigame package should return itself
return invert_binary_tree
