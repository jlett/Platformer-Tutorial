bump = require 'lib.bump.bump'
cupid = require 'lib.cupid'

world = nil -- storage place for bump

ground_0 = {}
ground_1 = {}

player = {
    x = 16,
    y = 16,

    xVelocity = 0,
    yVelocity = 0,
    maxYVelocity = 1000,
    maxSpeed = 400,
    jumpStrength = 80,
    gravity = 2400,
    jumpTime = 0,
    maxJumpTime = 8,

    isJumping = false,
    isGrounded = false,

    img = ni
}

function love.load()

    player.img = love.graphics.newImage('assets/char.png')

    -- Setup bump
    world = bump.newWorld(16)  -- 16 is our tile size

    world:add(player, player.x, player.y, player.img:getWidth(), player.img:getHeight())

    -- Draw a level
    world:add(ground_0, 120, 360, 640, 16)
    world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)

    --Get left/right input
    if love.keyboard.isDown("left", "a") then
        player.xVelocity = -player.maxSpeed
    elseif love.keyboard.isDown("right", "d") then
        player.xVelocity = player.maxSpeed
    else
        player.xVelocity = 0
    end

    --Get jump input, starts jump only when grounded
    if love.keyboard.isDown("up", "w") and player.isGrounded then
        player.isJumping = true
    end

    --calculate jump
    if love.keyboard.isDown("up", "w") and player.isJumping and player.jumpTime < player.maxJumpTime then
        player.jumpTime = player.jumpTime + player.jumpStrength*dt
        player.yVelocity = -player.jumpStrength*player.jumpTime
    else
        player.isJumping = false
    end

    --Apply gravity (only while not jumping)
    if(player.isJumping == false) then
        player.yVelocity = player.yVelocity + (player.gravity * dt)
    end

    --Terminal velocity for gravity
    if player.yVelocity > player.maxYVelocity then
        player.yVelocity = player.maxYVelocity
    end

    --apply movement and calc collisions
    local goalX = player.x + dt*player.xVelocity
    local goalY = player.y + dt*player.yVelocity
    player.x, player.y, collisions = world:move(player, goalX, goalY)

    --detect collisions
    player.isGrounded = false
    for i, coll in ipairs(collisions) do
        if coll.normal.y < 0 then
            player.isGrounded = true
            player.yVelocity = 0
        elseif coll.normal.y > 0 then
            --end jump when head bump
            player.isJumping = false
            player.yVelocity = 0
        end
    end

    --reset jump timer when on ground
    if player.isGrounded then
        player.jumpTime = 0
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit");
    end
end

function love.draw(dt)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.rectangle('fill', world:getRect(ground_0))
    love.graphics.rectangle('fill', world:getRect(ground_1))
end