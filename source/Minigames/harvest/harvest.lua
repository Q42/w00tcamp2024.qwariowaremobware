
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
local harvest = {}

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

local duurtLangSound = playdate.sound.sampleplayer.new('Minigames/harvest/sounds/duurt_te_lang')
local weekendSound = playdate.sound.sampleplayer.new('Minigames/harvest/sounds/weekend')
local ohOhSound = playdate.sound.sampleplayer.new('Minigames/harvest/sounds/oh-oh')

-- start timer	 
local MAX_GAME_TIME = 5 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "timeUp" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

local isFlipped

local aButton = makeCustomButton('a')
local bButton = makeCustomButton('b')

function harvest.setUp()
    print("setUp called.")
	isFlipped = math.random() < 0.5

	local bg_path = "Minigames/harvest/images/harvest-bg"
	local background_image = gfx.image.new(bg_path)
	local background_sprite = gfx.sprite.new(background_image)
	background_sprite:moveTo(200, 120)
	background_sprite:add()

	if isFlipped then
		aButton:moveTo(36 + 72, 240 - 36 - 16)
		bButton:moveTo(364 - 72, 240 - 36 - 16)
	else 
		bButton:moveTo(36 + 72, 240 - 36 - 16)
		aButton:moveTo(364 - 72, 240 - 36 - 16)
	end
end

harvest.setUp()

function harvest.update()
	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

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
		weekendSound:play()
		playdate.wait(2000)
		return 1
	elseif gamestate == 'defeat' then
		gfx.sprite.update() 
		mobware.print("DAT DUURT TE LANG")
		duurtLangSound:play()
		playdate.wait(2000)	
		return 0
	elseif gamestate == 'timeUp' then
		gfx.sprite.update() 
		mobware.print("TE LAAT, JE PL IS BOOS")
		ohOhSound:play()
		playdate.wait(2000)	
		return 0
	end
end

return harvest
