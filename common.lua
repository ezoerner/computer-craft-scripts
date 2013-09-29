depth = 0
unloaded = 0
collected = 0

xPos,zPos = 0,0
xDir,zDir = 0,1

maxSlot = maxSlot or 16

function unload( _bKeepOneFuelStack )
    print( "Unloading items..." )
    for n=1,maxSlot do
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

function returnSupplies()
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

function collect()
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

    local needed = amount or (xPos + zPos + depth + 2)
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

function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end


function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            collect()
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

function tryForwards()
    if not refuel() then
        print( "Not enough Fuel" )
        returnSupplies()
    end

    while not turtle.forward() do
        if turtle.detect() then
            if turtle.dig() then
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

function tryDown()
    if not refuel() then
        print( "Not enough Fuel" )
        returnSupplies()
    end

    while not turtle.down() do
        if turtle.detectDown() then
            if turtle.digDown() then
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

function tryUp()
    if not refuel() then
        print( "Not enough Fuel" )
        return false
    end

    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
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


function turnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

function turnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

function turnAround()
    turnRight()
    turnRight()
end

-- use a designated slot with cobblestone in it to select any other
-- slot with cobblestone in it, using the designated cobblestone
-- slot as a last resort if there is no other
function selectCobblestone(designatedCobblestoneSlot)
    for n=1,maxSlot do
        if turtle.getItemCount(n) > 0 then
            turtle.select(n)
            -- prefer to use collected cobblestone instead of the cobblestone slot itself
            if turtle.compareTo(designatedCobblestoneSlot) then
                return true
            end
        end
    end

    -- if we get here there there is no cobblestone elsewhere in the inventory, so
    -- use the cobblestone slot directly if more than one there
    if turtle.getItemCount(designatedCobblestoneSlot) > 1 then
        turtle.select(designatedCobblestoneSlot)
        return true
    end
    return false
end

function goTo( x, y, z, xd, zd )
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
