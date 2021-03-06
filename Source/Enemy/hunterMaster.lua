HunterMaster = Class{}
--Quiere que le tengas miedo y lo va ha hacer

local sprite_sheet_hunter = love.graphics.newImage('Imagen/SpritesEnemys/Hunter-1.png')
local sprite_sheet_explosion = love.graphics.newImage('Imagen/Sprites/Explo-Bullet.png')

local idleState = 0
local avoidBalasState = 1
local avoidCornerState = 2
local kamikazeState = 3

function HunterMaster:init(x, y, player, spacex, spacey, velocity)
    self.clase = 'hunter'
    self.hp = 16
	self.x = x
    self.y = y
	self.width = 58
    self.height = 40
    self.spacex = spacex
    self.spacey = spacey
    self.velocity = velocity
	self.sprite = love.graphics.newQuad(0, 0, 58, 40, sprite_sheet_hunter:getDimensions())
	self.sprite_ex = love.graphics.newQuad(0, 0, 25, 25, sprite_sheet_explosion:getDimensions())
    self.fps = love.math.random(6, 10)
    self.newx = (self.spacex - self.width) * (math.random(10,90)/100)
    self.newy = (self.spacey - self.height) * (math.random(10,70)/100)

    --Una lista vacía de balas, que se llena con balas del jugador que ya no nos deben hacer daño
    self.balas_usadas = {}

    self.combatState = idleState
    self.balasCredentials = {}

    --Define distancia inicial
    self.distancey = 0
    self.distancex = 0 
    if self.y <= self.newy then -- Hunter esta arriba del jugador
        self.distancey = math.max(0,self.newy - self.y)
    else -- Hunter esta abajo del jugador
        self.distancey = math.max(0,self.y - self.newy)
    end

    if self.x <= self.newx then -- Hunter esta a la izquierda del jugador
        self.distancex = math.max(0,self.newx - self.x)
    else -- Hunter esta a la derecha del jugador
        self.distancex = math.max(0,self.x - self.newx)
    end
    self.lastDistance = (self.distancex^2 + self.distancey^2)^0.5

    --Tiempo inicial medido que le tomara llegar al objetivo desde el sitio de aparicion apartir de una velocidad dada
    self.timeToTarget = self.velocity/self.lastDistance

    --Variable de control para definir cuando la nave ha llagado a las coordenadas objetivo
    self.objetiveApproach = false

	--variable para saber cuando el asteroide explotó y se puede borrar
	self.destruible = false
	--Aqui van todas las animaciones posibles
	self.anim = {['no_damage'] = Anim(0, 0, self.width, self.height, 2, 2, self.fps),
                ['small_damage'] = Anim(116, 0, self.width, self.height, 2, 2, self.fps),
                ['medium_damage'] = Anim(232, 0, self.width, self.height, 2, 2, self.fps),
                ['high_damage'] = Anim(348, 0, self.width, self.height, 2, 2, self.fps),
                ['explosion'] = Anim(0, 0, 25, 25, 4, 4, self.fps)} 
end

--Funcion de update
function HunterMaster:update(dt, player, playerBalas)
    if self.hp <= 0 then
        self.destruible = true
    end
    if self.destruible == false then
        if self.hp > 12 then
            self.anim['no_damage']:update(dt, self.sprite)
        elseif self.hp > 8 then
            self.anim['small_damage']:update(dt, self.sprite)
        elseif self.hp > 4 then
            self.anim['medium_damage']:update(dt, self.sprite)
        elseif self.hp > 0 then
            self.anim['high_damage']:update(dt, self.sprite)
        end

        if self.combatState == idleState then
            if self.objetiveApproach then
                self.newx = (self.spacex - self.width) * (love.math.random(10,90)/100)
                self.newy = (self.spacey - self.height) * (love.math.random(10,70)/100)
            end
            if not self:kamikaze(player) then
                if not self:avoidTheCorners() then
                    self:detectBalasAndAvoid(playerBalas)
                end
            end
        elseif self.combatState == avoidBalasState then
            if self.objetiveApproach then
                self.combatState = idleState
            end
        elseif self.combatState == avoidCornerState then
            if self.objetiveApproach then
                self.combatState = idleState
            end
        elseif self.combatState == kamikazeState then
            --ya valiste verga morro
            self.newx = player.x
            self.newy = player.y
        end
        self:moveEngine(dt)
	else
		if 4 == self.anim['explosion']:update(dt, self.sprite_ex) then
			return false
		end
	end
	return true
end

function HunterMaster:moveEngine(dt)
    if self.y <= self.newy then -- Hunter esta arriba del jugador
        self.distancey = self.newy - self.y
        self.y = self.y + self.distancey * dt * self.timeToTarget 
    else -- Hunter esta abajo del jugador
        self.distancey = self.y - self.newy
        self.y = self.y - self.distancey * dt * self.timeToTarget
    end

    if self.x <= self.newx then -- Hunter esta a la izquierda del jugador
        self.distancex = self.newx - self.x
        self.x = self.x + self.distancex * dt * self.timeToTarget 
    else -- Hunter esta a la derecha del jugador
        self.distancex = self.x - self.newx
        self.x = self.x - self.distancex * dt * self.timeToTarget
    end
    --Actualizacion de tiempo requerido para llegar al objetivo
    --Calcula la distancia mas corta para llegar al objetivo
    local new_distance = (self.distancex^2 + self.distancey^2)^0.5
    --Si el objetivo esta a menos de un pixel de distancia, se considerara que la nave ha llegado al objetivo
    if new_distance <= 1 then
        self.timeToTarget = 0
        self.lastDistance = 0
        self.objetiveApproach = true
    else --Si la distancia es mayor a un pixel de distancia, hay que calcular el tiempo necesario para llegar en funcion a la velocidad definida
        --La nave se habia detenido, se recalcula el nuevo viaje
        if self.objetiveApproach then
            self.lastDistance = new_distance
            self.timeToTarget = self.velocity/self.lastDistance
            self.objetiveApproach = false
        else --La nave solo ha recorrido parte de la distancia, se calcula el tiempo necesario para llegar para no genrerar cambios de velocidad
            self.timeToTarget = (self.lastDistance / new_distance) * self.timeToTarget
            self.lastDistance = new_distance
        end
    end
end

function HunterMaster:kamikaze(player)
    if self.hp <= 2 then
        if love.math.random(1,10) > 7 then
            self.newx = player.x
            self.newy = player.y
            self:resetMoveEngine()
            self.combatState = kamikazeState
            return true
        end
    end
    return false
end

function HunterMaster:avoidTheCorners()
    local change = false
    if self.x < self.width * 2 then
        change = true
        self.newx = love.math.random(self.spacex/4, self.spacex - (self.width * 3))
    elseif self.x > self.spacex - (self.width * 2) then
        change = true
        self.newx = love.math.random(0, (self.spacex * (3/4)) - self.width)
    end
    if change then
        self:resetMoveEngine()
        self.combatState = avoidCornerState
    end
    return change
end

function HunterMaster:isNotBalaDetectedBefore(bala)
    if table.getn(self.balasCredentials) > 0 then
        for i = 1, table.getn(self.balasCredentials) do
            if bala.credential == self.balasCredentials[i][1] then
                if self.balasCredentials[i][2] == false then
                    self.balasCredentials[i][2] = true
                else
                    table.remove(self.balasCredentials, i)
                end
                return false
            end
        end
    end
    table.insert(self.balasCredentials, {bala.credential, false})
    return true
end

function HunterMaster:detectBalasAndAvoid(balas)
    --Revisa cada bala en el area
    if table.getn(balas) > 0 then
        local dangerBalas = {}
        for i, bala in pairs(balas) do
            if bala.x + bala.width/2 >= self.x - self.width*4 and bala.x + bala.width/2 <= self.x + self.width*5 and
            bala.y + bala.height/2 >= self.y - self.height*4 and bala.y + bala.height/2 <= self.y + self.height*5 and
            self:isNotBalaDetectedBefore(bala) then
                table.insert(dangerBalas, bala)
            end
        end
        if table.getn(dangerBalas) > 0 then
            local px = 0
            local py = 0
            self.combatState = avoidBalasState
            self:resetMoveEngine()
            for i, bala in pairs(dangerBalas) do
                if self.x >= bala.x then --bala a la izquierda
                    px = self.x + love.math.random(self.height, self.height * 2)
                else --bala a la derecha
                    px = self.x - love.math.random(self.height, self.height * 2)
                end
                if self.y + self.spacey/8 >= bala.y then -- bala esta arriba baka >//.//<
                    py = self.y - love.math.random(self.width, self.width * 2) 
                elseif self.y - self.spacey/8 <= bala.y then -- bala esta abajo
                    py = self.y + love.math.random(self.width, self.width * 2) 
                end
                self.newx = math.min(self.spacex - self.width, math.max(0, px))
                self.newy = math.min(self.spacey - self.height, math.max(0, py))
            end
        end 
    end

    --Ninguna bala esta en el area
end

function HunterMaster:resetMoveEngine()
    self.timeToTarget = 0
    self.lastDistance = 0
    self.objetiveApproach = true
end

function HunterMaster:collides(objeto)
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

function HunterMaster:render()
	if self.destruible == false then
        love.graphics.draw(sprite_sheet_hunter, self.sprite, self.x, self.y)
	else
		love.graphics.draw(sprite_sheet_explosion, self.sprite_ex, self.x, self.y)
	end
end