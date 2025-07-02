local Panel = require 'panel'
local module = {}

---@type Panel[]
local toasts = {}
local timers = {} -- prevent GC

local baseText = hs.styledtext.new(' ', {
  color = { black = 1 },
  font = { name = hs.styledtext.defaultFonts.system, size = 16 },
})

local function repositionToasts()
  local margin = 20
  local screen = hs.screen.mainScreen():fullFrame()

  for i, toast in ipairs(toasts) do
    local frame = toast:frame()
    if i == 1 then
      toast:position(Panel.pos.absolute(screen.w - margin - frame.w, screen.h - margin - frame.h))
    else
      toast:position(Panel.pos.relativeTo(toasts[i - 1], 'top', { align = "end", offset = { y = -12 } }))
    end
  end
end

module.add = function(msg, duration)
  local panel = Panel.new()
  table.insert(toasts, panel)

  if type(msg) ~= 'string' then
    msg = hs.inspect(msg)
  end
  local text = baseText:setString(msg)
  local element = panel:textElement(text, { x = 0, y = 0 })
  panel:setElements({ element }, { xPadding = 16, yPadding = 8 })
  panel:mouseCallback(function() module.remove(panel) end)

  repositionToasts()

  if duration ~= nil then
    -- TODO memory leak
    table.insert(timers, hs.timer.doAfter(duration, function()
      module.remove(panel)
    end))
  end

  panel:show()
  return panel
end

module.remove = function(panel)
  for i, item in ipairs(toasts) do
    if item == panel then
      table.remove(toasts, i)
    end
  end
  repositionToasts()
  panel:delete()
end

return setmetatable(module, { __call = function(_, ...) return module.add(...) end })
