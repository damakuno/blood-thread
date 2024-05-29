LIP = require "lib.utils.LIP"
json = require "lib.utils.json"
file = require "lib.utils.file"
tween = require "lib.utils.tween"
Button = require "lib.utils.Button"
Audio = require "lib.utils.Audio"


ComicPanel = require "lib.core.ComicPanel"
Rope = require "lib.core.rope"
push = require "lib.utils.push"

mouse = { x = 0, y = 0, dx = 0, dy = 0, pressed = false }
scaled_mouse = {x = 0, y = 0}

game_end = false
panels = {}
panel_index = 1
chapter_index = 1

current_level = 0

stitch_radius = 10

stitch_region_group = {

}

current_body = {
    body_image = nil,
    wound_image =  nil
}

level_cleared = false

-- debug only
stitch_regions = {}

active_stitch_index = 0

wound_images_config = {
    alpha = 1
}
woundFadeOutTween = tween.new(1, wound_images_config, {alpha=0}, 'linear')

hp = 0

game_over = false

function cursorInCircle(x, y, center_x, center_y, radius)
    return ((x-center_x)^2 + (y - center_y)^2) < radius^2
end

function love.load()                  
    love.window.setTitle("Blood Sewn")

    love.mouse.setCursor(love.mouse.newCursor("res/needlecursor.png", 0, 0))
    settings = json.decode(file.readall('config/settings.json'))

    debug_text = settings.Misc.debug
    audio = Audio:new()

    local gameWidth, gameHeight = 1920, 1080 --fixed game resolution
    --settings.Preferences.resolution_width, settings.Preferences.resolution_height --
    local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
    adjustedWidth, adjustedHeight = desktopWidth, desktopHeight
    if settings.Preferences.resolution_width > desktopWidth then
        adjustedWidth = desktopWidth
    else
        adjustedWidth = settings.Preferences.resolution_width
    end
    if settings.Preferences.resolution_height > desktopHeight then
        adjustedHeight = desktopHeight
    else
        adjustedHeight = settings.Preferences.resolution_height
    end

    local windowWidth, windowHeight = adjustedWidth, adjustedHeight
    -- settings.Preferences.resolution_width, settings.Preferences.resolution_height
    -- love.window.getDesktopDimensions()

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = settings.Preferences.fullscreen})

    hp = settings.Game.hp

    --loading comic panels
    panel_config = json.decode(file.readall('intro1.json'))
    for key, value in ipairs(panel_config) do        
        debug_text = value.image
        panels[key] = ComicPanel:new(love.graphics.newImage(value.image), value.x, value.y, value.duration, value.transition)
    end

    -- if panels[panel_index]~=nil then
    --     panels[panel_index]:start()
    -- end
    rope1 = Rope(love.graphics.getWidth()*.25, 100, 300, 25, 10)
	rope1.fixLastPoint = true
	-- rope1:moveLastPoint(love.graphics.getWidth()*.5, love.graphics.getHeight()*1.0)
    rope1:moveLastPoint(gameWidth * 0.5, gameHeight * 1.0)

    -- set up for levels
    img_heart_gauge = love.graphics.newImage("res/ui/Heart Gauge.png")
    img_heart_gauge_blood = love.graphics.newImage("res/ui/Heart Gauge_Blood.png")
    blood_width = img_heart_gauge_blood:getWidth()
    blood_height = img_heart_gauge_blood:getHeight()
    blood_quad = love.graphics.newQuad(0,0, blood_width,blood_height * (hp / 100), blood_width,blood_height)

    img_mortician = love.graphics.newImage("res/ui/Mortician.png")
    img_vignette = love.graphics.newImage("res/ui/Vignette.png")
    img_hand = love.graphics.newImage("res/levels/Hand.png")
    img_hand_wound = love.graphics.newImage("res/levels/Hand_Wound.png")
    img_head = love.graphics.newImage("res/levels/Head.png")
    img_head_wound = love.graphics.newImage("res/levels/Head_Wound.png")
    img_leg = love.graphics.newImage("res/levels/Leg.png")
    img_leg_wound = love.graphics.newImage("res/levels/Leg_Wound.png")
    img_torso = love.graphics.newImage("res/levels/Torso.png")
    img_torso_wound = love.graphics.newImage("res/levels/Torso_Wound.png")
    
    img_game_over = love.graphics.newImage("res/Game Over.png")

    btn_next = Button:new("btn_next", 
        1500, 900, nil, nil, love.graphics.newImage("res/ui/Next Button.png"),
        love.graphics.newImage("res/ui/Next Button_Hover.png")
    )
    btn_next.visible = false
    btn_next.onclick = function(x, y, button)
        resetLevel()        
        loadNextLevel()
    end

    panels[panel_index]:start()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.draw()
    push:start()

    -- mx, my = suit.getMousePosition()
    -- print(mx..my)
    -- if mouseX ~= nil and mouseY ~= nil then
    --     love.mouse.setPosition(mouseX, mouseY)
    -- end

    love.graphics.setColor(255,255,255)
    for key, value in ipairs(panels) do
        panels[key]:draw()
    end

    if current_body.body_image ~= nil then love.graphics.draw(current_body.body_image, 0,0) end
    love.graphics.setColor(255,255,255, wound_images_config.alpha)
    if current_body.wound_image ~= nil then love.graphics.draw(current_body.wound_image, 0,0) end
    
    love.graphics.setColor(255,255,255)
    btn_next:draw()
    if current_level > 0 then
        love.graphics.draw(img_heart_gauge, 70,70)
        love.graphics.draw(img_heart_gauge_blood, blood_quad, 97,200)    
        love.graphics.draw(img_mortician, 50,800)
        love.graphics.draw(img_vignette, 0,0)
        rope1:draw()
    end

    if settings.Misc.debug == 1 then
        love.graphics.setColor(255,255,255)
        if debug_text ~= nil then
            love.graphics.print(debug_text, 500, 20)
        end
        pressed_text = ""
        if mouse.pressed then pressed_text = "True" else pressed_text = "False" end
        love.graphics.print("x: "..mouse.x.." y: "..mouse.y.." pressed: "..pressed_text.." hp: "..hp, 500, 40)
        -- love.graphics.print("mouseX: "..mouseX.." mouseY: "..mouseY, 500, 60)
    end
    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            if value.cleared == true then
                love.graphics.setColor(220/255,0,0, wound_images_config.alpha)
            else
                love.graphics.setColor(120/255,120/255,120/255, wound_images_config.alpha)
            end
            love.graphics.circle('fill', value.x, value.y, stitch_radius )        
        end
    end   

    --debug only
    for key, value in ipairs(stitch_regions) do
        love.graphics.setColor(120/255,120/255,120/255, 1)
        love.graphics.circle('fill', value.x, value.y, 7 )        
    end
    
    if game_over then
        love.graphics.setColor(255,255,255)
        love.graphics.draw(img_game_over, 0, 0)
    end

    push:finish()
end

function love.update(dt)
    rope1:update(dt)
    for key, value in ipairs(panels) do
        value:update(dt)
    end

    if level_cleared == true then
        woundFadeOutTween:update(dt)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    mouse.x = x
    mouse.y = y
    mouse.dx = dx
    mouse.dy = dy
    gmx, gmy = push:toGame(x, y)
    scaled_mouse.x = gmx and gmx or scaled_mouse.x
    scaled_mouse.y = gmy and gmy or scaled_mouse.y

	rope1:moveFirstPoint(scaled_mouse.x + 30, scaled_mouse.y + 30)
    in_circle = false
    debug_text = "Out of Circle, active_stitch_index: "..active_stitch_index
    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            if cursorInCircle(scaled_mouse.x, scaled_mouse.y, value.x, value.y, stitch_radius) then
                in_circle = true
                debug_text = "In Circle, active_stitch_index: "..active_stitch_index
                if mouse.pressed then
                    active_stitch_index = i
                    value.cleared = true
                end
            end
        end
    end

    if mouse.pressed then
        if in_circle and level_cleared == false then
            hp = hp - settings.Game.hp_drain_rate
        else
            hp = hp - settings.Game.out_of_bounds_hp_drain_rate
        end

        blood_quad = love.graphics.newQuad(0,0, blood_width,blood_height * (hp / settings.Game.hp), blood_width,blood_height)
        if hp <= 0 then
            current_level = 0
            game_over = true
            -- game over state
        end
    end

    btn_next:mousemoved(scaled_mouse.x, scaled_mouse.y, dx, dy, istouch)
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
    -- gmx, gmy = push:toGame(x, y)
    if button == 1 then
        mouse.pressed = true
        -- handle chapters here    
        if game_end then chapter_length = 13 else chapter_length = 10 end
        
        if chapter_index < (chapter_length + 1) then
            if panels[panel_index] ~= nil then
                panels[panel_index]:start()            
            end
            -- only play when it's the first chapter and panel
            if chapter_index == 2 and panel_index == 1 then
                audio:playIntroBGM()
            end
            panel_index = panel_index + 1
            if panel_index > #panels + 1 then
                for key, value in ipairs(panels) do
                    panels[key]:stop()
                end
                chapter_index = chapter_index + 1
                if chapter_index == (chapter_length + 1) then
                -- transition to gameplay here
                    if game_end then
                    else
                        audio:playDefaultBGM()
                        panels = {}
                        loadNextLevel()
                    end
                else
                    if game_end then
                        load_panels("ending"..chapter_index..".json")
                    else
                        load_panels("intro"..chapter_index..".json")
                    end                    
                end
            end
        end
        --for debugging and setting up levels only
        -- table.insert(stitch_regions, {x=x, y=y})
    end

    btn_next:mousepressed(scaled_mouse.x, scaled_mouse.y, button)
end

function love.mousereleased(x, y, button, istouch, presses )    
    mouse.pressed = false

    if stitch_region_group[active_stitch_index] ~= nil then
        if checkAllClear(stitch_region_group[active_stitch_index]) == false then
            resetRegions(stitch_region_group[active_stitch_index])
        else
            audio:playStitched()
        end    
        all_clear = true
        for key, stitch_region in ipairs(stitch_region_group) do
            if checkAllClear(stitch_region) == false then all_clear = false end
        end
        if all_clear then 
            level_cleared = true            
            print("All regions cleared!")
            btn_next.visible = true
        end
    end
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

function resetLevel()
    hp = settings.Game.hp
    wound_images_config = {alpha = 1}
    woundFadeOutTween = tween.new(1, wound_images_config, {alpha=0}, 'linear')
    level_cleared = false
    stitch_region_group = {}
    blood_quad = love.graphics.newQuad(0,0, blood_width,blood_height * (hp / settings.Game.hp), blood_width,blood_height)
    btn_next.visible = false
end

function loadNextLevel()
    current_level = current_level + 1
    if current_level == 1 then
        table.insert(stitch_region_group, json.decode(file.readall('levels/level1_hand_wound1.json')))
        current_body.body_image = img_hand
        current_body.wound_image = img_hand_wound
    end
    if current_level == 2 then        
        table.insert(stitch_region_group, json.decode(file.readall('levels/level2_leg_wound1.json')))
        table.insert(stitch_region_group, json.decode(file.readall('levels/level2_leg_wound2.json')))
        current_body.body_image = img_leg
        current_body.wound_image = img_leg_wound
    end
    if current_level == 3 then
        table.insert(stitch_region_group, json.decode(file.readall('levels/level3_torso_wound1.json')))
        table.insert(stitch_region_group, json.decode(file.readall('levels/level3_torso_wound2.json')))
        current_body.body_image = img_torso
        current_body.wound_image = img_torso_wound
    end
    if current_level == 4 then
        stitch_radius = 7
        table.insert(stitch_region_group, json.decode(file.readall('levels/level4_head_wound1.json')))
        table.insert(stitch_region_group, json.decode(file.readall('levels/level4_head_wound2.json')))
        table.insert(stitch_region_group, json.decode(file.readall('levels/level4_head_wound3.json')))
        current_body.body_image = img_head
        current_body.wound_image = img_head_wound
    end    
    for i, stitch_region in ipairs(stitch_region_group) do
        for key, value in ipairs(stitch_region) do
            value.cleared = false
        end
    end
    if current_level == 5 then
        -- transition to ending
        current_body.body_image = nil
        current_body.wound_image = nil
        game_end = true
        current_level = 0
        chapter_index = 0
        panel_index = 1        
        audio:playEndBGM()
    end
end

function load_panels(filename) 
    panel_index = 1
    panel_config = json.decode(file.readall(filename))
    panels = {}
    for key, value in ipairs(panel_config) do
        debug_text = value.image
        panels[key] = ComicPanel:new(love.graphics.newImage(value.image), value.x, value.y, value.duration, value.transition)
    end
end