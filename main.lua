LIP = require "lib.utils.LIP"
json = require "lib.utils.json"
file = require "lib.utils.file"
tween = require "lib.utils.tween"

ComicPanel = require "lib.core.ComicPanel"
Rope = require "lib.core.rope"
Button = require "lib.utils.Button"

mouse = { x = 0, y = 0, dx = 0, dy = 0, pressed = false }

panels = {}
panel_index = 1

stitch_region_group = {

}

-- stitch_regions = {}
active_stitch_index = 1

function cursorInCircle(x, y, center_x, center_y, radius)
    return ((x-center_x)^2 + (y - center_y)^2) < radius^2
end

function love.load()
    love.window.setTitle("Blood Sewn")
    love.window.setMode(1920, 1080)
    
    love.mouse.setCursor(love.mouse.newCursor("res/needlecursor.png", 0, 0))
    settings = json.decode(file.readall('config/settings.json'))
    debug_text = settings.Misc.debug

    -- panel_config = json.decode(file.readall('intro.json'))
    -- for key, value in ipairs(panel_config) do        
    --     debug_text = value.image
    --     panels[key] = ComicPanel:new(love.graphics.newImage(value.image), value.x, value.y, value.duration, value.transition)
    -- end

    -- stitch_regions = json.decode(file.readall('levels/level1_hand_wound1.json'))  
    -- level 1
    table.insert(stitch_region_group, json.decode(file.readall('levels/level1_hand_wound1.json')))

    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            value.cleared = false
        end
    end

    if panels[panel_index]~=nil then
        panels[panel_index]:start()
    end

    rope1 = Rope(love.graphics.getWidth()*.25, 100, 300, 25, 10)
	rope1.fixLastPoint = true
	rope1:moveLastPoint(love.graphics.getWidth()*.5, love.graphics.getHeight()*1)

    -- set up for levels
    img_heart_gauge = love.graphics.newImage("res/ui/Heart Gauge.png")
    img_mortician = love.graphics.newImage("res/ui/Mortician.png")
    img_vignette = love.graphics.newImage("res/ui/Vignette.png")
    img_hand = love.graphics.newImage("res/levels/Hand.png")
    img_hand_wound = love.graphics.newImage("res/levels/Hand_Wound.png")
    btn_next = Button:new("btn_next", 0, 0, nil, nil, love.graphics.newImage("res/ui/Next Button.png"))
end


function love.draw()
    love.graphics.setColor(255,255,255)
    for key, value in ipairs(panels) do
        panels[key]:draw()
    end
    love.graphics.draw(img_hand, 0,0)
    love.graphics.draw(img_hand_wound, 0,0)
    btn_next:draw()
    love.graphics.draw(img_heart_gauge, 0,0)
    love.graphics.draw(img_mortician, 0,0)
    love.graphics.draw(img_vignette, 0,0)

    if settings.Misc.debug == 1 then
        love.graphics.setColor(255,255,255)
        if debug_text ~= nil then
            love.graphics.print(debug_text, 500, 20)
        end
        pressed_text = ""
        if mouse.pressed then pressed_text = "True" else pressed_text = "False" end
        love.graphics.print("x: "..mouse.x.." y: "..mouse.y.." pressed: "..pressed_text, 500, 40)
    end
    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            if value.cleared == true then
                love.graphics.setColor(220/255,0,0, 1)
            else
                love.graphics.setColor(120/255,120/255,120/255, 1)
            end
            love.graphics.circle('fill', value.x, value.y, 10 )        
        end
    end

    rope1:draw()
end

function love.update(dt)
    rope1:update(dt)
    for key, value in ipairs(panels) do
        value:update(dt)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse.x = x
    mouse.y = y
    mouse.dx = dx
    mouse.dy = dy
	rope1:moveFirstPoint(mouse.x + 30, mouse.y + 30)    
    
    debug_text = "Out of Circle, active_stitch_index: "..active_stitch_index
    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            if cursorInCircle(x, y, value.x, value.y, 10) then
                debug_text = "In Circle, active_stitch_index: "..active_stitch_index
                if mouse.pressed then
                    active_stitch_index = i
                    value.cleared = true
                end
            end
        end
    end
end

function love.keypressed(key, u)
    --Debug
    if key == "rctrl" then --set to whatever key you want to use
       debug.debug()
    end
    if key == "space" then
        print(json.encode(stitch_regions))
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mouse.pressed = true
        panel_index = panel_index + 1
        if panels[panel_index] ~= nil then
            panels[panel_index]:start()
        end    
        if panel_index > #panels then
            for key, value in ipairs(panels) do
                panels[key]:stop()
            end
            -- transition to gameplay here
        end

        -- for debugging and setting up levels only
        -- table.insert(stitch_regions, {x=x, y=y})
    end
end

function love.mousereleased( x, y, button, istouch, presses )
    mouse.pressed = false
    if checkAllClear(stitch_region_group[active_stitch_index]) == false then
        resetRegions(stitch_region_group[active_stitch_index])
    end
    
    all_clear = true
    for key, stitch_region in ipairs(stitch_region_group) do
        if checkAllClear(stitch_region) == false then all_clear = false end
    end
    if all_clear then print("All regions cleared!") end
end

function checkAllClear(stitch_region)
    flag = true
    for key, value in ipairs(stitch_region) do
        if value.cleared == false then
            flag = false
        end
    end
    return flag
end

function resetRegions(stitch_region)    
    for key, value in ipairs(stitch_region) do
        value.cleared = false
    end    
end