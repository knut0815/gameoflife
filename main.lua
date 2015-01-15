math.randomseed(os.time())
math.random(); math.random(); math.random()

function love.keypressed(key)
  if key == 'escape' then
    love.event.push("quit")
  elseif not (key == "up" or key == "down" or key == "right" or key == "left") then
    run = not run
  end
end

function love.mousepressed(x, y, button)
  if button == "r" then
    love.load()
  elseif button == "wu" or button == "wd" then
     if run then
       run = false
     end
     update()
  else
    run = not run
  end
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function love.load()
  
  run = false
  xoff = 0      -- view offset
  yoff = 0
  speed = 300   -- view move speed
  line_x = nil  -- red/blue winning line position
  
  livecells = {}      -- holds the live cells for the current genertation
  newlivecells = {}   -- holds all cells that live/born to the next generattion
  deadcells = {}      -- holds dead cells that could be changed in next generation
  newdeadcells = {}   -- holds cells that were alive but died

  grid = {}
  grid.x = 0
  grid.y = 0
  grid.rows = 120
  grid.cols = 160
  grid.width = love.graphics.getWidth()
  grid.height= love.graphics.getHeight()
  grid.row_height = grid.height/grid.rows
  grid.col_width = grid.width/grid.cols
  
  -- fill the grid with cells
  for j=1,grid.rows do
    grid[j] = {}
    for i=1,grid.cols do
      local cell = cell:new()
      cell.grid_x = i
      cell.grid_y = j
      cell.x = grid.x + (i-1)*grid.col_width
      cell.y = grid.y + (j-1)*grid.row_height
      
      grid[j][i] = cell
    end
  end
  
  
  -- set the neighbours of each cell
  for j=1,grid.rows do
    for i=1,grid.cols do
      local cell = grid[j][i]
      
      -- loop through surrounding neighbours of the cell
      for y=j-1,j+1 do
        for x=i-1,i+1 do
          
          -- don't add cell as a neighbour if the neighbour is the cell itself
          if (not (x == i and y == j)) then
          
            -- dont add the cell as a neighbour if it is an outside corner cell
            if not (x == 0 and y == 0) and
               not (x == grid.cols + 1 and y == 0) and
               not (x == 0 and y == grid.rows + 1) and
               not (x == grid.cols + 1 and y == grid.rows + 1) then
              
              -- coordinate corrections for map wrap around
              if x == 0 then x = grid.cols end
              if x == grid.cols + 1 then x = 1 end
              if y == 0 then y = grid.rows end
              if y == grid.rows + 1 then y = 1 end
              
              cell.neighbours[#cell.neighbours+1] = grid[y][x]
              
            end
          end
          
        end
      end
    end
  end
  

  
  -- create some living cells to start with  
  if true then
    local sep = 5
    local ymin = 20
    local ymax = 100
    for i=ymin,ymax do
      grid[i][grid.cols/2 - sep].state = 1
      livecells[#livecells+1] = grid[i][grid.cols/2 - sep]
    end
    
    for j=1,119 do
      local sep2 = math.random(-2,2)
      local i = grid.cols/2 + sep2
      grid[j][i].state = 1
      grid[j][i].faction = math.random(0,1)
      livecells[#livecells+1] = grid[j][i]
    end
    
    for j=ymin,ymax do
      local sep2 = math.random(-1,1)
      local i = grid.cols/2 + sep2 + 20
      grid[j][i].state = 1
      grid[j][i].faction = 1
      livecells[#livecells+1] = grid[j][i]
    end
    
    for j=ymin,ymax do
      local sep2 = math.random(-1,1)
      local i = grid.cols/2 + sep2 - 20
      grid[j][i].state = 1
      grid[j][i].faction = 0
      livecells[#livecells+1] = grid[j][i]
    end
    
    for j=ymin,ymax do
      local i = grid.cols/2 + sep
      grid[j][i].state = 1
      grid[j][i].faction = 1
      livecells[#livecells+1] = grid[j][i]
    end
  end
  
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function love.update(dt)
  if love.keyboard.isDown(' ') or run == true then
    -- updates to the next generation
    update()
  end
  
  -- controls x,y offsets
  if love.keyboard.isDown('left') then
    xoff = xoff + speed*dt
    if xoff > grid.width then
      xoff = xoff - grid.width
    end
  end
  if love.keyboard.isDown('right') then
    xoff = xoff - speed*dt
    if xoff < -grid.width then
      xoff = xoff + grid.width
    end
  end
  if love.keyboard.isDown('down') then
    yoff = yoff - speed*dt
    if yoff < -grid.height then
      yoff = yoff + grid.height
    end
  end
  if love.keyboard.isDown('up') then
    yoff = yoff + speed*dt
    if yoff > grid.height then
      yoff = yoff - grid.height
    end
  end
  
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function love.draw()

  love.graphics.setBackgroundColor(255,255,255,255)

  love.graphics.setColor(0,0,255,255)
  local num_red = 0
  local num_blue = 0
  for i=1,#livecells do
    local v = livecells[i]
    if v.faction == 0 then
      love.graphics.setColor(20,0,255,255)
      num_blue = num_blue + 1
    else
      love.graphics.setColor(255,0,20,255)
      num_red = num_red + 1
    end
    
    
    local x = v.x+1 + xoff
    if x > grid.width then
      x = x - grid.width
    end
    if x < 0 then
      x = x + grid.width
    end
    
    local y = v.y+1 + yoff
    if y > grid.height then
      y = y - grid.height
    end
    if y < 0 then
      y = y + grid.height
    end
    
    love.graphics.rectangle('fill', x, y, 
                              grid.col_width-2, grid.row_height-2)
  end

  local pct_red = num_red / (num_red + num_blue)
  local w = love.graphics.getWidth()
  local h = 20
  local maxv = 50
  line_x = line_x or pct_red*w
  
  if (math.abs(line_x - pct_red*w)/love.timer.getDelta() > maxv) then
    if pct_red*w - line_x > 0 then
      line_x = line_x + maxv*love.timer.getDelta()
    else
      line_x = line_x - maxv*love.timer.getDelta()
    end
  else
    line_x = pct_red*w
  end
  
  local lg = love.graphics
  lg.setColor(255, 0, 0, 100)
  lg.rectangle("fill", 0, 0, line_x, h)
  lg.setColor(0, 0, 255, 100)
  lg.rectangle("fill", line_x, 0, w - line_x, h)
  
end



--##########################################################################--
--[[----------------------------------------------------------------------]]--
-- cell object
--[[----------------------------------------------------------------------]]--
--##########################################################################--
  
cell = {}
cell.x = nil            -- position in pixels
cell.y = nil
cell.grid_x = nil       -- coordinate position on grid
cell.grid_y = nil
cell.state = 0          -- alive == 1, dead == 0
cell.next_state = nil   -- holds the state for the next generation
cell.neighbours = nil   -- table of all cells that are neighbours of this cell
cell.count = 0          -- a count of all neighbours
cell.inlist = false     -- whether the cell has been added to a deadcells list
cell.faction = 0        -- blue = 0, red = 1  


cell_mt = { __index = cell }
function cell:new()
  local neighbours = {}
  return setmetatable({ neighbours = neighbours }, cell_mt)
end

-- counts the live neighbours of the cell
-- if the neighbour is dead, the dead cell is added to list of deadcells
-- and a count is added to the dead cell indicating that a live neighbour is
-- next to it
function cell:count_neighbours()

  for i=1,#self.neighbours do
    local cell = self.neighbours[i]
    if     cell.state == 0 then
      cell.count = cell.count + 1
      if cell.inlist == false then
        cell.inlist = true
        deadcells[#deadcells+1] = cell
      end
    elseif cell.state == 1 then
      self.count = self.count + 1
    end
  end
end


-- reset counter/commit any state changes
function cell:refresh()
  self.count = 0
  self.inlist = false
  self.state = self.next_state
  self.next_state = nil
end



--------------------------------------------------------------------------------
-- updates all cells for the next generation of life
function update()
  deadcells = {}      -- holds dead cells that could be changed in next generation
  newlivecells = {}   -- holds all cells that live/born to the next generattion
  newdeadcells = {}   -- holds cells that were alive but died

  -- update live cells
  for i=#livecells,1,-1 do
    local cell = livecells[i]
    cell:count_neighbours()
    
    if cell.count < 2 or cell.count > 3 then
      -- if a live cell dies, add it to newdeadcells
      cell.next_state = 0
      newdeadcells[#newdeadcells+1] = cell
    else
      cell.next_state = 1
      newlivecells[#newlivecells+1] = cell
    end
  end
  
  -- update dead cells
  local length = #deadcells
  for i=length,1,-1 do
    local cell = deadcells[i]
    
    -- A cell is born when it has exactly 3 live neighbours
    if cell.count == 3 then
      cell.next_state = 1
      
      -- cell takes on to color of the majority of its live neighbours
      local bluecount = 0
      local redcount = 0
      for n=1,#cell.neighbours do
        local neighbour = cell.neighbours[n]
        if neighbour.state == 1 then
          if neighbour.faction == 0 then
            bluecount = bluecount + 1
          else
            redcount = redcount + 1
          end
        end
      end
      
      if bluecount > redcount then cell.faction = 0 else cell.faction = 1 end
      
      -- add born cell to newlivecells and remove from deadcells
      newlivecells[#newlivecells+1] = cell
      table.remove(deadcells,i)
    end
  end
  
  -- commit changes to each altered cell
  for i=1,#newlivecells do newlivecells[i]:refresh() end
  for i=1,#deadcells do deadcells[i]:refresh() end
  for i=1,#newdeadcells do newdeadcells[i]:refresh() end
  
  livecells = newlivecells
  
end





















