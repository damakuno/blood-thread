local Rope = {}

Rope.__index = Rope
setmetatable(Rope, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local NUM_ITERATIONS = 20

function Rope.new(x, y, length, angle, angleVariation)
   local self = setmetatable({}, Rope)
   
   self.NUM_POINTS = 200;
   self.DRAG_FACTOR = 0.5
   self.GRAVITY_X = 0
   self.GRAVITY_Y = 1200
   self.SEG_LENGTH = length / self.NUM_POINTS
   self.fixLastPoint = false
   -- Current position
   self.pos_x, self.pos_y = {}, {}
   -- Old position
   self.old_x, self.old_y = {}, {}
   -- Force accumulator
   self.force_x, self.force_y = {}, {}
   
   -- Initial positions
   local i
   self.pos_x[1], self.pos_y[1] = x, y
   for i = 2, self.NUM_POINTS do
		local segmentAngle = math.rad(angle + 2 * (love.math.random()-0.5) * angleVariation)
		self.pos_x[i] = self.pos_x[i-1] + math.cos(segmentAngle) * self.SEG_LENGTH
		self.pos_y[i] = self.pos_y[i-1] + math.sin(segmentAngle) * self.SEG_LENGTH
   end
   -- Initial everything else
   for i = 1, self.NUM_POINTS do
		self.old_x[i], self.old_y[i] = self.pos_x[i], self.pos_y[i]
		self.force_x[i], self.force_y[i] = 0, 0
   end
   
   return self
end

function Rope:update(dt)
	self:accumulateForces()
	self:verlet(dt)
	self:constrain()
end

function Rope:verlet(dt)
	local i
	for i = 1, self.NUM_POINTS do
		local tmp_x, tmp_y = self.pos_x[i], self.pos_y[i]
		self.pos_x[i] = self.pos_x[i] + (1-self.DRAG_FACTOR)*(self.pos_x[i] - self.old_x[i]) + self.force_x[i] * dt * dt * 0.5
		self.pos_y[i] = self.pos_y[i] + (1-self.DRAG_FACTOR)*(self.pos_y[i] - self.old_y[i]) + self.force_y[i] * dt * dt * 0.5
		self.old_x[i], self.old_y[i] = tmp_x, tmp_y
	end
end

function Rope:accumulateForces()
	local i
	for i = 1, self.NUM_POINTS do
		self.force_x[i] = self.GRAVITY_X
		self.force_y[i] = self.GRAVITY_Y
	end
end

function Rope:constrain()
	local i, j
	for j = 1, NUM_ITERATIONS do
		for i = 2, self.NUM_POINTS do
			local delta_x, delta_y = self.pos_x[i] - self.pos_x[i - 1], self.pos_y[i] - self.pos_y[i - 1]
			local dist = math.sqrt(delta_x*delta_x+delta_y*delta_y)
			local diff = (dist - self.SEG_LENGTH) / dist
			self.pos_x[i] = self.pos_x[i] - delta_x * diff * 0.5
			self.pos_y[i] = self.pos_y[i] - delta_y * diff * 0.5
			self.pos_x[i-1] = self.pos_x[i-1] + delta_x * diff * 0.5
			self.pos_y[i-1] = self.pos_y[i-1] + delta_y * diff * 0.5
		end
		-- For now just fix the first point
		self.pos_x[1], self.pos_y[1] = self.old_x[1], self.old_y[1]
		-- And the last one if required
		if self.fixLastPoint then
			self.pos_x[self.NUM_POINTS], self.pos_y[self.NUM_POINTS] = self.old_x[self.NUM_POINTS], self.old_y[self.NUM_POINTS]
		end
	end
end

function Rope:moveFirstPoint(new_x, new_y)
	self.pos_x[1], self.pos_y[1] = new_x, new_y
end

function Rope:moveLastPoint(new_x, new_y)
	self.pos_x[self.NUM_POINTS], self.pos_y[self.NUM_POINTS] = new_x, new_y
end

function Rope:draw()
	love.graphics.setColor(194, 0, 0)
	for i = 2, self.NUM_POINTS do
		love.graphics.line(self.pos_x[i-1], self.pos_y[i-1], self.pos_x[i], self.pos_y[i])
	end
	love.graphics.setColor(255, 255, 255)
	--for i = 1, self.NUM_POINTS do
	--	love.graphics.circle("line", self.pos_x[i], self.pos_y[i], 5)
	--end
end

--

return Rope