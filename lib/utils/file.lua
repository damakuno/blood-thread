local file
file = {
    -- Read an entire file.
    -- Use "a" in Lua 5.3; "*a" in Lua 5.1 and 5.2
    readall = function (filename)
        contents, size = love.filesystem.read(filename)
        -- local fh = assert(io.open(filename, "rb"))
        -- local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
        -- fh:close()
        return contents
    end,
    -- Write a string to a file.
    write = function (filename, contents)
        local fh = assert(io.open(filename, "wb"))
        fh:write(contents)
        fh:flush()
        fh:close()
    end
}  
return file