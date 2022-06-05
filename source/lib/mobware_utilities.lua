-- Utilities for use with Mobware Minigames

local gfx <const> = playdate.graphics

-- generate table of minigames from directories found in the given path
function generate_minigame_list(path)

	print("Generating minigame list:")

	local minigame_list = {}
	local minigame_folders = playdate.file.listFiles(path)
	for _i, minigame in ipairs(minigame_folders) do
		if minigame:sub(#minigame,#minigame) == "/" then -- we check if the file is a directory
			local minigame_name = minigame:sub(1, #minigame-1) -- removing trailing slash to get minigame name
			print("adding", minigame_name, "to minigame list")
			table.insert( minigame_list, minigame_name )
		else
			print("ERROR: ", minigame, "is not a directory. Ommitting from minigame list")
		end
	end
	
	return minigame_list

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
	-- unload minigame
	minigame = nil
	_minigame_env = nil	
	
	-- Reset values for main game and clean up assets/memory
	gfx.clear()
	playdate.display.setRefreshRate( SET_FRAME_RATE or math.min(20 + time_scaler, 40) )
	gfx.setColor(gfx.kColorBlack)
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.sprite.removeAll()
	gfx.setDrawOffset(0, 0)
	playdate.display.setScale(1)

	-- set font used in transition screen if I'm displaying text
	gfx.setFont(mobware_default_font)
	
	-- kill any sounds still playing
	local sounds = playdate.sound.playingSources()
	for _i, sound in ipairs(sounds) do
		sound:stop() 
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

--[[
-- Function to load launcher card specified path
function get_launcher_card(card_path)
	card_path = 
	local launcher_card = gfx.image.new(card_path) 
	return launcher_card
end


function get_small_launcher_card(path)
	-- look for a launcher card from specified path, and reduce the size to fit in our onscreen Playdate sprite
		
	--while launcher.width > 200 or image.height 
	-- Add bonus game launcher sprite
	local status, launcher_image = pcall(get_launcher_card, path) 
	if status == true and launcher_image ~= nil then
		--print('launcher card  at', path, 'loaded successfully')
		local launcher_sprite = gfx.sprite.new(launcher_image)
	else
		-- loads default dog if the minigame's credits sprite can't be loaded
		print('Error: could not locate launcher card at', path)

		local text_width, text_height = gfx.getTextSize(text)		
		local canvas = gfx.image.new( text_width + 32, text_height + 32 )
			
		-- draw bonus game name on canvas, then transform into a sprite
		gfx.lockFocus(canvas)
			mobware.print("bonus game")
		gfx.unlockFocus()
		launcher_sprite:setImage(canvas)	
		
	end
	
	return launcher_sprite

end
]]