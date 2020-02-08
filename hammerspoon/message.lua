exports = {}

local tween = require 'tween'

local timer = nil
local fadeTime = .1
local margin = 20
local paddingX = 15
local paddingY = 10

local text = hs.styledtext.new(' ', {
  color = {white = 1},
  font = {name = hs.styledtext.defaultFonts.label, size = 20},
})
local canvas = hs.canvas.new({x = 0, y = 0, w = 100, h = 100}):appendElements({
  type = 'rectangle',
  action = 'fill',
  fillColor = {black = 1, alpha = 2/3},
  roundedRectRadii = {xRadius = 7, yRadius = 7}
}, {
  type = 'text', text = text
})
local canvasText = canvas[2]

local fadeInTween = tween.new(0, 1, fadeTime, function(v) canvas:alpha(v) end)
local fadeOutTween = tween.new(1, 0, fadeTime, function(v) canvas:alpha(v) end)


local function reFrame()
  local size = canvas:minimumTextSize(text)
  local frame = {w = size.w + paddingX * 2, h = size.h + paddingY * 2}
  local screen = hs.screen.mainScreen():fullFrame()
  frame.x = screen.w - frame.w - margin
  frame.y = screen.h - frame.h - margin
  canvas:frame(frame)
  canvasText.frame.x = paddingX
  canvasText.frame.y = paddingY
end

function exports.set(msg)
  msg = msg and #msg > 0 and msg or ' '
  text = text:setString(msg)
  canvasText.text = text
  reFrame()
end

function exports.show(msg, n)
  n = n or 0
  exports.set(msg)

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
