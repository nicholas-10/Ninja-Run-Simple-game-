Player = Class{}

local player_speed = 300
local jump_speed = -800
local gravity = 15
local coyote = 16
local life = 3
local state2 = ''

-- the system for delays seems a bit mess
local immune = false
local clock_is_set = false
function Player:init(map)
    self.map = map
    self.points = 0
    self.x = 128
    self.y =  VIRTUAL_HEIGHT - 10 * self.map.tileWidth
    self.state = 'jumping'
    self.life = life
    self.dx = 0
    self.dy = 0

    
    self.height = 124
    self.width = 64

    --note rotation is used as scalex in draw function
    self.rotation = 1
    
    self.sounds = {
        ['hit'] = love.audio.newSource('Audio/Hit_Hurt29.wav', 'static'),
        ['jump'] = love.audio.newSource('Audio/Jump2.wav', 'static'),
        ['points'] = love.audio.newSource('Audio/Pickup_Coin5.wav', 'static'),
        ['death'] = love.audio.newSource('Audio/Explosion3.wav', 'static'),
        ['attack'] = love.audio.newSource('Audio/attack.wav', 'static')
    }
   

    --loads sprites and puts them into quads
    --and sets up everything needed for animation
    idle_frames = love.graphics.newImage("ninja/idle_spritesheet.png")
    idle_grid = anim8.newGrid(idle_frames:getWidth() * 0.5, idle_frames:getHeight(),
        idle_frames:getWidth(), idle_frames:getHeight())
    idle_animation = anim8.newAnimation(idle_grid('1-2', 1), 0.2)

    walk_frames = love.graphics.newImage("ninja/walk_spritesheet.png")
    walk_grid = anim8.newGrid(walk_frames:getWidth() * 0.25, walk_frames:getHeight(),
        walk_frames:getWidth(), walk_frames:getHeight())
    walk_animation = anim8.newAnimation(walk_grid('1-4', 1), 0.2)

    jump_frames = love.graphics.newImage("ninja/jumpfall_spritesheet.png")
    jump_grid = anim8.newGrid(jump_frames:getWidth() * 1/2, jump_frames:getHeight(),
        jump_frames:getWidth(), jump_frames:getHeight())
    jump_animation = anim8.newAnimation(jump_grid('1-2', 1), 1)

    hurt_frames = love.graphics.newImage("ninja/hurt_spritesheet.png")
    hurt_grid = anim8.newGrid(84, hurt_frames:getHeight(),
        hurt_frames:getWidth(), hurt_frames:getHeight())
    hurt_animation = anim8.newAnimation(hurt_grid('1-3',  1), {['1-3'] = 0.1}, 
        function () 
            self.state = state2 
            self.life = self.life - 1
            immune_clock = cron.after(2, function () immune = false end)
            clock_is_set = true
        end)
    
    attack_frames = love.graphics.newImage("ninja/attack_spritesheet_v2.png")
    attack_grid = anim8.newGrid(159, 124,
        attack_frames:getWidth(), attack_frames:getHeight())
    attack_animation = anim8.newAnimation(attack_grid('1-3', 1), {['1-2'] = 0.01, ['2-3'] = 0.05}, function () self.state = state2 end)

    death_frames = love.graphics.newImage("ninja/death_spritesheet_v2.png")
    death_grid = anim8.newGrid(death_frames:getWidth() / 8, death_frames:getHeight(),
        death_frames:getWidth(), death_frames:getHeight())
    death_animation = anim8.newAnimation(death_grid('1-8', 1), {['1-8'] = 0.15}, function ()
        self.life = self.life - 1
    end)

    life_icon = love.graphics.newImage("ninja/life_icon.png")

    -- for rotation
    self.offsetX = 32
    self.offsetY = 132

    self.general = {
        
    }
    self.behaviors = {
        ['idle'] = function (dt)
            
            if love.keyboard.isDown('right') then
                self.state = 'walking'
                rotation = 1
            elseif love.keyboard.isDown('left') then
                self.state = 'walking'
                rotation = -1
            elseif love.keyboard.wasPressed('space') then
                self.dy = jump_speed
                self.state = 'jumping'
                self.sounds['jump']:play()
            end

            -- attack 
            if love.keyboard.wasPressed('x') then
                self.state = 'attacking'
                self.sounds['attack']:play()
            end
            state2 = 'idle'
            -- if there's a block bellow it then stop falling
            if (self.map:collides(self.map:tileAt(self.x, self.y  + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width, self.y  + self.height))) and self.dy > 0 then
                        
            -- if so, reset velocity and position and change state
                self.dy = 0

            end
        end,
        ['walking'] = function (dt)
     
            if love.keyboard.isDown('right') then
                rotation = 1
                self.dx = player_speed
                self.state = 'walking'
                -- so player can't walk through walls
                self:checkRightCollision()
                if immune == false then
                    self:checkRightHurtCollision()
                end
      
            elseif love.keyboard.isDown('left') then
                rotation = -1
                
                self.dx = -player_speed
                
                self.state = 'walking'      
                self:checkLeftCollision()
                if immune == false then
                    self:checkLeftHurtCollision()
                end                    
            else
                self.dx = 0
                self.state = 'idle'
            
            end
            self:checkRightCollision()
            self:checkLeftCollision()
            --check if standing on grass of not
            if (self.map:collides(self.map:tileAt(self.x + self.width , self.y  + self.height)) ~= true) and 
                (self.map:collides(self.map:tileAt(self.x , self.y  + self.height)) ~= true) then
                        
            -- if not, set state to jumping so character falls
                self.state = 'jumping'
            end      

            if love.keyboard.wasPressed('space') then
                self.dy = jump_speed
                self.sounds['jump']:play()
                self.state = 'jumping'
                
            end
            -- dont actually need this... i think
            if (self.map:collidesHurt(self.map:tileAt(self.x, self.y + self.height + 1)) or
                self.map:collidesHurt(self.map:tileAt(self.x + self.width, self.y + self.height + 1))) and immune == false then
                immune = true
                self.state = 'hurting'
             
            end

            -- attack 
            if love.keyboard.wasPressed('x') then
                self.state = 'attacking'
                self.sounds['attack']:play()
            end
            
 
            state2 = 'walking'
        end,
        ['jumping'] = function (dt)

            if love.keyboard.isDown('right') then
                rotation = 1
                self.dx = player_speed   
                self:checkRightCollision()
       
            elseif love.keyboard.isDown('left') then
                rotation = -1
                self.dx = -player_speed              
                self:checkLeftCollision()
            end
            -- so it doesnt teleport
            self:checkLeftCollision()
            self:checkRightCollision()
            if immune == false then

                self:checkRightHurtCollision()  
                self:checkLeftHurtCollision()
            end
            -- if he is jumping set to jumping animation
            if self.state == 'jumping' then
                jump_animation:pauseAtStart()
            end

            -- if he's falling set to falling animation
            if self.dy >= 0 then
                jump_animation:pauseAtEnd()
            end

            self.dy =  self.dy + gravity

            if (self.map:collidesHurt(self.map:tileAt(self.x + self.width, self.y + self.height)) or
                self.map:collidesHurt(self.map:tileAt(self.x + self.width, self.y + self.height))) and immune == false then
          
                immune = true
                self.state = 'hurting'
                
            end


            -- if there's a block bellow it then stop falling
                -- not perfectly at edge so that it doesn't interfere with other code
                -- if the collision detection is perfectly at edge it sort of goes in to the block?? I think.
                    -- So the game thinks he's standing on a block, but it looks like he's standing in mid air to the player
            if self.map:collides(self.map:tileAt(self.x + 1 , self.y  + self.height)) or self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then
                self.dy = 0
                self.dx = 0
                self.state = 'idle'
      
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            --so he doesnt just teleport back after falling out of the world
            if self.y > 2 * VIRTUAL_HEIGHT then
                self:respawn()
                self.sounds['hit']:play()
            end
            if love.keyboard.wasPressed('x') then
                self.state = 'attacking'
                self.sounds['attack']:play()
            end
            state2 = 'jumping'

        end,
        ['hurting'] = function (dt)  
            self.dx = 0
            self.dy = 0

            -- if there's a block bellow it then stop falling
            if self.map:collides(self.map:tileAt(self.x, self.y  + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width, self.y  + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.dy = 0
                self.dx = 0 
            end

            
      
            
        end,

        ['attacking'] = function (dt)
            if self.map:collidesHurt(self.map:tileAt(self.x, self.y + self.height + 1)) or
                self.map:collidesHurt(self.map:tileAt(self.x + self.width, self.y + self.height + 1)) then
                self.state = 'hurting'
            end
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or 
                self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height)) then
                self.dy = 0
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

        end,

        ['game_over'] = function (dt)
            if love.keyboard.wasPressed('return') then
                self:reset()
            
            end
        end
    }
end


function Player:render()
    --debug collisions
    --love.graphics.rectangle('line', self.x, self.y, self.width, self.height)

    --draw the character depending on it's state
    -- why does it render it from it's center point???
    if self.state == 'idle' then
        idle_animation:draw(idle_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
    elseif  self.state == 'walking' then
        walk_animation:draw(walk_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
    elseif self.state == 'jumping' then
        jump_animation:draw(jump_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
    elseif self.state == 'hurting' then
        if self.life == 1 then
            death_animation:draw(death_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
        else    
            hurt_animation:draw(hurt_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
        end
    elseif self.state == 'attacking' then
        attack_animation:draw(attack_frames, self.x + 0.5 * self.width, self.y, 0, rotation, 1, self.offsetX, 0)
    end
    
end
function Player:update(dt)
    self.behaviors[self.state](dt)

    if self.life == 0 then
        self.state = 'game_over'
    end
    if self.state == 'idle' then
        idle_animation:update(dt)
    elseif  self.state == 'walking' then
        walk_animation:update(dt) 
    elseif self.state == 'jumping' then
        jump_animation:update(dt)
    elseif self.state == 'hurting' then
        if self.life == 1 then
            self.sounds['death']:play()
            death_animation:update(dt)
        else
            self.sounds['hit']:play()
            hurt_animation:update(dt)
        end
    elseif self.state == 'attacking' then
        attack_animation:update(dt)
    end
    if clock_is_set then
        immune_clock:update(dt)
    end
    self.x = math.max(0, self.x)
    self.x = math.min(self.map.mapWidthPixels - self.width, self.x)
    --update x and y position
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end
--for later
-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 3)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
            
        end
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly beneath us
        if self.map:collides(self.map:tileAt(self.x + self.width + 1, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width + 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self.dx = 0
        end
   
    end
end
function Player:checkRightHurtCollision()
    

        
        if self.map:collidesHurt(self.map:tileAt(self.x + self.width + 1, self.y)) or
            self.map:collidesHurt(self.map:tileAt(self.x + self.width + 1, self.y + self.height - 1)) then
                immune = true
            self.state = 'hurting'
        end
    

end
function Player:checkLeftHurtCollision()
    
        
        if self.map:collidesHurt(self.map:tileAt(self.x - 1, self.y)) or
            self.map:collidesHurt(self.map:tileAt(self.x - 1, self.y + self.height - 3)) then
            immune = true
            self.state = 'hurting'
        end
  
end
function Player:respawn()
    self.x = 128
    self.y =  VIRTUAL_HEIGHT - 10 * self.map.tileWidth
    self.state = 'jumping'
    self.dx = 0
    self.dy = 0
    rotation = 1
    self.life = self.life - 1
end

-- resets game
function Player:reset()
    self.x = 128
    self.y =  VIRTUAL_HEIGHT - 10 * self.map.tileWidth
    self.state = 'jumping'
    self.life = life
    self.dx = 0
    self.dy = 0
    self.points = 0
    GAME_OVER = false
end
