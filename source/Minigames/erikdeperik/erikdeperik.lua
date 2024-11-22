local erikdeperik = { }

local gfx <const> = playdate.graphics

local SPRITE_START_Y = 150
local SPRITE_START_X = 50
local SPRITE_END_X = 346
mobware.crankIndicator.start()

-- local smileWidth, smileHeight = 36, 36
-- local smileImage = gfx.image.new(smileWidth, smileHeight)
-- -- Pushing our new image to the graphics context, so everything
-- -- drawn will be drawn directly to the image
-- gfx.pushContext(smileImage)
--     -- => Indentation not required, but helps organize things!
--     gfx.setColor(gfx.kColorWhite)
--     -- Coordinates are based on the image being drawn into
--     -- (e.g. (x=0, y=0) refers to the top left of the image)
--     gfx.fillCircleInRect(0, 0, smileWidth, smileHeight)
--     gfx.setColor(gfx.kColorBlack)
--     -- Drawing the eyes
--     gfx.fillCircleAtPoint(11, 13, 3)
--     gfx.fillCircleAtPoint(25, 13, 3)
--     -- Drawing the mouth
--     gfx.setLineWidth(3
--     gfx.drawArc(smileWidth/2, smileHeight/2, 11, 115, 245)
--     -- Drawing the outline
--     gfx.setLineWidth(2)
--     gfx.setStrokeLocation(gfx.kStrokeInside)
--     gfx.drawCircleInRect(0, 0, smileWidth, smileHeight)
-- -- Popping context to stop drawing to image
-- gfx.popContext()

local backgroundImage = gfx.image.new( "Minigames/erikdeperik/images/jira_bg.png" )
assert(backgroundImage, "Failed to load background image")
gfx.sprite.setBackgroundDrawingCallback(
  function (x, y, width, height)
    backgroundImage:draw(0, 0)
  end
)
local ticketImage = gfx.image.new("Minigames/erikdeperik/images/ticket.png")
local pd_sprite = gfx.sprite.new(ticketImage)
pd_sprite:moveTo(SPRITE_START_X, SPRITE_START_Y)
pd_sprite:add()
pd_sprite.frame = 1
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 16
pd_sprite.done = false

-- start timer 
local MAX_GAME_TIME = 5 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end )
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate

function erikdeperik.update()
	-- update sprite animations
	gfx.sprite.update() -- updates all sprites
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	-- Win condition:
	if pd_sprite.done == true then
		playdate.wait(1000)	-- Pause 1s before ending the minigame
		return 1
	end

	-- Loss condition
	if gamestate == "defeat" then 
		-- if player has lost, show images of playdate running out of power then exit
		local playdate_low_battery_image = gfx.image.new("Minigames/hello_world/images/playdate_low_battery")
		local low_battery = gfx.sprite.new(playdate_low_battery_image)
		low_battery:moveTo(150, 75)
		low_battery:addSprite()
		gfx.sprite.update() 

		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		return 0 -- returning 0 to indicate that the player has lost and exit the minigame 
	end
end


function erikdeperik.cranked(change, acceleratedChange)
  -- display crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end

  local cranks_needed = 7
  local degrees_needed = cranks_needed * 360

	-- Increment animation counter:
	pd_sprite.crank_counter = pd_sprite.crank_counter + change

  -- calculate the movement speed
  local total_distance = SPRITE_END_X - SPRITE_START_X
  local move_speed = total_distance / degrees_needed

  local sprite_x_pos = SPRITE_START_X + pd_sprite.crank_counter * move_speed

  print("Change: ", change, "Crank Counter: ", pd_sprite.crank_counter, "Frame: ", pd_sprite.frame, "pos: ", sprite_x_pos)
  -- Move the sprite
  pd_sprite:moveTo(sprite_x_pos, SPRITE_START_Y)

  -- We've cranked as far as we should crunk, you won!
  if sprite_x_pos >= SPRITE_END_X then
    pd_sprite.done = true
  end
end

return erikdeperik
