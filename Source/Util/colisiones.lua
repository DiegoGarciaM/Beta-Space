--Aqui van las funsiones que checan colisiones entre objetos como asteroides, enemigos, balas, etc.

function collisions_asteroide(dt, asteroides, balas, nave)
	--checamos si el asteroide salio de la pantalla y la borramos
	for i, asteroide in pairs(asteroides) do
		asteroide:update(dt)
		
		if asteroide.y > WINDOW_HEIGHT or asteroide.x > WINDOW_WIDTH or asteroide.x < -asteroide.width or asteroide.y < -35 then
			table.remove(asteroides, i)
		end
	end

	--Aqui checamos las colisiones entre asteroides y balas
	for i, bala in pairs(balas) do
		for j, asteroide in pairs(asteroides) do
			if asteroide:collides(bala) then
				puntaje = puntaje + 10
				table.remove(asteroides, j)
				table.remove(balas, i)
				TEsound.play({'Soundtrack/Effect/soundExplosion1.wav','Soundtrack/Effect/soundExplosion2.wav','Soundtrack/Effect/soundExplosion3.wav'},
					'static',
					{'explosion'},
					0.5)
				break
			end
		end
	end

	--Aqui checamos las colisiones entre asteroides y otros asteroides
	for i, ast1 in pairs(asteroides) do
		for j, ast2 in pairs(asteroides) do
			if ast2:collides(ast1) then
				--Primero movemos el asteroide para que dejen de chocar
				if ast1.x < ast2.x then
					ast1.x = ast1.x - 1
					ast2.x = ast2.x + 1
				else
					ast1.x = ast1.x + 1
					ast2.x = ast2.x - 1
				end
				if ast1.y < ast2.y then
					ast1.y = ast1.y - 1
					ast2.y = ast2.y + 1
				else
					ast1.y = ast1.y + 1
					ast2.y = ast2.y - 1
				end

				--Ahora calculamos la nueva dirección de los asteroides
				tempx = ast1.dx
				tempy = ast1.dy
				ast1.dx = ast2.dx
				ast1.dy = ast2.dy
				ast2.dx = tempx
				ast2.dy = tempy
				break
			end
		end
	end

	--Checamos si el asteroide choca con la nave
	for j, asteroide in pairs(asteroides) do
		if asteroide:collides(nave) then
			table.remove(asteroides, j)
			if escudo_nave == false then
				puntaje = puntaje - 5
				TEsound.play('Soundtrack/Effect/GolpeSimple.wav', 'static')
			else
				TEsound.play({'Soundtrack/Effect/hit1.wav', 'Soundtrack/Effect/hit2.wav', 'Soundtrack/Effect/hit3.wav'}, 'static')
			end
			break
		end
	end
end