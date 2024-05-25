LIP = require "lib.utils.LIP"
json = require "lib.utils.json"
file = require "lib.utils.file"
tween = require "lib.utils.tween"

ComicPanel = require "lib.core.ComicPanel"
Rope = require "lib.core.rope"

mouse = { x = 0, y = 0, dx = 0, dy = 0, pressed = false }

panels = {}
panel_index = 1

function love.load()
    love.window.setTitle("Blood Sewn")
    love.window.setMode(1920, 1080)
    
    love.mouse.setCursor(love.mouse.newCursor("res/needlecursor.png", 0, 0))
    -- settings = LIP.load("config/Settings.ini")
    -- debug_text = file.readall('config/test.json')
    settings = json.decode(file.readall('config/settings.json'))
    debug_text = settings.Misc.debug

    panel_config = json.decode(file.readall('intro.json'))
    for key, value in ipairs(panel_config) do        
        debug_text = value.image
        panels[key] = ComicPanel:new(love.graphics.newImage(value.image), value.x, value.y, value.duration, value.transition)
    end
    -- panel1 = ComicPanel:new(love.graphics.newImage("res/test/panel1.png"), nil,nil, 1, "from_bottom")
    -- panel1.x = 50
    -- panel1.y = 50
    panels[panel_index]:start()

    rope1 = Rope(love.graphics.getWidth()*.25, 100, 300, 25, 10)
	rope1.fixLastPoint = true
	rope1:moveLastPoint(love.graphics.getWidth()*.5, love.graphics.getHeight()*1)
end


function love.draw()
    for key, value in ipairs(panels) do
        panels[key]:draw()
    end
    -- love.graphics.setColor(135 / 255, 76 / 255, 71 / 255, 1)
    -- panel1:draw()
    -- love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 1)    
    rope1:draw()

    if settings.Misc.debug == 1 then
        love.graphics.setColor(255,255,255)
        if debug_text ~= nil then
            love.graphics.print(debug_text, 500, 20)
        end
        love.graphics.print("x: "..mouse.x.." y: "..mouse.y, 500, 40)
    end
end

function love.update(dt)
    rope1:update(dt)
    for key, value in ipairs(panels) do
        value:update(dt)
    end
    -- panel1:update(dt)
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse.x = x
    mouse.y = y
    mouse.dx = dx
    mouse.dy = dy
	rope1:moveFirstPoint(mouse.x + 30, mouse.y + 30)
end

function love.keypressed(key, u)
    --Debug
    if key == "rctrl" then --set to whatever key you want to use
       debug.debug()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        panel_index = panel_index + 1
        if panels[panel_index] ~= nil then
            panels[panel_index]:start()
        end
    end
end