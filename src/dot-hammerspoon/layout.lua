-- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/layout/init.lua

local exports = {}

-- Used to detect the "main" Slack window.
local function widestVisibleWindow(app)
  return hs.fnutils.reduce(app:visibleWindows(), function(a, b)
    return a:frame().w > b:frame().w and a or b
  end)
end

local function getLayout()
  local screen = hs.screen.mainScreen()
  local frame = screen:frame()
  local gap = 10
  local browserW = 1440

  local isHomeMacbook = hs.network.configuration.open():hostname() == 'zakj-m1'
  local isMacbookScreen = screen:name():find('Built-in', 1, true) == 1
  local userSpaces = hs.fnutils.filter(hs.spaces.spacesForScreen(screen), function(space)
    return hs.spaces.spaceType(space) == "user"
  end)
  local isFirstScreen =
      hs.fnutils.indexOf(userSpaces, hs.spaces.activeSpaceOnScreen(screen)) == 1

  local mainSlackRect = { x = 0, y = frame.h * 1 / 5, w = frame.w - browserW - gap, h = frame.h * 4 / 5 }
  local layout = {
    Arc = { x = 0, y = 0, w = browserW, h = frame.h },
    Finder = { w = 900, h = 450 },
    Messages = { x = gap, y = frame.h - gap - 850, w = 850, h = 850 },
    Obsidian = {
      x = (frame.w - 900) / 2,
      y = (frame.h - 1100) * 2 / 5,
      w = 900,
      h = 1100,
    },
    Slack = function(app, win)
      return win == widestVisibleWindow(app) and mainSlackRect or { w = 550, h = 950 }
    end,
    Zed = { x = browserW + gap, y = gap, w = frame.w - browserW - gap * 2, h = frame.h - gap * 2 },
  }

  if isMacbookScreen then
    local secondaryW = 1100
    mainSlackRect = { x = 0, y = gap, w = secondaryW, h = frame.h - gap }
    layout.Zed.x = frame.w - secondaryW
    layout.Zed.w = secondaryW
  end

  if not isHomeMacbook and isFirstScreen then
    layout.Arc = { x = frame.w - browserW, y = 0, w = browserW, h = frame.h }
  end

  return layout
end


-- TODO refactor
function exports.autolayout()
  exports.apply(getLayout())
end

-- screen:localToAbsolute uses fullFrame, which we don't want here.
local function localToAbsolute(rect, frame)
  local abs = hs.fnutils.copy(rect)
  abs.x = rect.x + frame.x
  abs.y = rect.y + frame.y
  return abs
end

-- layout is a table keyed by application name, whose values are either a table
-- or a function (accepting application and window arguments) returning a table.
-- The value table is a partial hs.geometry.rect, where w and h are required and
-- x and y are optional. x and y are relative to the screen's coordinates.
function exports.apply(layout)
  local screenFrame = hs.screen.mainScreen():frame()
  for appName, rectOrFn in pairs(layout) do
    local app = hs.application.get(appName)
    if app then
      -- TODO: visibleWindows includes from all active spaces, not just current screen
      for _, win in pairs(app:visibleWindows()) do
        local rect = rectOrFn
        if type(rectOrFn) == "function" then
          rect = rectOrFn(app, win)
        end
        if rect.x ~= nil and rect.y ~= nil then
          win:setFrame(localToAbsolute(rect, screenFrame))
        else
          win:setSize(rect)
        end
      end
    end
  end
end

function exports.staggerWindows(app)
  local staggerSize = 22
  local topLeft
  hs.fnutils.each(app:visibleWindows(), function(w)
    if w:size().h == 1 then return end -- ignore magic Chrome windows
    if topLeft == nil then
      topLeft = w:topLeft()
    else
      topLeft.x = topLeft.x + staggerSize
      w:setTopLeft(topLeft)
    end
  end)
end

function exports.moveCenter(win)
  local frame = win:frame()
  local screen = win:screen():fullFrame()
  frame.x = (screen.w - frame.w) / 2 + screen.x
  frame.y = (screen.h - frame.h) / 3 + screen.y
  win:setTopLeft(frame)
end

function exports.moveTL(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.x = screen.x
  frame.y = screen.y
  win:setFrame(frame)
end

function exports.moveBL(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.x = screen.x
  frame.y = screen.y + screen.h - frame.h
  win:setFrame(frame)
end

function exports.moveTR(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.x = screen.x + screen.w - frame.w
  frame.y = screen.y
  win:setFrame(frame)
end

function exports.moveBR(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.x = screen.x + screen.w - frame.w
  frame.y = screen.y + screen.h - frame.h
  win:setFrame(frame)
end

function exports.maximizeV(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.y = screen.y
  frame.h = screen.h
  win:setFrame(frame)
end

function exports.sizeQuarter(win)
  local frame = win:frame()
  local screen = win:screen():frame()
  frame.w = screen.w / 2
  frame.h = screen.h / 2
  win:setFrame(frame)
end

return exports
