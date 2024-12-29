local FILE_LIST = "file_list.csv"

shell.run("rm " .. FILE_LIST)
shell.run("wget https://raw.githubusercontent.com/eriksters/Minecraft/refs/heads/main/file_list.csv " .. FILE_LIST)

local files = {}
for line in io.lines(FILE_LIST) do
    table.insert(files, line)
end

for _, file in ipairs(files) do
    local file_name = string.match(file, "[^/]+$")
    file_name = string.match(file_name, "(.+)%.")
    shell.run("rm " .. file_name)
    shell.run("wget " .. file .. " " .. file_name)
end
