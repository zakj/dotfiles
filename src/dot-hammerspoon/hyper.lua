local tween = require 'tween'
local util = require 'util'

local MODIFIER = 'cmd'
local MODS = { 'alt', 'cmd', 'ctrl', 'shift' }

local State = {
  IDLE = {},
  SINGLE_PRESS = {},
  HYPER = {},
  HYPER_RELEASE = {},
  HYPER_TIMEOUT = {},
}

local Message = {
  MOD_DOWN = {},
  MOD_UP = {},
  MOD_OTHER = {},
  KEY_UP = {},
  IDLE_TIMEOUT = {},
  HYPER_TIMEOUT = {},
}

local function makeKeyIcon()
  local self = {}
  local fgColor = { red = 0.866, green = 0.866, blue = 0.866 }
  local size = 50
  local padding = 25
  local containerSize = size + padding * 2
  local borderWidth = 2
  local radius = 7

  local c = hs.canvas.new({ x = 0, y = 0, w = containerSize, h = containerSize })
  c:appendElements({
    type = 'rectangle',
    action = 'fill',
    fillColor = fgColor,
    roundedRectRadii = { xRadius = radius, yRadius = radius },
    withShadow = true,
    shadow = {
      blurRadius = 10,
      color = { alpha = 1 / 4 },
      offset = { h = -3, w = 0 },
    },
    padding = padding,
  }, {
    type = 'rectangle',
    action = 'fill',
    fillGradient = 'linear',
    fillGradientAngle = 90,
    fillGradientColors = {
      { red = 0.25,  green = 0.25,  blue = 0.25 },
      { red = 0.133, green = 0.133, blue = 0.133 },
    },
    frame = {
      x = padding + borderWidth,
      y = padding + borderWidth,
      w = size - borderWidth * 2,
      h = size - borderWidth * 2,
    },
    roundedRectRadii = { xRadius = radius - borderWidth, yRadius = radius - borderWidth },
  }, {
    type = 'text',
    text = '✦',
    textColor = fgColor,
    frame = { x = padding, y = size / 2 + 8, w = size, h = size },
    textAlignment = 'center',
    textSize = 27,
  })

  local enterTween = tween.new(0, 1, 0.12, function(v) c:alpha(v) end)
  local exitTween = tween.new(1, 0, 0.18, function(v) c:alpha(v) end)

  function self.show()
    local frame = c:frame()
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:fullFrame()
    frame.x = (screenFrame.w - frame.w) / 2
    frame.y = (screenFrame.h - frame.h) * 4 / 5
    c:frame(screen:localToAbsolute(frame))
    enterTween:cancel()
    if exitTween:running() then
      exitTween:onComplete(function() end)
      exitTween:cancel()
    end
    enterTween:start()
    c:show()
  end

  function self.hide()
    enterTween:cancel()
    if exitTween:running() then return end
    exitTween:start()
    exitTween:onComplete(function() c:hide() end)
  end

  return self
end

local function startMachine()
  local state = State.IDLE
  local idleTimer
  local hyperTimer
  local keyIcon = makeKeyIcon()
  local arrowKeys = { 123, 124, 125, 126 }
  local arrowMods = hs.fnutils.concat({ 'fn' }, MODS)

  local hyperEmit = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
    -- If this is not a synthetic hyper event, emit one.
    if not e:getFlags():contain(MODS) then
      local code = e:getKeyCode()
      -- Hammerspoon isn't able to emit arrow key events without adding the 'fn' modifier.
      -- https://github.com/Hammerspoon/hammerspoon/issues/1946
      local mods = util.fif(hs.fnutils.contains(arrowKeys, code), arrowMods, MODS)
      hs.eventtap.keyStroke(mods, e:getKeyCode(), 50000)
      return true -- suppress original event
    end
  end)

  local function exitHyper()
    keyIcon:hide()
    hyperEmit:stop()
    return State.IDLE
  end

  local stateMap = {
    [State.IDLE] = {
      [Message.MOD_DOWN] = function(event)
        idleTimer:start()
        return State.SINGLE_PRESS
      end,
    },
    [State.SINGLE_PRESS] = {
      [Message.IDLE_TIMEOUT] = State.IDLE,
      [Message.MOD_OTHER] = State.IDLE,
      [Message.KEY_UP] = State.IDLE,
      [Message.MOD_DOWN] = function(event)
        hyperTimer:start()
        keyIcon:show()
        hyperEmit:start()
        return State.HYPER
      end,
    },
    [State.HYPER] = {
      [Message.MOD_UP] = State.HYPER_RELEASE,
      [Message.HYPER_TIMEOUT] = State.HYPER_TIMEOUT,
    },
    [State.HYPER_RELEASE] = {
      [Message.MOD_DOWN] = function(event)
        hyperTimer:start()
        return State.HYPER
      end,
      [Message.HYPER_TIMEOUT] = exitHyper,
    },
    [State.HYPER_TIMEOUT] = {
      [Message.MOD_UP] = exitHyper,
    },
  }

  local function handleMessage(message, event)
    local handler = stateMap[state][message]
    if type(handler) == "function" then
      state = handler(event) or state
    elseif type(handler) == "table" then
      state = handler
    end
  end

  idleTimer = hs.timer.delayed.new(0.2, function() handleMessage(Message.IDLE_TIMEOUT) end)
  hyperTimer = hs.timer.delayed.new(0.5, function() handleMessage(Message.HYPER_TIMEOUT) end)

  return handleMessage
end

local function init()
  local self = { mods = MODS }
  local send = startMachine()

  local flagsTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    local flags = e:getFlags()
    if flags:containExactly({ MODIFIER }) then
      send(Message.MOD_DOWN)
    elseif not flags:contain({ MODIFIER }) then
      send(Message.MOD_UP)
    end
    if util.len(flags) > 1 or (util.len(flags) > 0 and not flags:contain({ MODIFIER })) then
      send(Message.MOD_OTHER)
    end
  end)

  local keyUpTap = hs.eventtap.new({ hs.eventtap.event.types.keyUp }, function(e)
    send(Message.KEY_UP)
  end)

  function self.start()
    flagsTap:start()
    keyUpTap:start()
  end

  function self.stop()
    flagsTap:stop()
    keyUpTap:stop()
  end

  return self
end

return init()
