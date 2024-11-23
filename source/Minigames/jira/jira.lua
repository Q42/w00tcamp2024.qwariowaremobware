local jira = { }

local gfx <const> = playdate.graphics

local SPRITE_START_Y = 150
local SPRITE_START_X = 50
local SPRITE_END_X = 346
local CRANKS_NEEDED = 4

mobware.crankIndicator.start()

local backgroundImage = gfx.image.new( "Minigames/jira/images/jira_bg.png" )
assert(backgroundImage, "Failed to load background image")
gfx.sprite.setBackgroundDrawingCallback(
  function (x, y, width, height)
    backgroundImage:draw(0, 0)
  end
)
local ticketImage = gfx.image.new("Minigames/jira/images/ticket.png")
local pd_sprite = gfx.sprite.new(ticketImage)
pd_sprite:moveTo(SPRITE_START_X, SPRITE_START_Y)
pd_sprite:add()
pd_sprite.frame = 1
pd_sprite.crank_counter = 0
pd_sprite.done = false

-- start timer 
local MAX_GAME_TIME = 8 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
game_timer.timerEndedCallback = function() gamestate = "defeat" end
game_timer.updateCallback = function() mobware.timer.setGameProgress(game_timer.value) end


mobware.timer.sprite:add()

function jira.update()
	-- update sprite animations
	gfx.sprite.update() -- updates all sprites
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	-- Win condition:
	if pd_sprite.done == true then
    local playdate_sprint_complete_image = gfx.image.new("Minigames/jira/images/sprint_complete.png")
    local sprint_complete = gfx.sprite.new(playdate_sprint_complete_image)
    sprint_complete:moveTo(200, 120)
    sprint_complete:addSprite()
    gfx.sprite.update()

		playdate.wait(2000)	-- Pause 1s before ending the minigame
		return 1
	end

	-- Loss condition
	if gamestate == "defeat" then 
		-- if player has lost, show images of playdate running out of power then exit
		local playdate_low_battery_image = gfx.image.new("Minigames/jira/images/burndown.png")
		local low_battery = gfx.sprite.new(playdate_low_battery_image)
		low_battery:moveTo(200, 120)
		low_battery:addSprite()
		gfx.sprite.update() 

		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		return 0 -- returning 0 to indicate that the player has lost and exit the minigame 
	end
end


function jira.cranked(change, acceleratedChange)
  -- display crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end

  local degrees_needed = CRANKS_NEEDED * 360

	-- Increment animation counter:
	pd_sprite.crank_counter = pd_sprite.crank_counter + change

  -- calculate the movement speed
  local total_distance = SPRITE_END_X - SPRITE_START_X
  local move_speed = total_distance / degrees_needed

  local sprite_x_pos = SPRITE_START_X + pd_sprite.crank_counter * move_speed

  -- Block moving to the left if the position of the sprite hasn't changed yet
  if sprite_x_pos < SPRITE_START_X then
    sprite_x_pos = SPRITE_START_X
    pd_sprite.crank_counter = 0
  end

  -- Move the sprite
  pd_sprite:moveTo(sprite_x_pos, SPRITE_START_Y)

  -- We've cranked as far as we should crunk, you won!
  if sprite_x_pos >= SPRITE_END_X then
    pd_sprite.done = true
  end
end

return jira
