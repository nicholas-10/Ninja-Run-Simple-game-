Enemies = Class{}

local player_speed = 200
local jump_speed = -800
local gravity = 15
local coyote = 16
local life = 3
local state2 = ''

function Enemies:init(map, x, y)

    self.width = 64
    self.height = 128
    self.map = map
    self.x = x
    self.y = y - self.height
    idle_frames_enemies = love.graphics.newImage("enemies/idle - Copia.png")
    idle_grid_enemies = anim8.newGrid(64, 128, 
        idle_frames_enemies:getWidth(), idle_frames_enemies:getHeight())
    idle_animation_enemies = anim8.newAnimation(idle_grid_enemies('1-7', 1), 0.2)
    
    math.randomseed(os.time())
end

function Enemies:render()
    idle_animation_enemies:draw(idle_frames_enemies, 
        self.x, self.y)
    --love.graphics.rectangle("line)
end

function Enemies:update(dt)
    idle_animation_enemies:update(dt)
end