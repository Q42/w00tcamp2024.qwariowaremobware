
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

local backgroundMusic = snd.sampleplayer.new("Minigames/uurtjefactuurtje/sounds/uurtjefactuurtje")
backgroundMusic:play(0)


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local uurtjefactuurtje = {}

--> Initialize music / sound effects

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

-- start timer	 
local MAX_GAME_TIME = 10 -- define the time at 20 fps that the game will run before setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
	game_timer.timerEndedCallback = function() gamestate = "defeat" end
	game_timer.updateCallback = function() mobware.timer.setGameProgress(game_timer.value) end
-- Background
-- True = Richard, False = Frank 
-- Factuur 
-- True = OK, False = NotOK
local backgroundState = math.random() > 0.5
local factuurState = math.random() > 0.5
local bgPath, factuurPath, factuurSprite, bannerSprite

function uurtjefactuurtje.setUp()

	mobware.AbuttonIndicator.start()
	mobware.BbuttonIndicator.start()
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:moveTo(350, 200)
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:moveTo(75, 200)

	print "uurtje factuurtje setup"
	mobware.timer.setColor("white")
	mobware.timer.sprite:add()


	if backgroundState == true then
	 	bgPath = "Minigames/uurtjefactuurtje/images/bg2" --richard
	else
	 	bgPath = "Minigames/uurtjefactuurtje/images/bg1" --frank
	end

	if factuurState == true then
		factuurPath = "Minigames/uurtjefactuurtje/images/ok" --OK
	else
		factuurPath = "Minigames/uurtjefactuurtje/images/notok" --NOTOK
	end

	local factuurImage = gfx.image.new(factuurPath)
	factuurSprite = gfx.sprite.new(factuurImage)

	local bannerPath = "Minigames/uurtjefactuurtje/images/banner" 
	local bannerImage = gfx.image.new(bannerPath)
	bannerSprite = gfx.sprite.new(bannerImage)


	local background_image = gfx.image.new(bgPath)
	local background_sprite = gfx.sprite.new(background_image)
	background_sprite:moveTo(200, 120)
	background_sprite:add()
end

uurtjefactuurtje.setUp()

function uurtjefactuurtje.update()
	-- updates all sprites
	gfx.sprite.update() 


	factuurSprite:setCenter(0, 0)
	factuurSprite:moveTo(140,73)
	factuurSprite:add()

	bannerSprite:moveTo(200,50)
	bannerSprite:add()

	-- update timer
	playdate.frameTimer.updateTimers()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		if backgroundState == true then
			if factuurState == true then
				gamestate = 'victory'
			else
				gamestate = 'defeat'
			end
		else 
			if factuurState == true then
				gamestate = 'defeat'
			else
				gamestate = 'victory'
			end
		end
	end

	if playdate.buttonJustPressed(playdate.kButtonB) then
		if backgroundState == true then
			if factuurState == true then
				gamestate = 'defeat'
			else
				gamestate = 'victory'
			end
		else 
			if factuurState == true then
				gamestate = 'victory'
			else
				gamestate = 'defeat'
			end
		end
	end

	if gamestate == 'start' then

	elseif gamestate == 'victory' then
		mobware.print("NICE")
		local goedSound = snd.sampleplayer.new("Minigames/minigame_kunstofweg/sounds/nice.wav")
		goedSound:play(1)
		playdate.wait(2000)
		return 1

	elseif gamestate == 'defeat' then
		gfx.sprite.update() 
		mobware.print("DUUR GRAPJE")
		local foutSound = snd.sampleplayer.new("Minigames/uurtjefactuurtje/sounds/duurgrapje.wav")
		foutSound:play(1)
		playdate.wait(2000)	
		return 0

	elseif gamestate == 'timeUp' then
		gfx.sprite.update() 
		mobware.print("TE LAAT")
		local telaatSound = snd.sampleplayer.new("Minigames/uurtjefactuurtje/sounds/telaat.wav")
		telaatSound:play(1)
		playdate.wait(2000)	
		return 0
	end
end

return uurtjefactuurtje
