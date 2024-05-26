local Audio = {}

function Audio:new(object)    
    object =
        object or
        {
            audioFadeIn = nil,
            audioFadeOut = nil,
            bgmVolume = 0.35,
            fadein = false,
            fadeout = false
        }

    -- sfx
    -- object.srcStitched = love.audio.newSource("res/audio/stitched.mp3", "static")
    object.audioFadeIn = tween.new(1, object, {bgmVolume = 0.35}, 'linear')
    object.audioFadeOut = tween.new(1, object, {bgmVolume = 0}, 'linear')
    --bgm
    object.srcIntroBGM = love.audio.newSource("res/audio/moonlight-sonata.mp3", "stream")
    object.srcDefaultBGM = love.audio.newSource("res/audio/gnossienne.mp3", "stream")

    setmetatable(object, self)
    self.__index = self
    return object
end

function Audio:stopAllBGM()
    self.srcDefaultBGM:stop()
    self.srcIntroBGM:stop()
end

function Audio:playDefaultBGM()
    self:stopAllBGM()
    self.srcDefaultBGM:setVolume(0.35 * settings.Sound.masterVolume * settings.Sound.musicVolume)
    self.srcDefaultBGM:setLooping(true)
    self.srcDefaultBGM:play()
end

function Audio:playIntroBGM()
    self:stopAllBGM()
    self.srcIntroBGM:setVolume(0.5 * settings.Sound.masterVolume * settings.Sound.musicVolume)
    self.srcIntroBGM:setLooping(true)
    self.srcIntroBGM:play()
end

function Audio:playSFX()
    self.srcStitched:setVolume(0.2 * settings.Sound.masterVolume * settings.Sound.sfxVolume)
    self.srcStitched:setLooping(false)
    self.srcStitched:play()
end

function Audio:update(dt)
    if self.fadein == true then        
        self.audioFadeIn:update(dt)
    end
    if self.fadeout == true then
        self.audioFadeOut:update(dt)
    end
end

function Audio:draw()

end

function Audio:registerCallback(event, callback)
    self.callback[event] = callback
    self.callbackFlag[event] = false
end

return Audio
