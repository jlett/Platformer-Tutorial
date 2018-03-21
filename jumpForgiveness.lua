bump = require 'lib.bump.bump'
cupid = require 'lib.cupid'
flux = require 'lib.flux'

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

    accelTween = nil,
    accelTime = 1,
    decelTime = .3,

    gravity = 3000,
    jumpSpeed = 600,
    jumpTime = .5,
    jumpTween = nil,
    jumpForgiveness = 1,

    isJumping = false,
    ungroundedTime = 0,
    isGrounded = false,

    animation = nil,
    moveLeft = false
}

function love.load()

    player.animation = newAnimation(love.graphics.newImage('assets/oldHero.png'), 16, 18, 1)

    -- Setup bump
    world = bump.newWorld(16)  -- 16 is our tile size

    world:add(player, player.x, player.y, 16*4, 18*4)

    -- Draw a level
    world:add(ground_0, 120, 360, 640, 16)
    world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)

    flux.update(dt)

    --Cap our velocity
    if player.xVelocity > player.maxSpeed then
        player.xVelocity = player.maxSpeed
    elseif player.xVelocity < -player.maxSpeed then
        player.xVelocity = -player.maxSpeed
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
            player.ungroundedTime = 0
        end
        
        if coll.normal.y > 0 then
            --end jump when head bump
            player.isJumping = false
            if player.jumpTween ~= nil then
                player.jumpTween:stop()
            end
            player.yVelocity = 0
        end
    end
    
    --jump forgiveness
    if player.isGrounded == false then
        if player.ungroundedTime > player.jumpForgiveness then
            player.isGrounded = false
        else
            player.isGrounded = true
            player.ungroundedTime = player.ungroundedTime + dt
        end
    end

    --update animation sheet
    local percentVel = math.abs(player.xVelocity / player.maxSpeed)
    player.moveLeft = player.xVelocity < 0
    player.animation.currentTime = player.animation.currentTime + dt*percentVel
    if player.animation.currentTime >= player.animation.duration then
        player.animation.currentTime = player.animation.currentTime - player.animation.duration
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit");
    elseif key == "right" or key == "d" then
        local speedPercent = (player.maxSpeed - player.xVelocity)/player.maxSpeed
        player.accelTween = flux.to(player, player.accelTime*speedPercent, {xVelocity = player.maxSpeed}):ease("circout")
    elseif key == "left" or key == "a" then
        local speedPercent = math.abs((-player.maxSpeed - player.xVelocity)/player.maxSpeed)
        player.accelTween = flux.to(player, player.accelTime*speedPercent, {xVelocity = -player.maxSpeed}):ease("circout")
    elseif (key == "up" or key == "w") and player.isGrounded then
        player.isJumping = true
        player.isGrounded = false
        player.yVelocity = -player.jumpSpeed
        player.jumpTween = flux.to(player, player.jumpTime, {yVelocity = 0}):ease("quartin"):oncomplete(function() player.isJumping = false end)
    end
end

function love.keyreleased(key)
    if key == "right" or key == "d" or key == "left" or key == "a" then
        --make sure we didnt release while still holding a different movement button
        if not love.keyboard.isDown("right", "d", "left", "a") then
            local speedPercent = math.abs(player.xVelocity/player.maxSpeed)
            player.accelTween = flux.to(player, player.decelTime*speedPercent, {xVelocity = 0}):ease("circout")
        end
    elseif key == "w" or key == "up" then
        --sanity check, covers a small edge case
        if player.jumpTween ~= nil then
            player.jumpTween:stop()
        end
        player.isJumping = false
    end
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function love.draw(dt)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    --love.graphics.draw(player.img, player.x, player.y)
    local spriteNum = math.floor(player.animation.currentTime / player.animation.duration * #player.animation.quads) + 1
    local leftMult = player.moveLeft and -1 or 1
    local leftOffset = player.moveLeft and 16*4 or 0
    love.graphics.draw(player.animation.spriteSheet, player.animation.quads[spriteNum], player.x + leftOffset, player.y, 0, leftMult*4, 4)
    love.graphics.rectangle('fill', world:getRect(ground_0))
    love.graphics.rectangle('fill', world:getRect(ground_1))
end