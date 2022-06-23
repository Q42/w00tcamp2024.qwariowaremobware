
--[[
	Author: Brandon Dean

	squasher for Mobware Minigames
	
	Drew's Updates: 
		- adding audio & visual touches 
]]

local squasher = {}

import "background"
import "bug"
import "target"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

gamestate = 'play'
local game_counter = 0
local GAME_TIME_LIMIT = 8 -- player has 8 seconds at 20fps

local bugSprite
local targetSprite
local backgroundSprite

function initialize()
	backgroundSprite = Background()
	bugSprite = Bug()
	targetSprite = Target()
end

initialize()

function squasher.update()
	local dt = 1 / playdate.display.getRefreshRate()
	gfx.sprite.update()

	if bugSprite.isSquashed then
		playdate.wait(1000)
		return 1
	end

	if gamestate == "defeat" then
		bugSprite:leave()
		targetSprite:stop()
		--print('isOffScreen', bugSprite:isOffScreen())
		while bugSprite:isOffScreen() do
			playdate.wait(1000)
			return 0
		end
	end

	game_counter = game_counter + dt
	if game_counter >= GAME_TIME_LIMIT then
		gamestate = "defeat"
	end
end

-- Minigame package should return itself
return squasher
