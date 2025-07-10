local tween = require("tween")

---@alias Position {x: number, y: number}
---@alias Positioner fun(panel: Panel): Position

---@class Panel
-- The tween for any currently-running animation.
---@field currentTween any|nil
-- A function used to calculate this panel's visual position.
---@field positionFunc Positioner
-- Desired absolute position (vs actual position, which varies during animations).
---@field topLeft Position
local Panel = { pos = {}, anim = {} }
Panel.__index = Panel

-- Needed to avoid clipping the box shadow on the outer frame.
Panel.SHADOW_BLUR = 10
Panel.SHADOW_OFFSET = { h = -5, w = 0 }

---@generic T: {x: number, y: number}
---@param rect `T`
---@param options? {invert?: boolean, padding?: {x: number, y: number}}
---@return T
local function addShadowPos(rect, options)
  local mult = (options and options.invert and -1) or 1
  local padding = (options and options.padding) or { x = 0, y = 0 }
  local adj = hs.fnutils.copy(rect)
  if adj.x then adj.x = adj.x + (Panel.SHADOW_BLUR + Panel.SHADOW_OFFSET.w + padding.x) * mult end
  if adj.y then adj.y = adj.y + (Panel.SHADOW_BLUR + Panel.SHADOW_OFFSET.h + padding.y) * mult end
  return adj
end

function Panel.new()
  local self = setmetatable({}, Panel)
  self.currentTween = nil
  self.positionFunc = nil
  self.topLeft = { x = 0, y = 0 }

  -- Position and size will be adjusted later based on content.
  self.canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })

  -- We want a subtle border, but canvas does a bad job rendering stroke and
  -- fill with border radius. We fake it by adding another box underneath.
  local cornerRadius = 12
  local borderWidth = 1
  self.canvas:appendElements({
    {
      type = "rectangle",
      action = "fill",
      fillColor = { alpha = 0.15 },
      roundedRectRadii = { xRadius = cornerRadius, yRadius = cornerRadius },
      withShadow = true,
      shadow = { blurRadius = Panel.SHADOW_BLUR, color = { alpha = 3 / 3 }, offset = Panel.SHADOW_OFFSET },
      frame = { x = 0, y = 0, w = 0, h = 0 }
    },
    {
      type = "rectangle",
      action = "fill",
      fillColor = { red = .9, green = .9, blue = .9, alpha = 0.95 },
      roundedRectRadii = { xRadius = cornerRadius - borderWidth, yRadius = cornerRadius - borderWidth },
      trackMouseDown = true,
    },
  })
  self.canvas:clickActivating(false)

  return self
end

---@param elements table[]
---@param options? {padding?: number, xPadding?: number, yPadding?: number}
---@return nil
function Panel:setElements(elements, options)
  options = options or {}
  local firstContentIndex = 3
  local padding = {
    x = options.xPadding or options.padding or 0,
    y = options.yPadding or options.padding or 0,
  }
  local width = 0
  local height = 0

  -- Clear previous content elements (skip border and background).
  -- Iterate backwards because hs.canvas forbids sparse tables.
  for i = #self.canvas, firstContentIndex, -1 do
    self.canvas[i] = nil
  end

  self.canvas:appendElements(elements)
  for i = firstContentIndex, #self.canvas do
    local bounds = self.canvas:elementBounds(i)
    width = math.max(width, bounds.x + bounds.w)
    height = math.max(height, bounds.y + bounds.h)
    local element = self.canvas[i]
    if element.type == 'circle' then
      element.center = addShadowPos(element.center, { padding = padding })
    elseif element.frame then
      element.frame = addShadowPos(element.frame, { padding = padding })
    end
  end

  width = width + padding.x * 2
  height = height + padding.y * 2

  self.canvas:size({ w = width + Panel.SHADOW_BLUR * 2, h = height + Panel.SHADOW_BLUR * 2 })
  self.canvas[1].frame = addShadowPos({ x = 0, y = 0, w = width, h = height })
  self.canvas[2].frame = addShadowPos({ x = 1, y = 1, w = width - 2, h = height - 2 })

  -- Reposition without animation, in case a new size would cause us to calculate a different position.
  if self.positionFunc then
    self:setTopLeft(self:positionFunc())
  end
end

---@param positionFunc Positioner|nil
function Panel:position(positionFunc)
  local isInitialPosition = self.positionFunc == nil
  if positionFunc then self.positionFunc = positionFunc end
  assert(self.positionFunc, 'missing a positionFunc')

  local oldPos = self:frame()
  local newPos = self.positionFunc(self)
  assert(newPos and newPos.x and newPos.y)

  if isInitialPosition then
    self:setTopLeft(newPos)
  elseif oldPos.x ~= newPos.x or oldPos.y ~= newPos.y then
    self.topLeft = newPos
    self:animate(function()
      return tween.new(0, 1, 0.2, function(progress)
        self:moveCanvas({
          x = oldPos.x + (newPos.x - oldPos.x) * progress,
          y = oldPos.y + (newPos.y - oldPos.y) * progress
        })
      end)
    end)
  end
end

-- Returns the *visual* frame of the panel, ignoring box-shadow padding.
---@return {x: number, y: number, w: number, h: number}
function Panel:frame()
  local canvasFrame = self.canvas:frame()
  return {
    x = self.topLeft.x,
    y = self.topLeft.y,
    w = canvasFrame.w - Panel.SHADOW_BLUR * 2,
    h = canvasFrame.h - Panel.SHADOW_BLUR * 2,
  }
end

-- Sets the *visual* top left point of the panel, accounting for box-shadow padding.
---@param point Position
function Panel:setTopLeft(point)
  self.topLeft = hs.fnutils.copy(point)
  self:moveCanvas(point)
end

-- A helper for positioning the *visual* top left point of the panel without
-- caching the new position; useful for using inside animation tweens.
---@param point Position
function Panel:moveCanvas(point)
  self.canvas:topLeft(addShadowPos(point, { invert = true }))
end

function Panel:show(animationFunc)
  if self:isShowing() then return nil end
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

function Panel:mouseCallback(callback)
  self.canvas:mouseCallback(callback)
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
  if self.currentTween then self.currentTween:cancel() end
  local newTween = createTweenCallback(self)
  newTween:onComplete(function() self.currentTween = nil end)
  newTween:start()
  self.currentTween = newTween
  return newTween
end

function Panel:isShowing()
  return self.canvas and self.canvas:isShowing()
end

-- Converts a styledText into a canvas element whose frame size is the minimum
-- necessary to fit the text.
---@generic X (number | string)
---@generic Y (number | string)
---@param styledText any
---@param position {x: `X`, y: `Y`}
---@return {type: "text", text: any, frame: {x: X, y: Y, w: number, h: number}}
function Panel:textElement(styledText, position)
  position = position or {}
  local frame = self.canvas:minimumTextSize(styledText)
  frame.x = position.x or 0
  frame.y = position.y or 0
  return { type = "text", text = styledText, frame = frame }
end

-- Position helpers ----

---@return Positioner
function Panel.pos.center()
  return function(panel)
    local screen = hs.screen.mainScreen()
    local screenFrame = screen:frame()
    local visualFrame = panel:frame()

    return {
      x = (screenFrame.w - visualFrame.w) / 2,
      y = (screenFrame.h * 0.4) - (visualFrame.h / 2),
    }
  end
end

---@return Positioner
function Panel.pos.absolute(x, y)
  return function()
    return { x = x, y = y }
  end
end

---@param other Panel
---@param side "top"|"bottom"|"left"|"right"
---@param options? {align?: "start"|"middle"|"end", offset?: {x?: number, y?: number}}
---@return Positioner
function Panel.pos.relativeTo(other, side, options)
  options = options or {}
  local align = options.align or "start"
  local offset = options.offset or {}

  return function(panel)
    local otherFrame = other:frame()
    local frame = panel:frame()
    local x, y = otherFrame.x, otherFrame.y

    if side == "top" then
      y = y - frame.h
    elseif side == "bottom" then
      y = y + otherFrame.h
    elseif side == "left" then
      x = x - frame.w
    elseif side == "right" then
      x = x + otherFrame.w
    end

    -- Nothing to do for align start.
    if align == "middle" then
      if side == "top" or side == "bottom" then
        x = x + (otherFrame.w - frame.w) / 2
      else
        y = y + (otherFrame.h - frame.h) / 2
      end
    elseif align == "end" then
      if side == "top" or side == "bottom" then
        x = x + otherFrame.w - frame.w
      else
        y = y + otherFrame.h - frame.h
      end
    end

    return { x = x + (offset.x or 0), y = y + (offset.y or 0) }
  end
end

-- Animation helpers ----

---@param panel Panel
function Panel.anim.popIn(panel)
  local finalPos = panel.topLeft
  panel.canvas:alpha(0)
  panel:moveCanvas({ x = finalPos.x, y = finalPos.y + 10 })

  return tween.new(0, 1, 0.15, function(progress)
    panel.canvas:alpha(progress)
    panel:moveCanvas({ x = finalPos.x, y = (finalPos.y + 10) - progress * 10 })
  end)
end

---@param panel Panel
function Panel.anim.popOut(panel)
  local startPos = panel.topLeft

  return tween.new(0, 1, 0.12, function(progress)
    panel.canvas:alpha(1 - progress)
    panel:moveCanvas({ x = startPos.x, y = startPos.y + progress * 8 })
  end)
end

---@param panel Panel
function Panel.anim.shake(panel)
  local originalPos = panel.topLeft
  local shakeDistance = 8

  return tween.new(0, 1, 0.6, function(progress)
    local cycles = 3
    local rampUpTime = 0.1
    local amplitude = progress < rampUpTime and (progress / rampUpTime) or 1

    -- Calculate damping based on cycles, but after ramp-up
    local adjustedProgress = math.max(0, (progress - rampUpTime) / (1 - rampUpTime))
    local cycleProgress = adjustedProgress * cycles
    local completedCycles = math.floor(cycleProgress)
    local damping = math.max(0.1, 1 - (completedCycles / cycles)) -- Keep some minimum amplitude

    local offset = math.sin(progress * cycles * 2 * math.pi) * shakeDistance * amplitude * damping
    panel:moveCanvas({ x = originalPos.x + offset, y = originalPos.y })
  end)
end

return Panel
