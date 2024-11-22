--[[
	Author: Jan van Overbeek

	"Dino the game" Blatent ripoff of the Chrome Dino game for QWarioWare
]]

-- Define name for minigame package
local dino_the_game = {}

local gfx <const> = playdate.graphics

-- Crank indicator prompt
mobware.crankIndicator.start()

-- Initialize graphics
local dino_image_table = gfx.imagetable.new("Minigames/dino_the_game/images/dino")
assert(dino_image_table, "Error loading image table")

-- Load background image
local background_image = gfx.image.new("Minigames/dino_the_game/images/background.png")
assert(background_image, "Error loading background image")

-- Create a sprite for the background
local background_sprite = gfx.sprite.new(background_image)
background_sprite:moveTo(1200,200)
background_sprite:add()

dino_sprite = AnimatedSprite.new(dino_image_table)
dino_sprite:addState("standing", 1, 2, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
dino_sprite:addState("walking", 3, 4, { tickStep = 3, loop = true, nextAnimation = "idle" }, true)
dino_sprite:moveTo(50, 175)

function dino_the_game.update()
    gfx.sprite.update()
    playdate.frameTimer.updateTimers()
    if playdate.buttonJustPressed("a") then
        -- JUMP
    end

    if playdate.getCrankChange() ~= 0 then
        dino_sprite:changeState("walking")
    else
        dino_sprite:changeState("standing")
    end
end

-- Minigame package should return itself
return dino_the_game