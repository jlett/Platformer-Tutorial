player = {
    x = 16,
    y = 16,

    xVelocity = 0,
    yVelocity = 0,
    acc = 200,
    maxSpeed = 600,
    friction = 40,
    gravity = 80,

    isJumping = false,
    isGrounded = false,
    hasReachedMax = false,
    jumpAcc = 500,
    jumpMaxSpeed = 9.5,

    img = ni
}

function love.load()
    player.img = love.graphics.newImage('assets/char.png')
end

function love.update(dt)
    player.x = player.x + player.xVelocity
    player.y = player.y + player.yVelocity

    player.xVelocity = player.xVelocity * (1 - math.min(dt * player.friction, 1))
    player.yVelocity = player.yVelocity * (1 - math.min(dt * player.friction, 1))

    --player.yVelocity = player.yVelocity + player.gravity * dt

    if love.keyboard.isDown("left", "a") and player.xVelocity > -player.maxSpeed then
        player.xVelocity = player.xVelocity - player.acc * dt
    elseif love.keyboard.isDown("right", "d") and player.xVelocity < player.maxSpeed then
        player.xVelocity = player.xVelocity + player.acc * dt
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit");
    end
end

function love.draw(dt)
    love.graphics.draw(player.img, player.x, player.y)
end