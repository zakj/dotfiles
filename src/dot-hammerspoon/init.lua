local layout = require 'layout'
local LeaderKey = require 'leaderkey'
local modtap = require 'modtap'
local reload = require 'reload'
local toast = require 'toast'

modtap:start('cmd', { 'ctrl', 'option', 'cmd', 'shift' }, '1', 0.15)
reload:start()

local function systemKey(name)
  return function()
    -- HACK: without this delay, emitted system key events seem to get lost sometimes.
    hs.timer.doAfter(0.001, function()
      hs.eventtap.event.newSystemKeyEvent(name, true):post()
      hs.eventtap.event.newSystemKeyEvent(name, false):post()
    end)
  end
end

local focusGroup = {
  { 'a', app = 'Arc' },
  { 'f', app = 'Finder' },
  { 'h', app = 'Hammerspoon' },
  { 'i', app = 'Music' },
  { 'l', app = 'Slack' },
  { 'm', app = 'Messages' },
  { 'n', app = 'Obsidian' },
  { 't', app = 'Ghostty' },
  { 'a', app = 'Arc' },
}
local systemGroup = {
  { 'a', desc = 'Toggle system appearance', url = 'raycast://extensions/raycast/system/toggle-system-appearance' },
  { 'c', desc = 'Toggle caffeinate',        url = 'raycast://extensions/mooxl/coffee/caffeinateToggle?launchType=background' },
  { 'l', desc = 'Lock screen',              url = 'raycast://extensions/raycast/system/lock-screen' },
  { ',', app = 'System Settings' },
  { 'h', desc = 'Reload Hammerspoon',       fn = hs.reload },
}
local windowGroup = {
  { 'a', desc = 'Auto layout',     url = 'hammerspoon://autolayout' },
  { 'c', desc = 'Center',          url = 'raycast://customWindowManagementCommand?&name=Center%20(shifted%20up)&position=center&relativeYOffset=-0.05' },
  { 'm', desc = 'Maximize',        url = 'raycast://extensions/raycast/window-management/maximize' },
  { 'r', desc = 'Restore',         url = 'raycast://extensions/raycast/window-management/restore' },
  { 's', desc = 'Reasonable size', url = 'raycast://customWindowManagementCommand?&name=Comfortable%20size&position=center&absoluteWidth=1320.0&absoluteHeight=945.0&relativeYOffset=-0.05' },
  { 't', desc = 'Wide terminal',   url = 'hammerspoon://wide-terminal' },
}
local audioGroup = {
  { 'space', desc = 'Play/pause',      fn = systemKey('PLAY') },
  { 'h',     desc = 'Previous track',  fn = systemKey('PREVIOUS') },
  { 'l',     desc = 'Next track',      fn = systemKey('NEXT') },
  { 'k',     desc = 'Increase volume', fn = systemKey('SOUND_UP'),   sticky = true },
  { 'j',     desc = 'Decrease volume', fn = systemKey('SOUND_DOWN'), sticky = true },
  { 'm',     desc = 'Mute',            fn = systemKey('MUTE') },
}
local keymap = {
  { 'e', desc = 'Emoji picker', url = "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols" },
  { 't', app = 'Ghostty' },
  { '`', desc = '→ quick', url = "hammerspoon://quick-terminal" },
  { 'tab', desc = 'Window switcher', url = "raycast://extensions/raycast/navigation/switch-windows" },
  { 'f', desc = 'Focus', children = focusGroup },
  { 's', desc = 'System', children = systemGroup, },
  { 'v', desc = 'Audio', children = audioGroup },
  { 'w', desc = 'Windows', children = windowGroup },
}
LeaderKey.new({ 'cmd', 'ctrl', 'option', 'shift' }, '1', keymap)

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
  Obsidian = { x = "center", y = "center", w = 900, h = 1100 },
  Slack = function(app, win)
    if win ~= layout.widestVisibleWindow(app) then
      return { x = 1100 + gap, y = 1 / 5, w = 550, h = 950 }
    end
    return { x = 0, y = 1 / 5, w = 1100, bottom = 0 }
  end
}

local laptopLayout = hs.fnutils.copy(externalLayout)
laptopLayout.Ghostty = { right = 0, w = 1100, y = 0, bottom = 0 }
laptopLayout.Slack = function(app, win)
  if win ~= layout.widestVisibleWindow(app) then
    -- TODO maybe w = 550 and align right?
    return { x = 1100, y = gap, right = 0, bottom = 0 }
  end
  return { x = 0, y = gap, w = 1100, bottom = 0 }
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
