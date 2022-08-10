local u = require 'util'

local State = {
  IDLE = 'IDLE',
  TYPING = 'TYPING',
  SPACE_DOWN = 'SPACE_DOWN',
  SYNTHETIC_SPACE = 'SYNTHETIC_SPACE',
  SPACE_HELD = 'SPACE_HELD',
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

  local function enterTyping()
    state = State.TYPING
    idleTimer:start()
  end

  local function sendSyntheticSpace()
    heldTimer:stop()
    state = State.SYNTHETIC_SPACE
    hs.eventtap.event.newKeyEvent('space', true):post()
  end

  -- eventtap callbacks return true to suppress the original event.
  local function suppressEvent() return true end

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
      [Message.HELD_TIMER] = function()
        state = State.SPACE_HELD
        hs.eventtap.event.newKeyEvent(hyperKey, true):post()
        heldTimer:start()
        idleTimer:stop()
      end,
    },

    [State.SYNTHETIC_SPACE] = {
      [Message.KEYDOWN_SPACE] = function() state = State.IDLE end,
    },

    -- An in-between state; send the hyper key for a quick transition to hyper
    -- mode, but also send a synthetic space event if we see a space up during
    -- this window to allow for tapping space from IDLE.
    [State.SPACE_HELD] = {
      [Message.KEYDOWN_SPACE] = suppressEvent,
      [Message.KEYUP_SPACE] = function()
        sendSyntheticSpace()
        hs.eventtap.event.newKeyEvent(hyperKey, false):post()
      end,
      [Message.HELD_TIMER] = function() state = State.HYPER end,
    },

    [State.HYPER] = {
      [Message.KEYDOWN_SPACE] = suppressEvent,
      [Message.KEYUP_SPACE] = function()
        heldTimer:stop()
        state = State.IDLE
        hs.eventtap.event.newKeyEvent(hyperKey, false):post()
      end,
    },
  }

  local function handleMessage(message, event)
    local handler = stateMap[state][message]
    if handler ~= nil then return handler(event) end
  end

  idleTimer = hs.timer.delayed.new(0.2, function() handleMessage(Message.IDLE_TIMER) end)
  heldTimer = hs.timer.delayed.new(0.1, function() handleMessage(Message.HELD_TIMER) end)

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

  function self.start()
    keyDownTap:start()
    keyUpTap:start()
  end

  function self.stop()
    keyDownTap:stop()
    keyUpTap:stop()
  end

  return self
end

return init()
