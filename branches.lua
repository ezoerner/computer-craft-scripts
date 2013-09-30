-- Usage: branches.lua <branchLength> <numBranches> [<branchInterval>]
-- Digs branches off a 3x2 access shaft presumed to have already been dug.
-- Each branch is <branchLength> and branches occur every
-- <branchInterval> blocks (defaults to 3 if not provided, or if specified then must be at least 2).
-- The program will try to continue until numBranches have been mined.

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
if #tArgs < 2 or #tArgs > 3 then
    print( "Usage: branches.lua <branchLength> <numBranches> [<branchInterval>]" )
    return
end

local branchLength = tonumber(tArgs[1])
if branchLength < 1 then
    print("branch length must be positive")
    return
end

local numBranches = tonumber(tArgs[2])
if numBranches < 1 then
    print("numBranches must be positive")
    return
end

-- interval of branches, defaults to 3
local branchInterval = 3
if #tArgs == 4 then
    branchInterval = tonumber(tArgs[3])
    if branchInterval < 2 then
        print("branchInterval must be greater than 1")
        return
    end
end

function mineBranch()
    for n=1,branchLength-1 do
        if not tryForwards() then
            return false
        end
    end
    tryDig()
    tryUp()
    tryDig()
    turtle.select(torchSlot)
    turtle.place()
    turnAround()
    for n=1,branchLength do
        if not tryForwards() then
            return false
        end
    end
    tryDown()
    return true
end

-- Begin branches
local branchesMined = 0
while true do
    for n=1,branchInterval do
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
unload(false)
turnAround()
