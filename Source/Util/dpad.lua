--Esta va a ser la herramienta para controlar la nave en el estado de play
--Consiste en una serie de botones en los lugares adecuados
--Son: un dpad para el movimiento, un boton para disparar, un boton para el escudo y uno para el disparo especial

control = {}

control.touched = {}

--Tamaño de los botones:

control.buttonw = 100
control.buttonh = 100

--se crea el widget del dpad
control.dpad = {}
control.dpad.name = 'dpad'

--Las caracteristicas del canvas del dpad
control.dpad.w = control.buttonw*3
control.dpad.h = control.buttonh*3
control.dpad.x = 20
control.dpad.y = WINDOW_HEIGHT-60-control.dpad.h

--Los nombres y posiciones de los botones del dpad
control.dpad.buttons = {
	{ name="up",   x=control.buttonw - 25, y= - 25 },
	{ name="left", x= - 25, y=control.buttonh - 25 },
	{ name="right",x=control.buttonw*2 - 25, y=control.buttonh - 25 },
	{ name="down", x=control.buttonw -25, y=control.buttonh*2 -25},
	{ name="up-left",   x= -25, y= -25 },
	{ name="up-right", x=control.buttonw*2 -25, y= -25 },
	{ name="down-left",x= -25, y=control.buttonh*2 -25},
	{ name="down-right", x=control.buttonw*2 -25, y=control.buttonh*2 -25}
}

control.dpad.opacity = 200
control.dpad.padding = 5

--Creamos el widget de los botones sueltos
control.buttons = {}
control.buttons.name = 'buttons'

--Creamos el canvas de los botones, que solo será el área en donde estan
control.buttons.w = WINDOW_WIDTH - 1035
control.buttons.h = WINDOW_HEIGHT - 440
control.buttons.x = 1035
control.buttons.y = 440

--nombre y posiciones de los botones para disparar
control.buttons.buttons = {
	{ name="shoot",   x=1183, y=443 },
	{ name="shoot2", x=1183, y=583 },
	{ name="shield",x=1063, y=583 },
	{ name="pause",x=1183, y=8 },
}

control.buttons.opacity = 200
control.buttons.padding = 5

--agupamos todo en los widgets correspondientes
control.widgets = {control.dpad, control.buttons}

function control:render()
	for _,widget in ipairs(control.widgets) do

		if widget.name == 'dpad' then
			love.graphics.setColor(0.607,0.607,0.607,0.4)
			love.graphics.circle("fill", widget.x+widget.w/2,widget.y+widget.h/2,widget.w/2)

		end
	
	end
	love.graphics.setColor(1, 1, 1, 1)

	for _,id in ipairs(control.touched) do
		local x,y = love.touch.getPosition(id)
		local tx, ty = push:toGame(x, y)
		if tx ~= nil and ty ~= nil then love.graphics.circle("fill",tx,ty,20) end
	end
end

function control:isDown(key)
	for _,widget in ipairs(control.widgets) do
		for _,button in ipairs(widget.buttons) do
			if button.isDown and button.name == key then return true end
		end
	end
end

function control:update(dt)
	
 	control.touched = love.touch.getTouches()
	
 	for _,widget in ipairs(control.widgets) do
		for _,button in ipairs(widget.buttons) do
			button.isDown = false
			for _,id in ipairs(control.touched) do	
				local x,y = love.touch.getPosition(id)
				local tx, ty = push:toGame(x, y)
				if tx ~= nil and ty ~= nil then

					if widget.name == 'dpad' then
						if  tx >= widget.x+button.x 
						and tx <= widget.x+button.x+control.buttonw + 50
						and ty >= widget.y+button.y 
						and ty <= widget.y+button.y+control.buttonh + 50 then
							button.isDown = true
						end
					else
						if  tx >= button.x 
						and tx <= button.x+control.buttonw 
						and ty >= button.y 
						and ty <= button.y+control.buttonh then
							button.isDown = true
						end
					end
				end
			end
		end
	end
end