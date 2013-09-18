--[[
Based on "Vertical mineshaft with water drop" at
http://www.minecraftwiki.net/wiki/Mining#Vertical_mineshaft_with_water_drop

Start with turtle at level that will be top of shaft and facing forward to what will become the alcove.

Prepare the turtle with the following inventory. This assumes the shaft is started at about sea level.
- slot 16: 24+ torches
- slot 15: water bucket
- slot 14: water bucket
- slot 13: about 60 ladders or vines
- slot 12: 1+ cobblestone, used for comparison purposes.
- any slot 11 or less: fuel, only a handful of coal should be needed
]]

maxSlot = 11
shell.run("common.lua")

local torchSlot = 16
local bucket1Slot = 15
local bucket2Slot = 14
local ladderSlot = 13
local cobblestoneSlot = 12

local function digAlcove()
    if not tryForwards() or not tryUp() or
            not tryForwards() or not tryForwards() or
            not tryDown() then return false end
    turnAround()
    if not tryForwards() or not tryForwards() then return false end
    turnAround()
    return true
end

local function selectCobblestone()
    for n=1,maxSlot do
        if turtle.getItemCount(n) > 0 then
            turtle.select(n)
            -- prefer to use collected cobblestone instead of the cobblestone slot itself
            if turtle.compareTo(cobblestoneSlot) then
                return true
                -- if no cobblestone elsewhere (unlikely) then
                -- use the cobblestone slot directly if more than one there
            elseif turtle.getItemCount(cobblestoneSlot) > 1 then
                turtle.select(11)
                return true
            end
        end
    end
    return false
end

-- placing torches every five blocks
local function digAscentShaft()
    if tryDown() then
        turtle.dig() -- remove first block on top of pillar
    else
        return false
    end

    while tryDown() do
        if math.fmod(depth,5) == 0 then -- place torch on side
            turnRight()
            turtle.dig()
            turtle.select(torchSlot)
            turtle.place()
            turnLeft()
        end

        turtle.select(ladderSlot) -- select ladder or vine
        turtle.placeUp()
    end
    return true;
end

local function pillarUp(n)
    -- collect ladders?
    for n=1,n do
        if tryUp() and selectCobblestone() then
            turtle.placeDown()
        end
    end
end

local function digBottomArea()
    if not tryForwards() then
        print("Could not go forwards")
        return false
    end

    if not tryUp() then
        print ("Could not go up")
        return false
    end

    if not tryForwards() then
        print("Could not go forwards")
        return false
    end

    -- go down one plus three more to make room for the water pit
    for n=1,4 do
        if not tryDown() then
            print("Could not go down")
            return false
        end
    end
    -- move back up to floor level
    for n=1,3 do
        if not tryUp() then
            return false
        end
    end
    return true
end

local function digUtilityRoom()
 -- turtle is now sitting on top of the water pit facing the wall
    turnAround()
    if not tryForwards() then return false end
    turnLeft()

    -- lower middle of room
    for n=1,6 do
        if not tryForwards() then return false end
    end

    if not tryUp() then return false end
    turnAround()
    -- move one block away from wall then place torch
    if not tryForwards() then return false end
    turnAround()
    turtle.select(torchSlot)
    turtle.place();
    turnAround()

    -- rest of upper middle of room
    for n=1,4 do
        if not tryForwards() then return false end
    end

    -- go back one
    turnAround()
    if not tryForwards() then return false end

    -- upper left part of room
    turnLeft()
    tryForwards()
    turnRight()
    for n=1,4 do
        if not tryForwards() then return false end
    end

    -- lower left part of room
    if not tryDown() then return false end
    turnAround()
    for n=1,4 do
        if not tryForwards() then return false end
    end

    -- move to right part of room
    turnLeft()
    if not tryForwards() then return false end
    if not tryForwards() then return false end
    turnLeft()

    -- lower right
    for n=1,4 do
        if not tryForwards() then return false end
    end
    if not tryUp() then return false end
    turnAround()

    -- upper right
    for n=1,4 do
        if not tryForwards() then return false end
    end

    -- leave turtle down and facing the wall
    if not tryDown() then return false end
    turnLeft()
    return true
end

local function digWaterTrough()
    if not tryForwards() then return false end
    turnLeft()
    if not tryForwards() then return false end
    if not tryForwards() then return false end
    turnAround()
    if not tryDown() then return false end
    if not tryForwards() then return false end
    if not tryForwards() then return false end
    if not tryUp() then return false end
    turnAround()
    -- place one water at each end
    if not turtle.select(bucket1Slot) or not turtle.placeDown() then return false end
    if not tryForwards() then return false end
    if not tryForwards() then return false end
    if not turtle.select(bucket2Slot) or not turtle.placeDown() then return false end

    -- now move into position of middle of water trough to start moving water
    turnAround()
    if not tryForwards() then return false end
    turnRight()
    return true
end

local function placeWaterInPit()
    turtle.select(bucket1Slot)
    --for b=1,3 do -- only one water bucket is actually necessary to fill the three-block pit...
        -- pick up water
        if not turtle.placeDown() then return false end
        if not tryForwards() then return false end
        if not tryForwards() then return false end
        turnLeft()
        if not tryForwards() then return false end
        if not tryForwards() then return false end
        if not tryForwards() then return false end
        turnRight()
        if not tryForwards() then return false end
        -- place bucket of water
        if not turtle.placeDown() then return false end

--[[
        -- if not done go get another bucket
        if b < 3 then
            turnAround()
            if not tryForwards() then return false end
            turnLeft()
            if not tryForwards() then return false end
            if not tryForwards() then return false end
            if not tryForwards() then return false end
            turnRight()
            if not tryForwards() then return false end
            if not tryForwards() then return false end
            turnAround()
        end
]]
    --end
    return true
end

-- placing torches every five blocks
local function digToSurface()
    while depth > 0 do

        if math.fmod(depth,5) == 0 then -- place torch forward
            turtle.dig()
            turtle.select(torchSlot)
            turtle.place()
        end

        if not tryUp() then return false end
    end
    return true
end

if not refuel() then
    print( "Out of Fuel" )
    return
end

digAlcove()
digAscentShaft()
-- pillar up an extra couple blocks to allow for irregularity in bedrock
-- and we want to be about six blocks up anyway for the best mining
pillarUp(6)
digBottomArea()
if digUtilityRoom() and digWaterTrough() and placeWaterInPit() then
    digToSurface()
end
