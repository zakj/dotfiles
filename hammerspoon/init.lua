local ctrl = require 'ctrl'
local layout = require 'layout'
local message = require 'message'
local reload = require 'reload'
local superClick = require 'superclick'
local u = require 'util'

ctrl:start()
reload:start()

hs.hints.style = 'vimperator'
hs.hotkey.setLogLevel('warning')
hs.window.animationDuration = 0

local menuItem = hs.menubar.new(false)

local function withFocusedWindow(...)
  local varargs = { ... }
  return function()
    for i, fn in ipairs(varargs) do
      fn(hs.window.focusedWindow())
    end
  end
end

local function debugWindow(win)
  local frame = win:frame()
  local notif = hs.notify.new(nil, {
    title = win:title(),
    informativeText = string.format('%s\n(%.0f, %.0f) %.0f⨉%.0f',
      win:application():title(), frame.x, frame.y, frame.w, frame.h),
    autoWithdraw = false,
  })
  notif:send()
  hs.timer.doAfter(30, function()
    notif:withdraw()
    notif:release()
  end)
end

local function toggleDesktopIcons()
  hs.task.new('/usr/bin/defaults', function(exitCode, stdOut, stdErr)
    local hidden = exitCode == 0 or stdOut:gsub('%s+', '') == '0'
    if hidden then
      os.execute('defaults delete com.apple.finder CreateDesktop')
    else
      os.execute('defaults write com.apple.finder CreateDesktop -bool false')
    end
    os.execute('killall Finder')
  end, { 'read', 'com.apple.finder', 'CreateDesktop' }
  ):start()
end

local function undock()
  for path, volume in pairs(hs.fs.volume.allVolumes()) do
    if not volume.NSURLVolumeIsInternalKey then
      hs.fs.volume.eject(path)
    end
  end
  hs.caffeinate.systemSleep()
end

-- hs.application.open can be slow.
-- TODO hs.application.launchOrFocus()
local function open(name, ...)
  local args = u.map({ ... }, function(x) return "'" .. x .. "'" end)
  io.popen('open -a "' .. name .. '" ' .. u.join(args, ' '))
end

local function toggleCaffeinate()
  local sleeping = hs.caffeinate.toggle('displayIdle')
  if sleeping then
    menuItem:returnToMenuBar()
    menuItem:setClickCallback(toggleCaffeinate)
    menuItem:setIcon(hs.image.imageFromName('NSTouchBarControlStripLockScreenTemplate'))
  else
    menuItem:removeFromMenuBar()
  end
end

local function openAndResizeObsidian()
  open('Obsidian')
  hs.timer.waitUntil(
    function()
      local app = hs.application.frontmostApplication()
      return app:name() == 'Obsidian' and app:focusedWindow() ~= nil
    end,
    function() hs.window.focusedWindow():setSize(850, 1050) end,
    .1
  )
end

local modal = hs.hotkey.modal.new({'option'}, 'space')
local modalTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function (event)
  hs.timer.doAfter(0.1, function() modal:exit() end)
end)
modal.entered = function()
  message.show('⌘')
  modalTap:start()
end
modal.exited = function()
  message.hide()
  modalTap:stop()
end

local function launch(name)
  return function() hs.application.launchOrFocus(name) end
end

modal
  -- Utility:
  :bind({}, 'escape', function() modal:exit() end)
  :bind({}, ';', function() hs.caffeinate.lockScreen() end)
  :bind({}, "'", toggleCaffeinate)
  -- :bind({}, 'u', undock)
  -- :bind({}, 'x', superClick)
  -- :bind({}, 'd', toggleDesktopIcons)

  -- Applications:
  :bind({}, 'f', launch(hs.settings.get('default-browser') or 'Safari'))
  :bind({}, 'h', launch('Things3'))
  :bind({}, 'l', launch('Slack'))
  :bind({}, 'm', launch('Messages'))
  :bind({}, 'n', launch('Obsidian'))
  :bind({ 'shift' }, 'n', openAndResizeObsidian)
  :bind({}, 't', launch('kitty'))
  :bind({}, 'v', launch('Visual Studio Code'))

  -- Window layouts:
  :bind({ 'shift' }, 'k', withFocusedWindow(layout.moveCenter, layout.maximizeV))
  :bind({}, 'k', withFocusedWindow(layout.moveCenter))
  :bind({}, 'left', withFocusedWindow(layout.moveTL, layout.maximizeV))
  :bind({}, 'right', withFocusedWindow(layout.moveTR, layout.maximizeV))
  :bind({}, '1', withFocusedWindow(layout.sizeQuarter, layout.moveTL))
  :bind({}, '2', withFocusedWindow(layout.sizeQuarter, layout.moveBL))
  :bind({}, '3', withFocusedWindow(layout.sizeQuarter, layout.moveTR))
  :bind({}, '4', withFocusedWindow(layout.sizeQuarter, layout.moveBR))
  :bind({}, '5', withFocusedWindow(function(w) w:setSize(1320, 870 + 75) end))


-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

message.show('Hammerspoon loaded.', 1.5)
