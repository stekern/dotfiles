local obj = {}
obj.__index = obj
obj.hs = hs
obj.isMoving = false

-- Constants
local DEFAULT_OFFSET = { x = 5, y = 12 }
local SWITCH_DELAY = 0.2
local RELEASE_DELAY = 0.5

obj.customOffsets = {
	["Firefox"] = { x = 130, y = 15 },
	["Claude"] = { x = 15, y = 10 },
}

-- Internal helper to simulate a key press (modifier, key)
local function simulateKeyEvent(modifier, key)
	obj.hs.eventtap.event.newKeyEvent(modifier, true):post()
	obj.hs.eventtap.event.newKeyEvent(key, true):post()
	obj.hs.timer.doAfter(0.1, function()
		obj.hs.eventtap.event.newKeyEvent(modifier, false):post()
		obj.hs.eventtap.event.newKeyEvent(key, false):post()
	end)
end

-- Compute a safe click point for dragging the window
local function getSafeClickPoint(win)
	local appName = win:application():name()
	local frame = win:frame()
	local offset = obj.customOffsets[appName] or DEFAULT_OFFSET
	local x = frame.x + offset.x
	local y = frame.y + offset.y
	local clickPos = obj.hs.geometry.point(x, y)
	local centerPos = obj.hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
	return clickPos, centerPos
end

-- Move the focused window to the next desktop
function obj:move_window_to_next_desktop()
	if self.isMoving then
		return
	end
	self.isMoving = true

	local win = self.hs.window.focusedWindow()
	if not win then
		self.isMoving = false
		return
	end
	win:unminimize()
	win:raise()

	local spaces = self.hs.spaces.spacesForScreen()
	local currentSpace = self.hs.spaces.focusedSpace()
	if currentSpace == spaces[#spaces] then
		self.hs.alert.show("Already at the rightmost desktop.")
		self.isMoving = false
		return
	end

	local clickPos, centerPos = getSafeClickPoint(win)
	local originalPos = self.hs.mouse.absolutePosition()
	self.hs.mouse.absolutePosition(clickPos)

	self.hs.eventtap.event.newMouseEvent(self.hs.eventtap.event.types.leftMouseDown, clickPos):post()

	self.hs.timer.doAfter(SWITCH_DELAY, function()
		simulateKeyEvent("ctrl", "right")
	end)

	self.hs.timer.doAfter(RELEASE_DELAY, function()
		self.hs.eventtap.event.newMouseEvent(self.hs.eventtap.event.types.leftMouseUp, clickPos):post()
		self.hs.mouse.absolutePosition(originalPos)
		win:raise()
		win:focus()
		self.isMoving = false
	end)
end

-- Move the focused window to the previous desktop
function obj:move_window_to_previous_desktop()
	if self.isMoving then
		return
	end
	self.isMoving = true

	local win = self.hs.window.focusedWindow()
	if not win then
		self.isMoving = false
		return
	end
	win:unminimize()
	win:raise()

	local spaces = self.hs.spaces.spacesForScreen()
	local currentSpace = self.hs.spaces.focusedSpace()
	if currentSpace == spaces[1] then
		self.hs.alert.show("Already at the leftmost desktop.")
		self.isMoving = false
		return
	end

	local clickPos, centerPos = getSafeClickPoint(win)
	local originalPos = self.hs.mouse.absolutePosition()
	self.hs.mouse.absolutePosition(clickPos)

	self.hs.eventtap.event.newMouseEvent(self.hs.eventtap.event.types.leftMouseDown, clickPos):post()

	self.hs.timer.doAfter(SWITCH_DELAY, function()
		simulateKeyEvent("ctrl", "left")
	end)

	self.hs.timer.doAfter(RELEASE_DELAY, function()
		self.hs.eventtap.event.newMouseEvent(self.hs.eventtap.event.types.leftMouseUp, clickPos):post()
		self.hs.mouse.absolutePosition(originalPos)
		win:raise()
		win:focus()
		self.isMoving = false
	end)
end

return {
	moveLeft = function()
		obj:move_window_to_previous_desktop()
	end,
	moveRight = function()
		obj:move_window_to_next_desktop()
	end,
}
