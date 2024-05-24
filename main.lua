LIP = require "lib.utils.LIP"
json = require "lib.utils.json"
file = require "lib.utils.file"

ComicPanel = require "lib.core.ComicPanel"
Rope = require "lib.core.rope"

mouse = { x = 0, y = 0, dx = 0, dy = 0, pressed = false }

function love.load()
    love.window.setTitle("Blood Thread")
    love.window.setMode(1920, 1080)
    settings = LIP.load("config/Settings.ini")
    -- debug_text = file.readall('config/test.json')
    test = json.decode(file.readall('config/test.json'))
    debug_text = test.Misc.debug
    panel1 = ComicPanel:new(love.graphics.newImage("res/test/panel1.png"))

    rope1 = Rope(love.graphics.getWidth()*.25, 100, 300, 25, 10)
	rope1.fixLastPoint = true
	rope1:moveLastPoint(love.graphics.getWidth()*.5, love.graphics.getHeight()*1)
end


function love.draw()    
    -- love.graphics.setColor(135 / 255, 76 / 255, 71 / 255, 1)
    if settings["Misc"].debug == 1 then
        if debug_text ~= nil then
            love.graphics.print(debug_text, 500, 20)
        end
        love.graphics.print("x: "..mouse.x.." y: "..mouse.y, 500, 40)
    end
    -- panel1:draw(40, 40)
    -- love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 1)    
    rope1:draw()
end

function love.update(dt)
    rope1:update(dt)
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse.x = x
    mouse.y = y
    mouse.dx = dx
    mouse.dy = dy    
	rope1:moveFirstPoint(mouse.x, mouse.y)
end

function love.keypressed(key, u)
    --Debug
    if key == "rctrl" then --set to whatever key you want to use
       debug.debug()
    end
 end