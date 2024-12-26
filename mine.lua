local length = ...
local width = select(2, ...)
local count = select(3, ...)
local height = select(4, ...)

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
