
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
--import 'Minigames/minigame_template/lib/AnimatedSprite' 

local function ternary(cond, T, F )
    if cond then return T else return F end
end

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

local function printSign(text)
	local text_width, text_height = gfx.getTextSize(text)
	local centered_x = 291 - text_width / 2
	local centered_y = 48 - text_height / 2
	gfx.drawTextAligned(text, centered_x, centered_y, kTextAlignment.left)
end

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local pliepos = {}

--> Initialize music / sound effects
local coin1_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin1')
local coin2_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin2')
local coin3_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin3')
local coin4_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin4')
local coin5_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin5')
local coin6_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin7')
local coin7_noise = playdate.sound.sampleplayer.new('Minigames/pliepos/sounds/coin6')

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

-- start timer	 
local MAX_GAME_TIME = 10 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
-- local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "timeUp" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

local exchangePliepos = 0
local exchangeCareokas = 0
local offeredPliepos = 0
local offeredCareokas = 0

local pliepoSprites
local careokaSprites

local function addPliepoSprite(index)
	local path = "Minigames/pliepos/images/pliepos_coin_p"
	local image = gfx.image.new(path)
	local sprite = gfx.sprite.new(image)

	local x = 32 + math.random(0, 70)
	local y = 120 + math.random(0, 70)

	sprite:setZIndex(y)
	sprite:moveTo(x, y)
	sprite:add()
end

local function addPliepoSprites()
	for i = 1, offeredPliepos do
		addPliepoSprite(i)
	end
end

local function addCareokaSprite()
	local path = "Minigames/pliepos/images/pliepos_coin_c"
	local image = gfx.image.new(path)
	local sprite = gfx.sprite.new(image)

	local x = 300 + math.random(-20, 70)
	local y = 110 + math.random(0, 60)

	sprite:setZIndex(y)
	sprite:moveTo(x, y)
	sprite:add()
end

function pliepos.setUp()
    print("setUp called.")

	local bg_path = "Minigames/pliepos/images/pliepos"
	local background_image = gfx.image.new(bg_path)
	local background_sprite = gfx.sprite.new(background_image)
	background_sprite:moveTo(200, 120)
	background_sprite:add()

	do
		-- generate random int between 1 & 4
		local randomInt = math.random(1, 3)
		local randomInt2 = math.random(1, 2)
		-- switch over the random int to play the corresponding sound
		if randomInt == 1 then
			exchangePliepos = 1
			exchangeCareokas = 3
			offeredPliepos = ternary(randomInt2 == 1, 2, 4)
		elseif randomInt == 2 then
			exchangePliepos = 1
			exchangeCareokas = 4
			offeredPliepos = ternary(randomInt2 == 1, 2, 3)
		else 		
			exchangePliepos = 2
			exchangeCareokas = 3
			offeredPliepos = ternary(randomInt2 == 1, 2, 4)
		end

		addPliepoSprites()
	end

	mobware.AbuttonIndicator.start()
	mobware.BbuttonIndicator.start()
end

pliepos.setUp()

function pliepos.update()
	-- updates all sprites
	gfx.sprite.update() 

	do
		local message = string.format("%dP = %dC", exchangePliepos, exchangeCareokas)
		print(message)
		print("some euqla", exchangePliepos, exchangeCareokas)
		printSign(message)
		-- printSign("vert")
	end

	-- update timer
	playdate.frameTimer.updateTimers()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		offeredCareokas += 1
		addCareokaSprite()
		print("offeredCareokas", offeredCareokas)		

		-- play random coin noise 
		local randomInt = math.random(1, 7)
		if randomInt == 1 then
			coin1_noise:play()
		elseif randomInt == 2 then
			coin2_noise:play()
		elseif randomInt == 3 then
			coin3_noise:play()
		elseif randomInt == 4 then
			coin4_noise:play()
		elseif randomInt == 5 then
			coin5_noise:play()
		elseif randomInt == 6 then
			coin6_noise:play()
		else
			coin7_noise:play()
		end
	end

	if playdate.buttonJustPressed(playdate.kButtonB) then
		local expectedCareokas = (offeredPliepos / exchangePliepos) * exchangeCareokas
		print("expected: ", expectedCareokas, "offeredCareokas", offeredCareokas)
		if expectedCareokas == offeredCareokas then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end
	end

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'start' then

	elseif gamestate == 'victory' then
		mobware.AbuttonIndicator.stop()
		mobware.BbuttonIndicator.stop()
		mobware.print("DANKJEWEL",200, 120)
		playdate.wait(2000)
		return 1

	elseif gamestate == 'defeat' then
		mobware.AbuttonIndicator.stop()
		mobware.BbuttonIndicator.stop()
		gfx.sprite.update() 
		mobware.print("FOUT",200, 120)
		playdate.wait(2000)	
		return 0

	elseif gamestate == 'timeUp' then
		mobware.AbuttonIndicator.stop()
		mobware.BbuttonIndicator.stop()
		gfx.sprite.update() 
		local message = string.format("TE LAAT")
		printSign(message)
		playdate.wait(2000)	
		return 0
	end
end

return pliepos
