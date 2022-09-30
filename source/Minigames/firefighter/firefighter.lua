-- Define minigame package
local firefighter = {}
--[[
import "Minigames/firefighter/CoreLibs/math"
import "Minigames/firefighter/CoreLibs/graphics"
import "Minigames/firefighter/CoreLibs/ui"
import "Minigames/firefighter/CoreLibs/timer"
import "Minigames/firefighter/CoreLibs/object"
]]

local gfx <const> = playdate.graphics

local gamestate = "start"
pant = gfx.image.new("Minigames/firefighter/pant")
pantcut = gfx.image.new("Minigames/firefighter/pantcut")

-- < Drew's code >
local GAME_TIME_LIMIT = 10 -- player has 8 seconds at 20fps
local game_timer = playdate.frameTimer.new( GAME_TIME_LIMIT * 20, function() gamestate = "defeat" end ) --runs for 6 seconds at 20fps, and 3 seconds at 40fps

local fire_imagetable = gfx.imagetable.new('Minigames/firefighter/fire')
local fire_small_imagetable = gfx.imagetable.new('Minigames/firefighter/fire_small')
local fire = gfx.image.new("Minigames/firefighter/fire")
local fire_hp = 10
--local fire_frame_num = 1

-- ADDED BY DREW
function newflame(x,y, hp)
	local new = {}
	new.x = x
	new.y = y
	new.hp = hp
	new.frame = math.random(fire_imagetable:getLength())

	table.insert(flames, new)
end

flames = {}
for i = 1, 5 do
	-- have flames bewween 120 - 360
	--newflame(80 + 40 * i, 162, fire_hp)
	newflame(120 + 40 * i, 200, fire_hp)
end
-- < end Drew's code >

width = playdate.display.getWidth()
height = playdate.display.getHeight()

dropletbaserad = 2

droplets = {}

gravity = 0.25

ppangle = 180

pppower = 10

ppspread = 1
ppanglespread = 0.5

ppflow = 2

ppx = 90
ppy = 90
ppgirth = 32
pplength = 64
--id say that's average

headx = 0
heady = 0

pantxoff = 0

lines = {}

local line = {}
line.x1 = 200
line.y1 = 240-32
line.x2 = 400-32
line.y2 = 120
table.insert(lines,line)
local line = {}
line.x1 = 400-32
line.y1 = 120
line.x2 = 400
line.y2 = 0
table.insert(lines,line)

playdate.startAccelerometer()
accel = {}

--mobware.crankIndicator.start()

function firefighter.update()
	
	-- update timer
	playdate.frameTimer.updateTimers()
	
	time = playdate.getTime()
	epoch = playdate.getSecondsSinceEpoch()

	accel[1],accel[2] = playdate.readAccelerometer()
	--printTable(accel)

	accel[2] = math.clamp(0.1,accel[2],2)

	ppangle = playdate.getCrankPosition() - 90

	local buffa = 10
	upangle = -90 + buffa
	downangle = 90 - buffa

	--if(ppangle > 180)then
	--	ppangle = upangle
	--end

	--ppangle = math.clamp(upangle,ppangle,downangle)

	if(playdate.isCrankDocked() == true)then
		ppangle = 90
	end

	ppanglerad = math.rad(ppangle)
	
	headx = ppx + (math.cos(ppanglerad) * pplength)
	heady = ppy + (math.sin(ppanglerad) * pplength)

	-- Drew: commenting out loop so that you're always ... spraying 
	--if(playdate.buttonIsPressed(playdate.kButtonB))then
		for i=1, ppflow do
			local as = (math.random() - 0.5) * ppanglespread
			local as = 0
			local velx = math.cos(ppanglerad + as) * pppower
			local vely = math.sin(ppanglerad + as) * pppower
			--random size
			local dropradius = dropletbaserad + math.random() * 4

			velx += (math.random() - 0.5) * ppspread
			vely += (math.random() - 0.5) * ppspread
		
			newdrop(headx,heady,velx,vely,dropradius)
		end
	--end

	physics()

	draw()
	
	if gamestate == "start" then
		mobware.print("extinguish!", 160, 60)
		if game_timer.frame > 50 then 
			--mobware.crankIndicator.stop()
			gamestate = "play" 
		end
	
	elseif gamestate == "victory" then
		playdate.stopAccelerometer()
		mobware.print("you're a hero!")
		playdate.wait(1500)
		return 1
		
	elseif gamestate == "defeat" then
		playdate.stopAccelerometer()
		return 0
	end
	
end

function physics()
	for i = 1, #droplets do
		local drop = droplets[i]

		drop.vx += gravity * accel[1]
		drop.vy += gravity * accel[2]

		drop.x += drop.vx
		drop.y += drop.vy

		for i = 1, #lines do
		local line = lines[i]
		local closest = closestpointonline(line.x1,line.y1,line.x2,line.y2,drop.x,drop.y)
		local dist = distance(drop.x,drop.y,closest[1],closest[2])
		local distto1 = squaredDistance(drop.x,drop.y,line.x1,line.y1)
		local distto2 = squaredDistance(drop.x,drop.y,line.x2,line.y2)
		local linelength = squaredDistance(line.x1,line.y1,line.x2,line.y2) + (drop.r * drop.r) + 10
		if dist < drop.r and distto1 < linelength and distto2 < linelength then
			--hit(i,closest[1],closest[2])
		end
		end
	end

	i = 1
	while i < #droplets do
		local drop = droplets[i]
		
		--if (drop.y > 300) then
		--	table.remove(droplets,i)
		if drop.y > 240 then
			_collision = check_collision(drop.x, drop.y)
			if _collision == 1 then 
				print("collision!")
			end

			table.remove(droplets,i)
			
		else
			i += 1
		end

	end
end

function draw()
	gfx.clear(gfx.kColorWhite)

	gfx.pushContext(pant)
		playdate.graphics.setPattern({ 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 })
		for i=1, #droplets do
			local drop = droplets[i]
			if(drop.x < 100)then
				gfx.fillCircleAtPoint(drop.x,drop.y,drop.r)
			end
		end
	gfx.popContext()

	pant:draw(pantxoff,0)
	pantcut:draw(pantxoff,0)

	if(playdate.isCrankDocked() == false)then
		drawdroplets()
	end
	
	drawflames()

	gfx.setLineWidth(2)
	setBlack()
	--[[
	for i=1, #lines do
		local line = lines[i]
		gfx.drawLine(line.x1,line.y1,line.x2,line.y2)
	end
	]]

	if(playdate.isCrankDocked() == false)then
		drawpp()
	end

end

function drawpp()
	setBlack()
	gfx.setLineWidth(ppgirth)
	playdate.graphics.setLineCapStyle(playdate.graphics.kLineCapStyleSquare)
	gfx.drawLine(ppx,ppy,headx,heady)
end

function drawdroplets()
	setBlack()
	for i=1, #droplets do
		local drop = droplets[i]
		gfx.fillCircleAtPoint(drop.x,drop.y,drop.r+1)
	end

	setWhite()
	for i=1, #droplets do
		local drop = droplets[i]
		gfx.fillCircleAtPoint(drop.x,drop.y,drop.r)
	end
end

-- ADDED BY DREW
function drawflames()
	for i=1, #flames do
		local flame = flames[i]
		flame.frame += 1
		if flame.frame  > fire_imagetable:getLength() then flame.frame = 1 end
		if flame.hp > fire_hp / 2 then
			--fire_imagetable:getImage(flame.frame):drawCentered(flame.x, flame.y)
			fire_imagetable:getImage(flame.frame):drawCentered(flame.x, 200)
		else
			fire_small_imagetable:getImage(flame.frame):drawCentered(flame.x, 220)
		end
	end
end

function check_collision(drop_x, drop_y)
	-- check if drop overlaps with flame
	-- if it does, reduce HP of flame and remove droplet
	
	for i=1, #flames do
		if math.abs(drop_x - flames[i].x) < 10 then 
			flames[i].hp -= 1
			if flames[i].hp < 0 then 
				print("extinguished!")
				table.remove(flames,i)
			if #flames <= 0 then gamestate = "victory" end
			end
			return 1 
		end
	end
	
	return nil
	
end

function newdrop(x,y,vx,vy,r)
	local new = {}
	new.x = x
	new.y = y
	new.vx = vx
	new.vy = vy
	new.r = r

	table.insert(droplets, new)
end


function setBlack()
    gfx.setColor(gfx.kColorBlack)
end

function setWhite()
    gfx.setColor(gfx.kColorWhite)
end

function setClear()
    gfx.setColor(gfx.kColorClear)
end

function remap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function disttoline(ax,ay,bx,by,cx,cy)
	local numer = math.abs((cx-ax)*(-by+ay)+(cy-ay)*(bx-ax))
	local dy = (-by+ay)
	local dx = (bx-ax)
	local denom = math.sqrt((dy*dy)+(dx*dx))
	local dist = numer/denom

	return dist
end

function closestpointonline(x1, y1, x2, y2, x0, y0)
    local A1 = y2 - y1
    local B1 = x1 - x2
    local C1 = (y2 - y1)*x1 + (x1 - x2)*y1
    local C2 = -B1*x0 + A1*y0
    local det = A1*A1 - -B1*B1
    local cx = 0; 
    local cy = 0; 
    if(det ~= 0)then 
        cx = ((A1*C1 - B1*C2)/det)
        cy = ((A1*C2 - -B1*C1)/det)
    else
        cx = x0
        cy = y0
	end
    return {cx,cy}
end

function distance( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

function squaredDistance(x1,y1,x2,y2)
  return (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)
end

function hit(i,px,py)

  local mass = 1
  local ball = droplets[i]
  local ball2 = {}
  ball2.vx = -ball.vx
  ball2.vy = -ball.vy
  ball2.x = px
  ball2.y = py

  local differencex = ball2.x-ball.x
  local differencey = ball2.y-ball.y

  local distance = distance(ball.x,ball.y,ball2.x,ball2.y)

  local normalx = differencex / distance
  local normaly = differencey / distance

  local velocitydeltax = ball.vx-ball2.vx
  local velocitydeltay = ball.vy-ball2.vy

  velocitydelta = math.sqrt(velocitydeltax^2 + velocitydeltay^2)
  --print("vd "..velocitydelta)
  --if(velocitydelta < -0.01 or velocitydelta > 0.01)then
  --for i = 1, #hitsounds do
    --hitsounds[i]:setVolume(remap(velocitydelta,-0.1,0.5,0,1))
  --end
  --hitsounds[math.floor(math.random(1,3))]:play(1)
  --end

  local dot = velocitydeltax * normalx + velocitydeltay * normaly

  if(dot > 0)then
    coefficient = -0.5
    impulseStrength = (1 + coefficient) * dot * (1 / mass + 1 / mass)
    impulsex = impulseStrength * normalx
    impulsey = impulseStrength * normaly
    ball.vx = ball.vx - (impulsex / mass)
    ball.vy = ball.vy - (impulsey / mass)
    ball2.vx = ball2.vx + (impulsex / mass)
    ball2.vy = ball2.vy + (impulsey / mass)
    ball.moving = true
    ball2.moving = true
  end

end
-- Return minigame package
return firefighter