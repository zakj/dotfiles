bear         = require 'bear'
ctrl         = require 'ctrl'
hotkeyPrefix = require 'hotkeyPrefix'
layout       = require 'layout'
reload       = require 'reload'
superClick   = require 'superclick'
tween        = require 'tween'

bear:start()
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

local modalCfg = {
    size = {w = 100, h = 100},
    duration = 2,
    fadeIn = .25,
    fadeOut = .1,
}
local modalIndicator = hs.canvas.new(modalCfg.size):appendElements({
    action = 'fill', type = 'circle',
    fillColor = { alpha = 0.3 },
    padding = 1,
})
local modalExitTimer = hs.timer.delayed.new(modalCfg.duration, function()
    modal:exit()
end)
function modal:entered()
    modalExitTimer:start()
    local rect = hs.geometry.rectMidPoint(hs.screen.mainScreen():frame())
    rect.x = rect.x - modalCfg.size.w / 2
    rect.y = rect.y - modalCfg.size.h / 2
    modalIndicator:topLeft(rect)
    modalIndicator:show(modalCfg.fadeIn)
end
function modal:exited()
    modalExitTimer:stop()
    modalIndicator:hide(modalCfg.fadeOut)
end


-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

-- Maybe I want an interface more like this?
-- new(set function)
-- :start(from, to, interval, onComplete)
-- tweener = tween.new(function(v) modalIndicator:setAlpha(v) end)
-- tweener:start(0, .3, .25)
-- tweener:start(modalIndicator:alpha(), 0, .1, function() modalIndicator:hide() end)
