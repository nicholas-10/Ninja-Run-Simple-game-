Map = Class{}

-- top layer of dirt with grass

MIDDLE_GRASS_DIRT = 1

-- spike
SPIKE = 3

-- middle layer of dirt
MIDDLE_DIRT = 2


EMPTY_TILE = 4

CRATE = 5

NEW_LEVEL_SIGN = 6
LEVEL_END_SIGN = 7

function Map:init()
    math.randomseed(os.time())
    self.camX = 0
    self.camY = 0


    self.mapWidth = 80
    self.mapHeight = 16
    self.tileWidth = 64
    self.tileHeight = 64
    self.tiles = {}

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    --player
    self.player = Player(self)

    self.spritesheet = love.graphics.newImage("background/Tiles/textures_final.png")

    self.sprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    
    self:generateMap()
end
-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
    self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:update(dt)
    self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
        math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
    -- if end goal is reached give points
    if self.player.x >= self.mapWidth * self.tileWidth - 64 then
      
        self.player.points = self.player.points + 500
    end
    self.player:update(dt)
end
function Map:render()


    for y = 1, self.mapHeight do
                
        
        for x = 1, self.mapWidth do
            
            love.graphics.draw(self.spritesheet, self.sprites[self:getTile(x, y)], (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
             
        end
    end
    if self.player.life == 0 then
        love.graphics.clear(0, 0, 0, 1)
        love.graphics.setFont(raleway_large)
        -- + 2 * map.camX. since center divides it by 2, you multiply it by 2 to off set it.
        -- not elegant but it works. Could I draw it on the window instead? IDK maybe
        love.graphics.printf("Game Over", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH + 2 * map.camX, 'center')
        love.graphics.setFont(raleway_regular)
        love.graphics.printf("Press enter to start again", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH + 2 * map.camX, 'center')
        self:generateMap()
        GAME_OVER = true
    end
    -- points on top right
    love.graphics.setFont(raleway_large)
    love.graphics.printf(self.player.points, 0, 0, VIRTUAL_WIDTH + 2 * map.camX, 'center')

    -- draws life icons
    for x = 1, self.player.life do 
        love.graphics.draw(life_icon, (x - 1) * life_icon:getWidth() * 1.2 + 32 + map.camX, 32)
    end
    if self.player.x >= self.mapWidth * self.tileWidth - 64 then
        self:generateMap()
        self.player.sounds['points']:play()
        self.player:reset()
        self.player.points = self.player.points + 500
    end
    self.player:render()
end
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        MIDDLE_GRASS_DIRT, MIDDLE_DIRT, CRATE
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end
    return false
end
function Map:collidesHurt(tile)
        -- define our collidable tiles
        local collidables = {
            SPIKE
        }
    
        -- iterate and return true if our tile type matches
        for _, v in ipairs(collidables) do
            if tile.id == v then
                return true
            end
        end
        return false
end
function Map:generateMap()
 
    --first fills all with empty tiles
   for a = 1, self.mapWidth do
       for b = 1, self.mapHeight do
           self:setTile(a, b, EMPTY_TILE)
       end
   end

   -- fill tile map with ground after a certain point
   for z = self.mapHeight / 2 + 2, self.mapHeight / 2 + 2 do 
       for y = 1, self.mapWidth do
               
           self:setTile(y, z, MIDDLE_GRASS_DIRT)

       end
   end
   -- fill rest of map with ground
   for z = self.mapHeight / 2 + 3, self.mapHeight do 
       for y = 1, self.mapWidth do
           self:setTile(y, z, MIDDLE_DIRT)
       end
   end

   local x = 1
   while x < self.mapWidth do
       -- puts a hole in map
       -- x > 6 so it's not too close to start, x < self.mapWidth - 7 so not too close to levels end
       if math.random(10) == 1 and x > 6 and self:getTile(x - 1, self.mapHeight / 2 + 2) ~= EMPTY_TILE and x < self.mapWidth - 7  then
           for z = self.mapHeight / 2 + 2, self.mapHeight do 
               self:setTile(x, z, EMPTY_TILE)
               self:setTile(x + 1, z, EMPTY_TILE)
               self:setTile(x + 2, z, EMPTY_TILE)

           end
           -- sets at least one tile as ground after a hole so the player can get over it
           self:setTile(x + 3, self.mapHeight / 2 + 2, MIDDLE_GRASS_DIRT)
           
           
       end
       if math.random(10) == 1 and x > 6 and x < self.mapWidth - 7 then
        self:setTile(x, self.mapHeight / 2 + 1, SPIKE)
       end
       --crate pyramid
       if math.random(15) == 1 and x > 6 and x < self.mapWidth - 7 then
            for a = 1, 5 do
                for b = 1, a do
                    self:setTile(x + a, self.mapHeight / 2 - b + 2, CRATE)
                end
   
            end
       end
       --signs
       if x == self.mapWidth - 2 then
            self:setTile(x, self.mapHeight / 2 + 1, LEVEL_END_SIGN)
       end
       if x == self.mapWidth - 1 then
            self:setTile(x, self.mapHeight / 2 + 1, NEW_LEVEL_SIGN)
       end
       x = x + 1

   end
end