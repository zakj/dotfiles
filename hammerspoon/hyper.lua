message = require 'message'

local hyperKeys = {s = true, d = true}
local hyperMsg = '⌘'
local releaseWindow = 0.04  -- allowed delay between presses

function len(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end

hyper = {}

function hyper.new(bindings)
  local self = {}
  local hyperMode = false
  local keyPresses = {}
  local modal = hs.hotkey.modal.new()
  local passthroughKeyPresses = {}

  hs.fnutils.each(bindings, function(binding)
    local key, fn = table.unpack(binding)
    modal:bind({}, key, fn)
  end)

  local function releaseKey(chr)
    if not keyPresses[chr] then return end
    keyPresses[chr] = nil
    passthroughKeyPresses[chr] = true
    hs.eventtap.keyStroke(nil, chr, 0)
  end

  local function setHyperMode()
    prev = hyperMode
    hyperMode = len(keyPresses) >= len(hyperKeys)
    if prev == hyperMode then return end
    if hyperMode then
      keyPresses = {}
      message.show(hyperMsg)
      modal:enter()
    else
      message.hide()
      modal:exit()
    end
  end

  local keyDownTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local chr = e:getCharacters()
    if passthroughKeyPresses[chr] then
      passthroughKeyPresses[chr] = nil
      return false
    end
    local flags = e:getFlags()
    if not flags:containExactly({}) or not hyperKeys[chr] then return false end
    if hyperMode then return true end  -- down events continue to emit while holding
    keyPresses[chr] = true
    hs.timer.doAfter(releaseWindow, function() releaseKey(chr) end)
    setHyperMode()
    return true
  end)

  local keyUpTap = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local chr = e:getCharacters()
    if not hyperKeys[chr] or passthroughKeyPresses[chr] then return false end
    releaseKey(chr)
    setHyperMode()
    return true
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
