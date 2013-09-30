-- Usage: torch-tunnel.lua <tunnelLength> <torchInterval>
-- digs a 3 wide by 2 high access shaft of <tunnelLength>
-- centered width-wise on the beginning position of the turtle.
-- Will place torches in the tunnel every <torchInterval>

-- To prepare:
-- slot 16: torches
-- slot 15: cobblestone
-- fuel in any other slot(s)

maxSlot = 14
shell.run("common.lua")

-- designated slots
local cobblestoneSlot = 15
local torchSlot = 16

local tArgs = { ... }
if #tArgs ~= 2 then
    print( "Usage: torch-tunnel.lua <tunnelLength> <torchInterval>" )
    return
end

local tunnelLength = tonumber( tArgs[1] )
if tunnelLength < 1 then
    print( "tunnel length must be positive" )
    return
end

local torchInterval = tonumber(tArgs[2])
if torchInterval < 1 then
    print("torch interval must be positive")
    return
end

function tunnel(length)
    local nextTorchPlacement = torchInterval
    print( "Tunnelling..." )
    for n=1,length do
        if selectCobblestone(cobblestoneSlot) then
            turtle.placeDown() -- try to see to it that there's some floor...
        end
        tryDigUp()
        turnLeft()
        tryDig()
        tryUp()
        tryDig()
        turnAround()
        tryDig()
        if n >= nextTorchPlacement then
            turtle.select(torchSlot)
            if turtle.place() then
                nextTorchPlacement = n + torchInterval
            end
        end
        tryDown()
        tryDig()
        turnLeft()

        if n<length then
            tryDig()
            if not tryForwards() then
                print( "Aborting Tunnel." )
                break
            end
        else
            print( "Tunnel complete." )
        end
    end
end

tunnel(tunnelLength, torchInterval)

-- attempt to return to beginning and unload
goTo( 0,0,0,0,-1 )
unload(false)
turnAround()
