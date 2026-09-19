local toast = require 'toast'

local exports = {}

local SETTINGS_KEY = 'caffeine.on'

-- Approximates the `wake` SF Symbol: a stroked circle with a chord above
-- center. Hammerspoon exposes no SF Symbol loader, and drawing it keeps a
-- binary out of the repo.
local DIAMETER = 13
local STROKE_RATIO = 0.085 -- of the diameter
local CHORD_RATIO = 0.425  -- of the radius, above center

local menubar

local function icon()
  local stroke = STROKE_RATIO * DIAMETER
  -- Inset by half the stroke so it falls inside the circle's bounds rather
  -- than straddling them, plus a point of padding for antialiasing.
  local radius = DIAMETER / 2 - stroke / 2
  local size = DIAMETER + 2
  local center = size / 2
  local dy = CHORD_RATIO * radius
  local halfChord = math.sqrt(radius ^ 2 - dy ^ 2)

  local canvas = hs.canvas.new({ x = 0, y = 0, w = size, h = size })
  canvas:appendElements(
    {
      type = 'circle',
      action = 'stroke',
      strokeWidth = stroke,
      radius = radius,
      center = { x = center, y = center },
    },
    {
      type = 'segments',
      action = 'stroke',
      strokeWidth = stroke,
      coordinates = {
        { x = center - halfChord, y = center - dy },
        { x = center + halfChord, y = center - dy },
      },
    }
  )
  local image = canvas:imageFromCanvas()
  canvas:delete()
  return image
end

---@param on boolean
local function updateMenubar(on)
  if menubar then menubar:delete() end
  menubar = nil
  if not on then return end

  menubar = hs.menubar.new(true, 'caffeine')
  if not menubar then return end
  menubar:setIcon(icon(), true)
  menubar:setTooltip('Caffeinated')
  menubar:setClickCallback(exports.toggle)
end

---@param on boolean
local function apply(on)
  hs.caffeinate.set('displayIdle', on)
  hs.settings.set(SETTINGS_KEY, on)
  updateMenubar(on)
end

function exports.toggle()
  local on = not hs.caffeinate.get('displayIdle')
  apply(on)
  toast(on and 'Caffeinated' or 'Decaffeinated', 1.5)
end

function exports.start()
  if hs.settings.get(SETTINGS_KEY) then apply(true) end
end

return exports
