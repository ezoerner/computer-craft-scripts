local tArgs = { ... }
local n = tonumber(tArgs[1])
local h = tonumber(tArgs[2])
local selected = 1

for tier = 1,h do
  for side = 1,4 do
    local numBlocks;
    if side == 1 then
      numBlocks = n
    else
      numBlocks = n - 1
    end
  
    for i = 1,numBlocks do
    
      while turtle.getItemCount(selected) == 0 do
        print("Searching for building materials...")
        selected = selected + 1
        if selected == 17 then
          selected = 1
        end
        turtle.select(selected)
      end
      
      turtle.place()
      turtle.back()
    end
    
    if side < 4 then
      turtle.turnLeft()
      turtle.back()
      turtle.turnLeft()
      turtle.back()
      turtle.back()
      turtle.turnRight()
      turtle.back()
    else
      turtle.turnRight()
      turtle.back()
      turtle.place()
      turtle.up()
      turtle.forward()
      turtle.turnLeft()
      turtle.back()
      turtle.turnLeft()
      turtle.back()
    end
  end
end
