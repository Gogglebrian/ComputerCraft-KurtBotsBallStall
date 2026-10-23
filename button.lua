Button = {}

function Button:new (inTerminal, inX, inY, inText, inCallback, inTextColor, inBackColor)
	local b = {terminal = inTerminal, x = inX, y = inY, text = inText, callback = inCallback, textColor = inTextColor or 1, backColor = inBackColor or 8192}
	b.rightEdge = inX + #inText
	setmetatable(b, self)
	self.__index = self
	b:draw()
	return b
end

function Button:newInPlace (inTerminal, addX,addY,inText, inCallback, inTextColor, inBackColor, newlineXGap, newlineYGap)
	local curX, curY = inTerminal.getCursorPos()
	local maxX, maxY = inTerminal.getSize()
	if (curX + addX + #inText > maxX) then
		curX = 1
		addX = newlineXGap or 0
		curY = curY + 1 + (newlineYGap or 1)
	end
	return self:new(inTerminal,curX+addX,curY+addY,inText,inCallback,inTextColor,inBackColor)
end

function Button:draw ()
	self.terminal.setTextColor(self.textColor)
	self.terminal.setBackgroundColor(self.backColor)
	self.terminal.setCursorPos(self.x,self.y)
	self.terminal.write(self.text)
end

function Button:isClicked (clickX, clickY)
	if (self.y == clickY and clickX >= self.x and clickX < self.x+#self.text) then
		return true
	else
		return false
	end
end

function Button:processClick (clickX, clickY)
	if self:isClicked(clickX,clickY) then
		--print("Button clicked")
		return self.callback()
	else
		return false
	end
end

