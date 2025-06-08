local layout = require 'layout'
local modtap = require 'modtap'
local reload = require 'reload'
local toast = require 'toast'

modtap:start('cmd', {'ctrl', 'option', 'cmd', 'shift'}, '1', 0.1)
reload:start()

local function isProgrammableKeyboard(device) return device.productName == 'Keychron K7 Pro' end
if not hs.fnutils.some(hs.usb.attachedDevices(), isProgrammableKeyboard) then
  modtap:start('ctrl', {}, 'escape', 0.3)
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
