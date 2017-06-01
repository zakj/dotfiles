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

hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
    local flags = e:getFlags()
    local nflags = len(flags)

    -- If control is present, is the only modifier present, and wasn't present
    -- last time a modifier was pressed, consider this a possible ESC. If
    -- another modifier is also present, cancel the ESC.
    if flags.ctrl then
        if ctrl ~= flags.ctrl and nflags == 1 then
            wantsEscape = true
            timer:start()
        else
            wantsEscape = false
        end
    end
    ctrl = flags.ctrl

    if nflags == 0 and wantsEscape then
        return true, {
            hs.eventtap.event.newKeyEvent({}, 'escape', true),
            hs.eventtap.event.newKeyEvent({}, 'escape', false),
        }
    end
end):start()

-- Pressing any other key cancels the ESC.
hs.eventtap.new({hs.eventtap.event.types.keyDown}, function()
    wantsEscape = false
end):start()
