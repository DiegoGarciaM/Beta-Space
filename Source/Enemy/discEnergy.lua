DiscEnergy = Class{}

local sprite_sheet_bala = love.graphics.newImage('Imagen/SpritesEnemys/Discenergy.png')
local sprite_sheet_explosion = love.graphics.newImage('Imagen/Sprites/Explo-Bullet.png')


function DiscEnergy:init(x, y, player, velocity)
    self.damage = 0
    self.x = x
    self.y = y
	self.sprite = love.graphics.newQuad(0, 0, 40, 40, sprite_sheet_bala:getDimensions())
    self.width = 40
    self.height = 40
    self.anim = Anim(0, 0, 40, 40, 5, 5, 12)
    self.fps = math.random(6, 10)
    self.spriteExplotion = love.graphics.newQuad(0, 0, 25, 25, sprite_sheet_explosion:getDimensions())
    self.destruible = false
    self.explotionAnim = Anim(0, 0, 25, 25, 4, 4, 10)

    local dix = player.x + (player.width/2) - self.x
    local diy = player.y + (player.height/2) - self.y
    local angle = math.atan(diy/dix)
    self.velx = velocity * math.cos(angle)
    self.vely = velocity * math.sin(angle)

    if (player.x + (player.width/2)) < self.x then
        self.velx = -self.velx
        self.vely = -self.vely
    end

end

function DiscEnergy:update(dt)
    self.y = self.y + self.vely * dt 
    self.x = self.x + self.velx * dt

    if self.destruible == true then 
		if 4 == self.explotionAnim:update(dt, self.spriteExplotion) then
			return false
		end
    else
        self.anim:update(dt, self.sprite)
	end
	return true
end

function DiscEnergy:collides(objeto)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > objeto.x + objeto.width or objeto.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > objeto.y + objeto.height or objeto.y > self.y + self.height then
        return false
    end 

    if self.destruible then
        return false
    end
    -- if the above aren't true, they're overlapping
    return true
end

function DiscEnergy:render()
    if self.destruible == false then
		love.graphics.draw(sprite_sheet_bala, self.sprite, self.x, self.y)
	else
		love.graphics.draw(sprite_sheet_explosion, self.spriteExplotion, self.x, self.y, 0, 2, 2)
	end
end