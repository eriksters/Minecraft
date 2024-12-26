local args = {...}
local length = args[1]
local width = args[2]
local count = args[3]
local height = args[4]

if length == nil then length = 2 end
if width == nil then width = 0 end 
if count == nil then count = 0 end
if height == nil then height = 1 end

length = math.floor(length)
width = math.floor(width)
count = math.floor(count)
height = math.floor(height)

if length < 2 then
    error("Length must be at least 2")
end

if width < 0 then
    error("Width must be at least 0")
end

if count < 0 then
    error("Count must be at least 0")
end

if height < 1 then
    error("Height must be at least 1")
end
