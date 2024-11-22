-- Utilities for use with Mobware Minigames

local gfx <const> = playdate.graphics

-- generate table of minigames from directories found in the given path
function generate_minigame_list(path, minigame_blocklist)

	print("Generating minigame list:")

	local minigame_list = {}
	local minigame_folders = playdate.file.listFiles(path)
	for _i, minigame in ipairs(minigame_folders) do
		if minigame:sub(#minigame,#minigame) == "/" then -- we check if the file is a directory
			local minigame_name = minigame:sub(1, #minigame-1) -- removing trailing slash to get minigame name
			
			-- Check if minigame is in blocklist before adding
			local blocked = false
			for _, blocked_game in ipairs(minigame_blocklist) do
				if minigame_name == blocked_game then
					blocked = true
					break
				end
			end
			
			if not blocked then
				print("adding", minigame_name, "to minigame list")
				table.insert( minigame_list, minigame_name )
			else
				print("skipping blocked minigame:", minigame_name)
			end
		else
			print("ERROR: ", minigame, "is not a directory. Ommitting from minigame list")
		end
	end
	
	return minigame_list

end


-- generate table of bonus games from directories found in the given path
function generate_bonusgame_list(path)

	print("Returning empty bonus game list")
	return {}, {}
	
	

end


-- loads minigame package at location given by 'game_file'
function load_minigame(game_file)
	_minigame_env = {}	-- create new environment for minigame
	setmetatable(_minigame_env, {__index = _G}) --> creating minigame's own namespace
	minigame = _minigame_env
	_minigame_env.import = function(a) playdate.file.run( a, _minigame_env) end -- special import function to allow minigames to import libraries at runtime
	minigame = playdate.file.run(game_file, _minigame_env) --loads minigame package to "game" variable
	return minigame
end


-- clean-up graphics & sound after running a minigame
function minigame_cleanup()

	-- Reset values for main game and clean up assets/memory
	gfx.clear()
	playdate.display.setRefreshRate( SET_FRAME_RATE or math.min(20 + time_scaler, 40) )
	gfx.setColor(gfx.kColorBlack)
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.sprite.removeAll()
	gfx.setDrawOffset(0, 0)
	playdate.display.setScale(1)
	playdate.display.setInverted(false)
	playdate.keyboard.hide()

	-- set font used in transition screen if I'm displaying text
	gfx.setFont(mobware_default_font)
	gfx.setImageDrawMode("copy")
	
	-- kill any sounds still playing
	local sounds = playdate.sound.playingSources()
	for _i, sound in ipairs(sounds) do
		sound:stop() 
	end	
	
	-- kill any timers running?
	for _i, timer in ipairs(playdate.timer.allTimers()) do
		timer:remove()
		timer = nil
	end
	for _i, timer in ipairs(playdate.frameTimer.allTimers()) do
		timer:remove()
		timer = nil
	end
		
	--trigger garbage collection to clear up memory
	--collectgarbage("collect")	
end

function set_black_background()
	-- set background color to black
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400, 240)
	gfx.setBackgroundColor(gfx.kColorBlack)
	gfx.setColor(gfx.kColorWhite)
end

function set_white_background()
	-- set background color to white
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.setColor(gfx.kColorBlack)
end