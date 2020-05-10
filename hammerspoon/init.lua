ctrl         = require 'ctrl'
hotkeyPrefix = require 'hotkeyPrefix'
hyper        = require 'hyper'
layout       = require 'layout'
message      = require 'message'
reload       = require 'reload'
superClick   = require 'superclick'
tween        = require 'tween'

ctrl:start()
reload:start()

hs.hints.style = 'vimperator'
hs.hotkey.setLogLevel('warning')
hs.window.animationDuration = 0


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

local function lockScreen()
    version = hs.host.operatingSystemVersion()
    if version.major > 10 or (version.major == 10 and version.minor >= 13) then
        hs.eventtap.keyStroke({'cmd', 'ctrl'}, 'q')
    else
        os.execute('"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend')
    end
end

local function toggleDesktopIcons()
    t = hs.task.new('/usr/bin/defaults', nil, {'read', 'com.apple.finder', 'CreateDesktop'})
    t:setCallback(function(exitCode, stdOut, stdErr)
        local hidden = exitCode == 0 or stdOut:gsub('%s+', '') == '0'
        if hidden then
            os.execute('defaults delete com.apple.finder CreateDesktop')
        else
            os.execute('defaults write com.apple.finder CreateDesktop -bool false')
        end
        os.execute('killall Finder')
    end)
    t:start()
end

local function openFinderSelectionWithCurrentApp()
    local app = hs.application.frontmostApplication():name()
    hs.osascript.applescript(string.format([[
      tell application "Finder"
        set finderSelection to the selection as text
      end tell
      tell application "%s"
        open finderSelection
      end tell
    ]], app))
end

local function undock()
    for path, volume in pairs(hs.fs.volume.allVolumes()) do
        if not volume.NSURLVolumeIsInternalKey then
            hs.fs.volume.eject(path)
        end
    end
    hs.caffeinate.systemSleep()
end


hyperMode = hyper.new({
  {';', lockScreen},
  {'f', function() hs.application.open('Firefox') end},
  {'i', function() hs.application.open('iA Writer') end},
  {'k', withFocusedWindow(layout.moveCenter)},
  {'l', function() hs.application.open('Slack') end},
  {'m', function() hs.application.open('Messages') end},
  {'t', function() hs.application.open('iTerm') end},
  {'u', undock},
  {'v', function() hs.application.open('Visual Studio Code') end},
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
hyperMode:start()


-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

message.show('Hammerspoon loaded.', 1.5)
