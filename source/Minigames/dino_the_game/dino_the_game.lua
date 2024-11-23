--[[
	Author: Jan van Overbeek

	"Dino the game" Blatent ripoff of the Chrome Dino game for QWarioWare
]]

-- Define name for minigame package
local dino_the_game = {}

local gfx <const> = playdate.graphics

-- Crank indicator prompt
mobware.crankIndicator.start()

-- Make sound
local finish_sound = playdate.sound.sampleplayer.new('Minigames/dino_the_game/sounds/tada.wav')
local internet_startup_sound = playdate.sound.sampleplayer.new('Minigames/dino_the_game/sounds/internet_startup.wav')

-- Initialize graphics
local dino_image_table = gfx.imagetable.new("Minigames/dino_the_game/images/dino")
assert(dino_image_table, "Error loading image table")

-- Load background image
local background_image = gfx.image.new("Minigames/dino_the_game/images/background.png")
assert(background_image, "Error loading background image")

-- Load finish image
local finish_image = gfx.image.new("Minigames/dino_the_game/images/finish.png")
assert(finish_image, "Error loading finish image")

-- Create a sprite for the background
local background_sprite = gfx.sprite.new(background_image)
background_sprite:moveTo(1200, 200)
background_sprite:add()

-- Load cactusses
local cactuses = {
    { image = "Minigames/dino_the_game/images/smoll_cactus.png", x = 400, y = 180, },
    { image = "Minigames/dino_the_game/images/big_cactus.png", x = 800, y = 180, },
    { image = "Minigames/dino_the_game/images/multiple_cactus.png", x = 1300, y = 180 },
    { image = "Minigames/dino_the_game/images/smoll_cactus.png",    x = 1700,  y = 180, }
}
local cactus_sprites = {}

for _, cactus in ipairs(cactuses) do
    local cactus_image = gfx.image.new(cactus.image)
    if cactus_image then
        local cactus_sprite = gfx.sprite.new(cactus_image)
        cactus_sprite:moveTo(cactus.x, cactus.y)
        cactus_sprite:add()
        cactus_sprite:setZIndex(10)
        table.insert(cactus_sprites, { sprite = cactus_sprite, x = cactus.x, y = cactus.y })
    else
        print("Error loading cactus image: " .. cactus.image)
    end
end

local function updateCactus(moveBy)
    if moveBy <= 0 then
        return
    end

    for _, cactus in ipairs(cactus_sprites) do
        cactus.x = cactus.x - moveBy
        cactus.sprite:moveBy(-moveBy, 0)

        -- Make cactus invisible when not in frame
        if cactus.x < -50 or cactus.x > 450 then
            cactus.sprite:setVisible(false)
        else
            cactus.sprite:setVisible(true)
        end
    end
end

local finish_sprite = gfx.sprite.new(finish_image)
local finish_x = 400
local finish_y = 150
finish_sprite:moveTo(finish_x, finish_y) -- 300, 150
finish_sprite:setScale(0.5) -- Scale the sprite to 50% of its original size
finish_sprite:add()
finish_sprite:setVisible(false)

local dino_sprite = AnimatedSprite.new(dino_image_table)
dino_sprite:addState("standing", 1, 2, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
dino_sprite:addState("walking", 3, 4, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
dino_sprite:moveTo(50, 175)

local function doesDinoCollideWithCactus()
    local collisions = dino_sprite:overlappingSprites()

    for i = 1, #collisions do
        local collision = collisions[i]
        for _, cactus in ipairs(cactus_sprites) do
            if collision.other == cactus.sprite then
                return true
            end
        end
    end

    return false;
end

local function jump()

end;

local dino_position = 50;
local endgame = false;
local finished = false;
local finish_position = 400

internet_startup_sound:play()
mobware.BbuttonIndicator.start()

-- Jump variables
local gravity = 0.8
local jump_velocity = -12
local dino_y = 175
local is_jumping = false

local function jump()
    if not is_jumping then
        is_jumping = true
        jump_velocity = -12
    end
end

function dino_the_game.update()
    gfx.sprite.update()
    playdate.frameTimer.updateTimers()

    if doesDinoCollideWithCactus() then
        return 0;
    end

    local crankChange = playdate.getCrankChange()

    updateCactus(crankChange)

    if dino_position >= 1800 and not finished then
        endgame = true
        finish_sprite:setVisible(true)

        if finish_position <= 300 then
            if dino_position >= 2050 then
                finished = true
                finish_sound:play()
                playdate.wait(1300)
                return 1;
            end
        else
            finish_position = finish_position - crankChange
            finish_sprite:moveTo(finish_position, finish_y)
        end
    end

    -- Handle jumping
    if is_jumping then
        dino_y = dino_y + jump_velocity
        jump_velocity = jump_velocity + gravity

        if dino_y >= 175 then
            dino_y = 175
            is_jumping = false
            jump_velocity = 0
        end

        dino_sprite:moveTo(50, dino_y)
    end

    if playdate.buttonJustPressed("b") and not finished then
        if mobware.BbuttonIndicator then
            mobware.BbuttonIndicator.stop()
        end
        print("Jumping")
        jump()
    end

    if crankChange > 0 and not finished then

        if finish_position > 300 then
            background_sprite:moveBy(-crankChange, 0)
        end

        if endgame then
            dino_sprite:moveBy(crankChange, 0)
        end

        if is_jumping then
            dino_sprite:changeState("standing")
        else
            dino_sprite:changeState("walking")
        end

        dino_position = dino_position + crankChange
    else
        dino_sprite:changeState("standing")
    end
end

function dino_the_game.cranked(change, acceleratedChange)
  -- display crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end
end

-- Minigame package should return itself
return dino_the_game