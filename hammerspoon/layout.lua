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

return exports
