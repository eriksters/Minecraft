local MAX_MOVE_RETRIES = 10
local CHEST_SLOT = 16

--[[
    ARGUMENTS
    length: length of the tunnel
    width: width of the gap
    height: height of the tunnel
    dig_type: how strictly to ensure that every block is dug (clean / dirty)
]]
local args = {...}
local length = args[1]
local width = args[2]
local height = args[3]
local dig_type = args[4]

local direction = 0 -- 0: x+, 1: z+, 2: x-, 3: z-
local x = 0
local z = 0
local y = 0
if length == nil then length = 2 end
if width == nil then width = 0 end
if height == nil then height = 2 end
if dig_type == nil then dig_type = "clean" end

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

if dig_type ~= "clean" and dig_type ~= "dirty" then
    error("dig_type must be either 'clean' or 'dirty'")
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

function dirty_tunnel(l, h, current_column)
    -- Function setup
    local moveHeight = h - 3
    local block_count = 0
    local pos = "down"         -- up / down

    -- Dig the tunnel
    while block_count < l do
        local dirty_block = false
        -- Go forward if not the first block
        if block_count ~= 0 then
            turtle.dig()
            turtle.digUp()
            moveForward()
        end

        if block_count + 1 ~= l then
            turtle.dig()
            turtle.digUp()
            turtle.digDown()
            moveForward()
            dirty_block = true
        end

        -- Dig upwards if currently on the bottom
        if pos == "down" then
            if (current_column and block_count == 0) or block_count ~= 0 then
                turtle.digDown()
                for i = 1, moveHeight do
                    turtle.dig()
                    turtle.digUp()
                    moveUp()
                end
                turtle.digUp()
                pos = "up"
            end

        -- Dig downwards if currently on the top
        elseif pos == "up" then
            turtle.digUp()
            for i = 1, moveHeight do
                turtle.dig()
                turtle.digDown()
                moveDown()
            end
            turtle.digDown()
            pos = "down"
        end
        block_count = block_count + 1
        if dirty_block then
            block_count = block_count + 1
        end
    end
    if pos == "up" then
        for i = 1, moveHeight do
            moveDown()
        end
    end
end

function clean_tunnel(l, h, current_column)
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
                if h > 2 then
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
    Digs a tunnel of length l and height h
    current_column: if true, dig the current column, otherwise start with the next.
]]
function tunnel(l, h, current_column)
    print("Digging tunnel of length " .. l .. " and height " .. h .. " with current_column " .. tostring(current_column))
    if dig_type == "dirty" then
        dirty_tunnel(l, h, current_column)
    else
        clean_tunnel(l, h, current_column)
    end
end

function inventoryCheck()
    local free_slots = 0
    for i = 1, 15 do
        if turtle.getItemCount(i) == 0 then
            free_slots = free_slots + 1
        end
    end
    print("I have " .. free_slots .. " free slots")
    if free_slots == 0 then
        turtle.select(CHEST_SLOT)
        turtle.placeDown()
        for i = 1, 15 do
            turtle.select(i)
            item_count = turtle.getItemCount(i)
            if item_count > 0 then
                turtle.dropDown(item_count)
            end
        end
    end
end

--[[
    STARTUP
]]
print("I am at: " .. x .. ", " .. y .. ", " .. z)
turtle.digUp()
moveUp()

--[[
    MAIN LOOP
]]
local row_count = 0
while true do
    local did_tunnel_connect = false

    -- Bottom Left, tunnel
    tunnel(length, height, row_count == 0)

    -- Top Left, gap connect
    if row_count ~= 0 and width > 0 then
        turnLeft()
        tunnel(width + 1, height, false)
        turnRight()
        turnRight()
        for i = 1, width do
            moveForward()
        end
        did_tunnel_connect = true
    end
    -- Top Left, gap
    if not did_tunnel_connect then
        turnRight()
    end
    tunnel(width + 2, height, false)
    
    -- Top Right, tunnel
    turnRight()
    tunnel(length, height, false)

    -- Bottom Right, gap connect
    turnRight()
    tunnel(width + 1, height, false)
    turnRight()
    turnRight()
    for i = 1, width do
        moveForward()
    end

    -- Inventory check
    inventoryCheck()

    -- Bottom Right, gap
    tunnel(width + 2, height, false)

    turnLeft()

    row_count = row_count + 1

end

