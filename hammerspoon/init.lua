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


modal = hotkeyPrefix({'ctrl'}, 'space', {
    {nil, 's', function() layout.staggerWindows(hs.application.frontmostApplication()) end},
    {nil, 'l', lockScreen},
    {nil, 'd', toggleDesktopIcons},
    {{'shift'}, 'd', withFocusedWindow(debugWindow)},
    {nil, 'h', hs.hints.windowHints},
    {nil, '`', hs.toggleConsole},
    {nil, 'k', withFocusedWindow(layout.moveCenter)},
    {{'shift'}, 'k', withFocusedWindow(layout.moveCenter, layout.maximizeV)},
    {nil, 'left', withFocusedWindow(layout.moveTL, layout.maximizeV)},
    {nil, 'right', withFocusedWindow(layout.moveTR, layout.maximizeV)},
    {nil, 'o', openFinderSelectionWithCurrentApp},
    {nil, 'u', undock},
    {nil, 'c', function()
        hs.window.focusedWindow():setSize(1003, 600)
    end},
    {nil, 'v', function()
        hs.window.focusedWindow():setSize(1320, 870 + 75)
    end},
    {nil, 'x', superClick},
})

modalCfg = {
    size = {w = 100, h = 100},
    duration = 2,
    fadeIn = .25,
    fadeOut = .1,
}
modalIndicator = hs.canvas.new(modalCfg.size):appendElements({
    action = 'fill', type = 'circle',
    fillColor = { alpha = 0.3 },
    padding = 1,
}, {
    action = 'stroke', type = 'arc', arcRadii = false,
    startAngle = 0, endAngle = 360,
    strokeColor = { red = 1, green = 1, blue = 1 },
    strokeWidth = 1,
    padding = 1.5,
}, {
    action = 'stroke', type = 'arc', arcRadii = false,
    startAngle = 0, endAngle = 360,
    strokeColor = { red = 1, green = 1, blue = 1 },
    strokeWidth = 3,
    padding = 3,
})
modalExitTimer = hs.timer.delayed.new(modalCfg.duration, function()
    modal:exit()
end)
modalTween = tween.new(360, 0, modalCfg.duration, function(v)
    modalIndicator[3].endAngle = v
end)

function modal:entered()
    modalExitTimer:start()
    modalTween:start()
    local rect = hs.geometry.rectMidPoint(hs.screen.mainScreen():frame())
    rect.x = rect.x - modalCfg.size.w / 2
    rect.y = rect.y - modalCfg.size.h / 2
    modalIndicator:topLeft(rect)
    modalIndicator:show(modalCfg.fadeIn)
end
function modal:exited()
    modalExitTimer:stop()
    modalTween:cancel()
    modalIndicator:hide(modalCfg.fadeOut)
    -- Calling hide while show is still animating can cause alpha to get stuck.
    hs.timer.doAfter(modalCfg.fadeIn + modalCfg.fadeOut, function()
        modalIndicator:alpha(1)
    end)
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
  -- {nil, 'v', function() hs.window.focusedWindow():setSize(1320, 870 + 75) end},
  -- {{'shift'}, 'k', withFocusedWindow(layout.moveCenter, layout.maximizeV)},
  {'left', withFocusedWindow(layout.moveTL, layout.maximizeV)},
  {'right', withFocusedWindow(layout.moveTR, layout.maximizeV)},
  {'1', withFocusedWindow(layout.sizeQuarter, layout.moveTL)},
  {'2', withFocusedWindow(layout.sizeQuarter, layout.moveBL)},
  {'3', withFocusedWindow(layout.sizeQuarter, layout.moveTR)},
  {'4', withFocusedWindow(layout.sizeQuarter, layout.moveBR)},
})
hyperMode:start()


-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

message.show('Hammerspoon loaded.', 1.5)
