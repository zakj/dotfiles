local layout = require 'layout'
local modtap = require 'modtap'
local reload = require 'reload'
local toast = require 'toast'

modtap:start('cmd', { 'ctrl', 'option', 'cmd', 'shift' }, '1', 0.15)
reload:start()

local function isProgrammableKeyboard(device) return device.productName == 'Keychron K7 Pro' end
if not hs.fnutils.some(hs.usb.attachedDevices(), isProgrammableKeyboard) then
  modtap:start('ctrl', {}, 'escape', 0.3)
end

-- TODO specify size for Arc popups separately from the largest window
local gap = 10
local browserW = 1440
local externalLayout = {
  Arc = { x = 0, y = 0, w = browserW, bottom = 0 },
  Finder = { w = 900, h = 450 },
  Ghostty = { x = browserW + gap, y = gap, right = gap, bottom = gap },
  Messages = { x = gap, bottom = gap, w = 850, h = 850 },
  Obsidian = { w = 900, h = 1100, center = true },
  Slack = function(app, win)
    if win ~= layout.widestVisibleWindow(app) then
      return { x = 1100 + gap, y = 1 / 5, w = 550, h = 950 }
    end
    return { x = 0, y = 1 / 5, w = 1100, bottom = 0 }
  end
}

local laptopLayout = hs.fnutils.copy(externalLayout)
laptopLayout.Ghostty = {right = 0, w = 1100, y = 0, bottom = 0}
laptopLayout.Slack = function(app, win)
  if win ~= layout.widestVisibleWindow(app) then
    return { x = 1100, y = gap, right = 0, bottom = 0 }
  end
  return {x = 0, y = gap, w = 1100, bottom = 0 }
end

hs.urlevent.bind('autolayout', function()
  local currentLayout = externalLayout
  if layout.isBuiltinDisplay() then currentLayout = laptopLayout end
  layout.apply(currentLayout)
end)
hs.urlevent.bind('quick-terminal', function()
  hs.eventtap.keyStroke({}, 'f19', 0, hs.application.get('Ghostty'))
end)
hs.urlevent.bind('wide-terminal', function()
  layout.apply({ Ghostty = { right = 10, y = 10, bottom = 10, w = 1770 } })
end)
hs.urlevent.bind('reload', hs.reload)

-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

toast('Hammerspoon loaded.', 1.5)
