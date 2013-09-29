-- Usage: branch-mine.lua <accessShaftLength> <branchLength> <numBranches> [<branchInterval>]
-- digs a 3 wide by 2 high access shaft of <accessShaftLength>
-- centered width-wise on the beginning position of the turtle, then branch mines.
-- Each branch is <branchLength> and branches occur every
-- <branchInterval> blocks (defaults to 3 if not provided, or if specified then must be at least 2).
-- Will place torches in the access shaft after every other branch or every 5-6 blocks depending
-- on the branch interval
-- The program will try to continue until numBranches have been mined.

-- To prepare:
-- slot 16 torches
-- slot 15 cobblestone
-- fuel in any other slot(s)

maxSlot = 14
shell.run("common.lua")

-- designated slots
local cobblestoneSlot = 15
local torchSlot = 16

local tArgs = { ... }
if #tArgs < 3 or #tArgs > 4 then
    print( "Usage: branch-mine.lua <accessShaftLength> <branchLength> <numBranches> [<branchInterval>]" )
    return
end

local accessShaftLength = tonumber( tArgs[1] )
if accessShaftLength < 1 then
    print( "access shaft length must be positive" )
    return
end

local branchLength = tonumber(tArgs[2])
if branchLength < 1 then
    print("branch length must be positive")
    return
end

local numBranches = tonumber(tArgs[3])
if numBranches < 1 then
    print("numBranches must be positive")
    return
end

-- interval of branches, defaults to 3
local branchInterval = 3
if #tArgs == 4 then
    branchInterval = tonumber(tArgs[4])
    if branchInterval < 2 then
        print("branchInterval must be greater than 1")
        return
    end
end

function tunnel(length,torchInterval)
    local nextTorchPlacement = torchInterval
    print( "Tunnelling..." )
    for n=1,length do
        if selectCobblestone(cobblestoneSlot) then
            turtle.placeDown()
        end
        tryDigUp()
        turtle.turnLeft()
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
        turtle.turnLeft()

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

function mineBranch()
    for n=1,branchLength-1 do
        if not tryForwards() then
            return false
        end
    end
    tryDig()
    turtle.select(torchSlot)
    turtle.place()
    turnAround()
    for n=1,branchLength do
        if not tryForwards() then
            return false
        end
    end
    return true
end

tunnel(accessShaftLength, 5)
-- return to beginning and try to unload before continuing
goTo( 0,0,0,0,-1 )
unload( true )
turnAround()

-- Begin branches
local branchesMined = 0
while true do
    for n=1,(branchInterval-1) do
        tryForwards()
    end
    turnLeft()
    tryForwards()
    if mineBranch() then
        branchesMined = branchesMined + 1
        if branchesMined >= numBranches then
            break
        end
    end
    tryForwards()
    tryForwards()
    if mineBranch() then
        branchesMined = branchesMined + 1
        if branchesMined >= numBranches then
            break
        end
    end
    tryForwards()
    turnRight()
end

-- attempt to return to beginning and unload
goTo( 0,0,0,0,-1 )
unload( true )
turnAround()
