local Button = {}

function Button:new(name, x, y, width, height, image, hoverImage, text, font, object)
    if width == nil then width = image:getWidth() end
    if height == nil then height = image:getHeight() end
    object = object or {
        name = name,
        x = x,
        y = y,
        width = width,
        height = height,
        image = image,
        text = text,
        font = font,
        hoverImage = hoverImage or image,
        onclick = function(x, y, button) end,
        onclickOutside = function(x, y, button) end,
        onhover = function(x, y, dx, dy, istouch) end,        
        isHover = false,
        visible = true
    }

    setmetatable(object, self)
    self.__index = self

    return object
end

function Button:isWithin(mx, my)
    x1 = self.x
    y1 = self.y     
    x2 = self.x + self.width    
    y2 = self.y + self.height

    if (mx > x1 and mx < x2 and my > y1 and my < y2) then return true end
    return false
end

function Button:mousepressed(x, y, button)
    if self.visible ~= true then return end
    if button == 1 then
        mouse.pressed = true
        if self:isWithin(x, y) then        
            if self.onclick ~= nil then self.onclick(x, y, button) end
        else
            if self.onclickOutside ~= nil then self.onclickOutside(x, y, button) end
        end
    end
end

function Button:mousemoved(x, y, dx, dy, istouch)
    if self.visible ~= true then 
        self.isHover = false 
        return 
    end
    if self:isWithin(x, y) then        
        self.isHover = true
		if self.onclick ~= nil then self.onhover(x, y, dx, dy, istouch) end
    else
        self.isHover = false
    end
end

function Button:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    if self.visible ~= true then return end
    love.graphics.setColor(255, 255, 255)
    if self.isHover == true then
        -- self.hoverImage:draw(self.x, self.y)        
        love.graphics.draw(self.hoverImage, self.x or x, self.y or y, r or 0, sx or 1, sy or 1, ox, oy, kx, ky)
    else
        -- self.image:draw(self.x, self.y)
        love.graphics.draw(self.image, self.x or x, self.y or y, r or 0, sx or 1, sy or 1, ox , oy, kx, ky)
    end
    if self.text ~=nil then
        --TODO: Add colors to the button text
        love.graphics.setColor(135 / 255, 76 / 255, 71 / 255, 1)
        love.graphics.printf(self.text, self.font, self.x, self.y + (self.height / 2) - (self.font:getHeight() / 2), self.width, "center")        
        love.graphics.setColor(255 / 255, 255 / 255, 255 / 255, 1)
    end
end

function Button:resetCallbacks()
    self.onclick = function(x, y, button) end
    self.onclickOutside = function(x, y, button) end
    self.onhover = function(x, y, dx, dy, istouch) end
    self.visible = false
end

return Button
