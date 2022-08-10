local ctrl = hs.eventtap.checkKeyboardModifiers().ctrl
local wantsEscape = false
local timer = hs.timer.delayed.new(0.3, function() wantsEscape = false end)

-- eventtap callbacks return true to suppress the original event.
local SUPPRESS_EVENT = true

local function handleFlagsChanged(e)
  local flags = e:getFlags()

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
    return SUPPRESS_EVENT, {
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

return hs.eventtap.new({ types.flagsChanged, types.keyDown }, function(e)
  return handlers[e:getType()](e)
end)
