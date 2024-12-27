local MAX_MOVE_RETRIES = 10

local args = {...}
local length = args[1]
local width = args[2]
local height = args[3]

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
            return
        else
            turtle.digUp()
        end
    end
    print("Failed to move up")
end

function moveDown()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.down()
        if success then
            return
        else
            turtle.digDown()
        end
    end
    print("Failed to move down")
end

function moveForward()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.forward()
        if success then
            return
        else
            turtle.dig()
        end
    end
    print("Failed to move forward")
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

    for i = 1, length do
        digColumn()
        moveForward()
    end
    digColumn()

    if row_count ~= 0 and width > 0 then
        turtle.turnLeft()
        for i = 1, width do
            turtle.dig()
            moveForward()
            digColumn()
        end
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, width do
            moveForward()
        end
        did_tunnel_connect = true
    end

    if not did_tunnel_connect then
        turtle.turnRight()
    end

    for i = 1, width + 1 do
        turtle.dig()
        moveForward()
        digColumn()
    end

    turtle.turnRight()

    for i = 1, length do
        if i ~= 0 then
            digColumn()
        end
        moveForward()
    end
    digColumn()

    turtle.turnRight()

    for i = 1, width do
        turtle.dig()
        moveForward()
        digColumn()
    end
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, width do
        moveForward()
    end
    for i = 1, width + 1 do
        turtle.dig()
        moveForward()
        digColumn()
    end

    turtle.turnLeft()

    row_count = row_count + 1
end

