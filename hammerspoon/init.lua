hotkeyPrefix = require 'hotkeyPrefix'
layout = require 'layout'
require 'mixpanel'
require 'reload'
require 'safari'
superClick = require 'superclick'
tween = require 'tween'

hs.hints.style = 'vimperator'
hs.window.animationDuration = 0


function withFocusedWindow(...)
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
    os.execute('"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend')
end


modal = hotkeyPrefix({'ctrl'}, 'space', {
    {nil, 's', function() layout.staggerWindows(hs.application.frontmostApplication()) end},
    {nil, 'l', lockScreen},
    {nil, 'd', withFocusedWindow(debugWindow)},
    {nil, 'h', hs.hints.windowHints},
    {nil, '`', hs.toggleConsole},
    {nil, 'k', withFocusedWindow(layout.moveCenter)},
    {{'shift'}, 'k', withFocusedWindow(layout.moveCenter, layout.maximizeV)},
    {nil, 'left', withFocusedWindow(layout.moveTL, layout.maximizeV)},
    {nil, 'right', withFocusedWindow(layout.moveTR, layout.maximizeV)},
    {nil, 'c', function()
        hs.window.focusedWindow():setSize(1003, 600)
    end},
    {nil, 'v', function()
        hs.window.focusedWindow():setSize(1320, 870 + 75)
    end},
    {nil, 'x', superClick},
})

modalIndicator = hs.drawing.circle({w = 100, h = 100}):setFillColor({0, 0, 0})
local modalExitTimer
local tweener = {cancel = function() end}
function modal:entered()
    modalExitTimer = hs.timer.doAfter(2, function() modal:exit() end)
    local topLeft = hs.geometry.rectMidPoint(hs.screen.mainScreen():frame())
    topLeft.x = topLeft.x - 50
    topLeft.y = topLeft.y - 50
    modalIndicator:setTopLeft(topLeft)
    modalIndicator:show()
    tweener.cancel()
    tweener = tween(modalIndicator.setAlpha, modalIndicator, 0, .3, .25)
end
function modal:exited()
    modalExitTimer:stop()
    tweener.cancel()
    tweener = tween(modalIndicator.setAlpha, modalIndicator, .3, 0, .1)
    tweener.onComplete(function() modalIndicator:hide() end)
end


-- Maybe I want an interface more like this?
-- new(set function)
-- :start(from, to, interval, onComplete)
-- tweener = tween.new(function(v) modalIndicator:setAlpha(v) end)
-- tweener:start(0, .3, .25)
-- tweener:start(modalIndicator:alpha(), 0, .1, function() modalIndicator:hide() end)
