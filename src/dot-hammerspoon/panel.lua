local tween = require("tween")

---@class Panel
---@field header string
---@field content {type: "text" | "symbol" | "table"}
local Panel = { pos = {}, anim = {} }
Panel.__index = Panel

-- Needed to avoid clipping the box shadow on the outer frame.
Panel.SHADOW_PADDING = 30

function Panel.new()
  local self = setmetatable({}, Panel)
  local cornerRadius = 12
  local borderWidth = 1
  self.currentTween = nil
  self.positionFunc = nil

  -- Position and size will be adjusted later based on content.
  self.canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })

  -- We want a subtle border, but canvas doesn't support that directly. Fake it
  -- by adding another box underneath.
  self.canvas:appendElements({
    {
      type = "rectangle",
      action = "fill",
      fillColor = { alpha = 0.15 },
      roundedRectRadii = { xRadius = cornerRadius, yRadius = cornerRadius },
      withShadow = true,
      shadow = { blurRadius = 10, color = { alpha = 2 / 3 }, offset = { h = -8, w = 0 } },
      frame = { x = 0, y = 0, w = 0, h = 0 }
    },
    {
      type = "rectangle",
      action = "fill",
      fillColor = { red = .9, green = .9, blue = .9, alpha = 0.95 },
      roundedRectRadii = { xRadius = cornerRadius - borderWidth, yRadius = cornerRadius - borderWidth },
      frame = { x = borderWidth, y = borderWidth, w = 0, h = 0 }
    }
  })

  return self
end

---@param elements table[]
---@param options? {padding?: number}
---@return nil
function Panel:setElements(elements, options)
  if not self.canvas then error('no canvas on panel') end
  options = options or {}

  -- Clear previous content elements (skip border and background).
  -- Iterate backwards because hs.canvas forbids sparse tables.
  for i = #self.canvas, 3, -1 do
    self.canvas[i] = nil
  end

  local padding = options.padding or 0
  local width = 0
  local height = 0
  for _, src in ipairs(elements) do
    local element = hs.fnutils.copy(src)
    if element.frame then
      width = math.max(width, element.frame.x + element.frame.w)
      height = math.max(height, element.frame.y + element.frame.h)
      element.frame.x = element.frame.x + padding + Panel.SHADOW_PADDING
      element.frame.y = element.frame.y + padding + Panel.SHADOW_PADDING
    end
    self.canvas:appendElements(element)
  end

  width = width + padding * 2
  height = height + padding * 2

  self.canvas:size({ w = width + Panel.SHADOW_PADDING * 2, h = height + Panel.SHADOW_PADDING * 2 })
  self.canvas[1].frame = { x = Panel.SHADOW_PADDING, y = Panel.SHADOW_PADDING, w = width, h = height }
  self.canvas[2].frame = { x = Panel.SHADOW_PADDING + 1, y = Panel.SHADOW_PADDING + 1, w = width - 2, h = height - 2 }

  if self.positionFunc then self.positionFunc(self) end
end

function Panel:position(positionFunc)
  self.positionFunc = positionFunc
end

-- Helper methods for visual coordinates (excludes shadow)
function Panel:getVisualFrame()
  local canvasFrame = self.canvas:frame()
  return {
    x = canvasFrame.x + Panel.SHADOW_PADDING,
    y = canvasFrame.y + Panel.SHADOW_PADDING,
    w = canvasFrame.w - Panel.SHADOW_PADDING * 2,
    h = canvasFrame.h - Panel.SHADOW_PADDING * 2
  }
end

function Panel:setVisualPosition(x, y)
  self.canvas:topLeft({ x = x - Panel.SHADOW_PADDING, y = y - Panel.SHADOW_PADDING })
end

function Panel:show(animationFunc)
  if self:isShowing() then return nil end
  if self.positionFunc then self.positionFunc(self) end
  self.canvas:show()
  animationFunc = animationFunc or Panel.anim.popIn
  return self:animate(animationFunc)
end

function Panel:hide(animationFunc)
  if not self:isShowing() then return nil end

  animationFunc = animationFunc or Panel.anim.popOut
  local anim = self:animate(animationFunc)
  if anim then
    anim:onComplete(function() self.canvas:hide() end)
  else
    self.canvas:hide()
  end
  return anim
end

function Panel:delete()
  if self.currentTween then
    self.currentTween:cancel()
    self.currentTween = nil
  end

  local function deleteCanvas()
    if self.canvas then
      self.canvas:delete()
      self.canvas = nil
    end
  end

  local anim = self:hide()
  if anim then
    anim:onComplete(deleteCanvas)
  else
    deleteCanvas()
  end
end

function Panel:animate(createTweenCallback)
  if not self.canvas then return nil end
  if self.currentTween then self.currentTween:cancel() end
  local newTween = createTweenCallback(self.canvas)
  newTween:start()
  self.currentTween = newTween
  return newTween
end

function Panel:containsPoint(x, y)
  if not self:isShowing() then return false end

  local frame = self:getVisualFrame()
  return x >= frame.x and x <= frame.x + frame.w and
      y >= frame.y and y <= frame.y + frame.h
end

function Panel:isShowing()
  return self.canvas and self.canvas:isShowing()
end

-- Position helpers ----

---@return function
function Panel.pos.center()
  return function(panel)
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local visualFrame = panel:getVisualFrame()

    panel:setVisualPosition(
      (screenFrame.w - visualFrame.w) / 2,
      (screenFrame.h * 0.4) - (visualFrame.h / 2)
    )
  end
end

---@return function
function Panel.pos.absolute(x, y)
  return function(panel)
    panel:setVisualPosition(x, y)
  end
end

---@param other Panel
---@param offset {x: number, y: number, align?: "center"}
---@return function
function Panel.pos.relativeTo(other, offset)
  offset = offset or {}
  return function(panel)
    local visualFrame = other:getVisualFrame()
    local x = visualFrame.x + visualFrame.w + (offset.x or 0)
    local y = visualFrame.y + (offset.y or 0)

    -- TODO maybe y = "center" instead?
    if offset.align == "center" then
      local targetFrame = panel:getVisualFrame()
      y = visualFrame.y + visualFrame.h / 2 - targetFrame.h / 2
    end

    panel:setVisualPosition(x, y)
  end
end

-- Animation helpers ----

function Panel.anim.popIn(canvas)
  local finalPos = canvas:topLeft()
  canvas:alpha(0)
  canvas:topLeft({ x = finalPos.x, y = finalPos.y + 10 })

  return tween.new(0, 1, 0.15, function(progress)
    if canvas then
      canvas:alpha(progress)
      canvas:topLeft({ x = finalPos.x, y = (finalPos.y + 10) + progress * -10 })
    end
  end)
end

function Panel.anim.popOut(canvas)
  local startPos = canvas:topLeft()

  return tween.new(0, 1, 0.12, function(progress)
    if canvas then
      canvas:alpha(1 - progress)
      canvas:topLeft({ x = startPos.x, y = startPos.y + progress * 8 })
    end
  end)
end

function Panel.anim.shake(canvas)
  local originalPos = canvas:topLeft()
  local shakeDistance = 8

  return tween.new(0, 1, 0.6, function(progress)
    if canvas then
      local cycles = 3
      local rampUpTime = 0.1
      local amplitude = progress < rampUpTime and (progress / rampUpTime) or 1

      -- Calculate damping based on cycles, but after ramp-up
      local adjustedProgress = math.max(0, (progress - rampUpTime) / (1 - rampUpTime))
      local cycleProgress = adjustedProgress * cycles
      local completedCycles = math.floor(cycleProgress)
      local damping = math.max(0.1, 1 - (completedCycles / cycles)) -- Keep some minimum amplitude

      local offset = math.sin(progress * cycles * 2 * math.pi) * shakeDistance * amplitude * damping
      canvas:topLeft({ x = originalPos.x + offset, y = originalPos.y })
    end
  end)
end

return Panel
