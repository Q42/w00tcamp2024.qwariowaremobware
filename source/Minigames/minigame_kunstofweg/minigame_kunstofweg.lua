
--[[
	Author: Paul Kros

	minigame_template for Mobware Minigames

	feel free to search and replace "minigame_template" in this code with your minigame's name,
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
	--> Note that all supporting files should be located in the minigame's directory "Minigames/minigame_template/" (or any subdirectory) 
--import 'Minigames/minigame_template/lib/AnimatedSprite' 


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local minigame_kunstofweg = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics
local snd = playdate.sound

-- animation for on-screen Playdate sprite
local pd_sprite = gfx.sprite.new(image_table)

pd_sprite:moveTo(200, 120)
pd_sprite:add()
pd_sprite.frame = 1 
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 16


--> Initialize music / sound free-sound-effects
local backgroundMusic = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/clowntheme.wav")
backgroundMusic:play(0)

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'
mobware.BbuttonIndicator.start()

-- start timer	 
local MAX_GAME_TIME = 16 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "timeUp" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


--[[
	function <minigame name>:update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]

local initialSetup = false
local shuffledMap, shuffledKeys, path, firstKey, firstValue, shuffledFirstFive
local messageSprites = {}
local typeSprites = {}
local backgroundImage = nil

local function initializeSprites()
    -- Pre-load all message and type sprites
	backgroundImage = gfx.image.new("Minigames/minigame_kunstofweg/images/slackinterface.png")
	assert(backgroundImage, "Failed to load background image")
	gfx.sprite.setBackgroundDrawingCallback(function()
		backgroundImage:draw(0, 0)
	end)
    for key, _ in pairs(shuffledMap) do
        local messagePath = "Minigames/minigame_kunstofweg/images/textSprites/" .. key .. "text.png"
        local messageSprite = gfx.sprite.new(gfx.image.new(messagePath))
        messageSprites[key] = messageSprite
        
        -- Create both kunst and weg sprites for each item
        local wegSprite = gfx.sprite.new(gfx.image.new("Minigames/minigame_kunstofweg/images/weg.png"))
        local kunstSprite = gfx.sprite.new(gfx.image.new("Minigames/minigame_kunstofweg/images/kunst.png"))
        typeSprites[key] = {
            [false] = wegSprite,
            [true] = kunstSprite
        }
    end
end

function minigame_kunstofweg.update()
	playdate.frameTimer.updateTimers()
	-- true is art, false is trash
	if initialSetup == false then
		shuffledMap, shuffledKeys = generateObjectMap()
		firstKey, firstValue = getFirstEntry(shuffledMap, shuffledKeys)
		path = "Minigames/minigame_kunstofweg/images/objectSprites/".. firstKey .. ".png"
        shuffledFirstFive = getFirstFiveEntriesShuffled(shuffledMap, shuffledKeys)
		initializeSprites()
		mobware.AbuttonIndicator.start()
		mobware.BbuttonIndicator.start()
		initialSetup = true
	end
	
	-- updates all sprites
	gfx.sprite.update() 

	displaySprites(shuffledFirstFive)
	-- update timer
	playdate.frameTimer.updateTimers()

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'start' then
		local object_image = gfx.image.new(path)
		local objectSprite = gfx.sprite.new(object_image)
		objectSprite:moveTo(275, 100)
		objectSprite:add()


		if playdate.buttonIsPressed('a') then
			if firstValue == true then
				gamestate = 'defeat'
			else
				gamestate = 'victory'
			end
		elseif playdate.buttonIsPressed('b') then
			if firstValue == false then
				gamestate = 'defeat'
			else
				gamestate = 'victory'
			end
		end

	elseif gamestate == 'victory' then
		mobware.print("NICE",200, 120)
		local niceSound = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/nice.wav")
		niceSound:play(1)
		playdate.wait(2000)
		return 1

	elseif gamestate == 'defeat' then
		gfx.sprite.update() 
		mobware.print("FOUT",200, 120)
		local foutSound = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/fout.wav")
		foutSound:play(1)
		playdate.wait(2000)	
		return 0

	elseif gamestate == 'timeUp' then
		gfx.sprite.update() 
		local message
		if firstValue == true then
			message = "Het was Kunst!"
			local kunstSound = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/kunst.wav")
			kunstSound:play(1)
		else
			message = "Het mocht Weg!"
			local wegSound = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/weg.wav")
			wegSound:play(1)
		end
		mobware.print(message, 150, 120)
		playdate.wait(2000)	
		return 0

	end

end

function displaySprites(fiveRandomValues)
    local yOffset = 0
    local yOffsetIncrement = 40

    for key, value in pairs(fiveRandomValues) do
        local messageSprite = messageSprites[key]
        local typeSprite = typeSprites[key][value]

        messageSprite:moveTo(70, 30 + yOffset)
        typeSprite:moveTo(115, 30 + yOffset)

        messageSprite:add()
        typeSprite:add()

        yOffset = yOffset + yOffsetIncrement
    end
end

function generateObjectMap()
    -- Define a table with string keys
    local booleanMap = {
        ["kratje"] = false,
        ["schoene"] = false,
        ["flessen"] = false,
        ["telefoon"] = false,
        ["stiften"] = false,
        ["printer"] = false,
        ["desktop"] = false,
        ["postit"] = false,
        ["boeken"] = false,
        ["gitaar"] = false
    }

    -- Create a list of keysx
    local keys = {}
    for key in pairs(booleanMap) do
        table.insert(keys, key)
    end

    -- Shuffle the keys
    for i = #keys, 2, -1 do
        local j = math.random(i)
        keys[i], keys[j] = keys[j], keys[i]
    end

    -- Create a new table with shuffled keys and random boolean values
    local shuffledMap = {}
    for _, key in ipairs(keys) do
        shuffledMap[key] = math.random() > 0.5
    end

    return shuffledMap, keys
end

function getFirstEntry(shuffledMap, keys)
    local firstKey = keys[1]
    return firstKey, shuffledMap[firstKey]
end

function getFirstFiveEntriesShuffled(shuffledMap, keys)
    local firstFiveList = {}
    
    -- Extract the first five key-value pairs into a list
    for i = 1, math.min(5, #keys) do
        local key = keys[i]
        table.insert(firstFiveList, {key = key, value = shuffledMap[key]})
    end

    -- Shuffle the list of key-value pairs
    for i = #firstFiveList, 2, -1 do
        local j = math.random(i)
        firstFiveList[i], firstFiveList[j] = firstFiveList[j], firstFiveList[i]
    end

    -- Create a new table from the shuffled list
    local shuffledFirstFive = {}
    for _, pair in ipairs(firstFiveList) do
        shuffledFirstFive[pair.key] = pair.value
    end

    return shuffledFirstFive
end

return minigame_kunstofweg
