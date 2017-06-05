-- Use cmd-n to switch tabs in Safari.

local hotkeys = hs.hotkey.modal.new()

for i = 1, 9 do
    hotkeys:bind({'cmd'}, tostring(i), function()
        hs.applescript.applescript('tell front window of app "Safari" to set current tab to tab ' .. i)
    end)
end

local eventHandlers = {
    [hs.application.watcher.activated] = hotkeys.enter,
    [hs.application.watcher.deactivated] = hotkeys.exit,
    [hs.application.watcher.terminated] = hotkeys.exit,
}

watcher = hs.application.watcher.new(function(appName, eventType, app)
    handler = eventHandlers[eventType]
    if handler and appName == 'Safari' then
        handler(hotkeys)
    end
end):start()
