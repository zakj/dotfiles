-- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/layout/init.lua

local exports = {}

function exports.autolayout()
  local screen = hs.screen.mainScreen():frame()
  local gap = 10
  local browserW = 1440
  local isHomeMacbook = hs.network.configuration.open():hostname() == 'zakj-m1'

  -- TODO layout for when I don't have an external monitor attached?

  local layout = {
    Arc = { x = 0, y = 0, w = browserW, h = screen.h },
    Finder = { w = 900, h = 450 },
    Messages = { x = gap, y = screen.h - gap - 850, w = 850, h = 850 },
    Obsidian = {
      x = (screen.w - 900) / 2,
      y = (screen.h - 1100) * 2 / 5,
      w = 900,
      h = 1100,
    },
    Zed = { x = browserW + gap, y = gap, w = screen.w - browserW - gap * 2, h = screen.h - gap * 2 },
  }

  if not isHomeMacbook then
    -- maybe make a copy? {table.unpack(layout)}
    local workLayout = { table.unpack(layout) }
    layout['Arc'] = { x = screen.w - browserW, y = 0, w = browserW, h = screen.h }
    layout['Slack '] = { x = 0, y = screen.h * 1 / 5, w = screen.w - browserW - gap, h = screen.h * 4 / 5 }
    -- TODO Zoom?
  end

  for appName, rect in pairs(layout) do
    local app = hs.application.get(appName)
    if app then
      for _, win in pairs(app:visibleWindows()) do
        if rect['x'] ~= nil and rect['y'] ~= nil then
          rect.x = rect.x + screen.x
          rect.y = rect.y + screen.y
          win:setFrame(rect)
        else
          win:setSize(rect)
        end
      end
    end
  end
end

-- {app name or nil, window name or nil, screen name or screen or nil, rect}
function exports.apply(layout)
  for _, row in pairs(layout) do
    local appName, title, screen, rect = table.unpack(row)
    local app
    local windows

    if appName then
      app = hs.appfinder.appFromName(appName)
    end
    if app then
      windows = app:visibleWindows()
    else
      windows = hs.window.visibleWindows()
    end

    windows = hs.fnutils.filter(windows, function(w)
      return not title or w:title() == title
    end)
    -- hs.fnutils.each(windows, function(w)
    --     w:setFrame(rect)
    -- end)
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
