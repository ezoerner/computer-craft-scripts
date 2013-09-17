-- Based on "Vertical mineshaft with water drop" at
-- http://www.minecraftwiki.net/wiki/Mining#Vertical_mineshaft_with_water_drop

-- start with turtle at level that will be top of shaft and facing forward
-- to what will be the alcove

-- slot 16: 24+ torches
-- slot 15: water bucket
-- slot 14: water bucket
-- slot 13: water bucket
-- slot 12: 64 ladders or vines
-- slot 11: 1+ cobblestone, used for comparison
-- slot 10: fuel (how many coal are needed?)

local maxSlot = 10

local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local function collect()
    local bFull = true
    local nTotalItems = 0
    for n=1,maxSlot do
        local nCount = turtle.getItemCount(n)
        if nCount == 0 then
            bFull = false
        end
        nTotalItems = nTotalItems + nCount
    end

    if nTotalItems > collected then
        collected = nTotalItems
        if math.fmod(collected + unloaded, 50) == 0 then
            print( "Mined "..(collected + unloaded).." items." )
        end
    end

    if bFull then
        print( "No empty slots left." )
        return false
    end
    return true
end

function refuel( amount )
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
        return true
    end

    local needed = amount or 1
    if turtle.getFuelLevel() < needed then
        local fueled = false
        for n=1,maxSlot do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    while turtle.getItemCount(n) > 0 and turtle.getFuelLevel() < needed do
                        turtle.refuel(1)
                    end
                    if turtle.getFuelLevel() >= needed then
                        turtle.select(1)
                        return true
                    end
                end
            end
        end
        turtle.select(1)
        return false
    end

    return true
end

local function tryForwards()
    if not refuel() then
        print( "Not enough Fuel" )
        return false
    end

    while not turtle.forward() do
        if turtle.detect() then
            if turtle.dig() then
                if not collect() then
                    return false
                end
            else
                return false
            end
        elseif turtle.attack() then
            if not collect() then
                return false
            end
        else
            sleep( 0.5 )
        end
    end

    xPos = xPos + xDir
    zPos = zPos + zDir
    return true
end

local function tryDown()
    if not refuel() then
        print( "Not enough Fuel" )
        return false
    end

    while not turtle.down() do
        if turtle.detectDown() then
            if turtle.digDown() then
                if not collect() then
                    return false
                end
            else
                return false
            end
        elseif turtle.attackDown() then
            if not collect() then
                return false
            end
        else
            sleep( 0.5 )
        end
    end

    depth = depth + 1
    if math.fmod( depth, 10 ) == 0 then
        print( "Descended "..depth.." metres." )
    end

    return true
end

local function tryUp()
    if not refuel() then
        print( "Not enough Fuel" )
        return false
    end

    while not turtle.up() do
        if turtle.detectUp() then
            if turtle.digUp() then
                if not collect() then
                    return false
                end
            else
                return false
            end
        elseif turtle.attackUp() then
            if not collect() then
                return false
            end
        else
            sleep( 0.5 )
        end
    end

    depth = depth - 1
    if math.fmod( depth, 10 ) == 0 then
        print( "Ascended to "..depth.." metres." )
    end

    return true
end


local function turnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

local function turnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

local function turnAround()
    turnRight()
    turnRight()
end

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
            if turtle.compareTo(11) then
                return true
                -- if no cobblestone elsewhere (unlikely) then
                -- use slot 11 if more than one there
            elseif turtle.getItemCount(11) > 1 then
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
            turtle.select(16)
            turtle.place()
            turnLeft()
        end

        turtle.select(12) -- select ladder or vine
        turtle.placeUp()
    end
    return true;
end

local function pillarUp(n)
    -- collect ladders?
    for n=1,n do
        tryUp()
        if selectCobblestone() then
            turtle.placeDown()
        end
    end
end

-- placing torches every five blocks
local function digToSurface()
    while depth > 0 do

        if fmod(depth,5) == 0 then -- place torch forward
            turtle.dig()
            turtle.select(16)
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
pillarUp(3)

if not tryForwards() then
    print("Could not go forwards")
    return
end

if not tryUp() then
    print ("Could not go up")
    return
end

if not tryForwards() then
    print("Could not go forwards")
    return
end

-- go down one plus three more for the water pit
for n=1,4 do
    if not tryDown() then
        print("Could not go down")
        return
    end
end

-- for now place the three water buckets
-- an improvement later will be to use only two buckets to create
-- an infinite water trough and use that to generate three water
for n=1,3 do
    if not tryUp() then
        return
    end
    if not turtle.select(12+n) or not turtle.placeDown() then
        return
    end
end

digToSurface()
