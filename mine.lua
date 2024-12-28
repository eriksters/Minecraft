local MAX_MOVE_RETRIES = 10

local args = {...}
local length = args[1]
local width = args[2]
local height = args[3]

local direction = 0 -- 0: x+, 1: z+, 2: x-, 3: z-
local x = 0
local z = 0
local y = 0
if length == nil then length = 2 end
if width == nil then width = 0 end
if height == nil then height = 2 end

length = math.floor(length)
width = math.floor(width)
height = math.floor(height)

if length < 2 then
    error("Length must be at least 2")
end

if width < 0 then
    error("Width must be at least 0")
end

if height < 2 then
    error("Height must be at least 1")
end

function moveUp()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.up()
        if success then
            y = y + 1
            return
        else
            turtle.digUp()
            turtle.attackUp()
        end
    end
    print("Failed to move up")
end

function moveDown()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.down()
        if success then
            y = y - 1
            return
        else
            turtle.digDown()
            turtle.attackDown()
        end
    end
    print("Failed to move down")
end

function moveForward()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.forward()
        if success then
            if direction == 0 then
                x = x + 1
            elseif direction == 1 then
                z = z + 1
            elseif direction == 2 then
                x = x - 1
            elseif direction == 3 then
                z = z - 1
            end
            return
        else
            turtle.dig()
            turtle.attack()
        end
    end
    print("Failed to move forward")
end

function turnLeft()
    turtle.turnLeft()
    direction = (direction + 3) % 4
end

function turnRight()
    turtle.turnRight()
    direction = (direction + 1) % 4
end

function digColumn()
    turtle.digDown()
    local moveHeight = height - 3
    for i = 1, moveHeight do
        turtle.digUp()
        moveUp()
    end
    if height > 2 then
        turtle.digUp()
    end
    for i = 1, moveHeight do
        moveDown()
    end
end

--[[
    Digs a tunnel of length l and height h
    (optional) current_column: if true, dig the current column, otherwise start with the next. Default is true.
]]
function tunnel(t)
    -- Handle arguments
    setmetatable(t,{__index={current_column=true}})
    local l, h, current_column =
        t[1] or t.a, 
        t[2] or t.b,
        t[3] or t.c
    
    -- Function setup
    local moveHeight = h - 3
    local block_count = 0
    local pos = "down"         -- up / down

    -- Dig the tunnel
    while block_count < l do
        -- Go forward if not the first block
        if block_count ~= 0 then
            turtle.dig()
            moveForward()
        end

        -- Dig downwards if currently on the top
        if pos == "up" then
            if l > 2 then
                turtle.digUp()
            end
            for i = 1, moveHeight do
                turtle.digDown()
                moveDown()
            end
            turtle.digDown()
            pos = "down"

        -- Dig upwards if currently on the bottom
        elseif pos == "down" then
            if (current_column and block_count == 0) or block_count ~= 0 then
                turtle.digDown()
                for i = 1, moveHeight do
                    turtle.digUp()
                    moveUp()
                end
                if l > 2 then
                    turtle.digUp()
                end
                pos = "up"
            end
        end
        block_count = block_count + 1
    end
    if pos == "up" then
        for i = 1, moveHeight do
            moveDown()
        end
    end
end

--[[
    STARTUP
]]
turtle.digUp()
moveUp()

--[[
    MAIN LOOP
]]
local row_count = 0
while true do
    local did_tunnel_connect = false
    print("I am at: " .. x .. ", " .. y .. ", " .. z)

    -- Bottom Left, tunnel
    tunnel{length, height}
    print("I am at: " .. x .. ", " .. y .. ", " .. z)

    -- Top Left, gap connect
    if row_count ~= 0 and width > 0 then
        turnLeft()
        tunnel{width + 1, height, row_count == 0}
        turnRight()
        turnRight()
        for i = 1, width do
            moveForward()
        end
        did_tunnel_connect = true
    end
    print("I am at: " .. x .. ", " .. y .. ", " .. z)
    -- Top Left, gap
    if not did_tunnel_connect then
        turnRight()
    end
    tunnel{width + 2, height, false}
    print("I am at: " .. x .. ", " .. y .. ", " .. z)
    
    -- Top Right, tunnel
    turnRight()
    tunnel{length, height, false}
    print("I am at: " .. x .. ", " .. y .. ", " .. z)

    -- Bottom Right, gap connect
    turnRight()
    tunnel{width + 1, height, false}
    turnRight()
    turnRight()
    for i = 1, width do
        moveForward()
    end
    print("I am at: " .. x .. ", " .. y .. ", " .. z)

    -- Bottom Right, gap
    tunnel{width + 2, height, false}

    turnLeft()

    row_count = row_count + 1

    print("I am at: " .. x .. ", " .. y .. ", " .. z)
end

