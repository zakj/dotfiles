local exports = {}

local tween = require 'tween'

local timer = nil
local fadeTime = .1
local margin = 20
local paddingX = 15
local paddingY = 10

local text = hs.styledtext.new(' ', {
  color = { white = 1 },
  font = { name = hs.styledtext.defaultFonts.label, size = 20 },
})
local canvas = hs.canvas.new({ x = 0, y = 0, w = 100, h = 100 }):appendElements({
  type = 'rectangle',
  action = 'fill',
  fillColor = { black = 1, alpha = 2 / 3 },
  roundedRectRadii = { xRadius = 7, yRadius = 7 }
}, {
  type = 'text', text = text
})
local canvasText = canvas[2]
canvasText.frame.x = paddingX
canvasText.frame.y = paddingY

local fadeInTween = tween.new(0, 1, fadeTime, function(v) canvas:alpha(v) end)
local fadeOutTween = tween.new(1, 0, fadeTime, function(v) canvas:alpha(v) end)


local function updateText(msg)
  msg = msg and #msg > 0 and msg or ' '
  text = text:setString(msg)
  canvasText.text = text

  local textSize = canvas:minimumTextSize(text)
  local msgFrame = { w = textSize.w + paddingX * 2, h = textSize.h + paddingY * 2 }
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:fullFrame()
  msgFrame.x = screenFrame.w - msgFrame.w - margin
  msgFrame.y = screenFrame.h - msgFrame.h - margin
  canvas:frame(screen:localToAbsolute(msgFrame))
end

function exports.show(msg, n)
  n = n or 0
  updateText(msg)

  if fadeOutTween:running() then
    fadeOutTween:onComplete(function() end)
    fadeOutTween:cancel()
  end
  if not canvas:isShowing() then
    canvas:show()
    n = n > 0 and n + fadeTime or 0
    fadeInTween:start()
  end
  if timer then timer:stop() end
  if n > 0 then
    timer = hs.timer.doAfter(n, exports.hide)
  end
end

function exports.hide()
  if fadeOutTween:running() then return end
  fadeOutTween:start()
  fadeOutTween:onComplete(function() canvas:hide() end)
end

return exports
