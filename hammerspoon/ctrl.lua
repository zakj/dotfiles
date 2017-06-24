local ctrl = hs.eventtap.checkKeyboardModifiers().ctrl
local wantsEscape = false
local timer = hs.timer.delayed.new(0.15, function()
    wantsEscape = false
end)

local function len(t)
    local l = 0
    for _ in pairs(t) do l = l + 1 end
    return l
end

local function handleFlagsChanged(e)
    local flags = e:getFlags()
    local nflags = len(flags)

    -- If control is present and wasn't present last time a modifier was
    -- pressed, consider this a possible ESC.
    if flags.ctrl and not ctrl then
        wantsEscape = true
        timer:start()
    end
    ctrl = flags.ctrl

    if wantsEscape and not flags.ctrl then
        wantsEscape = false
        timer:stop()
        return true, {
            hs.eventtap.event.newKeyEvent({}, 'escape', true),
            hs.eventtap.event.newKeyEvent({}, 'escape', false),
        }
    end
end

-- Pressing any other key cancels the ESC.
local function handleKeyDown()
    wantsEscape = false
end

local types = hs.eventtap.event.types

local handlers = {
    [types.flagsChanged] = handleFlagsChanged,
    [types.keyDown]      = handleKeyDown,
}

return hs.eventtap.new({types.flagsChanged, types.keyDown}, function(e)
    return handlers[e:getType()](e)
end)
