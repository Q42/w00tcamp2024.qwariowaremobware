local stef = {}

local shakeThreshold = 1.5 -- Adjust this threshold based on the desired sensitivity
local shakeCount = 0
local shakesNeeded = 20 -- Number of shakes needed to win

playdate.startAccelerometer()

local gfx <const> = playdate.graphics
local stefImage = gfx.image.new("Minigames/stef/images/stef.png")
assert(stefImage, "Failed to load stef image")

local smots1Img = gfx.image.new("Minigames/stef/images/smots1.png")
assert(smots1Img, "Failed to load smots1 image")
local smotsSprite = gfx.sprite.new(smots1Img)

local stefSprite = gfx.sprite.new(stefImage)
local screenWidth, screenHeight = playdate.display.getSize()
local imageWidth, imageHeight = stefImage:getSize()
local startY = screenHeight + imageHeight / 2
local endY = screenHeight - screenHeight / 4
local returnY = screenHeight

stefSprite:moveTo(screenWidth / 2, startY)
stefSprite:add()

local animationTimer = playdate.timer.new(2000, startY, endY, playdate.easingFunctions.linear)
animationTimer.updateCallback = function(timer)
  local y = timer.value
  stefSprite:moveTo(screenWidth / 2, y)
end
animationTimer.timerEndedCallback = function(timer)
  local returnTimer = playdate.timer.new(2000, endY, returnY, playdate.easingFunctions.linear)
  returnTimer.updateCallback = function(timer)
    local y = timer.value
    stefSprite:moveTo(screenWidth / 2, y)
  end
  returnTimer.timerEndedCallback = function(timer)
    -- gfx.sprite.setBackgroundDrawingCallback(
    --   function(x, y, width, height)
    --     stefImage:draw(0, 0)
    --   end
    -- )
    -- stefSprite:remove()
  end
end

function stef.update()
  gfx.sprite.update()
  playdate.timer.updateTimers()
  -- Get the accelerometer data
  local ax, ay, az = playdate.readAccelerometer()

  -- Calculate the magnitude of the acceleration vector
  local magnitude = math.sqrt(ax * ax + ay * ay + az * az)

  -- Check if the magnitude exceeds the shake threshold
  if magnitude > shakeThreshold then
    shakeCount = shakeCount + 1
    print("Shake detected! Count: " .. shakeCount)
  end

  -- Check if the player has shaken the device enough to win
  if shakeCount >= shakesNeeded then
    print("You cleaned the head!")
    playdate.stopAccelerometer()
    return 1 -- Return 1 to indicate that the player has won
  end
end

return stef