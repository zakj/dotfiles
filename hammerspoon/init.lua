hotkeyPrefix = require 'hotkeyPrefix'
layout = require 'layout'
require 'reload'
require 'safari'


function debugFocusedWindow()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local notif = hs.notify.new(nil, {
        title = win:title(),
        informativeText = string.format('%s\n(%.0f, %.0f) %.0f⨉%.0f',
            win:application():title(), frame.x, frame.y, frame.w, frame.h),
    })
    notif:send()
    hs.timer.doAfter(30, function()
        notif:withdraw()
        notif:release()
    end)
end


hs.hints.style = 'vimperator'

modal = hotkeyPrefix({'ctrl'}, 'space', {
    {nil, 'd', debugFocusedWindow},
    {nil, 'h', hs.hints.windowHints},
    {nil, 'space', function()
        -- Send to Phoenix for now.
        hs.eventtap.keyStroke({'ctrl', 'alt', 'cmd'}, 'q')
    end},
    {nil, 'c', function()
        hs.window.focusedWindow():setSize({w = 1003, h = 600})
    end},
    {nil, 'v', function()
        hs.window.focusedWindow():setSize({w = 1320, h = 942})
    end},
})

modalIndicator = hs.drawing.circle({w = 100, h = 100})
    :setFillColor({0, 0, 0}):setAlpha(.2)
local modalExitTimer
function modal:entered()
    modalExitTimer = hs.timer.doAfter(2, function() modal:exit() end)
    local topLeft = hs.geometry.rectMidPoint(hs.screen.mainScreen():frame())
    topLeft.x = topLeft.x - 50
    topLeft.y = topLeft.y - 50
    modalIndicator:setTopLeft(topLeft)
    modalIndicator:show()
end
function modal:exited()
    modalExitTimer:stop()
    modalIndicator:hide()
end
