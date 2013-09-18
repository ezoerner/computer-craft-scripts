shell.run("common.lua")

local tArgs = { ... }
if #tArgs ~= 1 then
    print( "Usage: dive-excavate <diameter>" )
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
size = tonumber( tArgs[1] )
if size < 1 then
    print( "Excavate diameter must be positive" )
    return
end

while not turtle.detectDown() and tryDown() do
end


print( "Excavating..." )

local reseal = false
turtle.select(1)
if turtle.digDown() then
    reseal = true
end

local alternate = 0
local done = false
while not done do
    for n=1,size do
        for m=1,size-1 do
            if not tryForwards() then
                done = true
                break
            end
        end
        if done then
            break
        end
        if n<size then
            if math.fmod(n + alternate,2) == 0 then
                turnLeft()
                if not tryForwards() then
                    done = true
                    break
                end
                turnLeft()
            else
                turnRight()
                if not tryForwards() then
                    done = true
                    break
                end
                turnRight()
            end
        end
    end
    if done then
        break
    end

    if size > 1 then
        if math.fmod(size,2) == 0 then
            turnRight()
        else
            if alternate == 0 then
                turnLeft()
            else
                turnRight()
            end
            alternate = 1 - alternate
        end
    end

    if not tryDown() then
        done = true
        break
    end
end

print( "Returning to surface..." )

-- Return to where we started
goTo( 0,0,0,0,-1 )
unload( false )
goTo( 0,0,0,0,1 )

-- Seal the hole
if reseal then
    turtle.placeDown()
end

print( "Mined "..(collected + unloaded).." items total." )
