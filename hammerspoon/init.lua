function testMjomatic()
    hs.mjomatic.go({
        "ttttt.cccccccc..",
        "ttttt.cccccccc..",
        "ttttt.cccccccc..",
        "ttttt.cccccccc..",
        "ttttt.cccccccc..",
        "......cccccccc..",
        "......cccccccc..",
        "",
        "c Google Chrome",
        "t iTerm",
    })
end


-- Use cmd-n to switch tabs in Safari.
(function()
    local safariHotkeys = {}

    for i = 1, 9 do
        local hotkey = hs.hotkey.new({'cmd'}, tostring(i), function()
            hs.applescript.applescript('tell front window of app "Safari" to set current tab to tab ' .. i)
        end)
        table.insert(safariHotkeys, hotkey)
    end

    hs.application.watcher.new(function(appName, eventType, app)
        if appName ~= 'Safari' then return end
        if eventType == hs.application.watcher.activated then
            for _, key in pairs(safariHotkeys) do
                key:enable()
            end
        elseif eventType == hs.application.watcher.deactivated then
            for _, key in pairs(safariHotkeys) do
                key:disable()
            end
        end
    end):start()
end)()


-- Reload config on change.
hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/init.lua', hs.reload):start()

hs.alert('Loaded Hammerspoon config.')
