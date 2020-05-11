message = require 'message'

local hyperKeys = {s = true, d = true}
local hyperMsg = '⌘'
local releaseWindow = 0.04  -- allowed delay between presses

local function len(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end

local function append(t1, t2)
  for _, v in pairs(t2) do
    table.insert(t1, v)
  end
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

  modal.entered = function()
    keyPresses = {}
    message.show(hyperMsg)
  end

  modal.exited = function()
    message.hide()
  end

  local function releaseKey(chr)
    if not keyPresses[chr] then return end
    keyPresses[chr] = nil
    passthroughKeyPresses[chr] = true
    return hs.eventtap.event.newKeyEventSequence({}, chr)
  end

  local function releaseAllKeys()
    local events = {}
    for chr, _ in pairs(keyPresses) do
      append(events, releaseKey(chr))
    end
    return events
  end

  local function emitAll(events)
    for i, event in ipairs(events) do
      event:post()
    end
  end

  local function setHyperMode()
    prev = hyperMode
    hyperMode = len(keyPresses) >= len(hyperKeys)
    if prev == hyperMode then return end
    if hyperMode then
      modal:enter()
    else
      modal:exit()
    end
  end

  local keyDownTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e)
    local chr = e:getCharacters()
    if passthroughKeyPresses[chr] then
      return false
    end
    if not hyperKeys[chr] or len(e:getFlags()) > 0 then
      -- If we see a non-hyper before the release window, probably just typing fast.
      return false, releaseAllKeys()
    end
    if hyperMode then return true end  -- down events continue to emit while holding
    keyPresses[chr] = true
    hs.timer.doAfter(releaseWindow, function() emitAll(releaseAllKeys()) end)
    setHyperMode()
    return true
  end)

  local keyUpTap = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(e)
    local chr = e:getCharacters()
    if passthroughKeyPresses[chr] then
      passthroughKeyPresses[chr] = nil
      return false
    end
    if not hyperKeys[chr] or passthroughKeyPresses[chr] or len(e:getFlags()) > 0 then return false end
    local events = releaseKey(chr)  -- must call before setHyperMode
    setHyperMode()
    return true, events
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
