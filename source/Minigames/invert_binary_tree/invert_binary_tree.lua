
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

-- title image
-- Load the title screen
local title_sprite = gfx.sprite.new(gfx.image.new("Minigames/invert_binary_tree/images/invert_binary_tree_title"))

title_sprite:moveTo(200, 120)
title_sprite:add()

local bg_sprite = gfx.sprite.new(gfx.image.new("Minigames/invert_binary_tree/images/invert_binary_tree_background"))
bg_sprite:moveTo(200, 120)

local rotation_sprite = gfx.sprite.new(gfx.image.new(10,10)) -- dummy image
local unrotated_tree_image = nil
local tree_image_angle = 0.0

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
numberStates[3] =  { createNumberObject(4), createNumberObject(5), createNumberObject(6), createNumberObject(7) }

local function reverse(tab)
	for i = 1, #tab//2, 1 do
			tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
	end
	return tab
end

local targetStates = table.deepcopy(numberStates)
for level, value in ipairs(targetStates) do
	targetStates[level] = reverse(value)
end
print ("numberStates")
printTable(numberStates)

print("targetStates")
printTable(targetStates)


local selectedLevel = 1
local selectedLevelIndex = 1

-- local selection_spritesheet = gfx.imagetable.new("Minigames/invert_binary_tree/images/selection_borders")
-- local selection_sprite = AnimatedSprite.new( selection_spritesheet )
-- selection_sprite:playAnimation()
-- selection_sprite:pauseAnimation()
-- selection_sprite:frame_num(1)
-- selection_sprite:setZIndex(1)
local selection_frames = gfx.imagetable.new("Minigames/invert_binary_tree/images/selection_borders")
local selection_sprite = gfx.sprite.new(selection_frames:getImage(1))
selection_sprite:setZIndex(1)

local function showBinaryTreeRow(states, center_x, level)
	local numSplits = 2 ^ (level-1)
	local splitSpacing = 360 / numSplits
	if #states == 1 then
		splitSpacing = 0
	end
	local halfSpacing = splitSpacing / 2
	local y = 25 + (level - 1) * 70
	for index, value in ipairs(states) do
		-- local pos_x = center_x - halfSpacing + spacing * (index - 1 ) -- + 0 if index 1, + spacing if index 2
		local pos_x = 200 - (#states/2 - 0.5) * splitSpacing + (index - 1) * splitSpacing
		
		value.spr:moveTo(pos_x, y)
		if selectedLevel == level and selectedLevelIndex == index then
			selection_sprite:setImage(selection_frames:getImage(level))
			selection_sprite:moveTo(pos_x + halfSpacing, y)
		end
	end
end

local function updateBinaryTree()
	for level, value in ipairs(numberStates) do
		showBinaryTreeRow(value, 200 , level) -- todo centerPoint
	end
end

local function showBinaryTree()
	updateBinaryTree()
	selection_sprite:add()
	for index, value in ipairs(numberStates) do
		for index2, value2 in ipairs(value) do
			value2.spr:add()
		end
	end
end

local function hideBinaryTree()
	for index, value in ipairs(numberStates) do
		for index2, value2 in ipairs(value) do
			value2.spr:remove()
		end
	end
	bg_sprite:remove()
	selection_sprite:remove()
end

local function check_win()
	for level, value in ipairs(numberStates) do
		for index, value2 in ipairs(value) do
			if value2.val ~= targetStates[level][index].val then
				return false
			end
		end
	end
	return true
end



--> Initialize music / sound effects
local click_noise = playdate.sound.sampleplayer.new('Minigames/invert_binary_tree/sounds/click')

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'title'
-- mobware.BbuttonIndicator.start()

-- start timer	 
local MAX_GAME_TIME = 12 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
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
		playdate.wait(1500)
		title_sprite:remove()
		bg_sprite:add()
		updateBinaryTree()
		showBinaryTree()
		gamestate = 'playing'
	elseif gamestate == 'playing' then
		updateBinaryTree()
		if playdate.buttonJustPressed('a') then
			print("a")
			local oldLeft = numberStates[selectedLevel][selectedLevelIndex]
			local oldRight = numberStates[selectedLevel][selectedLevelIndex + 1]
			numberStates[selectedLevel][selectedLevelIndex] = oldRight
			numberStates[selectedLevel][selectedLevelIndex + 1] = oldLeft

			print("win?", check_win())
			if(check_win()) then
				updateBinaryTree()
				gamestate = "victory"
			end
		elseif playdate.buttonJustPressed('down') then
			print("down")
			selectedLevel = selectedLevel + 1
			if selectedLevel > #numberStates then
				selectedLevel = 1
			end
			selectedLevelIndex = 1
		elseif playdate.buttonJustPressed('up') then
			print("up")
			selectedLevel = selectedLevel - 1
			if selectedLevel < 1 then
				selectedLevel = #numberStates
			end
			selectedLevelIndex = 1
		elseif playdate.buttonJustPressed('left') then
			print("left")
			selectedLevelIndex = selectedLevelIndex - 1
			if selectedLevelIndex < 1 then
				selectedLevelIndex = 1
			end
		elseif playdate.buttonJustPressed('right') then
			print("right")
			selectedLevelIndex = selectedLevelIndex + 1 -- to the next pair
			if selectedLevelIndex >= #numberStates[selectedLevel] then
				selectedLevelIndex = 1
			end
		end
	elseif gamestate == "cranking" then
		local crank_change = playdate.getCrankChange()
		tree_image_angle = tree_image_angle + crank_change
		local rotated_tree_image = unrotated_tree_image:rotatedImage(tree_image_angle)
		rotation_sprite:setImage(rotated_tree_image)
		print("angle", "" .. tree_image_angle,  "crank_change" .. crank_change)
		local abs_tree_image_angle = math.abs(tree_image_angle)
		if abs_tree_image_angle > 175 and abs_tree_image_angle < 185 then
			gamestate = "victory"
		end
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


--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function invert_binary_tree.cranked(change, acceleratedChange)
	-- When crank is turned, play clicking noise

	-- update sprite's frame so that the sprite will reflect the crank's actual position
	-- local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	-- local frame_num = math.floor( crank_position / 45.1 + 1 ) -- adding .1 to fix bug that occurs if crank_position ~= 360
	if gamestate == 'playing' and math.abs(playdate.getCrankChange()) > 5 then
		gamestate = "cranking"
		-- get a screenshot of the current state without the selection_spritesheet
		selection_sprite:remove()
		gfx.sprite.update()
		playdate.display.flush()
		hideBinaryTree()
		rotation_sprite:moveTo(200, 120)
		rotation_sprite:add()
		unrotated_tree_image = gfx.getDisplayImage()
	end


end


-- Minigame package should return itself
return invert_binary_tree
