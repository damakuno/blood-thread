local ComicPanel = {}
function ComicPanel:new(image, x, y, duration, transition, width, height, object)
    if width == nil then
        width = image:getWidth()
    end
    if height == nil then
        height = image:getHeight()
    end

    object = object or {
        currentTime = 0,
        sprite = image,
        width = width,
        height = height,
        duration = duration or 1,
        enabled = false,
        visible = true,
        alpha = 0,
        x = x or 0,
        y = x or 0,
        offsetX = 0,
        offsetY = 0,
        fadeInTween = nil
    }
    
    if transition == "from_top" then
        object.offsetY = 50
    elseif transition == "from_left" then
        object.offsetX = 50
    elseif transition == "from_right" then
        object.offsetX = -50
    elseif transition == "from_bottom" then
        object.offsetY = -50
    end

    object.fadeInTween = tween.new(object.duration, object, {alpha=1, offsetX = 0, offsetY = 0}, 'linear')

    setmetatable(object, self)
    self.__index = self
    return object
end

function ComicPanel:update(dt)
    if self.enabled == true then
        self.fadeInTween:update(dt)
        self.currentTime = self.currentTime + dt
        if self.currentTime >= self.duration then
            self.currentTime = self.currentTime - self.duration
        end
    end
end

function ComicPanel:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    love.graphics.setColor(255,255,255,self.alpha)
    if self.visible == true then
        if self.sprite ~= nil then
            love.graphics.draw(self.sprite, self.x or x, self.y or y, r or 0, sx or 1, sy or 1, ox or self.offsetX, oy or self.offsetY, kx, ky)
        end
    end
end


function ComicPanel:start()
    self.enabled = true
end    

function ComicPanel:show()
    self.visible = true
end

function ComicPanel:hide()
    self.visible = false
end

return ComicPanel