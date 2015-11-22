local l_gfx = love.graphics
local mouse = love.mouse
-- this is a spin element
-- currently it's only way of control is by mousewheel, wheelup increases the value by a step, wheeldown decreases
-- it also has mutlipliers, like precise multiplier, base multiplier, coarse and turbo multipliers
-- if you press left shift, or left ctrl or left alt while mouse over the spin element, you will switch its step multiplier and show its value in a box to the right
-- multipliers are redefinable on runtime as well as you can deny it from use step multipliers at all
-- its changeValue() method is fired on every increase or decrease

Spin = {}
Spin.__index = Spin
Spin.ident = "ui_spin"
Spin.leftCaption = false
Spin.w = 48
Spin.h = 16
Spin.caption = "Spin"
Spin.colorHighlight = {160,160,160,128}
Spin.name = "Spin"
Spin.caption_xpad = -4
Spin.caption_ypad = 0
Spin.updateable = true
function Spin:new(name)
	local self = {}
	setmetatable(self,Spin)
	self.value = 0
	self.step = 1
	self.step_mult = 1
	self.isHeld = false
	self.allowMult = false
	self.displMult = false
	self.mult_coarse = 10
	self.mult_base = 1
	self.mult_precise = 0.1
	self.mult_turbo = 100
	self.held_timer = 0
	self.max = nil
	self.min = nil
	if name ~= nil then self.name = name end
	return self
end
setmetatable(Spin,{__index = UIElement})

function Spin:click(b)
	if b == "wu" then
		self:increment()
		self:changeValue()
	elseif b == "wd" then
		self:decrement()
		self:changeValue()
	elseif b == "l" then
		self.isHeld = true	
		local mx,my = mouse.getPosition()
		if self:isMouseOver() then
			if mx>=self.x+self.w/2 then self:increment() else self:decrement() end
			self:changeValue()
		end
	end
end

function Spin:update(dt)
	if self.isHeld == true then
		self.held_timer = self.held_timer + dt
		if self.held_timer>0.5 then
			local mx,my = mouse.getPosition()
			if self:isMouseOver() then
				if mx>=self.x+self.w/2 then self:increment() else self:decrement() end
				self:changeValue()
			end
		end
	end
end

function Spin:unclick(b)
	if b == "l" then
		self.isHeld = false
		self.held_timer = 0
	end
end

function Spin:increment()
	if self.max ~= nil then
		if self.value<=self.max-self.step*self.step_mult then self.value = self.value + self.step*self.step_mult end
	else
		self.value = self.value + self.step*self.step_mult
	end
end

function Spin:decrement()
	if self.min ~= nil then
		if self.value>=self.min+self.step*self.step_mult then self.value = self.value - self.step*self.step_mult end 
	else
		self.value = self.value - self.step*self.step_mult
	end
end

function Spin:keypressed(key) 
	if self.allowMult == true then
		if key == "lshift" then
			self.step_mult = self.mult_coarse
			self.displMult = true
		elseif key == "lctrl" then
			self.step_mult = self.mult_precise
			self.displMult = true
		elseif key == "lalt" then
			self.step_mult = self.mult_turbo
			self.displMult = true
		end
	end
end

function Spin:keyreleased(key) 
	if key == "lshift" or key == "lctrl" or key == "lalt" then
		self.step_mult = self.mult_base
		self.displMult = false
	end
end

function Spin:draw()
	local cr,cg,cb,ca = love.graphics.getColor()
	if self:isMouseOver() == true then
		local mx,my = mouse:getPosition()
		l_gfx.setColor(self.colorHardFill)
		if mx>=self.x+self.w/2 then 
			l_gfx.rectangle("fill",self.x+self.w/2,self.y,self.w/2,self.h)
		else
			l_gfx.rectangle("fill",self.x,self.y,self.w/2,self.h)
		end
		if self.displMult == true then
			local str = "x"..self.step_mult*self.step
			
			l_gfx.rectangle("fill",self.x+self.w+2,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str)+2,14)
			l_gfx.setColor(self.colorFont)
			l_gfx.rectangle("line",self.x+self.w+2,self.y+(self.h/2-7),l_gfx.getFont():getWidth(str),14)
			l_gfx.setColor(self.colorFont)
			l_gfx.print(str,self.x+self.w+2,self.y+(self.h/2-7))
		end
		l_gfx.setColor(self.colorHighlight)
	else
		l_gfx.setColor(self.colorFill)
	end
	l_gfx.rectangle("fill",self.x,self.y,self.w,self.h)
	l_gfx.setColor(self.colorFont)
	local v = self.value
	local sh = self.h/2-7
	l_gfx.printf(v,self.x,self.y+sh,self.w,"center")
	if self.leftCaption == true then
		l_gfx.print(self.caption,self.x-l_gfx:getFont():getWidth(self.caption)+self.caption_xpad,self.y+(self.h/2-7)+self.caption_ypad)
	else
		l_gfx.print(self.caption,self.x+self.caption_xpad,self.y-14+self.caption_ypad)
	end
	
	l_gfx.setColor(cr,cg,cb,ca)
end

function Spin:changeValue() end
function Spin:setValue(value) self.value = value end
