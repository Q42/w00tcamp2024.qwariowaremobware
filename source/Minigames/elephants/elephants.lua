local elephants = {}

local gfx <const> = playdate.graphics
local snd = playdate.sound
math.randomseed(playdate.getSecondsSinceEpoch())
local state = "playing"
local MIC_THRESHOLD = 0.65 -- Adjust this threshold based on the desired sensitivity

mobware.MicIndicator.start()

-- Initialize the microphone
playdate.sound.micinput.startListening()

mobware.timer.setPosition("bottomLeft")
mobware.timer.sprite:add()

local MAX_GAME_TIME = 12 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 0.0, 1.0)
game_timer.timerEndedCallback = function() gamestate = "defeat" end

local htpbgmusic = snd.sampleplayer.new("Minigames/elephants/sounds/htpbgmusic")
htpbgmusic:play(0)

local ollieImage = gfx.image.new("Minigames/elephants/images/ellie.png")
local ollieSprite = gfx.sprite.new(ollieImage)
ollieSprite:moveTo(330, 180)
ollieSprite:add()

local bgImage = gfx.image.new("Minigames/elephants/images/bg.png")
gfx.sprite.setBackgroundDrawingCallback(
  function (x, y, width, height)
    bgImage:draw(0, 0)
  end
)

local elephantImage = gfx.image.new("Minigames/elephants/images/ellie.png")
local elephantSprites = {}
local elephantTimers = {}
local numElephants = 5
local allTimersDone = false
local finalSoundPlayed = false

for i = 1, numElephants do
  local xOffset = math.random(-20, 20) -- Random x offset between -20 and 20
  local yOffset = math.random(-10, 10) -- Random y offset between -10 and 10
  local elephantSprite = gfx.sprite.new(elephantImage)
  elephantSprite:moveTo(500 + (i * 75) + xOffset, 180 + yOffset)
  local elephantSprite = gfx.sprite.new(elephantImage)
  elephantSprite:moveTo(500 + (i * 75) + xOffset, 180 + yOffset)
  elephantSprite:add()
  table.insert(elephantSprites, elephantSprite)
end

local function drawText(text, x, y)
    local textWidth, textHeight = gfx.getTextSize(text)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, textWidth + 10, textHeight + 10)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(text, x, y)
end

local ollieAnimationTimer = nil
function elephants.update()
	-- updates all sprites
	gfx.sprite.update()
  -- Get the current microphone input level
	playdate.frameTimer.updateTimers()
	-- update timer
	mobware.timer.setGameProgress(game_timer.value)
  local micLevel = playdate.sound.micinput.getLevel()
  print("mic level: " .. micLevel)
  -- Check if the microphone input level is above the threshold
  if micLevel > MIC_THRESHOLD then
    state = "done"    
    elephants.PlayYay()
    print("You scared the elephants away!")
    drawText("You scared the elephants away!", 0, 0)
    playdate.sound.micinput.stopListening()
    -- Start the animation timer to move the ollie sprite to the right
    local startX, startY = ollieSprite:getPosition()
    local endX = 500 -- Move to the right side of the screen
    local duration = 2000 -- 1 second

    ollieAnimationTimer = playdate.timer.new(duration, startX, endX, playdate.easingFunctions.linear)
    ollieAnimationTimer.updateCallback = function(timer)
      local x = timer.value
      ollieSprite:moveTo(x, startY)
    end
  end
  if state == "done" and ollieAnimationTimer and ollieAnimationTimer.timeLeft == 0 then
    return 1
  end

  if micLevel > 0.1 then
    mobware.MicIndicator.stop()
  end
  if gamestate == "defeat" then
    elephants.PlayElephant()
    print("The elephants are still here!")
    playdate.sound.micinput.stopListening()
    
    drawText("The elephants are attacking!", 0, 0)
    local allTimersDone = true
    -- Animate the elephant sprites moving to the left using timers
    for i, elephantSprite in ipairs(elephantSprites) do
      if not elephantTimers[i] then
        local startX, startY = elephantSprite:getPosition()
        local endX = -100 -- Move off the left side of the screen
        local duration = 2000 -- 2 seconds

        elephantTimers[i] = playdate.timer.new(duration, startX, endX, playdate.easingFunctions.linear)
        elephantTimers[i].updateCallback = function(timer)
          local x = timer.value
          elephantSprite:moveTo(x, startY)
        end
      end
      if elephantTimers[i] and elephantTimers[i].timeLeft > 0 then
        allTimersDone = false
      end
      -- Check for collision with ollieSprite
      if ollieSprite:overlappingSprites()[elephantSprite] then
        ollieSprite:setVisible(false)
      end
    end
    -- Animate ollie moving to the left
    if not ollieAnimationTimer then
      local startX, startY = ollieSprite:getPosition()
      local endX = -100 -- Move off the left side of the screen
      local duration = 2000 -- 2 seconds

      ollieAnimationTimer = playdate.timer.new(duration, startX, endX, playdate.easingFunctions.linear)
      ollieAnimationTimer.updateCallback = function(timer)
        local x = timer.value
        ollieSprite:moveTo(x, startY)
      end
    end
    if allTimersDone and ollieAnimationTimer and ollieAnimationTimer.timeLeft == 0 then
      return 0
    end
  end

  -- local barHeight = micLevel * 200 -- Scale the bar height based on the mic level
  -- gfx.fillRect(10, 240 - barHeight, 20, barHeight) -- Draw the bar on the left side of the screen

    -- Shake the ollie sprite based on mic level
    -- TODO: SHAKY BAKY
    local shakeMagnitude = math.floor(micLevel * 10) -- Adjust the multiplier to control the shake intensity

    local shakeX = math.random(-shakeMagnitude, shakeMagnitude)
    local shakeY = math.random(-shakeMagnitude, shakeMagnitude)
    ollieSprite:moveTo(330 + shakeX, 180 + shakeY)
end

function elephants.cleanup()
  -- Stop listening to the microphone when the game is done
  playdate.sound.micinput.stopListening()
end

function elephants.PlayElephant()
  if finalSoundPlayed == false then
    finalSoundPlayed = true
    local elephants = snd.sampleplayer.new("Minigames/elephants/sounds/elephant")
    elephants:play(1)
  end
end

function elephants.PlayYay()
  if finalSoundPlayed == false then
    finalSoundPlayed = true
    local yay = snd.sampleplayer.new("Minigames/elephants/sounds/yay")
    yay:play(1)
  end
end

return elephants