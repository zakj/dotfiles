local ctrl = require 'ctrl'
local hyper = require 'hyper'
local launcher = require 'launcher'
local layout = require 'layout'
local message = require 'message'
local reload = require 'reload'
local superClick = require 'superclick'
local u = require 'util'

reload:start()

hs.hints.style = 'vimperator'
hs.hotkey.setLogLevel('warning')
hs.window.animationDuration = 0

local notesPath = '/Users/zakj/Library/Mobile Documents/27N4MQEA55~pro~writer/Documents'

local function withFocusedWindow(...)
  local varargs = {...}
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
    end, {'read', 'com.apple.finder', 'CreateDesktop'}
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
local function open(name, ...)
  local args = u.map({...}, function (x) return "'" .. x .. "'" end)
  io.popen('open -a "' .. name .. '" ' .. u.join(args, ' '))
end

local function opener(name, ...)
  local args = {...}
  return function() open(name, table.unpack(args)) end
end


local hyperMode = hyper.new({
  {'space', launcher()},
  {';', function() hs.caffeinate.lockScreen() end},
  {'f', opener(hs.settings.get('default-browser') or 'Firefox')},
  {'k', withFocusedWindow(layout.moveCenter)},
  {'l', opener('Slack')},
  {'m', opener('Messages')},
  {'n', opener('Visual Studio Code', notesPath)},
  {'t', opener('kitty')},
  {'u', undock},
  {'v', opener('Visual Studio Code')},
  {'x', superClick},

  -- {nil, 's', function() layout.staggerWindows(hs.application.frontmostApplication()) end},
  -- {nil, 'd', toggleDesktopIcons},
  -- {{'shift'}, 'k', withFocusedWindow(layout.moveCenter, layout.maximizeV)},
  {'left', withFocusedWindow(layout.moveTL, layout.maximizeV)},
  {'right', withFocusedWindow(layout.moveTR, layout.maximizeV)},
  {'1', withFocusedWindow(layout.sizeQuarter, layout.moveTL)},
  {'2', withFocusedWindow(layout.sizeQuarter, layout.moveBL)},
  {'3', withFocusedWindow(layout.sizeQuarter, layout.moveTR)},
  {'4', withFocusedWindow(layout.sizeQuarter, layout.moveBR)},
  {'5', function() hs.window.focusedWindow():setSize(1320, 870 + 75) end},
})


local keysEnabled = true
hs.hotkey.bind('⌘⌃⌥', 'k', function()
  if keysEnabled then
    ctrl:stop()
    hyperMode:stop()
    message.show('Hotkeys disabled.', 2)
  else
    ctrl:start()
    hyperMode:start()
    message.show('Hotkeys enabled.', 2)
  end
  keysEnabled = not keysEnabled
end)
ctrl:start()
hyperMode:start()


-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

message.show('Hammerspoon loaded.', 1.5)
