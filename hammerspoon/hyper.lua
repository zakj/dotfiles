local message = require 'message'
local u = require 'util'

local hyperKeys = {s = true, d = true}
local hyperMsg = '⌘'
local releaseWindow = 0.04  -- allowed delay between presses
local hyperWindow = 0.1 -- hold of hyper keys before activating hyper mode

-- eventtap.new handler returns true to delete an event, false to pass through.
local SUPPRESS_EVENT = true
local PASSTHROUGH_EVENT = false

local hyper = {}

function hyper.new(bindings)
  local self = {}
  local hyperMode = false
  local keyPresses = {}
  local releaseTimer = hs.timer.new(0, function() end)
  local hyperTimer = hs.timer.new(0, function() end)
  local modal = hs.hotkey.modal.new()

  hs.fnutils.each(bindings, function(binding)
    local key, fn = table.unpack(binding)
    modal:bind({}, key, fn)
  end)

  local function releaseAllKeys()
    if u.len(keyPresses) == 0 then return end
    self:stop()
    hs.eventtap.keyStrokes(u.join(u.keys(keyPresses)))
    keyPresses = {}
    self:start()
  end

  modal.entered = function()
    hyperMode = true
    keyPresses = {}
    message.show(hyperMsg)
  end

  modal.exited = function()
    hyperMode = false
    releaseAllKeys()
    message.hide()
  end

  local keyDownTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local chr = e:getCharacters()
    local hasFlags = u.len(e:getFlags()) > 0

    -- Down events continue to emit while holding hyper keys.
    if hyperMode and hyperKeys[chr] then return SUPPRESS_EVENT end

    if hyperKeys[chr] and not hasFlags then
      keyPresses[chr] = true
      if u.len(keyPresses) == u.len(hyperKeys) then
        releaseTimer:stop()
        if not hyperTimer:running() then
          hyperTimer = hs.timer.doAfter(hyperWindow, function () modal:enter() end)
        end
      else
        releaseTimer = hs.timer.doAfter(releaseWindow, releaseAllKeys)
      end
      return SUPPRESS_EVENT
    end

    releaseAllKeys()
    return PASSTHROUGH_EVENT
  end)

  local keyUpTap = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local chr = e:getCharacters()
    local hasFlags = u.len(e:getFlags()) > 0
    hyperTimer:stop()

    if hyperKeys[chr] and not hasFlags then
      -- We can see a "shift-s" keydown followed by a raw "s" keyup.
      local suppressedKeydown = keyPresses[chr]
      modal:exit()
      return u.fif(suppressedKeydown, SUPPRESS_EVENT, PASSTHROUGH_EVENT)
    end

    return PASSTHROUGH_EVENT
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

return hyper
