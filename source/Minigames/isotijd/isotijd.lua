
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

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local isotijd = {}

--> Initialize music / sound effects

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'start'

-- start timer	 
local MAX_GAME_TIME = 6 -- define the time at 20 fps that the game will run before setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
	game_timer.timerEndedCallback = function() gamestate = "timeUp" end
	game_timer.updateCallback = function() mobware.timer.setGameProgress(game_timer.value) end


local stickitSound = snd.sampleplayer.new("Minigames/isotijd/sounds/stickit.wav")
local  scenario, randomChance
local hits = 0

function isotijd.setUp()
    print("setUp called.")
	local bgPath = "Minigames/isotijd/images/isobg"
	local background_image = gfx.image.new(bgPath)
	local background_sprite = gfx.sprite.new(background_image)
	background_sprite:moveTo(200, 120)
	background_sprite:add()

	local randomChance = math.random()
	if randomChance > 0.6 then
		scenario = 1
	elseif randomChance > 0.3 and randomChance < 0.6 then
		scenario = 2
	else
		scenario = 3
	end

	mobware.AbuttonIndicator:start()

end

isotijd.setUp()

function isotijd.update()
	local spritePath = "Minigames/isotijd/images/scen" .. scenario .. hits .. ".png"
	local spriteImage = gfx.image.new(spritePath)
	local spriteSprite = gfx.sprite.new(spriteImage)
	spriteSprite:moveTo(200, 120)
	spriteSprite:add()
	-- updates all sprites
	gfx.sprite.update() 
	mobware.timer.sprite:add()



	-- update timer
	playdate.frameTimer.updateTimers()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		if scenario == 1 then
			if hits == 5 then
				gamestate = 'victory'
			else 
			stickitSound:play(1)
			hits = hits + 1
			end
		elseif scenario == 2 then
			if hits == 9 then
				gamestate = 'victory'
			else
				stickitSound:play(1)
				hits = hits + 1
			end
		else
			if hits == 11 then
				gamestate = 'victory'
			else
				stickitSound:play(1)
				hits = hits + 1
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

	elseif gamestate == 'timeUp' then
		mobware.print("TE LAAT")
		local telaatSound = snd.sampleplayer.new("Minigames/isotijd/sounds/telaat.wav")
		telaatSound:play(1)
		playdate.wait(2000)	
		return 0
	end
end

return isotijd
