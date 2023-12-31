push = require "push"

Class = require "class"

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong')

	math.randomseed(os.time())

	smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)

	love.graphics.setFont(smallFont)

	sounds = {
		['paddle_hit'] = love.audio.newSource('Sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('Sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('Sounds/wall_hit.wav', 'static'),
		['winning_sound'] = love.audio.newSource('Sounds/winning_sound.wav', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = true,
		vsync = true
	})

	servingPlayer = 1

	player1Score = 0
	player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	gameState = 'titlepage'
end


function love.resize(w, h)
	push:resize(w, h)
end

function love.update(dt)
	if gameState == 'start' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end

	else if gameState == 'play' then
       	if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

        	if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end
 
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end

    	if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

       	if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

		if ball.x < 0 then
       		servingPlayer = 1
       		player2Score = player2Score + 1
       		sounds.score:play()

    		if player2Score == 3 then
   				winningPlayer = 2
	    	  	gameState = 'done'
	    	  	sounds.winning_sound:play()
    		else
        		gameState = 'start'
        		ball:reset()
    		end
		end



	    if ball.x > VIRTUAL_WIDTH then
	        servingPlayer = 2
	        player1Score = player1Score + 1
	        sounds.score:play()

	    	if player1Score == 3 then
	        	winningPlayer = 1
	        	gameState = 'done'
	        	sounds.winning_sound:play()
	    	else
	        	gameState = 'start'
	        	ball:reset()
	    	end
		end
	end

 
   	if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

	if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end
end



function love.keypressed(key)

    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'titlepage' then
            gameState = 'start'
            ball:reset()
        elseif gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'done' then
      
        	gameState = 'start'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
	push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

 	if gameState == 'titlepage' then
		love.graphics.setFont(scoreFont)
		love.graphics.printf('Press ENTER to start!',	0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH,'center')
	end

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Play!',	0, 20, VIRTUAL_WIDTH,'center')
		love.graphics.setFont(scoreFont)
		love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
		love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
	end

	if gameState == 'play' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Play!',	0, 20, VIRTUAL_WIDTH,'center')
		love.graphics.setFont(scoreFont)
		love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
		love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
	end

	if gameState == 'start' then
		player1:render()
		player2:render()
		ball:render()
	end

	if gameState == 'play' then
		player1:render()
		player2:render()
		ball:render()
	end

	if gameState == 'done' then
		love.graphics.setFont(scoreFont)
		love.graphics.printf('PLAYER ' .. tostring(winningPlayer) .. ' WINS!',	0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH,'center')
		love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
        player1:render()
        player2:render()
        displayScore()
	end

	displayFPS()

	push:apply('end')
end


function displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end