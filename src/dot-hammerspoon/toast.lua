local tween = require 'tween'

local fadeTime = .2
local margin = 20
local paddingX = 15
local paddingY = 10
local toasts = {}

-- TODO should append the rectangle here, but then copy fails?
local baseCanvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
    :canvasMouseEvents(true)
    :clickActivating(false)
local baseText = hs.styledtext.new(' ', {
  color = { white = 1 },
  font = { name = hs.styledtext.defaultFonts.label, size = 20 },
})


local function reposition(inserted)
  local screen = hs.screen.mainScreen()
  local frame = screen:fullFrame()
  local yOffset = margin

  for i = #toasts, 1, -1 do
    local canvas = toasts[i]
    local size = canvas:frame()
    local curPos = canvas:topLeft()
    local pos = {
      x = frame.w - margin - size.w,
      y = frame.h - yOffset - size.h
    }
    yOffset = yOffset + size.h + margin

    if canvas == inserted then
      canvas:topLeft(screen:localToAbsolute(pos))
    else
      tween.new(curPos.x, pos.x, fadeTime, function(x) pos.x = x end):start()
      tween.new(curPos.y, pos.y, fadeTime, function(y)
        pos.y = y
        canvas:topLeft(screen:localToAbsolute(pos))
      end):start()
    end
  end
end

local function removeToast(canvas)
  for i, item in ipairs(toasts) do
    if item == canvas then
      table.remove(toasts, i)
    end
  end
  reposition()
  canvas:hide(fadeTime)
  hs.timer.doAfter(fadeTime, function() canvas:delete() end)
end

local function add(msg, duration)
  local canvas = baseCanvas:copy()
  table.insert(toasts, canvas)
  canvas:mouseCallback(function() removeToast(canvas) end)

  if type(msg) ~= 'string' then
    msg = hs.inspect(msg)
  end
  local text = baseText:setString(msg)
  local textSize = canvas:minimumTextSize(text)
  canvas:size({ w = textSize.w + paddingX * 2, h = textSize.h + paddingY * 2 })
  reposition(canvas)

  if duration ~= nil then
    local timer
    timer = hs.timer.doAfter(duration, function()
      removeToast(canvas)
      timer = nil -- prevent GC
    end)
  end
  canvas
      :appendElements(
        {
          type = 'rectangle',
          action = 'fill',
          fillColor = { black = 1, alpha = 2 / 3 },
          roundedRectRadii = { xRadius = 7, yRadius = 7 }
        },
        {
          type = 'text',
          text = text,
          frame = { x = paddingX, y = paddingY, w = "100%", h = "100%" }
        })
      :show(fadeTime)
end

return add
