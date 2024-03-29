local u = require 'util'

local State = {
  IDLE = 'IDLE',
  TYPING = 'TYPING',
  SPACE_DOWN = 'SPACE_DOWN',
  SYNTHETIC_SPACE = 'SYNTHETIC_SPACE',
  HYPER = 'HYPER',
}

local Message = {
  KEYDOWN_SPACE = 'KEYDOWN_SPACE',
  KEYDOWN_OTHER = 'KEYDOWN_OTHER',
  KEYUP_SPACE = 'KEYUP_SPACE',
  IDLE_TIMER = 'IDLE_TIMER',
  HELD_TIMER = 'HELD_TIMER',
}

local function startMachine(hyperKey)
  local state = State.IDLE
  local idleTimer
  local heldTimer

  -- eventtap callbacks return true to suppress the original event.
  local function suppressEvent() return true end

  local function enterTyping()
    state = State.TYPING
    idleTimer:start()
  end

  local function sendSyntheticSpace()
    heldTimer:stop()
    state = State.SYNTHETIC_SPACE
    hs.eventtap.event.newKeyEvent('space', true):post()
    hs.eventtap.event.newKeyEvent('space', false):post()
    return suppressEvent()
  end

  local stateMap = {
    [State.IDLE] = {
      [Message.KEYDOWN_SPACE] = function(event)
        -- Ignore/pass through if any modifier is held.
        if u.len(event:getFlags()) > 0 then return end

        state = State.SPACE_DOWN
        heldTimer:start()
        return suppressEvent()
      end,
      [Message.KEYDOWN_OTHER] = enterTyping,
    },

    [State.TYPING] = {
      [Message.KEYDOWN_SPACE] = enterTyping,
      [Message.KEYDOWN_OTHER] = enterTyping,
      [Message.IDLE_TIMER] = function() state = State.IDLE end,
    },

    [State.SPACE_DOWN] = {
      [Message.KEYUP_SPACE] = sendSyntheticSpace,
      [Message.KEYDOWN_OTHER] = function(event)
        -- Ensure the space keydown event is sent before this one.
        sendSyntheticSpace()
        hs.eventtap.event.newKeyEvent(event:getCharacters(), true):post()
        return suppressEvent()
      end,
      [Message.HELD_TIMER] = function()
        state = State.HYPER
        hs.eventtap.event.newKeyEvent(hyperKey, true):post()
        idleTimer:stop()
      end,
    },

    [State.SYNTHETIC_SPACE] = {
      [Message.KEYDOWN_SPACE] = enterTyping,
    },

    [State.HYPER] = {
      [Message.KEYDOWN_SPACE] = suppressEvent,
      [Message.KEYUP_SPACE] = function()
        state = State.IDLE
        -- HACK: Something causes newKeyEvent to include an fn keydown when
        -- sending hyperKey as f18. Somehow that would then get stuck;
        -- subsequent keypresses would act like fn was still down. For some
        -- reason explicitly resetting flags here seems to solve it.
        hs.eventtap.event.newKeyEvent(hyperKey, false):setFlags({}):post()
      end,
    },
  }

  local function handleMessage(message, event)
    local handler = stateMap[state][message]
    if handler ~= nil then return handler(event) end
  end

  idleTimer = hs.timer.delayed.new(0.2, function() handleMessage(Message.IDLE_TIMER) end)
  heldTimer = hs.timer.delayed.new(0.15, function() handleMessage(Message.HELD_TIMER) end)

  return handleMessage
end

local function init()
  local self = {}
  local send = startMachine('f18')

  local keyDownTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    local message = u.fif(e:getCharacters() == ' ', Message.KEYDOWN_SPACE, Message.KEYDOWN_OTHER)
    return send(message, e)
  end)

  local keyUpTap = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(e)
    if e:getCharacters() == ' ' then return send(Message.KEYUP_SPACE) end
  end)

  local cafWatcher = hs.caffeinate.watcher.new(function()
    -- When locking the screen or going to sleep while in a non-idle state
    -- (e.g., because we used a space-based shortcut), Hammerspoon won't see
    -- the keyup event. Send one artificially to avoid needing to manually hit
    -- space to break out of SPACE_DOWN/HYPER.
    return send(Message.KEYUP_SPACE)
  end)

  function self.isEnabled()
    return keyDownTap:isEnabled() or keyUpTap:isEnabled()
  end

  function self.start()
    keyDownTap:start()
    keyUpTap:start()
    cafWatcher:start()
  end

  function self.stop()
    keyDownTap:stop()
    keyUpTap:stop()
    cafWatcher:stop()
  end

  return self
end

return init()
