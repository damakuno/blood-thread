local ComicPanel = {}

function ComicPanel:new(image, width, height, duration, object)
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
        visible = true
    }

    setmetatable(object, self)
    self.__index = self
    return object
end

function ComicPanel:update(dt)
    if self.enabled == true then
        self.currentTime = self.currentTime + dt
        if self.currentTime >= self.duration then
            self.currentTime = self.currentTime - self.duration
        end
    end
end

function ComicPanel:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    if self.visible == true then
        if self.sprite ~= nil then
            love.graphics.draw(self.sprite, x, y, r or 0, sx or 1, sy or 1, ox, oy, kx, ky)
        end
    end
end

function ComicPanel:show()
    self.visible = true
end

function ComicPanel:hide()
    self.visible = false
end

return ComicPanel