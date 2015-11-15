-- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/layout/init.lua

local exports = {}

-- {app name or nil, window name or nil, screen name or screen or nil, rect}
function exports.apply(layout)
    for _, row in pairs(layout) do
        local appName, title, screen, rect = table.unpack(row)
        local app
        local windows

        if appName then
            app = hs.appfinder.appFromName(appName)
        end
        if app then
            windows = app:visibleWindows()
        else
            windows = hs.window.visibleWindows()
        end

        windows = hs.fnutils.filter(windows, function(w)
            return not title or w:title() == title
        end)
        -- hs.fnutils.each(windows, function(w)
        --     w:setFrame(rect)
        -- end)
    end
end

function exports.staggerWindows(app)
    local staggerSize = 22
    local topLeft
    hs.fnutils.each(app:visibleWindows(), function(w)
        if w:size().h == 1 then return end  -- ignore magic Chrome windows
        if topLeft == nil then
            topLeft = w:topLeft()
        else
            topLeft.x = topLeft.x + staggerSize
            w:setTopLeft(topLeft)
        end
    end)
end

function exports.moveCenter(win)
    local frame = win:frame()
    local screen = win:screen():fullFrame()
    frame.x = screen.w / 2 - frame.w / 2 + screen.x
    frame.y = screen.h / 2 - frame.h / 2 + screen.y
    win:setTopLeft(frame)
end

function exports.moveTL(win)
    local frame = win:frame()
    local screen = win:screen():frame()
    frame.x = screen.x
    frame.y = screen.y
    win:setFrame(frame)
end

function exports.moveTR(win)
    local frame = win:frame()
    local screen = win:screen():frame()
    frame.x = screen.x + screen.w - frame.w
    frame.y = screen.y
    win:setFrame(frame)
end

function exports.maximizeV(win)
    local frame = win:frame()
    local screen = win:screen():frame()
    frame.y = screen.y
    frame.h = screen.h
    win:setFrame(frame)
end

return exports
