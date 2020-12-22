WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 1280, 720

GAME_OVER = false

push = require 'push'
Class = require 'class'
anim8 = require 'anim8'
gamera = require 'gamera'
cron = require 'cron'

require 'Map'
require 'player'
require 'enemies'
require 'Util'
map = Map()


function love.load()
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    

    -- loads background image
    background = love.graphics.newImage("background/BG/BG.png")
    background:setWrap('repeat', 'repeat')
    background_quad = love.graphics.newQuad(0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT,
         background:getWidth(), background:getHeight())

    --basic features
    love.window.setTitle("Ninja Run")
    

    --might use spritebatch later but I've spent hours trying to get the damn background to work
    -- spriteBatch = love.graphics.newSpriteBatch(background )

    --text (fonts, size, etc)
    love.graphics.setDefaultFilter('nearest', 'nearest')
    raleway_regular = love.graphics.newFont("fonts/Raleway-Regular.ttf", 12)
    raleway_large = love.graphics.newFont("fonts/Raleway-Regular.ttf", 72)



    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    love.keyboard.keysPressed[key] = true
end
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.resize(w, h)
    push:resize(w, h)
end
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.draw()
    push:apply('start')

    -- for i = 0, love.graphics.getWidth() / background:getWidth() do
    --     for j = 0, love.graphics.getHeight() / background:getHeight() do
    --         love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
    --     end
    -- end
    love.graphics.draw(background, background_quad, 0, 0)
    
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    
    map:render()
    push:apply('end')
end

function love.update(dt)
    map:update(dt)
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

function dividedInto(divided_into, image_width)
    return image_width * (1 / divided_into)
    
end