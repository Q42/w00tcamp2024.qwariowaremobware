local stef = {}

local shakeThreshold = 1.5 -- Adjust this threshold based on the desired sensitivity
local shakeCount = 0
local shakesNeeded = 20 -- Number of shakes needed to win

playdate.startAccelerometer()

function stef.update()
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