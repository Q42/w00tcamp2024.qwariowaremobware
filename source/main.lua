--[[
	MobWare Minigames

	Author: Andrew Loebach
	loebach@gmail.com

	This main program will reference the Minigames and run the minigames by calling their functions to execute the minigame's logic
]]

-- variables for use with testing/debugging:
-- DEBUG_GAME = "touchy" --> Set "DEBUG_GAME" variable to the name of a minigame and it'll be chosen every time!
--SET_FRAME_RATE = 40 --> as the name implies will set a framerate. Used for testing minigames at various framerates

-- Import CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"
import "CoreLibs/keyboard"
import "CoreLibs/math"
import "CoreLibs/easing"

-- Import supporting libraries
import 'lib/AnimatedSprite' --used to generate animations from spritesheet
import 'lib/AnimatedImage'  --used to generate animations from images
import 'lib/mobware_ui'
import 'lib/mobware_utilities'

-- Import classes
import 'lib/Playdate'

-- Defining gfx as shorthand for playdate graphics API
local gfx <const> = playdate.graphics
local ease <const> = playdate.easingFunctions

--Define local variables to be used outside of the minigames
local previous_game
local GameState
local minigame
local unlockable_game
local is_in_bonus_game_list
local poster_complete_sprite
local games_won = 0
local games_lost = 0
local lose_guage = 0;
local max_lose_guage = 4
local game_start_timer
local the_man_sprite
local poster_complete_sprite

-- generate table of minigames and bonus games
minigame_blocklist = { "hello_world", "minigame_template" }
minigame_list = generate_minigame_list("Minigames/", minigame_blocklist)
local bonus_game_list, unlocked_bonus_games = generate_bonusgame_list("extras/")

-- seed the RNG so that calls to random are always random
local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms, s)

-- initialize fonts
mobware_font_S = gfx.font.new("fonts/Mobware_S")
mobware_font_M = gfx.font.new("fonts/Mobware_M")
mobware_font_L = gfx.font.new("fonts/Mobware_L")
mobware_default_font = mobware_font_M

-- initialize sprite sheets for transitions
local playdate_spritesheet = gfx.imagetable.new("images/playdate_spinning")
local bang_spritesheet = gfx.imagetable.new("images/bang")
local the_man_image_table = gfx.imagetable.new("images/theman")
local poster_complete_image_table = gfx.imagetable.new("images/poster-complete-1")
local eidra_building = gfx.imagetable.new("images/eidra_building")
local q_building = gfx.imagetable.new("images/q_building")

-- initialize music
local main_theme = playdate.sound.fileplayer.new('sounds/main_theme')
local victory_music = playdate.sound.fileplayer.new('sounds/victory_theme')
local defeat_music = playdate.sound.fileplayer.new('sounds/lose_sound')

-- initialize sound effects for menu
local click_sound_1 = playdate.sound.sampleplayer.new('sounds/click1')
local click_sound_2 = playdate.sound.sampleplayer.new('sounds/click2')
local select_sound = playdate.sound.sampleplayer.new('sounds/select')
local swish_sound = playdate.sound.sampleplayer.new('sounds/swish')

local current_frame_rate = 20
function initialize_metagame()
	games_won = 0
	games_lost = 0
	lose_guage = 0
	if game_start_timer ~= nil then
		game_start_timer:remove()
	end
	game_start_timer = nil
	-- if DEBUG_GAME is set then jump right into the action!
	if DEBUG_GAME then
		GameState = 'initialize'
	else
		GameState = 'start'
	end

	-- Set initial FPS to 20, which will gradually increase to a maximum of 40
	time_scaler = 0 --initial value for variable used to speed up game speed over time
	current_frame_rate = SET_FRAME_RATE or math.min(20 + time_scaler, 40)
	playdate.display.setRefreshRate(current_frame_rate)

	gfx.setFont(mobware_default_font)
end

function getRandomGame()
	local game_num = math.random(#minigame_list)
	if game_num == previous_game then
		return getRandomGame()
	else
		previous_game = game_num
		return game_num
	end
end

-- Call function to initialize and start game
initialize_metagame()

local endgameText = ""
local restartTimer
-- Main game loop called every frame
function playdate.update()
	if GameState == 'start' then
		GameState = 'menu' -- go to main game menu
	elseif GameState == 'menu' then
		-- TO-DO: FLESH OUT GAME MENU!

		if menu_initialized then
			gfx.sprite.update()
			playdate.timer:updateTimers()

			mobware.print("QwarioWare")

			if playdate.buttonIsPressed("a") then
				main_theme:stop() -- play music only once
				mobware.AbuttonIndicator.stop()
				menu_initialized = nil
				GameState = 'initialize'
			end
		else
			-- Initialize the game's main menu

			-- set background color to black
			set_black_background()

			-- TO-DO: ONLY SHOW MENU INDICATOR IF THE PLAYER HAS UNLOCKED NEW GOODIES?
			-- add menu indicator, then remove after ~1.2 seconds
			mobware.MenuIndicator.start()
			menu_indicator_timer = playdate.timer.new(1200, function() mobware.MenuIndicator.stop() end)

			mobware.AbuttonIndicator.start()
			main_theme:play() -- play theme only once
			main_theme:setVolume(0.7)
			menu_initialized = 1
		end
	elseif GameState == 'initialize' then
		-- Take a random game from our list of games, or take DEBUG_GAME if defined
		local game_num = getRandomGame()

		minigame_name = DEBUG_GAME or minigame_list[game_num]
		local minigame_path = 'Minigames/' .. minigame_name .. '/' .. minigame_name -- build minigame file path

		-- Clean up graphical environment for minigame
		pcall(minigame_cleanup)

		mobware.timer.reset()
		-- Load minigame package:
		minigame = load_minigame(minigame_path)
		if minigame and minigame.init then
			minigame.init()
		end
		GameState = 'play'
		-- showBuilding()
	elseif GameState == 'play' then
		playdate.timer.updateTimers()
		playdate.frameTimer.updateTimers()

		-- call minigame's update function
		game_result = minigame.update()
		--> minigame update function should return 1 if the player won, and 0 if the player lost
	
		-- move to "transition" gamestate if the minigame is over
		if game_result == 0 or game_result == 1 or game_result == 2 then
			GameState = 'transition'

			-- unload & clean-up minigame
			minigame = nil
			_minigame_env = nil
			pcall(minigame_cleanup)

			-- Set up demon sprite for transition animation
			set_white_background()
			if game_result == 0 then
				onGameLost();
			elseif game_result == 1 then
				onGameWon();
				-- TODO: some kind of win state

				-- increase game speed after each successful minigame:
				time_scaler = time_scaler + 1
			end
			-- animation for the pasting man

			the_man_sprite = AnimatedSprite.new(the_man_image_table)
			the_man_sprite:addState("animate", 1, 4, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			the_man_sprite:moveTo(200, 120)
			the_man_sprite:setZIndex(2)

			the_man_sprite:changeState("animate")

			poster_complete_sprite = AnimatedSprite.new(poster_complete_image_table)
			-- poster_complete_sprite:addState("lose-0", 1, 1, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			-- poster_complete_sprite:addState("lose-1", 2, 2, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			-- poster_complete_sprite:addState("lose-2", 3, 3, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			-- poster_complete_sprite:addState("lose-3", 4, 4, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			-- poster_complete_sprite:addState("lose-4", 5, 5, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)

			poster_complete_sprite:addState("lose-0", 1, 1, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:addState("lose-1", 2, 7, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:addState("lose-2", 8, 13, { tickStep = 2, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:addState("lose-3", 14, 17, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:addState("lose-4", 18, 18, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:addState("start", 1, 1, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
			poster_complete_sprite:moveTo(300, 100)
			poster_complete_sprite:setZIndex(1)

			set_poster_state()

			-- after 2 seconds begin the minigame
			if game_start_timer == nil and lose_guage < max_lose_guage then
				game_start_timer = playdate.frameTimer.performAfterDelay(60, function()
					GameState = 'initialize'
					game_start_timer = nil
				end)
			end

			-- update music speed depending on the player's progress
			local music_rate = math.min(1 + time_scaler / 20, 1.8)
			if SET_FRAME_RATE then music_rate = math.min(SET_FRAME_RATE / 20, 1.8) end

			-- animate demon laughing or crying depending on if the player won the minigame
			if game_result == 0 then
				defeat_music:setRate(music_rate)
				defeat_music:play(1)
				-- TODO replace with the man
				-- demon_sprite:changeState("laughing")
			elseif game_result == 1 then
				victory_music:setRate(music_rate)
				victory_music:play(1) -- play victory theme

				-- TODO replace with the man
				-- demon_sprite:changeState("angry")
			else
				victory_music:setRate(music_rate)
				victory_music:play(1) -- play victory theme
				-- TODO replace with the man
				-- demon_sprite:changeState("throwing")
			end





		end
	elseif GameState == 'transition' then
		-- Play transition animation between minigames

		-- update timer
		playdate.frameTimer.updateTimers()

		-- updates sprites
		gfx.sprite.update()

		-- display UI for transition
		gfx.setFont(mobware_font_S)
		mobware.print("score: " .. getScore(), 15, 20)
		if endgameText ~= "" then
			mobware.print(endgameText, 270, 200)
		end
		gfx.setFont(mobware_default_font) -- reset font to default
	elseif GameState == 'game_over' then
		pcall(minigame_cleanup)
		set_white_background()
		if the_man_sprite then
			the_man_sprite:remove()
			the_man_sprite = nil
		end
		if poster_complete_sprite then
			poster_complete_sprite:remove()
			poster_complete_sprite = nil
		end
		local building = AnimatedSprite.new(eidra_building)
		building:addState("idle", 1, 1, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
		building:addState("hoist", 2, 9, { tickStep = 7, loop = false, nextAnimation = "hoisted" }, true)
		building:addState("hoisted", 9, 9, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
		building:moveTo(200, 120)
		-- building:setZIndex(2)
		building:changeState("hoist")

		endgameText = "You lost!"
		if restartTimer == nil then
			print("starting restart timer")
			restartTimer = playdate.frameTimer.performAfterDelay(120, function()
				initialize_metagame()
				GameState = 'start'
				restartTimer = nil
				endgameText = ""
				if building then
					building:remove()
					building = nil
				end
			end)
		end
		GameState = 'transition'
	elseif GameState == 'game_won' then
		pcall(minigame_cleanup)
		set_white_background()
		if the_man_sprite then
			the_man_sprite:remove()
			the_man_sprite = nil
		end
		if poster_complete_sprite then
			poster_complete_sprite:remove()
			poster_complete_sprite = nil
		end
		mobware.print("you won!", 15, 20)
		local building = AnimatedSprite.new(q_building)
		building:addState("idle", 1, 1, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
		building:addState("hoist", 2, 9, { tickStep = 7, loop = false, nextAnimation = "hoisted" }, true)
		building:addState("hoisted", 9, 9, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
		building:moveTo(200, 120)
		-- building:setZIndex(2)
		building:changeState("hoist")
		if restartTimer == nil then
			print("starting restart timer")
			restartTimer = playdate.frameTimer.performAfterDelay(120, function()
				initialize_metagame()
				GameState = 'start'
				endgameText = ""
				restartTimer = nil
				if building then
					building:remove()
					building = nil
				end
			end)
		end
		endgameText = "You won!"
		GameState = 'transition'
	end

	-- Added for debugging
	-- playdate.drawFPS()
end

-- Callback functions for Playdate inputs:

-- Callback functions for crank
function playdate.cranked(change, acceleratedChange)
	if minigame and minigame.cranked then
		minigame.cranked(change,
			acceleratedChange)
	end
end

function playdate.crankDocked() if minigame and minigame.crankDocked then minigame.crankDocked() end end

function playdate.crankUndocked() if minigame and minigame.crankUndocked then minigame.crankUndocked() end end

-- Callback functions for button presses:
function playdate.AButtonDown() if minigame and minigame.AButtonDown then minigame.AButtonDown() end end

function playdate.AButtonHeld() if minigame and minigame.AButtonHeld then minigame.AButtonHeld() end end

function playdate.AButtonUp() if minigame and minigame.AButtonUp then minigame.AButtonUp() end end

function playdate.BButtonDown() if minigame and minigame.BButtonDown then minigame.BButtonDown() end end

function playdate.BButtonHeld() if minigame and minigame.BButtonHeld then minigame.BButtonHeld() end end

function playdate.BButtonUp() if minigame and minigame.BButtonUp then minigame.BButtonUp() end end

function playdate.downButtonDown() if minigame and minigame.downButtonDown then minigame.downButtonDown() end end

function playdate.downButtonUp() if minigame and minigame.downButtonUp then minigame.downButtonUp() end end

function playdate.leftButtonDown() if minigame and minigame.leftButtonDown then minigame.leftButtonDown() end end

function playdate.leftButtonUp() if minigame and minigame.leftButtonUp then minigame.leftButtonUp() end end

function playdate.rightButtonDown() if minigame and minigame.rightButtonDown then minigame.rightButtonDown() end end

function playdate.rightButtonUp() if minigame and minigame.rightButtonUp then minigame.rightButtonUp() end end

function playdate.upButtonDown() if minigame and minigame.upButtonDown then minigame.upButtonDown() end end

function playdate.upButtonUp() if minigame and minigame.upButtonUp then minigame.upButtonUp() end end

sysMenu = playdate.getSystemMenu()

-- OPTIONAL DEBUGGING MENU OPTION TO CHOOSE MINIGAME:
sysMenu:addOptionsMenuItem("game:", minigame_list,
	function(selected_minigame)
		DEBUG_GAME = selected_minigame
	end
)

-- For debugging
function playdate.keyPressed(key)
	if GameState == 'play' then pcall(minigame.keyPressed, minigame, key) end

	--Debugging code for memory management
	print("Memory used: " .. math.floor(collectgarbage("count")))

	if key == "c" then print('Sprite count: ', gfx.sprite.spriteCount()) end

	-- mute sounds if "m" is pressed
	if key == "m" then
		sounds = playdate.sound.playingSources()
		for _i, sound in ipairs(sounds) do
			print('muting', sound)
			sound:stop()
		end
	end
end

--[[
There currently are 5 states for the poster, lose-0 through lose-4.
lose-0 is q42 poster, lose-4 is eidra poster.
This method sets the correct state for the poster based on the player's score and the max_lose_guage variable.
if the lose_guage is equal to the max_lose_guage, then the player has lost the maximum number of games and the eidra poster is displayed.
else the poster is set to the correct state based on the player's lose_guage, the function interpolates between 0 and 4, so it might skip states if lose state is lower than 4.
]]
function set_poster_state()
	if poster_complete_sprite == nil then
		return
	end

	-- If player has hit max losses, show final poster state
	if lose_guage >= max_lose_guage then
		poster_complete_sprite:changeState("lose-4")
		return
	end

	-- Calculate state based on lose_guage relative to max_lose_guage
	local state = math.floor((lose_guage / max_lose_guage) * 4)
	-- Clamp state between 0 and 4
	state = math.max(0, math.min(4, state))

	poster_complete_sprite:changeState("lose-" .. state)
end

function getScore()
	return games_won - games_lost
end

function onGameWon()
	games_won = games_won + 1

	if lose_guage > 0 then
		lose_guage = lose_guage - 1
	end

	checkEndGame()
end

function onGameLost()
	games_lost = games_lost + 1
	lose_guage = lose_guage + 1

	checkEndGame()
end

function checkEndGame()
	if lose_guage >= max_lose_guage then
		-- after 2000ms
		print("game over!")
		GameState = 'game_over'

	end

	if lose_guage <= 0 and time_scaler >= 10 then
		print("game won!")
		GameState = 'game_won'
	end
end