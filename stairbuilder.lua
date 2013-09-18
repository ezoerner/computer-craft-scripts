local depth = 0
local unloaded = 0
local collected = 0

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local goTo -- Filled in further down
local refuel -- Filled in further down

local function unload( _bKeepOneFuelStack )
    print( "Unloading items..." )
    for n=1,16 do
        local nCount = turtle.getItemCount(n)
        if nCount > 0 then
            turtle.select(n)
            local bDrop = true
            if _bKeepOneFuelStack and turtle.refuel(0) then
                bDrop = false
                _bKeepOneFuelStack = false
            end
            if bDrop then
                turtle.drop()
                unloaded = unloaded + nCount
            end
        end
    end
    collected = 0
    turtle.select(1)
end

local function returnSupplies()
    local x,y,z,xd,zd = xPos,depth,zPos,xDir,zDir
    print( "Returning to surface..." )
    goTo( 0,0,0,0,-1 )

    local fuelNeeded = 2*(x+y+z) + 1
    if not refuel( fuelNeeded ) then
        unload( true )
        print( "Waiting for fuel" )
        while not refuel( fuelNeeded ) do
            sleep(1)
        end
    else
        unload( true )
    end

    print( "Resuming mining..." )
    goTo( x,y,z,xd,zd )
end

local function collect()
    local bFull = true
    local nTotalItems = 0
    for n=1,16 do
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

local function refuel( ammount )
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then
        return true
    end

    local needed = ammount or (xPos + zPos + depth + 2)
    if turtle.getFuelLevel() < needed then
        local fueled = false
        for n=1,16 do
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

local function tryForwards(dig)
    if not refuel() then
        print( "Not enough Fuel" )
        returnSupplies()
    end

    while not turtle.forward() do
        if turtle.detect() then
            if dig and turtle.dig() then
                if not collect() then
                    returnSupplies()
                end
            else
                return false
            end
        elseif turtle.attack() then
            if not collect() then
                returnSupplies()
            end
        else
            sleep( 0.5 )
        end
    end

    xPos = xPos + xDir
    zPos = zPos + zDir
    return true
end

local function tryDown(dig)
    if not refuel() then
        print( "Not enough Fuel" )
        returnSupplies()
    end

    while not turtle.down() do
        if turtle.detectDown() then
            if dig and turtle.digDown() then
                if not collect() then
                    returnSupplies()
                end
            else
                return false
            end
        elseif turtle.attackDown() then
            if not collect() then
                returnSupplies()
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

local function turnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

local function turnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

local function turnAround()
    turnLeft()
    turnLeft()
end

local function placeBack()
    turnAround()
    local success = turtle.place()
    turnAround()
    return success
end

local function goTo( x, y, z, xd, zd )
    while depth > y do
        if turtle.up() then
            depth = depth - 1
        elseif turtle.digUp() or turtle.attackUp() then
            collect()
        else
            sleep( 0.5 )
        end
    end

    if xPos > x then
        while xDir ~= -1 do
            turnLeft()
        end
        while xPos > x do
            if turtle.forward() then
                xPos = xPos - 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep( 0.5 )
            end
        end
    elseif xPos < x then
        while xDir ~= 1 do
            turnLeft()
        end
        while xPos < x do
            if turtle.forward() then
                xPos = xPos + 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep( 0.5 )
            end
        end
    end

    if zPos > z then
        while zDir ~= -1 do
            turnLeft()
        end
        while zPos > z do
            if turtle.forward() then
                zPos = zPos - 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep( 0.5 )
            end
        end
    elseif zPos < z then
        while zDir ~= 1 do
            turnLeft()
        end
        while zPos < z do
            if turtle.forward() then
                zPos = zPos + 1
            elseif turtle.dig() or turtle.attack() then
                collect()
            else
                sleep( 0.5 )
            end
        end
    end

    while depth < y do
        if turtle.down() then
            depth = depth + 1
        elseif turtle.digDown() or turtle.attackDown() then
            collect()
        else
            sleep( 0.5 )
        end
    end

    while zDir ~= zd or xDir ~= xd do
        turnLeft()
    end
end

-- turtle starts in a corner of a square excavation with front in the direction to start
-- the stairs. This version always builds in clockwise direction
if not refuel() then
    print( "Out of Fuel" )
    return
end

turtle.select(1)
turtle.digDown()
tryDown(false)

local done = false

while not done do

    if not tryForwards(false) then
        turnRight()
        if not tryForwards(false) then
            break
        end
    end

    turtle.select(1)
    if not placeBack() then
        turtle.select(2)
        if not placeBack() then
            break
        end
    end
    turtle.select(1)
    
    if not tryDown(false) then
        break
    end
end

-- Return to where we started
goTo( 0,0,0,0,1 )
