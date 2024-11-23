local stef = {}

local shakeThreshold = 1.5 -- Adjust this threshold based on the desired sensitivity
local shakeCount = 0
local shakesNeeded = 20 -- Number of shakes needed to win

playdate.startAccelerometer()
local screenWidth, screenHeight = playdate.display.getSize()

mobware.timer.setPosition("bottomLeft")
mobware.timer.sprite:add()

local gfx <const> = playdate.graphics
local stefImage = gfx.image.new("Minigames/stef/images/stef.png")
assert(stefImage, "Failed to load stef image")

local smots1Img = gfx.image.new("Minigames/stef/images/smots1_dt.png")
assert(smots1Img, "Failed to load smots1 image")
local smots1Sprite = gfx.sprite.new(smots1Img)

local smots2Img = gfx.image.new("Minigames/stef/images/smots2_dt.png")
assert(smots2Img, "Failed to load smots2 image")
local smots2Sprite = gfx.sprite.new(smots2Img)

local headerImg = gfx.image.new("Minigames/stef/images/header.png")
assert(headerImg, "Failed to load header image")
local headerSprite = gfx.sprite.new(headerImg)

local shakeitOff = gfx.imagetable.new("Minigames/stef/images/shakeitoff")
assert(shakeitOff, "Failed to load shakeitoff image")
local shakeitoffSprite = AnimatedSprite.new(shakeitOff)


local stefSprite = gfx.sprite.new(stefImage)
local imageWidth, imageHeight = stefImage:getSize()
local startY = screenHeight + imageHeight / 2
local endY = screenHeight - screenHeight / 4
local returnY = screenHeight

stefSprite:moveTo(screenWidth / 2, startY)
stefSprite:add()

local gamestate = "intro"
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
    smots1Sprite:moveTo(screenWidth / 2 + 10, screenHeight / 2 + 10)
    smots1Sprite:add()
    smots2Sprite:moveTo(screenWidth / 2 -50, screenHeight / 2 + 10)
    smots2Sprite:add()
    headerSprite:moveTo(screenWidth / 2, 50)
    headerSprite:add()

    shakeitoffSprite:addState("shake", 1, shakeitOff:getLength(), {tickStep = 4}, true)
    shakeitoffSprite:moveTo(screenWidth / 2, screenHeight / 2)
    shakeitoffSprite:setZIndex(1000)
    shakeitoffSprite:changeState("shake")
    shakeitoffSprite:playAnimation()
    shakeitoffSprite:moveTo(screenWidth / 2, screenHeight / 2)
    shakeitoffSprite:add()


    gamestate = "playing"
    -- gfx.sprite.setBackgroundDrawingCallback(
    --   function(x, y, width, height)
    --     stefImage:draw(0, 0)
    --   end
    -- )
    -- stefSprite:remove()
  end
end

local MAX_GAME_TIME = 9 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
game_timer.timerEndedCallback = function() gamestate = "defeat" end

function stef.update()
  if gamestate == "playing" then
    mobware.print("Er zit smots op mn hoofd!", screenWidth/2, 50)
  end
  gfx.sprite.update()
  playdate.timer.updateTimers()

	mobware.timer.setGameProgress(game_timer.value)
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
    smots1Sprite:remove()
    smots2Sprite:remove()
    headerSprite:remove()
    mobware.print("Schoon!", screenWidth/2, 50)
    playdate.wait(2000)
    
    print("You cleaned the head!")
    playdate.stopAccelerometer()
    return 1 -- Return 1 to indicate that the player has won
  end

  if gamestate == "defeat" then
    headerSprite:remove()
    mobware.print("duurt te lang!")
    playdate.wait(2000)
    return 0
  end
end

return stef