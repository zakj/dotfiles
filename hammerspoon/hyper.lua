message = require 'message'
u = require 'util'

local hyperKeys = {s = true, d = true}
local hyperMsg = '⌘'
local releaseWindow = 0.04  -- allowed delay between presses

-- eventtap.new handler returns true to delete an event, false to pass through.
local SUPPRESS_EVENT = true
local PASSTHROUGH_EVENT = false

hyper = {}

function hyper.new(bindings)
  local self = {}
  local hyperMode = false
  local keyPresses = {}
  local modal = hs.hotkey.modal.new()

  hs.fnutils.each(bindings, function(binding)
    local key, fn = table.unpack(binding)
    modal:bind({}, key, fn)
  end)

  modal.entered = function()
    keyPresses = {}
    message.show(hyperMsg)
  end

  modal.exited = function()
    message.hide()
  end

  local function releaseAllKeys()
    if u.len(keyPresses) == 0 then return end
    self:stop()
    hs.eventtap.keyStrokes(u.join(u.keys(keyPresses)))
    keyPresses = {}
    self:start()
  end

  local function updateHyperMode()
    prev = hyperMode
    hyperMode = u.len(keyPresses) >= u.len(hyperKeys)
    if prev == hyperMode then return end
    if hyperMode then
      modal:enter()
    else
      modal:exit()
    end
  end

  local keyDownTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local chr = e:getCharacters()
    local hasFlags = u.len(e:getFlags()) > 0

    -- Down events continue to emit while holding hyper keys.
    if hyperMode and hyperKeys[chr] then return SUPPRESS_EVENT end

    if hyperKeys[chr] and not hasFlags then
      keyPresses[chr] = true
      hs.timer.doAfter(releaseWindow, releaseAllKeys)
      updateHyperMode()
      return SUPPRESS_EVENT
    end

    releaseAllKeys()
    return PASSTHROUGH_EVENT
  end)

  local keyUpTap = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local chr = e:getCharacters()
    local hasFlags = u.len(e:getFlags()) > 0

    -- Also check keyPresses, since you can get a "shift-s" keydown followed by a raw "s" keyup.
    if keyPresses[chr] and hyperKeys[chr] and not hasFlags then
      releaseAllKeys()
      updateHyperMode()
      return SUPPRESS_EVENT
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
