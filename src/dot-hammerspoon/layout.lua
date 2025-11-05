-- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/layout/init.lua

local exports = {}

function exports.isBuiltinDisplay()
  return hs.screen.mainScreen():name():find('Built-in', 1, true) == 1
end

function exports.isFirstUserDesktop()
  local screen = hs.screen.mainScreen()
  local userSpaces = hs.fnutils.filter(hs.spaces.spacesForScreen(screen), function(space)
    return hs.spaces.spaceType(space) == "user"
  end)
  return hs.fnutils.indexOf(userSpaces, hs.spaces.activeSpaceOnScreen(screen)) == 1
end

-- Used to detect the "main" window for a given app.
function exports.isLargestVisible(win)
  return win == hs.fnutils.reduce(win:application():visibleWindows(), function(a, b)
    local aFrame, bFrame = a:frame(), b:frame()
    return (aFrame.w * aFrame.h) > (bFrame.w * bFrame.h) and a or b
  end)
end

local function normalizeRect(rect, winFrame, screenFrame)
  assert(not (rect.right and rect.x and rect.w), 'right cannot be used with both x and w')
  assert(not (rect.bottom and rect.y and rect.h), 'bottom cannot be used with both y and h')
  assert(not (rect.x == 'center' and rect.right), 'x = center cannot be used with right')
  assert(not (rect.y == 'center' and rect.bottom), 'y = center cannot be used with bottom')

  -- Create our return value, falling back to winFrame for missing keys.
  local rv = {
    x = rect.x or winFrame.x,
    y = rect.y or winFrame.y,
    w = rect.w or winFrame.w,
    h = rect.h or winFrame.h,
  }

  -- Normalize fractional values to a percentage of the screen size in the same dimension.
  -- Needs to happen before centering.
  if type(rv.x) == 'number' and rv.x > 0 and rv.x <= 1 then rv.x = rv.x * screenFrame.w end
  if type(rv.y) == 'number' and rv.y > 0 and rv.y <= 1 then rv.y = rv.y * screenFrame.h end
  -- TODO fractional right/bottom?
  if rv.h and rv.h > 0 and rv.h <= 1 then rv.h = rv.h * screenFrame.h end
  if rv.w and rv.w > 0 and rv.w <= 1 then rv.w = rv.w * screenFrame.w end

  -- Center, biased slightly toward the top of the screen for vertical.
  if rect.x == 'center' then
    rv.x = (screenFrame.w - rv.w) / 2
  end
  if rect.y == 'center' then
    rv.y = (screenFrame.h - rv.h) / 3
  end

  -- Convert bottom/right values to x/y/w/h.
  if rect.right then
    if rect.x then
      rv.w = screenFrame.w - rect.right - rv.x
    elseif rect.w then
      rv.x = screenFrame.w - rect.right - rv.w
    end
  end
  if rect.bottom then
    if rect.y then
      rv.h = screenFrame.h - rect.bottom - rv.y
    elseif rect.h then
      rv.y = screenFrame.h - rect.bottom - rv.h
    end
  end

  return rv
end

-- screen:localToAbsolute uses fullFrame, which we don't want here.
local function localToAbsolute(rect, frame)
  local abs = hs.fnutils.copy(rect)
  abs.x = rect.x + frame.x
  abs.y = rect.y + frame.y
  return abs
end

local function set(win, rectOrFn)
  local screenFrame = hs.screen.mainScreen():frame()
  local rect = rectOrFn
  if type(rectOrFn) == "function" then
    rect = rectOrFn(win)
  end
  if rect then
    rect = normalizeRect(rect, win:frame(), screenFrame)
    -- Clamp to screenFrame.
    rect.w = math.min(rect.w, screenFrame.w)
    rect.h = math.min(rect.h, screenFrame.h)
    rect.x = math.max(0, math.min(rect.x, screenFrame.w - rect.w))
    rect.y = math.max(0, math.min(rect.y, screenFrame.h - rect.h))
    win:setFrame(localToAbsolute(rect, screenFrame))
  end
end

-- For leaderkey bindings; returns a function so we don't have to wrap in the
-- leaderkey configuration.
function exports.setCurrentWin(rectOrFn)
  return function()
    set(hs.window.focusedWindow(), rectOrFn)
  end
end

-- layout is a table keyed by application name, whose values are either a table
-- or a function (taking a window argument) returning a table. The value table
-- is a partial hs.geometry.rect, where missing values are filled from the
-- existing window's frame.
function exports.apply(layout)
  for appName, rectOrFn in pairs(layout) do
    local app = hs.application.find(appName, true)
    if app and app:isRunning() then
      -- TODO: visibleWindows includes from all active spaces, not just current screen
      for _, win in pairs(app:visibleWindows()) do
        set(win, rectOrFn)
      end
    end
  end
end

return exports
