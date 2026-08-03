-- A global variable for the Hyper Mode
hyper = hs.hotkey.modal.new({}, "F17")

-- NOTE: macOS sometimes leaves secure event input held after an unlock
-- (usually by loginwindow). While it's held, modifier-less hotkeys never fire, so hyper mode
-- does nothing at all -- no errors, and reloading doesn't help. Only a
-- lock/unlock or logout clears it. Checked on every hyper press, since that's
-- when it's noticeable. A browser or terminal holding it while a password field
-- is focused is normal and clears on its own.
local holderCache = { at = 0, who = nil }
local lastWarned = 0

local function secureInputHolder()
	local now = hs.timer.secondsSinceEpoch()
	if holderCache.who and now - holderCache.at < 15 then
		return holderCache.who -- ioreg is slow; don't run it per keypress
	end
	local out = hs.execute("ioreg -l -w 0 | grep -o 'kCGSSessionSecureInputPID\"=[0-9]*' | head -1")
	local pid = tostring(out or ""):match("=(%d+)")
	local who = "an unknown process"
	if pid and pid ~= "0" then
		local info = hs.execute("lsappinfo info -only name " .. pid)
		who = string.format("%s (pid %s)", tostring(info or ""):match('"LSDisplayName"="([^"]+)"') or "unknown", pid)
	end
	holderCache = { at = now, who = who }
	return who
end

local function warnIfSecureInput()
	if not hs.eventtap.isSecureInputEnabled() then
		return false
	end
	local now = hs.timer.secondsSinceEpoch()
	if now - lastWarned < 3 then -- don't stack alerts while mashing keys
		return true
	end
	lastWarned = now
	local who = secureInputHolder()
	print("[secure-input] HELD by " .. who .. " -- hyper keys will not fire")
	hs.alert.show("MacOS secure input held by " .. who .. "\nHyper keys dead - lock & unlock the screen", 4)
	return true
end

-- Enter Hyper Mode when F18 (Hyper/Capslock) is pressed
function enterHyperMode()
	hyper.triggered = false
	warnIfSecureInput()
	hyper:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
-- send ESCAPE if no other keys are pressed.
function exitHyperMode()
	hyper:exit()
	if not hyper.triggered then
		hs.eventtap.keyStroke({}, "ESCAPE")
	end
end

-- Bind the Hyper key
f18 = hs.hotkey.bind({}, "F18", enterHyperMode, exitHyperMode)

hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0.3
spoon.MiroWindowsManager:bindHotkeys(hyper, {
	up = { "", "k" },
	right = { "", "l" },
	down = { "", "j" },
	left = { "", "h" },
	fullscreen = { "", "f" },
	nextscreen = { "", "n" },
	center = { "", "c" },
})

-- NOTE: Using a workaround due to issues in MacOS 15 https://github.com/Hammerspoon/hammerspoon/issues/3698#issuecomment-2562188364
local useWorkaround = true

-- === SPACE MOVER ABSTRACTION ===
local spaceMover
if useWorkaround then
	spaceMover = require("workaround")
else
	-- Move window across spaces
	-- Slight modification of https://github.com/Hammerspoon/hammerspoon/issues/3111#issuecomment-1061388685
	-- original implementation, directly here
	local spaces = require("hs.spaces")
	local window = require("hs.window")

	-- Moved window often lose focus
	-- Seems to at least be triggered if first moving to a
	-- space by selecting a window using Cmd-Tab, and then trying
	-- to initiate a move of a window in that space (potentially
	-- another one then the one we switched to)
	function getGoodFocusedWindow(nofull)
		local win = window.focusedWindow()
		if not win or not win:isStandard() then
			return
		end
		if nofull and win:isFullScreen() then
			return
		end
		return win
	end

	function flashScreen(screen)
		local flash = hs.canvas.new(screen:fullFrame()):appendElements({
			action = "fill",
			fillColor = { alpha = 0.25, red = 1 },
			type = "rectangle",
		})
		flash:show()
		hs.timer.doAfter(0.15, function()
			flash:delete()
		end)
	end

	function switchSpace(skip, dir)
		for i = 1, skip do
			hs.eventtap.keyStroke({ "ctrl", "fn" }, dir, 0)
		end
	end

	local function focusSpace(space, win)
		local screen = hs.screen(hs.spaces.spaceDisplay(space))
		if not screen then
			return
		end
		local do_focus = coroutine.wrap(function()
			local function check_focus(w, n)
				for i = 1, n do
					if hs.window.focusedWindow() ~= w then
						return false
					end
					coroutine.yield(false)
				end
				return true
			end
			repeat
				win:focus()
				coroutine.yield(false)
			until (hs.spaces.focusedSpace() == space) and check_focus(win, 3)
			return true
		end)
		local start = hs.timer.secondsSinceEpoch()
		hs.timer.doUntil(do_focus, function(timer)
			if hs.timer.secondsSinceEpoch() - start > 2 then
				timer:stop()
			end
		end, 0.05)
	end

	local function moveWindowOneSpace(dir, switch)
		local win = getGoodFocusedWindow(true)
		if not win then
			return
		end
		local screen = win:screen()
		local uuid = screen:getUUID()
		local userSpaces = hs.spaces.allSpaces()[uuid]
		if not userSpaces then
			return
		end
		local thisSpace = hs.spaces.windowSpaces(win)
		if not thisSpace then
			return
		end
		thisSpace = thisSpace[1]
		local last = nil
		local skip = 0
		for _, spc in ipairs(userSpaces) do
			if hs.spaces.spaceType(spc) ~= "user" then
				skip = skip + 1
			else
				if last and ((dir == "left" and spc == thisSpace) or (dir == "right" and last == thisSpace)) then
					local newSpace = (dir == "left" and last or spc)
					if switch then
						switchSpace(skip + 1, dir)
					end
					hs.spaces.moveWindowToSpace(win, newSpace)
					focusSpace(newSpace, win)
					return
				end
				last = spc
				skip = 0
			end
		end
		flashScreen(screen)
	end

	spaceMover = {
		moveLeft = function()
			moveWindowOneSpace("left", true)
		end,
		moveRight = function()
			moveWindowOneSpace("right", true)
		end,
	}
end

-- Move all windows on the current screen to the other screen
hyper:bind(nil, "m", function()
	if #hs.screen.allScreens() < 2 then
		hs.alert.show("Only one screen detected")
		return
	end

	local currentScreen = hs.screen.mainScreen()
	local targetScreen = currentScreen:next()

	for _, win in ipairs(hs.window.visibleWindows()) do
		if win:screen():id() == currentScreen:id() and win:isStandard() then
			win:move(win:frame():toUnitRect(currentScreen:frame()), targetScreen, true, 0)
		end
	end
end)

hyper:bind(nil, "g", function()
	hyper.triggered = true
	local miroGrid = spoon.MiroWindowsManager.GRID
	hs.grid.setGrid("6x4")
	hs.grid.setMargins({ 0, 0 })
	hs.grid.show(function()
		hs.grid.setGrid(miroGrid.w .. "x" .. miroGrid.h)
		hs.grid.MARGINX = 0
		hs.grid.MARGINY = 0
	end)
end)

hyper:bind(nil, "i", function()
	spaceMover.moveLeft()
end)
hyper:bind(nil, "o", function()
	spaceMover.moveRight()
end)
