local touchy = {}
local graphics <const> = playdate.graphics
-- -- Import the animatedImage class
local button_gif = AnimatedImage.new("Minigames/touchy/images/button_gif", {delay = 200, loop = true, first = 1, last = 5})
local explosion_gif = AnimatedImage.new("Minigames/touchy/images/explosion", { delay = 100, loop = false, first = 1, last = 9 })
local mission_failed = graphics.image.new("Minigames/touchy/images/mission_failed.png")
local mission_passed = graphics.image.new("Minigames/touchy/images/mission_passed.png")

assert(button_gif ~= nil, "Error: button_gif failed to load")
assert(explosion_gif ~= nil, "Error: explosion_gif failed to load")
assert(mission_failed ~= nil, "Error: mission_failed failed to load")
assert(mission_passed ~= nil, "Error: mission_passed failed to load")

-- Load the explosion sound
local explosion_sound = playdate.sound.sampleplayer.new('Minigames/touchy/sounds/explosion.wav')
local mission_passed_sound = playdate.sound.sampleplayer.new('Minigames/touchy/sounds/mission_passed.wav')
local mission_failed_sound = playdate.sound.sampleplayer.new('Minigames/touchy/sounds/mission_failed.wav')

local explosion_playing = false

local buttonHasBeenPressed = false

local function isAButtonPressed()
    return playdate.buttonIsPressed(playdate.kButtonA)
end

local function isWrongButtonPressed()
    local bButton = playdate.buttonIsPressed(playdate.kButtonB)
    local upButton = playdate.buttonIsPressed(playdate.kButtonUp)
    local downButton = playdate.buttonIsPressed(playdate.kButtonDown)
    local leftButton = playdate.buttonIsPressed(playdate.kButtonLeft)
    local rightButton = playdate.buttonIsPressed(playdate.kButtonRight)

    return bButton or upButton or downButton or leftButton or rightButton
end

local gamestate = "playing"
-- start timer

local MAX_GAME_TIME = 5 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20, function() gamestate = "mission_failed" end)
--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate

-- Scale factor for the explosion gif
local explosion_scale = 2
local explosion_offset_x = 20
local explosion_offset_y = -15

function touchy.update()
    -- -- Update the frameTimer, so that the game stops after x seconds
    playdate.frameTimer.updateTimers()
    playdate.frameTimer.updateTimers()

    if isAButtonPressed() and not buttonHasBeenPressed then
        buttonHasBeenPressed = true
        gamestate = "mission_passed"
        mission_passed_sound:play()

        button_gif:reset()
        button_gif:setPaused(true)
    end
    if isWrongButtonPressed() and not buttonHasBeenPressed then
        buttonHasBeenPressed = true
        gamestate = "mission_failed"
        explosion_sound:play()

        button_gif:reset()
        explosion_gif:reset()
        button_gif:setPaused(true)
        explosion_gif:setPaused(false)
        explosion_playing = true
    end

    -- graphics.clear(graphics.kColorWhite)

    if explosion_playing then
        explosion_gif:drawScaled(explosion_offset_x, explosion_offset_y, explosion_scale)
        if explosion_gif:getFrame() == 9 then
            explosion_playing = false
        end
    else
        button_gif:draw(0, 0)
    end

    if not explosion_playing and gamestate == "mission_failed" then
        graphics.clear(graphics.kColorWhite)
        mission_failed_sound:play()
        mission_failed:draw(0, 0)
        playdate.wait(2000)
        return 0
    end

    if buttonHasBeenPressed and gamestate == "mission_passed" then
        graphics.clear(graphics.kColorWhite)
        mission_passed_sound:play()
        mission_passed:draw(0, 0)
        playdate.wait(2000)
        return 1
    end
end
return touchy