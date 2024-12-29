local MAX_MOVE_RETRIES = 16

local args = {...}
local depth = args[1]

local direction = 0 -- 0: x+, 1: z+, 2: x-, 3: z-
local x = 0
local z = 0
local y = 0

depth = math.floor(depth)

if depth < 1 then
    error("Depth must be at least 1")
end

function moveUp()
    for i = 1, MAX_MOVE_RETRIES do
        local success, result = turtle.up()
        if success then
            y = y + 1
            print("I am at: " .. x .. ", " .. y .. ", " .. z)
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
            print("I am at: " .. x .. ", " .. y .. ", " .. z)
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
            print("I am at: " .. x .. ", " .. y .. ", " .. z)
            return
        else
            turtle.dig()
            turtle.attack()
        end
    end
    print("Failed to move forward")
end

for i = 1, depth do
    turtle.dig()
    turtle.digUp()
    turtle.digDown()
    moveForward()
    turtle.dig()
    turtle.digUp()
    turtle.digDown()
    moveDown()
end
