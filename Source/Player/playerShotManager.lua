--Esta clase hace un manager para los disparos y tipos de disparos del jugador
PlayerShot = Class{}


function PlayerShot:init()
    self.balas = {} --lista para hacer seguimiento de las balas
    self.power_up = 'direccional' --variable para saber que tipo de balas tenemos equipadas
end

--Funciones que tienen que ver con listas de objetos en distintos estados
function PlayerShot:mover_balas_jugador(dt)
		--Hacemos un ciclo en el que se haga update de todas las balas
	for i, bala in pairs(self.balas) do
		if bala:update(dt) == false then
            table.remove(self.balas, i)
        end
		--checamos si la bala salio de la pantalla y la borramos
		if bala.y < 0 or bala.y > WINDOW_HEIGHT or bala.x < 0 or bala.x > WINDOW_WIDTH then
			table.remove(self.balas, i)
		end
	end

end

function PlayerShot:disparo_jugador(player)
	if love.keyboard.wasPressed('a') or love.keyboard.wasPressed('A') then
    	table.insert(self.balas, Bala(player.x + player.width/2 - 3, player.y, BULLET_SPEED))
    	TEsound.play('Soundtrack/Effect/soundLaser1.wav', 'static')
    end
    if love.keyboard.wasPressed('s') or love.keyboard.wasPressed('S') then
        if self.power_up == 'direccional' then
            self:disparo_direccional(player)
        end
    end
end

function PlayerShot:disparo_direccional(player)
    if love.keyboard.isDown('up') and  love.keyboard.isDown('left')then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 8))
        elseif love.keyboard.isDown('up') and  love.keyboard.isDown('right') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 5))
        elseif love.keyboard.isDown('down') and  love.keyboard.isDown('left') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 7))
        elseif love.keyboard.isDown('down') and  love.keyboard.isDown('right') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 6))
        elseif love.keyboard.isDown('up') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 1))
        elseif love.keyboard.isDown('down') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 2))
        elseif love.keyboard.isDown('left') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 4))
        elseif love.keyboard.isDown('right') then
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 3))
        else
            table.insert(self.balas, Direccional(player.x + player.width/2 -10, player.y, BULLET_SPEED, 1))
        end
        TEsound.play('Soundtrack/Effect/soundLaser2.wav', 'static')
end

function PlayerShot:render()
    for i, bala in pairs(self.balas) do
        bala:render()
    end
end