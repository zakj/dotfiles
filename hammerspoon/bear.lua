-- Resize the window when adding/removing columns in Bear.

local tagsWidth = 215
local notesWidth = 280
local editorWidth = 575

local keys = {
    [1] = {
        menuItem = 'Show Tags, Notes and Editor',
        width = tagsWidth + notesWidth + editorWidth,
    },
    [2] = {
        menuItem = 'Show Notes and Editor',
        width = notesWidth + editorWidth,
    },
    [3] = {
        menuItem = 'Show Editor Only',
        width = editorWidth + 80,
    },
}

local hotkeys = hs.hotkey.modal.new()

local resizeTimer = {stop = function() end}
for key, config in pairs(keys) do
    hotkeys:bind({'cmd, ctrl'}, tostring(key), function()
        local win = hs.window.focusedWindow()
        local size = win:size()
        local app = hs.application.frontmostApplication()
        resizeTimer:stop()
        app:selectMenuItem(config.menuItem)
        resizeTimer = hs.timer.doAfter(.3, function()
            win:setSize(config.width, size.h)
        end)
    end)
end

local eventHandlers = {
    [hs.application.watcher.activated] = hotkeys.enter,
    [hs.application.watcher.deactivated] = hotkeys.exit,
    [hs.application.watcher.terminated] = hotkeys.exit,
}

watcher = hs.application.watcher.new(function(appName, eventType, app)
    handler = eventHandlers[eventType]
    if handler and appName == 'Bear' then
        handler(hotkeys)
    end
end):start()
