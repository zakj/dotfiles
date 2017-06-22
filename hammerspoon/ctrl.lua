local ctrl = hs.eventtap.checkKeyboardModifiers().ctrl
local wantsEscape = false
local timer = hs.timer.delayed.new(0.15, function()
    wantsEscape = false
end)

function len(t)
    local l = 0
    for _ in pairs(t) do l = l + 1 end
    return l
end

flagsTap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
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
end):start()

-- Pressing any other key cancels the ESC.
keyDownTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function()
    wantsEscape = false
end):start()
